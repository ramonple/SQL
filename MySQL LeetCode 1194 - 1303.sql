-- 1194. Tournament Winners [Hard]
drop table if exists players;
create table players
(player_id int primary key, group_id int);

insert into players values(15,1);
insert into players values(25,1);
insert into players values(30,1);
insert into players values(45,1);
insert into players values(10,2);
insert into players values(35,2);
insert into players values(20,3);
insert into players values(40,3);

drop table if exists matches;
create table matches
(match_id int primary key, 
first_player int,
second_player int,
first_score int,
second_score int);

insert into matches values(1,15,45,3,0);
insert into matches values(2,30,25,1,2);
insert into matches values(3,30,15,2,0);
insert into matches values(4,40,20,5,2);
insert into matches values(5,35,50,1,1);


-- The winner in each group is the player who scored the maximum total points within the group. In the case of a tie, the lowest player_id wins.

-- Write an SQL query to find the winner in each group.

-- my code: cannot run
select  match_id, ( case when first_score > second_score then first_player 
              when first_score < second_score then second_player
						 else min(first_player,second_player) end ) as player_id
from matches
group by match_id

-- we need to focus on the sum scores of each player, instead of in each match

-- leetcode:
SELECT group_id, player_id FROM (
SELECT a.group_id, a.player_id,
ROW_NUMBER() OVER(PARTITION BY a.group_id ORDER BY IFNULL(b.score,0) DESC, a.player_id) AS rnk
FROM Players AS a
LEFT JOIN (
SELECT player_id, SUM(score) AS score FROM (
SELECT match_id, first_player AS player_id, first_score AS score
FROM Matches
UNION ALL
SELECT match_id, second_player AS player_id, second_score AS score
FROM Matches
) AS x
GROUP BY player_id
) AS b
ON a.player_id = b.player_id
) AS tmp
WHERE rnk = 1;

-- 
select a.*,b.*
from
players as a
LEFT JOIN
( select player_id, sum(score) as score
from 
(select match_id,first_player as player_id,first_score as score
from matches

UNION all  -- does no delete the duplications
select match_id, second_player as player_id, second_score as score
from matches ) as x
group by player_id ) as b
ON a.player_id = b.player_id

-- out out the corresponding score of each player, and the player's corresponding team
-- how to deal with the NULL?

select temp.group_id, temp.player_id
from (
select a.group_id, a.player_id, ROW_NUMBER() OVER(PARTITION BY a.group_id ORDER BY IFNULL(b.score,0) DESC, a.player_id) AS rnk -- IFNULL
from
players as a
LEFT JOIN
( select player_id, sum(score) as score
from 
(select match_id,first_player as player_id,first_score as score
from matches
UNION all  -- does no delete the duplications
select match_id, second_player as player_id, second_score as score
from matches ) as x
group by player_id ) as b
ON a.player_id = b.player_id ) as temp
where rnk = 1

-- 1204. Last Person to Fit in the Elevator [Medium]
drop table if exists queue;
create table queue
(person_id int primary key, person_name varchar(255), weight int, turn int);
insert into queue values(5, 'George Washington',250,1);
insert into queue values(3, 'John Adams',350,2);
insert into queue values(6, 'Thomas Jefferson',400,3);
insert into queue values(2, 'Will Johnliams',200,4);
insert into queue values(4, 'Thomas Jefferson',175,5);
insert into queue values(1, 'James Eleplhant',500,6);

-- The maximum weight the elevator can hold is 1000.

-- Write an SQL query to find the person_name of the last person who will fit in the elevator without exceeding the weight limit. 
-- It is guaranteed that the person who is first in the queue can fit in the elevator.

WITH
tmp AS (
SELECT person_id, person_name, weight, turn,
SUM(weight) OVER(ORDER BY turn ASC) AS cum_weight
FROM Queue
),
tmp1 AS (
SELECT person_name, turn, cum_weight FROM tmp
WHERE cum_weight <= 1000
)
SELECT person_name FROM tmp1
WHERE turn >= all(SELECT turn FROM tmp1); -- quite clever, Should be ALL!!!



-- 1205. Monthly Transactions II [Medium]

drop table if exists transactions;
create table transactions
(id int primary key, country varchar(255),state enum("approved", "declined"), amount int, trans_date date);

insert into transactions values(101,'US','approved',1000,'2019-05-18');
insert into transactions values(102,'US','declined',2000,'2019-05-19');
insert into transactions values(103,'US','approved',3000,'2019-06-10');
insert into transactions values(104,'US','approved',4000,'2019-06-13');
insert into transactions values(105,'US','approved',5000,'2019-06-15');

