-- 重点题目： Q12， Q17, Q18, Q23,Q35, Q40, Q41
-- CANNOT run window function with this version of MySql. WILL update in another file.
-- Window funtion: Q: 22, 25


-- 11 查询至少有一门课与学号为“01”的学生所学课程相同的学生的学号和姓名（重点）
Select DISTINCT student.sname,student.sid
from student JOIN score on student.sid=score.sid
Where student.sid IN
(select distinct sid
from score 
where cid IN
(select cid
From score
where sid='01')  AND sid<>'01')
 
 
 -- 12 !!!!!!!!!! 查询和“01”号同学所学课程完全相同的其他同学的学号(重点)
select  sid From score
where sid <>'01'
group by sid having count(distinct cid) = (select count(distinct cid) from score where sid='01')
AND sid NOT IN
( select distinct sid from score
where cid NOT IN
(select cid from score where sid='01') )


-- 15 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩（重点）

select student.sid,student.sname,avg(score.sscore)
from student JOIN score ON student.sid = score.sid
Where score.sscore < 60
group by student.sid
Having count(student.sid) >= 2

-- 16 检索"01"课程分数小于60，按分数降序排列的学生信息（和34题重复，不重点）
select student.*,score.sscore
from student JOIN score ON score.sid=student.sid
where score.cid ='01' AND score.sscore < 60
Order By score.sscore DESC


-- 17 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩(重重点与35一样) 
-- 备注：1.因为要选出需要的字段 用case when 当c_id='01' then 可以得到对应的 s_core
-- 2.因为GROUP UP 要与select 列一致，所以case when 加修饰max
-- 3.因为最后要展现出每个同学的各科成绩为一行，所以用到case
-- IMPORTANT !!!!! use aggregation functions as new column name to avoid group by
select
sid,
MAX(CASE WHEN cid='01' Then sscore ELSE NULL END) "Chinese", -- NULL！！ 这一列只有一科成绩，一定是最大。如果没有，就用null
MAX(CASE WHEN cid='02' Then sscore ELSE NULL END) "Math",
MAX(CASE WHEN cid='03' Then sscore ELSE NULL END) " English",
avg(sscore)
from score
group by sid


-- 18 查询各科成绩最高分、最低分和平均分：以如下形式显示：课程ID，课程name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
--  重点！！！如何使用 case when 来对条件进行计算
select score.cid,course.cname, max(score.sscore),min(score.sscore),avg(score.sscore),
sum(case when score.sscore >= 60 Then 1 else 0 end)/count(score.sid) AS "及格率",
sum(case when score.sscore >= 70 and score.sscore < 80 Then 1 else 0 end)/count(score.sid) AS "中等率",
sum(case when score.sscore >= 80 and score.sscore < 90 Then 1 else 0 end)/count(score.sid) AS "优良率",
sum(case when score.sscore >= 90 Then 1 else 0 end)/count(score.sid) AS "优秀率"
from score JOIN course ON course.cid=score.cid
group by score.cid

-- 19、按各科成绩进行排序，并显示排名(重点row_number)  row_number(）over （order by 列）
select sid,cid
RANK () OVER(Order By sscore DESC) AS Rank
from score

-- 20、查询学生的总成绩并进行排名（不重点）
select sid,sum(sscore) as ' TotalMark'
from score
group by sid
order by TotalMark DESC

-- 21 、查询不同老师所教不同课程平均分从高到低显示(不重点)

-- 1. 以课程为主体
select course.cid, course.cname, avg(score.sscore) as avgeragescore
from score JOIN course ON score.cid=course.cid
Group by score.cid
Order by avgeragescore DESC

-- 2. 以老师为主体
select teacher.Tname,avg(score.sscore) as avgscore
from score JOIN course ON score.cid = course.cid
           JOIN Teacher ON teacher.tid = course.tid
Group by teacher.Tid
Order by avgscore DESC

-- 22、查询所有课程的成绩第2名到第3名的学生信息及该课程成绩（重要 25类似）
-- this is question, it is more suitable for row number 
select *
From (select student.*,course.*, row_number () OVER (partition by course.cid Order By score.sscore DESC) as ra)
      From score JOIN course ON score.cid = course.cid
           JOIN Teacher ON teacher.tid = course.tid ) as A  -- MUST name this within query
Where ra IN (2,3)

