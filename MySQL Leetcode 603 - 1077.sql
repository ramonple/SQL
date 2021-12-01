-- 603 Consecutive Available Seats [Easy]
create table cinema
(seat_id int, free int,
primary key (seat_id));


insert into cinema VALUES (1,1);
insert into cinema VALUES (2,0);
insert into cinema VALUES (3,1);
insert into cinema VALUES (4,1);
insert into cinema VALUES (5,1);

-- Can you help to query all the consecutive available seats order by the seat_id using the following cinema table?

-- Note:

-- The seat_id is an auto increment int, and free is bool ('1' means free, and '0' means occupied.).
-- Consecutive available seats are more than 2(inclusive) seats consecutively available.

-- my answer (use the approach from Q 601)
WITH
AP as (
select a.seat_id as A, b.seat_id as B
from cinema a LEFT JOIN cinema b ON a.seat_id=b.seat_id -1
where a.free = 1 and b.free =1 ),

SP as (
select A as seat from AP. -- at first attempt, I make a mistake here. We should notice FROM should be the table defiend before
UNION 
select B as seat from AP
)

select seat_id
from cinema
where seat_id IN (select seat from SP);

-- Leetcode answer
SELECT DISTINCT a.seat_id
FROM cinema AS a JOIN cinema AS b
ON ABS(a.seat_id - b.seat_id) = 1. -- first time see this, as in this question, there is no date, no particular sequence 
                                  -- through abs(xx-xx) = 1 we can make sure these two seats are con
AND a.free = 1 AND b.free = 1
ORDER BY a.seat_id;
-- through this approach, we dont need to do the UNION step

-- it seems this can also be used for two consecutive thing. I applied it to Q601, where with 3 consecutive date, it does not work.
select distinct a.seat_id
from cinema a JOIN cinema b ON abs(a.seat_id-b.seat_id) = 1
where a.free = 1 and b.free = 1

-- 607 Sales Person [Easy]
create table salesperson
(sales_id int, name varchar(15), salary int, commission_rate int,hire_date DATE,
primary key (sales_id) );

insert into salesperson Values(1,'John',100000,6,'4.1.2006');
insert into salesperson Values(2,'Amy',120000,5,'5.1.2010');
insert into salesperson Values(3,'Mark',65000,12,'25.12.2008');
insert into salesperson Values(4,'Pam',25000,25,'1.1.2005');
insert into salesperson Values(5,'Alex',50000,10,'2.3.2007');

create table company 
(com_id int, name varchar(55), city varchar(55),
primary key (com_id) );

insert into company VALUES (1,'Red','Boston');
insert into company VALUES (2,'Orange','New York');
insert into company VALUES (3,'Yellow','Boston');
insert into company VALUES (4,'Green','Austin');

drop table if exists orders
create table orders
(order_id int Primary KEY, 
order_date DATE,
com_id int,
sales_id int,
amount int);

insert into orders values (1,'1.1.2014',3,4,100000);
insert into orders values (2,'2.1.2014',4,5,5000);
insert into orders values (3,'3.1.2014',1,1,50000);
insert into orders values (4,'4.1.2014',1,4,25000);

-- Output all the names in the table salesperson, who didn’t have sales to company 'RED'.

select distinct salesperson.name
from salesperson LEFT JOIN orders ON orders.sales_id = salesperson.sales_id
group by salesperson.name
Having orders.com_id NOT IN
(select company.com_id AS red_id
from company
where company.name='RED') -- find out the id of red 
OR 
orders.com_id IS NULL
-- why wrong answer? 
-- my answer:
Amy
Mark
Pam
Alex
-- correct answer
Amy
Mark
Alex

select s.name,s.sales_id
from salesperson s
where s.sales_id not in 
    (select o.sales_id
    from orders o
    left join company c on o.com_id = c.com_id
    where c.name = 'RED')


select sales_id,name
from salesperson
where sales_id NOT IN(
select orders.sales_id
from orders JOIN company ON orders.com_id = company.com_id
where company.name='Red')
		
		
-- 608 Tree Node [Medium]
create table tree
(id int, p_id int,
primary key (id) );  -- p_id is its parent node's id.

insert into tree values(1,null);
insert into tree values(2,1);
insert into tree values(3,1);	
insert into tree values(4,2);	
insert into tree values(5,2);

-- Each node in the tree can be one of three types:

-- Leaf: if the node is a leaf node.
-- Root: if the node is the root of the tree.
-- Inner: If the node is neither a leaf node nor a root node.

-- Write a query to print the node id and the type of the node. Sort your output by the node id. The result for the above sample is:

