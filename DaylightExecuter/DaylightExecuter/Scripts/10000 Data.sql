ALTER SEQUENCE store.image_image_id_seq RESTART WITH 1;

INSERT INTO store.image(image_url, public_id) VALUES 
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400003/item_images/tjah32egdkq8idarjgkd.png', 'glaze'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400201/item_images/l7gfyvo8tps7zwdin4wn.png', 'blueberry'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400184/item_images/x9zkxmolm60ezdtdxyvv.png', 'chocolate'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400244/item_images/fgvymicizcsmmwqgbgyh.png', 'old fashion'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400038/item_images/dnpdlshemy8o5tyfud3x.png', 'white'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400128/item_images/sc3ak4kogmgwtfop5rtv.png', 'bearclaw'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400165/item_images/ymaoojgwuxwwnothysau.png', 'bismark'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400219/item_images/m6ikhqa5jbxcmsijcugx.png', 'apple fritter'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400190/item_images/pkxmpk0cksokr7owp3dv.png', 'cinnamon roll'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400252/item_images/zkq02moggopu8sm7ykz2.png', 'fried roll'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400224/item_images/rr7rlz3sshtwbvpvdp5r.png', 'knot'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400247/item_images/pihzt8aa2r2fo3va0yfx.png', 'pinecone'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400237/item_images/eutffmss66bvkeakzluu.png', 'longjohn'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400269/item_images/qf1w5yix2npebwjfjyvu.png', 'twist'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400208/item_images/vnlysmjlt4e3n3fmoram.png', 'glazed donut holes'),
('imageURL', 'blueberry donut holes'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400196/item_images/uxugecee5valahl88zzx.png', 'biscuit sandwich'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400196/item_images/uxugecee5valahl88zzx.png', 'croissant sandwich'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400158/item_images/awlhxhnsh45auqicxliq.png', 'biscuits and gravy'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400232/item_images/crlfbuwp00zndxhzbekn.png', 'kolache'),
('https://res.cloudinary.com/dwg1i9w2u/image/upload/v1673400213/item_images/lxq8mszreuxcb66kbjjn.png', 'baked cinnamon roll'),
('imageURL', 'french cruller');

ALTER SEQUENCE store.grouping_grouping_id_seq RESTART WITH 1;

INSERT INTO store.grouping (price, name, size, image_id) VALUES 
(10.50, 'Raised and Cake', 12, 1), 
(2.19, 'Donut Holes', 12, 15);

ALTER SEQUENCE store.menu_item_menu_item_id_seq RESTART WITH 1;

INSERT INTO store.menu_item (name, price, image_id, description, grouping_id) VALUES 
('Glaze', 1.19, 1, 'Made fresh from scratch for you. Soft, delicious raised donut melts in your mouth!', 1), 
('Blueberry', 1.19, 2, 'You can''t beat a blueberry donut! Fresh, glazed or cream cheese icing!', 1), 
('Chocolate', 1.19, 3, 'Fresh chocolate batter fried to perfection with a finish of delightful glaze!', 1), 
('Old Fashion', 1.19, 4, 'Often called an old fashioned or a sour cream donut, this cake donut is a timeless classic for good reason.  It''s YUMMY!', 1), 
('White', 1.19, 5, 'Amazing white cake batter fried to perfection!', 1), 

('Bearclaw', 1.79, 6, 'A spiced delight!  Our bear claws have a spice added to the dough and are fried and glazed.', NULL), 
('Bismark', 1.79, 7, 'Typically glazed, filled with lemon, bavarian cream, white holland cream, or black raspberry jelly.  Bavarian is a chocolate iced donut with the vanilla bavarian cream pudding in it.', NULL), 
('Apple Fritter', 1.79, 8, 'Daylight dough with cinnamon and spice and delicious chunks of apple fried to a crispy fritter.  It''s unique but it''s delicious!  A favorite of many.', NULL), 
('Cinnamon Roll', 1.79, 9, 'Warm, fresh and delicious fried cinnamon rolls with our famous Daylight Donuts glaze! So good!', NULL), 
('Fried Roll', 1.79, 10, 'A Daylight favorite!  Choose your icing. With or without peanuts. Very delicious!', NULL), 
('Knot', 1.79, 11, 'A traditional knot.  It''s a cross between a glazed donut and a long john.  Add your favorite icing if you like.', NULL), 
('Pinecone', 1.79, 12, 'Made fresh from scratch for you. Soft, delicious cinnamon flavor donut melts in your mouth!', NULL), 

('Long John', 1.69, 13, 'Made fresh from scratch for you. Soft, delicious raised donut melts in your mouth!', NULL), 
('Twist', 1.69, 14, 'Our warm, fresh glazed twists are the best of both worlds!  Part glazed donut, part long john.  Goes great with a cold milk!', NULL), 
 
