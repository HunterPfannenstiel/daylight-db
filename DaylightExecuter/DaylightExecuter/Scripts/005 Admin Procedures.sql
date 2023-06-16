--item_image JSON: {publicId, imageUrl}, extra_images JSON: {publicId, imageUrl, displayOrder}[]
CREATE OR REPLACE PROCEDURE store.create_menu_item(item_name TEXT, item_price NUMERIC(4, 2), item_image JSON, item_description TEXT, OUT item_id SMALLINT,
	item_grouping_id SMALLINT DEFAULT NULL, extra_groups SMALLINT[] DEFAULT NULL, categories SMALLINT[] DEFAULT NULL, 
	subcategories SMALLINT[] DEFAULT NULL, available_weekdays SMALLINT[] DEFAULT NULL, available_range DATERANGE DEFAULT NULL, extra_images JSON DEFAULT NULL)
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
DECLARE item_image_id INTEGER;
BEGIN
	INSERT INTO store.image(image_url, public_id)
	VALUES (item_image->>'imageUrl', item_image->>'publicId')
	RETURNING image_id INTO item_image_id;

	INSERT INTO store.menu_item(name, price, image_id, description, grouping_id, availability_range)
	VALUES(item_name, item_price, item_image_id, item_description, item_grouping_id, available_range)
	RETURNING menu_item_id INTO item_id;
	
	IF extra_groups IS NOT NULL THEN
		INSERT INTO store.item_extra_group(extra_group_id, menu_item_id)
		SELECT T.extra_group_id, item_id
		FROM UNNEST(extra_groups) T(extra_group_id);
	END IF;
	IF categories IS NOT NULL THEN
		INSERT INTO store.menu_item_category(item_category_id, menu_item_id)
		SELECT T.item_category_id, item_id
		FROM UNNEST(categories) T(item_category_id);
	END IF;
	IF subcategories IS NOT NULL THEN
		INSERT INTO store.menu_item_subcategory(item_subcategory_id, menu_item_id)
		SELECT T.item_subcategory_id, item_id
		FROM UNNEST(subcategories) T(item_subcategory_id);
	END IF;
	IF available_weekdays IS NOT NULL THEN
		INSERT INTO store.weekday_availability(weekday_id, menu_item_id)
		SELECT T.weekday_id, item_id
		FROM UNNEST(available_weekdays) T(weekday_id);
	END IF;	
	IF extra_images IS NOT NULL THEN
		INSERT INTO store.image(image_url, public_id)
		SELECT I."imageUrl", I."publicId"
		FROM JSON_POPULATE_RECORDSET(NULL::store.images, extra_images) I;
			
		INSERT INTO store.menu_item_image(menu_item_id, image_id, display_order)
		SELECT item_id, I.image_id, JPR."displayOrder"
		FROM store.image I 
		JOIN JSON_POPULATE_RECORDSET(NULL::store.images, extra_images) JPR ON JPR."publicId" = I.public_id;
	END IF;	
END;
$$;	

