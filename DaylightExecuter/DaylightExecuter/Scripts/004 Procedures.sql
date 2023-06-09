--CART PROCEDURES
CREATE OR REPLACE PROCEDURE store.check_cart_lock("id" INTEGER)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$$
BEGIN
	IF EXISTS (SELECT C.cart_id FROM store.cart C WHERE C.cart_id = "id" AND C.is_locked = true) THEN
		RAISE EXCEPTION 'Your cart is locked and is being processed for order. If you have not placed your order yet, please contact us.';
	END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE store.update_cart("id" INTEGER, items JSON DEFAULT NULL)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$$
BEGIN
	CALL store.check_cart_lock("id");
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
		UPDATE store.cart
		SET last_modified = CURRENT_TIMESTAMP
		WHERE cart_id = "id";
	END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE store.create_cart(OUT "id" INTEGER, items JSON DEFAULT NULL)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$$
BEGIN
	INSERT INTO store.cart(last_modified)
	VALUES (CURRENT_TIMESTAMP)
	RETURNING cart_id INTO "id";
	CALL store.update_cart("id", items);
END;
$$;

CREATE OR REPLACE PROCEDURE store.update_cart_lock("id" INTEGER, "lock" BOOLEAN)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$$
BEGIN
	UPDATE store.cart
	SET is_locked = "lock"
	WHERE cart_id = "id";
END;
$$;

CREATE OR REPLACE PROCEDURE store.insert_stripe_uid(user_cart_id INTEGER, stripe_id TEXT)
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
BEGIN
	CALL store.check_order_verification(user_cart_id);
	UPDATE store.cart
	SET stripe_uid = stripe_id
	WHERE cart_id = user_cart_id;
END;
$$;

--END OF CART PROCEDURES

