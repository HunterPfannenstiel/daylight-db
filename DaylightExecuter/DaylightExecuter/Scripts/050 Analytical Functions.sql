/*CREATE OR REPLACE FUNCTION store.get_donuts_sold_within_time_frame(begin_date DATE, end_date DATE, time_unit TEXT, donut_type TEXT)
RETURNS TABLE ()
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
BEGIN
	
END;
$func$;*/

CREATE OR REPLACE FUNCTION store.get_dates(begin_date DATE, end_date DATE, trunc_unit TEXT, interval_type TEXT)
RETURNS TABLE (date DATE)
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
		SELECT CAST(generate_series(
			DATE_TRUNC(trunc_unit, begin_date)::date,
			DATE_TRUNC(trunc_unit, end_date)::date,
			interval_type::interval
		) AS DATE) AS date;
END;
$func$;

CREATE OR REPLACE FUNCTION store.get_item_analytics(
	begin_date DATE, 
	end_date DATE,
	time_unit TEXT,
	preserve_null_dates BOOL,
	item_category TEXT,
	item_name TEXT
)
RETURNS TABLE (year DOUBLE PRECISION, month DOUBLE PRECISION, day DOUBLE PRECISION, amount NUMERIC, total NUMERIC(5,2))
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
BEGIN
	IF time_unit = 'month' THEN
		RETURN QUERY
			SELECT DATE_PART('year', I.created_on) AS year, 
				DATE_PART('month', I.created_on) as month,
				1::DOUBLE PRECISION as day,
				SUM(I.amount) AS amount,
				SUM(I.subtotal) as total
			FROM store.filter_items_and_date_range(
				DATE_TRUNC('month', begin_date)::DATE,
				(DATE_TRUNC('month', end_date) + INTERVAL '1 month - 1 day')::DATE,
				preserve_null_dates,
				item_category,
				item_name
			) I
			GROUP BY DATE_PART('year', I.created_on),
				DATE_PART('month', I.created_on)
			ORDER BY year ASC, month ASC;
	ELSEIF time_unit = 'week' THEN 
		RETURN QUERY
			SELECT DATE_PART('year', DATE_TRUNC('week', I.created_on)) AS year, 
				MIN(DATE_PART('month', DATE_TRUNC('week', I.created_on))) AS month,
				MIN(DATE_PART('day', DATE_TRUNC('week', I.created_on))) AS day,
				SUM(I.amount) AS amount,
				SUM(I.subtotal) as total
			FROM store.filter_items_and_date_range(
				DATE_TRUNC('week', begin_date)::DATE,
				(DATE_TRUNC('week', end_date) + INTERVAL '6 days')::DATE,
				preserve_null_dates,
				item_category,
				item_name
			) I
			GROUP BY DATE_PART('year', DATE_TRUNC('week', I.created_on)),
				DATE_PART('week', DATE_TRUNC('week', I.created_on))
			ORDER BY year ASC, month ASC, day ASC;
	ELSE 
		RETURN QUERY
			SELECT DATE_PART('year', I.created_on) AS year, 
				DATE_PART('month', I.created_on) AS month,
				DATE_PART('day', I.created_on) AS day,
				SUM(I.amount) AS amount,
				SUM(I.subtotal) as total
			FROM store.filter_items_and_date_range(
				begin_date,
				end_date,
				preserve_null_dates,
				item_category,
				item_name
			) I
			GROUP BY DATE_PART('year', I.created_on),
				DATE_PART('month', I.created_on),
				DATE_PART('day', I.created_on)
			ORDER BY year ASC, month ASC, day ASC;
	END IF;
END;
$func$;

CREATE OR REPLACE FUNCTION store.filter_items_and_date_range(
	begin_date DATE, 
	end_date DATE, 
	preserve_null_dates BOOL, 
	item_category TEXT, 
	item_name TEXT
)
RETURNS TABLE (created_on DATE, amount BIGINT, subtotal NUMERIC(5,2))
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
BEGIN
	IF item_category IS NOT NULL THEN
		RETURN QUERY
			SELECT O.created_on,
				COALESCE(SUM(CI.amount), 0) as amount,
				COALESCE(SUM(CI.subtotal), 0) as subtotal
			FROM store.cart C
				INNER JOIN store.cart_item CI ON C.cart_id = CI.cart_id
				INNER JOIN store.menu_item_category MIC ON CI.menu_item_id = MIC.menu_item_id
				INNER JOIN store.item_category IC ON MIC.item_category_id = IC.item_category_id
					AND IC.name = COALESCE(item_category, IC.name)
				RIGHT JOIN store.get_orders_in_date_range(begin_date, end_date, preserve_null_dates) O
					ON C.cart_id = O.cart_id
			GROUP BY O.created_on
			ORDER BY created_on;
	ELSE
		RETURN QUERY
			SELECT O.created_on,
				COALESCE(SUM(CI.amount), 0) as amount,
				COALESCE(SUM(CI.subtotal), 0) as subtotal
			FROM store.cart C
				INNER JOIN store.cart_item CI ON C.cart_id = CI.cart_id
				INNER JOIN store.menu_item MI ON CI.menu_item_id = MI.menu_item_id
					AND MI.name = COALESCE(item_name, MI.name)
				RIGHT JOIN store.get_orders_in_date_range(begin_date, end_date, preserve_null_dates) O
					ON C.cart_id = O.cart_id
			GROUP BY O.created_on
			ORDER BY created_on;
	END IF;
END;
$func$;

