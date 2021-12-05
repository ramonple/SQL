-- 1308. Running Total for Different Genders [Medium]

drop table if exists scores;
create table scores
(player_name varchar(55),gender varchar(5), day date, score_points int,
primary key (gender, day) );

insert into scores Values ('Aron','F','2020-01-01',17);
insert into scores Values ('Alice','F','2020-01-07',23);
insert into scores Values ('Bajrang','M','2020-01-07',7);
insert into scores Values ('Khali','M','2019-12-025',11);
insert into scores Values ('Slaman','M','2019-12-30',13);
insert into scores Values ('Joe','M','2019-12-31',3);
insert into scores Values ('Jose','M','2019-12-18',2);
insert into scores Values ('Priya','F','2019-12-31',23);
insert into scores Values ('Priyanka','F','2019-12-30',17);

-- Write an SQL query to find the total score for each gender at each day.

-- Order the result table by gender and day

select gender, day, SUM(score_points) OVER(PARTITION BY gender ORDER BY day) AS total -- why need the partition by?
from scores 
group by day, gender
order by gender, day


-- 1321. Restaurant Growth [Medium]
-- You are the restaurant owner and you want to analyze a possible expansion (there will be at least one customer every day).
-- Write an SQL query to compute moving average of how much customer paid in a 7 days window (current day + 6 days before) .
drop table if exists Customer;
create table Customer
(customer_id int, name varchar(55), visited_on date, amount int,
primary key (customer_id, visited_on));

insert into Customer values(1,'jhon','2019-01-01',100);
insert into Customer values(2,'Daniel','2019-01-02',110);
insert into Customer values(3,'jade','2019-01-03',120);
insert into Customer values(4,'Khaled','2019-01-04',130);
insert into Customer values(5,'Winston','2019-01-05',110);
insert into Customer values(6,'Elvis','2019-01-06',140);
insert into Customer values(7,'Anna','2019-01-07',150);
insert into Customer values(8,'Maria','2019-01-08',80);
insert into Customer values(9,'Jaze','2019-01-09',110);
insert into Customer values(1,'jhon','2019-01-10',130);
insert into Customer values(3,'jade','2019-01-10',150);

-- confused -- needs to really understand the requirement of this question
-- compute moving average of how much customer paid in a 7 days window ???!!!
WITH t AS
(
SELECT visited_on, 
ROW_NUMBER() OVER(ORDER BY visited_on) AS rn,
SUM(SUM(amount)) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND current row) AS amount
FROM Customer
GROUP BY visited_on
)

SELECT visited_on, amount, ROUND(amount/7,2) AS average_amount
FROM t
WHERE rn >= 7;

-- notice, there are more than one customers on 2019-01-10. 
-- if we direcly use sum, we will have two columns, it should be SUM( SUM(amount) )
-- ROW 6 PRECEDING


-- self join approach
select a.visited_on, 
    sum(b.amount) amount,
    round(sum(b.amount)/7,2) average_amount
from (select visited_on, sum(amount) amount from Customer GROUP BY visited_on) a, 
    (select visited_on, sum(amount) amount from Customer GROUP BY visited_on) b 
where datediff(a.visited_on,b.visited_on) between 0 and 6
group by a.visited_on
having count(distinct b.visited_on) = 7;

-- 1322. Ads Performance [Easy]
drop table if exists Ads;
create table Ads
(ad_id int, user_id int, action enum('Clicked', 'Viewed', 'Ignored'),
primary key (ad_id, user_id) );

insert into Ads values(1,1,'Clicked');
insert into Ads values(2,2,'Clicked');
insert into Ads values(3,3,'Viewed');
insert into Ads values(5,5,'Ignored');
insert into Ads values(1,7,'Ignored');
insert into Ads values(2,7,'Viewed');
insert into Ads values(3,5,'Clicked');
insert into Ads values(1,4,'Viewed');
insert into Ads values(2,11,'Viewed');
insert into Ads values(1,2,'Clicked');

-- A company is running Ads and wants to calculate the performance of each Ad.
-- Performance of the Ad is measured using Click-Through Rate (CTR) where:
-- Write an SQL query to find the ctr of each Ad.


