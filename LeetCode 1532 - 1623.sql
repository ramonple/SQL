-- 1532. The Most Recent Three Orders [Medium]

drop table if exists Customers;
create table Customers
(customer_id int primary key, name varchar(55));
insert into Customers Values(1,'Winston');
insert into Customers Values(2,'Jonathan');
insert into Customers Values(3,'annabelle');
insert into Customers Values(4,'Marwan');
insert into Customers Values(5,'Khaled');

drop table if exists Orders;
create table Orders
(order_id int primary key, order_date date,customer_id int, cost int);

insert into Orders Values(1,'2020-07-31',1,30);
insert into Orders Values(2,'2020-07-30',2,40);
insert into Orders Values(3,'2020-07-31',3,70);
insert into Orders Values(4,'2020-07-29',4,100);
insert into Orders Values(5,'2020-06-10',1,1010);
insert into Orders Values(6,'2020-08-01',2,102);
insert into Orders Values(7,'2020-08-01',3,111);
insert into Orders Values(8,'2020-08-03',1,99);
insert into Orders Values(9,'2020-08-07',2,32);
insert into Orders Values(10,'2020-07-15',1,2);

-- Write an SQL query to find the most recent 3 orders of each user. If a user ordered less than 3 orders return all of their orders.
-- Return the result table sorted by customer_name in ascending order and in case of a tie by the customer_id in ascending order. If there still a tie, order them by the order_date in descending order.


select c.name, c.customer_id, a.order_date,a.order_id, a.cost
from 
(select customer_id, order_date,order_id, cost,rank() over (partition by customer_id order by order_date DESC) as rnk
from Orders) as a JOIN Customers as c
ON a.customer_id = c.customer_id
where rnk<=3
order by c.name, c.customer_id,a.order_date DESC
-- leetcode answer:
WITH

tmp AS (
SELECT a.name, a.customer_id, b.order_id, b.order_date,
ROW_NUMBER() OVER(PARTITION BY a.name, a.customer_id ORDER BY b.order_date DESC) AS rnk
FROM Customers AS a
JOIN Orders AS b
ON a.customer_id = b.customer_id
)

SELECT name AS customer_name, customer_id, order_id, order_date
FROM tmp
WHERE rnk <= 3
ORDER BY customer_name, customer_id, order_date DESC;


-- 1543. Fix Product Name Format [Easy]
drop table if exists Sales;
create table Sales
(sale_id int primary key, product_name varchar(55), sale_date date);
insert into Sales Values(1,'   LCPHONE','2000-01-16');
insert into Sales Values(2,'LCPHONE','2000-01-17');
insert into Sales Values(3,'  LcPhOnE','2000-02-18');
insert into Sales Values(4,'    LcKeyCHAiN','2000-02-19');
insert into Sales Values(5,'   LcKeyChain','2000-02-28');
insert into Sales Values(6,'Matryoshka','2000-03-31');

-- Since table Sales was filled manually in the year 2000, product_name may contain leading and/or trailing white spaces, also they are case-insensitive.
-- Write an SQL query to report
-- product_name in lowercase without leading or trailing white spaces.
-- sale_date in the format 'YYYY-MM'
--  total：the number of times the product was sold in this month.
-- Return the result table ordered by product_name in ascending order, in case of a tie order it by sale_date in ascending order.

SELECT LOWER(TRIM(product_name)) AS product_name,  -- The TRIM() function removes the space character OR other specified characters from the start or end of a string. 
LEFT(sale_date, 7) AS sale_date, COUNT(*) AS total FROM Sales
GROUP BY LOWER(TRIM(product_name)), LEFT(sale_date, 7)
ORDER BY product_name, sale_date;



SELECT LOWER(TRIM(product_name)) AS product_name, 
date_format(sale_date, '%Y-%m') AS sale_date, COUNT(*) AS total FROM Sales
GROUP BY LOWER(TRIM(product_name)), date_format(sale_date, '%Y-%m') 
ORDER BY product_name, sale_date;



-- 1549. The Most Recent Orders for Each Product [Medium]

drop table if exists Customers;
create table Customers
(customer_id int primary key, name varchar(55));
insert into Customers Values(1,'Winston');
insert into Customers Values(2,'Jonathan');
insert into Customers Values(3,'annabelle');
insert into Customers Values(4,'Marwan');
insert into Customers Values(5,'Khaled');

