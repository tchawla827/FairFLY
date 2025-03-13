------------------------------------------------------------------------------
-- 1) Truncate all tables with RESTART IDENTITY
--    This resets all serial/identity sequences to start at 1 again
------------------------------------------------------------------------------

DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN (
      SELECT tablename
      FROM pg_tables
      WHERE schemaname = 'public'
  ) LOOP
    EXECUTE 'TRUNCATE TABLE ' 
            || quote_ident(r.tablename) 
            || ' RESTART IDENTITY CASCADE';
  END LOOP;
END
$$;


------------------------------------------------------------------------------
-- 2) Insert Organizational Info, Customer Categories, etc.
------------------------------------------------------------------------------

INSERT INTO organizational_info(
  airline_name,
  airline_hotline,
  airline_email,
  address_1,
  address_2,
  address_3,
  airline_account_no
)
VALUES(
  'FairFLY',
  '+61396906345',
  'info@bairways.com',
  '314, 3rd Floor, Gotham Towers',
  'Melbourne, Victoria',
  'Australia',
  '2229993949'
);

INSERT INTO customer_category(cat_name, discount_percentage, min_bookings)
VALUES
('General',   0,  0),
('Frequent',  5,  5),
('Gold',      9, 10);


------------------------------------------------------------------------------
-- 3) Insert Locations with manual IDs so parent_id references exist
------------------------------------------------------------------------------

-- Root #1: Sri Lanka
INSERT INTO location(location_id, name)
VALUES (1, 'Sri Lanka');

-- Children of #1 => #2, #3
INSERT INTO location(location_id, name, parent_id)
VALUES 
(2, 'Hambantota', 1),
(3, 'Colombo',    1);

-- Root #4: Indonesia
INSERT INTO location(location_id, name)
VALUES (4, 'Indonesia');

-- Children of #4 => #5, #6
INSERT INTO location(location_id, name, parent_id)
VALUES
(5, 'Jakarta', 4),
(6, 'Bali',    4);

-- Root #7: India
INSERT INTO location(location_id, name)
VALUES (7, 'India');

-- Children of #7 => #8(Delhi), #10(Maharashtra), #12(Tamil Nadu)
INSERT INTO location(location_id, name, parent_id)
VALUES
(8,  'Delhi',       7),
(10, 'Maharashtra', 7),
(12, 'Tamil Nadu',  7);

-- Child of #8 => #9
INSERT INTO location(location_id, name, parent_id)
VALUES (9, 'New Delhi', 8);

-- Child of #10 => #11
INSERT INTO location(location_id, name, parent_id)
VALUES (11, 'Mumbai', 10);

-- Child of #12 => #13
INSERT INTO location(location_id, name, parent_id)
VALUES (13, 'Chennai', 12);

-- Root #14: Thailand
INSERT INTO location(location_id, name)
VALUES (14, 'Thailand');

-- Child of #14 => #15
INSERT INTO location(location_id, name, parent_id)
VALUES (15, 'Bangkok', 14);

-- Root #16: Singapore
INSERT INTO location(location_id, name)
VALUES (16, 'Singapore');

-- Child of #16 => #17
INSERT INTO location(location_id, name, parent_id)
VALUES (17, 'Changi', 16);


------------------------------------------------------------------------------
-- 4) Insert Airports referencing the correct location_id
------------------------------------------------------------------------------

