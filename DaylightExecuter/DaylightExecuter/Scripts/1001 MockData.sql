--Cart				   
CALL store.create_cart(NULL, '[{"cart_item_id": 1, "menu_item_id": 21, "amount": 3}, 
					   {"cart_item_id": 2, "menu_item_id": 5, "amount": 8, "extra_ids": [9]}, 
					   {"cart_item_id": 3, "menu_item_id": 5, "amount": 20, "extra_ids": [12]},
					   {"cart_item_id": 4, "menu_item_id": 5, "amount": 3, "extra_ids": [2, 12]}]');				  
--

--Orders
DO $$
DECLARE cart_id INTEGER;
DECLARE acc_id INTEGER;
DECLARE info_id INTEGER;
DECLARE order_id INTEGER;
BEGIN
CALL store.create_cart(cart_id, '[{"cart_item_id": 1, "menu_item_id": 1, "amount": 12, "extra_ids": [2, 12]}, 
					   {"cart_item_id": 2, "menu_item_id": 3, "amount": 34, "extra_ids": [9, 12]}, 
					   {"cart_item_id": 3, "menu_item_id": 2, "amount": 43, "extra_ids": [9, 12]},
					   {"cart_item_id": 4, "menu_item_id": 10, "amount": 2}]');

CALL store.create_account('jstarz@monkey.com', acc_id, 
'{"first_name": "Joshua", "last_name": "Starz", "phone_number": "(620) starsssz"}'::JSON);

SELECT AUI.user_info_id INTO info_id FROM store.account_user_info AUI WHERE AUI.account_id = acc_id;

CALL store.create_order(cart_id, 1::SMALLINT, 9::SMALLINT, NOW()::DATE, order_id, NULL, acc_id, info_id);
CALL store.confirm_order(order_id, 124.54, 16.01, 140.55, 1::SMALLINT, '123Banana');
END $$;

DO $$
DECLARE cart_id INTEGER;
DECLARE order_id INTEGER;
BEGIN
CALL store.create_cart(cart_id, '[{"cart_item_id": 1, "menu_item_id": 1, "amount": 12, "extra_ids": [2, 12]}, 
					   {"cart_item_id": 2, "menu_item_id": 1, "amount": 12, "extra_ids": [9, 11]}, 
					   {"cart_item_id": 3, "menu_item_id": 1, "amount": 12, "extra_ids": [9]},
					   {"cart_item_id": 4, "menu_item_id": 1, "amount": 12}]');

CALL store.create_order(cart_id, 1::SMALLINT, 9::SMALLINT, NOW()::DATE, order_id, 
					   '[{"first_name": "Algonquin", "last_name": "Monk", "email": "alg@monkey.com", "phone_number": "(620) banana"}]'::JSON);
CALL store.confirm_order(order_id, 124.54, 16.01, 140.55, 1::SMALLINT, '123Banana');
END $$;
--