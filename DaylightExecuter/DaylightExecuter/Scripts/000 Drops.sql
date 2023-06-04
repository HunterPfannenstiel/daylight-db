DROP TABLE IF EXISTS store."order";
DROP TABLE IF EXISTS store.location_pickup_time;
DROP TABLE IF EXISTS store.location_closed_weekday;
DROP TABLE IF EXISTS store.location;
DROP TABLE IF EXISTS store.customer_order_info;
DROP TABLE IF EXISTS store.pickup_time;
DROP TABLE IF EXISTS store.payment_processor;
DROP TABLE IF EXISTS store.cart_extra;
DROP TABLE IF EXISTS store.cart_item;
DROP TABLE IF EXISTS store.cart;
DROP TABLE IF EXISTS store.weekday_availability;
DROP TABLE IF EXISTS store.weekday;
DROP TABLE IF EXISTS store.menu_item_category;
DROP TABLE IF EXISTS store.menu_item_subcategory;
DROP TABLE IF EXISTS store.item_subcategory;
DROP TABLE IF EXISTS store.item_category;
DROP TABLE IF EXISTS store.item_extra_group;
DROP TABLE IF EXISTS store.extra_group_extra;
DROP TABLE IF EXISTS store.extra_group;
DROP TABLE IF EXISTS store.extra;
DROP TABLE IF EXISTS store.extra_category;
DROP TABLE IF EXISTS store.tax;
DROP TABLE IF EXISTS store.menu_item_image;
DROP FUNCTION IF EXISTS store.fetch_grouping_items;
DROP FUNCTION IF EXISTS store.fetch_menu_items;
DROP VIEW IF EXISTS store.vw_menu_item_details;
DROP TYPE IF EXISTS store.menu_items;
DROP TABLE IF EXISTS store.menu_item;
DROP TABLE IF EXISTS store."grouping";
DROP TABLE IF EXISTS store.image;
DROP TABLE IF EXISTS store.user_info;
DROP TABLE IF EXISTS store.account;
DROP TYPE IF EXISTS store.new_cart_item;
DROP TYPE IF EXISTS store.customer_info_t;
DROP FUNCTION IF EXISTS store.get_item_images;
DROP FUNCTION IF EXISTS store.get_item_extras;
DROP FUNCTION IF EXISTS store.fetch_groupings;
DROP FUNCTION IF EXISTS store.fetch_grouping_names;
DROP FUNCTION IF EXISTS store.fetch_item_details;
DROP FUNCTION IF EXISTS store.fetch_group_item_details;
DROP FUNCTION IF EXISTS store.view_cart;
DROP FUNCTION IF EXISTS store.view_account_orders;
DROP FUNCTION IF EXISTS store.check_cart_process;
DROP FUNCTION IF EXISTS store.get_checkout_info;
DROP FUNCTION IF EXISTS store.get_cart_availability;
DROP FUNCTION IF EXISTS store.fetch_totaling_cart;
DROP FUNCTION IF EXISTS store.retrieve_stripe_id;
DROP FUNCTION IF EXISTS store.fetch_paypal_order_items;
DROP FUNCTION IF EXISTS store.fetch_group_info;
DROP FUNCTION IF EXISTS store.fetch_menu_names;
DROP FUNCTION IF EXISTS store.fetch_categories;
DROP FUNCTION IF EXISTS store.get_user_id;
DROP FUNCTION IF EXISTS store.fetch_item_customizations;
DROP FUNCTION IF EXISTS store.fetch_item_selections;
DROP FUNCTION IF EXISTS store.fetch_item_initial_categories;
DROP FUNCTION IF EXISTS store.search_items;
DROP PROCEDURE IF EXISTS store.check_cart_lock;
DROP PROCEDURE IF EXISTS store.update_cart;
DROP PROCEDURE IF EXISTS store.create_cart;
DROP PROCEDURE IF EXISTS store.update_cart_lock;
DROP PROCEDURE IF EXISTS store.insert_stripe_uid;
DROP PROCEDURE IF EXISTS store.check_order_verification;
DROP PROCEDURE IF EXISTS store.create_order;
DROP PROCEDURE IF EXISTS store.insert_customer_order_info;
DROP PROCEDURE IF EXISTS store.confirm_order;
DROP PROCEDURE IF EXISTS store.set_order_error;
DROP PROCEDURE IF EXISTS store.create_user_info;
DROP PROCEDURE IF EXISTS store.create_account;
DROP PROCEDURE IF EXISTS store.modify_menu_item;
DROP PROCEDURE IF EXISTS store.update_item_extras;
DROP PROCEDURE IF EXISTS store.create_menu_item;
DROP PROCEDURE IF EXISTS store.edit_user_info;
DROP TYPE IF EXISTS store.images;