CREATE OR REPLACE FUNCTION store.fetch_item_customizations()
RETURNS TABLE (groupings JSON, extra_groupings JSON, item_categories JSON)
SECURITY DEFINER
LANGUAGE plpgsql
AS
$func$
BEGIN
	RETURN QUERY
	SELECT * FROM
	(SELECT json_agg(json_build_object('grouping_id', G.grouping_id, 'name', G.name)) AS groupings FROM store.grouping G) G
	CROSS JOIN (
		SELECT json_agg(EG) AS extra_groupings FROM (SELECT EC.name, json_agg(json_build_object('name', EG.name, 'extra_group_id', EG.extra_group_id, 
				'extras', (SELECT array_agg(E.name) 
						   FROM store.extra E JOIN store.extra_group_extra EGE ON EGE.extra_group_id = EG.extra_group_id
								AND EGE.extra_id = E.extra_id))) AS extra_groupings
		FROM store.extra_category EC
		JOIN store.extra_group EG ON EG.extra_category_id = EC.extra_category_id
		GROUP BY EC.name
		)EG) EG
	CROSS JOIN (
		SELECT json_agg(C) AS item_categories 
		FROM (SELECT IC.name, IC.item_category_id, array_agg(json_strip_nulls(json_build_object('name', ISC.name, 'item_subcategory_id', ISC.item_subcategory_id))) AS subcategories
		FROM store.item_category IC
		LEFT JOIN store.item_subcategory ISC ON ISC.item_category_id = IC.item_category_id
		GROUP BY IC.name, IC.item_category_id) C) C;
END;
$func$;

CREATE OR REPLACE FUNCTION store.fetch_item_selections(item_id SMALLINT)
RETURNS TABLE (initial_details JSON, initial_group_id SMALLINT, initial_extra_groupings JSON, initial_item_categories JSON, initial_weekdays JSON, initial_range JSON, initial_images JSON[])
SECURITY DEFINER
LANGUAGE plpgsql
AS
$func$
BEGIN
	RETURN QUERY
	SELECT json_build_object('name', MI.name, 'price', MI.price, 'description', MI.description) AS initial_details,
	G.grouping_id AS initial_group_id, (SELECT * FROM store.fetch_item_initial_extra_groupings(item_id)),
	(SELECT * FROM store.fetch_item_initial_categories(item_id)),
	(SELECT * FROM store.fetch_item_initial_weekdays(item_id)), 
	CASE WHEN MI.availability_range IS NOT NULL THEN json_build_object('from', lower(MI.availability_range), 'to', upper(MI.availability_range)) ELSE NULL END AS initial_range,
	(SELECT * FROM store.fetch_item_images(item_id)) 
	FROM store.menu_item MI
	JOIN store.image I ON I.image_id = MI.image_id
	LEFT JOIN store.grouping G ON G.grouping_id = MI.grouping_id
	LEFT JOIN store.menu_item_image MII ON MII.menu_item_id = MI.menu_item_id
	LEFT JOIN store.image I2 ON I2.image_id = MII.image_id
	WHERE MI.menu_item_id = item_id
	GROUP BY MI.name, MI.price, MI.description, G.grouping_id, MI.availability_range;
END;
$func$;

CREATE OR REPLACE FUNCTION store.fetch_item_images(item_id SMALLINT)
RETURNS TABLE (initial_images JSON[])
SECURITY DEFINER
LANGUAGE plpgsql
AS
$func$
BEGIN
	RETURN QUERY
	SELECT array_agg(json_build_object('imageUrl', tb.image_url, 'imageId', tb.image_id, 'displayOrder', tb.display_order))
	FROM(
		SELECT *
		FROM
			(
				SELECT I.image_url, I.image_id, 0 AS display_order
				FROM store.menu_item MI
				JOIN store.image I ON I.image_id = MI.image_id
				WHERE MI.menu_item_id = item_id

				UNION ALL

				SELECT I.image_url, I.image_id, MII.display_order
				FROM store.menu_item_image MII
				JOIN store.image I ON I.image_id = MII.image_id
				WHERE MII.menu_item_id = item_id
			) images
		ORDER BY display_order
	) tb;