('Glazed Donut Holes', 0.17, 15, 'Glazed holes travel well.  Eat them at the stoplight so the donuts make it home.', 2), 
('Blueberry Donut Holes', 0.17, 16, 'Just like its parent but bite-size!', 2), 

('Biscuit Sandwich', 3.49, 17, 'A fresh and DELICIOUS way to start the morning! Choose from Sausage, Egg, and Cheese or Bacon, Egg, and Cheese on a biscuit.', NULL), 
('Croissant Sandwich', 3.49, 18, 'A fresh and DELICIOUS way to start the morning! Choose from Sausage, Egg, and Cheese or Bacon, Egg, and Cheese on a large, flaky, fresh croissant.', NULL), 
('Biscuits and Gravy', 2.79, 19, 'Our warm and delicious buttermilk biscuits topped with our sausage gravy really hit''s the spot in the morning!', NULL), 
('Kolache', 2.79, 20, 'Another savory breakfast favorite in Hutchinson is our Kolaches.  A cheddar or jalapeno sausage wrapped in our signature Daylight Donuts dough then baked and lightly buttered with our honey butter.  It''s warm and it''s filling!', NULL), 

('Baked Cinnamon Roll', 3.49, 21, 'A cinnamon roll that is baked, not fried, and made out of a special dough along with cinnamon, sugar, and butter combining for an irresistible delicacy', NULL), 
('French Cruller', 1.19, 22, 'Treat yourself to the light, airy deliciousness of our french cruller donuts. The delicate, twisted pastry is made from the finest ingredients and fried to golden perfection. The subtle sweetness of the dough pairs perfectly with a cup of coffee or tea. Don''t miss out on the unique flavor of our french cruller donuts - grab one today!', 1);

INSERT INTO store.menu_item_image(menu_item_id, image_id, display_order) VALUES
(1, 21, 1);

ALTER SEQUENCE store.item_category_item_category_id_seq RESTART WITH 1;

INSERT INTO store.item_category (name, display_order) VALUES 
('Donuts', 1),
('Savory', 2),
('Featured', 3);

ALTER SEQUENCE store.item_subcategory_item_subcategory_id_seq RESTART WITH 1;

INSERT INTO store.item_subcategory (name, item_category_id) VALUES 
('Raised', 1),
('Cake', 1),
('Specialty', 1);

INSERT INTO store.menu_item_category (item_category_id, menu_item_id) VALUES 
(1, 1), 
(1, 2), 
(1, 3), 
(1, 4), 
(1, 5), 
(1, 6), 
(1, 7), 
(1, 8), 
(1, 9), 
(1, 10), 
(1, 11), 
(1, 12), 
(1, 13), 
(1, 14), 
(1, 15), 
(1, 16), 

(2, 17), 
(2, 18), 
(2, 19), 
(2, 20),

(3, 1),
(3, 15),
(3, 20),
(3, 21);

INSERT INTO store.menu_item_subcategory (item_subcategory_id, menu_item_id) VALUES 
(1, 1), 
(1, 6), 
(1, 7), 
(1, 9), 
(1, 10), 
(1, 11), 
(1, 12), 
(1, 13), 
(1, 14), 
(1, 15), 

(2, 2), 
(2, 3), 
(2, 4), 
(2, 5), 
(2, 16), 

(3, 6), 
(3, 7), 
(3, 8), 
(3, 9), 
(3, 10), 
(3, 11), 
(3, 12), 
(3, 13), 
(3, 14);

ALTER SEQUENCE store.extra_category_extra_category_id_seq RESTART WITH 1;

INSERT INTO store.extra_category (name) VALUES 
('Frosting'),
('Topping'),
('Filling'),
('Flavor'),
('Type'),
('Size');

ALTER SEQUENCE store.extra_extra_id_seq RESTART WITH 1;

INSERT INTO store.extra (name, price, extra_category_id) VALUES 
('None', NULL, 1),
('Chocolate', NULL, 1),
('Maple', NULL, 1),
('Caramel', NULL, 1),
('Vanilla', NULL, 1),
('Strawberry', NULL, 1),
('Cherry', NULL, 1),
('Cream Cheese', NULL, 1),
('Peanut Butter', 0.10, 1),
('Peanut Butter (w/ Chocolate Drizzle)', 0.10, 1),

('None', NULL, 2),
('Peanuts', NULL, 2),
('Sprinkles', NULL, 2),

('Bavarian Cream', NULL, 3),
('Berry', NULL, 3),
('Lemon', NULL, 3),
('Marshmallow', NULL, 3),
('Bavarian Cream', 0.10, 3),
('Berry', 0.10, 3),
('Lemon', 0.10, 3),
('Marshmallow', 0.10, 3),
('Apple', 0.10, 3),
('Strawberry Cream Cheese', 0.10, 3),

