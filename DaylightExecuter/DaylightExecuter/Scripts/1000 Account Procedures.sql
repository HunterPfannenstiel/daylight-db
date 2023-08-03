CREATE OR REPLACE PROCEDURE store.edit_user_info(
	OUT new_info_id INTEGER,
	info_account_id INTEGER, 
	info_first_name TEXT DEFAULT NULL, 
	info_last_name TEXT DEFAULT NULL, 
	info_phone_number TEXT DEFAULT NULL, 
	favorite BOOL DEFAULT false, 
	info_id INTEGER DEFAULT NULL, 
	should_update BOOL DEFAULT false
)
LANGUAGE plpgsql
SECURITY DEFINER AS
$$
DECLARE favorited_id INTEGER;
BEGIN
	IF favorite THEN
			SELECT UI.user_info_id INTO favorited_id
			FROM store.user_info UI 
			WHERE UI.account_id = info_account_id 
				AND UI.is_favorited = true;

			IF favorited_id IS NOT NULL THEN
				UPDATE store.user_info
				SET is_favorited = false
				FROM store.user_info UI
				WHERE UI.user_info_id = favorited_id;
			END IF;
		END IF;
		
	IF info_id IS NOT NULL THEN
		IF NOT EXISTS (SELECT * FROM store.user_info UI WHERE UI.user_info_id = info_id AND UI.account_id = info_account_id AND UI.is_archived = false) THEN
			RAISE EXCEPTION 'User info does not exist for the info_id passed in or the passed in info_account_id is not associated with info_id';
		END IF;
		
		IF should_update THEN
			UPDATE store.user_info 
			SET first_name = COALESCE(info_first_name, first_name),
				last_name = COALESCE(info_last_name, last_name),
				phone_number = COALESCE(info_phone_number, phone_number),
				is_favorited = COALESCE(favorite, is_favorited)
			WHERE user_info_id = info_id;
		ELSE
			UPDATE store.user_info
			SET is_archived = true
			WHERE user_info_id = info_id;
		END IF;	
	ELSE
		INSERT INTO store.user_info(account_id, first_name, last_name, phone_number, is_favorited)
		VALUES(info_account_id, info_first_name, info_last_name, info_phone_number, favorite)
		RETURNING user_info_id INTO new_info_id;
	END IF;
END;
$$;

SELECT * FROM store.user_info UI WHERE UI.user_info_id = 58 AND UI.account_id = 2 AND UI.is_archived = true