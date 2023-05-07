DROP TYPE IF EXISTS store.new_cart_item;
DROP PROCEDURE IF EXISTS store.update_cart;
DROP PROCEDURE IF EXISTS store.create_cart;

CREATE TYPE store.new_cart_item AS (
	cart_item_id INTEGER,
	menu_item_id SMALLINT,
	amount INTEGER,
	extra_ids SMALLINT[]
)

CREATE OR REPLACE PROCEDURE store.update_cart("id" INTEGER, items JSON DEFAULT NULL)
LANGUAGE plpgsql AS
$$
BEGIN
	IF EXISTS (SELECT C.cart_id FROM store.cart C WHERE C.cart_id = "id" AND C.is_locked = true) THEN
		RAISE EXCEPTION 'Your cart is locked and is being processed for order. If you have not placed your order yet, please contact us.';
	END IF;
	IF items IS NOT NULL THEN
		MERGE INTO store.cart_item T
		USING (SELECT "id", I.cart_item_id, I.menu_item_id, I.amount
				FROM JSON_POPULATE_RECORDSET(NULL::store.new_cart_item, items) I) 
				AS S ON (S.id = T.cart_id AND S.cart_item_id = T.cart_item_id)
		WHEN MATCHED THEN
			UPDATE SET amount = T.amount + S.amount
		WHEN NOT MATCHED THEN
			INSERT (cart_id, cart_item_id, menu_item_id, amount)
			VALUES (S.id, S.cart_item_id, S.menu_item_id, S.amount);
		
		MERGE INTO store.cart_extra T
			USING (SELECT I.cart_item_id, "id", eId
					FROM JSON_POPULATE_RECORDSET(NULL::store.new_cart_item, items) I
					CROSS JOIN LATERAL UNNEST(I.extra_ids) AS eId) 
					AS S ON (S.id = T.cart_id AND S.cart_item_id = T.cart_item_id)
		WHEN NOT MATCHED THEN
			INSERT (cart_item_id, cart_id, extra_id)
			VALUES (S.cart_item_id, S.id, S.eId);
			
		DELETE FROM store.cart_item CI WHERE CI.cart_id = "id" AND CI.amount < 1;
	END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE store.create_cart(OUT "id" INTEGER, items JSON DEFAULT NULL)
LANGUAGE plpgsql AS
$$
BEGIN
	INSERT INTO store.cart(last_modified)
	VALUES (CURRENT_TIME)
	RETURNING cart_id INTO "id";
	CALL store.update_cart("id", items);
END;
$$;

CALL store.create_cart(NULL, '[{"cart_item_id": 1, "menu_item_id": 1, "amount": 2, "extra_ids": [2, 12]}]');
CALL store.update_cart(2, '[{"cart_item_id": 1, "amount": -82}]')

SELECT C.cart_id, CI.menu_item_id, CE.extra_id, CI.amount FROM store.cart C
LEFT JOIN store.cart_item CI ON CI.cart_id = C.cart_id
LEFT JOIN store.cart_extra CE ON CE.cart_item_id = CI.cart_item_id AND CE.cart_id = C.cart_id
WHERE CI.cart_id = 2
