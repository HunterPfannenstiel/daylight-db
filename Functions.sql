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
LANGUAGE plpgsql AS
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

SELECT * FROM store.fetch_menu_items('Savory', NULL);

--Fetches the specific items within a grouping
CREATE OR REPLACE FUNCTION store.fetch_grouping_items(grouping_name TEXT)
RETURNS SETOF store.menu_items
LANGUAGE plpgsql AS
$func$
BEGIN
	RETURN QUERY
	SELECT MI.name, MI.image, MI.price
	FROM store.menu_item MI
	JOIN store.grouping G ON G.grouping_id = MI.grouping_id
	WHERE G.name = grouping_name AND MI.is_active = true;
END;
$func$;

SELECT * FROM store.fetch_grouping_items('Donut Holes');
--END OF FUNCTIONS CREATED IN 'Tables.sql'

--Fetches the various groupings and displays them like a menu item
CREATE OR REPLACE FUNCTION store.fetch_groupings()
RETURNS TABLE ( name TEXT, image TEXT, price numeric(4,2))
LANGUAGE plpgsql AS
$func$
BEGIN
	RETURN QUERY
	SELECT G.name, G.image, G.price 
	FROM store.grouping G;
END;
$func$;

SELECT * FROM store.fetch_groupings();

--Fetches the details of a menu item
CREATE OR REPLACE FUNCTION store.fetch_item_details(item_name TEXT)
RETURNS TABLE (name TEXT, id SMALLINT, price NUMERIC(4,2), image TEXT, description TEXT, groupprice NUMERIC(4,2), groupname TEXT, groupsize SMALLINT, extras JSON)
LANGUAGE plpgsql AS
$func$
BEGIN
	RETURN QUERY
	SELECT tb.name, tb.menu_item_id AS id, tb.price, tb.image, tb.description, tb.groupprice, tb.groupname, tb.groupsize, json_agg(tb.extras) AS extras
	FROM(
		SELECT MI.name, MI.menu_item_id, MI.price, MI.image, MI.description, G.price AS groupprice, G.name AS groupname, G.size AS groupsize,
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
	GROUP BY tb.name, tb.menu_item_id, tb.price, tb.image, tb.description, tb.groupprice, tb.groupname, tb.groupsize;
END;
$func$;

SELECT * FROM store.fetch_item_details('Kolache')