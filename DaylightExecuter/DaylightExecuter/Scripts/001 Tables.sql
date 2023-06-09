-- This script was generated by a beta version of the ERD tool in pgAdmin 4.
BEGIN;

CREATE TABLE IF NOT EXISTS store."order"
(
    order_id serial NOT NULL,
    cart_id integer NOT NULL,
    customer_order_info_id integer,
    location_id smallint NOT NULL,
    pickup_time_id smallint NOT NULL,
    pickup_date date NOT NULL,
    payment_processor_id smallint,
    is_printed boolean NOT NULL DEFAULT false,
    is_verified boolean NOT NULL DEFAULT false,
    error_message text,
    subtotal numeric(6, 2),
    tax numeric(5, 2),
    total_price numeric(6, 2),
	processor_fee numeric(5, 2),
    payment_uid text,
    created_on timestamp(0) NOT NULL DEFAULT NOW(),
    user_info_id integer,
	account_id integer,
    PRIMARY KEY (order_id)
);

CREATE TABLE IF NOT EXISTS store.location
(
    location_id smallserial NOT NULL,
    city text NOT NULL,
    state text NOT NULL,
    zip text NOT NULL,
    address text NOT NULL,
    common_name text,
    phone_number text,
    PRIMARY KEY (location_id)
);

CREATE TABLE IF NOT EXISTS store.cart
(
    cart_id serial NOT NULL,
    last_modified timestamp without time zone DEFAULT current_timestamp NOT NULL,
    is_locked boolean NOT NULL DEFAULT false,
	stripe_uid text,
    PRIMARY KEY (cart_id)
);

CREATE TABLE IF NOT EXISTS store.cart_item
(
    cart_id integer NOT NULL,
    cart_item_id integer NOT NULL,
    menu_item_id integer NOT NULL,
    amount integer NOT NULL,
    subtotal numeric(5, 2),
    PRIMARY KEY (cart_id, cart_item_id),
    UNIQUE (cart_id, cart_item_id)
);

CREATE TABLE IF NOT EXISTS store.cart_extra
(
    cart_item_id integer NOT NULL,
    cart_id integer NOT NULL,
    extra_id integer NOT NULL,
    PRIMARY KEY (cart_item_id, cart_id, extra_id)
);