-- 23、使用分段[100-85],[85-70],[70-60],[<60]来统计各科成绩，分别统计各分数段人数：课程ID和课程名称(重点和18题类

-- !!! there can not exist black space between sum and parenthese
select course.cid, course.cname,score.sscore,
sum(cASE WHEN score.sscore <= 100 AND score.sscore > 85 Then 1 ELSE 0 END) AS "100-85",
sum(cASE WHEN score.sscore <= 85 AND score.sscore > 70 Then 1 ELSE 0 END) AS "85-70",
sum(caSE WHEN score.sscore <= 70 AND score.sscore > 60 Then 1 ELSE 0 END) AS "70-60",
sum(case when score.sscore <= 60 Then 1 else 0 end) AS "<60"
From course JOIN score ON course.cid = score.cid
group by course.cid,course.cname

-- when you want to use COUNT instead of SUM, you must use NULL instead of 0
select course.cid, course.cname,score.sscore,
count(cASE WHEN score.sscore <= 100 AND score.sscore > 85 Then 1 ELSE NULL END) AS "100-85",
count(cASE WHEN score.sscore <= 85 AND score.sscore > 70 Then 1 ELSE NULL END) AS "85-70",
count(caSE WHEN score.sscore <= 70 AND score.sscore > 60 Then 1 ELSE NULL END) AS "70-60",
count(case when score.sscore <= 60 Then 1 else NULL end) AS "<60"
From course JOIN score ON course.cid = score.cid
group by course.cid,course.cname

-- 24、查询学生平均成绩及其名次（同19题，重点）
select student.sid,student.sname,avg(score.sscore),
RANK () OVER (Partition By student.sid Order By avg(score.sscore) DESC) as Ranking
from  studnet JOIN score ON student.sid=score.sid

-- 25、查询各科成绩前三名的记录（不考虑成绩并列情况）（重点 与22题类似）
select score.cid,score
MAX(case when m = 1 then scoure.sscore else null end) as "No.1",
MAX(case when m = 2 then scoure.sscore else null end) as "No.2",
MAX(case when m = 3 then scoure.sscore else null end) as "No.3",
from  (select student.*, course.cid,course.score,row_number() over (partition by score.cid Order by score.sscore DESC) as m
       from  studnet JOIN score ON student.sid=score.sid ) as a
where m IN (1,2,3)
 
-- 26、查询每门课程被选修的学生数(不重点)
select course.cname, count(score.sid)
from course JOIN score ON course.cid=score.cid
group by course.cid,course.cname

-- 7、 查询出只有两门课程的全部学生的学号和姓名(不重点)
select student.sid,student.sname
from student JOIN score ON student.sid=score.sid
Group by student.sid
Having count(score.sid) =2

-- 28、查询男生、女生人数(不重点)
select ssex, count(Ssex)
from student
group by ssex

-- 29 查询名字中含有"风"字的学生信息（不重点）
select student.*
from student
where sname LIKE '%风%'

-- 31、查询1990年出生的学生名单（重点year）
select student.*
from student
where Year(sbirth) =1990
 -- 回忆一下其他关于时间的算法
select sname,DATE_ADD(sbirth,Interval 8 Year)
from student
-- 怎么用生日计算年龄
 SELECT  TIMESTAMPDIFF(YEAR, sbirth, CURDATE()) -- CURDATE current date
 from student
 Select  ROUND(TIMESTAMPDIFF(MONTH, sbirth, CURDATE())/12,1)-- CURDATE current date
 from student

-- 32、查询平均成绩大于等于85的所有学生的学号、姓名和平均成绩（不重要
select student.sid,student.sname,avg(score.sscore)
from student JOIN score ON student.sid=score.sid
Group by student.sid,student.sname
Having avg(score.sscore>=85)

-- 33、查询每门课程的平均成绩，结果按平均成绩升序排序，平均成绩相同时，按课程号降序排列（不重要）
select course.cname,avg(score.sscore)
from course JOIN score ON score.cid=course.cid
group by course.cname
order by avg(score.sscore), course.cid DESC

-- 34、查询课程名称为"数学"，且分数低于60的学生姓名和分数（不重点）
select student.sname,score.sscore
From student JOIN score ON student.sid=score.sid
             JOIN course ON course.cid=score.cid
Where course.cname = "数学 " and score.sscore < 60

-- 35、查询所有学生的课程及分数情况（重点）
-- 每个人的信息都要出现在相同行
select student.sid,student.sname,score.sscore,
MAX(case when course.cid='01' Then score.sscore Else NULL END) AS 'COURSE1',
MAX(case when course.cid='02' Then score.sscore Else NULL END) AS 'COURSE2',
MAX(case when course.cid='03' Then score.sscore Else NULL END) AS 'COURSE3'
From student JOIN score ON student.sid=score.sid
             JOIN course ON course.cid=score.cid
GROUP BY student.sid

-- 36、查询任何一门课程成绩在70分以上的姓名、课程名称和分数（重点）
select student.sname,course.cname,score.sscore
From student JOIN score ON student.sid=score.sid
             JOIN course ON course.cid=score.cid
Where score.sscore > 70

-- 37、查询不及格的课程并按课程号从大到小排列(不重点)
select course.cid,student.sname,course.cname,score.sscore
From student JOIN score ON student.sid=score.sid
             JOIN course ON course.cid=score.cid
Where score.sscore < 60
Order By course.cid DESC

-- 38、查询课程编号为03且课程成绩在80分以上的学生的学号和姓名（不重要）
select course.cid,student.sname,course.cname,score.sscore
From student JOIN score ON student.sid=score.sid
             JOIN course ON course.cid=score.cid
Where score.sscore > 80 AND course.cid = '03'

-- 39、求每门课程的学生人数（不重要）
select course.cid,course.cname,count(DISTINCT score.sid)
From score JOIN course ON course.cid=score.cid
Group by course.cid,course.cname

-- 40、查询选修“张三”老师所授课程的学生中成绩最高的学生姓名及其成绩（重要top）

select student.sid,student.sname,score.sscore
From student JOIN score ON student.sid=score.sid
             JOIN course ON course.cid=score.cid
						 JOIN teacher ON teacher.tid=course.tid
Where teacher.tname="张三"
Order by score.sscore DESC
Limit 1
-- 这是一种新思路，还是得记一下。我一直想用max 然后where score= (). 太麻烦了

select student.sid, student.sname,score.sscore
From student JOIN score ON student.sid=score.sid
where score.sscore = (
select max(score.sscore)
From student JOIN score ON student.sid=score.sid
             JOIN course ON course.cid=score.cid
						 JOIN teacher ON teacher.tid=course.tid
Where teacher.tname="张三")
AND score.cid = 
(select DISTINCT course.cid
From student 
             JOIN score   ON student.sid=score.sid
             JOIN course ON course.cid=score.cid
						 JOIN teacher ON teacher.tid=course.tid
Where teacher.tname="张三")

-- 41.查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩 （重点）
-- 自己写错了
select student.sid,sname,score.cid,score.sscore
From student JOIN score   ON student.sid=score.sid
where student.sid = (
select student.sid
From student JOIN score   ON student.sid=score.sid
GROUP BY student.sid
HAVING Max(score.sscore) = MIN(score.sscore))
-- 我们需要他们出现在一行
-- 再次尝试
select sid
from (
select sid,sscore
from score
group by sid,sscore)  -- 成绩相同的人，只有一行，不一样的会有很多行) a
as a 
Group by sid
Having count(sid) = 1