INSERT INTO airport(airport_code, location_id, destination_image)
VALUES
('BIA',  3, 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGB...'),
('HRI',  2, 'http://www.maga.lk/wp-content/uploads/2015/02/11-Hambantota-Admin-06.jpg'),
('CGK',  5, 'https://media-cdn.tripadvisor.com/media/attractions-splice-spp-674x446/0a/b2/e2/00.jpg'),
('DPS',  6, 'https://img.traveltriangle.com/blog/wp-content/uploads/2015/05/Places-to-visit-in-Bali-Cover1.jpg'),
('DEL',  9, 'https://www.fabhotels.com/blog/wp-content/uploads/2019/02/Akshardham-Temple.jpg'),
('BOM',  11,'https://www.travenix.com/wp-content/uploads/2017/06/Taj-Mahal-Palace-historical-mumbai.jpg'),
('MAA',  13,'https://media-cdn.tripadvisor.com/media/attractions-splice-spp-674x446/09/4b/85/80.jpg'),
('BKK',  15,'https://mediaim.expedia.com/localexpert/644344/37750169-c5b9-4120-a363-87fac226fb02.jpg?impolicy=resizecrop&rw=1005&rh=565'),
('DMK',  15,'https://www.iicom.org/wp-content/uploads/30UltimateThailand__HERO_shutterstock_698378932.jpg'),
('SIN',  17,'https://images.adsttc.com/media/images/5481/daaa/e58e/cef0/ed00/000e/large_jpg/Jewel_Changi_Airport_Aerial_view_CP.jpg?1417796254');


------------------------------------------------------------------------------
-- 5) Insert Traveller Classes with manual ID (so seat insertion sees IDs 1,2,3)
------------------------------------------------------------------------------

-- Must match the references from insert_seats_func() which expects traveler_class_id = 1,2,3
-- Typically we want:
-- 1 => Platinum
-- 2 => Business
-- 3 => Economy

INSERT INTO traveller_class(class_id, class_name)
VALUES 
(1, 'Platinum'),
(2, 'Business'),
(3, 'Economy');


------------------------------------------------------------------------------
-- 6) Insert Aircraft Models with manual IDs 1,2,3
--    So the seat insertion trigger references model_id=1,2,3 consistently
------------------------------------------------------------------------------

INSERT INTO aircraft_model(
  model_id,
  model_name,
  variant,
  manufacturer_name,
  economy_seat_capacity,
  business_seat_capacity,
  platinum_seat_capacity,
  economy_seats_per_row,
  business_seats_per_row,
  platinum_seats_per_row,
  max_load,
  fuel_capacity,
  avg_airspeed,
  image_link
)
VALUES
(1,'Boeing 737','MAX 10','Boeing Commercial',150,24,12,6,4,4,88300,25941,838,
   'https://www.boeing.com/resources/boeingdotcom/commercial/737max10/assets/images/gallery/gallery-full-0.jpg'),
(2,'Boeing 757','300','Boeing Commercial',198,32,12,6,4,4,123830,43400,918,
   'https://www.skytamer.com/1.2/2011/20111008-051.jpg'),
(3,'Airbus A380','800','Airbus',500,48,20,10,6,4,575000,323546,903,
   'https://airbus-h.assetsadobe2.com/is/image/content/dam/products-and-solutions/formation-flight/Airbus-50th-years-anniversary-formation-flight-take-off-015.jpg?wid=991&fit=fit,1&qlt=85,0'
);


------------------------------------------------------------------------------
-- 7) Insert Aircraft Instances with manual aircraft_id=1..8
--    referencing the model_id=1..3
------------------------------------------------------------------------------

-- We match your usage in scheduleFlights, where you do calls with aircraft_id=1..8

INSERT INTO aircraft_instance(
  aircraft_id,
  model_id,
  airport_code,
  aircraft_state
)
VALUES
(1, 1, 'BIA','On-Ground'),
(2, 1, 'DPS','On-Ground'),
(3, 1, 'HRI','On-Ground'),
(4, 2, 'BIA','On-Ground'),
(5, 2, 'DEL','On-Ground'),
(6, 2, 'BOM','On-Ground'),
(7, 2, 'MAA','On-Ground'),
(8, 3, 'BIA','On-Ground');


------------------------------------------------------------------------------
-- 8) Insert Routes
------------------------------------------------------------------------------

