-- 1398. Customers Who Bought Product A and B but Not C [Medium]

drop table if exists Customers;
create table Customers
(customer_id int primary key, customer_name varchar(55));
Insert into Customers Values(1,'Daniel');
Insert into Customers Values(2,'Diana');
Insert into Customers Values(3,'Elizabeth');
Insert into Customers Values(4,'Jhon');

drop table if exists Orders;
create table orders
(order_id int primary key, customer_id int, product_name varchar(55));
insert into Orders Values(10,1,'A');
insert into Orders Values(20,1,'B');
insert into Orders Values(30,1,'D');
insert into Orders Values(40,1,'C');
insert into Orders Values(50,2,'A');
insert into Orders Values(60,3,'A');
insert into Orders Values(70,3,'B');
insert into Orders Values(80,3,'D');
insert into Orders Values(90,4,'C');

-- Write an SQL query to report the customer_id and customer_name of customers who bought products 
-- "A", "B" but did not buy the product "C" since we want to recommend them buy this product.
-- Return the result table ordered by customer_id.

-- my answer
select  DISTINCT Customers.customer_name, Customers.customer_id
from Customers JOIN orders On Customers.customer_id = Orders.customer_id
where customers.customer_id IN (
select customer_id 
from Orders 
where product_name = 'A' )
AND customers.customer_id IN (
select customer_id 
from Orders 
where product_name ='B')
AND customers.customer_id NOT IN
(
select customer_id 
from Orders 
where product_name = 'C')

-- leetcode
SELECT c.customer_id, c.customer_name
FROM customers AS c
WHERE EXISTS(SELECT * FROM orders WHERE customer_id = c.customer_id AND product_name = 'A')
AND EXISTS(SELECT * FROM orders WHERE customer_id = c.customer_id AND product_name = 'B')
AND NOT EXISTS(SELECT * FROM orders WHERE customer_id = c.customer_id AND product_name = 'C')
ORDER BY c.customer_id;

-- 1407. Top Travellers [Easy]
drop table if exists Users;
create table Users
(id int primary key, name varchar(55));

insert into Users Values(1,'Alice');
insert into Users Values(2,'Bob');
insert into Users Values(3,'Alex');
insert into Users Values(4,'Donald');
insert into Users Values(7,'Lee');
insert into Users Values(13,'Jonathan');
insert into Users Values(19,'Elvis');

drop table Rides;
create table Rides
(id int primary key, user_id int , distance int);
insert into Rides Values(1,1,120);
insert into Rides Values(2,2,317);
insert into Rides Values(3,3,222);
insert into Rides Values(4,7,100);
insert into Rides Values(5,13,312);
insert into Rides Values(6,19,50);
insert into Rides Values(7,7,120);
insert into Rides Values(8,19,400);
insert into Rides Values(9,7,230);

-- Write an SQL query to report the distance travelled by each user.
-- Return the result table ordered by travelled_distance in descending order, 
-- if two or more users travelled the same distance, order them by their name in ascending order.

SELECT a.name, IFNULL(SUM(b.distance), 0) as travelled_distance
FROM Users AS a
LEFT JOIN Rides AS b ON a.id = b.user_id
GROUP BY a.name
order by travelled_distance DESC,a.name


-- 1412. Find the Quiet Students in All Exams [Hard]

drop table if exists Student;
Create table Student
(student_id int primary key, student_name varchar(55));

insert into Student Values(1,'Daniel');
insert into Student Values(2,'Jade');
insert into Student Values(3,'Stella');
insert into Student Values(4,'Jonathan');
insert into Student Values(5,'Will');

drop table if exists Exam;
create table Exam
(exam_id int, student_id int, score int,
primary key (exam_id,student_id));
insert into Exam Values(10,1,70);
insert into Exam Values(10,2,80);
insert into Exam Values(10,3,90);
insert into Exam Values(20,1,80);
insert into Exam Values(30,1,70);
insert into Exam Values(30,3,80);
insert into Exam Values(30,4,90);
insert into Exam Values(40,1,60);
insert into Exam Values(40,2,70);
insert into Exam Values(40,4,80);

