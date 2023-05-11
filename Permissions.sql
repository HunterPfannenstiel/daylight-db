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
--

--Procedure Permissions
GRANT EXECUTE ON PROCEDURE store.confirm_order(IN confirm_order_id integer, IN order_subtotal numeric, IN order_tax numeric, IN order_total numeric, IN order_payment_uid text) TO daylight_user;

GRANT EXECUTE ON PROCEDURE store.create_account(IN user_email text, OUT id integer, IN user_info json) TO daylight_user;

GRANT EXECUTE ON PROCEDURE store.create_cart(OUT id integer, IN items json) TO daylight_user;

GRANT EXECUTE ON PROCEDURE store.create_order(IN order_cart_id integer, IN order_location_id smallint, IN order_pickup_time_id smallint, IN order_pickup_date date, IN order_payment_processor smallint, OUT id integer, IN customer_info json, IN order_account_id integer, IN order_user_info_id integer) TO daylight_user;

GRANT EXECUTE ON PROCEDURE store.create_user_info(IN user_first_name text, IN user_last_name text, IN user_phone_number text, IN user_account_id integer) TO daylight_user;

GRANT EXECUTE ON PROCEDURE store.update_cart(IN id integer, IN items json) TO daylight_user;
--

--View Permissions
GRANT SELECT ON TABLE store.vw_menu_item_details TO daylight_user;
--

--Table Permissions
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.account TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.account_user_info TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.cart TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.cart_extra TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.cart_item TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.customer_order_info TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.extra TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.extra_category TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.extra_group TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.extra_group_extra TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store."grouping" TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.item_category TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.item_extra_group TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.item_range_availability TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.item_subcategory TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.location TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.menu_item TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.menu_item_category TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.menu_item_subcategory TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store."order" TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.payment_processor TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.pickup_time TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.range_availability TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.user_info TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.weekday TO daylight_user;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE store.weekday_availability TO daylight_user;
--

--Revoke Tables
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.account FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.account_user_info FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.cart FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.cart_extra FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.cart_item FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.customer_order_info FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.extra FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.extra_category FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.extra_group FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.extra_group_extra FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store."grouping" FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.item_category FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.item_extra_group FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.item_range_availability FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.item_subcategory FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.location FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.menu_item FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.menu_item_category FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.menu_item_subcategory FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store."order" FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.payment_processor FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.pickup_time FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.range_availability FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.user_info FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.weekday FROM daylight_user;
REVOKE INSERT, SELECT, UPDATE, DELETE ON TABLE store.weekday_availability FROM daylight_user;
--