--added extra images {publicId?, imageUrl?, displayOrder?, imageId?}
--display_image {image_id?: SMALLINT, imageUrl?: TEXT, publicId?: TEXT}
--item_details {name, price, description, groupingId, displayImage, isActive, isArchived, availabilityRange}
CREATE OR REPLACE PROCEDURE store.modify_menu_item(item_id SMALLINT, item_details JSON, add_extra_groups SMALLINT[], remove_extra_groups SMALLINT[], 
	add_categories SMALLINT[], remove_categories SMALLINT[], add_subcategories SMALLINT[], remove_subcategories SMALLINT[],
	add_weekdays SMALLINT[], remove_weekdays SMALLINT[], add_extra_images JSON, remove_extra_images INTEGER[], OUT removed_public_ids TEXT[])
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
DECLARE display_image_id INTEGER;
DECLARE old_image_id INTEGER;
BEGIN
	IF item_details IS NOT NULL THEN
		IF item_details->>'displayImage' IS NOT NULL THEN
			IF item_details->'displayImage'->>'imageId' IS NOT NULL THEN
				display_image_id := item_details->'displayImage'->>'imageId';
				
				DELETE FROM store.menu_item_image
				WHERE image_id = display_image_id;
			ELSE
				INSERT INTO store.image(image_url, public_id)
				VALUES(item_details->'displayImage'->>'imageUrl', item_details->'displayImage'->>'publicId')
				RETURNING image_id INTO display_image_id;
			END IF;
		SELECT MI.image_id INTO old_image_id FROM store.menu_item MI WHERE MI.menu_item_id = item_id;
		END IF;
		UPDATE store.menu_item
		SET name = COALESCE(item_details->>'name', name), price = COALESCE((item_details->>'price')::NUMERIC(4,2), price),
		description = COALESCE(item_details->>'description', description), grouping_id = (item_details->>'groupingId')::SMALLINT, 
		image_id = COALESCE(display_image_id, image_id), is_active = COALESCE((item_details->>'isActive')::BOOLEAN, is_active),
		is_archived = COALESCE((item_details->>'isArchived')::BOOLEAN, is_archived), availability_range = COALESCE((item_details->>'availabilityRange')::DATERANGE, availability_range)
		WHERE menu_item_id = item_id;
	END IF;
	IF add_extra_groups IS NOT NULL THEN
		INSERT INTO store.item_extra_group(extra_group_id, menu_item_id)
		SELECT T.extra_group_id, item_id
		FROM UNNEST(add_extra_groups) T(extra_group_id);
	END IF;
	IF remove_extra_groups IS NOT NULL THEN
		DELETE FROM store.item_extra_group
		WHERE extra_group_id = ANY(remove_extra_groups) AND menu_item_id = item_id;
	END IF;
	IF add_categories IS NOT NULL THEN
		INSERT INTO store.menu_item_category(item_category_id, menu_item_id)
		SELECT T.item_category_id, item_id
		FROM UNNEST(add_categories) T(item_category_id);
	END IF;
	IF remove_categories IS NOT NULL THEN
		DELETE FROM store.menu_item_category
		WHERE item_category_id = ANY(remove_categories) AND menu_item_id = item_id;
	END IF;
	IF add_subcategories IS NOT NULL THEN
		INSERT INTO store.menu_item_subcategory(item_subcategory_id, menu_item_id)
		SELECT T.item_subcategory_id, item_id
		FROM UNNEST(add_subcategories) T(item_subcategory_id);
	END IF;
	IF remove_subcategories IS NOT NULL THEN
		DELETE FROM store.menu_item_subcategory
		WHERE item_subcategory_id = ANY(remove_subcategories) AND menu_item_id = item_id;
	END IF;
	IF add_weekdays IS NOT NULL THEN
		INSERT INTO store.weekday_availability(weekday_id, menu_item_id)
		SELECT T.weekday_id, item_id
		FROM UNNEST(add_weekdays) T(weekday_id);
	END IF;
	IF remove_weekdays IS NOT NULL THEN
		DELETE FROM store.weekday_availability
		WHERE weekday_id = ANY(remove_weekdays) AND menu_item_id = item_id;
	END IF;
	IF add_extra_images IS NOT NULL THEN
		INSERT INTO store.image(image_url, public_id)
		SELECT T."imageUrl", T."publicId"
		FROM JSON_POPULATE_RECORDSET(NULL::store.images, add_extra_images) T
		WHERE "imageUrl" IS NOT NULL;
		
		INSERT INTO store.menu_item_image(menu_item_id, image_id, display_order)
		SELECT item_id, I.image_id, JPR."displayOrder"
		FROM store.image I 
		JOIN JSON_POPULATE_RECORDSET(NULL::store.images, add_extra_images) JPR ON JPR."publicId" = I.public_id;
		
		MERGE INTO store.menu_item_image T
		USING (SELECT item_id, JPR."imageId", JPR."displayOrder"
		FROM JSON_POPULATE_RECORDSET(NULL::store.images, add_extra_images) JPR
		WHERE JPR."imageId" IS NOT NULL) S ON (S."imageId" = T.image_id AND S.item_id = T.menu_item_id)
		WHEN MATCHED THEN
			UPDATE SET display_order = S."displayOrder"
		WHEN NOT MATCHED THEN
			INSERT (menu_item_id, image_id, display_order)
			VALUES(S.item_id, S."imageId", S."displayOrder");
	END IF;
	IF remove_extra_images IS NOT NULL THEN
		WITH deleted_images AS (
			DELETE FROM store.image
			WHERE image_id = ANY(remove_extra_images) 
			RETURNING public_id
		)
		SELECT array_agg(public_id) INTO removed_public_ids
		FROM deleted_images;
	END IF;
	IF old_image_id <> display_image_id THEN 
		IF NOT EXISTS (
			SELECT 1 
			FROM json_array_elements(add_extra_images) AS obj
			WHERE (obj->>'imageId')::INTEGER = old_image_id
		) THEN
			removed_public_ids := array_append(removed_public_ids, (
				SELECT I.public_id
				FROM store.image I
				WHERE I.image_id = old_image_id));
				
			DELETE FROM store.image
			WHERE image_id = old_image_id;
		END IF;
	END IF;
END;
$$;