-- A "quite" student is the one who took at least one exam and didn't score neither the high score nor the low score.

-- Write an SQL query to report the students (student_id, student_name) being "quiet" in ALL exams.

-- Don't return the student who has never taken any exam. Return the result table ordered by student_id.



select student_id, student_name
from student
where student_id NOT IN (
select distinct student_id
from
( select  student_id, rank() over (partition by exam_id order by score) as rk
from Exam) as bottom
where bottom.rk=1) 
AND student_id NOT IN (
select distinct student_id
from
( select  student_id, rank() over (partition by exam_id order by score DESC) as rp
from Exam) as top
where top.rp=1)
AND student_id IN 
(
select student_id
from Exam
group by student_id
having count(student_id) > 0 ) -- at least one exam

-- leetcode:
WITH

tmp AS (
SELECT exam_id, student_id, score,
MAX(score) OVER(PARTITION BY exam_id) AS max_score,
MIN(score) OVER(PARTITION BY exam_id) AS min_score
FROM Exam
),

tmp1 AS (
SELECT DISTINCT a.student_id, a.student_name FROM Student AS a
JOIN tmp AS b
ON a.student_id = b.student_id
WHERE b.score = b.max_score OR b.score = b.min_score

)

SELECT DISTINCT a.student_id, a.student_name FROM Student AS a
JOIN Exam AS b
ON a.student_id = b.student_id
WHERE a.student_id NOT IN (SELECT student_id FROM tmp1)
ORDER BY a.student_id;









-- 1435. Create a Session Bar Chart [Easy]

drop table if exists Sessions;
create table sessions
(session_id int primary key, duration int);
insert into Sessions Values(1,30);
insert into Sessions Values(2,199);
insert into Sessions Values(3,299);
insert into Sessions Values(4,580);
insert into Sessions Values(5,1000);

-- You want to know how long a user visits your application. 
-- You decided to create bins of "[0-5>", "[5-10>", "[10-15>" and "15 minutes or more" and count the number of sessions on it.
-- Write an SQL query to report the (bin, total) in any order.

select 
SUM(CASE WHEN duration>=0 and duration < 0 Then 1 else 0 end) as '[0-5>',
SUM(CASE WHEN duration>=5 and duration < 10 Then 1 else 0 end) as '[5-10>',
SUM(CASE WHEN duration>=10 and duration <15 Then 1 else 0 end) as '[10-15>',
SUM(CASE WHEN duration>=15 Then 1 else 0 end) as '15 or more'
from Sessions


-- leetcode
WITH 

tmp AS (
SELECT session_id, duration,
CASE WHEN duration/60 < 5 THEN '[0-5>'
     WHEN duration/60 >=5 AND duration/60 < 10 THEN '[5-10>'
     WHEN duration/60 >=10 AND duration/60 < 15 THEN '[10-15>'
     ELSE '15 or more'
     END AS bin
FROM Sessions
),

tmp1 AS (
SELECT '[0-5>' AS bin
UNION
SELECT '[5-10>' AS bin
UNION
SELECT '[10-15>' AS bin
UNION
SELECT '15 or more' AS bin
)

SELECT a.bin, IFNULL(COUNT(b.session_id),0) AS total
FROM tmp1 AS a
LEFT JOIN tmp AS b
ON a.bin = b.bin
GROUP BY a.bin;


-- 1440. Evaluate Boolean Expression [Medium]
create table Variables
(name varchar(55) primary key, value int);
insert into Variables Values('x',66);
insert into Variables Values('y',77);

drop table if exists Expression;
create table Expression
(left_operand varchar(55), operator enum('<', '>', '='), right_operand varchar(55)
);

insert into Expression Values('x','>','y');
insert into Expression Values('x','<','y');
insert into Expression Values('x','=','y');
insert into Expression Values('y','>','x');
insert into Expression Values('y','<','X');
insert into Expression Values('y','=','x');

