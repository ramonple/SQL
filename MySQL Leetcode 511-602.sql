-- Leetcode 511
Use Summary;
-- 511. Game Play Analysis I
Create Table Activity
(player_id int, device_id int, event_date date, games int,
Primary Key (player_id,event_date) );

Insert INTO Activity Values(1,2,'2016-03-01',5);
Insert INTO Activity Values(1,2,'2016-05-02',6);
Insert INTO Activity Values(2,3,'2017-06-25',5);
Insert INTO Activity Values(3,1,'2016-03-02',5);
Insert INTO Activity Values(3,4,'2018-07-03',5);

select player_id, Min( Date(event_date)) As first_login
from Activity
Group by player_id


-- 512. Game Play Analysis II
UPDATE activity
SET games = 1
WHERE event_date ='2017-06-25';

update activity
set games=0
where event_date='2016-03-02';

select player_id, device_id
from activity
where (player_id,event_date) IN (
select player_id, Min(date(event_date)) As first_login
from activity
group by player_id );

select player_id,device_id
from 
(select player_id,device_id,Rank() Over (partition by player_id Order by event_date) as FirstDay
from activity ) as a
where FirstDay = 1;


-- 534. Game Play Analysis III
-- Write an SQL query that reports for each player and date, how many games played so far by the player. 
-- That is, the total number of games played by the player until that date. Check the example for clarity.

-- importance!! how to understand this question. It is asking for the cummulative time.

-- window function SUM () Over (partition by Order by)
select player_id,event_date,sum(games) Over (partition by player_id order by event_date) as game_played_so_far
from activity


-- Using SelfJoin
select a.player_id, a.event_date,sum(b.games)
from activity a join activity b
on a.player_id = b.player_id
where a.event_date >= b.event_date
group by a.player_id, a.event_date
order by a.player_id;


-- 550. Game Play Analysis IV
-- Write an SQL query that reports the fraction of players that logged in again on the day after the day 
-- they first logged in, rounded to 2 decimal places. 
-- In other words, you need to count the number of players that logged in for at least two consecutive days 
-- starting from their first login date, then divide that number by the total number of players.

-- aggreate function and group 
SELECT ROUND(COUNT(DISTINCT b.player_id)/COUNT(DISTINCT a.player_id), 2) AS fraction FROM Activity AS a
LEFT JOIN
(SELECT player_id, MIN(event_date) AS first_login FROM Activity
GROUP BY player_id) AS b
ON a.player_id = b.player_id
AND DATEDIFF(a.event_date, b.first_login) = 1

-- first value window function
SELECT ROUND(COUNT(DISTINCT b.player_id)/COUNT(DISTINCT a.player_id), 2) AS fraction FROM Activity AS a
LEFT JOIN
(SELECT player_id, FIRST_VALUE(event_date) OVER(PARTITION BY player_id ORDER BY event_date) AS first_login FROM Activity) AS b
ON a.player_id = b.player_id
AND DATEDIFF(a.event_date, b.first_login) = 1

-- 569 Median Employee Salary [Hard]
-- Write a SQL query to find the median salary of each company. 
-- Bonus points if you can solve it without using any built-in SQL functions.

drop table if exists employee;

create table employee
(id int, company varchar(255),salary int,
primary key (id) );

INSERT INTO employee VALUES (1,'A',2341);
INSERT INTO employee VALUES (2,'A',341);
INSERT INTO employee VALUES (3,'A',15);
INSERT INTO employee VALUES (4,'A',15314);
INSERT INTO employee VALUES (5,'A',451);
INSERT INTO employee VALUES (6,'A',513);
INSERT INTO employee VALUES (7,'B',15);
INSERT INTO employee VALUES (8,'B',13);
INSERT INTO employee VALUES (9,'B',1154);
INSERT INTO employee VALUES (10,'B',1345);
INSERT INTO employee VALUES (11,'B',1221);
INSERT INTO employee VALUES (12,'B',234);
INSERT INTO employee VALUES (13,'C',2345);
INSERT INTO employee VALUES (14,'C',2645);
INSERT INTO employee VALUES (15,'C',2645);
INSERT INTO employee VALUES (16,'C',2652);
INSERT INTO employee VALUES (17,'C',65);