--Extras
CREATE OR REPLACE PROCEDURE store.create_extra("name" TEXT, price NUMERIC(4,2), group_ids SMALLINT[], category_id SMALLINT, abbrev TEXT, new_extra_id OUT SMALLINT)
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
BEGIN
	INSERT INTO store.extra("name", price, extra_category_id, abbreviation)
	VALUES("name", price, category_id, abbrev)
	RETURNING extra_id INTO new_extra_id;
	
	IF group_ids IS NOT NULL THEN
		INSERT INTO store.extra_group_extra(extra_group_id, extra_id)
		SELECT T.extra_group_id, new_extra_id
		FROM UNNEST(group_ids) T(extra_group_id);
	END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE store.modify_extra("id" SMALLINT, extra_name TEXT, extra_price NUMERIC(4,2), group_info JSON, remove_group_ids SMALLINT[], category_id SMALLINT, abbrev TEXT, archived BOOLEAN)
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
BEGIN
	IF extra_name IS NOT NULL OR extra_price IS NOT NULL OR category_id IS NOT NULL OR abbrev IS NOT NULL OR archived IS NOT NULL THEN
		UPDATE store.extra
			SET "name" = COALESCE(extra_name, "name"), price = COALESCE(extra_price, price), extra_category_id = COALESCE(category_id, extra_category_id),
			abbreviation = COALESCE(abbrev, abbreviation), is_archived = COALESCE(archive, is_archived)
		WHERE extra_id = "id";
	END IF;
	
	IF group_info IS NOT NULL THEN
		MERGE INTO store.extra_group_extra T
		USING (SELECT "id", JPR."extraGroupId", JPR."displayOrder" 
			   FROM JSON_POPULATE_RECORDSET(NULL::store.extra_group_info, group_info) JPR) S 
			   ON S."id" = T.extra_id AND S."extraGroupId" = T.extra_group_id
		WHEN MATCHED THEN
			UPDATE SET display_order = S."displayOrder"
		WHEN NOT MATCHED THEN
			INSERT (extra_group_id, extra_id, display_order)
			VALUES(S."extraGroupId", S."id", S."displayOrder");
	END IF;
	
	IF remove_group_ids IS NOT NULL THEN
		DELETE FROM store.extra_group_extra
		WHERE extra_group_id = ANY(remove_group_ids) AND extra_id = "id";
	END IF;
END;
$$;
--End of Extras

--Extra Group
CREATE OR REPLACE PROCEDURE store.create_extra_group("name" TEXT, extras_info JSON, category_id SMALLINT, menu_item_ids SMALLINT[], new_group_id OUT SMALLINT)
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
BEGIN
	INSERT INTO store.extra_group(extra_category_id, "name")
	VALUES(category_id, "name")
	RETURNING extra_group_id INTO new_group_id;
	
	IF extras_info IS NOT NULL THEN
		INSERT INTO store.extra_group_extra(extra_id, extra_group_id, display_order)
		SELECT JPR."extraId", new_group_id, JPR."displayOrder"
		FROM JSON_POPULATE_RECORDSET(NULL::store.extras_info, extras_info) JPR;
	END IF;
	
	IF menu_item_ids IS NOT NULL THEN
		INSERT INTO store.item_extra_group(menu_item_id, extra_group_id)
		SELECT T.menu_item_id, new_group_id
		FROM UNNEST(menu_item_ids) T(menu_item_id);
	END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE store.modify_extra_group("id" SMALLINT, group_name TEXT, extras_info JSON, remove_extra_ids SMALLINT[], 
	category_id SMALLINT, add_menu_item_ids SMALLINT[], remove_menu_item_ids SMALLINT[])
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
BEGIN
	IF group_name IS NOT NULL OR category_id IS NOT NULL THEN
		UPDATE store.extra_group
		SET "name" = COALESCE(group_name, "name"), extra_category_id = COALESCE(category_id, extra_category_id)
		WHERE extra_group_id = "id";
	END IF;
	
	IF extras_info IS NOT NULL THEN
		INSERT INTO store.extra_group_extra(extra_id, extra_group_id, display_order)
		SELECT JPR."extraId", "id", JPR."displayOrder"
		FROM JSON_POPULATE_RECORDSET(NULL::store.extras_info, extras_info) JPR;
	END IF;
	
	IF remove_extra_ids IS NOT NULL THEN
		DELETE FROM store.extra_group_extra
		WHERE extra_id = ANY(remove_extra_ids) AND extra_group_id = "id";
	END IF;
	
	IF add_menu_item_ids IS NOT NULL THEN
		INSERT INTO store.item_extra_group(menu_item_id, extra_group_id)
		SELECT T.menu_item_id, "id"
		FROM UNNEST(add_menu_item_ids) T(menu_item_id);
	END IF;
	
	IF remove_menu_item_ids IS NOT NULL THEN
		DELETE FROM store.item_extra_group
		WHERE menu_item_id = ANY(remove_menu_item_ids) AND extra_group_id = "id";
	END IF;
