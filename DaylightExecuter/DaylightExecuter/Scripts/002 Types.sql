CREATE TYPE store.menu_items AS (
	name TEXT,
	image_url TEXT,
	price numeric(4, 2)
);

CREATE TYPE store.new_cart_item AS (
	cart_item_id INTEGER,
	menu_item_id SMALLINT,
	amount INTEGER,
	extra_ids SMALLINT[]
);

CREATE TYPE store.customer_info_t AS (
	first_name TEXT,
	last_name TEXT,
	email TEXT,
	phone_number TEXT
);

CREATE TYPE store.images AS (
	"publicId" TEXT,
	"imageUrl" TEXT,
	"displayOrder" SMALLINT,
	"imageId" INTEGER
);

CREATE TYPE store.extra_group_info AS (
	"id" SMALLINT,
	"displayOrder" SMALLINT
);

CREATE TYPE store.extras_info AS (
	"id" SMALLINT,
	"displayOrder" SMALLINT
);

CREATE TYPE store.item_infos AS (
	"itemId" SMALLINT,
	"subcategory" TEXT
);