-- Write an SQL query to evaluate the boolean expressions in Expressions table.

-- Return the result table in any order.

-- The query result format is in the following example.


-- Have NO idea
SELECT a.left_operand, a.operator, a.right_operand, 
CASE WHEN b.value > c.value AND a.operator = '>' THEN 'true'
WHEN b.value = c.value AND a.operator = '=' THEN 'true'
WHEN b.value < c.value AND a.operator = '<' THEN 'true'
ELSE 'false' END AS value
FROM Expression AS a
LEFT JOIN Variables AS b ON a.left_operand = b.name
LEFT JOIN Variables AS c ON a.right_operand = c.name;



-- 1445. Apples & Oranges
drop table if exists Sales;
create table Sales
(sale_date date, fruit enum('apples','oranges'), sold_num int,
Primary key (sale_date,fruit) );
insert into Sales Values('2020-05-01','apples',10);
insert into Sales Values('2020-05-01','oranges',8);
insert into Sales Values('2020-05-02','apples',15);
insert into Sales Values('2020-05-02','oranges',15);
insert into Sales Values('2020-05-03','apples',20);
insert into Sales Values('2020-05-03','oranges',0);
insert into Sales Values('2020-05-04','apples',15);
insert into Sales Values('2020-05-04','oranges',16);

-- Write an SQL query to report the difference between number of apples and oranges sold each day.

-- Return the result table ordered by sale_date in format ('YYYY-MM-DD').


SELECT a.sale_date, a.sold_num-b.sold_num as diff
FROM (
SELECT sale_date, fruit, sold_num FROM Sales
WHERE fruit = 'apples'
) AS a
LEFT JOIN (
SELECT sale_date, fruit, sold_num FROM Sales
WHERE fruit = 'oranges'
) AS b
ON a.sale_date = b.sale_date
order by a.sale_date



-- 1454. Active Users [Medium]

create table Accounts
(id int primary key, name varchar(55));

insert into Accounts Values(1,'Winston');
insert into Accounts Values(7,'Jonathan');

create table Logins
(id int, login_date date);
insert into Logins Values(7,'2020-05-30');
insert into Logins Values(1,'2020-05-30');
insert into Logins Values(7,'2020-05-31');
insert into Logins Values(7,'2020-06-01');
insert into Logins Values(7,'2020-06-02');
insert into Logins Values(7,'2020-06-02');
insert into Logins Values(7,'2020-06-03');
insert into Logins Values(1,'2020-06-07');
insert into Logins Values(7,'2020-06-10');

-- Write an SQL query to find the id and the name of active users.

-- Active users are those who logged in to their accounts for 5 or more consecutive days.

-- Return the result table ordered by the id.

select a.id,a.name
from Accounts as a JOIN Logins as l1
     ON a. id = l1.id
group by l1.id
having count(l.id)>=5

-- consecutive days!!!

WITH

tmp AS(
SELECT a.id, a.name, b.login_date,
ROW_NUMBER() OVER(PARTITION BY a.id ORDER BY b.login_date) AS rnk, 
DATEDIFF(b.login_date, '2020-01-01') AS diff 
FROM Accounts AS a
LEFT JOIN (
SELECT DISTINCT id, login_date FROM Logins
) AS b
ON a.id = b.id
)

SELECT DISTINCT id, name FROM tmp
GROUP BY id, name, diff-rnk -- use diff-rank to check whether continuous or not
HAVING COUNT(login_date) >= 5;



-- 1459. Rectangles Area [Medium]

create table points
(id int primary key, x_value int, y_value int);
insert into points Values(1,2,8);
insert into points Values(2,4,7);
insert into points Values(3,2,10);

-- Write an SQL query to report of all possible rectangles which can be formed by any two points of the table.
-- Each row in the result contains three columns (p1, p2, area) where:
-- p1 and p2 are the id of two opposite corners of a rectangle and p1 < p2.
-- Area of this rectangle is represented by the column area.
-- Report the query in descending order by area in case of tie in ascending order by p1 and p2.