drop table if exists chargebacks;
create table chargebacks
(trans_id int , trans_date date) ;

insert into chargebacks values(102,'2019-05-29');
insert into chargebacks values(101,'2019-06-30');
insert into chargebacks values(105,'2019-09-18');

-- Write an SQL query to find for each month and country, the number of approved transactions and their total amount, 
-- the number of chargebacks and their total amount.

WITH
tmp AS (
SELECT a.trans_id AS id, b.country, 'checkback' AS state, b.amount, a.trans_date 
FROM Chargebacks AS a
LEFT JOIN Transactions AS b
ON a.trans_id = b.id

UNION ALL
    
SELECT * FROM Transactions
WHERE state = 'approved'
)

SELECT DATE_FORMAT(trans_date, "%Y-%m") AS month, country,
SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_amount,
SUM(CASE WHEN state = 'checkback' THEN 1 ELSE 0 END) AS chargeback_count,
SUM(CASE WHEN state = 'checkback' THEN amount ELSE 0 END) AS chargeback_amount
FROM tmp
GROUP BY DATE_FORMAT(trans_date, "%Y-%m"), country;

-- 1211. Queries Quality and Percentage [Easy]

drop table if exists queries;
create table queries
(query_name varchar(55),result varchar(55),position int, rating int);
insert into queries values('Dog','Golden Retriever',1,5);
insert into queries values('Dog','German Shepherd',2,5);
insert into queries values('Dog','Mule',200,1);
insert into queries values('Cat','Shirazi',5,2);
insert into queries values('Cat','Siamese',3,3);
insert into queries values('Cat','Sphynx',7,4);



-- We define query quality as: The average of the ratio between query rating and its position.

-- We also define poor_query_percentage as: The percentage of all queries with rating less than 3.

-- Write an SQL query to find each query name, the quality and poor_query_percentage.

-- Both quality and poor_query_percentage should be rounded to 2 decimal places.

-- my code
select query_name,ROUND(  avg(rating/ position),2) as quality,
ROUND( (SUM(case when rating < 3 then 1 else 0 end)/count(rating) ) * 100, 2) as poor_query_percentage
from queries
group by query_name


-- leetcode
SELECT query_name,
ROUND(AVG(rating/position),2) AS quality,
ROUND(SUM(100 * CASE WHEN rating < 3 THEN 1 ELSE 0 END)/COUNT(DISTINCT result),2) AS poor_query_percentage
FROM Queries
GROUP BY query_name;


-- 1212. Team Scores in Football Tournament [Medium]

drop table if exists Teams;
create table Teams
(team_id int primary key, team_name varchar(255));
insert into Teams values(10,'Leetcood FC');
insert into Teams values(20,'New York FC');
insert into Teams values(30,'Atlanta FC');
insert into Teams values(40,'Chicago FC');
insert into Teams values(50,'Toronto FC');

drop table if exists matches;
create table matches
(match_id int primary key, host_team int, guest_team int, host_goals int, guest_goals int);

insert into matches values(1,10,20,3,0);
insert into matches values(2,30,10,2,2);
insert into matches values(3,10,50,5,1);
insert into matches values(4,20,30,1,0);
insert into matches values(5,50,30,1,0);

-- You would like to compute the scores of all teams after all matches. Points are awarded as follows:

-- A team receives three points if they win a match (Score strictly more goals than the opponent team).
-- A team receives one point if they draw a match (Same number of goals as the opponent team).
-- A team receives no points if they lose a match (Score less goals than the opponent team).
-- Write an SQL query that selects the team_id, team_name and num_points of each team in the tournament after all described matches. Result table should be ordered by num_points (decreasing order). In case of a tie, order the records by team_id (increasing order).



 -- summarize each match conclusion
( select 
( case when host_goals > guest_goals then host_team else null end) as hostwin,
( case when host_goals <  guest_goals then guest_team else null end) as gustwin,
( case when host_goals = guest_goals then host_team else null end) as amatch,
( case when host_goals = guest_goals then guest_team else null end) as bmatch
from matches ) as tmp

-- have no idea what is the next step

