CREATE OR REPLACE FUNCTION store.fetch_item_customizations()
RETURNS TABLE (groupings JSON, extra_groupings JSON, item_categories JSON)
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
RETURNS TABLE (name TEXT, price NUMERIC(4,2), description TEXT, image_id INTEGER, initial_group_id SMALLINT, initial_extra_groupings JSON[], initial_item_categories JSON[], initial_weekdays JSON[], initial_range DATERANGE)
LANGUAGE plpgsql
AS
$func$
BEGIN
	RETURN QUERY
	SELECT MI.name, MI.price, MI.description, MI.image_id,
	G.grouping_id AS initial_group_id, array_agg(json_build_object(EC.name, IEG.extra_group_id)) AS initial_extra_groupings,
	(SELECT array_agg(tb) FROM store.fetch_item_initial_categories(item_id) tb) AS initial_item_categories, 
	array_agg(CASE WHEN WA.weekday_id IS NOT NULL THEN json_build_object(WA.weekday_id, true) END) AS initial_weekdays, MI.availability_range AS initial_range
	FROM store.menu_item MI
	JOIN store.grouping G ON G.grouping_id = MI.grouping_id
	LEFT JOIN store.item_extra_group IEG ON IEG.menu_item_id = MI.menu_item_id
	LEFT JOIN store.extra_group EG ON EG.extra_group_id = IEG.extra_group_id
	LEFT JOIN store.extra_category EC ON EC.extra_category_id = EG.extra_category_id
	LEFT JOIN store.weekday_availability WA ON WA.menu_item_id = MI.menu_item_id
	WHERE MI.menu_item_id = item_id
	GROUP BY MI.name, MI.price, MI.description, MI.image_id, G.grouping_id, MI.availability_range;
END;
$func$;

CREATE OR REPLACE FUNCTION store.fetch_item_initial_categories(item_id SMALLINT)
RETURNS TABLE (categories JSON)
LANGUAGE plpgsql
AS
$func$
BEGIN
	RETURN QUERY
	SELECT json_build_object(MIC.item_category_id, array_agg(CASE WHEN "IS".item_subcategory_id IS NOT NULL THEN json_build_object("IS".item_subcategory_id, true) END)) AS categories
	FROM store.menu_item_category MIC
	LEFT JOIN store.item_category IC ON IC.item_category_id = MIC.item_category_id
	LEFT JOIN store.menu_item_subcategory MIS ON MIS.menu_item_id = MIC.menu_item_id
	LEFT JOIN store.item_subcategory "IS" ON "IS".item_category_id = IC.item_category_id 
		AND "IS".item_subcategory_id = MIS.item_subcategory_id
	WHERE MIC.menu_item_id = item_id
	GROUP BY MIC.item_category_id;
END;
$func$;