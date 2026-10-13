CREATE SCHEMA `hp_pet_care` ;

CREATE TABLE `hp_pet_care`.`customer` (
  `customer_id`   INT          NOT NULL,
  `email`         VARCHAR(100) NULL,
  `address`       VARCHAR(255) NULL,
  PRIMARY KEY (`customer_id`),
  `customer_name` VARCHAR(100) NOT NULL,
  `phone_number`  VARCHAR(20)  NOT NULL,
  UNIQUE INDEX `phone_number_UNIQUE` (`phone_number` ASC) VISIBLE,
  UNIQUE INDEX `email_UNIQUE`        (`email` ASC)        VISIBLE);

CREATE TABLE `hp_pet_care`.`species` (
  `species_id`   INT         NOT NULL,
  `species_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`species_id`),
  UNIQUE INDEX `species_name_UNIQUE` (`species_name` ASC) VISIBLE);

CREATE TABLE `hp_pet_care`.`breed` (
  `breed_id`   INT          NOT NULL,
  `breed_name` VARCHAR(100) NOT NULL,
  `species_id` INT          NOT NULL,
  PRIMARY KEY (`breed_id`),
  UNIQUE INDEX `breed_name_UNIQUE`    (`breed_name` ASC) VISIBLE,
  INDEX        `fk_breed_species_idx` (`species_id` ASC) VISIBLE,
  CONSTRAINT `fk_breed_species` FOREIGN KEY (`species_id`) REFERENCES `hp_pet_care`.`species` (`species_id`) ON DELETE RESTRICT ON UPDATE CASCADE);

CREATE TABLE `hp_pet_care`.`pet` (
  `pet_id`        INT          NOT NULL,
  `customer_id`   INT          NOT NULL,
  `pet_name`      VARCHAR(100) NOT NULL,
  `weight`        DECIMAL(5,2) NULL,
  `neutered`      INT   NULL,
  `breed_id`      INT          NOT NULL,
  `gender`        VARCHAR(10)  NULL,
  `date_of_birth` DATE         NULL,
  PRIMARY KEY (`pet_id`),
  CHECK (`gender` IN ('M', 'F', 'Unknown')),
  CHECK (`weight` > 0),
  INDEX `fk_pet_customer_idx` (`customer_id` ASC) VISIBLE,
  INDEX `fk_pet_breed_idx`    (`breed_id`    ASC) VISIBLE,
  CONSTRAINT `fk_pet_customer` FOREIGN KEY (`customer_id`) REFERENCES `hp_pet_care`.`customer` (`customer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_pet_breed`    FOREIGN KEY (`breed_id`)    REFERENCES `hp_pet_care`.`breed`    (`breed_id`)    ON DELETE RESTRICT ON UPDATE CASCADE);

CREATE TABLE `hp_pet_care`.`staff` (
  `staff_id`      INT          NOT NULL,
  `staff_name`    VARCHAR(100) NOT NULL,
  `role`          VARCHAR(45)  NOT NULL,
  `phone_number`  VARCHAR(20)  NOT NULL,
  `email`         VARCHAR(100) NULL,
  `certification` VARCHAR(100) NULL,
  PRIMARY KEY (`staff_id`),
  CHECK (`role` IN ('admin', 'groomer', 'vet', 'receptionist', 'janitor')),
  UNIQUE INDEX `staff_phone_UNIQUE` (`phone_number` ASC) VISIBLE,
  UNIQUE INDEX `staff_email_UNIQUE` (`email`        ASC) VISIBLE);

CREATE TABLE `hp_pet_care`.`service` (
  `service_id`       INT           NOT NULL,
  `service_name`     VARCHAR(100)  NOT NULL,
  `service_type`     VARCHAR(45)   NOT NULL,
  `description`      TEXT          NULL,
  `price`            DECIMAL(10,2) NOT NULL,
  `availability`     VARCHAR(100)  NULL,
  `duration_minutes` INT           NOT NULL,
  PRIMARY KEY (`service_id`),
  CHECK (`price` >= 0),
  CHECK (`duration_minutes` > 0),
  CHECK (`service_type` IN ('grooming', 'vaccination', 'wellness')),
  UNIQUE INDEX `service_name_UNIQUE` (`service_name` ASC) VISIBLE);

CREATE TABLE `hp_pet_care`.`appointment` (
  `appointment_id`       INT         NOT NULL,
  `pet_id`               INT         NOT NULL,
  `staff_id`             INT         NULL,
  `service_id`           INT         NOT NULL,
  `appointment_datetime` DATETIME    NOT NULL,
  `status`               VARCHAR(20) NOT NULL DEFAULT 'scheduled',
  PRIMARY KEY (`appointment_id`),
  CHECK (`status` IN ('scheduled', 'completed', 'cancelled', 'no-show')),
  UNIQUE INDEX `no_double_booking_UNIQUE` (`staff_id` ASC, `appointment_datetime` ASC) VISIBLE,
  INDEX `fk_appointment_pet_idx`     (`pet_id`     ASC) VISIBLE,
  INDEX `fk_appointment_service_idx` (`service_id` ASC) VISIBLE,
  CONSTRAINT `fk_appointment_pet`     FOREIGN KEY (`pet_id`)     REFERENCES `hp_pet_care`.`pet`     (`pet_id`)     ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_appointment_staff`   FOREIGN KEY (`staff_id`)   REFERENCES `hp_pet_care`.`staff`   (`staff_id`)   ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_appointment_service` FOREIGN KEY (`service_id`) REFERENCES `hp_pet_care`.`service` (`service_id`) ON DELETE RESTRICT ON UPDATE CASCADE);

CREATE TABLE `hp_pet_care`.`medical_record` (
  `record_id`      INT         NOT NULL,
  `pet_id`         INT         NOT NULL,
  `appointment_id` INT         NULL,
  `record_date`    DATE        NOT NULL,
  `record_type`    VARCHAR(20) NOT NULL,
  `description`    TEXT        NULL,
  `next_due_date`  DATE        NULL,
  PRIMARY KEY (`record_id`),
  CHECK (`record_type` IN ('checkup', 'vaccination', 'treatment')),
  INDEX `fk_medrecord_pet_idx`         (`pet_id`         ASC) VISIBLE,
  INDEX `fk_medrecord_appointment_idx` (`appointment_id` ASC) VISIBLE,
  CONSTRAINT `fk_medrecord_pet`         FOREIGN KEY (`pet_id`)         REFERENCES `hp_pet_care`.`pet`         (`pet_id`)         ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_medrecord_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `hp_pet_care`.`appointment` (`appointment_id`) ON DELETE SET NULL ON UPDATE CASCADE);

CREATE TABLE `hp_pet_care`.`room_type` (
  `room_type_id`   INT           NOT NULL,
  `room_type_name` VARCHAR(45)   NOT NULL,
  `nightly_rate`   DECIMAL(10,2) NOT NULL,
  `description`    VARCHAR(255)  NULL,
  PRIMARY KEY (`room_type_id`),
  CHECK (`nightly_rate` >= 0),
  UNIQUE INDEX `room_type_name_UNIQUE` (`room_type_name` ASC) VISIBLE);

CREATE TABLE `hp_pet_care`.`pet_hotel_booking` (
  `booking_id`     INT           NOT NULL,
  `pet_id`         INT           NOT NULL,
  `staff_id`       INT           NULL,
  `room_type_id`   INT           NOT NULL,
  `check_in_date`  DATE          NOT NULL,
  `check_out_date` DATE          NOT NULL,
  `booking_status` VARCHAR(20)   NOT NULL DEFAULT 'booked',
  PRIMARY KEY (`booking_id`),
  CHECK (`check_out_date` > `check_in_date`),
  CHECK (`booking_status` IN ('booked', 'checked-in', 'completed', 'cancelled')),
  INDEX `fk_hotelbooking_pet_idx`      (`pet_id`       ASC) VISIBLE,
  INDEX `fk_hotelbooking_staff_idx`    (`staff_id`     ASC) VISIBLE,
  INDEX `fk_hotelbooking_roomtype_idx` (`room_type_id` ASC) VISIBLE,
  CONSTRAINT `fk_hotelbooking_pet`      FOREIGN KEY (`pet_id`)       REFERENCES `hp_pet_care`.`pet`       (`pet_id`)       ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_hotelbooking_staff`    FOREIGN KEY (`staff_id`)     REFERENCES `hp_pet_care`.`staff`     (`staff_id`)     ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_hotelbooking_roomtype` FOREIGN KEY (`room_type_id`) REFERENCES `hp_pet_care`.`room_type` (`room_type_id`) ON DELETE RESTRICT ON UPDATE CASCADE);

CREATE TABLE `hp_pet_care`.`product` (
  `product_id`     INT           NOT NULL,
  `product_name`   VARCHAR(100)  NOT NULL,
  `category`       VARCHAR(45)   NOT NULL,
  `price`          DECIMAL(10,2) NOT NULL,
  `stock_quantity` INT           NOT NULL DEFAULT 0,
  PRIMARY KEY (`product_id`),
  CHECK (`price` >= 0),
  CHECK (`stock_quantity` >= 0),
  UNIQUE INDEX `product_name_UNIQUE` (`product_name` ASC) VISIBLE);

CREATE TABLE `hp_pet_care`.`sale` (
  `sale_id`      INT           NOT NULL,
  `customer_id`  INT           NULL,
  `sale_date`    DATE          NOT NULL,
  `total_amount` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`sale_id`),
  CHECK (`total_amount` >= 0),
  INDEX `fk_sale_customer_idx` (`customer_id` ASC) VISIBLE,
  CONSTRAINT `fk_sale_customer` FOREIGN KEY (`customer_id`) REFERENCES `hp_pet_care`.`customer` (`customer_id`) ON DELETE SET NULL ON UPDATE CASCADE);

CREATE TABLE `hp_pet_care`.`sale_item` (
  `sale_id`    INT           NOT NULL,
  `product_id` INT           NOT NULL,
  `quantity`   INT           NOT NULL,
  `unit_price` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`sale_id`, `product_id`),
  CHECK (`quantity`   > 0),
  CHECK (`unit_price` >= 0),
  INDEX `fk_saleitem_product_idx` (`product_id` ASC) VISIBLE,
  CONSTRAINT `fk_saleitem_sale`    FOREIGN KEY (`sale_id`)    REFERENCES `hp_pet_care`.`sale`    (`sale_id`)    ON DELETE CASCADE  ON UPDATE CASCADE,
  CONSTRAINT `fk_saleitem_product` FOREIGN KEY (`product_id`) REFERENCES `hp_pet_care`.`product` (`product_id`) ON DELETE RESTRICT ON UPDATE CASCADE);

CREATE TABLE `hp_pet_care`.`payment` (
  `payment_id`     INT           NOT NULL,
  `appointment_id` INT           NULL,
  `booking_id`     INT           NULL,
  `sale_id`        INT           NULL,
  `payment_date`   DATE          NOT NULL,
  `amount`         DECIMAL(10,2) NOT NULL,
  `payment_method` VARCHAR(45)   NOT NULL,
  PRIMARY KEY (`payment_id`),
  CHECK ((`appointment_id` IS NOT NULL) + (`booking_id` IS NOT NULL) + (`sale_id` IS NOT NULL) = 1),
  CHECK (`amount` >= 0),
  CHECK (`payment_method` IN ('cash', 'card', 'online', 'bank_transfer')),
  INDEX `fk_payment_appointment_idx` (`appointment_id` ASC) VISIBLE,
  INDEX `fk_payment_booking_idx`     (`booking_id`     ASC) VISIBLE,
  INDEX `fk_payment_sale_idx`        (`sale_id`        ASC) VISIBLE,
  CONSTRAINT `fk_payment_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `hp_pet_care`.`appointment`       (`appointment_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_payment_booking`     FOREIGN KEY (`booking_id`)     REFERENCES `hp_pet_care`.`pet_hotel_booking` (`booking_id`)     ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_payment_sale`        FOREIGN KEY (`sale_id`)        REFERENCES `hp_pet_care`.`sale`              (`sale_id`)        ON DELETE RESTRICT ON UPDATE RESTRICT);
-- SPECIES  (6 rows) 

INSERT INTO `hp_pet_care`.`species` (species_id, species_name) VALUES
(1, 'Dog'),
(2, 'Cat'),
(3, 'Rabbit'),
(4, 'Bird'),
(5, 'Hamster'),
(6, 'Guinea Pig');

-- BREED  (24 rows) 

INSERT INTO `hp_pet_care`.`breed` (breed_id, breed_name, species_id) VALUES
(1,  'Golden Retriever',    1),
(2,  'Labrador Retriever',  1),
(3,  'Siberian Husky',      1),
(4,  'German Shepherd',     1),
(5,  'Beagle',              1),
(6,  'Shih Tzu',            1),
(7,  'Poodle',              1),
(8,  'Corgi',               1),
(9,  'Persian',             2),
(10, 'Scottish Fold',       2),
(11, 'Maine Coon',          2),
(12, 'Siamese',             2),
(13, 'Ragdoll',             2),
(14, 'British Shorthair',   2),
(15, 'Holland Lop',         3),
(16, 'Lionhead',            3),
(17, 'Mini Rex',            3),
(18, 'Cockatiel',           4),
(19, 'Budgerigar',          4),
(20, 'Lovebird',            4),
(21, 'Syrian Hamster',      5),
(22, 'Dwarf Hamster',       5),
(23, 'American Guinea Pig', 6),
(24, 'Peruvian Guinea Pig', 6);
 
-- CUSTOMER (35 rows)

INSERT INTO `hp_pet_care`.`customer` (customer_id, customer_name, phone_number, email, address) VALUES
(1,  'Ahmad Bin Razali',         '012-3456789', 'ahmad.razali@gmail.com',      '12, Jalan Bahagia, Petaling Jaya, Selangor'),
(2,  'Siti Norzahra',            '013-2345678', 'siti.norzahra@yahoo.com',     '45, Lorong Damai 3, Shah Alam, Selangor'),
(3,  'Tan Wei Liang',            '016-5678901', 'weiliang.tan@gmail.com',      '8, Jalan Utama, Subang Jaya, Selangor'),
(4,  'Priya Subramaniam',        '017-3456789', 'priya.sub@hotmail.com',       '22, Jalan Harmoni, Klang, Selangor'),
(5,  'Muhammad Hafiz',           '011-7654321', 'hafiz.my@gmail.com',          '3, Taman Maju, Puchong, Selangor'),
(6,  'Lim Mei Ling',             '019-8765432', 'meiling.lim@gmail.com',       '67, Jalan Kenanga, Cheras, Kuala Lumpur'),
(7,  'Nurul Ain Binti Hassan',   '014-5678902', 'nurul.ain@yahoo.com',         '15, Taman Sejahtera, Ampang, Selangor'),
(8,  'Kevin Raj',                '012-9876543', 'kevin.raj@gmail.com',         '9, Jalan Putra, Batu Caves, Selangor'),
(9,  'Zainab Binti Yusof',       '016-3456780', 'zainab.yusof@gmail.com',      '34, Lorong Permai, Kajang, Selangor'),
(10, 'Chan Siaw Kok',            '018-2345679', 'chankok.siaw@gmail.com',      '21, Jalan Wawasan, Rawang, Selangor'),
(11, 'Faizal Bin Noor',          '011-2233445', 'faizal.noor@gmail.com',       '5, Jalan Ceria, Nilai, Negeri Sembilan'),
(12, 'Yap Shu Fen',              '013-9988776', 'shufen.yap@hotmail.com',      '33, Taman Desa, Kuala Lumpur'),
(13, 'Rohani Binti Ismail',      '017-6655443', 'rohani.ismail@yahoo.com',     '7, Lorong Bunga Raya, Sepang, Selangor'),
(14, 'S. Dhanraj',               '016-1122334', 'dhanraj.s@gmail.com',         '18, Jalan Selatan, Klang, Selangor'),
(15, 'Ng Bee Ling',              '012-4455667', 'beeling.ng@gmail.com',        '29, Taman Megah, Petaling Jaya, Selangor'),
(16, 'Azlinda Binti Kamal',      '019-3344556', 'azlinda.kamal@gmail.com',     '11, Jalan Tenang, Bangi, Selangor'),
(17, 'Chong Kok Wai',            '013-5566778', 'kokwai.chong@gmail.com',      '6, Lorong Pelangi, Shah Alam, Selangor'),
(18, 'Nabilah Binti Osman',      '017-7788990', 'nabilah.osman@yahoo.com',     '40, Jalan Impian, Kajang, Selangor'),
(19, 'Balakrishnan A/L Nair',    '011-8899001', 'bala.nair@gmail.com',         '55, Taman Sri Muda, Shah Alam, Selangor'),
(20, 'Jesmine Wong',             '016-9900112', 'jesmine.wong@gmail.com',      '3, Jalan Damai Indah, Ampang, Selangor'),
(21, 'Hanisah Binti Daud',       '014-1122334', 'hanisah.daud@gmail.com',      '88, Taman Bukit Indah, Puchong, Selangor'),
(22, 'Loh Chee Keong',           '012-2233446', 'cheekeong.loh@gmail.com',     '14, Jalan Seri Alam, Subang Jaya, Selangor'),
(23, 'Farizan Bin Wahid',        '013-4455668', 'farizan.wahid@yahoo.com',     '27, Lorong Hijau, Rawang, Selangor'),
(24, 'Kaviya Nair',              '017-5566779', 'kaviya.nair@gmail.com',       '31, Taman Pinggiran, Klang, Selangor'),
(25, 'Michelle Tan',             '019-6677880', 'michelle.tan@gmail.com',      '2, Jalan Puteri, Putrajaya'),
(26, 'Norhaslinda Binti Ramli',  '011-7788991', 'haslin.ramli@gmail.com',      '76, Jalan Sri Wangi, Seremban, Negeri Sembilan'),
(27, 'Ong Boon Seng',            '016-8899002', 'boonseng.ong@gmail.com',      '49, Jalan Cahaya, Cheras, Kuala Lumpur'),
(28, 'Suresh A/L Pillai',        '014-9900113', 'suresh.pillai@hotmail.com',   '10, Lorong Melati, Kajang, Selangor'),
(29, 'Aishah Binti Samsudin',    '012-0011224', 'aishah.samsudin@gmail.com',   '63, Taman Sri Mawar, Semenyih, Selangor'),
(30, 'Cindy Khor',               '013-1122335', 'cindy.khor@gmail.com',        '5, Jalan Berlian, Petaling Jaya, Selangor'),
(31, 'Hamizan Bin Rashid',       '017-2233447', 'hamizan.rashid@yahoo.com',    '19, Lorong Aman, Shah Alam, Selangor'),
(32, 'Teo Jia Lin',              '019-3344557', 'jialin.teo@gmail.com',        '8, Taman Harmoni, Puchong, Selangor'),
(33, 'Rajeswari A/P Gopal',      '011-4455669', 'rajes.gopal@gmail.com',       '24, Jalan Sri Murni, Klang, Selangor'),
(34, 'Adila Binti Kadir',        '016-5566780', 'adila.kadir@gmail.com',       '37, Taman Suria, Rawang, Selangor'),
(35, 'Brandon Lee',              '014-6677881', 'brandon.lee@gmail.com',       '12, Lorong Bestari, Subang Jaya, Selangor');

-- PET (45 rows)
INSERT INTO `hp_pet_care`.`pet` (pet_id, customer_id, pet_name, breed_id, gender, date_of_birth, weight, neutered) VALUES 
(1, 1, 'Biscuit', 1, 'M', '2020-03-15', 30.5, true),
(2, 1, 'Nuonuo', 9, 'F', '2021-07-22', 4.2, true), 
(3, 2, 'Mochi', 10, 'F', '2022-01-10', 3.8, false), 
(4, 3, 'Rocky', 2, 'M', '2019-11-05', 32.0, true),
(5, 4, 'Luna', 15, 'F', '2023-02-28', 1.8, false), 
(6, 5, 'Max', 3, 'M', '2021-06-18', 25.4, true),  
(7, 6, 'Wilson', 11, 'M', '2020-09-30', 7.8, true), 
(8, 7, 'Kiki', 18, 'F', '2022-05-14', 0.09, false), 
(9, 8, 'Bruno', 4, 'M', '2018-08-20', 36.2, true), 
(10, 9, 'Mimi', 12, 'F', '2021-12-03', 3.5, true), 
(11, 10, 'Peanut', 5, 'M', '2022-04-17', 11.3, true), 
(12, 3, 'Daisy', 16, 'F', '2023-06-01', 1.4, false), 
(13, 11, 'Oreo', 14, 'M', '2021-03-12', 5.5, true),
(14, 11, 'Pepper', 6, 'F', '2022-08-25', 5.8, true), 
(15, 12, 'Coco', 13, 'F', '2020-11-18', 4.9, true), 
(16, 13, 'Ginger', 9, 'F', '2023-01-07', 4.0, true), 
(17, 14, 'Atlas', 4, 'M', '2019-05-22', 35.0, true), 
(18, 15, 'Milky', 7, 'F', '2022-09-14', 6.2, true), 
(19, 16, 'Bubbles', 21, 'F', '2023-04-03', 0.12, false),
(20, 17, 'Thor', 1, 'M', '2020-07-11', 31.8, true), 
(21, 18, 'Snowball', 13, 'F', '2021-10-29', 5.1, true), 
(22, 19, 'Raja', 4, 'M', '2019-03-16', 37.5, true), 
(23, 20, 'Buttercup', 23, 'F', '2023-07-20', 0.95, false), 
(24, 21, 'Bandit', 5, 'M', '2021-12-30', 12.1, true), 
(25, 22, 'Toffee', 8, 'M', '2022-06-05', 13.2, true), 
(26, 23, 'Ziggy', 19, 'M', '2022-11-19', 0.04, false),
(27, 24, 'Bella', 7, 'F', '2021-05-03', 5.9, true), 
(28, 25, 'Nemo', 12, 'M', '2023-02-14', 4.1, true), 
(29, 26, 'Fluffy', 16, 'F', '2022-03-28', 1.5, false), 
(30, 27, 'Charlie', 6, 'M', '2020-08-08', 7.0, true),
(31, 28, 'Honey', 9, 'F', '2021-09-17', 4.3, true), 
(32, 29, 'Rusty', 5, 'M', '2019-12-22', 11.8, true), 
(33, 30, 'Mocha', 10, 'F', '2022-07-04', 3.9, true), 
(34, 31, 'Duke', 2, 'M', '2020-04-14', 32.7, true), 
(35, 32, 'Pearl', 14, 'F', '2021-08-23', 5.3, true), 
(36, 33, 'Latte', 7, 'F', '2023-03-11', 5.5, true), 
(37, 34, 'Sky', 3, 'M', '2022-01-30', 26.1, true), 
(38, 35, 'Cleo', 11, 'F', '2020-10-06', 7.2, true), 
(39, 6, 'Hazel', 22, 'F', '2023-08-15', 0.03, false), 
(40, 8, 'Titan', 4, 'M', '2022-02-19', 34.8, true), 
(41, 12, 'Pippin', 18, 'M', '2021-06-27', 0.11, false), 
(42, 15, 'Cookie', 5, 'F', '2023-05-09', 10.2, true), 
(43, 20, 'Mango', 24, 'M', '2022-12-01', 1.05, false), 
(44, 25, 'Shadow', 14, 'M', '2020-06-18', 5.7, true), 
(45, 30, 'Pudding', 17, 'F', '2023-04-25', 1.7, false); 

-- STAFF (10 rows)

INSERT INTO `hp_pet_care`.`staff` (staff_id, staff_name, role, phone_number, email, certification) VALUES
(1,  'Dr. Farah Nadia',     'vet',          '012-1111001', 'farah.nadia@happypaws.com',  'MVSc, Universiti Putra Malaysia'),
(2,  'Dr. Sum Ting Wong',   'vet',          '012-1111002', 'wong.sum@happypaws.com',     'BVSc, Universiti Malaya'),
(3,  'Ravi Krishnan',       'groomer',      '012-1111003', 'ravi.k@happypaws.com',       'Certified Pet Groomer, IPGSA'),
(4,  'Nurul Hidayah',       'groomer',      '012-1111004', 'hidayah@happypaws.com',      'Certified Pet Groomer, IPGSA'),
(5,  'Azrul Bin Amin',      'receptionist', '012-1111005', 'azrul.amin@happypaws.com',   'Diploma in Business Administration'),
(6,  'Tan Siew Hua',        'janitor',      '012-1111006', 'siewhua@happypaws.com',      'Certificate in Animal Care'),
(7,  'Kavitha Pillai',      'janitor',      '012-1111007', 'kavitha.p@happypaws.com',    'Certificate in Animal Care'),
(8,  'Mohd Syafiq',         'groomer',      '012-1111008', 'syafiq@happypaws.com',       'Certified Pet Groomer, IPGSA'),
(9,  'Dr. Lee Wen Xin',     'vet',          '012-1111009', 'wenxin.lee@happypaws.com',   'BVSc, Universiti Putra Malaysia'),
(10, 'Salmah Binti Johari', 'admin',        '012-1111010', 'salmah.j@happypaws.com',     'Diploma in Office Management');

-- SERVICE (10 rows)

INSERT INTO `hp_pet_care`.`service` (service_id, service_name, service_type, description, price, availability, duration_minutes) VALUES
(1,  'Basic Grooming',         'grooming',    'Bath, dry, and basic trim',                              45.00,  'Available', 60),
(2,  'Full Grooming Package',  'grooming',    'Bath, dry, full trim, nail clip, ear cleaning',          90.00,  'Available', 120),
(3,  'Core Vaccination',       'vaccination', 'Core vaccines: DHPPiL for dogs, FVRCP for cats',        80.00,  'Available', 30),
(4,  'Wellness Check-Up',      'wellness',    'Full physical examination by vet',                      60.00,  'Available', 45),
(5,  'Dental Cleaning',        'wellness',    'Professional dental scaling and cleaning',              120.00, 'Available', 90),
(6,  'Flea & Tick Treatment',  'wellness',    'Topical flea and tick prevention application',          35.00,  'Available', 20),
(7,  'Nail Trimming',          'grooming',    'Nail clipping and filing only',                         20.00,  'Available', 20),
(8,  'Microchipping',          'wellness',    'Permanent pet ID microchip implant',                    55.00,  'Available', 30),
(9,  'Overnight Boarding',     'wellness',    'Single night stay; includes meals and exercise',        80.00,  'Available', 1440),  -- FIXED A
(10, 'Ear Cleaning',           'grooming',    'Ear canal cleaning and inspection',                     25.00,  'Available', 20);

-- ROOM_TYPE  (4 rows) 

INSERT INTO `hp_pet_care`.`room_type` (room_type_id, room_type_name, nightly_rate, description) VALUES
(1, 'Standard', 80.00, 'Comfortable individual kennel with daily feeding and exercise'),
(2, 'Deluxe',  120.00, 'Spacious room with enrichment toys and extra playtime'),
(3, 'Suite',   180.00, 'Premium suite with 24-hr monitoring, luxury bedding, and live camera'),
(4, 'Family',  250.00, 'Large shared room for multi-pet families from the same household');

-- APPOINTMENT (25 rows)

INSERT INTO `hp_pet_care`.`appointment` (appointment_id, pet_id, staff_id, service_id, appointment_datetime, status) VALUES
(1,  1,  3,    1,  '2026-05-05 09:00:00', 'completed'),   -- Biscuit: Basic Grooming (Ravi)
(2,  3,  4,    2,  '2026-05-06 10:30:00', 'completed'),   -- Mochi: Full Grooming (Hidayah)
(3,  4,  1,    3,  '2026-05-07 11:00:00', 'completed'),   -- Rocky: Core Vaccination (Dr Farah)
(4,  6,  3,    1,  '2026-05-08 14:00:00', 'completed'),   -- Max: Basic Grooming (Ravi)
(5,  9,  2,    4,  '2026-05-10 09:30:00', 'completed'),   -- Bruno: Wellness Check-Up (Dr Wong)
(6,  1,  3,    7,  '2026-05-12 15:00:00', 'completed'),   -- Biscuit: Nail Trimming (Ravi)
(7,  7,  4,    2,  '2026-05-14 10:00:00', 'completed'),   -- Wilson: Full Grooming (Hidayah)
(8,  5,  1,    4,  '2026-05-15 13:00:00', 'completed'),   -- Luna: Wellness Check-Up (Dr Farah)
(9,  10, 2,    3,  '2026-05-20 11:30:00', 'completed'),   -- Mimi: Core Vaccination (Dr Wong)
(10, 11, 8,    1,  '2026-05-22 09:00:00', 'completed'),   -- Peanut: Basic Grooming (Syafiq)
(11, 13, 4,    2,  '2026-05-23 10:00:00', 'completed'),   -- Oreo: Full Grooming (Hidayah)
(12, 17, 9,    4,  '2026-05-24 11:00:00', 'completed'),   -- Atlas: Wellness Check-Up (Dr Lee)
(13, 20, 3,    1,  '2026-05-25 14:00:00', 'completed'),   -- Thor: Basic Grooming (Ravi)
(14, 22, 1,    3,  '2026-05-26 09:30:00', 'completed'),   -- Raja: Core Vaccination (Dr Farah)
(15, 25, 8,    6,  '2026-05-27 15:30:00', 'completed'),   -- Toffee: Flea & Tick Treatment (Syafiq)
(16, 27, 3,    2,  '2026-05-28 10:00:00', 'completed'),   -- Bella: Full Grooming (Ravi)
(17, 30, 2,    4,  '2026-05-29 11:00:00', 'completed'),   -- Charlie: Wellness Check-Up (Dr Wong)
(18, 34, 4,    7,  '2026-05-30 09:00:00', 'completed'),   -- Duke: Nail Trimming (Hidayah)
(19, 38, 9,    3,  '2026-05-31 14:00:00', 'completed'),   -- Cleo: Core Vaccination (Dr Lee)
(20, 40, 1,    4,  '2026-06-01 10:30:00', 'completed'),   -- Titan: Wellness Check-Up (Dr Farah)
(21, 8,  1,    4,  '2026-06-02 14:30:00', 'scheduled'),   -- Kiki: Wellness Check-Up (Dr Farah)
(22, 4,  2,    5,  '2026-06-05 10:00:00', 'scheduled'),   -- Rocky: Dental Cleaning (Dr Wong)
(23, 15, 4,    2,  '2026-06-06 11:00:00', 'scheduled'),   -- Coco: Full Grooming (Hidayah)
(24, 33, 3,    1,  '2026-06-07 09:00:00', 'scheduled'),   -- Mocha: Basic Grooming (Ravi)
(25, 37, 9,    4,  '2026-06-08 13:00:00', 'scheduled');   -- Sky: Wellness Check-Up (Dr Lee)

-- MEDICALRECORD (30 rows) 

INSERT INTO `hp_pet_care`.`medical_record` (record_id, pet_id, record_date, record_type, description, next_due_date) VALUES
(1,  1,  '2025-03-15', 'vaccination', 'Core vaccines (DHPPiL) administered. Annual booster completed.',       '2026-03-15'),
(2,  2,  '2024-08-10', 'treatment',   'Spayed successfully. Recovery normal. Post-op check passed.',          NULL),
(3,  3,  '2024-09-05', 'vaccination', 'FVRCP administered. No known allergies recorded.',                     '2025-09-05'),
(4,  4,  '2025-01-20', 'checkup',     'Full physical exam. Hip examination completed. Overall healthy.',      '2026-01-20'),
(5,  5,  '2025-03-01', 'checkup',     'New patient intake exam. No prior medical history on file.',           '2026-03-01'),
(6,  6,  '2025-02-14', 'vaccination', 'Core vaccines administered. Mild skin allergy noted on record.',       '2026-02-14'),
(7,  7,  '2024-11-22', 'treatment',   'Neutered. Flea treatment applied. Healthy body weight confirmed.',     '2025-05-22'),
(8,  8,  '2025-05-14', 'treatment',   'Routine wing clipping performed. Bird assessed as healthy.',           '2025-11-14'),
(9,  9,  '2025-04-10', 'checkup',     'Vaccinations up to date. Arthritis noted. Joint supplement advised.',  '2026-04-10'),
(10, 10, '2025-03-03', 'vaccination', 'FVRCP booster given. Cat is healthy and active.',                      '2026-03-03'),
(11, 11, '2025-04-17', 'checkup',     'Vaccinations current. Healthy weight maintained.',                     '2026-04-17'),
(12, 12, '2025-06-02', 'checkup',     'New patient intake exam. No prior medical history on file.',           '2026-06-02'),
(13, 13, '2025-05-10', 'vaccination', 'FVRCP administered. Cat calm and well-behaved during visit.',          '2026-05-10'),
(14, 14, '2025-06-01', 'checkup',     'Full physical exam. Dental tartar noted; cleaning recommended.',       '2026-06-01'),
(15, 15, '2025-02-20', 'vaccination', 'FVRCP booster. Ragdoll in excellent condition.',                       '2026-02-20'),
(16, 17, '2025-01-15', 'checkup',     'Hip and joint assessment. Mild dysplasia noted. Supplement started.',  '2026-01-15'),
(17, 18, '2025-04-05', 'vaccination', 'Core vaccines (DHPPiL) administered. Poodle in good health.',          '2026-04-05'),
(18, 20, '2025-03-28', 'checkup',     'Full wellness check. Golden Retriever in excellent shape.',            '2026-03-28'),
(19, 22, '2025-02-10', 'vaccination', 'Core vaccines administered. Strong and healthy German Shepherd.',      '2026-02-10'),
(20, 24, '2025-05-20', 'checkup',     'Routine check. Beagle healthy; ear inspection clear.',                 '2026-05-20'),
(21, 25, '2025-04-22', 'treatment',   'Flea treatment applied. Mild skin irritation resolved after treatment.','2025-10-22'),
(22, 27, '2025-03-18', 'vaccination', 'Core vaccines (DHPPiL) administered. Poodle healthy and active.',     '2026-03-18'),
(23, 30, '2025-05-05', 'checkup',     'Senior dog checkup. Blood panel normal. Moderate dental wear noted.',  '2026-05-05'),
(24, 32, '2025-04-30', 'treatment',   'Tick removal performed. Area cleaned and treated. Monitoring advised.','2025-10-30'),
(25, 34, '2025-06-10', 'vaccination', 'Core vaccines (DHPPiL) booster. Labrador energetic and healthy.',     '2026-06-10'),
(26, 37, '2025-05-25', 'checkup',     'Full wellness check. Siberian Husky coat in excellent condition.',     '2026-05-25'),
(27, 38, '2025-03-12', 'vaccination', 'FVRCP administered. Maine Coon in good health.',                       '2026-03-12'),
(28, 40, '2025-06-01', 'checkup',     'Young German Shepherd. All vaccinations current. Healthy.',            '2026-06-01'),
(29, 9,  '2024-12-15', 'treatment',   'Dental scaling performed. Gum inflammation resolved.',                 NULL),
(30, 7,  '2025-05-30', 'vaccination', 'FVRCP booster administered. Maine Coon healthy weight.',               '2026-05-30');
 
-- PETHOTELBOOKING (15 rows)

INSERT INTO `hp_pet_care`.`pet_hotel_booking`
   (booking_id, pet_id, staff_id, room_type_id, check_in_date, check_out_date, booking_status) VALUES
(1,  1,  6, 1, '2026-05-10', '2026-05-13', 'completed'),   -- Standard 3n = RM240   FIXED B+C
(2,  3,  7, 2, '2026-05-15', '2026-05-17', 'completed'),   -- Deluxe   2n = RM240   FIXED B+C
(3,  6,  6, 1, '2026-05-18', '2026-05-20', 'completed'),   -- Standard 2n = RM160   FIXED B+C
(4,  4,  7, 3, '2026-05-20', '2026-05-25', 'completed'),   -- Suite    5n = RM900   FIXED B+C
(5,  7,  6, 1, '2026-05-28', '2026-05-30', 'completed'),   -- Standard 2n = RM160   FIXED B+C
(6,  9,  7, 2, '2026-06-01', '2026-06-04', 'checked-in'),  -- Deluxe   3n = RM360   FIXED B+C
(7,  10, 6, 1, '2026-06-07', '2026-06-10', 'booked'),      -- Standard 3n = RM240   FIXED B+C
(8,  11, 7, 3, '2026-06-12', '2026-06-15', 'booked'),      -- Suite    3n = RM540   FIXED B+C
(9,  20, 6, 2, '2026-05-23', '2026-05-26', 'completed'),   -- Deluxe   3n = RM360   FIXED B+C
(10, 13, 7, 1, '2026-05-25', '2026-05-27', 'completed'),   -- Standard 2n = RM160   FIXED B+C
(11, 25, 6, 2, '2026-05-30', '2026-06-02', 'completed'),   -- Deluxe   3n = RM360   FIXED B+C
(12, 34, 7, 1, '2026-06-03', '2026-06-07', 'checked-in'),  -- Standard 4n = RM320   FIXED B+C
(13, 27, 6, 3, '2026-06-05', '2026-06-08', 'booked'),      -- Suite    3n = RM540   FIXED B+C
(14, 22, 7, 1, '2026-05-22', '2026-05-24', 'completed'),   -- Standard 2n = RM160   FIXED B+C
(15, 38, 6, 2, '2026-06-08', '2026-06-11', 'booked');      -- Deluxe   3n = RM360   FIXED B+C

-- PRODUCT (12 rows)

INSERT INTO `hp_pet_care`.`product` (product_id, product_name, category, price, stock_quantity) VALUES
(1,  'Royal Canin Adult Dog Food 4kg',      'Pet Food',    75.00,  50),
(2,  'Whiskas Dry Cat Food 1.5kg',          'Pet Food',    22.00,  80),
(3,  'FRONTLINE Plus Flea & Tick Spray',    'Healthcare',  48.00,  40),
(4,  'Natures Miracle Stain Remover 500ml', 'Cleaning',    35.00,  30),
(5,  'Kong Classic Dog Toy',                'Toy',         28.00,  60),
(6,  'Cat Scratching Post with Toy',        'Accessory',   55.00,  25),
(7,  'Pet Carrier Bag (Medium)',            'Accessory',   95.00,  20),
(8,  'Virbac Pet Shampoo 250ml',            'Grooming',    18.00,  70),
(9,  'Nutritional Supplement Omega-3',      'Healthcare',  42.00,  35),
(10, 'Stainless Steel Water Fountain',      'Accessory',  110.00,  15),
(11, 'Rabbit Pellet Food 1kg',              'Pet Food',    18.00,  45),
(12, 'Bird Seed Mix 500g',                  'Pet Food',    12.00,  55);

-- SALE (15 rows)

INSERT INTO `hp_pet_care`.`sale` (sale_id, customer_id, sale_date, total_amount) VALUES
(1,  3,  '2026-05-05', 150.00),   -- 2×Royal Canin (75×2)
(2,  1,  '2026-05-06',  75.00),   -- 1×Royal Canin
(3,  5,  '2026-05-08',  88.00),   -- Kong(28)+Shampoo(18)+Omega-3(42)
(4,  2,  '2026-05-10',  40.00),   -- Whiskas(22)+Shampoo(18)
(5,  7,  '2026-05-12',  95.00),   -- 1×Pet Carrier
(6,  4,  '2026-05-15', 207.00),   -- Royal Canin(75)+FRONTLINE(48)+2×Omega-3(84)
(7,  6,  '2026-05-18',  58.00),   -- Whiskas(22)+2×Shampoo(36)
(8,  8,  '2026-05-20', 110.00),   -- 1×Water Fountain
(9,  9,  '2026-05-25',  42.00),   -- 1×Omega-3
(10, 10, '2026-05-28', 110.00),   -- 1×Water Fountain
(11, 11, '2026-05-28',  36.00),   -- 2×Rabbit Pellet Food
(12, 15, '2026-05-29', 105.00),   -- Royal Canin(75)+Bird Seed(12)+Shampoo(18)
(13, 20, '2026-05-30',  55.00),   -- 1×Cat Scratching Post
(14, 27, '2026-06-01', 100.00),   -- Kong(28)+Shampoo(18)+Omega-3(42)+Bird Seed(12)
(15, 33, '2026-06-03',  75.00);   -- 1×Royal Canin

-- SALEITEM (26 rows)

INSERT INTO `hp_pet_care`.`sale_item` (sale_id, product_id, quantity, unit_price) VALUES
-- Sale 1: 2× Royal Canin Dog Food = RM150
(1,  1,  2,  75.00),
-- Sale 2: 1× Royal Canin Dog Food = RM75
(2,  1,  1,  75.00),
-- Sale 3: Kong + Shampoo + Omega-3 = RM88
(3,  5,  1,  28.00),
(3,  8,  1,  18.00),
(3,  9,  1,  42.00),
-- Sale 4: Whiskas + Shampoo = RM40
(4,  2,  1,  22.00),
(4,  8,  1,  18.00),
-- Sale 5: Pet Carrier Bag = RM95
(5,  7,  1,  95.00),
-- Sale 6: Royal Canin + FRONTLINE + 2× Omega-3 = RM207
(6,  1,  1,  75.00),
(6,  3,  1,  48.00),
(6,  9,  2,  42.00),
-- Sale 7: Whiskas + 2× Shampoo = RM58
(7,  2,  1,  22.00),
(7,  8,  2,  18.00),
-- Sale 8: Water Fountain = RM110
(8,  10, 1, 110.00),
-- Sale 9: Omega-3 = RM42
(9,  9,  1,  42.00),
-- Sale 10: Water Fountain = RM110
(10, 10, 1, 110.00),
-- Sale 11: 2× Rabbit Pellet Food = RM36
(11, 11, 2,  18.00),
-- Sale 12: Royal Canin + Bird Seed + Shampoo = RM105
(12, 1,  1,  75.00),
(12, 12, 1,  12.00),
(12, 8,  1,  18.00),
-- Sale 13: Cat Scratching Post = RM55
(13, 6,  1,  55.00),
-- Sale 14: Kong + Shampoo + Omega-3 + Bird Seed = RM100
(14, 5,  1,  28.00),
(14, 8,  1,  18.00),
(14, 9,  1,  42.00),
(14, 12, 1,  12.00),
-- Sale 15: Royal Canin = RM75
(15, 1,  1,  75.00);

-- PAYMENT (44 rows) 

INSERT INTO `hp_pet_care`.`payment` (payment_id, appointment_id, booking_id, sale_id, payment_date, amount, payment_method) VALUES
 
-- ── Appointment payments  (appointments 1–20, all completed) ───
(1,  1,  NULL, NULL, '2026-05-05', 45.00,  'cash'),
(2,  2,  NULL, NULL, '2026-05-06', 90.00,  'card'),
(3,  3,  NULL, NULL, '2026-05-07', 80.00,  'online'),
(4,  4,  NULL, NULL, '2026-05-08', 45.00,  'cash'),
(5,  5,  NULL, NULL, '2026-05-10', 60.00,  'card'),
(6,  6,  NULL, NULL, '2026-05-12', 20.00,  'cash'),
(7,  7,  NULL, NULL, '2026-05-14', 90.00,  'card'),
(8,  8,  NULL, NULL, '2026-05-15', 60.00,  'online'),
(9,  9,  NULL, NULL, '2026-05-20', 80.00,  'cash'),
(10, 10, NULL, NULL, '2026-05-22', 45.00,  'card'),
(11, 11, NULL, NULL, '2026-05-23', 90.00,  'card'),
(12, 12, NULL, NULL, '2026-05-24', 60.00,  'online'),
(13, 13, NULL, NULL, '2026-05-25', 45.00,  'cash'),
(14, 14, NULL, NULL, '2026-05-26', 80.00,  'bank_transfer'),
(15, 15, NULL, NULL, '2026-05-27', 35.00,  'cash'),
(16, 16, NULL, NULL, '2026-05-28', 90.00,  'card'),
(17, 17, NULL, NULL, '2026-05-29', 60.00,  'online'),
(18, 18, NULL, NULL, '2026-05-30', 20.00,  'cash'),
(19, 19, NULL, NULL, '2026-05-31', 80.00,  'card'),
(20, 20, NULL, NULL, '2026-06-01', 60.00,  'bank_transfer'),
 
-- ── Hotel booking payments  (bookings 1–5, 9–11, 14 = completed) ─
(21, NULL, 1,  NULL, '2026-05-13', 240.00, 'card'),           -- Standard 3n = RM240
(22, NULL, 2,  NULL, '2026-05-17', 240.00, 'online'),         -- Deluxe   2n = RM240
(23, NULL, 3,  NULL, '2026-05-20', 160.00, 'cash'),           -- Standard 2n = RM160
(24, NULL, 4,  NULL, '2026-05-25', 900.00, 'card'),           -- Suite    5n = RM900
(25, NULL, 5,  NULL, '2026-05-30', 160.00, 'card'),           -- Standard 2n = RM160
(26, NULL, 9,  NULL, '2026-05-26', 360.00, 'online'),         -- Deluxe   3n = RM360
(27, NULL, 10, NULL, '2026-05-27', 160.00, 'cash'),           -- Standard 2n = RM160
(28, NULL, 11, NULL, '2026-06-02', 360.00, 'card'),           -- Deluxe   3n = RM360
(29, NULL, 14, NULL, '2026-05-24', 160.00, 'bank_transfer'),  -- Standard 2n = RM160
 
-- ── Product sale payments  (sales 1–15) ─────────────────────────
(30, NULL, NULL, 1,  '2026-05-05', 150.00, 'cash'),
(31, NULL, NULL, 2,  '2026-05-06',  75.00, 'card'),
(32, NULL, NULL, 3,  '2026-05-08',  88.00, 'online'),
(33, NULL, NULL, 4,  '2026-05-10',  40.00, 'cash'),
(34, NULL, NULL, 5,  '2026-05-12',  95.00, 'card'),
(35, NULL, NULL, 6,  '2026-05-15', 207.00, 'card'),
(36, NULL, NULL, 7,  '2026-05-18',  58.00, 'cash'),
(37, NULL, NULL, 8,  '2026-05-20', 110.00, 'online'),
(38, NULL, NULL, 9,  '2026-05-25',  42.00, 'cash'),
(39, NULL, NULL, 10, '2026-05-28', 110.00, 'card'),
(40, NULL, NULL, 11, '2026-05-28',  36.00, 'cash'),
(41, NULL, NULL, 12, '2026-05-29', 105.00, 'online'),
(42, NULL, NULL, 13, '2026-05-30',  55.00, 'card'),
(43, NULL, NULL, 14, '2026-06-01', 100.00, 'card'),
(44, NULL, NULL, 15, '2026-06-03',  75.00, 'cash');

SELECT staff_id, staff_name, role, phone_number, email, certification
FROM hp_pet_care.staff
WHERE role = 'vet';

SELECT service_name, service_type, description, price, availability, duration_minutes
FROM hp_pet_care.service
WHERE service_type = 'wellness' AND price < 60;

USE hp_pet_care;
SELECT customer.customer_name, pet.pet_name, breed.breed_name, pet.gender
FROM pet
JOIN customer on pet.customer_id = customer.customer_id
JOIN breed on pet.breed_id = breed.breed_id;

SELECT service.service_name, service.service_type, staff.staff_name, pet.pet_name, breed.breed_name
FROM appointment
JOIN pet on appointment.pet_id = pet.pet_id
JOIN staff on appointment.staff_id = staff.staff_id
JOIN service on appointment.service_id = service.service_id
JOIN breed ON pet.breed_id = breed.breed_id;

SELECT 'Total Sales from Appointment' AS category, SUM(payment.amount) AS total_sales
FROM payment
WHERE payment.appointment_id IS NOT NULL
UNION ALL
SELECT 'Total Sales from Pet Hotel', SUM(payment.amount)
FROM payment
WHERE payment.booking_id IS NOT NULL
UNION ALL
SELECT 'Total Sales from Products', SUM(payment.amount)
FROM payment
WHERE payment.sale_id IS NOT NULL;

SELECT
room_type.room_type_name,
COUNT(pet_hotel_booking.booking_id) AS `Total Booking`,
AVG(DATEDIFF(pet_hotel_booking.check_out_date, pet_hotel_booking.check_in_date)) AS `Average Night Spent`
FROM pet_hotel_booking
JOIN room_type on room_type.room_type_id = pet_hotel_booking.room_type_id
GROUP BY room_type.room_type_name
HAVING `Average Night Spent` >= 2
ORDER BY `Average Night Spent` DESC;

SELECT
staff.staff_name,
staff.role,
COUNT(appointment.appointment_id) as `Total Appointment`,
SUM(service.price) as `Revenue from Services`,
ROUND(SUM(service.price) / COUNT(appointment.appointment_id), 2) AS `Average Revenue per Appointment`
FROM staff
JOIN appointment on appointment.staff_id = staff.staff_id
JOIN service on service.service_id = appointment.service_id
WHERE appointment.status = 'completed'
GROUP BY staff.staff_id, staff.staff_name, staff.role
ORDER BY `Average Revenue per Appointment` DESC;

SELECT product.product_name, product.category, SUM(sale_item.unit_price*sale_item.quantity) as `Revenue for Product`
FROM product
JOIN sale_item on sale_item.product_id = product.product_id
GROUP BY product.product_id, product.product_name
ORDER BY `Revenue for Product` DESC;