select id, company, salary
from
(
  select id, company, salary, 
         row_number() over(partition by company order by salary) as rno, -- the rank of each salary in each company
         count(*) over(partition by company) as cnt -- how many staff in each company
  from Employee
) x
WHERE (cnt/2) <= rno AND rno<= (cnt/2) + 1;  -- where rno in (ceil(cnt/2), cnt/2 + 1)

-- 570. Managers with at Least 5 Direct Reports
drop table if exists employee;

create table employee
(id int, name varchar(255), Department varchar(255), ManagerId int,
primary key (id) ) ;

INSERT INTO employee Values (101,'John','A',NULL);
INSERT INTO employee Values (102,'Dan','A',101);
INSERT INTO employee Values (103,'James','A',101);
INSERT INTO employee Values (104,'Amy','A',101);
INSERT INTO employee Values (105,'Anne','A',101);
INSERT INTO employee Values (106,'Ron','B',101);
-- self join

select Name
From employee
where id IN 
(select managerid from employee 
group by managerid
Having count(managerID) >= 5 )

select name
from employee
where id IN
(select managerid from employee 
group by managerid
Having count(managerID) >= 5 )

-- 571 Find Median Given Frequency of Numbers [Hard]
Drop table if exists numbers;
create table numbers
(number int, frequency int,
primary key (number) );

Insert INTO numbers Values (0,7);
Insert INTO numbers Values (1,1);
Insert INTO numbers Values (2,3);
Insert INTO numbers Values (3,1);

-- Write a query to find the median of all numbers and name the result as median. 
-- In this table, the numbers are 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 2, 3, so the median is (0 + 0)/2 = 0.
SELECT AVG(Number) AS median
FROM 
(
select *, SUM(Frequency) OVER (ORDER BY Number) AS cum_sum, -- calculta the cummulative number
          (SUM(Frequency) OVER ())/2.0  AS mid
FROM Numbers
) AS temp
WHERE mid BETWEEN cum_sum - frequency AND cum_sum;

SELECT AVG(Number) AS median
From
(select *, SUM(Frequency) OVER (ORDER BY   Number) AS cum_sum, 
          (sum(frequency) Over () / 2) As mid
FROM Numbers ) as T
Where mid BETWEEN cum_sum - frequency AND cum_sum; -- cum_sum caculate the number is from which position
                                                   -- 5<= mid <= 9, the corresponding number starts from 5th and ends at 9th
-- Use Average to deal with the condition when the number of numbers is event. the median should be 1/2 (x1+x2)

-- 574 Winning Candidate [Medium]

Create table Candidate
(id int, Name varchar(15),
primary key (id));
INsert INTO Candidate Values(1,'A');
INsert INTO Candidate Values(2,'B');
INsert INTO Candidate Values(3,'C');
INsert INTO Candidate Values(4,'D');
INsert INTO Candidate Values(5,'E');

INsert INTO Vote Values(1,2);
INsert INTO Vote Values(2,4);
INsert INTO Vote Values(3,3);
INsert INTO Vote Values(4,2);
INsert INTO Vote Values(5,5);
-- Write a sql to find the name of the winning candidate, the above example will return the winner B.
-- Notes: You may assume there is no tie, in other words there will be only one winning candidate.

-- problem is how to read the vote table. id is the one who votes, and candidate id is the one who gets the vote.
-- for example, id=1 votes to candidate 2.

select Name 
from candidate As A JOIN
(select candidateId,COUNT(*) from Vote
Group by CandidateId
Order by COUNT(*) DESC
LIMIT 1 ) as B
ON a. id=B.candidateid