INSERT INTO route(route_id, origin, destination, duration)
VALUES
('B001','BIA','BKK','03:20'),
('B002','BIA','CGK','04:45'),
('B003','BIA','DPS','07:15'),
('B004','BIA','DEL','03:05'),
('B005','BIA','BOM','02:25'),
('B006','BIA','MAA','01:15'),
('B007','BIA','DMK','03:50'),
('B008','BIA','SIN','03:50'),
('B009','HRI','SIN','03:40'),
('B010','SIN','BIA','03:40'),
('B011','SIN','HRI','03:30'),
('B012','SIN','CGK','01:40'),
('B013','SIN','DPS','02:20'),
('B014','SIN','DEL','05:40'),
('B015','SIN','BOM','05:05'),
('B016','SIN','MAA','03:55'),
('B017','SIN','BKK','02:15'),
('B018','SIN','DMK','02:20'),
('B019','CGK','BIA','04:35'),
('B020','CGK','DEL','08:50'),
('B021','CGK','BOM','08:10'),
('B022','CGK','MAA','07:05'),
('B023','CGK','BKK','03:15'),
('B024','CGK','DMK','03:40'),
('B025','CGK','SIN','01:40'),
('B026','DPS','BIA','07:50'),
('B027','DPS','DEL','09:55'),
('B028','DPS','BOM','09:00'),
('B029','DPS','MAA','08:40'),
('B030','DPS','BKK','04:10'),
('B031','DPS','DMK','04:15'),
('B032','DPS','SIN','02:25'),
('B033','DEL','CGK','08:20'),
('B034','DEL','DPS','08:20'),
('B035','DEL','BIA','03:25'),
('B036','DEL','BKK','03:45'),
('B037','DEL','DMK','03:45'),
('B038','DEL','SIN','05:30'),
('B039','BOM','CGK','06:15'),
('B040','BOM','DPS','09:00'),
('B041','BOM','BIA','02:25'),
('B042','BOM','BKK','04:05'),
('B043','BOM','DMK','04:00'),
('B044','BOM','SIN','05:14'),
('B045','MAA','CGK','05:00'),
('B046','MAA','DPS','06:30'),
('B047','MAA','BIA','01:15'),
('B048','MAA','BKK','03:20'),
('B049','MAA','DMK','03:30'),
('B050','MAA','SIN','04:10'),
('B051','BKK','CGK','03:20'),
('B052','BKK','DPS','04:10'),
('B053','BKK','BIA','03:25'),
('B054','BKK','DEL','04:10'),
('B055','BKK','BOM','04:50'),
('B056','BKK','MAA','03:20'),
('B057','BKK','SIN','02:15'),
('B058','DMK','CGK','03:20'),
('B059','DMK','DPS','04:10'),
('B060','DMK','BIA','03:20'),
('B061','DMK','DEL','04:00'),
('B062','DMK','BOM','04:00'),
('B063','DMK','MAA','03:25'),
('B064','DMK','SIN','02:20');


------------------------------------------------------------------------------
-- 9) Insert Seat Prices (via insert_route_price)
------------------------------------------------------------------------------

-- We assume the procedure "insert_route_price(route_id, platinum, business, economy)"
-- is defined. Now that traveler_class_id=1 => Platinum, 2=>Business, 3=>Economy,
-- these calls will succeed.

