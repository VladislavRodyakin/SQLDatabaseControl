-- 5.1
--1
drop table if exists table1;
create table table1(
    coloumn1 serial,
    coloumn2 integer,
    coloumn3 char(20)
);
create table table2(
    coloumn1 serial,
    coloumn2 integer,
    coloumn4 char(20)
);

insert into table1 (coloumn2, coloumn3)
values (123,'abc'),
        (543,'bda'),
        (261,'134adbg'),
        (109,'adbg');

insert into table2 (coloumn2, coloumn4)
values (1,'bda'),
        (5,'adbg'),
        (123,'bff');

select coloumn1, coloumn2
from table1
where coloumn3 in (select coloumn4 from table2);

with subquery_data as 
(
    select coloumn4
    from table2
)
select coloumn1, coloumn2
from table1
where coloumn3 in (select coloumn4 from subquery_data);

--2
SELECT o.order_id, c.customer_name, o.order_date, o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

WITH 
    customer_orders AS (
        SELECT o.order_id, o.customer_id, o.order_date, o.total_amount
        FROM orders o
    ),
    customer_names AS (
        SELECT c.customer_id, c.customer_name
        FROM customers c
    )
SELECT co.order_id, cn.customer_name, co.order_date, co.total_amount
FROM customer_orders co
JOIN customer_names cn ON co.customer_id = cn.customer_id;

--3
SELECT e1.name AS employee_name, e2.name AS manager_name
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.id;

WITH RECURSIVE employee_hierarchy AS (
    SELECT id, name, manager_id, 1 as level
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.id, e.name, e.manager_id, eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.id
)
SELECT id, name, level, string_agg(manager_id::text, ' -> ') AS manager_chain
FROM employee_hierarchy
GROUP BY id, name, level
ORDER BY level;


-- 5.2
create table folders(
folder_id integer primary key,
parent_folder_id integer,
folder_name CHAR(100),
foreign key(parent_folder_id) references folders(folder_id)
);

insert into folders (folder_id, parent_folder_id, folder_name) values
(1, null, 'first'),
(2, 1, 'secondLFirst'),
(3, 1, 'secondLSecond'),
(4, 2, 'ThirdLFirst');

with recursive folder_hierarchy AS (
    select folder_id, parent_folder_id, folder_name, 1 as level
    --creates a table with cols:
    --folder_id, parent_folder_id, folder_name, level
    --sets level to 1 because 
    --initial table created from base folders, e.g. parent_folder_id is null 
    from folders
    where parent_folder_id is null
    union all --unifies with further quieries, standart recursion
    select f.folder_id, f.parent_folder_id, f.folder_name, fh.level + 1 --how does fh.level+1 work? --it is +1 to parent folder level, as by "on f.parent_folder_id = fh.folder_id" condition
    --table with same cols, level++ from their parents
    --every iteration recieves the same level
    from folders as f
    join folder_hierarchy as fh on f.parent_folder_id = fh.folder_id
    --inner join on all the same cols -> previous results affect current
    --this results in fh adding to itself only direct children of folders already in results
    --e.g. only next-level folders are added per iteration
)
select level, COUNT(*) as folder_count
from folder_hierarchy
group by level --this results in levels becoming groups, and count(*) gives number of element (rows) for each group
order by level;



-- 5.3
-- after explanation
drop table if exists Tasks_Dates;
create table Tasks_Dates(
task_id SERIAL primary key,
createdTime TIMESTAMP
)

insert into Tasks_Dates(createdTime) values
('2024-01-21'),
('2024-01-21'),
('2024-01-24'),
('2024-01-23'),
('2024-01-25'),
('2024-01-20');
select * from Tasks_Dates;

create index taskDate_index on Tasks_Dates(createdTime); 

with recursive t as(
	select 1 as n
	union all
	select n+1 as n
	from t
)
select * from t limit 120;

