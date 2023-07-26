--Fetches all of the items within a category (or all items if no category)
CREATE OR REPLACE FUNCTION store.fetch_menu_items(category TEXT DEFAULT NULL, subcategory TEXT DEFAULT NULL)
RETURNS SETOF store.menu_items
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	IF (category IS NULL) THEN
		RETURN QUERY
		SELECT MD.name, MD.image_url, MD.price FROM store.vw_menu_item_details MD;
	ELSIF (subcategory IS NULL) THEN
		RETURN QUERY
		SELECT MD.name, MD.image_url, MD.price
		FROM store.vw_menu_item_details MD
		JOIN store.item_category IC ON IC.name = category
		JOIN store.menu_item_category MIC ON MIC.menu_item_id = MD.menu_item_id 
			AND MIC.item_category_id = IC.item_category_id;
	ELSE 
		RETURN QUERY
		SELECT MD.name, MD.image_url, MD.price
		FROM store.vw_menu_item_details MD
		JOIN store.item_category IC ON IC.name = category
		JOIN store.item_subcategory ISC ON ISC.name = subcategory
		JOIN store.menu_item_category MIC ON MIC.menu_item_id = MD.menu_item_id AND MIC.item_category_id = IC.item_category_id
		JOIN store.menu_item_subcategory MISC ON MISC.menu_item_id = MIC.menu_item_id AND MISC.item_subcategory_id = ISC.item_subcategory_id;
	END IF;
END;
$func$;

--Fetches the specific items within a grouping
CREATE OR REPLACE FUNCTION store.fetch_grouping_items(grouping_name TEXT)
RETURNS SETOF store.menu_items
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT MI.name, MI.price, I.image_url
	FROM store.menu_item MI
	JOIN store.image I ON I.image_id = MI.image_id
	JOIN store.grouping G ON G.grouping_id = MI.grouping_id
	WHERE G.name = grouping_name AND MI.is_active = true;
END;
$func$;

--Fetches the various groupings and displays them like a menu item
CREATE OR REPLACE FUNCTION store.fetch_groupings()
RETURNS TABLE ( name TEXT, image_url TEXT, price numeric(4,2))
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT G.name, I.image_url, G.price 
	FROM store.grouping G
	JOIN store.image I ON I.image_id = G.image_id
	WHERE G.is_active = true;
END;
$func$;

CREATE OR REPLACE FUNCTION store.fetch_grouping_names()
RETURNS TABLE (names TEXT[])
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT array_agg(G.name) AS names
	FROM store.grouping G
	WHERE G.is_active = true;
END;
$func$;

CREATE OR REPLACE FUNCTION store.get_item_images(item_id INTEGER)
RETURNS TABLE (image_urls TEXT[])
LANGUAGE plpgsql
AS
$func$
BEGIN
	RETURN QUERY
	SELECT array_agg(I.image_url) AS image_urls
	FROM store.menu_item_image MII
	JOIN store.image I ON I.image_id = MII.image_id
	WHERE MII.menu_item_id = item_id;
END;
$func$;

CREATE OR REPLACE FUNCTION store.get_item_extras(item_id INTEGER)
RETURNS TABLE (extras JSON[])
LANGUAGE plpgsql
AS
$func$
BEGIN
	RETURN QUERY
	SELECT array_agg(tb."group") AS extras
	FROM (
		SELECT json_build_object('category', EC.name, 'extras', json_agg(json_strip_nulls(json_build_object('name', E.name, 'price', E.price, 'id', E.extra_id)) ORDER BY EGE.display_order)) AS "group"
		FROM store.item_extra_group IEG
		LEFT JOIN store.extra_group_extra EGE ON EGE.extra_group_id = IEG.extra_group_id
		LEFT JOIN store.extra E ON E.extra_id = EGE.extra_id
		LEFT JOIN store.extra_group EG ON EG.extra_group_id = IEG.extra_group_id
		LEFT JOIN store.extra_category EC ON EC.extra_category_id = EG.extra_category_id
		WHERE IEG.menu_item_id = item_id
		GROUP BY EC.name
	) tb;
END;
$func$;

