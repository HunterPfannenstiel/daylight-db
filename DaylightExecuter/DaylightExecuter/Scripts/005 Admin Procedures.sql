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


--name, price, description, display_image, grouping id, is_active, is_archived, availability range
--added extra groups SMALLINT[], removed extra groups SMALLINT[], added categories SMALLINT[], removed categories SMALLINT[]
--added subcategories, removed subcategories, added weekdays SMALLINT[], removed weekdays SMALLINT[], 
--added extra images {publicId?, imageUrl?, displayOrder?, imageId?}, removed extra images SMALLINT[]
--display_image {image_id?: SMALLINT, imageUrl?: TEXT, publicId?: TEXT}

--When we'll remove an image: display image changes and old display_image_id is not in 'add_extra_images' 
--item_details {name, price, description, groupingId, displayImage, isActive, isArchived, availabilityRange}
CREATE OR REPLACE PROCEDURE store.modify_menu_item(item_id SMALLINT, item_details JSON, add_extra_groups SMALLINT[], remove_extra_groups SMALLINT[], 
	add_weekdays SMALLINT[], remove_weekdays SMALLINT[], add_extra_images JSON[], remove_extra_images INTEGER[], OUT removed_public_ids TEXT[])
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
DECLARE display_image_id INTEGER;
DECLARE old_image_id INTEGER;
DECLARE add_image_info JSON[];
BEGIN
	IF item_details IS NOT NULL THEN
		IF item_details->display_image IS NOT NULL THEN
			IF item_details->display_image->>'image_id' IS NOT NULL THEN
				display_image_id := display_image->>'image_id';
			ELSE
				INSERT INTO store.image(image_url, public_id)
				VALUES(item_details->display_image->>'imageUrl', item_details->display_image->>'publicId')
				RETURNING image_id INTO display_image_id;
			END IF;
		SELECT MI.image_id INTO old_image_id FROM store.menu_item MI WHERE MI.menu_item_id = item_id;
		END IF;
		UPDATE store.menu_item
		SET name = COALESCE(item_details->>'name', name), price = COALESCE(item_details->>'price', price),
		description = COALESCE(item_details->>'description', description), grouping_id = item_details->>'groupingId', 
		image_id = COALESCE(display_image_id, image_id), is_active = COALESCE(item_details->>'isActive', is_active),
		is_archived = COALESCE(item_details->>'isArchived', is_archived), availability_range = COALESCE(item_details->>'availabilityRange', availability_range)
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
	IF add_weekdays IS NOT NULL THEN
		INSERT INTO store.weekday_availability(weekday_id, menu_item_id)
		SELECT T.weekday_id, item_id
		FROM UNNEST(add_weekdays) T(weekday_id);
	END IF;
	IF remove_weekdays IS NOT NULL THEN
		DELETE FROM store.weekday_availability
		WHERE weekday_id = ANY(remove_weekdays) AND menu_item_id = item_id;
	END IF;
	IF add_extra_images IS NOT NULL
		INSERT INTO store.image(image_url, public_id)
		SELECT T."imageUrl", T."publicId"
		FROM JSON_POPULATE_RECORDSET(NULL::store.images, add_extra_images) T("publicId", "imageUrl", "displayOrder", "imageId")
		WHERE "imageUrl" IS NOT NULL;
		
		INSERT INTO store.menu_item_image(menu_item_id, image_id, display_order)
		SELECT item_id, I.image_id, JPR."displayOrder"
		FROM store.image I 
		JOIN JSON_POPULATE_RECORDSET(NULL::store.images, add_extra_images) JPR ON JPR."publicId" = I.public_id;
		
		INSERT INTO store.menu_item_image(menu_item_id, image_id, display_order)
		SELECT item_id, JPR."imageId", JPR."displayOrder"
		FROM JSON_POPULATE_RECORDSET(NULL::store.images, add_extra_images) JPR
		WHERE JPR."imageId" IS NOT NULL;
	END IF;
	IF remove_extra_images IS NOT NULL THEN
		DELETE FROM store.menu_item_image
		WHERE image_id = ANY(remove_extra_images) AND menu_item_id = item_id;
	END IF;
END;
$$;
--TODO: return removed public ids (check if old_image_id is not null and in 'add_extra_images'), remove images from image table