('Cheddar', NULL, 4),
('Jalapeno', NULL, 4),


('Sausage, Egg, and Cheese', NULL, 5),
('Bacon, Egg, and Cheese', NULL, 5),

('Single', NULL, 6),
('Double', 0.50, 6);

ALTER SEQUENCE store.extra_group_extra_group_id_seq RESTART WITH 1;

INSERT INTO store.extra_group (extra_category_id, name) VALUES 
(1, 'Generic Frostings'), 
(1, 'Blueberry Frostings'), 
(2, 'Generic Toppings'), 
(3, 'Bearclaw Fillings'), 
(3, 'Bismark Fillings'), 
(3, 'Longjohn Fillings'), 
(4, 'Kolache Flavors'), 
(5, 'Sandwich Types'), 
(6, 'Biscuits and Gravy Sizes');

INSERT INTO store.extra_group_extra (extra_group_id, extra_id, display_order) VALUES 
(1, 2, NULL), 
(1, 3, NULL), 
(1, 4, NULL), 
(1, 5, NULL), 
(1, 6, NULL), 
(1, 7, NULL), 
(1, 9, NULL), 
(1, 10, NULL), 

(2, 8, NULL), 

(3, 11, NULL), 
(3, 12, NULL), 
(3, 13, NULL), 

(4, 22, NULL), 
(4, 23, NULL), 

(5, 14, NULL), 
(5, 15, NULL), 
(5, 16, NULL), 
(5, 17, NULL), 

(6, 18, NULL), 
(6, 19, NULL), 
(6, 20, NULL), 
(6, 21, NULL), 

(7, 24, NULL), 
(7, 25, NULL), 

(8, 26, NULL), 
(8, 27, NULL), 

(9, 28, NULL), 
(9, 29, NULL);

INSERT INTO store.item_extra_group (menu_item_id, extra_group_id) VALUES 
(1, 1), 
(3, 1), 
(4, 1), 
(5, 1), 
(10, 1), 
(11, 1), 
(13, 1), 
(14, 1), 

(2, 2), 

(1, 3), 
(3, 3), 
(4, 3), 
(5, 3), 
(7, 3), 
(10, 3), 
(11, 3), 
(13, 3), 
(14, 3), 

(6, 4), 

(7, 5), 

(13, 6),

(20, 7),

(17, 8), 
(18, 8), 

(19, 9);

INSERT INTO store.weekday(weekday_id, weekday) VALUES 
(1, 'Sunday'),
(2, 'Monday'),
(3, 'Tuesday'),
(4, 'Wednesday'),
(5, 'Thursday'),
(6, 'Friday'),
(7, 'Saturday');

INSERT INTO store.weekday_availability(menu_item_id, weekday_id) VALUES
(21, 2);

ALTER SEQUENCE store.location_location_id_seq RESTART WITH 1;

INSERT INTO store.location(city, state, zip, address, common_name, phone_number)
VALUES('Hutchinson', 'Kansas', '67502', '1435 East 30th Ave.', '30th Street Daylight Donuts', '(620) 500-5550'),
('Hutchinson', 'Kansas', '67501', '305 N Main St.', 'Main Street Daylight Donuts', '(620) 259-2488');

ALTER SEQUENCE store.payment_processor_payment_processor_id_seq RESTART WITH 1;

INSERT INTO store.payment_processor(payment_processor)
VALUES('Stripe'), ('PayPal');

ALTER SEQUENCE store.pickup_time_pickup_time_id_seq RESTART WITH 1;

INSERT INTO store.pickup_time(pickup_time)
VALUES('5:00 AM'), ('5:30 AM'), 
('6:00 AM'), ('6:30 AM'),
('7:00 AM'), ('7:30 AM'),
('8:00 AM'), ('8:30 AM'),
('9:00 AM'), ('9:30 AM'),
('10:00 AM'), ('10:30 AM'),
('11:00 AM'), ('11:30 AM'),
('12:00 PM');

INSERT INTO store.location_pickup_time(location_id, pickup_time_id)
VALUES (1, 1), (2, 1), (1, 2), (2, 2), (1, 3), (2, 3), (1, 4), (2, 4), (1, 5), (2, 5), (1, 6), (2, 6), (1, 7), (2, 7), (1, 8), (2, 8), 
(1, 9), (2, 9), (2, 10), (2, 11), (2, 12), (2, 13), (2, 14), (2, 15), 
(1, 10), (1, 11), (1, 12), (1, 13), (1, 14), (1, 15);

INSERT INTO store.tax(tax_amount)
VALUES(.08);

INSERT INTO store.location_closed_weekday(location_id, weekday_id)
VALUES (2, 1), (2, 2);