select id, 
CASE WHEN p_id IS NULL THEN 'Root'
      WHEN id NOT IN (select DISTINCT p_id from tree where p_id is NOT NULL) THEN 'leaf'
			ELSE 'Inner' 
   END AS Type
from tree
-- it seems like we can have only one 'ELSE' in When clause

select id,
(Case when p_id is NULL THEN 'Root'
     when id NOT IN (select p_id from tree where p_id IS NOT NULL ) THEN 'LEAF' 
		 else 'INNER' END ) as TYPE
from tree

select id,
(Case when p_id is NULL then 'Root'
      when id IN  (select p_id from tree where p_id IS NOT NULL) THEN 'INNER'
			ELSE 'LEAF' END ) as TYPE
from tree

-- 610 Triangle Judgement [Easy]
create table triangle
(x int, y int, z int);

insert into triangle VALUES (13,15,30);
insert into triangle VALUES (10,20,15);
-- A pupil Tim gets homework to identify whether three line segments could possibly form a triangle.

-- However, this assignment is very heavy because there are hundreds of records to calculate.
select x,y,z,
( Case when x+y> z and x+z>y AND y+z > x then 'Yes' ELSE 'No' END )AS triangle
from triangle

-- Another approach
select *, 
    IF(x + y > z AND x + z > y AND y + z > x, 'Yes', 'No') as triangle 
    FROM triangle;
		
		-- SELECT IF(500<1000, "YES", "NO");
		
-- 612 Shortest Distance in a Plane [Medium]
create table point_2d
(x int, y int);
-- Table point_2d holds the coordinates (x,y) of some unique points (more than two) in a plane.
insert into point_2d Values (-1,-1);
insert into point_2d Values (0,0);
insert into point_2d Values (-1,-2);
-- find out the shortest distance between two points

-- !! I have no idea two to deal with this!!
-- for the relationship inside a table should use the 'self join'

select  DISTINCT ( POWER(a.x-b.x,2) + POWER(a.y-b.y,2)) as shortest
from point_2d as a
JOIN point_2d as b
ON a.x<>b.x OR a.y<>b.y. -- focus on this condition
order by shortest
LIMIT 1
-- POWER( base, exponent )

SELECT
ROUND(MIN(SQRT(POW(a.x - b.x, 2) + POW(a.y - b.y, 2))),2) AS shortest
FROM point_2d AS a
JOIN point_2d AS b
ON a.x <> b.x OR a.y <> b.y;

-- 613 Shortest Distance in a Line [Easy]
create table point (x int);
insert into point VALUES(-1);
insert into point VALUES(0);
insert into point VALUES(2);

-- Write a query to find the shortest distance between two points in these points.
-- The shortest distance is '1' obviously, which is from point '-1' to '0'. So the output is as below:
select MIN( POWER(a.x-b.x,2)) As 'shortest'
from point a JOIN point b ON a.x<>b.x

-- WRONG!!!! these two are on a line. The distance should be |x1-x2|!!
select min(abs(a.x-b.x)) As 'shortest'
from point a JOIN point b ON a.x<>b.x

-- 614 Second Degree Follower [Medium]
create table follow 
(followee varchar(1),follower varchar(1));

insert into follow VALUES('A','B');
insert into follow VALUES('B','C');
insert into follow VALUES('B','D');
insert into follow VALUES('D','E');

-- Please write a SQL query to get the amount of each follower’s follower if he/she has one.

SELECT a.follower, COUNT(DISTINCT b.follower) AS num 
FROM follow AS a LEFT JOIN follow AS b 
ON a.follower = b.followee
WHERE b.followee IS NOT NULL
GROUP BY a.follower
ORDER BY a.follower;

select a.follower AS follower,count(distinct b.follower) as num
FROM follow AS a LEFT JOIN follow AS b 
ON a.follower = b.followee
where b.follower is not null
group by a.follower


-- 615 Average Salary: Departments VS Company [Hard]
drop table if exists salary;
create table salary(id int, employee_id int, amount int, pay_date DATE,
primary key (id),
foreign key(employee_id) references employee(employee_id) );

drop table if exists employee;
create table employee 
(employee_id int, department_id int,
primary key (employee_id));

insert into employee values (1,1);
insert into employee values (2,2);
insert into employee values (3,2);
insert into salary Values (1,1,9000,'2017-03-31');
insert into salary Values (2,2,6000,'2017-03-31');
insert into salary Values (3,3,10000,'2017-03-31');
insert into salary Values (4,1,7000,'2017-02-28');
insert into salary Values (5,2,6000,'2017-02-28');
insert into salary Values (6,3,8000,'2017-02-28');

 -- write a query to display the comparison result (higher/lower/same) of the average salary of employees in a department to the company's average salary.
 