with recursive uniqDates as 
(
	(select 1 as n, createdTime as startDate
	from Tasks_Dates
	where createdTime = '2024-01-20'
	limit 1)
	union all
	(select n+1 as n, (select Tasks_Dates.createdTime as startDate 
	from Tasks_Dates 
	where Tasks_dates.createdTime = '2024-01-20'::date + n 
	--and Tasks_dates.createdTime::date + n <= '2025-01-21'
	limit 1) from uniqDates)
)
select startdate from uniqDates limit '2025-01-21'::date-'2024-01-20'::date;






--does not work 
with recursive uniqDates as 
(
	(select 1 as n, createdTime as startDate
	from Tasks_Dates
	where createdTime = '2024-01-20'
	limit 1)
	union all
	(select n+1 as n, startDate::date + n as startDate
	from Tasks_Dates, uniqDates
	where startDate is not null and startDate <= '2025-01-21'
	limit 1)
)
select * from uniqDates;



-- from 22.05.2024
drop table if exists Tasks_Dates;
create table Tasks_Dates(
task_id SERIAL primary key,
createdTime TIMESTAMP
)

insert into Tasks_Dates(createdTime) values
('2024-01-21'),
('2024-01-21'),
('2024-01-24'),
('2024-01-23'),
('2024-01-25'),
('2024-01-20');
select * from Tasks_Dates;
create index taskDate_index on Tasks_Dates(createdTime); 

with recursive Dates as 
(
(select  createdTime as StartDay,
 array[createdTime] as arr
 from Tasks_Dates
 where createdTime >= '2024-01-20' and createdTime <= '2025-01-21'
 limit 1)
 
 union all 
 
 (select Tasks_Dates.createdTime as StartDay,
 Dates.arr || Tasks_Dates.createdTime as arr
 from Tasks_Dates, Dates
 where
 Tasks_Dates.createdTime not in (select unnest(Dates.arr))
 and  Tasks_Dates.createdTime >= '2024-01-20' and Tasks_Dates.createdTime <= '2025-01-21'
 limit 1) 
)
--select * from Dates;
select startday from Dates;



-- redo with indexes

--insert into Tasks ("createdTime") values
--('2024-01-21 10:00:00'),
--('2024-01-21 11:00:00'),
--('2024-01-21 11:00:00'),
--('2024-01-21 11:00:00'),
--('2024-01-21 11:00:00'),
--('2024-01-24 09:00:00');


create table Tasks (
task_id SERIAL primary key,
createdTime TIMESTAMP
)

insert into Tasks (createdTime) values
('2024-01-21 10:00:00'),
('2024-01-21 11:00:00'),
('2024-01-24 09:00:00'),
('2024-01-23 10:00:00'),
('2024-01-25 11:00:00'),
('2024-01-20 09:00:00');

select * from Tasks;
 with recursive Dates as 
(
(select createdTime as StartDay, --1 as Num, --dont need it anymore 
 array[createdTime] as arr
 from Tasks
 where createdTime >= '2024-01-20' and createdTime <= '2025-01-21'--extract(month from createdTime)=1 
 limit 1)
 --initializing 
 union all
 (select Tasks.createdTime as StartDay, --Dates.Num + 1 as Num, --how does Dates.Num + 1 work?
  Dates.arr || Tasks.createdTime as arr
 from Tasks, Dates
 where
 Tasks.createdTime not in (select unnest(Dates.arr))
 --and month(Tasks.createdTime)=1 and Dates.Num + 1 < 31 
 and Tasks.createdTime >= '2024-01-20' and Tasks.createdTime <= '2025-01-21'
 limit 1) 
)
select unnest(Dates.arr) from Dates;




with recursive search_tasks AS (
    select 1 as counter, task_id, "createdTime" 
    from Tasks
    where DATE("createdTime") between '2024-01-01' and '2025-01-01'
    union
    select , 
    from Tasks t
    where counter < 31
    
)
SELECT task_id
FROM search_tasks st;

SELECT DATE("createdTime") AS task_date
FROM Tasks t
JOIN cte ON t.YEAR("createdTime") = cte.year AND t.MONTH("createdTime") = cte.month
ORDER BY task_date;



select DATE("createdTime") as task_date
from Tasks
where DATE("createdTime") BETWEEN '2024-01-01' AND '2024-01-31'
group by DATE("createdTime")
order by task_date;