-- p1 should be less than p2 and area greater than 0.
-- p1 = 1 and p2 = 2, has an area equal to |2-4| * |8-7| = 2.
-- p1 = 2 and p2 = 3, has an area equal to |4-2| * |7-10| = 6.
-- p1 = 1 and p2 = 3 It's not possible because the rectangle has an area equal to 0-- .


-- cannot understand this question
SELECT a.id AS p1, b.id AS p2, 
ABS(a.x_value - b.x_value) * ABS(a.y_value - b.y_value) AS area
FROM Points AS a
LEFT JOIN Points AS b
ON a.id < b.id
WHERE ABS(a.x_value - b.x_value) <> 0 
AND ABS(a.y_value - b.y_value) <> 0
ORDER BY area DESC, p1, p2;


-- 1468. Calculate Salaries [Medium]
drop table if exists Salaries;
create table Salaries
(company_id int, employee_id int, employee_name varchar(55), salary int,
primary key (company_id,employee_id) );

insert into Salaries Values(1,1,'Tony',2000);
insert into Salaries Values(1,2,'Pronub',21300);
insert into Salaries Values(1,3,'Tyrrrox',10800);
insert into Salaries Values(2,1,'Pam',300);
insert into Salaries Values(2,7,'Bassem',450);
insert into Salaries Values(2,9,'Hermione',700);
insert into Salaries Values(3,7,'Bocaben',100);
insert into Salaries Values(3,2,'Ognjen',2200);
insert into Salaries Values(3,13,'Nyancat',3300);
insert into Salaries Values(3,15,'Morninngcat',2866);

-- Write an SQL query to find the salaries of the employees after applying taxes.
-- The tax rate is calculated for each company based on the following criteria:

-- 0% If the max salary of any employee in the company is less than 1000$.
-- 24% If the max salary of any employee in the company is in the range [1000, 10000] inclusive.
-- 49% If the max salary of any employee in the company is greater than 10000$.
-- Return the result table in any order. Round the salary to the nearest integer.

select company_id, employee_id,employee_name,
( CASE WHEN salary <= 1000 Then salary
     WHEN salary <= 10000 Then salary*(1-0.24)
		 ELSE  salary * (1-0.49) END ) as salary 
from Salaries
order by company_id, employee_id

-- WRONG! bu company!!!
WITH

tmp AS (
SELECT company_id, employee_id, employee_name, salary, 
MAX(salary) OVER(PARTITION BY company_id) AS max_sal
FROM Salaries   
)

SELECT company_id, employee_id, employee_name,
CASE WHEN max_sal < 1000  THEN ROUND(salary) 
WHEN max_sal BETWEEN 1000 AND 10000 THEN ROUND(salary * (1-0.24))
ELSE ROUND(salary * (1-0.49))
END AS salary
FROM tmp;


select a.company_id, a.employee_id,a.employee_name,
( CASE WHEN max_sal <= 1000 Then round(salary)
     WHEN max_sal <= 10000 Then round(salary*(1-0.24))
		 ELSE  round(salary * (1-0.49)) END ) as salary 
from (
select company_id,employee_id,employee_name, salary, MAX(salary) OVER(PARTITION BY company_id) AS max_sal
from salaries) as a
order by company_id, employee_id




-- 1479. Sales by Day of the Week [Hard]

drop table if exists Orders;
Create table Orders
(order_id int, customer_id int, order_date date, item_id varchar(33), quantity int,
primary key (order_id,item_id) );

insert into Orders Values(1,1,'2020-06-01',1,10);
insert into Orders Values(2,1,'2020-06-08',2,10);
insert into Orders Values(3,2,'2020-06-02',1,5);
insert into Orders Values(4,3,'2020-06-03',3,5);
insert into Orders Values(5,4,'2020-06-04',4,1);
insert into Orders Values(6,4,'2020-06-05',5,5);
insert into Orders Values(7,5,'2020-06-05',1,10);
insert into Orders Values(8,5,'2020-06-14',4,5);
insert into Orders Values(9,5,'2020-06-21',3,5);