--Fetches the details of a menu item
CREATE OR REPLACE FUNCTION store.fetch_item_details(item_name TEXT)
RETURNS TABLE (name TEXT, id SMALLINT, price NUMERIC(4,2), description TEXT, group_price NUMERIC(4,2), group_name TEXT, group_size SMALLINT, extras JSON[], image_urls TEXT[])
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
		SELECT MI.name, MI.menu_item_id, MI.price, MI.description, G.price AS group_price, G.name AS group_name, G.size AS group_size,
		(SELECT * FROM store.get_item_extras(MI.menu_item_id)), 
		array_append((SELECT * FROM store.get_item_images(MI.menu_item_id)), I.image_url) AS image_urls
		FROM store.menu_item MI
		JOIN store.image I ON I.image_id = MI.image_id
		LEFT JOIN store.grouping G ON G.grouping_id = MI.grouping_id
		WHERE MI.name = item_name
		GROUP BY MI.name, MI.menu_item_id, MI.price, I.image_url, MI.description, G.price, G.name, G.size;
END;
$func$;

CREATE OR REPLACE FUNCTION store.fetch_group_item_details(g_name TEXT)
RETURNS TABLE (name TEXT, id SMALLINT, price NUMERIC(4,2), image_urls TEXT[], description TEXT, group_price NUMERIC(4,2), group_name TEXT, group_size SMALLINT, extras JSON)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT MI.name, MI.menu_item_id, MI.price, MI.description, G.price AS group_price, G.name AS group_name, G.size AS group_size,
	(SELECT * FROM store.get_item_extras(MI.menu_item_id)), 
	array_append((SELECT * FROM store.get_item_images(MI.menu_item_id)), I.image_url)
	FROM store.menu_item MI
	JOIN store.image I ON I.image_id = MI.image_id
	JOIN store.grouping G ON G.grouping_id = MI.grouping_id
	WHERE G.name = g_name
	GROUP BY MI.name, MI.menu_item_id, MI.price, I.image_url, MI.description, G.price, G.name, G.size;
END;
$func$;

CREATE OR REPLACE FUNCTION store.fetch_group_info(g_name TEXT)
RETURNS TABLE (name TEXT, price NUMERIC(4,2), size SMALLINT)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT G.name, G.price, G.size
	FROM store.grouping G
	WHERE G.name = g_name;
END;
$func$;

CREATE OR REPLACE FUNCTION store.fetch_menu_names()
RETURNS TABLE (name TEXT)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT MI.name
	FROM store.menu_item MI
	WHERE MI.is_active = true;
END;
$func$;
--

--Cart Functions
CREATE OR REPLACE FUNCTION store.view_cart(user_cart_id INTEGER)
RETURNS TABLE (unit_price NUMERIC(4,2), cart_item_id SMALLINT, menu_item_id SMALLINT, amount SMALLINT, "name" TEXT, image TEXT, group_name TEXT, 
			  group_size SMALLINT, group_price NUMERIC(4,2), extra_info JSON)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT MI.price AS unit_price, CI.cart_item_id, MI.menu_item_id, CI.amount, MI.name, I.image_url, G.name AS group_name,
	G.size AS group_size, G.price AS group_price, (SELECT json_build_object('info', json_agg(json_build_object('category', EC.name, 'extra', E.name)),
		'ids', array_agg(E.extra_id), 'price', SUM(COALESCE(E.price, 0)))
		FROM store.cart_extra CE
		JOIN store.extra E ON E.extra_id = CE.extra_id
		JOIN store.extra_category EC ON EC.extra_category_id = E.extra_category_id
		WHERE CE.cart_id = CI.cart_id AND CE.cart_item_id = CI.cart_item_id
		GROUP BY CI.cart_item_id) AS extra_info
	FROM store.cart_item CI
	JOIN store.menu_item MI ON MI.menu_item_id = CI.menu_item_id
	JOIN store.image I ON I.image_id = MI.image_id
	LEFT JOIN store.grouping G ON G.grouping_id = MI.grouping_id
	WHERE CI.cart_id = user_cart_id
	ORDER BY CI.cart_item_id ASC;
END;
$func$;

DROP FUNCTION IF EXISTS store.get_item_images;
CREATE OR REPLACE FUNCTION store.get_item_images(m_id INTEGER)
RETURNS TABLE (image_urls TEXT[])
LANGUAGE plpgsql
SECURITY DEFINER
AS
$func$
BEGIN
	RETURN QUERY
	SELECT array_prepend(I.image_url, 
		(SELECT array_agg(I2.image_url)
		FROM store.menu_item_image MII
		JOIN store.image I2 ON I2.image_id = MII.image_id
		WHERE MII.menu_item_id = m_id
		GROUP BY MII.display_order
		ORDER BY MII.display_order)
	)
	FROM store.menu_item MI
	JOIN store.image I ON I.image_id = MI.image_id
	WHERE MI.menu_item_id = m_id;