select Name
From Candidate
WHere id =
(select CandidateId
From VOTE
group by CandidateID
Order by COUNT(*) DESC
LIMIT 1 )

-- 577 Employee Bonus [Easy]
drop table if exists Employee;
Create Table Employee
(empID int, Name varchar(30),supervisor int, salary int,
primary key (empId) );

Create Table Bonus
(empId int, bonus int,
primary KEY (empId) ) ;

Insert into employee Values (1,'John',3,1000);
Insert into employee Values (2,'Dan',3,2000);
Insert into employee Values (3,'Brad',null,3000);
Insert into employee Values (4,'Thomas',3,4000);

Insert into bonus Values (2,500);
Insert into bonus Values (4,2000);

-- Select all employee's name and bonus whose bonus is < 1000.


select employee.name,bonus.bonus
from Employee LEFT JOIN bonus ON employee.empid=bonus.empId
where employee.empid NOT IN (
select empid from Bonus
where bonus >= 1000);


select employee.name, IFNULL(bonus.bonus, null) As Bonus
from Employee LEFT JOIN bonus ON employee.empid=bonus.empId
where employee.empid NOT IN (
select empid from Bonus
where bonus >= 1000);

SELECT a.name, 
b.bonus
FROM Employee AS a
LEFT JOIN Bonus AS b
ON a.empId = b.empId
WHERE b.bonus < 1000 OR b.bonus IS NULL;

-- 578 Get Highest Answer Rate Question [Medium]
create table survey_log
(id int, action varchar(10),question_id int, answer_id int, q_num int, timestap int);

INSERT INTO survey_log Values (5,'show',285,NULL,1,123);
INSERT INTO survey_log Values (5,'answer',285,124124,1,124);
INSERT INTO survey_log Values (5,'show',369,NULL,2,125);
INSERT INTO survey_log Values (5,'skip',369,NULL,2,126);

-- Write a sql query to identify the question which has the highest answer rate.

-- Note:The highest answer rate meaning is: answer number's ratio in show number in the same question.


SELECT question_id AS 'survey_log' -- Leetcode asks for the column name 'survey_log'
FROM survey_log
GROUP BY question_id
ORDER BY COUNT(answer_id) / COUNT(IF(action = 'show', 1, NULL)) DESC
LIMIT 1;
-- clear solution, use # of answer_id to represent how many times this qustion is answered. As null will be treated as 0.


SELECT question_id AS 'survey_log' -- Leetcode asks for the column name 'survey_log'
FROM survey_log
GROUP BY question_id
ORDER BY COUNT(answer_id)/ COUNT(IF(action = 'show', 1, NULL)) DESC
LIMIT 1;


-- COUNT(IF(action = 'show', 1, NULL)) can be repressed as:

select question_id as 'survery_log'
from survey_log
group by question_id
Order by COUNT(answer_id) / SUM(CASE WHEN action = 'show' THEN 1 ELSE 0 END) DESC
LIMIT 1


SELECT question_id AS survey_log
FROM
(SELECT question_id,
        SUM(case when action="answer" THEN 1 ELSE 0 END) AS num_answer,
        SUM(case when action="show" THEN 1 ELSE 0 END) AS num_show  
	FROM survey_log
	GROUP BY question_id
) AS tbl
ORDER BY (num_answer / num_show) DESC
LIMIT 1



-- 579 Find Cumulative Salary of an Employee [Hard]
drop table if exists employee;

create table Employee
(id int, month int, salary int);

INSERT INTO employee VALUES ( 1,1,20);
INSERT INTO employee VALUES ( 2,1,20);
INSERT INTO employee VALUES ( 1,2,30);
INSERT INTO employee VALUES ( 2,2,30);
INSERT INTO employee VALUES ( 3,2,40);
INSERT INTO employee VALUES ( 1,3,40);
INSERT INTO employee VALUES ( 3,3,60);
INSERT INTO employee VALUES ( 1,4,60);
INSERT INTO employee VALUES ( 3,4,70);

