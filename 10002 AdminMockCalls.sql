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
--