-- leetcode
SELECT a.team_id, a.team_name, IFNULL(b.score,0) AS num_points 
FROM Teams AS a
LEFT JOIN (
SELECT team, SUM(score) AS score
FROM (
SELECT match_id, host_team AS team,
CASE WHEN host_goals > guest_goals THEN 3 
WHEN host_goals = guest_goals THEN 1
ELSE 0 END AS score
FROM Matches
UNION ALL
SELECT match_id, guest_team AS team,
CASE WHEN guest_goals > host_goals THEN 3 
WHEN guest_goals = host_goals THEN 1
ELSE 0 END AS score
FROM Matches
) AS tmp
GROUP BY team
) AS b
ON a.team_id = b.team
ORDER BY num_points DESC, team_id;

-- we should summarize the score according to each match
-- add 3 scores for the winner of each match

select a.team_id,a.team_name,IFNULL( b.score,0) as num_points
from Teams as a 
LEFT JOIN 
(
select team, sum(score) as score
from
(
select match_id, host_team as team, 
       ( case when host_goals > guest_goals THEN 3 
            WHEN host_goals = guest_goals THEN 1
            ELSE 0 END) as score
from matches

UNION ALL

select match_id, guest_team as team, 
       ( case when host_goals < guest_goals THEN 3 
            WHEN host_goals = guest_goals THEN 1
            ELSE 0 END) as score
from matches
) as tmp  
group by team) as b
ON a.team_id = b.team
order by num_points DESC

-- one team, the one with zero score, disappeared -- IFNULL(b.score,0)



-- 1225. Report Contiguous Dates [hard]

drop table if exists Failed;
create table Failed
(fail_date date primary key);

insert into Failed values('2018-12-28');
insert into Failed values('2018-12-29');
insert into Failed values('2019-01-04');
insert into Failed values('2019-01-05');

drop table if exists succeeded;
create table succeeded
(success_date date primary key);

insert into succeeded values('2018-12-30');
insert into succeeded values('2018-12-31');
insert into succeeded values('2019-01-01');
insert into succeeded values('2019-01-02');
insert into succeeded values('2019-01-03');
insert into succeeded values('2019-01-06');

-- A system is running one task every day. Every task is independent of the previous tasks. The tasks can fail or succeed.

-- Write an SQL query to generate a report of period_state for each continuous interval of days in the period from 2019-01-01 to 2019-12-31.

-- period_state is 'failed' if tasks in this interval failed or 'succeeded' if tasks in this interval succeeded. Interval of days are retrieved as start_date and end_date.

-- Order result by start_date.

select state,date
from
( select 'failed' as state, fail_date as date
from Failed
UNION ALL
select 'succeeded' as state, success_date as date
from succeeded) as tmp
where date BETWEEN '2019-01-01' and '2019-12-31'
order by date 

-- how to write the one in the answer? pivot table?

-- ，通过给记录排序得到rank，然后根据rank跟连续时间组之间的差值固定，
-- 分辨出不同组的连续数据，最后选择同组数据中最大值和最小值，作为每组数据的start_date和end_date

-- leetcode:
WITH 

t1 as (
SELECT * FROM (
(SELECT fail_date AS datelist, 'failed' AS state FROM Failed)
UNION ALL
(SELECT success_date, 'succeeded' from Succeeded)
) AS x
WHERE YEAR(datelist) = 2019
), 

t2 AS (
SELECT
datelist,
state,
CASE WHEN state = 'succeeded'  THEN DATEDIFF(datelist, '2018-12-31') - ROW_NUMBER() OVER (PARTITION BY state ORDER BY state, datelist)
WHEN state = 'failed'  THEN DATEDIFF(datelist, '2017-12-31') - ROW_NUMBER() over (PARTITION BY state ORDER BY state, datelist) 
ELSE -100 END AS group_num
FROM t1
order by datelist
)

SELECT DISTINCT
state AS period_state,
FIRST_VALUE(datelist) OVER (PARTITION BY group_num ORDER BY datelist) AS start_date,
FIRST_VALUE(datelist) OVER (PARTITION BY group_num ORDER BY datelist DESC) AS end_date
FROM t2
ORDER BY start_date;

-- it seems my code is the t1 here, following the idea shows here, update my previous code:


select DISTINCT state as period_state,
FIRST_VALUE(datelist) OVER (PARTITION BY group_num ORDER BY datelist) AS start_date,
FIRST_VALUE(datelist) OVER (PARTITION BY group_num ORDER BY datelist DESC) AS end_date
from (
select state,datelist,
CASE WHEN state = 'succeeded'  THEN DATEDIFF(datelist, '2018-12-31') - ROW_NUMBER() OVER (PARTITION BY state ORDER BY  datelist)
WHEN state = 'failed'  THEN DATEDIFF(datelist, '2017-12-31') - ROW_NUMBER() over (PARTITION BY state ORDER BY  datelist) -- two continuous failed dates
ELSE -100 END AS group_num
from 
( select state,datelist
from
( select 'failed' as state, fail_date as datelist
from Failed
UNION ALL
select 'succeeded' as state, success_date as datelist
from succeeded) as tp
where datelist BETWEEN '2019-01-01' and '2019-12-31') as tmp
order by datelist

) as ttp
ORDER BY start_date; 
-- my so many duplicated rows ??? 
-- can unserstand what they are doing, but I am still confused why I have so many duplicated rows- it will be okay after add ' DISTINCT' after selection

-- write accoring to leetcode

with 
t1 as
(SELECT * FROM (
(SELECT fail_date AS datelist, 'failed' AS state FROM Failed)
UNION ALL
(SELECT success_date, 'succeeded' from Succeeded)
) AS x
WHERE YEAR(datelist) = 2019
), 

t2 AS (
SELECT
datelist,
state,
CASE WHEN state = 'succeeded' 
THEN DATEDIFF(datelist, '2018-12-31') - ROW_NUMBER() OVER (PARTITION BY state ORDER BY state, datelist)
WHEN state = 'failed' 
THEN DATEDIFF(datelist, '2017-12-31') - ROW_NUMBER() over (PARTITION BY state ORDER BY state, datelist) 
ELSE -100 END AS group_num
FROM t1
order by datelist
)
select DISTINCT state AS period_state,
First_value(datelist) over (partition by group_num order by datelist) as start_date,
First_value(datelist) over (partition by group_num order by datelist DESC) as end_date
from t2
ORDER BY start_date;



-- 1241. Number of Comments per Post [Easy]
create table submissions
(sub_id int, parent_id int);
insert into submissions values(1,null);
insert into submissions values(2,null);
insert into submissions values(1,null);
insert into submissions values(12,null);
insert into submissions values(3,1);
insert into submissions values(5,2);
insert into submissions values(3,1);
insert into submissions values(4,1);
insert into submissions values(9,1);
insert into submissions values(10,2);
insert into submissions values(6,7);

-- Write an SQL query to find number of comments per each post.

-- Result table should contain post_id and its corresponding number of comments, and must be sorted by post_id in ascending order.

-- Submissions may contain duplicate comments. You should count the number of unique comments per post.

-- Submissions may contain duplicate posts. You should treat them as one post.

SELECT a.sub_id AS post_id, IFNULL(b.number_of_comments,0) AS
number_of_comments
from 
( SELECT DISTINCT sub_id FROM Submissions
WHERE parent_id IS NULL) as a  -- all parent post
LEFT JOIN (
SELECT DISTINCT parent_id, COUNT(DISTINCT sub_id) AS number_of_comments FROM Submissions
WHERE parent_id IS NOT NULL
GROUP BY parent_id
) AS b -- number of comments to each post
ON a.sub_id = b.parent_id
ORDER BY post_id;


-- discussion
select s1.sub_id as post_id,
    count(distinct s2.sub_id) as number_of_comments
from Submissions s1
left join Submissions s2
on s2.parent_id = s1.sub_id
where s1.parent_id is null
group by s1.sub_id


-- 1251. Average Selling Price [Easy]
-- (product_id, start_date, end_date) is the primary key for this table.
-- Each row of this table indicates the price of the product_id in the period from start_date to end_date.
-- For each product_id there will be no two overlapping periods. That means there will be no two intersecting periods for the same product_id.
drop table if exists prices;
create table prices
(product_id int, start_date date, end_date date, price int, primary key (product_id,start_date,end_date));
insert into prices values(1,'2019-02-17','2019-02-28',5);
insert into prices values(1,'2019-03-01','2019-03-22',20);
insert into prices values(2,'2019-02-01','2019-02-20',15);
insert into prices values(2,'2019-02-21','2019-03-31',30);

create table unitsSold
(product_id int, purchase_date date,units int);

insert into unitsSold values(1,'2019-02-25',100);
insert into unitsSold values(1,'2019-03-01',15);
insert into unitsSold values(2,'2019-02-10',200);
insert into unitsSold values(2,'2019-03-22',30);

-- Have no idea
SELECT a.product_id, 
ROUND(SUM(b.price * a.units)/SUM(a.units), 2) AS  average_price -- must be sum(units)
FROM (
SELECT DISTINCT product_id, purchase_date, units
FROM UnitsSold
) AS a
LEFT JOIN Prices AS b
ON a.product_id = b.product_id
AND a.purchase_date BETWEEN b.start_date AND b.end_date
GROUP BY a.product_id
-- should be more familar with how two tables can be combined 