select department_salary.pay_month, department_id,
    case
        when department_avg>company_avg then 'higher'
        when department_avg<company_avg then 'lower'
        else 'same'
    end as comparison
from
    (
      select department_id, avg(amount) as department_avg, date_format(pay_date, '%Y-%m') as pay_month
      from salary join employee on salary.employee_id = employee.employee_id
      group by department_id, pay_month
    ) as department_salary
join
    (
      select avg(amount) as company_avg,  date_format(pay_date, '%Y-%m') as pay_month 
        from salary 
        group by date_format(pay_date, '%Y-%m')
    ) as company_salary
on department_salary.pay_month = company_salary.pay_month

--
	-- average salary company
	select avg(amount) as com_avg, date_format(pay_date,'%Y-%m') as pay_month
	from salary
	group by date_format(pay_date,'%Y-%m') 
	
	-- average department
	select department_id, avg(amount) as dep_avg, date_format(pay_date,'%Y-%m') as pay_month
	from salary JOIN employee ON salary.employee_id = employee.employee_id
	group by department_id,date_format(pay_date,'%Y-%m')
--
--

select  department_salary.pay_month, department_id,
( CASE WHEN department_salary.dep_avg > company_salary. com_avg Then 'Higher'
     WHEN department_salary.dep_avg < company_salary. com_avg Then 'Lower'
		 ELSE 'Same' END ) as comparison
from 
(	select avg(amount) as com_avg, date_format(pay_date,'%Y-%m') as pay_month
	from salary
	group by date_format(pay_date,'%Y-%m')  ) as company_salary
	JOIN 
( select department_id, avg(amount) as dep_avg, date_format(pay_date,'%Y-%m') as pay_month
	from salary JOIN employee ON salary.employee_id = employee.employee_id
	group by department_id,date_format(pay_date,'%Y-%m') ) as  department_salary
ON company_salary.pay_month =  department_salary.pay_month

-- 618 Students Report By Geography [Hard]
drop table if exists student;
-- A U.S graduate school has students from Asia, Europe and America. The students' location information are stored in table student as below.
create table student
(name varchar(15), continent varchar(15));

insert into student values('Jack','America');
insert into student values('Pascal','Europe');
insert into student values('Xi','Asia');
insert into student values('Jane','America');

-- Pivot the continent column in this table so that each name is sorted alphabetically 
-- and displayed underneath its corresponding continent. 
-- The output headers should be America, Asia and Europe respectively. 
-- It is guaranteed that the student number from America is no less than either Asia or Europe.


-- How to pivot table? -- USE row_number
SELECT
    MAX(CASE WHEN continent = 'America' THEN name else NULL END) AS America,  -- must be null, cannot be 0
    MAX(CASE WHEN continent = 'Asia' THEN name else NULL  END) AS Asia,
    MAX(CASE WHEN continent = 'Europe' THEN name else NULL   END) AS Europe
FROM (
    SELECT 
        continent,
        name,
        ROW_NUMBER() OVER(PARTITION BY continent ORDER BY name) as rn
    FROM student
) x
GROUP BY rn -- group by rn!!!!!! because for each continent, the rn is unique

-- if we group by name
America  Asia  Europe 
Jack	   null   null	
Jane		 null   null
null    	Xi	  null
null     nul   Pascal


-- 619 Biggest Single Number [Easy]
create table my_number
(num int);

insert into my_number VALUES(8);
insert into my_number VALUES(8);
insert into my_number VALUES(3);
insert into my_number VALUES(3);
insert into my_number VALUES(1);
insert into my_number VALUES(4);
insert into my_number VALUES(5);
insert into my_number VALUES(6);

--  Can you write a SQL query to find the biggest number, which only appears once.
select x.num
from
(
select num, count(num) as cnt
from my_number
group by num
order by num DESC) as x
where x.cnt = 1
limit 1

-- leetcode
SELECT MAX(num) AS num FROM
(
SELECT num FROM my_number
GROUP BY num
HAVING COUNT(*) = 1
) AS x;


-- 620 Not Boring Movies [Easy]
-- X city opened a new cinema, many people would like to go to this cinema. The cinema also gives out a poster indicating the movies’ ratings and descriptions.
drop table if exists cinema ;

create table cinema 
(id int, movie varchar(15), description varchar(30), rating decimal(10,2), -- not integer, should be decimal
primary key (id) );