END;
$func$;

CREATE OR REPLACE FUNCTION store.fetch_item_initial_categories(item_id SMALLINT)
RETURNS TABLE (initial_item_categories JSON)
SECURITY DEFINER
LANGUAGE plpgsql
AS
$func$
BEGIN
	RETURN QUERY
	SELECT json_object_agg(tb.item_category_id, tb.subcategories) FILTER (WHERE tb.item_category_id IS NOT NULL) AS initial_item_categories
	FROM (
		SELECT MIC.item_category_id, json_object_agg("IS".item_subcategory_id, true) FILTER (WHERE "IS".item_subcategory_id IS NOT NULL) AS subcategories
		FROM store.menu_item_category MIC
		LEFT JOIN store.item_category IC ON IC.item_category_id = MIC.item_category_id
		LEFT JOIN store.menu_item_subcategory MIS ON MIS.menu_item_id = MIC.menu_item_id
		LEFT JOIN store.item_subcategory "IS" ON "IS".item_category_id = IC.item_category_id 
			AND "IS".item_subcategory_id = MIS.item_subcategory_id
		WHERE MIC.menu_item_id = item_id
		GROUP BY MIC.item_category_id
	) tb;
END;
$func$;

CREATE OR REPLACE FUNCTION store.fetch_item_initial_weekdays(item_id SMALLINT)
RETURNS TABLE (initial_weekdays JSON)
SECURITY DEFINER
LANGUAGE plpgsql
AS
$func$
BEGIN
	RETURN QUERY
	SELECT json_object_agg(WA.weekday_id, true)
	FROM store.weekday_availability WA 
	WHERE WA.menu_item_id = item_id;
END;
$func$;

CREATE OR REPLACE FUNCTION store.fetch_item_initial_extra_groupings(item_id SMALLINT)
RETURNS TABLE (initial_weekdays JSON)
SECURITY DEFINER
LANGUAGE plpgsql
AS
$func$
BEGIN
	RETURN QUERY
	SELECT json_object_agg(EC.name, IEG.extra_group_id)
	FROM store.item_extra_group IEG
	LEFT JOIN store.extra_group EG ON EG.extra_group_id = IEG.extra_group_id
	LEFT JOIN store.extra_category EC ON EC.extra_category_id = EG.extra_category_id
	WHERE IEG.menu_item_id = item_id;
END;
$func$;

CREATE OR REPLACE FUNCTION store.search_items(phrase TEXT DEFAULT '', includeArchived BOOLEAN DEFAULT NULL, includeInactive BOOLEAN DEFAULT NULL)
RETURNS TABLE (name TEXT, image_url TEXT, menu_item_id SMALLINT)
SECURITY DEFINER
LANGUAGE plpgsql
AS
$func$
BEGIN
	IF includeArchived IS NULL AND includeInactive IS NULL THEN
		RETURN QUERY
		SELECT MI.name, I.image_url, MI.menu_item_id
		FROM store.menu_item MI
		JOIN store.image I ON I.image_id = MI.image_id
		WHERE MI.name ILIKE '%' || phrase || '%';
	ELSIF includeArchived IS NULL THEN
		RETURN QUERY
		SELECT MI.name, I.image_url, MI.menu_item_id
		FROM store.menu_item MI
		JOIN store.image I ON I.image_id = MI.image_id
		WHERE MI.name ILIKE '%' || phrase || '%' AND MI.is_active = NOT includeInactive;
	ELSIF includeInactive IS NULL THEN
		RETURN QUERY
		SELECT MI.name, I.image_url, MI.menu_item_id
		FROM store.menu_item MI
		JOIN store.image I ON I.image_id = MI.image_id
		WHERE MI.name ILIKE '%' || phrase || '%' AND MI.is_archived = NOT includeArchived;
	ELSE
		RETURN QUERY
		SELECT MI.name, I.image_url, MI.menu_item_id
		FROM store.menu_item MI
		JOIN store.image I ON I.image_id = MI.image_id
		WHERE MI.name ILIKE '%' || phrase || '%' AND MI.is_archived = includeArchived AND MI.is_active = NOT includeInactive;
	END IF;
