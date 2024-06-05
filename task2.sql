-- 2-1 +
select distinct  
    t.priority, 
    t.responsible 
from tasks t,
    (select t.priority, t.responsible, 
            row_number() over (partition by t.responsible order by t.priority desc) as rn_high,
            row_number() over (partition by t.responsible order by t.priority) as rn_low
        from  
            tasks t 
    ) as tasks_with_rn
where  
    rn_high <= 3 or rn_low <= 3
order by 
    t.responsible, 
    t.priority desc;
 -- shows all tasks. why?
   

select distinct creator, "header", priority from tasks 
    where 
    (tasks.creator, tasks."header") in 
    (
        (select tasks_1.creator as creator, tasks_1."header" as task_name 
      	    from tasks as tasks_1 
      	    where tasks_1.creator = tasks.creator 
      	    order by priority desc 
        limit 3) 
      union 
        (select tasks_2.creator as creator, tasks_2."header" as task_name 
            from tasks as tasks_2 
      	    where tasks_2.creator = tasks.creator 
      	    order by priority asc 
      	limit 3)
    )  
order by creator, priority;
   


--2-2 +
select distinct concat(count(sur_key), ' - ', extract(month from date_on), ' - ', extract(year from date_on), ' - ', creator)
from tasks
where 
	date_on is not null
group by creator, responsible, date_on;
   

--2-3 +
select responsible as id_executor,
    sum((abs(-spent + estimate) - (-spent + estimate))/2) as "-",
    sum((abs(-spent + estimate) + (-spent + estimate))/2) as "+"
from tasks
group by responsible;
   
   
--2-4 +
--w/o least/greatest
select distinct
	least(responsible, creator) as login1, 
    greatest(responsible, creator) as login2
from tasks
where creator is not null and responsible is not null;


select creator, responsible
    from tasks
where creator is not null and responsible is not null
    and creator > responsible
union 
select creator, responsible --places may need to be swapped 
    from tasks
where creator is not null and responsible is not null
    and creator <= responsible


-- 2-5 +
select login, length(login) as length
from users
order by length desc
limit 1;



--2-6 +
drop table if exists char_varchar_demo;
create table char_varchar_demo (
	char_col char(20),
	varchar_col varchar(20)
	);
insert into char_varchar_demo (char_col, varchar_col)
	values ('len_test', 'len_test');
	
select octet_length (char_col) as char_len,
	octet_length (varchar_col) as varchar_len,
	pg_column_size(char_col) as char_col_size, 
	pg_column_size(varchar_col) as varchar_col_size from char_varchar_demo
--ocet_length returns number of bytes in a string
--pg_column_size returns amount of memory (disk space) used by coloumn


-- 2-7 +
select distinct creator, "header", priority from tasks 
  where 
    (tasks.creator, tasks."header") in 
    (
      (select tasks_1.creator as creator, tasks_1."header" as task_name 
      	from tasks as tasks_1 
      	where tasks_1.creator = tasks.creator 
      	order by priority desc 
      	limit 1) 
      union 
      (select tasks_2.creator as creator, tasks_2."header" as task_name 
      	from tasks as tasks_2 
      	where tasks_2.creator = tasks.creator 
      	order by priority asc 
      	limit 1)
    )  
  order by creator, priority;



-- 2-8 +
select responsible, sum(estimate)
from tasks,
     (select avg(estimate) as aver from tasks) as a
where estimate > a.aver
group by responsible, a.aver;



-- 2-9 +
-- must be in one view
drop view if exists user_task_statistics;
create view user_task_statistics as
select tasks.responsible    
    as responsible,

    count(tasks.responsible)    
    as amount,

    (select count(ontime_tasks.header)
        from (select header, responsible from tasks where (tasks.spent - tasks.estimate) >= 0)
        as ontime_tasks
    where ontime_tasks.responsible = tasks.responsible
    group by ontime_tasks.responsible)    
    as on_time,

    (select count(mistime_tasks.header)
    from (select header, responsible from tasks where (tasks.spent - tasks.estimate) < 0)
        as mistime_tasks
    where mistime_tasks.responsible = tasks.responsible
    group by mistime_tasks.responsible)    
    as late,

    (select count(opened_tasks.header)
    from (select header, responsible from tasks where tasks.status in ('new'))
        as opened_tasks
    where opened_tasks.responsible = tasks.responsible
    group by opened_tasks.responsible)    
    as opened,

    (select count(proceeding_tasks.header)
    from (select header, responsible from tasks where tasks.status in ('in process'))
        as proceeding_tasks
    where proceeding_tasks.responsible = tasks.responsible
    group by proceeding_tasks.responsible)    
    as proceeding,

    (select count(closed_tasks.header)
    from (select header, responsible from tasks where tasks.status in ('closed'))
        as closed_tasks
    where closed_tasks.responsible = tasks.responsible
    group by closed_tasks.responsible)    
    as closed,

    (select sum(spent_tasks.spent)
    from (select spent, responsible from tasks)
        as spent_tasks
    where spent_tasks.responsible = tasks.responsible
    group by spent_tasks.responsible)    
    as time_spent,

    (select avg(priority_tasks.priority)
    from (select priority, responsible from tasks)
        as priority_tasks
    where priority_tasks.responsible = tasks.responsible
    group by priority_tasks.responsible)    
    as pri,

    (select sum(estim_task.estimate)
    from (select estimate, responsible from tasks)
        as estim_task
    where estim_task.responsible = tasks.responsible 
    group by estim_task.responsible)    
    as total_estimate,

    (select max(max_time_t.spent)
    from (select spent, responsible from tasks)
        as max_time_t
    where max_time_t.responsible = tasks.responsible
    group by max_time_t.responsible)    
    as max_time

from tasks
group by tasks.responsible;

select *
from user_task_statistics;



--2-10 +
select tasks.header, users.login
from tasks, users
where tasks.creator = users.login;


select tasks.header, users.login
from (select header, creator from tasks) as tasks,
     (select login from users) as users
where users.login = tasks.creator;


select tasks.header, (select login from users where login = tasks.creator)
from tasks;

select header, creator
from tasks
where creator in (select login from users where login = tasks.creator);