CREATE TABLE IF NOT EXISTS store."grouping"
(
    grouping_id smallserial NOT NULL,
    price numeric(4, 2) NOT NULL,
    name text NOT NULL,
    size smallint NOT NULL,
    image_id integer NOT NULL,
	is_active boolean DEFAULT true NOT NULL,
    PRIMARY KEY (grouping_id),
	UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS store.menu_item
(
    menu_item_id smallserial NOT NULL,
    name text NOT NULL,
    price numeric(4, 2) NOT NULL,
    description text NOT NULL,
	image_id integer NOT NULL,
    grouping_id smallint,
	availability_range DATERANGE,
    is_active boolean NOT NULL DEFAULT true,
	is_archived boolean NOT NULL DEFAULT false,
    PRIMARY KEY (menu_item_id),
    UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS store.image
(
	image_id serial NOT NULL,
	image_url text NOT NULL,
	public_id text NOT NULL,
	PRIMARY KEY (image_id),
	UNIQUE (public_id)
);

CREATE TABLE IF NOT EXISTS store.menu_item_image
(
	menu_item_id smallint NOT NULL,
	image_id integer NOT NULL,
	display_order smallint,
	UNIQUE(menu_item_id, display_order),
	PRIMARY KEY (menu_item_id, image_id)
);

CREATE TABLE IF NOT EXISTS store.weekday_availability
(
    menu_item_id smallserial NOT NULL,
    weekday_id smallint NOT NULL,
    PRIMARY KEY (menu_item_id, weekday_id)
);

CREATE TABLE IF NOT EXISTS store.item_category
(
    item_category_id smallserial NOT NULL,
    name text NOT NULL,
	display_order smallint,
    is_active boolean NOT NULL DEFAULT true,
    PRIMARY KEY (item_category_id),
    UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS store.item_subcategory
(
    item_subcategory_id smallserial NOT NULL,
    item_category_id smallint NOT NULL,
    name text NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    PRIMARY KEY (item_subcategory_id),
    UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS store.extra_category
(
    extra_category_id serial NOT NULL,
    name text NOT NULL,
    PRIMARY KEY (extra_category_id),
    UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS store.extra
(
    extra_id smallserial NOT NULL,
    name text NOT NULL,
    price numeric(4, 2),
    extra_category_id smallint,
	abbreviation text,
    PRIMARY KEY (extra_id),
    UNIQUE (name, extra_category_id, price)
);

CREATE TABLE IF NOT EXISTS store.menu_item_category
(
    item_category_id smallint NOT NULL,
    menu_item_id smallint NOT NULL,
    PRIMARY KEY (item_category_id, menu_item_id)
);

CREATE TABLE IF NOT EXISTS store.menu_item_subcategory
(
    menu_item_id smallint NOT NULL,
    item_subcategory_id smallint NOT NULL,
    PRIMARY KEY (menu_item_id, item_subcategory_id)
);

CREATE TABLE IF NOT EXISTS store.extra_group
(
    extra_group_id smallserial NOT NULL,
    extra_category_id smallint NOT NULL,
    name text NOT NULL,
    PRIMARY KEY (extra_group_id),
    UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS store.extra_group_extra
(
    extra_id smallint NOT NULL,
    extra_group_id smallint NOT NULL,
	order_value smallint,
    PRIMARY KEY (extra_id, extra_group_id),
	UNIQUE(extra_group_id, order_value)
);

CREATE TABLE IF NOT EXISTS store.item_extra_group
(
    extra_group_id smallint NOT NULL,
    menu_item_id smallint NOT NULL,
    PRIMARY KEY (extra_group_id, menu_item_id)
);

CREATE TABLE IF NOT EXISTS store.customer_order_info
(
    customer_order_info_id serial NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text NOT NULL,
    phone_number text NOT NULL,
    PRIMARY KEY (customer_order_info_id)
);

CREATE TABLE IF NOT EXISTS store.weekday
(
    weekday_id smallint NOT NULL,
    weekday character varying(9) NOT NULL,
    PRIMARY KEY (weekday_id),
    UNIQUE (weekday)
);

CREATE TABLE IF NOT EXISTS store.location_closed_weekday
(
	location_id smallint NOT NULL,
	weekday_id smallint NOT NULL
);

CREATE TABLE IF NOT EXISTS store.account
(
    account_id serial NOT NULL,
    email text NOT NULL,
    PRIMARY KEY (account_id),
    UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS store.user_info
(
    user_info_id serial NOT NULL,
	account_id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    phone_number text NOT NULL,
	is_favorited boolean NOT NULL DEFAULT false,
	is_archived boolean NOT NULL DEFAULT false,
    PRIMARY KEY (user_info_id)
);

CREATE TABLE IF NOT EXISTS store.pickup_time
(
    pickup_time_id smallserial NOT NULL,
    pickup_time time(0) without time zone NOT NULL,
	is_active boolean DEFAULT true,
    PRIMARY KEY (pickup_time_id)
);

CREATE TABLE IF NOT EXISTS store.location_pickup_time
(
	location_id smallint NOT NULL,
	pickup_time_id smallint NOT NULL,
	PRIMARY KEY(location_id, pickup_time_id)
);

CREATE TABLE IF NOT EXISTS store.payment_processor
(
    payment_processor_id smallserial NOT NULL,
    payment_processor text NOT NULL,
    PRIMARY KEY (payment_processor_id)
);

CREATE TABLE IF NOT EXISTS store.tax
(
	tax_amount numeric(3,3) NOT NULL,
	PRIMARY KEY (tax_amount)
);

ALTER TABLE IF EXISTS store."order"
    ADD FOREIGN KEY (cart_id)
    REFERENCES store.cart (cart_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store."order"
    ADD FOREIGN KEY (location_id)
    REFERENCES store.location (location_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store."order"
    ADD FOREIGN KEY (customer_order_info_id)
    REFERENCES store.customer_order_info (customer_order_info_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store."order"
    ADD FOREIGN KEY (user_info_id)
    REFERENCES store.user_info (user_info_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
	
ALTER TABLE IF EXISTS store."order"
    ADD FOREIGN KEY (account_id)
    REFERENCES store.account (account_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS store."order"
    ADD FOREIGN KEY (payment_processor_id)
    REFERENCES store.payment_processor (payment_processor_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store."order"
    ADD FOREIGN KEY (pickup_time_id)
    REFERENCES store.pickup_time (pickup_time_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS store."order"
	ADD CONSTRAINT customer_info_or_user_info 
	CHECK(customer_order_info_id IS NOT NULL OR user_info_id IS NOT NULL);

ALTER TABLE IF EXISTS store.cart_item
    ADD FOREIGN KEY (cart_id)
    REFERENCES store.cart (cart_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store.cart_item
    ADD FOREIGN KEY (menu_item_id)
    REFERENCES store.menu_item (menu_item_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store.cart_extra
    ADD FOREIGN KEY (cart_item_id, cart_id)
    REFERENCES store.cart_item (cart_item_id, cart_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE
    NOT VALID;
	
ALTER TABLE IF EXISTS store.cart_extra
    ADD FOREIGN KEY (extra_id)
    REFERENCES store.extra (extra_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE
    NOT VALID;
	
ALTER TABLE IF EXISTS store.user_info
	ADD FOREIGN KEY (account_id)
	REFERENCES store.account (account_id) MATCH SIMPLE
	ON UPDATE NO ACTION
    ON DELETE CASCADE
    NOT VALID;
	
ALTER TABLE IF EXISTS store.grouping
	ADD FOREIGN KEY (image_id)
	REFERENCES store.image (image_id) MATCH SIMPLE
	ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
	
ALTER TABLE IF EXISTS store.menu_item
	ADD FOREIGN KEY (image_id)
	REFERENCES store.image (image_id) MATCH SIMPLE
	ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
	
ALTER TABLE IF EXISTS store.menu_item
    ADD FOREIGN KEY (grouping_id)
    REFERENCES store."grouping" (grouping_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
	
ALTER TABLE IF EXISTS store.menu_item_image
	ADD FOREIGN KEY (menu_item_id)
	REFERENCES store.menu_item (menu_item_id) MATCH SIMPLE
	ON UPDATE NO ACTION
	ON DELETE NO ACTION
	NOT VALID;
	
ALTER TABLE IF EXISTS store.menu_item_image
	ADD FOREIGN KEY (image_id)
	REFERENCES store.image (image_id)
	ON UPDATE NO ACTION
	ON DELETE CASCADE
	NOT VALID;

ALTER TABLE IF EXISTS store.weekday_availability
    ADD FOREIGN KEY (menu_item_id)
    REFERENCES store.menu_item (menu_item_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store.weekday_availability
    ADD FOREIGN KEY (weekday_id)
    REFERENCES store.weekday (weekday_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store.item_subcategory
    ADD FOREIGN KEY (item_category_id)
    REFERENCES store.item_category (item_category_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store.extra
    ADD FOREIGN KEY (extra_category_id)
    REFERENCES store.extra_category (extra_category_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store.menu_item_category
    ADD FOREIGN KEY (item_category_id)
    REFERENCES store.item_category (item_category_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store.menu_item_category
    ADD FOREIGN KEY (menu_item_id)
    REFERENCES store.menu_item (menu_item_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store.menu_item_subcategory
    ADD FOREIGN KEY (menu_item_id)
    REFERENCES store.menu_item (menu_item_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store.menu_item_subcategory
    ADD FOREIGN KEY (item_subcategory_id)
    REFERENCES store.item_subcategory (item_subcategory_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store.extra_group
    ADD FOREIGN KEY (extra_category_id)
    REFERENCES store.extra_category (extra_category_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store.extra_group_extra
    ADD FOREIGN KEY (extra_id)
    REFERENCES store.extra (extra_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store.extra_group_extra
    ADD FOREIGN KEY (extra_group_id)
    REFERENCES store.extra_group (extra_group_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store.item_extra_group
    ADD FOREIGN KEY (extra_group_id)
    REFERENCES store.extra_group (extra_group_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS store.item_extra_group
    ADD FOREIGN KEY (menu_item_id)
    REFERENCES store.menu_item (menu_item_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
	
ALTER TABLE IF EXISTS store.location_pickup_time
	ADD FOREIGN KEY (location_id)
	REFERENCES store.location (location_id) MATCH SIMPLE
	ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS store.location_pickup_time
	ADD FOREIGN KEY (pickup_time_id)
	REFERENCES store.pickup_time (pickup_time_id) MATCH SIMPLE
	ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
	
ALTER TABLE IF EXISTS store.location_closed_weekday
	ADD FOREIGN KEY (location_id)
	REFERENCES store.location (location_id) MATCH SIMPLE
	ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
	
ALTER TABLE IF EXISTS store.location_closed_weekday
	ADD FOREIGN KEY (weekday_id)
	REFERENCES store.weekday (weekday_id) MATCH SIMPLE
	ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

CREATE OR REPLACE VIEW store.vw_menu_item_details AS 
	SELECT MI.name, MI.price, I.image_url, MI.menu_item_id, MI.is_active
	FROM store.menu_item MI
	JOIN store.image I ON I.image_id = MI.image_id
	WHERE MI.is_active = true;
END;