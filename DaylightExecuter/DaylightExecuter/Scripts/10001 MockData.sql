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

SELECT UI.user_info_id INTO info_id FROM store.user_info UI WHERE UI.account_id = acc_id;

CALL store.create_order(cart_id, 2::SMALLINT, 9::SMALLINT, NOW()::DATE, order_id, NULL, acc_id, info_id);
CALL store.confirm_order(order_id, 124.54, 16.01, 140.55, 1::SMALLINT, '123Banana');
END $$;

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

CALL store.create_account('pfannenpayton@gmail.com', acc_id, 
'{"first_name": "Payton", "last_name": "P", "phone_number": "(620) jake"}'::JSON);

SELECT UI.user_info_id INTO info_id FROM store.user_info UI WHERE UI.account_id = acc_id;

CALL store.create_order(cart_id, 1::SMALLINT, 9::SMALLINT, NOW()::DATE, order_id, NULL, acc_id, info_id);
CALL store.confirm_order(order_id, 124.54, 16.01, 140.55, 1::SMALLINT, 'pp');


CALL store.create_cart(cart_id, '[{"cart_item_id": 1, "menu_item_id": 1, "amount": 12, "extra_ids": [2, 12]}, 
					   {"cart_item_id": 2, "menu_item_id": 3, "amount": 34, "extra_ids": [9, 12]}, 
					   {"cart_item_id": 3, "menu_item_id": 2, "amount": 43, "extra_ids": [9, 12]},
					   {"cart_item_id": 4, "menu_item_id": 10, "amount": 2}]');
CALL store.create_order(cart_id, 1::SMALLINT, 9::SMALLINT, NOW()::DATE, order_id, NULL, acc_id, info_id);
CALL store.confirm_order(order_id, 124.54, 16.01, 140.55, 1::SMALLINT, 'pp2');
END $$;

DO $$
DECLARE cart_id INTEGER;
DECLARE order_id INTEGER;
BEGIN
CALL store.create_cart(cart_id, '[{"cart_item_id": 1, "menu_item_id": 1, "amount": 12, "extra_ids": [2, 12]}, 
					   {"cart_item_id": 2, "menu_item_id": 1, "amount": 12, "extra_ids": [9, 11]}, 
					   {"cart_item_id": 3, "menu_item_id": 1, "amount": 12, "extra_ids": [8]},
					   {"cart_item_id": 4, "menu_item_id": 1, "amount": 12}]');

CALL store.create_order(cart_id, 1::SMALLINT, 9::SMALLINT, NOW()::DATE, order_id, 
					   '[{"first_name": "Algonquin", "last_name": "Monk", "email": "alg@monkey.com", "phone_number": "(620) banana"}]'::JSON);
CALL store.confirm_order(order_id, 124.54, 16.01, 140.55, 1::SMALLINT, '123Banana');
END $$;
--

--Admin mock data
INSERT INTO store.owner(email, "password")
VALUES('daylightdonutdeveloper@gmail.com', '$2b$12$ukxiJkEiWRg4.SqcFRrk7.tMSM5PMXJGlWH0OFYexnQ.6opHxBCDa');
--123donut

ALTER SEQUENCE store.team_member_team_member_id_seq RESTART WITH 1;

INSERT INTO store.team_member(email)
VALUES('hunterstatek@gmail.com'),
('pfannenstielhunter@gmail.com');

INSERT INTO store.team_member_password("password")
VALUES('$2b$12$72lo1qeGHUINKt3rfwiwweXAmuV848Xo2u1ZGxrero8GFP/r71.RC');
--donut

ALTER SEQUENCE store.role_role_id_seq RESTART WITH 1;

INSERT INTO store.role(title, description)
VALUES('Co-owner', 'The same permissions as the owner but without the ability to add new admins.'),
('Overnight', 'Grants the permission to view and print orders.');

INSERT INTO store.team_member_role(team_member_id, role_id)
VALUES(1, 1),
(2, 2);

SELECT * FROM store.menu_item_subcategory