drop table if exists Orders;
create table Orders
(order_id int primary key, order_date date,customer_id int, product_id int);

insert into Orders Values(1,'2020-07-31',1,1);
insert into Orders Values(2,'2020-07-30',2,2);
insert into Orders Values(3,'2020-08-29',3,3);
insert into Orders Values(4,'2020-07-29',4,1);
insert into Orders Values(5,'2020-06-10',1,2);
insert into Orders Values(6,'2020-08-01',2,1);
insert into Orders Values(7,'2020-08-01',3,1);
insert into Orders Values(8,'2020-08-03',1,2);
insert into Orders Values(9,'2020-08-07',2,3);
insert into Orders Values(10,'2020-07-15',1,2);

drop table if exists Products;
create table Products
(product_id int primary key, product_name varchar(15), price int);
insert into Products Values(1,'keyboard',120);
insert into Products Values(2,'mouse',80);
insert into Products Values(3,'screen',600);
insert into Products Values(4,'hard disk',450);

-- Write an SQL query to find the most recent order(s) of each product.
-- Return the result table sorted by product_name in ascending order and in case of a tie by the product_id in ascending order. If there still a tie, order them by the order_id in ascending order.

select p.product_name,a.product_id, a.order_id,a.order_date
from
(
select product_id, order_id, order_date,rank() over(partition by product_id order by order_date DESC) as rnk
from Orders) as a JOIN Products as p ON a.product_id=p.product_id
where a.rnk=1


-- leetcode:
WITH

tmp AS (
SELECT a.product_name, a.product_id, b.order_id, b.order_date,
RANK() OVER(PARTITION BY a.product_name, a.product_id ORDER BY b.order_date DESC) AS rnk
FROM Products AS a
JOIN Orders AS b
ON a.product_id = b.product_id
)

SELECT product_name, product_id, order_id, order_date FROM tmp
WHERE rnk = 1
ORDER BY product_name, product_id, order_id;



-- 1555. Bank Account Summary [Medium]
drop table if exists Users;
create table Users
(user_id int primary key, user_name varchar(55),credit int);
insert into Users Values(1,'Moustafa',100);
insert into Users Values(2,'Jonathan',200);
insert into Users Values(3,'Winston',10000);
insert into Users Values(4,'Luis',800);

drop table if exists Transactions;
create table Transactions
(trans_id int primary key, paid_by int, paid_to int, amount int, transacted_on date);
insert into Transactions Values(1,1,3,400,'2020-08-01');
insert into Transactions Values(2,3,2,500,'2020-08-02');
insert into Transactions Values(3,2,1,200,'2020-08-03');


-- Leetcode Bank (LCB) helps its coders in making virtual payments. 
-- Our bank records all transactions in the table Transaction, we want to find out the current balance of all users 
-- and check wheter they have breached their credit limit (If their current credit is less than 0).

-- Write an SQL query to report.

-- user_id
-- user_name
-- credit, current balance after performing transactions.
-- credit_limit_breached, check credit_limit ("Yes" or "No")


with
t1 as (
select user_id,user_name,amount as credit_minus
from users as u JOIN Transactions as t
ON u.user_id = t.paid_by)
,
t2 as 
(select user_id,user_name, amount as credit_add
from users as u JOIN Transactions as t
ON u.user_id = t.paid_to)

select Users.user_id, Users.user_name, IFNULL(Users.credit - t1.credit_minus + t2.credit_add, Users.credit) as credit
from Users LEFT JOIN  t1 on Users.user_id = t1.user_id
           LEFT JOIN  t2 on Users.user_id = t2.user_id



with
t1 as (
select user_id,user_name,amount as credit_minus
from users as u JOIN Transactions as t
ON u.user_id = t.paid_by)
,
t2 as 
(select user_id,user_name, amount as credit_add
from users as u JOIN Transactions as t
ON u.user_id = t.paid_to)
,
t3 as (
select Users.user_id, Users.user_name, IFNULL(Users.credit - t1.credit_minus + t2.credit_add, Users.credit) as credit
from Users LEFT JOIN  t1 on Users.user_id = t1.user_id
           LEFT JOIN  t2 on Users.user_id = t2.user_id)
					 
select *,CASE WHEN credit <= 0 Then 'Yes' ELSE 'No' END as credit_limit_breached
from t3
					 
					 
					 