-- 这样的问题在于，有可能有一个人只有一门课

select sid 
from
(
select b.sid,b.sscore from score as b
inner join
(
select sid from score group by sid having count(distinct cid) > 1
) as c on b.sid=c.sid
group by b.sid,b.sscore

) as a 

group by sid
Having count(sid)=1


-- 43、统计每门课程的学生选修人数（超过5人的课程才统计）。要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列（不重要）
select course.cid,course.cname, count(sid)
from score JOIN course ON score.cid = course.cid
Group by score.cid
Having count(sid) > 5

-- 44、检索至少选修两门课程的学生学号（不重要）
select sid,count(sid)
from score
group by sid
having count(sid) >= 2

-- 45、 查询选修了全部课程的学生信息（重点划红线地方
select student.*,count(score.sid)
from score JOIN course ON score.cid = course.cid
           JOIN student ON student.sid=score.sid
group by score.sid
having count(score.sid)=
(select count(cid) from course)

-- 46. 查询各个人的年龄
select round(DateDiff(NOw(),sbirth)/365,1)
from student

-- 47、查询没学过“张三”老师讲授的任一门课程的学生姓名
select *
from student
where sid NOT IN (
select DISTINCT student.sid
from student JOIN score ON student.sid=score.sid
where score.cid IN (
select course.cid
from course JOIN teacher ON course.tid=teacher.tid
where teacher.Tname ="张三" ))

-- 48、查询下周过生日同学
-- 出生年份的第几周，不一定是今年的第几周。我们算他们今年几号过生日，然后看看是不是在下周
select *
from student
where week( concat('2021-',substring(sbirth,6,5))) = Week (NOW())+ 1
-- 但是上面的办法对12-31 和1-1 没办法算


-- 49 查询本月过生日的人
select *
from student
where month(sbirth) = month(now())

select *
from student
where month(sbirth) = month('2002-05-18')

-- 50 查询下个月过生日的人
select *
from student
where month(sbirth) = month(now())+1

-- 那现在要是十二月怎么办
select * from student WHERE
CASE when month(NOW()) = 1 then month(sbirth) = 1 ELSE  month(sbirth) = month(now())+1 END