END;
$func$;

CREATE OR REPLACE FUNCTION store.get_cart_item_extras(c_id INTEGER, c_item_id SMALLINT)
RETURNS TABLE (extras JSON)
LANGUAGE plpgsql
SECURITY DEFINER
AS
$func$
BEGIN
	RETURN QUERY
	SELECT json_agg(tb)
	FROM (
		SELECT E.name || ' ' || EC.name AS "text", E.price
		FROM store.cart_extra CE
		JOIN store.extra E ON E.extra_id = CE.extra_id
		JOIN store.extra_category EC ON EC.extra_category_id = E.extra_category_id
		WHERE CE.cart_id = c_id AND CE.cart_item_id = c_item_id
	) tb;
END;
$func$;

CREATE OR REPLACE FUNCTION store.get_cart_items(user_cart_id INTEGER)
RETURNS TABLE (items JSON)
LANGUAGE plpgsql
SECURITY DEFINER
AS
$func$
BEGIN
	RETURN QUERY
	SELECT json_object_agg(tb.menu_item_id, json_build_object('details', tb.details, 'items', tb.item))
	FROM (
		SELECT MI.menu_item_id, json_build_object('name', MI.name, 'price', MI.price, 'imageUrl', I.image_url, 'availableDays', array_remove(array_agg(W.weekday), NULL), 
		'availableRange', CASE WHEN MI.availability_range IS NOT NULL THEN 
			to_jsonb(json_build_object('from', to_char(LOWER(MI.availability_range), 'YYYY-MM-DD'), 'to', to_char(UPPER(MI.availability_range), 'YYYY-MM-DD')))
			ELSE NULL END) AS details,
		json_object_agg(CI.cart_item_id, json_build_object('amount', CI.amount, 'extras', (SELECT * FROM store.get_cart_item_extras(user_cart_id, CI.cart_item_id)))) AS item
		FROM store.cart_item CI
		JOIN store.menu_item MI ON MI.menu_item_id = CI.menu_item_id
		LEFT JOIN store.weekday_availability WA ON WA.menu_item_id = MI.menu_item_id
		LEFT JOIN store.weekday W ON W.weekday_id = WA.weekday_id
		JOIN store.image I ON I.image_id = MI.image_id
		WHERE CI.cart_id = user_cart_id
		GROUP BY MI.menu_item_id, MI.name, MI.price, I.image_url, (CASE WHEN MI.availability_range IS NOT NULL THEN 
			to_jsonb(json_build_object('from', to_char(LOWER(MI.availability_range), 'YYYY-MM-DD'), 'to', to_char(UPPER(MI.availability_range), 'YYYY-MM-DD')))
			ELSE NULL END)
	) tb;
END;
$func$;

