--Create order (provide customer info), call 'create order' again with same cart but provide user info id
CALL store.create_cart(NULL, '[{"cart_item_id": 1, "menu_item_id": 21, "amount": 3}, 
					   {"cart_item_id": 2, "menu_item_id": 5, "amount": 8, "extra_ids": [9]}, 
					   {"cart_item_id": 3, "menu_item_id": 5, "amount": 20, "extra_ids": [12]},
					   {"cart_item_id": 4, "menu_item_id": 5, "amount": 3, "extra_ids": [2, 12]}]');	

--cart id: 6
--account id: 2
CALL store.create_account('test@example.com', NULL, 
'{"first_name": "Joshua", "last_name": "Starz", "phone_number": "(620) starsssz"}'::JSON);

--cart id 3

CALL store.create_order(6, 1::SMALLINT, 9::SMALLINT, NOW()::DATE, 1::SMALLINT, NULL, NULL, 2, 2);

CALL store.create_order(6, 2::SMALLINT, 7::SMALLINT, NOW()::DATE, 2::SMALLINT, NULL, 
					   '{"first_name": "Algonquin", "last_name": "Monk", "email": "alg@monkey.com", "phone_number": "(620) banana"}'::JSON);


SELECT * FROM store.order O WHERE O.cart_id = 6