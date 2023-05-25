DROP PROCEDURE IF EXISTS store.create_menu_item;
CREATE OR REPLACE PROCEDURE store.create_menu_item(item_name TEXT, item_price NUMERIC(4, 2), item_image TEXT, item_description TEXT, 
	item_grouping_id SMALLINT DEFAULT NULL, extra_groups SMALLINT[] DEFAULT NULL, categories SMALLINT[] DEFAULT NULL, 
	subcategories SMALLINT[] DEFAULT NULL, available_weekdays SMALLINT[] DEFAULT NULL, available_range DATERANGE DEFAULT NULL)
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
DECLARE item_id SMALLINT; 
DECLARE	range_id SMALLINT;
BEGIN
	INSERT INTO store.menu_item(name, price, image, description, grouping_id)
	VALUES(item_name, item_price, item_image, item_description, item_grouping_id)
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
	IF available_range IS NOT NULL THEN
		MERGE INTO store.range_availability T
		USING (SELECT available_range AS "range") S
			ON (S.range = T.range_availability)
		WHEN NOT MATCHED THEN
			INSERT (range_availability)
			VALUES(S.range);
			
		SELECT RA.range_availability_id INTO range_id 
		FROM store.range_availability RA
		WHERE RA.range_availability = available_range;
		
		INSERT INTO store.item_range_availability(range_availability_id, menu_item_id)
		VALUES(range_id, item_id);
	END IF;		
END;
$$;