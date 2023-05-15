--Schema Permission
GRANT USAGE ON SCHEMA store TO daylight_user;
--

--Function Permissions
GRANT EXECUTE ON FUNCTION store.fetch_grouping_items(grouping_name text) TO daylight_user;

GRANT EXECUTE ON FUNCTION store.fetch_groupings() TO daylight_user;

GRANT EXECUTE ON FUNCTION store.fetch_groupings(grouping_name text) TO daylight_user;

GRANT EXECUTE ON FUNCTION store.fetch_item_details(item_name text) TO daylight_user;

GRANT EXECUTE ON FUNCTION store.fetch_menu_items(category text, subcategory text) TO daylight_user;

GRANT EXECUTE ON FUNCTION store.get_cart_availability(user_cart_id integer) TO daylight_user;

GRANT EXECUTE ON FUNCTION store.get_checkout_info() TO daylight_user;

GRANT EXECUTE ON FUNCTION store.view_cart(user_cart_id integer) TO daylight_user;

GRANT EXECUTE ON FUNCTION store.fetch_categories() TO daylight_user;

GRANT EXECUTE ON FUNCTION store.fetch_totaling_cart(user_cart_id integer) TO daylight_user;

GRANT EXECUTE ON FUNCTION store.retrieve_stripe_id(user_cart_id integer) TO daylight_user;
--

--Procedure Permissions
GRANT EXECUTE ON PROCEDURE store.confirm_order(IN confirm_order_id integer, IN order_subtotal numeric, IN order_tax numeric, IN order_total numeric, IN order_payment_uid text) TO daylight_user;

GRANT EXECUTE ON PROCEDURE store.create_account(IN user_email text, OUT id integer, IN user_info json) TO daylight_user;

GRANT EXECUTE ON PROCEDURE store.create_cart(OUT id integer, IN items json) TO daylight_user;

GRANT EXECUTE ON PROCEDURE store.create_order(IN order_cart_id integer, IN order_location_id smallint, IN order_pickup_time_id smallint, IN order_pickup_date date, IN order_payment_processor smallint, OUT id integer, IN customer_info json, IN order_account_id integer, IN order_user_info_id integer) TO daylight_user;

GRANT EXECUTE ON PROCEDURE store.create_user_info(IN user_first_name text, IN user_last_name text, IN user_phone_number text, IN user_account_id integer) TO daylight_user;

GRANT EXECUTE ON PROCEDURE store.update_cart(IN id integer, IN items json) TO daylight_user;

GRANT EXECUTE ON PROCEDURE store.check_order_verification(user_cart_id integer) TO daylight_user;

GRANT EXECUTE ON PROCEDURE store.insert_stripe_uid(user_cart_id integer, stripe_id text) TO daylight_user;
--

--View Permissions
GRANT SELECT ON TABLE store.vw_menu_item_details TO daylight_user;
--