select t.ad_id, IFNULL( ROUND(a.clicktime/b.totalTime,2),0) as ctr
from 
(select ad_id from Ads group by ad_id) as t
LEFT JOIN
( select ad_id, IFNULL(count(ad_id),0) as clicktime
from Ads
where action = 'Clicked'
group by ad_id) as a ON t.ad_id = a.ad_id
JOIN
( select ad_id, count(ad_id) as totalTime
from Ads
where action = 'Clicked' OR action = 'Viewed'
group by ad_id) as b
On a.ad_id = b.ad_id
order by ctr DESC, ad_id

-- how to keep the one without click+ view


select ad_id,
    (case when clicks+views = 0 then 0 else round(clicks/(clicks+views)*100, 2) end) as ctr
from 
    (select ad_id,
        sum(case when action='Clicked' then 1 else 0 end) as clicks,
        sum(case when action='Viewed' then 1 else 0 end) as views
    from Ads
    group by ad_id) as t
order by ctr desc, ad_id asc


select ad_id, (case when total = 0 THEN 0 ELSE  round(clocks*100/total,2) end) as ctr
from
(
select ad_id,
sum( CASE WHEN action = 'Clicked' then 1 else 0 end ) as clocks,
sum(CASE WHen action IN ('Clicked','Viewed') Then 1 else 0 end) as total
from Ads
group by ad_id ) as a
order by ctr desc, ad_id asc


-- 1327. List the Products Ordered in a Period [Easy]


Create table Products 
( product_id int, product_name varchar(40), product_category varchar(40),
primary key (product_id));

Create table Orders 
( product_id int, order_date date, unit int,
foreign key (product_id) references products(product_id) );

insert into Products  values (1, 'Leetcode Solutions', 'Book');
insert into Products  values (2, 'Jewels of Stringology', 'Book');
insert into Products values (3, 'HP', 'Laptop');
insert into Products  values (4, 'Lenovo', 'Laptop');
insert into Products  values (5, 'Leetcode Kit', 'T-shirt');

 insert into Orders ( product_id, order_date , unit ) values (1, '2020-02-05', 60);
insert into Orders ( product_id , order_date , unit ) values (1, '2020-02-10', 70);
insert into Orders ( product_id , order_date , unit ) values (2, '2020-01-18', 30);
insert into Orders ( product_id , order_date , unit ) values (2, '2020-02-11', 80);
insert into Orders ( product_id , order_date , unit ) values (3, '2020-02-17', 2);
insert into Orders ( product_id , order_date , unit ) values (3, '2020-02-24', 3);
insert into Orders ( product_id , order_date , unit ) values (4, '2020-03-01', 20);
insert into Orders ( product_id , order_date , unit ) values (4, '2020-03-04', 30);
insert into Orders ( product_id , order_date , unit) values (4, '2020-03-04', 60);
insert into Orders ( product_id , order_date , unit ) values (5, '2020-02-25', 50);
insert into Orders ( product_id , order_date , unit ) values (5, '2020-02-27', 50);
insert into Orders (product_id , order_date , unit ) values (5, '2020-03-01', 50);

-- Write an SQL query to get the names of products with greater than or equal to 100 units ordered in February 2020 and their amount.

select products.product_name, sum(orders.unit) as amount
from products JOIN orders
     ON products.product_id = orders.product_id
where order_date BETWEEN '2020-02-01' AND '2020-02-29'
group by products.product_name
Having amount>= 100

-- 1336. Number of Transactions per Visit [Hard]
drop table if exists Vists;
create table Visits
(user_id int, visit_date date,
primary key (user_id, visit_date));

insert into Visits values(1,'2020-01-01');
insert into Visits values(2,'2020-01-02');
insert into Visits values(12,'2020-01-01');
insert into Visits values(19,'2020-01-03');
insert into Visits values(1,'2020-01-02');
insert into Visits values(2,'2020-01-03');
insert into Visits values(1,'2020-01-04');
insert into Visits values(7,'2020-01-11');
insert into Visits values(9,'2020-01-25');
insert into Visits values(8,'2020-01-28');