CREATE OR REPLACE FUNCTION store.get_orders_in_date_range(
	begin_date DATE, 
	end_date DATE, 
	preserve_null_dates BOOL
)
RETURNS TABLE (created_on DATE, cart_id INT)
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
BEGIN
	IF preserve_null_dates THEN
		RETURN QUERY
			SELECT D.date,
				O.cart_id
			FROM store.order O
				RIGHT JOIN store.get_dates(begin_date, end_date, 'day', '1 day') D 
					ON DATE_TRUNC('day', O.created_on) = D.date
			GROUP BY D.date,
				O.cart_id
			ORDER BY D.date;
	ELSE
		RETURN QUERY
			SELECT O.created_on::DATE,
				O.cart_id
			FROM store.order O
			WHERE O.created_on BETWEEN begin_date AND end_date
			GROUP BY O.created_on::DATE,
				O.cart_id
			ORDER BY O.created_on::DATE;
	END IF;
END;
$func$;

/*CREATE OR REPLACE FUNCTION store.get_monthly_donuts_sold(begin_date DATE, end_date DATE, donut_type TEXT)
RETURNS TABLE (year DOUBLE PRECISION, month DOUBLE PRECISION, amount NUMERIC)
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
		SELECT DATE_PART('year', DS.created_on) AS year, 
			DATE_PART('month', DS.created_on) as month,
			SUM(DS.amount) AS amount
		FROM store.get_donuts_sold(donut_type) DS
		WHERE DS.created_on BETWEEN DATE_TRUNC('month', begin_date) AND DATE_TRUNC('month', end_date) + INTERVAL '1 month - 1 day'
		GROUP BY DATE_PART('year', DS.created_on),
			DATE_PART('month', DS.created_on)
		ORDER BY year ASC, month ASC;
END;
$func$;*/

/*Have to truncate the date to the beginning of the week because some weeks can span across 2 months
CREATE OR REPLACE FUNCTION store.get_weekly_donuts_sold(begin_date DATE, end_date DATE, donut_type TEXT)
RETURNS TABLE (year DOUBLE PRECISION, month DOUBLE PRECISION, day DOUBLE PRECISION, amount NUMERIC)
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
		SELECT DATE_PART('year', DATE_TRUNC('week', DS.created_on)) AS year, 
			MIN(DATE_PART('month', DATE_TRUNC('week', DS.created_on))) AS month,
			MIN(DATE_PART('day', DATE_TRUNC('week', DS.created_on))) AS day,
			SUM(DS.amount) AS amount
		FROM store.get_donuts_sold(donut_type) DS
		WHERE DS.created_on BETWEEN DATE_TRUNC('week', begin_date) AND DATE_TRUNC('week', end_date) + INTERVAL '6 days'
		GROUP BY DATE_PART('year', DATE_TRUNC('week', DS.created_on)),
			DATE_PART('week', DATE_TRUNC('week', DS.created_on))
		ORDER BY year ASC, month ASC, day ASC;
END;
$func$;*/

/*CREATE OR REPLACE FUNCTION store.get_daily_donuts_sold(begin_date DATE, end_date DATE, donut_type TEXT)
RETURNS TABLE (year DOUBLE PRECISION, month DOUBLE PRECISION, day DOUBLE PRECISION, amount NUMERIC)
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
		SELECT DATE_PART('year', D.date) AS year, 
			DATE_PART('month', D.date) AS month,
			DATE_PART('day', D.date) AS day,
			COALESCE(SUM(DS.amount), 0) AS amount
		FROM store.get_donuts_sold(donut_type) DS
			RIGHT JOIN store.get_dates(begin_date, end_date, 'day', '1 day') D 
				ON DATE_TRUNC('day', DS.created_on) = D.date
		WHERE D.date BETWEEN begin_date AND end_date
		GROUP BY DATE_PART('year', D.date),
			DATE_PART('month', D.date),
			DATE_PART('day', D.date)
		ORDER BY year ASC, month ASC, day ASC;
END;
$func$;*/

/*CREATE OR REPLACE FUNCTION store.get_donuts_sold(donut_type TEXT)
RETURNS TABLE (created_on TIMESTAMP(0), amount BIGINT)
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
		SELECT O.created_on,
			SUM(CI.amount) as amount
		FROM store.order O
			INNER JOIN store.cart C ON O.cart_id = C.cart_id
			INNER JOIN store.cart_item CI ON C.cart_id = CI.cart_id
			INNER JOIN store.menu_item MI ON CI.menu_item_id = MI.menu_item_id
				AND MI.name = COALESCE(donut_type, MI.name)
		GROUP BY O.created_on;
END;
$func$;*/


/*SELECT name FROM store.item_category;
SELECT MI.name FROM store.menu_item MI INNER JOIN store.menu_item_category MIC ON MI.menu_item_id = MIC.menu_item_id 
	INNER JOIN store.item_category IC ON MIC.item_category_id = IC.item_category_id WHERE IC.name = 'Donuts'

SELECT * FROM store.get_item_analytics('2023-06-15', '2023-07-15', 'weeky', true, NULL, NULL)

SELECT * FROM store.filter_items_and_date_range('2023-06-15', '2023-07-15', true, NULL, NULL)
SELECT * FROM store.filter_items_and_date_range('2023-06-15', '2023-07-15', true, 'Featured', NULL)
SELECT * FROM store.get_orders_in_date_range('2023-06-15', '2023-07-15', false);
SELECT * FROM store.get_dates('2023-06-15', '2023-07-15', 'day', '1 day');
SELECT * FROM store.get_donuts_sold('Glaze');
SELECT * FROM store.get_monthly_donuts_sold('2023-06-15', '2023-07-15', NULL)
SELECT * FROM store.get_weekly_donuts_sold('2023-04-01', '2023-06-30', NULL)
SELECT * FROM store.get_daily_donuts_sold('2023-7-1', '2023-7-6', NULL)
SELECT DATE_TRUNC('week', '2023-06-26'::date) + INTERVAL '6 days';*/