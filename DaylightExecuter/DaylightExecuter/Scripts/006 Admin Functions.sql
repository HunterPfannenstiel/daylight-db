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