drop table if exists transactions;
create table transactions
(user_id int, transaction_date date,amount int,
foreign key (user_id, transaction_date) references Visits(user_id, visit_date) );

insert into transactions values(1,'2020-01-02',120);
insert into transactions values(2,'2020-01-03',22);
insert into transactions values(7,'2020-01-11',232);
insert into transactions values(1,'2020-01-04',7);
insert into transactions values(9,'2020-01-25',33);
insert into transactions values(9,'2020-01-25',66);
insert into transactions values(8,'2020-01-28',1);
insert into transactions values(9,'2020-01-25',99);

-- transaction_count 是一次访问完成的交易数，取值区间为 0 至 一个或多个用户完成最多交易数（transactions_count）
-- visits_count 是一次访问银行交易次数为 transaction_count 的用户数。

-- A bank wants to draw a chart of the number of transactions bank visitors did in one visit to the bank 
-- and the corresponding number of visitors who have done this number of transaction in one visit.
-- Write an SQL query to find how many users visited the bank and didn't do any transactions, how many visited the bank and did one transaction and so on.

-- The result table will contain two columns:

-- transaction_count which is the number of transactions done in one visit.
-- visits_count which is the corresponding number of users who did transaction_count in one visit to the bank.
-- transaction_count should take all values from 0 to max(transaction_count) done by one or more users.

-- Order the result table by transaction_count.

select a.transaction_count, count(transaction_count) as visits_count
from 
(select v.user_id, v.visit_date,count(t.transaction_date) as transaction_count
from Visits as v LEFT JOIN transactions as t
     ON v.user_id = t.user_id AND v.visit_date = t.transaction_date
group by v.user_id,v.visit_date) as a
group by transaction_count

-- leetcode:
WITH 
continuous AS (
SELECT ROW_NUMBER() OVER() AS transactions_count FROM Transactions
UNION 
SELECT 0 AS transactions_count
), -- how many transactions can we have. from 0 to the maximum row number of transaction

trans AS (
SELECT a.user_id, a.visit_date, 
IFNULL(COUNT(amount) OVER(PARTITION BY a.user_id, a.visit_date), 0) AS transactions_count
FROM Visits AS a
LEFT JOIN Transactions AS b
ON a.user_id = b.user_id AND a.visit_date = b.transaction_date
) -- how many transactions each user on each vist -- the one I obtained above

SELECT b.transactions_count, IFNULL(COUNT(DISTINCT a.user_id, a.visit_date), 0) AS visits_count
FROM trans AS a 
RIGHT JOIN continuous AS b
ON a.transactions_count = b.transactions_count
GROUP BY b.transactions_count
HAVING b.transactions_count <= (SELECT MAX(transactions_count) FROM trans)
ORDER BY 1;


-- 1341. Movie Rating [Medium]

create table Movies
(movie_id int, title varchar(55),
primary key (movie_id));

insert into Movies Values(1,'Avengers');
insert into Movies Values(2,'Frozen 2');insert into Movies Values(3,'Joker');

drop table if exists users;
create table Users
(user_id int, name varchar(55),
primary key (user_id) );

insert into users values(1,'Daniel');
insert into users values(2,'Monica');
insert into users values(3,'Maria');
insert into users values(4,'James');

create table Movie_rating
(movie_id int, user_id int, rating int, created_at date,
primary key (movie_id,user_id) );

insert into Movie_rating Values(1,1,3,'2020-01-12');
insert into Movie_rating Values(1,2,4,'2020-02-11');
insert into Movie_rating Values(1,3,2,'2020-02-12');
insert into Movie_rating Values(1,4,1,'2020-01-01');
insert into Movie_rating Values(2,1,5,'2020-02-17');
insert into Movie_rating Values(2,2,2,'2020-02-01');
insert into Movie_rating Values(2,3,2,'2020-03-01');
insert into Movie_rating Values(3,1,3,'2020-02-22');
insert into Movie_rating Values(3,2,4,'2020-02-25');