insert into cinema values(1,'war','greate 3D',8.9);
insert into cinema values(2,'science','fiction',8.5);
insert into cinema values(3,'irish','boring',6.2);
insert into cinema values(4,'ice song','Fantacy',8.6);
insert into cinema values(5,'house card','interesting',9.1);

-- Please write a SQL query to output movies with an odd numbered ID and a description that is not 'boring'. Order the result by rating.
select *
from cinema 
where description NOT LIKE '%boring%' 
      AND
			(ID % 2) <> 0
order by rating DESC

-- problem: when creating table, remind how many decimals want to use

SELECT * FROM cinema
WHERE MOD(id , 2) = 1 AND description <> 'boring'
ORDER BY rating DESC;


-- 626 Exchange Seats [Medium]

-- Mary is a teacher in a middle school and she has a table seat storing students' names and their corresponding seat ids.
drop table if exists seat;
create table seat
(id int, student varchar(15),
primary key (id) );

insert into seat values(1,'Abbot');
insert into seat values(2,'Doris');
insert into seat values(3,'Emerson');
insert into seat values(4,'Green');
insert into seat values(5,'Jeames');

-- Mary wants to change seats for the adjacent students.
-- Can you write a SQL query to output the result for Mary?
-- Note: If the number of students is odd, there is no need to change the last one's seat.

select
(CASE when (select max(id) from seat)%2 = 1 and id = (select max(id) from seat) then id
when id%2 = 1 then id+1
else id -1
end) as id,student
from seat
order by id

select 
(CASE when MOD(id, 2) != 0 and id = (select max(id) from seat) then id
      when MOD(id, 2) != 0 and id <> (select max(id) from seat) then id+1
else id -1
end) as id,student
from seat
order by id



-- Given a table salary, such as the one below, that has m=male and f=female values.

drop table if exists salary;
create table salary
(id int, name varchar(1),sex varchar(1),salary int,
primary key (id) );
-- Swap all f and m values (i.e., change all f values to m and vice versa) with a single update statement and no intermediate temp table.
-- Note that you must write a single update statement, DO NOT write any select statement for this problem
insert into salary values (1,'A','m',2500);
insert into salary values (2,'B','f',1500);
insert into salary values (3,'C','m',5500);insert into salary values (4,'D','f',500);

Update salary
set sex = (CASE when sex = 'm' then 'f' else 'm' end)

-- 1045 Customers Who Bought All Products [Medium]
drop table if exists product;
create table product
(product_key int primary key);

insert into product VALUES (5);
insert into product VALUES (6);

drop table if exists customer;
create table customer
(customer_id int,
product_key int,
foreign key (product_key) references product(product_key) );

insert into customer Values(1,5);
insert into customer Values(2,6);
insert into customer Values(3,5);
insert into customer Values(3,6);
insert into customer Values(1,6);

-- Write an SQL query for a report that provides the customer ids from the Customer table that bought all the products in the Product table.

-- my code
select customer_id
from customer
group by customer_id
Having count(*) =
(
select sum(num)
from
(select count(product_key) as num
from product
group by product_key) as a)


-- leetcode:
SELECT b.customer_id 
FROM Product AS a LEFT JOIN Customer AS b ON a.product_key = b.product_key
GROUP BY b.customer_id
HAVING COUNT(DISTINCT b.product_key) = (SELECT COUNT(*) FROM Product);


-- calculate number of product type
select count(distinct product_key)
from product

-- update my code to
select customer_id
from customer
group by customer_id
Having count(*) = (select count(distinct product_key)
                   from product )
								 

-- 1050 Actors and Directors Who Cooperated At Least Three Times [Easy]

-- Write a SQL query for a report that provides the pairs (actor_id, director_id) where the actor have cooperated with the director at least 3 times.

drop table if exists ActorDirector;
create table ActorDirector
(actor_id int, director_id int, timestamp int primary key);

insert into ActorDirector Values ( 1,1,0);
insert into ActorDirector Values ( 1,1,1);
insert into ActorDirector Values ( 1,1,2);
insert into ActorDirector Values ( 1,2,3);
insert into ActorDirector Values ( 1,2,4);
insert into ActorDirector Values ( 2,1,5);
insert into ActorDirector Values ( 2,1,6);

SELECT actor_id, director_id FROM ActorDirector
GROUP BY actor_id, director_id
HAVING COUNT(timestamp) >= 3;

