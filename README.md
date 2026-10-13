# HappyPaws Pet Care Centre: Relational Database (MySQL)

A relational database for a fictional pet care business, built as a group assignment for **Database Technology and Applications (ECM202)** at Xiamen University Malaysia (June 2026). It covers grooming, vaccination and wellness appointments, a pet hotel, retail sales and payments, and comes with sample data and SQL queries that turn it into business reports.

> **Team project (7 students).** My contribution: **Task 7 (data population)** and **Task 8 (SQL queries with business interpretation)**. The business case analysis and client requirement questions (Tasks 1-2) were shared across the team. The ERD, normalisation and schema creation were completed by other team members.

## The business case

HappyPaws is a growing pet care centre offering grooming, vaccinations and wellness checks by appointment, a pet hotel, and a retail shop for pet food, accessories and toys. The database replaces manual paper records so staff can manage appointments, track each pet's medical history, record every payment, and see how each part of the business is performing.

## Database design

14 tables, normalised to Third Normal Form (3NF).

| Area | Tables |
|---|---|
| Customers and pets | `customer`, `pet`, `breed`, `species` |
| Staff and services | `staff`, `service` |
| Appointments and health | `appointment`, `medical_record` |
| Pet hotel | `pet_hotel_booking`, `room_type` |
| Retail | `product`, `sale`, `sale_item` |
| Payments | `payment` |

**Design highlights**
- A pet's species is stored through its breed (`pet` → `breed` → `species`), and hotel room rates live in `room_type` rather than being repeated on every booking.
- Foreign keys with explicit `ON DELETE` / `ON UPDATE` rules.
- `CHECK` constraints for valid staff roles, statuses, payment methods, non-negative prices and `check_out_date > check_in_date`.
- A unique key on `(staff_id, appointment_datetime)` prevents double-booking a staff member.
- Each payment must reference exactly one of an appointment, a hotel booking or a product sale.

**Scope and assumptions**
- Each appointment is for one pet and one service, and each pet belongs to one customer (one customer can own many pets).
- Payment is made at the time of service or purchase, and walk-in sales are allowed (`sale.customer_id` is optional).
- Staff roles are predefined: admin, groomer, vet, receptionist, janitor.
- Out of scope: payment gateways, refunds and deposits, loyalty programmes, payroll and shift scheduling, supplier purchase orders, and multiple branches.

## Sample data

Synthetic but realistic Malaysian data: **301 rows across 14 tables**. Payment amounts reconcile with the underlying records (service prices, nights × room rate, and sale totals).

| Table | Rows | Table | Rows |
|---|---|---|---|
| `species` | 6 | `pet_hotel_booking` | 15 |
| `breed` | 24 | `product` | 12 |
| `customer` | 35 | `sale` | 15 |
| `pet` | 45 | `sale_item` | 26 |
| `staff` | 10 | `payment` | 44 |
| `service` | 10 | `appointment` | 25 |
| `room_type` | 4 | `medical_record` | 30 |

## SQL queries

Eight queries, each written with a technical explanation and a business interpretation.

| # | Type | Business question | Techniques | Result on the sample data |
|---|---|---|---|---|
| 8.1.1 | Retrieval | Which staff are vets? | `WHERE` | 3 vets |
| 8.1.2 | Retrieval | Which wellness services cost under RM60? | `WHERE` + `AND` | Flea & Tick Treatment, Microchipping |
| 8.2.1 | Join (3 tables) | Which customer owns which pet, and its breed? | `JOIN` | 45 rows |
| 8.2.2 | Join (5 tables) | For each appointment: service, staff, pet and breed | `JOIN` | 25 rows |
| 8.3.1 | Aggregate | Revenue by business stream | `SUM`, `UNION ALL` | Appointments RM1,235, Pet hotel RM2,740, Products RM1,346 |
| 8.3.2 | Grouped | Average hotel stay by room type (2+ nights) | `AVG`, `DATEDIFF`, `GROUP BY`, `HAVING` | Suite 3.67 nights, Deluxe 2.80, Standard 2.57 |
| 8.4.1 | Analytical | Revenue per completed appointment, by staff member | multi-table join, `SUM`, `COUNT`, `ROUND` | Highest: Nurul Hidayah, RM72.50 per appointment |
| 8.4.2 | Analytical | Product revenue ranking | `SUM(quantity * unit_price)` | Top: Royal Canin Adult Dog Food 4kg, RM450 |

**Example: revenue by business stream (8.3.1)**

```sql
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
```

| category | total_sales |
|---|---|
| Total Sales from Appointment | 1235.00 |
| Total Sales from Pet Hotel | 2740.00 |
| Total Sales from Products | 1346.00 |

The business reading: the pet hotel brings in the most revenue on this sample data, so management could look at room pricing and capacity before expanding other services.

## How to run it

**Requirements:** MySQL 8.0.16 or later (earlier versions accept `CHECK` constraints but ignore them) and MySQL Workbench or the `mysql` command line.

```
├── 01_schema.sql           -- creates the hp_pet_care schema and all 14 tables
├── 02_data_population.sql  -- inserts the sample data
└── 03_queries.sql          -- the 8 queries
```

1. Run `01_schema.sql` to create the `hp_pet_care` database.
2. Run `02_data_population.sql`. The inserts are ordered so that parent tables load before the tables that reference them: species, breed, customer, pet, staff, service, room_type, appointment, medical_record, pet_hotel_booking, product, sale, sale_item, payment.
3. Run `03_queries.sql` and compare your output with the table above.

## Known limitations

- The dataset is small and synthetic. It is enough to exercise joins and aggregates, but not to test performance.
- `medical_record.appointment_id` is left empty in the sample data, so medical records are not linked to specific appointments.
- The staff revenue query (8.4.1) uses service list prices for completed appointments, not the recorded payment amounts.

## Skills demonstrated

MySQL, relational modelling and 3NF, constraints and keys, multi-table joins, aggregation with `GROUP BY` / `HAVING`, `UNION ALL`, date arithmetic, synthetic data design, and translating query results into business insight.

## About

Created for coursework and shared for portfolio purposes. Please don't reuse it in your own assessed work.

**Chinjuanto Lendy Jaya**, Bachelor of Management in E-Commerce (Honours), Xiamen University Malaysia | [LinkedIn](https://www.linkedin.com/in/chinjuanto)