-- Find the name of the user who has rated the greatest number of http://movies.In case of a tie, return lexicographically smaller user name.
-- Find the movie name with the highest average rating in February 2020.In case of a tie, return lexicographically smaller movie name.

(SELECT name AS results FROM Users AS a
JOIN Movie_Rating AS b
ON a.user_id = b.user_id
GROUP BY b.user_id
ORDER BY COUNT(DISTINCT movie_id) DESC, name 
LIMIT 1 )
UNION ALL
(SELECT title AS results FROM Movies AS a
JOIN Movie_Rating AS b
ON a.movie_id = b.movie_id
WHERE b.created_at Between '2020-02-02' and '2020-02-28'
GROUP BY b.movie_id
ORDER BY AVG(b.rating) DESC, title ASC
LIMIT 1);



-- 1350. Students With Invalid Departments [Easy]
-- Write an SQL query to find the id and the name of all students who are enrolled in departments that no longer exists.
SELECT a.id, a.name FROM Students AS a
LEFT JOIN Departments AS b
ON a.department_id = b.id
WHERE b.id iS NULL;



-- 1355. Activity Participants [Medium]
drop table if exists Friends;
create table Friends
(id int, name varchar(55),activity varchar(55),
primary key (id));
insert into Friends values(1,'Jonathan D.','Eating');
insert into Friends values(2,'Jade W.','Singing');
insert into Friends values(3,'Victor J.','Singing');
insert into Friends values(4,'Elvis Q.','Eating');
insert into Friends values(5,'Daniel A.','Eating');
insert into Friends values(6,'Bob B.','Horse Riding');
drop table if exists Activities;
create table Activities
(id int primary key, name varchar(55));
insert into Activities Values(1,'Eating');
insert into Activities Values(2,'Singing');
insert into Activities Values(3,'Horse Riding');

-- Write an SQL query to find the names of all the activities with neither maximum, nor minimum number of participants.
-- Return the result table in any order. Each activity in table Activities is performed by any person in the table Friends.


select tmp.name as Activitiy
from
( select a.id,a.name, count(f.id) as num
from Activities as a JOIN Friends as f
on a.name = f.activity
group by a.id, a.name
order by num ) as tmp
where tmp.num <>1
and tmp.num <>
(select count(name)
from Activities)


with 
temp AS
(select activity, COUNT(activity) as num
from Friends
Group by activity)

select activity from temp
where num!=(select max(num) from temp)
and num!=(select min(num) from temp)


-- 1364. Number of Trusted Contacts of a Customer [Medium]

drop table if exists Customers;
create table Customers
(customer_id int primary key, customer_name varchar(55), email varchar(55));

insert into Customers values(1,'Alice','alice@leetcode.com');
insert into Customers values(2,'Bob','bob@leetcode.com');
insert into Customers values(13,'John','john@leetcode.com');
insert into Customers values(6,'Alex','alex@leetcode.com');

drop table if exists Contacts;
create table Contacts
(user_id int, contact_name varchar(55),contact_email varchar(55),
primary key (user_id,contact_email) );

insert into Contacts values(1,'Bob','bob@leetcode.com');
insert into Contacts values(1,'John','john@leetcode.com');
insert into Contacts values(1,'Jal','jal@leetcode.com');
insert into Contacts values(2,'Omar','omar@leetcode.com');
insert into Contacts values(2,'Meir','meir@leetcode.com');
insert into Contacts values(6,'Alice','alice@leetcode.com');

drop table if exists Invoices;
create table Invoices
(invoice_id int primary key, price int, user_id int);

insert into Invoices Values(77,100,1);
insert into Invoices Values(88,200,1);
insert into Invoices Values(99,300,2);
insert into Invoices Values(66,400,2);
insert into Invoices Values(55,500,13);
insert into Invoices Values(44,60,6);


-- Write an SQL query to find the following for each invoice_id：

-- customer_name: The name of the customer the invoice is related to.
-- price: The price of the invoice.
-- contacts_cnt: The number of contacts related to the customer.
-- trusted_contacts_cnt: The number of contacts related to the customer and at the same time they are customers to the shop. (i.e His/Her email exists in the Customers table.)
-- Order the result table by invoice_id.