-- 1068 Product Sales Analysis I [Easy] 1069 Product Sales Analysis II [Easy] 1070 Product Sales Analysis III [Medium]
-- 1068
drop table if exists customer;
drop table if exists product;
create table product
(product_id int, product_name varchar(55),
primary key (product_id) );
drop table if exists sales;
create table sales
(sale_id int, product_id int, year int, quantity int, price int,
primary key (sale_id,year),   
foreign key (product_id) references  product(product_id)         );

insert into product values(100,'Nokia');
insert into product values(200,'Apple');
insert into product values(300,'Samsung');

insert into Sales values(1,100,2008,10,5000);
insert into Sales values(2,100,2009,12,5000);
insert into Sales values(7,200,2011,15,9000);

 -- 1068 Write an SQL query that reports all product names of the products in the Sales table along with their selling year and price.
 -- my code:
 select product_name, year,price
 from sales JOIN product ON sales.product_id = product.product_id
 -- leetcode:
 SELECT b.product_name, a.year,  a.price
FROM Sales AS a
LEFT JOIN Product AS b
ON a.product_id = b.product_id;

-- 1069 Product Sales Analysis II [Easy]

-- Write an SQL query that reports the total quantity sold for every product id.
select product.product_id,sum(quantity)
from sales RIGHT JOIN product ON sales.product_id = product.product_id
group by product.product_id

SELECT product_id, SUM(quantity) AS total_quantity
FROM Sales
GROUP BY product_id;

-- 1070 Product Sales Analysis III [Medium]
-- Write an SQL query that selects the product id, year, quantity, and price for the first year of every product sold.

-- my answer:
select product_id, year as first_year, quantity, price
from sales
where (product_id, year) IN 
( select product_id, min(year) as year
from sales
group by product_id)

-- discussion
SELECT s.product_id, s.year AS first_year, s.quantity, s.price 
FROM (
SELECT *, DENSE_RANK() OVER (PARTITION BY product_id ORDER BY year ASC) AS rnk FROM sales
) AS s 
WHERE rnk=1;

-- 1075 Project Employees I [Easy]   1076 Project Employees II [Easy]  1077 Project Employees III [Medium]
drop table if exists project;
create table project
(project_id int, employee_id int,
primary key (project_id,employee_id),
foreign key (employee_id) references employee(employee_id));


drop table if exists employee;
create table employee
(employee_id int, name varchar(55),experience_years int,
primary key (employee_id) );

insert into project values(1,1);
insert into project values(1,2);
insert into project values(1,3);
insert into project values(2,1);
insert into project values(2,4);

insert into employee values(1,'Khaled',3);
insert into employee values(2,'Ali',2);
insert into employee values(3,'John',1);
insert into employee values(4,'Doe',2);

-- 1075 Project Employees I [Easy]  
-- Write an SQL query that reports the average experience years of all the employees for each project, rounded to 2 digits.

select p.project_id, avg(e.experience_years) as average_years
from employee as e JOIN project as p ON e.employee_id = p.employee_id
group by p.project_id

--  1076 Project Employees II [Easy]
-- Write an SQL query that reports all the projects that have the most employees.

-- my answer:
select p.project_id
from employee as e JOIN project as p ON e.employee_id = p.employee_id
group by p.project_id
order by sum(e.employee_id) DESC
Limit 1

-- from discussion
select a.project_id
from (
select project_id, RANK () Over(order by COUNT(employee_id) DESC) as r
from project  
group by project_id
) as a
where a.r=1


-- 1077 Project Employees III [Medium]

-- Write an SQL query that reports the most experienced employees in each project. In case of a tie, report all employees with the maximum number of experience years.

-- my answer:
select project.project_id, employee.employee_id
from employee  JOIN project ON employee.employee_id = project.employee_id
where  (project.project_id, employee.experience_years) IN
(
select p.project_id,max(e.experience_years) 
from employee as e JOIN project as p ON e.employee_id = p.employee_id
group by p.project_id   ) ; -- we know the max experience years in each project, but we don't know the corresponding employee
 -- my answer:
select project.project_id, employee.employee_id
from employee  JOIN project ON employee.employee_id = project.employee_id
where  (project.project_id, employee.experience_years) IN
(
select p.project_id
       RANK () OVER (partition by  p.project_id order by experience_years DESC) as r
from employee as e JOIN project as p 
       ON e.employee_id = p.employee_id ) ; 
			 
-- Leetcode			 
WITH t AS (
SELECT a.project_id, a.employee_id, RANK() OVER(PARTITION BY a.project_id ORDER BY b.experience_years DESC) AS exp
FROM Project AS a
LEFT JOIN Employee AS b
ON a.employee_id = b.employee_id
)
SELECT project_id, employee_id
FROM t
WHERE exp = 1;