-- 1264. Page Recommendations [Medium]
drop table if exists friendship;
create table friendship
(user1_id int, user2_id int, primary key (user1_id,user2_id) );

insert into friendship values(1,2);
insert into friendship values(1,3);
insert into friendship values(1,4);
insert into friendship values(2,3);
insert into friendship values(2,4);
insert into friendship values(2,5);
insert into friendship values(6,1);

drop table if exists Likes;
create table Likes
(user_id int, page_id int);
insert into Likes values(1,88);
insert into Likes values(2,23);
insert into Likes values(3,24);
insert into Likes values(4,56);
insert into Likes values(5,11);
insert into Likes values(6,33);
insert into Likes values(2,77);
insert into Likes values(3,77);
insert into Likes values(6,88);

-- Write an SQL query to recommend pages to the user with user_id = 1 using the pages that your friends liked. 
-- It should not recommend pages you already liked.

-- Return result table in any order without duplicates.

-- first find user_id = 1's friend

-- my code:
select DISTINCT likes.page_id as recommended_page
from 
( select user1_id as user1_friend
from friendship
where user2_id = 1
UNION
select user2_id as user1_friend
from friendship
where user1_id = 1) as tmp
JOIN
likes
On tmp.user1_friend = likes.user_id
where likes.page_id NOT IN
(select page_id
from likes
where user_id = 1 )
order by recommended_page

-- leetcode:
SELECT DISTINCT b.page_id AS recommended_page FROM (
SELECT user2_id AS user_id FROM Friendship
WHERE user1_id = 1
UNION
SELECT user1_id AS user_id FROM Friendship
WHERE user2_id = 1
) AS a
JOIN Likes AS b
ON a.user_id = b.user_id
AND b.page_id NOT IN (SELECT page_id FROM Likes WHERE user_id = 1)
ORDER BY b.page_id;


-- 1270. All People Report to the Given Manager [Medium]

drop table if exists employees;
create table employees
(employee_id int primary key, employee_name varchar(55), manager_id int);
insert into employees values(1,'Boss',1);
insert into employees values(3,'Alice',3);
insert into employees values(2,'Bob',1);
insert into employees values(4,'Daniel',2);
insert into employees values(7,'Luis',4);
insert into employees values(8,'Jhon',3);
insert into employees values(9,'Angela',8);
insert into employees values(77,'Robert',1);

-- Write an SQL query to find employee_id of all employees that directly or indirectly report their work to the head of the company.
-- The indirect relation between managers will not exceed 3 managers as the company is small.
-- Return result table in any order without duplicates.

select employee_id
from employees 
where manager_id = 1 and employee_id <> 1
UNION
select employee_id
from employees
where manager_id IN 
( select employee_id
from employees 
where manager_id = 1 and employee_id <> 1) 
UNION 
select employee_id 
from employees
where manager_id  IN
(
select employee_id
from employees
where manager_id IN 
( select employee_id
from employees 
where manager_id = 1 and employee_id <> 1) 
)


-- 1280. Students and Examinations [Easy]
drop table if exists students;
create table students
(student_id int primary key, student_name varchar(255));

insert into students values(1,'Alice');
insert into students values(2,'Bob');
insert into students values(13,'John');
insert into students values(6,'Alex');

drop table if exists subjects;
create table subjects
(subject_name varchar(155) primary key);

insert into subjects values('Math');
insert into subjects values('Physcis');
insert into subjects values('Programming');

drop table if exists Examinations;
create table Examinations
(student_id int, subject_name varchar(155) );

insert into Examinations values (1,'Math');
insert into Examinations values (1,'Physics');
insert into Examinations values (1,'Programming');
insert into Examinations values (2,'Programming');
insert into Examinations values (1,'Physics');
insert into Examinations values (1,'Math');
insert into Examinations values (13,'Math');
insert into Examinations values (13,'Programming');
insert into Examinations values (13,'Physics');
insert into Examinations values (2,'Math');
insert into Examinations values (1,'Math');

-- Write an SQL query to find the number of times each student attended each exam.
-- Order the result table by student_id and subject_name.

select students.student_id,students.student_name, Examinations.subject_name, IFNULL(count(Examinations.student_id),0) as attended_exams
from students LEFT JOIN Examinations 
On students.student_id = Examinations.student_id
LEFT JOIN Subjects ON Subjects.subject_name = Examinations.subject_name
group by students.student_id, Examinations.subject_name,students.student_name
-- wrong. cannot show Alex (never attend exam). I have already used the left joint and ifnull clause