--ORDER PROCEDURES
CREATE OR REPLACE PROCEDURE store.check_order_verification(user_cart_id INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
BEGIN
	IF EXISTS(SELECT O.order_id FROM store.order O WHERE O.cart_id = user_cart_id AND O.is_verified = true) THEN
		RAISE EXCEPTION 'This cart already has a verified order, please create a new cart.';
	END IF;
END;
$$;

	--customer_info - If customer doesn't have an account, this needs to be provided
	--order_user_info_id - If the customer has an account, this can be provided instead of 'customer_info'
CREATE OR REPLACE PROCEDURE store.create_order(order_cart_id INTEGER, order_location_id SMALLINT, 
	order_pickup_time_id SMALLINT, order_pickup_date DATE, OUT "id" INTEGER,
	customer_info JSON DEFAULT NULL, order_account_id INTEGER DEFAULT NULL, order_user_info_id INTEGER DEFAULT NULL)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$$
DECLARE customer_info_id INTEGER;
BEGIN
	IF(SELECT C.is_locked FROM store.cart C WHERE C.cart_id = order_cart_id) THEN --Card details failed and retrying, check if new user info was given	
		IF customer_info IS NOT NULL THEN
			SELECT O.customer_order_info_id INTO customer_info_id FROM store.order O WHERE O.cart_id = order_cart_id;
			IF customer_info_id IS NOT NULL THEN --There was a previous customer_order_info
				UPDATE store.customer_order_info COI
					SET first_name = CI.first_name,
					last_name = CI.last_name,
					email = CI.email,
					phone_number = CI.phone_number
				FROM 
				(SELECT * FROM JSON_POPULATE_RECORDSET(NULL::store.customer_info_t, customer_info)) CI
				WHERE COI.customer_order_info_id = customer_info_id AND EXISTS (
					SELECT COI.first_name, COI.last_name, COI.email, COI.phone_number
					EXCEPT
					SELECT CI.first_name, CI.last_name, CI.email, CI.phone_number
				);
			ELSE  --There wasn't a previous customer_order_info but now there is
				CALL store.insert_customer_order_info(customer_info, customer_info_id);
			END IF;
		UPDATE store.order O
		SET customer_order_info_id = CI.CII,
		location_id = CI.OLI,
		pickup_time_id = CI.OPI,
		pickup_date = CI.OPD,
		account_id = CI.OAI,
		user_info_id = CI.OUII
		FROM (VALUES(customer_info_id, order_location_id, order_pickup_time_id, order_pickup_date, order_account_id, order_user_info_id)) AS
			 CI(CII, OLI, OPI, OPD, OAI, OUII)
		WHERE cart_id = order_cart_id AND EXISTS
		(
			SELECT O.customer_order_info_id, O.location_id, O.pickup_time_id, O.pickup_date, O.account_id, O.user_info_id
			EXCEPT
			SELECT CI.CII, CI.OLI, CI.OPI, CI.OPD, CI.OAI, CI.OUII
		);
		END IF;
		--Check if order_user_info was given, if so update
		--Else check if customer_info remains the same as the old
	ELSE
		IF customer_info IS NOT NULL THEN
			CALL store.insert_customer_order_info(customer_info, customer_info_id);

			INSERT INTO store.order(cart_id, customer_order_info_id, location_id, pickup_time_id, pickup_date, account_id)
			VALUES(order_cart_id, customer_info_id, order_location_id, order_pickup_time_id, order_pickup_date, order_account_id)
			RETURNING order_id INTO "id";
		ELSE
			INSERT INTO store.order(cart_id, location_id, pickup_time_id, pickup_date, account_id, user_info_id)
			VALUES(order_cart_id, order_location_id, order_pickup_time_id, order_pickup_date, order_account_id, order_user_info_id)
			RETURNING order_id INTO "id";
		END IF;
	CALL store.update_cart_lock(order_cart_id, true);
	END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE store.insert_customer_order_info(customer_info JSON, OUT customer_id INTEGER)
LANGUAGE plpgsql AS
$$
BEGIN
	INSERT INTO store.customer_order_info(first_name, last_name, email, phone_number)
	VALUES((customer_info->0)->>'first_name', (customer_info->0)->>'last_name', (customer_info->0)->>'email', (customer_info->0)->>'phone_number')
	RETURNING customer_order_info_id INTO customer_id;
END;
$$;

CREATE OR REPLACE PROCEDURE store.confirm_order(confirm_cart_id INTEGER, order_subtotal NUMERIC(6,2), order_tax NUMERIC(5,2), 
	order_total NUMERIC(6,2), order_payment_processor SMALLINT, order_payment_uid TEXT, order_fee NUMERIC(5, 2) DEFAULT NULL)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$$
BEGIN
	UPDATE store.order
	SET subtotal = order_subtotal, tax = order_tax, total_price = order_total, processor_fee = order_fee, payment_processor_id = order_payment_processor, payment_uid = order_payment_uid,
		is_verified = true, error_message = NULL
	WHERE cart_id = confirm_cart_id;
	
	CALL store.update_cart_lock(confirm_cart_id, true);
	
	MERGE INTO store.cart_item T
	USING (SELECT CI.cart_id, CI.cart_item_id, (CI.amount * (MI.price)) AS subtotal,
		   COALESCE((SELECT SUM(COALESCE(E.price * CI.amount, 0))
			FROM store.cart_extra CE
			JOIN store.extra E ON E.extra_id = CE.extra_id
			WHERE CE.cart_item_id = CI.cart_item_id AND CE.cart_id = CI.cart_id
			), 0) AS extra_price
		   	FROM store.cart_item CI
			JOIN store.menu_item MI ON MI.menu_item_id = CI.menu_item_id
		  	WHERE CI.cart_id = confirm_cart_id) S ON S.cart_item_id = T.cart_item_id AND S.cart_id = T.cart_id
	WHEN MATCHED THEN
		UPDATE SET subtotal = S.subtotal + S.extra_price;
END;
$$;

CREATE OR REPLACE PROCEDURE store.set_order_error(user_cart_id INTEGER, "message" TEXT)
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
BEGIN
	UPDATE store.order
	SET error_message = "message"
	WHERE cart_id = user_cart_id;
END;
$$;
--END OF ORDER PROCEDURES

--ACCOUNT PROCEDURES
CREATE OR REPLACE PROCEDURE store.create_account(user_email TEXT, OUT "id" INTEGER, user_info JSON DEFAULT NULL)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$$
BEGIN
	INSERT INTO store.account(email)
	VALUES(user_email)
	RETURNING account_id INTO "id";
	
	IF user_info IS NOT NULL THEN
		CALL store.create_user_info(user_info->>'first_name', user_info->>'last_name', user_info->>'phone_number', "id");
	END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE store.create_user_info(user_first_name TEXT, user_last_name TEXT, user_phone_number TEXT, user_account_id INTEGER)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$$
DECLARE "id" INTEGER;
BEGIN
	INSERT INTO store.user_info(first_name, last_name, phone_number, account_id)
	VALUES(user_first_name, user_last_name, user_phone_number, user_account_id)
	RETURNING user_info_id INTO "id";
END;
$$;
--END OF ACCOUNT PROCEDURES

--Menu Procedures
--{menu_item_id: SMALLINT, extra_group_id: SMALLINT, remove: boolean}
CREATE OR REPLACE PROCEDURE store.update_item_extras(item_info JSON)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$$
DECLARE json_array JSON[] := ARRAY(SELECT json_array_elements(item_info));
DECLARE json_value JSON;
BEGIN
	FOREACH json_value IN ARRAY json_array
	LOOP
		CASE
			WHEN json_value->>'remove' = 'true' THEN
				DELETE FROM store.item_extra_group
				WHERE menu_item_id = (json_value->>'menu_item_id')::SMALLINT AND extra_group_id = (json_value->>'extra_group_id')::SMALLINT;
			ELSE
				INSERT INTO store.item_extra_group(extra_group_id, menu_item_id)
				VALUES((json_value->>'extra_group_id')::SMALLINT, (json_value->>'menu_item_id')::SMALLINT);
		END CASE;
	END LOOP;
END;
$$;
--END OF MENU PROCEDURES