SELECT a.invoice_id, b.customer_name, a.price,
IFNULL(COUNT(c.user_id), 0) AS contacts_cnt,
SUM(CASE WHEN c.contact_email IN (SELECT DISTINCT email FROM Customers) THEN 1 ELSE 0 END) AS trusted_contacts_cnt
FROM Invoices AS a
LEFT JOIN Customers AS b
ON a.user_id = b.customer_id
LEFT JOIN Contacts AS c
ON a.user_id = c.user_id
GROUP BY a.invoice_id, b.customer_name, a.price
ORDER BY a.invoice_id;



-- 1369. Get the Second Most Recent Activity 【Hard]
drop table if exists UserActivity;
create table UserActivity
(username varchar(55), activity varchar(55), startDate date, endDate date);

insert into UserActivity Values('Alice','Travel','2020-02-12','2020-02-20');
insert into UserActivity Values('Alice','Dacing','2020-02-21','2020-02-23');
insert into UserActivity Values('Alice','Travel','2020-02-24','2020-02-28');
insert into UserActivity Values('BOb','Travel','2020-02-11','2020-02-18');

-- Write an SQL query to show the second most recent activity of each user.
-- If the user only has one activity, return that one.
-- A user can't perform more than one activity at the same time. Return the result table in any order.


select a.username, a.activity, a.startDate, a.endDate
from
( select username, activity , startDate, endDate, rank() over (partition by username order by startDate DESC) as rk
from UserActivity ) as a
where a.rk=2

UNION
-- how to find only has one activity
select username, activity, startDate, endDate
from UserActivity
where username IS IN (
select username
from UserActivity
group by username
having count(username) = 1)

-- leetcode:
WITH

tmp AS(
SELECT username, activity, startDate, endDate,
ROW_NUMBER() OVER(PARTITION BY username ORDER BY startDate DESC) AS rnk,
COUNT(activity) OVER(PARTITION BY username) AS num -- we can add this column
FROM UserActivity 
)

SELECT DISTINCT username, activity, startDate, endDate FROM tmp 
WHERE 
CASE WHEN num = 1 THEN rnk = 1
ELSE rnk = 2
END;

-- my name
select a.username, a.activity, a.startDate, a.endDate
from
( select username, activity , startDate, endDate, rank() over (partition by username order by startDate DESC) as rk, count(activity) over(partition by username) as num
from UserActivity ) as a
where CASE WHEN num = 1 then rk = 1 else rk=2 end


-- 1378. Replace Employee ID w/ The Unique Identifier [easy]
drop table employees;
create table employees
(id int primary key, name varchar(55));

insert into employees values (1,'alice');
insert into employees values (7,'Bob');
insert into employees values (11,'Meir');
insert into employees values (90,'Winston');
insert into employees values (3,'Honathan');

create table EmployeeUNI
(id int, unique_id int,
primary key (id, unique_id));
insert into EmployeeUNI value(3,1);
insert into EmployeeUNI value(11,2);
insert into EmployeeUNI value(90,3);

-- Write an SQL query to show the unique ID of each user, If a user doesn't have a unique ID replace just show null.
select IFNULL (employeeUNI.unique_id,NULL),employees.name
from Employees LEFT JOIN employeeUNI
on employees.id=employeeUNI.id
order by name


-- 1384. Total Sales Amount by Year [Hard]
drop table if exists sales;
drop table if exists Product;
create table Product
(product_id int primary key, product_name varchar(55));
insert into Product Values(1,'LC Phone');
insert into Product Values(2,'LC T-shirt');
insert into Product Values(3,'LC Keychain');

drop table if exists Sales;
create table Sales
(product_id int primary key, period_start varchar(55),period_end date, average_daily_sales int);
insert into Sales Values(1,'2019-01-25','2019-02-28',100);
insert into Sales Values(2,'2018-12-01','2020-01-01',10);
insert into Sales Values(3,'2019-12-01','2020-01-31',1);

