create Database Summary
Use Summary -- how to call a already built database

-- 175. Combine Two Tables
# how to create the table
Create Table Person (
PersonId int,
lastName varchar(255),
firstName varchar(255),
Primary Key (PersonId)
);

create Table Address
(addressId int,
PersonId int,
city varchar(255),
state varchar(255),
Primary Key (addressId),
Foreign Key (PersonId) References Person(PersonId)
);

Insert INTO Person Values (1,'San','Zhang');
Insert INTO Person Values (2,'Si','Li');

Insert INTO Address Values('291',1,'New York City','New York');
Insert INTO Address Values ('518',2,'Lang Fang','He Bei')

Delete From Address Where addressid = 518

-- Write an SQL query to report the first name, last name, city, and state of each person in the Person table. 
-- If the address of a personId is not present in the Address table, report 'null' instead.
select firstname, lastname,city,state
From Person LEFT JOIN Address
ON Person.PersonId=Address.PersonId
-- !! To show NULL pls use 'Left JOIN'

-- Return the result table in any order.
select firstname, lastname,city,state
From Person LEFT JOIN Address
ON Person.PersonId=Address.PersonId
Order by firstName



 -- 176. Second Highest Salary
 Create Table Employee (
 id int,
 salary int,
 Primary Key (id)
 )
 
 Insert INTO Employee Values (1,100); -- Notice, should be ; instead of ,
 Insert INTO Employee Values (2,200);
 Insert INTO Employee Values (3,300);
 Insert INTO Employee Values (4, 500);
 Insert INTO Employee Values (5,1500);
 Insert INTO Employee Values (6,700);
 Insert INTO Employee Values (8,950);

select id,salary
from Employee
Order by Salary
limit 1
offset 1
-- However, this solution will be judged as 'Wrong Answer' if there is no such second highest salary since there might be only one record in this table. 
-- To overcome this issue, we can take this as a temp table.

SELECT
    IFNULL(
      (SELECT DISTINCT Salary
       FROM Employee
       ORDER BY Salary DESC
        LIMIT 1 OFFSET 1),
    NULL) AS SecondHighestSalary


-- 177. Nth Highest Salary
Insert INTO Employee Values (2, 200);
Insert INTO Employee Values (3,300);
Insert INTO Employee Values (5, 900);
-- Write an SQL query to report the nth highest salary from the Employee table. 
-- If there is no nth highest salary, the query should report null.

-- provided:
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT -- INT here is the data type
BEGIN
  RETURN (
      # Write your MySQL query statement below.
      
  );
END

Drop function if exists getNthHighestSalary

CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
SET N=N-1;
  RETURN (
      # Write your MySQL query statement below.
      SELECT
        IFNULL(
          (SELECT DISTINCT salary
          FROM Employee
          ORDER BY salary DESC
          LIMIT 1 OFFSET N),
            NULL) AS nthhisghestsalary
  );
END

-- have no idea why it cannot be runned in mysql, but it works online


-- 178 Rank Scores
Drop Table if exists Scores

Create Table Scores
(id int, score decimal(10,2), Primary Key (id));

Insert INTO Scores Values( 1, 3.5);
Insert INTO Scores Values( 2, 3.65);
Insert INTO Scores Values( 3, 4.0);
Insert INTO Scores Values( 4, 3.85);
Insert INTO Scores Values( 5, 4.00);
Insert INTO Scores Values( 6, 3.65);

select score, Dense_RANK() OVER (order by score DESC) as "RANK"
from scores

-- 180. Consecutive Numbers
Drop Table if exists Logs

Create Table Logs
(id int,num varchar(255), Primary Key (id) )

Insert INTO Logs Values(1,1);
Insert INTO Logs Values(2,1);
Insert INTO Logs Values(3,1);
Insert INTO Logs Values(4,2);
Insert INTO Logs Values(5,1);
Insert INTO Logs Values(6,2);
Insert INTO Logs Values(7,2);

-- Answer from LeetCode
select DISTINCT l1.num AS consecutiveNumbers
from logs as l1,
     logs as l2,
	  	logs as l3
Where l1.id = l2.id - 1
AND l2.id=l3.id-1
And l1.num=l2.num
And l2.num=l3.num

-- Answer from Discussion
SELECT DISTINCT t.num AS ConsecutiveNums
FROM
(
SELECT Num AS num, LEAD(Num) OVER (ORDER BY Id) AS 'lead', LAG(Num) OVER (ORDER BY Id) AS 'lag'
From Logs
) AS t
WHERE t.num = t.lead and t.num = t.lag
-- LEAD() is a window function
-- by using the LEAD() function, from the current row, you can access the data of the [following] row
-- LAG: by using the LAG() function, from the current row, you can access data of the [previous] row
-- LAG (scalar_expression [,offset] [,default])  
 --  OVER ( [ partition_by_clause ] order_by_clause ) 
 -- offset
-- The number of rows back from the current row from which to obtain a value. 
-- If not specified, the default is 1. 
-- default
-- The value to return when offset is beyond the scope of the partition. 
-- If a default value is not specified, NULL is returned.

-- 181. Employees Earning More Than Their Managers
Drop table if exists employee;
Create table employee
( id int, name varchar(255), Salary int, ManagerId int, 
primary key (id) );

Insert INTO employee Values (1,'Joe',7000,3);
Insert INTO employee Values (2,'Henry',8000,4);
Insert INTO employee Values (3,'Sam',6000,NULL);
Insert INTO employee Values (4,'Max',9000,NULL);

select a.name as Name
from employee as a JOIN employee as b
On a.managerId=b.id
Where a.salary > b.salary

-- 182. Duplicate Emails
Drop table if exists Person2;

Create Table Person2
(id int,email varchar(255),Primary key (id));

INSERT INTO Person2 VALUES (1,'a@b.com');
INSERT INTO Person2 VALUES (2,'c@b.com');
INSERT INTO Person2 VALUES (3,'a@b.com');

select Email, count(Email) as num
from Person2
Group by Email
having num > 1

select email from person2
group by email
having count(email) > 1

-- 183. Customers Who Never Order
drop table if exists Customers;
Create table Customers
(id int, name varchar(255), Primary Key (id));

drop table if exists Orders;
Create table Orders
(id int, customerId int, Primary Key (id), Foreign Key (customerId) References Customers(id) );
-- Write an SQL query to report all customers who never order anything.
INSERT INTO Customers Values(1,'Joe');
INSERT INTO Customers Values(2,'Henry');
INSERT INTO Customers Values(3,'Sam');
INSERT INTO Customers Values(4,'Max');

INSERT INTO Orders Values (1,3);
INSERT INTO Orders Values (2,1);


select customers.id
from customers
where customers.id NOT IN (
select customers.id
from customers JOIN orders ON customers.id=orders.customerid)