CREATE OR REPLACE FUNCTION store.get_cart(c_id INTEGER)
RETURNS TABLE (items JSON, status TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
AS
$func$
DECLARE cart_status TEXT;
BEGIN
	SELECT CCS.status INTO cart_status FROM store.check_cart_status(c_id) CCS;
	IF cart_status = 'Pending' OR cart_status = 'Open' THEN
		RETURN QUERY
		SELECT (SELECT * FROM store.get_cart_items(c_id)), cart_status;
	ELSE
		RETURN QUERY
		SELECT json_build_object(), cart_status;
	END IF;
END;
$func$;

DROP FUNCTION store.view_account_orders
CREATE OR REPLACE FUNCTION store.view_account_orders(user_account_id INTEGER)
RETURNS TABLE (order_date DATE, cart_id INTEGER, cart JSON)
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT O.created_on::DATE AS order_date,
		C.cart_id AS cart_id,
		(
			SELECT json_agg(CI) 
			FROM store.view_cart(C.cart_id) CI
		) AS cart
	FROM store.cart C
	JOIN store.order O ON C.cart_id = O.cart_id
	WHERE O.account_id = user_account_id
	ORDER BY O.created_on ASC;
END;
$func$;
SELECT * FROM store.view_account_orders(2)

CREATE OR REPLACE FUNCTION store.check_cart_status(user_cart_id INTEGER)
RETURNS TABLE (status TEXT)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	IF (SELECT C.is_locked FROM store.cart C WHERE C.cart_id = user_cart_id) THEN
		IF (SELECT O.is_verified FROM store.order O WHERE O.cart_id = user_cart_id) THEN
			RETURN QUERY
			SELECT 'Complete' AS status;
		ELSE
			RETURN QUERY
			SELECT 'Pending' AS status;
		END IF;
	ELSE
		RETURN QUERY
		SELECT 'Open' AS status;
	END IF;
END;
$func$;
--END OF CART FUNCTIONS

--Checkout Functions
CREATE OR REPLACE FUNCTION store.get_checkout_info()
RETURNS TABLE (common_name TEXT, city TEXT, "state" TEXT, zip TEXT, address TEXT, phone_number TEXT, location_id SMALLINT, times JSON[])
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT L.common_name, L.city, L.state, L.zip, L.address, L.phone_number, L.location_id, array_agg(json_build_object('name', to_char(PT.pickup_time, 'HH:MI AM'), 'id', PT.pickup_time_id) ORDER BY PT.pickup_time ASC) AS times
	FROM store.location L
	JOIN store.location_pickup_time LPT ON LPT.location_id = L.location_id
	JOIN store.pickup_time PT ON PT.pickup_time_id = LPT.pickup_time_id
		AND PT.is_active = true
	GROUP BY L.common_name, L.city, L.state, L.zip, L.address, L.phone_number, L.location_id;
END;
$func$;

CREATE OR REPLACE FUNCTION store.get_cart_availability(user_cart_id INTEGER)
RETURNS TABLE (available_weekdays JSON[], available_daterange JSON[])
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT t1.available_weekdays, t2.available_daterange
	FROM
	(SELECT array_agg(json_build_object('weekday', W.weekday, 'menu_item_id', CI.menu_item_id)) AS available_weekdays
		FROM store.cart_item CI
		JOIN store.weekday_availability WA ON WA.menu_item_id = CI.menu_item_id
		JOIN store.weekday W ON W.weekday_id = WA.weekday_id
		WHERE CI.cart_id = user_cart_id) t1
	CROSS JOIN
	(SELECT array_agg(json_build_object('menu_item_id', IRA.menu_item_id, 'range', RA.range_availability)) AS available_daterange
	FROM store.cart_item CI
	JOIN store.item_range_availability IRA ON IRA.menu_item_id = CI.menu_item_id
	JOIN store.range_availability RA ON RA.range_availability_id = IRA.range_availability_id
	WHERE CI.cart_id = user_cart_id) t2;
END;
$func$;

CREATE OR REPLACE FUNCTION store.fetch_totaling_cart(user_cart_id INTEGER)
RETURNS TABLE (cart JSON, tax_amount NUMERIC(3,3))
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT json_agg(t3) cart, tax.tax_amount
	FROM(
		SELECT t2.price, t2.size, array_agg(t2.items) AS items, SUM(t2.total_items) AS total_items
		FROM(
			SELECT CASE WHEN t1.extra_price > 0 THEN NULL ELSE t1.price END AS price, CASE WHEN t1.extra_price > 0 THEN NULL ELSE t1.size END AS "size", ARRAY[t1.unit_price + COALESCE(t1.extra_price, 0), t1."count"] AS items, SUM(t1."count") AS total_items
			FROM(
				SELECT G.price, G.size, G.grouping_id, 
				MI.price unit_price, SUM(CI.amount) "count", (
				SELECT SUM(COALESCE(E.price, 0)) FROM store.cart_extra CE JOIN store.extra E ON E.extra_id = CE.extra_id
					WHERE CE.cart_item_id = CI.cart_item_id AND CE.cart_id = CI.cart_id) AS extra_price
				FROM store.cart_item CI
				JOIN store.menu_item MI ON MI.menu_item_id = CI.menu_item_id
				LEFT JOIN store.grouping G ON G.grouping_id = MI.grouping_id
				WHERE CI.cart_id = user_cart_id
				GROUP BY MI.price, G.grouping_id, extra_price
			) t1
			GROUP BY t1.extra_price, items, t1.price, t1.size
		) t2
	GROUP BY t2.price, t2.size
	) t3
	CROSS JOIN store.tax
	GROUP BY tax.tax_amount;
END;
$func$;

CREATE OR REPLACE FUNCTION store.retrieve_stripe_id(user_cart_id INTEGER)
RETURNS TABLE (payment_uid TEXT)
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
BEGIN
	CALL store.check_order_verification(user_cart_id);
	RETURN QUERY
	SELECT O.payment_uid 
	FROM store.order O
	WHERE O.cart_id = user_cart_id;
END;
$func$;

CREATE OR REPLACE FUNCTION store.fetch_paypal_order_items(user_cart_id INTEGER)
RETURNS TABLE (name TEXT, price NUMERIC(4,2), amount SMALLINT, extra_price NUMERIC(4,2), extras JSON[])
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT MI.name, MI.price, CI.amount, SUM(COALESCE(E.price, 0)) AS extra_price, array_agg(json_build_object('category', EC.name, 'extra', E.name)) AS extras
	FROM store.cart_item CI
	JOIN store.menu_item MI ON MI.menu_item_id = CI.menu_item_id
	LEFT JOIN store.cart_extra CE ON CE.cart_item_id = CI.cart_item_id AND CE.cart_id = CI.cart_id
	LEFT JOIN store.extra E ON E.extra_id = CE.extra_id
	LEFT JOIN store.extra_category EC ON EC.extra_category_id = E.extra_category_id
	WHERE CI.cart_id = user_cart_id
	GROUP BY MI.name, MI.price, CI.amount;
END;
$func$;
--END OF CHECKOUT FUNCTIONS

--Category Functions
CREATE OR REPLACE FUNCTION store.fetch_categories()
RETURNS TABLE (category TEXT, subcategories TEXT[])
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT IC.name AS category, array_agg(ISC.name) AS subcategories
	FROM store.item_category IC
	LEFT JOIN store.item_subcategory ISC ON ISC.item_category_id = IC.item_category_id
		AND ISC.is_active = true
	WHERE IC.is_active = true
	GROUP BY IC.name, IC.display_order
	ORDER BY IC.display_order ASC;
END;
$func$;

CREATE OR REPLACE FUNCTION store.fetch_category_names()
RETURNS TABLE (name TEXT)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT IC.name
	FROM store.item_category IC
	WHERE IC.is_active = true
	ORDER BY IC.name ASC;
END;
$func$;
--END OF CATEGORY FUNCTIONS

CREATE OR REPLACE FUNCTION store.get_user_role(user_email TEXT)
RETURNS TABLE ("role" TEXT)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT R.role
	FROM(
		SELECT A.email, 'team member' AS "role"
		FROM store.team_member A

		UNION

		SELECT O.email, 'owner' AS "role"
		FROM store.owner O
	) R
	WHERE R.email = user_email;
	
	IF NOT FOUND THEN
		RETURN QUERY SELECT 'customer';
	END IF;
END;
$func$;

DROP FUNCTION IF EXISTS store.get_user_roles;
CREATE OR REPLACE FUNCTION store.get_user_roles(user_email TEXT)
RETURNS TABLE ("role" TEXT)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT R.title
	FROM store.team_member TM
	JOIN store.team_member_role TMR ON TMR.team_member_id = TM.team_member_id
	JOIN store.role R ON R.role_id = TMR.role_id
	WHERE TM.email = user_email;
END;
$func$;

CREATE OR REPLACE FUNCTION store.check_user_role(user_email TEXT, required_role_ids SMALLINT[])
RETURNS VOID
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	IF NOT EXISTS (
		SELECT 1
		FROM store.owner O
		WHERE O.email = user_email
	) THEN
		IF NOT EXISTS (
			SELECT 1
			FROM store.team_member_role TMR
			JOIN store.team_member TM ON TM.team_member_id = TMR.team_member_id
			WHERE TMR.role_id = ANY(required_role_ids) AND TM.email = user_email
		) THEN
			RAISE EXCEPTION 'User does not have permission to perform this action.';
		END IF;
	END IF;
END;
$func$;

--SELECT FROM store.check_user_role('hunterstatek@gmail.com', ARRAY[1, 2]::SMALLINT[])

CREATE OR REPLACE FUNCTION store.get_user_password(user_email TEXT)
RETURNS TABLE (hashed_password TEXT)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
DECLARE hashed_password TEXT;
BEGIN
	SELECT O.password INTO hashed_password FROM store.owner O WHERE O.email = user_email;
	
	IF hashed_password IS NULL THEN
		SELECT TMP.password INTO hashed_password 
		FROM store.team_member_password TMP
		WHERE EXISTS (
			SELECT 1
			FROM store.team_member TM
			WHERE TM.email = user_email
		);
	END IF;
	RETURN QUERY SELECT hashed_password;
END;
$func$;