-- Write an SQL query to report the Total sales amount of each item for each year, 
-- with corresponding product name, product_id, product_name and report_year.
-- Dates of the sales years are between 2018 to 2020. Return the result table ordered by product_id and report_year.

WITH 

cte AS(
SELECT product_id, '2018' AS report_year,
       CASE
       WHEN period_start >= '2019-01-01' THEN 0
       WHEN period_end < '2019-01-01' AND period_start < '2019-01-01' THEN  DATEDIFF(period_end, period_start)+1 -- start and both in year 2018
       ELSE DATEDIFF('2019-01-01', period_start) -- start < 2019-01-01 and end >2019-01-01. Start in 2018 and does not end in 2018
       END AS days_in_year,
       average_daily_sales
FROM Sales 
    
UNION 
    
SELECT product_id, '2019' AS report_year,
       CASE
       WHEN period_start >='2020-01-01' THEN 0
       WHEN period_end < '2020-01-01' AND period_start > '2018-12-31' THEN  DATEDIFF(period_end, period_start)+1 -- start in year 2019 and ends in 2019
       WHEN period_end < '2020-01-01' AND period_start <= '2018-12-31' THEN DATEDIFF(period_end, '2018-12-31') -- start in 2018 adn ends in 2019
       WHEN period_end >= '2020-01-01' AND period_start > '2018-12-31' THEN  DATEDIFF('2020-01-01', period_start) -- does not end in 2019 and start in 2019
       ELSE DATEDIFF('2020-01-01', '2019-01-01') -- start in 2018 ends later 2019
       END AS days_in_year,
       average_daily_sales
FROM Sales 

UNION 
    
SELECT product_id, '2020' AS report_year,
       CASE
       WHEN period_start >= '2020-01-01' THEN  DATEDIFF(period_end, period_start)+1 -- start in 2020 and ends in 2020
       WHEN period_end <'2020-01-01' THEN 0 -- ends before 2020
       ELSE DATEDIFF(period_end, '2019-12-31') -- start before 2020 and ends in 2020
       END AS days_in_year,
       average_daily_sales
FROM Sales 
)

SELECT c.product_id, 
       p.product_name,  
       c.report_year,
       c.days_in_year*c.average_daily_sales AS total_amount
FROM cte AS c
JOIN Product AS p ON c.product_id = p.product_id 
WHERE c.days_in_year > 0
ORDER BY 1, 3;



-- 1393. Capital Gain/Loss [Medium]

create table Stocks
(stock_name varchar(55),operation enum('Sell', 'Buy'),operation_day int, price int,
primary key (stock_name, operation_day) );
insert into Stocks Values('LeetCode','Buy',1,1000);
insert into Stocks Values('Corona Masks','Buy',2,10);
insert into Stocks Values('Leetcode','Sell',5,9000);
insert into Stocks Values('HandBags','Buy',17,30000);
insert into Stocks Values('Corona Masks','Sell',3,1010);
insert into Stocks Values('Corona Masks','Buy',4,1000);
insert into Stocks Values('Corona Masks','Sell',5,500);
insert into Stocks Values('Corona Masks','Buy',6,1000);
insert into Stocks Values('HandBags','Sell',29,7000);
insert into Stocks Values('Corona Masks','Sell',10,10000);

-- Write an SQL query to report the Capital gain/loss for each stock.
-- The capital gain/loss of a stock is total gain or loss after buying and selling the stock one or many times.
-- Return the result table in any order.


select buy.stock_name, sell.earn-buy.pay as captical_gain_loss
from
( select a.stock_name as stock_name,sum(a.price) as pay
from 
(select stock_name, price
from Stocks
where operation='Buy') as a
group by  a.stock_name ) as buy
JOIN
(
select b.stock_name as stock_name,sum(b.price) as earn
from (
select stock_name, price
from Stocks
where operation='Sell') as b
group by b.stock_name) as sell
On buy.stock_name = sell.stock_name
order by captical_gain_loss DESC

-- leetcode:
SELECT stock_name,
SUM(CASE WHEN operation = 'Sell' THEN price ELSE (-1) * price END) AS capital_gain_loss
FROM Stocks
GROUP BY stock_name;



