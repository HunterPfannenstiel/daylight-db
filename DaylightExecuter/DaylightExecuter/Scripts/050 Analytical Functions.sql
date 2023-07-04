/*CREATE OR REPLACE FUNCTION store.get_donuts_sold_within_time_frame(begin_date DATE, end_date DATE, time_unit TEXT, donut_type TEXT)
RETURNS TABLE ()
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
BEGIN
	
END;
$func$;*/

CREATE OR REPLACE FUNCTION store.get_monthly_donuts_sold(begin_date DATE, end_date DATE, donut_type TEXT)
RETURNS TABLE (year DOUBLE PRECISION, month TEXT, amount NUMERIC)
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
		SELECT DATE_PART('year', DS.created_on) AS year, 
			TO_CHAR(DS.created_on::TIMESTAMP, 'Mon') AS month,
			SUM(DS.amount) AS amount
		FROM store.get_donuts_sold(donut_type) DS
		WHERE DS.created_on BETWEEN DATE_TRUNC('month', begin_date) AND DATE_TRUNC('month', end_date) + INTERVAL '1 month - 1 day'
		GROUP BY DATE_PART('year', DS.created_on),
			TO_CHAR(DS.created_on::TIMESTAMP, 'Mon')
		ORDER BY year ASC, month ASC;
END;
$func$;

CREATE OR REPLACE FUNCTION store.get_weekly_donuts_sold(begin_date DATE, end_date DATE, donut_type TEXT)
RETURNS TABLE (year DOUBLE PRECISION, month TEXT, week DOUBLE PRECISION, amount NUMERIC)
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
		SELECT DATE_PART('year', DS.created_on) AS year, 
			TO_CHAR(DS.created_on::TIMESTAMP, 'Mon') AS month,
			DATE_PART('week', DS.created_on) AS week,
			SUM(DS.amount) AS amount
		FROM store.get_donuts_sold(donut_type) DS
		/* 1 week - 1 day might be wrong */
		WHERE DS.created_on BETWEEN DATE_TRUNC('week', begin_date) AND DATE_TRUNC('week', end_date) + INTERVAL '1 week - 1 day'
		GROUP BY DATE_PART('year', DS.created_on),
			TO_CHAR(DS.created_on::TIMESTAMP, 'Mon'),
			DATE_PART('week', DS.created_on)
		ORDER BY year ASC, month ASC, week ASC;
END;
$func$;

CREATE OR REPLACE FUNCTION store.get_daily_donuts_sold(begin_date DATE, end_date DATE, donut_type TEXT)
RETURNS TABLE (year DOUBLE PRECISION, month TEXT, day DOUBLE PRECISION, amount NUMERIC)
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
BEGIN
	RETURN QUERY
		SELECT DATE_PART('year', DS.created_on) AS year, 
			TO_CHAR(DS.created_on::TIMESTAMP, 'Mon') AS month,
			DATE_PART('day', DS.created_on) AS day,
			SUM(DS.amount) AS amount
		FROM store.get_donuts_sold(donut_type) DS
		WHERE DS.created_on BETWEEN begin_date AND end_date
		GROUP BY DATE_PART('year', DS.created_on),
			TO_CHAR(DS.created_on::TIMESTAMP, 'Mon'),
			DATE_PART('day', DS.created_on)
		ORDER BY year ASC, month ASC, day ASC;
END;
$func$;

CREATE OR REPLACE FUNCTION store.get_donuts_sold(donut_type TEXT)
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
$func$;

/*SELECT name FROM store.menu_item;
SELECT * FROM store.get_donuts_sold('Glaze');
SELECT * FROM store.get_monthly_donuts_sold('2023-06-15', '2023-07-15', NULL)
SELECT * FROM store.get_weekly_donuts_sold('2023-06-15', '2023-07-15', NULL)
SELECT * FROM store.get_daily_donuts_sold('2023-06-15', '2023-07-15', NULL)
SELECT DATE_TRUNC('week', '2023-06-15'::date) + INTERVAL '1 week - 1 day';*/