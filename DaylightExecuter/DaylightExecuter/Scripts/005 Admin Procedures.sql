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