-- Write a SQL to get the cumulative sum of an employee's salary over a period of 3 months 
-- but exclude the most recent month.
-- The result should be displayed by 'Id' ascending, and then by 'Month' descending.
SELECT E1.id, E1.month,
(IFNULL(E1.salary, 0) + IFNULL(E2.salary, 0) + IFNULL(E3.salary, 0)) AS Salary
FROM
(
SELECT id, MAX(month) AS month FROM Employee
GROUP BY id
HAVING COUNT(*) > 1
) AS maxmonth
LEFT JOIN Employee AS E1 
ON (maxmonth.id = E1.id AND maxmonth.month > E1.month)
LEFT JOIN Employee AS E2 
ON (E2.id = E1.id AND E2.month = E1.month - 1)
LEFT JOIN Employee AS E3 
ON (E3.id = E1.id AND E3.month = E1.month - 2)
ORDER BY id ASC, month DESC;


-- 580 Count Student Number in Departments [Medium]
create table student
(student_id int, student_name varchar(55), gender char(55),dept_id int,
primary key (student_id));

drop table if exists department;
create table department
( dept_id int, dept_name varchar(55),
primary key (dept_id) );

INSERT INTO student VALUES(1,'Jack','M',1);
INSERT INTO student VALUES(2,'Jane','F',1);
INSERT INTO student VALUES(3,'Mark','M',2);

Insert into department VALUES (1,'Engineering');
Insert into department VALUES (2,'Science');
Insert into department VALUES (3,'Law');

-- Write a query to print the respective department name and number of students majoring in each department 
-- for all departments in the department table (even ones with no current students).

select a.dept_name, count(b.student_id) as student_number
from department as a LEFT JOIN student as b
on a.dept_id=b.dept_id
group by a.dept_name
order by student_number DESC,
a.dept_name;

-- 584 Find Customer Referee
drop table if exists customer;
create table customer
(id int, name varchar(35), referee_id int,
primary key (id));

INSERT INTO customer VALUES (1,' Will ', NULL);
INSERT INTO customer VALUES (2,' Jane ', NULL);
INSERT INTO customer VALUES (3,' Alex ', 2);
INSERT INTO customer VALUES (4,' Bill ', NULL);
INSERT INTO customer VALUES (5,' Zack ', 1);
INSERT INTO customer VALUES (6,'Mark  ', 2);

-- Write a query to return the list of customers NOT referred by the person with id '2'.
select id,name
from customer
where referee_id <> 2 OR referee_id IS NULL


-- 585 Investments in 2016 [Medium]
create table insurance
(PID int, TIV_2015 NUMERIC(15,2), TIV_2016 NUMERIC(15,2), LAT NUMERIC(15,2), LON NUMERIC(15,2),
PRIMARY KEY (pid) );

INSERT INTO insurance VALUES (1,10,5,10,10);
INSERT INTO insurance VALUES (2,20,20,20,20);
INSERT INTO insurance VALUES (3,10,30,20,20);
INSERT INTO insurance VALUES (4,10,40,40,40);

-- Write a query to print the sum of all total investment values in 2016 (TIV_2016), 
-- to a scale of 2 decimal places, for all policy holders who meet the following criteria:

-- Have the same TIV_2015 value as one or more other policyholders.
-- Are not located in the same city as any other policyholder (i.e.: the (latitude, longitude) attribute pairs must be unique).
select  ROUND(sum(TIV_2016),2 ) as TIV_2016
from insurance
where insurance.TIV_2015 IN
(select TIV_2015 FROM insurance
GROUP by TIV_2015
Having Count(TIV_2015) > 1 )
AND  CONCAT (LAT,",",LON) IN
(select concat (LAT,",",LON) FROM insurance
group by LAT,LON
HAVING COUNT(*) = 1 );