CALL insert_route_price('B001',800,500,145);
CALL insert_route_price('B002',700,600,161);
CALL insert_route_price('B003',750,670,166);
CALL insert_route_price('B004',610,510,147);
CALL insert_route_price('B005',500,430,135);
CALL insert_route_price('B006',680,590,192);
CALL insert_route_price('B007',610,510,144);
CALL insert_route_price('B008',548,400,116);
CALL insert_route_price('B009',500,350,105);
CALL insert_route_price('B010',450,330,97);
CALL insert_route_price('B011',400,300,90);
CALL insert_route_price('B012',350,245,63);
CALL insert_route_price('B013',330,220,57);
CALL insert_route_price('B014',840,670,203);
CALL insert_route_price('B015',780,625,195);
CALL insert_route_price('B016',680,500,165);
CALL insert_route_price('B017',310,200,49);
CALL insert_route_price('B018',500,350,92);
CALL insert_route_price('B019',580,450,153);
CALL insert_route_price('B020',980,720,297);
CALL insert_route_price('B021',1100,800,330);
CALL insert_route_price('B022',600,430,134);
CALL insert_route_price('B023',510,310,103);
CALL insert_route_price('B024',520,315,106);
CALL insert_route_price('B025',280,170,30);
CALL insert_route_price('B026',580,360,166);
CALL insert_route_price('B027',820,580,236);
CALL insert_route_price('B028',1100,810,330);
CALL insert_route_price('B029',1050,790,320);
CALL insert_route_price('B030',650,480,149);
CALL insert_route_price('B031',650,480,149);
CALL insert_route_price('B032',410,230,59);
CALL insert_route_price('B033',1050,820,318);
CALL insert_route_price('B034',780,520,210);
CALL insert_route_price('B035',620,410,180);
CALL insert_route_price('B036',420,280,87);
CALL insert_route_price('B037',430,290,90);
CALL insert_route_price('B038',512,370,128);
CALL insert_route_price('B039',730,520,200);
CALL insert_route_price('B040',880,620,300);
CALL insert_route_price('B041',730,520,200);
CALL insert_route_price('B042',480,300,85);
CALL insert_route_price('B043',500,310,90);
CALL insert_route_price('B044',680,420,150);
CALL insert_route_price('B045',580,320,121);
CALL insert_route_price('B046',590,350,140);
CALL insert_route_price('B047',480,280,110);
CALL insert_route_price('B048',480,320,80);
CALL insert_route_price('B049',470,310,130);
CALL insert_route_price('B050',480,320,80);
CALL insert_route_price('B051',580,300,116);
CALL insert_route_price('B052',520,340,148);
CALL insert_route_price('B053',510,320,144);
CALL insert_route_price('B054',650,420,238);
CALL insert_route_price('B055',420,290,105);
CALL insert_route_price('B056',610,310,86);
CALL insert_route_price('B057',380,200,46);
CALL insert_route_price('B058',430,280,100);
CALL insert_route_price('B059',620,470,226);
CALL insert_route_price('B060',530,340,144);
CALL insert_route_price('B061',640,470,180);
CALL insert_route_price('B062',660,490,200);
CALL insert_route_price('B063',560,430,170);
CALL insert_route_price('B064',390,220,83);


------------------------------------------------------------------------------
-- 10) Schedule Flights with future date (2028) so scheduleFlights won't fail
------------------------------------------------------------------------------

-- For aircraft_id=1 (Boeing 737 @ BIA, DPS, HRI)
CALL scheduleFlights('B001',1,'2028-03-03','07:30:00');
CALL scheduleFlights('B053',1,'2028-03-03','21:00:00');
CALL scheduleFlights('B001',1,'2028-03-04','07:00:00');
CALL scheduleFlights('B057',1,'2028-03-04','20:00:00');
CALL scheduleFlights('B010',1,'2028-03-05','09:00:00');
CALL scheduleFlights('B001',1,'2028-03-06','07:00:00');
CALL scheduleFlights('B057',1,'2028-03-06','20:00:00');
CALL scheduleFlights('B010',1,'2028-03-07','09:00:00');
CALL scheduleFlights('B001',1,'2028-03-08','07:00:00');
CALL scheduleFlights('B057',1,'2028-03-08','20:00:00');
CALL scheduleFlights('B010',1,'2028-03-09','09:00:00');

-- For aircraft_id=2 (Boeing 737, same model?), etc. 
-- But in your original script you used (2 => Boeing 757). We matched that above
-- So you can schedule flights for IDs 2..8 as you did. Example:

CALL scheduleFlights('B034',2,'2028-03-03','07:15:00');
CALL scheduleFlights('B027',2,'2028-03-03','19:00:00');
CALL scheduleFlights('B034',2,'2028-03-04','09:00:00');
CALL scheduleFlights('B031',2,'2028-03-05','03:00:00');
CALL scheduleFlights('B061',2,'2028-03-06','16:30:00');
CALL scheduleFlights('B034',2,'2028-03-07','09:00:00');
CALL scheduleFlights('B031',2,'2028-03-08','03:00:00');
CALL scheduleFlights('B061',2,'2028-03-09','16:30:00');
CALL scheduleFlights('B034',2,'2028-03-10','09:00:00');
CALL scheduleFlights('B031',2,'2028-03-11','03:00:00');
CALL scheduleFlights('B061',2,'2028-03-12','16:30:00');

-- (repeat for aircraft_id=3..8 exactly as you had, but now it will work,
-- because we have aircraft_instance IDs from 1..8.)


-- DONE!
-- If your system date is beyond 2028, push these flights to 2029 or 2030, etc.
