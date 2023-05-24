CREATE OR REPLACE FUNCTION store.get_user_id(user_email TEXT)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
DECLARE
	user_account_id INT;
BEGIN
	SELECT A.account_id INTO user_account_id
	FROM store.account A
	WHERE email = user_email;
	
	RETURN user_account_id;
END;
$func$;

CREATE OR REPLACE FUNCTION store.get_user_infos(user_account_id INT)
RETURNS TABLE (infos JSON[], favorite_id INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER AS
$func$
DECLARE user_email TEXT;
BEGIN
	SELECT A.email INTO user_email FROM store.account A WHERE A.account_id = user_account_id;
	RETURN QUERY
	SELECT array_agg(json_build_object('first_name', UI.first_name, 'last_name', UI.last_name, 'phone_number', UI.phone_number, 'email', user_email)) AS infos,
	(
		SELECT UI2.user_info_id
		FROM store.user_info UI2
		WHERE UI2.is_favorited = true
	) AS favorite_id
	FROM store.user_info UI
	WHERE UI.account_id = user_account_id;
END;
$func$;