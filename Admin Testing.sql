--Create Item
CALL store.create_menu_item('Glizzy Hotdog', 1.00, '{"imageUrl": "Test", "publicId": "EEE"}', 'The Glizzy Hot Dog', NULL, 1::SMALLINT, '{1, 2}'::SMALLINT[], '{1}'::SMALLINT[], '{1}'::SMALLINT[], 
	'{1, 5}'::SMALLINT[], '[2023-05-24, 2023-05-30)', '[{"publicId": "id9", "imageUrl": "url1", "displayOrder": 1}, {"publicId": "id10", "imageUrl": "url2", "displayOrder": 2}]');
	
SELECT *
FROM store.menu_item MI
WHERE MI.menu_item_id = 23
	
--Modify Details
CALL store.modify_menu_item(23::SMALLINT, '{"name": "Glizzy Hawtdog", "price": 1.20, "description": "Glizzy Description", "displayImage": {"imageUrl": "ImageUrl", "publicId": "pubDisplay"}, "isActive": "false", "availabilityRange": null}'::JSON,
	NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::JSON, NULL::INTEGER[], NULL);

SELECT * 
FROM store.menu_item MI 
WHERE MI.menu_item_id = 23

--Modify Extras
CALL store.modify_menu_item(23::SMALLINT, NULL::JSON, '{3, 4}'::SMALLINT[], '{1, 2}'::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], 
	NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::JSON, NULL::INTEGER[], NULL)

SELECT IEG.extra_group_id
FROM store.menu_item MI 
JOIN store.item_extra_group IEG ON IEG.menu_item_id = MI.menu_item_id
WHERE MI.menu_item_id = 23

--Modify Categories
CALL store.modify_menu_item(23::SMALLINT, NULL::JSON, NULL::SMALLINT[], NULL::SMALLINT[], '{2, 3}'::SMALLINT[], '{1}'::SMALLINT[], 
	NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::JSON, NULL::INTEGER[], NULL)

SELECT *
FROM store.menu_item_category MIC
WHERE MIC.menu_item_id = 23

--Modify Subcategories
CALL store.modify_menu_item(23::SMALLINT, NULL::JSON, NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], 
	'{2, 3}'::SMALLINT[], '{1}'::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::JSON, NULL::INTEGER[], NULL)
	
SELECT *
FROM store.menu_item_subcategory MIS
WHERE MIS.menu_item_id = 23

--Modify Weekdays
CALL store.modify_menu_item(23::SMALLINT, NULL::JSON, NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], 
	'{7}'::SMALLINT[], '{1, 5}'::SMALLINT[], NULL::JSON, NULL::INTEGER[], NULL)

SELECT *
FROM store.weekday_availability WA
WHERE WA.menu_item_id = 23

--Modify Images
CALL store.modify_menu_item(23::SMALLINT, NULL::JSON, NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], 
	NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], 
	'[{"imageUrl": "ImageUrl", "publicId": "pub1", "displayOrder": "3"}]'::JSON, '{24}'::INTEGER[], NULL)

SELECT *
FROM store.menu_item_image MII
WHERE MII.menu_item_id = 23

--Modify Display image to an existing image (should remove existing image from menu_item_image and also delete old image)
CALL store.modify_menu_item(23::SMALLINT, '{"displayImage": {"imageId": 25}}'::JSON,
	NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::JSON, NULL::INTEGER[], NULL);

SELECT *
FROM store.menu_item MI
WHERE MI.menu_item_id = 23

SELECT *
FROM store.menu_item_image
WHERE menu_item_id = 23

SELECT * FROM store.image

--Modify Display image to an existing image and add old display image to extra image
CALL store.modify_menu_item(23::SMALLINT, '{"displayImage": {"imageId": 26}}'::JSON,
	NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], NULL::SMALLINT[], 
	'[{"imageId": 25, "displayOrder": "3"}]'::JSON, NULL::INTEGER[], NULL);
	
SELECT *
FROM store.menu_item MI
WHERE MI.menu_item_id = 23

SELECT *
FROM store.menu_item_image
WHERE menu_item_id = 23