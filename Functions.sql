--Created in the 'Tables' file because the view needs to be dropped before the menu_item table can be dropped
CREATE VIEW store.vw_menu_item_details AS 
	SELECT MI.name, MI.image, MI.price, MI.menu_item_id, MI.is_active
	FROM Store.menu_item MI
	WHERE MI.is_active = true;
	
CREATE TYPE store.menu_items AS (
	name TEXT,
	image TEXT,
	price numeric(4, 2)
);

--Fetches all of the items within a category (or all items if no category)
CREATE OR REPLACE FUNCTION store.fetch_menu_items(category TEXT DEFAULT NULL, subcategory TEXT DEFAULT NULL)
RETURNS SETOF store.menu_items
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	IF (category IS NULL) THEN
		RETURN QUERY
		SELECT MD.name, MD.image, MD.price FROM store.vw_menu_item_details MD;
	ELSIF (subcategory IS NULL) THEN
		RETURN QUERY
		SELECT MD.name, MD.image, MD.price
		FROM store.vw_menu_item_details MD
		JOIN store.item_category IC ON IC.name = category
		JOIN store.menu_item_category MIC ON MIC.menu_item_id = MD.menu_item_id 
			AND MIC.item_category_id = IC.item_category_id;
	ELSE 
		RETURN QUERY
		SELECT MD.name, MD.image, MD.price
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
	SELECT MI.name, MI.image, MI.price
	FROM store.menu_item MI
	JOIN store.grouping G ON G.grouping_id = MI.grouping_id
	WHERE G.name = grouping_name AND MI.is_active = true;
END;
$func$;
--END OF FUNCTIONS CREATED IN 'Tables.sql'
DROP FUNCTION IF EXISTS store.fetch_groupings;
DROP FUNCTION IF EXISTS store.fetch_grouping_names;
DROP FUNCTION IF EXISTS store.fetch_item_details;
DROP FUNCTION IF EXISTS store.fetch_group_item_details;
DROP FUNCTION IF EXISTS store.view_cart;
DROP FUNCTION IF EXISTS store.check_cart_process;
DROP FUNCTION IF EXISTS store.get_checkout_info;
DROP FUNCTION IF EXISTS store.get_cart_availability;
DROP FUNCTION IF EXISTS store.fetch_totaling_cart;
DROP FUNCTION IF EXISTS store.retrieve_stripe_id;
DROP FUNCTION IF EXISTS store.fetch_paypal_order_items;
DROP FUNCTION IF EXISTS store.fetch_group_info;
DROP FUNCTION IF EXISTS store.fetch_menu_names;
DROP FUNCTION IF EXISTS store.fetch_categories;

--Fetches the various groupings and displays them like a menu item
CREATE OR REPLACE FUNCTION store.fetch_groupings()
RETURNS TABLE ( name TEXT, image TEXT, price numeric(4,2))
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT G.name, G.image, G.price 
	FROM store.grouping G
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

--Fetches the details of a menu item
CREATE OR REPLACE FUNCTION store.fetch_item_details(item_name TEXT)
RETURNS TABLE (name TEXT, id SMALLINT, price NUMERIC(4,2), image TEXT, description TEXT, group_price NUMERIC(4,2), group_name TEXT, group_size SMALLINT, extras JSON)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT tb.name, tb.menu_item_id AS id, tb.price, tb.image, tb.description, tb.group_price, tb.group_name, tb.group_size, json_agg(tb.extras) AS extras
	FROM(
		SELECT MI.name, MI.menu_item_id, MI.price, MI.image, MI.description, G.price AS group_price, G.name AS group_name, G.size AS group_size,
		json_build_object('category', EC.name, 'extras', json_agg(json_build_object('name', E.name, 'price', E.price, 'id', E.extra_id))) AS extras
		FROM store.menu_item MI
		LEFT JOIN store.item_extra_group IEG ON IEG.menu_item_id = MI.menu_item_id
		LEFT JOIN store.extra_group_extra EGE ON EGE.extra_group_id = IEG.extra_group_id
		LEFT JOIN store.extra E ON E.extra_id = EGE.extra_id
		LEFT JOIN store.extra_category EC ON EC.extra_category_id = E.extra_category_id
		LEFT JOIN store.grouping G ON G.grouping_id = MI.grouping_id
		WHERE MI.name = item_name
		GROUP BY MI.name, MI.menu_item_id, MI.price, MI.image, MI.description, G.price, G.name, G.size, EC.name
	) tb
	GROUP BY tb.name, tb.menu_item_id, tb.price, tb.image, tb.description, tb.group_price, tb.group_name, tb.group_size;