END;
$$;
--End of Extra Group

--Extra Category
CREATE OR REPLACE PROCEDURE store.add_new_extras_to_category(category_id SMALLINT, new_extras JSON)
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
DECLARE elem JSON;
DECLARE extra_id SMALLINT;
BEGIN
	IF new_extras IS NOT NULL THEN
		FOR elem IN SELECT * FROM JSON_ARRAY_ELEMENTS(new_extras)
		LOOP
			BEGIN
				CALL store.create_extra(elem->>'name', (elem->>'price')::NUMERIC(4,2), NULL, category_id, elem->>'abbreviation', extra_id);
			END;
		END LOOP;
	END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE store.create_extra_category("name" TEXT, new_extras JSON, new_id OUT SMALLINT)
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
DECLARE elem JSON;
BEGIN
	INSERT INTO store.extra_category("name")
	VALUES("name")
	RETURNING extra_category_id INTO new_id;
	
	CALL store.add_new_extras_to_category(new_id, new_extras);
END;
$$;

CREATE OR REPLACE PROCEDURE store.modify_extra_category("id" SMALLINT, new_extras JSON, add_extra_ids SMALLINT[], change_extra_ids JSON)
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
BEGIN
	CALL store.add_new_extras_to_category("id", new_extras);
	
	IF add_extra_ids IS NOT NULL THEN
		UPDATE store.extra
		SET extra_category_id = "id"
		WHERE extra_id = ANY(add_extra_ids);
	END IF;
	
	IF change_extra_ids IS NOT NULL THEN
		UPDATE store.extra
		SET extra_category_id = (tb->>'categoryId')::SMALLINT
		FROM JSON_ARRAY_ELEMENTS(change_extra_ids) tb
		WHERE extra_id = (tb->>'extraId')::SMALLINT;
	END IF;
END;
$$;
--End of Extra Category

----Item Subcategory
CREATE OR REPLACE PROCEDURE store.create_item_subcategory("name" TEXT, item_category_id SMALLINT, item_ids SMALLINT[], new_id OUT SMALLINT)
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
BEGIN
	INSERT INTO store.item_subcategory("name", item_category_id)
	VALUES("name", item_category_id)
	RETURNING item_subcategory_id INTO new_id; 
	
	IF item_ids IS NOT NULL THEN
		INSERT INTO store.menu_item_subcategory(menu_item_id, item_subcategory_id)
		SELECT T.menu_item_id, new_id
		FROM UNNEST(item_ids) T(menu_item_id);
	END IF;
END;
$$;
--End of Item Subcategory

--Item Category
CREATE OR REPLACE PROCEDURE store.add_new_subcategories_to_category(category_id SMALLINT, new_subcategories JSON)
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
DECLARE elem JSON;
DECLARE subcategory_id SMALLINT;
BEGIN
	IF new_subcategories IS NOT NULL THEN
		FOR elem IN SELECT * FROM JSON_ARRAY_ELEMENTS(new_subcategories)
		LOOP
			BEGIN
				CALL store.create_item_subcategory(elem->>'name', category_id, NULL, subcategory_id);
			END;
		END LOOP;
	END IF;
END;
$$;

--item_infos: {itemId: number, subcategory: string}
CREATE OR REPLACE PROCEDURE store.create_item_category("name" TEXT, display_order SMALLINT, new_subcategories JSON, item_infos JSON, new_id OUT SMALLINT)
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
DECLARE elem JSON;
DECLARE subcategory_id SMALLINT;
BEGIN
	INSERT INTO store.item_category("name", display_order)
	VALUES("name", display_order)
	RETURNING item_category_id INTO new_id;
	
	CALL store.add_new_subcategories_to_category(new_id, new_subcategories);
	
	IF item_infos IS NOT NULL THEN
		CREATE TEMPORARY TABLE item_data AS (
			SELECT JPR."itemId", JPR.subcategory
			FROM JSON_POPULATE_RECORDSET(NULL::store.item_infos, item_infos) JPR
		);
		
		INSERT INTO store.menu_item_subcategory(item_subcategory_id, menu_item_id)
		SELECT ISC.item_subcategory_id, I."itemId"
		FROM item_data I
		JOIN store.item_subcategory ISC ON ISC.name = I.subcategory AND ISC.item_category_id = new_id;
		
		INSERT INTO store.menu_item_category(item_category_id, menu_item_id)
		SELECT new_id, I."itemId"
		FROM item_data I;
	END IF;
END;
$$;

DROP PROCEDURE IF EXISTS store.create_extra;
CREATE OR REPLACE PROCEDURE store.create_extra()
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
BEGIN

END;
$$;
--End of Item Category