-- leetcode
SELECT s.student_id,
s.student_name,
sub.subject_name,
COUNT(e.subject_name) AS attended_exams
FROM Students s
CROSS JOIN Subjects sub
LEFT JOIN Examinations e
ON (s.student_id = e.student_id
AND sub.subject_name = e.subject_name)
GROUP BY s.student_id, s.student_name, sub.subject_name
ORDER BY s.student_id, sub.subject_name;

-- use cross join
select students.student_id,students.student_name, Subjects.subject_name, count(Examinations.student_id) as attended_exams
from students  
LEFT JOIN Examinations  On students.student_id = Examinations.student_id
CROSS JOIN Subjects 
group by students.student_id,students.student_name,Subjects.subject_name


-- 1285. Find the Start and End Number of Continuous Ranges [Medium]
drop table if exists Logs;
create table Logs
(log_id int primary key);

insert into Logs values(1);
insert into Logs values(2);
insert into Logs values(3);
insert into Logs values(7);
insert into Logs values(8);
insert into Logs values(10);
-- Since some IDs have been removed from Logs. Write an SQL query to find the start and end number of continuous ranges in table Logs.

-- Order the result table by start_id.

select DISTINCT First_Value (log_id) over (partition by rk order by log_id) as start_id,
First_value(log_id) over (partition by rk order by log_id DESC) as end_id
from
(select log_id,log_id - row_number() over() as rk
from Logs ) as a



-- -- 1294. Weather Type in Each Country [Easy]

drop table if exists Countries;
create table Countries
(country_id int primary key, country_name varchar(255));
insert into Countries values(2,'USA');
insert into Countries values(3,'Australia');
insert into Countries values(7,'Peru');
insert into Countries values(5,'China');
insert into Countries values(8,'Morocco');
insert into Countries values(9,'Spain');

drop table if exists Weather;
create table Weather
(country_id int, weather_state varchar(55),day date,
primary key (country_id, day) );

insert into Weather values(2,15,'2019-11-01');
insert into Weather values(2,12,'2019-10-28');
insert into Weather values(2,12,'2019-10-27');
insert into Weather values(3,-2,'2019-11-10');
insert into Weather values(3,0,'2019-11-11');
insert into Weather values(3,3,'2019-11-12');
insert into Weather values(5,16,'2019-11-07');
insert into Weather values(5,18,'2019-11-09');
insert into Weather values(5,21,'2019-11-23');
insert into Weather values(7,25,'2019-11-28');
insert into Weather values(7,22,'2019-12-01');
insert into Weather values(7,20,'2019-12-02');
insert into Weather values(8,25,'2019-11-05');
insert into Weather values(8,27,'2019-11-15');
insert into Weather values(8,31,'2019-11-25');
insert into Weather values(9,7,'2019-10-23');
insert into Weather values(9,3,'2019-12-23');


-- Write an SQL query to find the type of weather in each country for November 2019.
-- The type of weather is Cold if the average weather_state is less than or equal 15, 
-- Hot if the average weather_state is greater than or equal 25 and Warm otherwise.


select a.country_name,
( CASE WHEN b.avgtemp <= 15 Then 'Cold'
	   When b.avgtemp >= 25 Then 'Hot'
		 ELSE 'Warm' END )  as Type
from 
Countries as a
JOIN
(
SELECT country_id, avg(weather_state) as avgtemp
FROM Weather
WHERE day BETWEEN "2019-11-01" AND "2019-11-30"
group by country_id) as b
Where a.country_id = b.country_id


-- 1303. Find the Team Size [Easy]
drop table if exists project;
drop table if exists Employee;
create table Employee
(employee_id int primary key, team_id int);
insert into Employee values(1,8);
insert into Employee values(2,8);
insert into Employee values(3,8);
insert into Employee values(4,7);
insert into Employee values(5,9);
insert into Employee values(6,9);

-- Write an SQL query to find the team size of each of the employees.
-- Return result table in any order.
-- !1 a very classic question. If we want to sum something through a group which we don't want to group by, what should we do
select a.employee_id,b.team_size
from
employee as a 
LEFT JOIN
( select team_id, count(employee_id) as team_size
from employee
group by team_id) as b
ON a.team_id = b.team_id

-- LEETCode (much simpler)
select employee_id, count(employee_id) over (partition by team_id) as team_size
from employee
order by employee_id