drop table if exists Items;
create table items
(item_id int primary key, item_name varchar(55),item_category varchar(55));

insert into Items Values(1,'LC Alg.Book','Book');
insert into Items Values(2,'LC DB.Book','Book');
insert into Items Values(3,'LC SmarthPhone','Phone');
insert into Items Values(4,'LC Phone 2020','Phone');
insert into Items Values(5,'LC SmartGlass','Glasses');
insert into Items Values(6,'LC T-shirt XL','T-shirt');

-- You are the business owner and would like to obtain a sales report for category items and day of the week.
-- Write an SQL query to report how many units in each category have been ordered on each day of the week.
-- Return the result table ordered by category.

-- get the day of the week

Select a.item_category as category,
SUM( CASE WHEN DAYOFWEEK(b.order_date) =2 THEN b.quantity ELSE 0 END) as MONDAY,
SUM( CASE WHEN DAYOFWEEK(b.order_date) =3 THEN b.quantity ELSE 0 END) as Tuesday,
SUM( CASE WHEN DAYOFWEEK(b.order_date) =4 THEN b.quantity ELSE 0 END) as Wednesday,
SUM( CASE WHEN DAYOFWEEK(b.order_date) =5 THEN b.quantity ELSE 0 END) as Thursday,
SUM( CASE WHEN DAYOFWEEK(b.order_date) =6 THEN b.quantity ELSE 0 END) as Friday,
SUM( CASE WHEN DAYOFWEEK(b.order_date) =7 THEN b.quantity ELSE 0 END) as Saturday,
SUM( CASE WHEN DAYOFWEEK(b.order_date) =1 THEN b.quantity ELSE 0 END) as Sunday
from items AS a LEFT JOIN Orders as b
on a.item_id=b.item_id
group by a.item_category
order by  a.item_category


-- 1484. Group Sold Products By The Date [Easy]

drop table if exists Activities;
create table Activities
(sell_date date, product varchar(55));
insert into Activities Values('2020-05-30','Headphone');
insert into Activities Values('2020-06-01','Pencil');
insert into Activities Values('2020-06-02','Mask');
insert into Activities Values('2020-05-30','Basketball');
insert into Activities Values('2020-06-01','Bible');
insert into Activities Values('2020-06-02','Mask');
insert into Activities Values('2020-05-30','T-shirt');


-- Write an SQL query to find for each date, the number of distinct products sold and their names.
-- The sold-products names for each date should be sorted lexicographically.
-- Return the result table ordered by sell_date.

select sell_date,count(distinct product),GROUP_CONCAT( DISTINCT product ORDER BY product) AS products
from Activities
group by sell_date

-- 1495. Friendly Movies Streamed Last Month [Easy]

create table TVProgram
(program_date date, content_id int, channel varchar(55),
primary key (program_date, content_id));

insert into TVProgram Values('2020-06-10 08:00',1,'LC-Channel');
insert into TVProgram Values('2020-05-11 12:00',2,'LC-Channel');
insert into TVProgram Values('2020-05-12 12:00',3,'LC-Channel');
insert into TVProgram Values('2020-05-13 14:00',4,'Disney Ch');
insert into TVProgram Values('2020-06-18 14:00',4,'Disney Ch');
insert into TVProgram Values('2020-07-15 16:00',5,'Disney Ch');



drop table if exists Content;
create table Content
(content_id varchar(55) primary key, title varchar(55), Kids_content enum('Y','N'), content_type varchar(55));

insert into Content Values(1,'Leetcode Movie','N','Movies');
insert into Content Values(2,'Alg.for Kids','Y','Seires');
insert into Content Values(3,'Database Sols','N','Series');
insert into Content Values(4,'Aladdin','Y','Movies');
insert into Content Values(5,'Cinderella','Y','Movies');

