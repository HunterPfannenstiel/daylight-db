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

CREATE OR REPLACE FUNCTION store.get_monthly_donuts_sold(begin_date DATE, end_date DATE, donut_type TEXT)
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
$func$;

/*Have to truncate the date to the beginning of the week because some weeks can span across 2 months*/
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
$func$;

CREATE OR REPLACE FUNCTION store.get_daily_donuts_sold(begin_date DATE, end_date DATE, donut_type TEXT)
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
SELECT * FROM store.order WHERE created_on = '2023-07-05'
SELECT * FROM store.get_dates('2023-06-15', '2023-07-15', 'day', '1 day');
SELECT * FROM store.get_donuts_sold('Glaze');
SELECT * FROM store.get_monthly_donuts_sold('2023-06-15', '2023-07-15', NULL)
SELECT * FROM store.get_weekly_donuts_sold('2023-04-01', '2023-06-30', NULL)
SELECT * FROM store.get_daily_donuts_sold('2023-7-1', '2023-7-6', NULL)
SELECT DATE_TRUNC('week', '2023-06-26'::date) + INTERVAL '6 days';*/