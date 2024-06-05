--4-1
drop table if exists a, b;

create table a(
    common int,
    a_data varchar(100)
);

create table b(
    common int,
    b_data varchar(100)
);

insert into a (common, a_data)
values (1, 'a_data1'),
       (2, 'a_data2');

insert into b (common, b_data)
values (1, 'b_data1'),
       (3, 'b_data2'),
       (1, 'b_data3');

select *
from a
     full outer join b on a.common = b.common
where a.common is null
   or b.common is null;

select *
from a
     full outer join b on a.common = b.common;

select *
from a
     inner join b on a.common = b.common;

select *
from a
     left join b on a.common = b.common;

select *
from a
     left outer join b on a.common = b.common
where b.common is null;

select *
from a
     right join b on a.common = b.common;

select *
from a
     right outer join b on a.common = b.common
where a.common is null;

create table c(
    common int,
    c_data varchar(100)
);

-- test this
drop table if exists c;
insert into c (common, c_data)
values (2, 'c_data1'),
       (1, 'c_data2'),
       (5, 'c_data3'),
       (3, 'c_data4'),
       (2, 'c_data5');

select *
from (
     select * as a_b
     from a
          full outer join b on a.common = b.common
     where a.common is null or b.common is null;
)
     inner join c on a_b.common = c.common;

select *
from (
     select * as a_b
     from a
          inner join b on a.common = b.common;
)
     inner join c on a_b.common = c.common;

 

-- 4-2 + 
select sur_key, header
from tasks as out
where priority = (select max(priority) from tasks as int where int.creator = out.creator);

select b.sur_key, b.header
from tasks as a,
     tasks as b
where a.creator = b.creator
group by b.sur_key, a.creator
having max(a.priority) = b.priority;

-- proof that we need 2 tables
select sur_key, header
from tasks
group by sur_key, creator
having max(priority) = priority;


-- 4-3 +
select login
from users
where login not in (
    select responsible 
    from tasks 
    where responsible is not null);

select distinct login
from users
    left outer join tasks as t on users.login = t.responsible
where t.responsible is null;

select distinct u.login
from users as u
where (
    select distinct responsible
    from tasks as t
    where t.responsible = u.login and responsible is not null
    ) is null;


-- 4-4 +
select distinct date_on
     from projects
union
select distinct date_off
     from projects


-- 4-5 +
select p.name, t.header
from tasks as t,
    projects as p;

select p.name, t.header
from tasks as t
    cross join projects as p;