END;
$func$;

CREATE OR REPLACE FUNCTION store.fetch_group_item_details(g_name TEXT)
RETURNS TABLE (name TEXT, id SMALLINT, price NUMERIC(4,2), image TEXT, description TEXT, group_price NUMERIC(4,2), group_name TEXT, group_size SMALLINT, extras JSON)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT tb.name, tb.menu_item_id AS id, tb.price, tb.image, tb.description, tb.group_price, tb.group_name, tb.group_size, json_agg(tb.extras) AS extras
	FROM(
		SELECT MI.name, MI.menu_item_id, MI.price, MI.image, MI.description, G.price AS group_price, G.name AS group_name, G.size AS group_size,
		json_build_object('category', EC.name, 'extras', json_agg(json_build_object('name', E.name, 'price', E.price, 'id', E.extra_id))) AS extras
		FROM store.menu_item MI
		LEFT JOIN store.item_extra_group IEG ON IEG.menu_item_id = MI.menu_item_id
		LEFT JOIN store.extra_group_extra EGE ON EGE.extra_group_id = IEG.extra_group_id
		LEFT JOIN store.extra E ON E.extra_id = EGE.extra_id AND E.price IS NULL
		LEFT JOIN store.extra_category EC ON EC.extra_category_id = E.extra_category_id
		JOIN store.grouping G ON G.grouping_id = MI.grouping_id
		WHERE G.name = g_name
		GROUP BY MI.name, MI.menu_item_id, MI.price, MI.image, MI.description, G.price, G.name, G.size, EC.name
	) tb
	GROUP BY tb.name, tb.menu_item_id, tb.price, tb.image, tb.description, tb.group_price, tb.group_name, tb.group_size;
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
RETURNS TABLE (unit_price NUMERIC(4,2), cart_item_id INTEGER, menu_item_id SMALLINT, amount INTEGER, name TEXT, image TEXT, group_name TEXT, 
			  group_size SMALLINT, group_price NUMERIC(4,2), extra_info JSON)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT MI.price AS unit_price, CI.cart_item_id, MI.menu_item_id, CI.amount, MI.name, MI.image, G.name AS group_name,
	G.size AS group_size, G.price AS group_price, (SELECT json_build_object('info', json_agg(json_build_object('category', EC.name, 'extra', E.name)),
		'ids', array_agg(E.extra_id), 'price', SUM(COALESCE(E.price, 0)))
		FROM store.cart_extra CE
		JOIN store.extra E ON E.extra_id = CE.extra_id
		JOIN store.extra_category EC ON EC.extra_category_id = E.extra_category_id
		WHERE CE.cart_id = CI.cart_id AND CE.cart_item_id = CI.cart_item_id
		GROUP BY CI.cart_item_id) AS extra_info
	FROM store.cart_item CI
	JOIN store.menu_item MI ON MI.menu_item_id = CI.menu_item_id
	LEFT JOIN store.grouping G ON G.grouping_id = MI.grouping_id
	WHERE CI.cart_id = user_cart_id
	ORDER BY CI.cart_item_id ASC;
END;
$func$;

CREATE OR REPLACE FUNCTION store.check_cart_process(user_cart_id INTEGER)
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
RETURNS TABLE (locations JSON, pickup_times JSON)
LANGUAGE plpgsql 
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
	SELECT t1.locations, t2.times
	FROM
		(SELECT json_agg(L) AS locations FROM store.location L) t1
	CROSS JOIN
		(SELECT json_agg(time) AS times FROM (SELECT PT.pickup_time_id, to_char(PT.pickup_time, 'HH:MI AM') AS pickup_time FROM store.pickup_time PT ORDER BY PT.pickup_time ASC) AS time) t2;
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
RETURNS TABLE (name TEXT, price NUMERIC(4,2), amount INTEGER, extra_price NUMERIC(4,2), extras JSON[])
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