-- Write an SQL query to report the distinct titles of the kid-friendly movies streamed in June 2020.
-- Return the result table in any order.

select DISTINCT a.title
FROM Content AS a
JOIN TVProgram AS b
ON a.content_id = b.content_id
where a.Kids_content ='Y' and a.content_type='Movies' AND LEFT(b.program_date,7) ='2020-06'



-- 1501. Countries You Can Safely Invest In [Medium]
drop table address;
drop table Person;
create table Person
(id int primary key, name varchar(55),phone_number varchar(55));
insert into Person Values(3,'Jonathan','051-1234567');
insert into Person Values(12,'Elvis','051-7654321');
insert into Person Values(1,'Moncef','212-1234567');
insert into Person Values(2,'Maroua','212-7654321');
insert into Person Values(7,'Meir','971-1234567');
insert into Person Values(9,'Rachel','971-7654321');

drop table if exists Country;
create table Country
(name varchar(55),country_code varchar(44) primary key);
insert into Country Values('Peru','051');
insert into Country Values('Israel','972');
insert into Country Values('Morocco','212');
insert into Country Values('Germany','049');
insert into Country Values('Ethiopia','251');

create table Calls
(caller_id int, callee_id int, duration int);

insert into Calls Values(1,9,33);
insert into Calls Values(2,9,4);
insert into Calls Values(1,2,59);
insert into Calls Values(3,12,102);
insert into Calls Values(3,12,330);
insert into Calls Values(12,3,5);
insert into Calls Values(7,9,13);
insert into Calls Values(7,1,3);
insert into Calls Values(9,7,1);
insert into Calls Values(1,7,7);

-- A telecommunications company wants to invest in new countries. The company intends to invest in the countries where the average call duration of the calls in this country is strictly greater than the global average call duration.
-- Write an SQL query to find the countries where this company can invest.
-- Return the result table in any order.

-- leetcode:
WITH  

tmp AS (
SELECT caller_id AS call_id, duration FROM (
SELECT DISTINCT caller_id, callee_id, duration FROM Calls
) AS a
UNION ALL
SELECT callee_id AS call_id, duration FROM (
SELECT DISTINCT caller_id, callee_id, duration FROM Calls
) AS b)

SELECT a.name AS country FROM Country AS a
LEFT JOIN Person AS b
ON a.country_code = LEFT(b.phone_number, 3)
LEFT JOIN tmp AS c
ON b.id = c.call_id
GROUP BY a.name
HAVING AVG(c.duration) > (SELECT AVG(duration) FROM tmp);


-- 1511. Customer Order Frequency [Easy]
drop table if exists Customers;
create table Customers
(customer_id int primary key, name varchar(55), country varchar(55));
insert into Customers Values(1,'Winston','USA');
insert into Customers Values(2,'Jonathan','Peru');
insert into Customers Values(3,'moustafa','Egypt');

drop table if exists Product;
create table Product
(product_id int primary key, description varchar(55), price int);

insert into Product Values(10,'LC Phone',300);
insert into Product Values(20,'LC T-shirt',10);
insert into Product Values(30,'LC Book',45);
insert into Product Values(40,'LC Keychain',2);


drop table if exists Orders;
create table Orders
(order_id int primary key, customer_id int, product_id int, order_date date, quantity int);

insert into Orders Values(1,1,10,'2020-06-10',1);
insert into Orders Values(2,1,20,'2020-07-01',1);
insert into Orders Values(3,1,30,'2020-07-08',2);
insert into Orders Values(4,2,10,'2020-06-15',2);
insert into Orders Values(5,2,40,'2020-07-01',10);
insert into Orders Values(6,3,20,'2020-06-24',2);
insert into Orders Values(7,3,30,'2020-06-25',2);
insert into Orders Values(9,3,30,'2020-05-08',3);