-- CONCAT ('a','b') add two strings together

-- 586 Customer Placing the Largest Number of Orders [Easy]

-- 595 Big Countries [Easy]
-- A country is big if it has an area of bigger than 3 million square km or a population of more than 25 million.
-- Write a SQL solution to output big countries' name, population and area.

select population,area
from world
where population > 2500000 OR area>3000000

-- we can also use UNION to do this



-- 596 Classes More Than 5 Students [Easy]
-- Please list out all classes which have more than or equal to 5 students.
-- Note: The students should not be counted duplicate in each course

select class
from courses
group by class
having count(DISTINCT student) >= 5

-- SUBQUERY
select class FROM
(
select class,count(distinct student) as num
from courses
group by class ) as temp_table
from temp_table.num>= 5

-- 597 Friend Requests I: Overall Acceptance Rate [Easy]
-- 602 Friend Requests II: Who Has the Most Friends [Medium]
create table friend_request
(sender_id int, send_to_id int, request_date DATE);

create table request_accepted
( request_id int, accept_id int, accept_date DATE);

INSERT INTO friend_request Values (1,2,"2016_06_01");
INSERT INTO friend_request Values (1,3,"2016_06_01");
INSERT INTO friend_request Values (1,4,"2016_06_01");
INSERT INTO friend_request Values (2,3,"2016_06_02");
INSERT INTO friend_request Values (3,4,"2016_06_09");

INSERT INTO request_accepted Values (1,2,"2016_06_03");
INSERT INTO request_accepted Values (1,3,"2016_06_08");
INSERT INTO request_accepted Values (2,3,"2016_06_08");
INSERT INTO request_accepted Values (3,4,"2016_06_09");
INSERT INTO request_accepted Values (3,4,"2016_06_10");



-- 597 Friend Requests I: Overall Acceptance Rate [Easy]
-- Write a query to find the overall acceptance rate of requests rounded to 2 decimals, 
-- which is the number of acceptance divides the number of requests.


-- Note:

-- The accepted requests are not necessarily from the table friend_request. In this case, you just need to simply count the total accepted requests 
-- (no matter whether they are in the original requests), and divide it by the number of requests to get the acceptance rate.
-- It is possible that a sender sends multiple requests to the same receiver, and a request could be accepted more than once. 
-- In this case, the ‘duplicated’ requests or acceptances are only counted once.
-- If there is no requests at all, you should return 0.00 as the accept_rate.



-- SQL WITH caluse: The SQL WITH clause allows you to give a sub-query block a name (a process also called sub-query refactoring), which can be referenced in several places within the main SQL query. 

WITH 
tr AS (
	-- total unique sent requests
    SELECT COUNT(sender_id) AS tot_req FROM(
    SELECT sender_id
    FROM friend_request
    GROUP BY sender_id, send_to_id) AS t1 
),

ta AS (
	-- total unique accepted requests
    SELECT COUNT(request_id) AS tot_act FROM  (
    SELECT request_id
    FROM request_accepted
    GROUP BY request_id, accept_id) AS t2
)

SELECT ROUND(IFNULL(ta.tot_act / tr.tot_req,0),2) AS accept_rate
FROM tr, ta;

WITH 
AC as (
select count(a.request_id) as total_accept  -- number of accepted request
from (
select request_id
from request_accepted
group by request_id,accept_id) as a)
,
SENT as (
select count(b.sender_id) as total_sent   -- number of send out request
from (select sender_id
from friend_request
group by sender_id,send_to_id) as b)

select IFNULL( round(AC.total_accept/SENT.total_sent,2), 0) as percentage
from AC,SENT;

-- 602 Friend Requests II: Who Has the Most Friends [Medium]
drop table if exists request_accepted;

create table request_accepted
( requester_id int, accepter_id int, accept_date DATE);