-- 1565. Unique Orders and Customers Per Month [Easy]
-- Write an SQL query to find the number of unique orders and the number of unique customers with invoices > $20 for each different month
select DATE_FORMAT(order_date, '%Y-%m')  as month, count (order_in) as order_count, count(customer_id) as customer_count
from Orders
where invoice > 20
Group by DATE_FORMAT(order_date, '%Y-%m')
order by DATE_FORMAT(order_date, '%Y-%m')

select LEFT(order_date,7) as month, count (order_in) as order_count, count(customer_id) as customer_count
from Orders
where invoice > 20
Group by LEFT(order_date, 7) 
order by LEFT(order_date, 7) 



-- 1571. Warehouse Manager [Easy]

create table Warehouse
(name varchar(55), product_id int, units int,
primary key (name,product_id));
insert into Warehouse Values('LCHouse1',1,10);
insert into Warehouse Values('LCHouse1',2,10);
insert into Warehouse Values('LCHouse1',3,5);
insert into Warehouse Values('LCHouse2',1,2);
insert into Warehouse Values('LCHouse2',2,2);
insert into Warehouse Values('LCHouse3',4,1);

drop table if exists Products;
create table Products
(product_id int primary key, product_name varchar(44),Width int, Length int, Height int);

insert into Products Values(1,'LC-TV',5,50,40);
insert into Products Values(2,'LC-Keyboards',5,5,5);
insert into Products Values(3,'LC-Phone',2,10,10);
insert into Products Values(4,'LC-T-Shirt',4,10,20);

-- Write an SQL query to report, How much cubic feet of volume does the inventory occupy in each warehouse.

select warehouse.name, sum(units*product_volume) as volume
from warehouse JOIN 
( select product_id, product_name, width*Length*height as product_volume
from Products) as p
ON warehouse.product_id = p.product_id
group by warehouse.name

SELECT a.name AS warehouse_name,
SUM(a.units * b.Width * b.Length * b.Height) AS volume
FROM Warehouse AS a
LEFT JOIN Products AS b
ON a.product_id = b.product_id
GROUP BY a.name;

-- 1581. Customer Who Visited but Did Not Make Any Transactions [Easy]
-- Write an SQL query to find the IDs of the users who visited without making any transactions and the number of times they made these types of visits.
drop table if exists Visits;
create table Visits
(visit_id int primary key, customer_id int);
insert into Visits Values(1,23);
insert into Visits Values(2,9);
insert into Visits Values(4,30);
insert into Visits Values(5,54);
insert into Visits Values(6,96);
insert into Visits Values(7,54);
insert into Visits Values(8,54);

drop table if exists Transactions;
create table Transactions
(transaction_id int primary key, visit_id int, amount int);

insert into Transactions Values(2,5,310);
insert into Transactions Values(3,5,300);
insert into Transactions Values(9,5,200);
insert into Transactions Values(12,1,910);
insert into Transactions Values(13,2,970);


-- my anser WRONG!!
select v.customer_id, count(v.visit_id IS NULL) as count_no_trans
from Visits as v LEFT JOIN Transactions as t ON v.visit_id = t.visit_id -- correct
group by v.customer_id
order by count_no_trans DESC, v.customer_id
-- leetcode
SELECT a.customer_id, COUNT(a.visit_id) AS count_no_trans 
FROM Visits AS a
LEFT JOIN Transactions AS b
ON a.visit_id = b.visit_id
WHERE b.transaction_id IS NULL
GROUP BY a.customer_id;
-- rewrite
select v.customer_id,count(v.visit_id) as count_no_trans
from Visits as v LEFT JOIN Transactions as t ON v.visit_id = t.visit_id -- correct
where t.transaction_id IS NULL
group by v.customer_id
order by count_no_trans DESC, v.customer_id


-- 1587. Bank Account Summary II [Easy]
-- Write an SQL query to report the name and balance of users with a balance higher than 10000. The balance of an account is equal to the sum of the amounts of all transactions involving that account.
select a.name SUM(amount)f as balance
from Users as a JOIN transactions as b ON a.acount = b.account
group by a.name
Having sum(amount) > 10000

