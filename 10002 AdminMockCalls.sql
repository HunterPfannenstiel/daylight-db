--Create new extra, update the extra
CALL store.create_extra('None', NULL, ARRAY[1, 2]::SMALLINT[], 1::SMALLINT, NULL, NULL);

--group_info: {"extraGroupId": 3, "displayOrder": 20}
CALL store.modify_extra(30::SMALLINT, NULL, 0.01, '[{"extraGroupId": 3, "displayOrder": 20}]', ARRAY[1, 2]::SMALLINT[], NULL, 'No');
--

--Create extra group

--Extras info: {extraId: number, displayOrder: number}
CALL store.create_extra_group('Test Toppings', '[{"extraId": 2, "displayOrder": 1}, {"extraId": 3}]', 2::SMALLINT, ARRAY[18]::SMALLINT[], NULL);

CALL store.modify_extra_group(13::SMALLINT, 'Test Fillings', '[{"extraId": 4, "displayOrder": 2}]', ARRAY[2, 3]::SMALLINT[], 3::SMALLINT, 
							 ARRAY[19, 20]::SMALLINT[], ARRAY[18]::SMALLINT[]);
							 
--SELECT * FROM store.fetch_item_details('Kolache');
--



--Create Extra Category
--new_extras: {name: string, price: number, abbreviation: string}
CALL store.create_extra_category('Cream', '[{"name": "Cream One"}, {"name": "Cream Two", "price": 1.09, "abbreviation": "C2"}]', NULL);

CALL store.modify_extra_category(14::SMALLINT, '[{"name": "Cream Three"}]', ARRAY[1, 2]::SMALLINT[], '[{"extraId": 3, "categoryId": 6}]');
--

--Create Item Category/Subcategory
CALL store.create_item_category('New Category', NULL, '[{"name": "New Subb Cat"}]', '[{"itemId": 1, "subcategory": "New Subb Cat"}]', NULL);

CALL store.create_item_subcategory('Goods', 1::SMALLINT, ARRAY[15, 16]::SMALLINT[], NULL);

CALL store.modify_item_subcategory(1::SMALLINT, NULL, NULL, ARRAY[16]::SMALLINT[], ARRAY[1, 6]::SMALLINT[]);

CALL store.modify_item_category(1::SMALLINT, NULL, NULL, NULL, NULL, ARRAY[3]::SMALLINT[], NULL, ARRAY[16, 5]::SMALLINT[]);
SELECT * FROM store.menu_item_category MIC WHERE MIC.item_category_id = 1
SELECT * FROM store.item_subcategory "IS" WHERE "IS".item_category_id = 1
SELECT * FROM store.menu_item_subcategory MIS WHERE MIS.item_subcategory_id = 3;
--

--Create grouping
CALL store.create_item_grouping('Test Grouping', 10.12, 3::SMALLINT, '{"imageUrl": "hello", "publicId": "123EE"}', ARRAY[1, 15]::SMALLINT[], NULL);

CALL store.modify_item_grouping(3::SMALLINT, 'Test', 9.00, 2::SMALLINT, '{"imageUrl": "ooo", "publicId": "eee"}', NULL, ARRAY[2]::SMALLINT[], ARRAY[15]::SMALLINT[], NULL);
--