INSERT INTO request_accepted Values (1,2,"2016_06_03");
INSERT INTO request_accepted Values (1,3,"2016_06_08");
INSERT INTO request_accepted Values (2,3,"2016_06_08");
INSERT INTO request_accepted Values (3,4,"2016_06_09");

-- Write a query to find the the people who has most friends and the most friends number under the following rules:

-- It is guaranteed there is only 1 people having the most friends.
-- The friend request could only been accepted once, which mean there is no multiple records with the same requester_id and accepter_id value.

-- NOTICE: this should be a double direction!!! one can be the requester and accepter at the same time.

SELECT c.people as id, SUM(c.cnt) AS num
FROM (
SELECT requester_id AS people, COUNT(DISTINCT accepter_id) AS cnt
FROM request_accepted
GROUP BY requester_id

UNION ALL   

SELECT accepter_id AS people, COUNT(DISTINCT requester_id) AS cnt
FROM request_accepted
GROUP BY accepter_id 
) AS c    -- using UNION we directly combine two tables. THUS they should have the same number of columns with same names

GROUP BY c.people
ORDER BY SUM(c.cnt) DESC
LIMIT 1;

select a.people as id, sum(a.num) as num
from (
select requester_id as people, count(DISTINCT accepter_id) as num
from request_accepted
group by requester_id

UNION ALL --   UNION removes duplicate records (where all columns in the results are the same), UNION ALL does not.

select accepter_id as people,count(DISTINCT requester_id) as num
from request_accepted
group by accepter_id ) as a
group by a.people
order by num DESC
limit 1

-- 601 Human Traffic of Stadium [Hard]
create table stadium
(id int, vist_date DATE, people int,
primary key (id ));

INSERT INTO stadium VALUES (1,'2017-01-01',10);
INSERT INTO stadium VALUES (2,'2017-01-02',109);
INSERT INTO stadium VALUES (3,'2017-01-03',150);
INSERT INTO stadium VALUES (4,'2017-01-04',99);
INSERT INTO stadium VALUES (5,'2017-01-05',145);
INSERT INTO stadium VALUES (6,'2017-01-06',1455);
INSERT INTO stadium VALUES (7,'2017-01-07',199);
INSERT INTO stadium VALUES (8,'2017-01-08',188);
-- Please write a query to display the records which have 3 or more consecutive rows and the amount of people more than 100(inclusive).
-- Note: Each day only have one row record, and the dates are increasing with id increasing.

-- my idea: no result -- not sure why I want to find the difference??
select a.people - b.people as abdiff
from stadium a JOIN stadium b ON  a.id=b.id AND DATE_ADD(b.vist_date,INTERVAL 1 DAY) = a.vist_date;

-- leetcode answer:
WITH 
tmp AS (
SELECT a.vist_date AS date1, b.vist_date AS date2, c.vist_date AS date3
FROM stadium AS a  LEFT JOIN stadium AS b ON b.id = a.id + 1
                   LEFT JOIN stadium AS c ON c.id = a.id + 2
WHERE a.people >= 100 AND b.people >= 100  AND c.people >= 100),

temp1 AS (
select date1 AS total_date FROM tmp
UNION 
select date2 AS total_date from tmp
UNION 
select date3 AS total_date from tmp
)  -- UNION will delete the duplicated information

select * From Stadium
where vist_date IN (select * from temp1);

					
WITH 
tp AS (

select a.vist_date as day1, b.vist_date as day2, c.vist_date as day3
from stadium a LEFT  JOIN stadium b ON a.id=b.id-1
                LEFT  JOIN stadium c ON a.id=c.id-2
where a.people >= 100 AND b.people>= 100 AND c.people >= 100),

tmp AS (
select day1 as Alldate from tp
UNION
select day2 as Alldate from tp
UNION
select day3 as Alldate from tp )

select stadium.*
from stadium
where stadium.vist_date IN (select Alldate from tmp)