-- 1596. Most Frequent Products of Each Customer [Medium]
drop table if exists Customers;
create table Customers
(customer_id int primary key, name varchar(55));
insert into Customers Value(1,'Alice');
insert into Customers Value(2,'Bob');
insert into Customers Value(3,'Tom');
insert into Customers Value(4,'Jerry');
insert into Customers Value(5,'John');

drop table if exists Products;
Create table Products
(product_id int primary key, product_name varchar(45),price int);

insert into Products Values(1,'keyboard',120);
insert into Products Values(2,'mouse',80);
insert into Products Values(3,'screen',600);
insert into Products Values(4,'hard disk',450); 

-- Write an SQL query to find the most frequently ordered product(s) for each customer.

-- The result table should have the product_id and product_name for each customer_id who ordered at least one order. Return the result table in any order.

-- my code wrong!!
select customer_id,product_id,product_name
from (select c.customer_id,o.product_id, p.product_name, rank() over( order by count(p.product_name) ) as rnk
from Orders as o JOIN products as p ON o.product_id=p.product_id
                 JOIN customers as c ON o.customer_id=c.customer_id 
group by c.customer_id,o.product_id,p.product_name ) as t
where rnk = 1

-- leetcode:
WITH

tmp AS (
SELECT a.customer_id, b.product_id, c.product_name,
COUNT(b.order_id) OVER(PARTITION BY a.customer_id, b.product_id) AS freq -- caculate the purchase frequency
FROM Customers AS a
JOIN Orders AS b
ON a.customer_id = b.customer_id
JOIN Products AS c
ON b.product_id = c.product_id
),

tmp1 AS (
SELECT customer_id, product_id, product_name, freq,
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY freq DESC) AS rnk
FROM tmp
)

SELECT DISTINCT customer_id, product_id, product_name FROM tmp1
WHERE rnk = 1;




-- 1607. Sellers With No Sales [Easy]
-- Write an SQL query to report the names of all sellers who did not make any sales in 2020.
select seller_name 
from Seller
where seller_id NOT IN ( 
select DISTINCT seller_id 
from Orders 
where sale_date BETWEEN '2020-01-01' and '2020-12-31'
)
order  by seller_name

-- 1613. Find the Missing IDs [Medium]
drop table if exists Customers;
create table Customers
(customer_id int primary key, name varchar(55));
insert into Customers Value(1,'Alice');
insert into Customers Value(4,'Bob');
insert into Customers Value(5,'Charlie');
-- Write an SQL query to find the missing customer IDs. The missing IDs are ones that are not in the Customers table but are in the range between 1 and the maximum customer_id present in the table.
-- Notice that the maximum customer_id will not exceed 100.

WITH RECURSIVE id_seq AS (
SELECT 1 as continued_id
UNION 
SELECT continued_id + 1
FROM id_seq
WHERE continued_id < (SELECT MAX(customer_id) FROM Customers) 
)

SELECT continued_id AS ids
FROM id_seq
WHERE continued_id NOT IN (SELECT customer_id FROM Customers)
ORDER BY ids;  

with RECURSIVE id_seq AS
(select 1 as id 
UNION 
select id + 1 from id_seq  where id < (SELECT max(customer_id) FROM Customers)
)

select id 
from id_seq
where id  NOT IN (SELECT customer_id FROM Customers)
		
		

-- 1623. All Valid Triplets That Can Represent a Country [Easy]
-- There is a country with three schools, where each student is enrolled in exactly one school. The country is joining a competition and wants to select one student from each school to represent the country such that:
create table SchoolA
(sutdent_id int, student_name varchar(55));
insert into SchoolA Values(1,'Alice');
insert into SchoolA Values(2,'Bob');

create table SchoolB
(sutdent_id int, student_name varchar(55));
insert into SchoolB Values(3,'Tom');

create table SchoolC
(sutdent_id int, student_name varchar(55));
insert into SchoolC Values(3,'Tom');
insert into SchoolC Values(2,'Jerry');
insert into SchoolC Values(10,'Alice');


SELECT a.student_name AS 'member_A',
b.student_name AS 'member_B',
c.student_name AS 'member_C'
FROM SchoolA AS a
JOIN SchoolB AS b
ON a.sutdent_id <> b.sutdent_id
AND a.student_name <> b.student_name
JOIN SchoolC AS c
ON a.sutdent_id <> c.sutdent_id
AND b.sutdent_id <> c.sutdent_id
AND a.student_name <> c.student_name
AND b.student_name <> c.student_name;