END;
$func$;

--order_contents: {name, amount, breakdown: {extras: {category, extra, abbreviation}[], amount}[]}[]
CREATE OR REPLACE FUNCTION store.fetch_orders(from_date DATE, to_date DATE)
RETURNS TABLE (order_id INTEGER, pickup_date TEXT, created_on TEXT, is_printed BOOLEAN, is_verified BOOLEAN, error_message TEXT, order_contents JSON, payment_processor TEXT, customer_info JSON, pickup_time TEXT, "location" TEXT, payment_uid TEXT, price_details JSON)
SECURITY DEFINER
LANGUAGE plpgsql
AS
$func$
BEGIN
	RETURN QUERY
	SELECT O.order_id, to_char(O.pickup_date, 'FMDay, FMMonth FMDD') AS pickup_date, to_char(O.created_on, 'FMDay, FMMonth FMDD') AS created_on, O.is_printed, O.is_verified, O.error_message, (SELECT * FROM store.fetch_order_cart(O.cart_id)),
	PP.payment_processor, (SELECT * FROM store.fetch_order_pickup_info(O.user_info_id, O.customer_order_info_id)), to_char(PT.pickup_time, 'FMHH12:MI AM') AS pickup_time,
	COALESCE(L.common_name, L.address) AS "location", O.payment_uid, json_build_object('subtotal', O.subtotal, 'tax', O.tax, 'processor_fee', O.processor_fee) AS price_details
	FROM store.order O
	LEFT JOIN store.payment_processor PP ON PP.payment_processor_id = O.payment_processor_id
	JOIN store.pickup_time PT ON PT.pickup_time_id = O.pickup_time_id
	JOIN store.location L ON L.location_Id = O.location_id
	WHERE O.pickup_date BETWEEN from_date AND to_date;
END;
$func$;

CREATE OR REPLACE FUNCTION store.fetch_order_cart(cart_order_id INTEGER)
RETURNS TABLE (order_contents JSON)
SECURITY DEFINER
LANGUAGE plpgsql
AS
$func$
BEGIN
	RETURN QUERY
	SELECT json_agg(tb)
	FROM (
		SELECT MI.name, SUM(CI.amount) AS amount, array_agg(json_build_object('extras', (
			SELECT array_agg(json_build_object('category', EC.name, 'extra', E.name, 'abbreviation', E.abbreviation))
			FROM store.cart_extra CE 
			LEFT JOIN store.extra E ON E.extra_id = CE.extra_id
			LEFT JOIN store.extra_category EC ON EC.extra_category_id = E.extra_category_id
			WHERE CE.cart_id = C.cart_id AND CE.cart_item_id = CI.cart_item_id
		), 'amount', CI.amount)) AS breakdown
		FROM store.cart C
		JOIN store.cart_item CI ON CI.cart_id = C.cart_id
		JOIN store.menu_item MI ON MI.menu_item_id = CI.menu_item_id
		WHERE C.cart_id = cart_order_id
		GROUP BY MI.name
	) tb;
END;
$func$;

CREATE OR REPLACE FUNCTION store.fetch_order_pickup_info(order_user_info_id INTEGER, customer_info_id INTEGER)
RETURNS TABLE (customer_info JSON)
SECURITY DEFINER
LANGUAGE plpgsql
AS
$func$
BEGIN
	IF order_user_info_id IS NOT NULL THEN
		RETURN QUERY
		SELECT json_build_object('name', concat(UI.first_name, ' ', UI.last_name), 'email', A.email, 'phone_number', UI.phone_number)
		FROM store.user_info UI
		JOIN store.account A ON A.account_id = UI.account_id
		WHERE UI.user_info_Id = order_user_info_id;
	ELSE
		RETURN QUERY
		SELECT json_build_object('name', concat(COI.first_name, ' ', COI.last_name), 'email', COI.email, 'phone_number', COI.phone_number)
		FROM store.customer_order_info COI
		WHERE COI.customer_order_info_id = customer_info_id;
	END IF;
END;
$func$;

SELECT * FROM store.fetch_orders('2023-06-07', '2023-06-7');