-- Write an SQL query to report the customer_id and customer_name of customers who have spent at least $100 in each month of June and July 2020.
-- Return the result table in any order.


-- my answer 
select a.customer_id,a.name
from 
(
(select c.customer_id,c.name
from Orders as o JOIN Customers as c on c.customer_id= o.customer_id
                 JOIN Product as p on p.product_id=o.product_id
where o.order_date BETWEEN '2020-06-01' AND '2020-06-30'
group by c.customer_id,c.name
HAVING sum(o.quantity * p.price) >= 100) as a
JOIN
(select c.customer_id,c.name
from Orders as o JOIN Customers as c on c.customer_id= o.customer_id
                 JOIN Product as p on p.product_id=o.product_id
where o.order_date BETWEEN '2020-07-01' AND '2020-07-31'
group by c.customer_id,c.name
HAVING sum(o.quantity * p.price) >= 100) as b
ON a.customer_id = b.customer_id 
) 



-- leetcode:
select customer_id,name from customers
where customer_id IN
(SELECT a.customer_id 
FROM Orders AS a JOIN Product AS b
ON a.product_id = b.product_id
WHERE a.order_date BETWEEN '2020-06-01' AND '2020-06-30'
GROUP BY a.customer_id
HAVING SUM(a.quantity * b.price) >= 100
)
AND customer_id IN
(SELECT a.customer_id 
FROM Orders AS a JOIN Product AS b
ON a.product_id = b.product_id
WHERE a.order_date BETWEEN '2020-07-01' AND '2020-07-31'
GROUP BY a.customer_id
HAVING SUM(a.quantity * b.price) >= 100
)












-- 1517. Find Users With Valid E-Mails [Easy]
drop table if exists Users;
create table Users
(userid int primary key, name varchar(55), mail varchar(55));

insert into Users values(1,'WInston','winston@leetcode.com');
insert into Users values(2,'Jonathan','jonathanisgreat');
insert into Users values(3,'Annabelle','bella-@leetcode.com');
insert into Users values(4,'Sally','sally.cone@leetcode.com');
insert into Users values(5,'Marwan','quarz#2020@leetcode.com');
insert into Users values(6,'David','david69@gamil.com');
insert into Users values(7,'Shapiro','.shapo@leetcode.com');

-- Write an SQL query to find the users who have valid emails.
-- A valid e-mail has a prefix name and a domain where:
-- The prefix name is a string that may contain letters (upper or lower case), digits, underscore '_', period '.' and/or dash '-'. The prefix name must start with a letter.
-- The domain is '@leetcode.com'.

-- my answer, HAVE NO idea how to check whehter starts with letter
select userid,name,mail
from Users
where mail LIKE '%@leetcode%' 

-- leetcode
SELECT * FROM users
WHERE mail REGEXP '^[A-Za-z][a-zA-Z0-9_.-]*@leetcode.com$' -- REGEXP is the operator used when performing regular expression pattern matches.
                                                      -- ^	caret(^) matches Beginning of string
																											-- $	End of string
																											-- [A-Z]	match any upper case letter.
																											-- [a-z]	match any lower case letter
																											-- [0-9]	match any digit from 0 through to 9.
																											-- *	Zero or more instances of string preceding it

      





-- 1527. Patients With a Condition [Easy]
drop table if exists Patients;
create table Patients
(patient_id int primary key, patient_name varchar(55), conditions varchar(55));

insert into Patients Values(1,'Daniel','YFEV COUCH');
insert into Patients Values(2,'Alice','');
insert into Patients Values(3,'BOb','DIAB100 MYOP');
insert into Patients Values(4, 'George','ACNE DIAB100');
insert into Patients Values(5, 'Alain','DIAB201');
-- Write an SQL query to report the patient_id, patient_name all conditions of patients who have Type I Diabetes. Type I Diabetes always starts with DIAB1 prefix

select *
from Patients
where conditions REGEXP 'DIAB1'

select  *
from patients
where conditions LIKE '%DIAB1%'



