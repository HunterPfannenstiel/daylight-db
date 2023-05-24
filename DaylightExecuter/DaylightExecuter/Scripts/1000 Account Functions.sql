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