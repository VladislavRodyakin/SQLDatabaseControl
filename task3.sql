-- 3-1 
-- table level + 

drop table if exists a, b;

create table a
(
  id   serial primary key,
  data varchar(200)
);

create table b
(
  id   serial primary key,
  data varchar(32),
  aid  int,
  foreign key (aid) references a (id) on delete cascade
);

insert into b(data)
values ('alice'),
       ('bob');

insert into a(data)
values ('alice'),
       ('bob'),
       ('charlie'),
       ('dave');

insert into b(data)
values ('alise'),
       ('bob');

delete
from a
where data like 'alice';

update a
set id = 20
where id = 1;

-- SQL level ~
-- demonstrate without reference 
-- make sure inserted data not copies what already inside
-- on script level
drop table if exists a, b;
create table a(
  id   serial primary key,
  data varchar(32)
);

create table b(
  id   serial primary key,
  data varchar(32),
  aid  int
);


drop trigger if exists trig_del on a;
drop trigger if exists trig_upd on a;

create or replace function del_f() returns trigger as
$$
begin
  if tg_op = 'delete' then
    delete
    from b
    where b.aid = old.id;
    return old;
  end if;
end;
$$ language plpgsql;

create or replace function upd_f() returns trigger as
$$
begin
  if tg_op = 'update' then
    update b
    set aid = new.id
    where aid = old.id;
    return new;
  end if;
end;
$$ language plpgsql;

-- through triggers it is hard
-- redo as comparisons of selects
create trigger trig_del
  before delete
  on a
  for each row
execute procedure del_f();

create trigger trig_upd
  after update
  on a
  for each row
execute procedure upd_f();


insert into b(data)
values ('alice'),
       ('bob');

insert into a(data)
values ('alice'),
       ('bob'),
       ('charlie'),
       ('dave');

insert into b(data)
values ('some data'),
       ('for test');

delete
from a
where data like 'alice';

update a
set id = 2019
where id = 2;


--3-2 +
-- tables are incorrect, accepted by life examples 
drop table if exists a, b;

-- one to one
drop table if exists a, b;
create table a(
  id serial primary key
);

create table b(
  id int primary key,
  foreign key (id) references a (id) on delete cascade
);

-- one to many
drop table if exists a, b;
create table a(
  id serial primary key
);

create table b(
  id   serial primary key,
  a_id int,
  foreign key (a_id) references a (id) on delete cascade
);

-- many to many
drop table if exists a, b, a_b_link;
create table a(
  id serial primary key
);

create table b(
  id serial primary key
);

create table a_b_link(
  a_id int,
  b_id int,
  foreign key (a_id) references a (id) on delete cascade,
  foreign key (b_id) references b (id) on delete cascade,
  primary key (a_id, b_id)
);



-- 3-3 +
drop table if exists student, products, orders;

create table student(
  id serial primary key,
  name varchar(100),
  birth_date date,
  books varchar(40),
  age int -- excessive bc calculated from current time and date of birth 
);


-- bad example bc this is how it is done irl, for storing discount purchases and the likes
create table products(
  id serial primary key,
  name varchar(100),
  price numeric (10,2)
);
create table orders(
  id serial primary key,
  product_id int references products(id),
  where condition,
  quantity int,
  total_price numeric (10,2)
);
insert into products (name, price)
values
  ('productA', 10.00),
  ('productB', 20.00);
-- possible errors in update
insert into orders (product_id, quantity, total_price)
values
  (1, 5, 50.00),
  (1, 3, 30.00),
  (2, 3, 30.00);
select products.name, sum(orders.total_price) as sales
  from products
join orders on products.id = orders.product_id
group by products.name;



-- better
DROP TABLE IF EXISTS workers;

CREATE TABLE workers
(
  id             SERIAL PRIMARY KEY,
  name           VARCHAR(30),
  department     VARCHAR(30),
  phone          VARCHAR(11), 
  task           VARCHAR(30),
  books          VARCHAR(40),
  colleagues     VARCHAR(120),
  cluster_access BOOLEAN
);

INSERT INTO workers(name, department, phone, task, books, colleagues, cluster_access)
VALUES ('Daniil Yakovlev', 'Yandex', '79831033794', 'Decay Tree Fitter', 'Avery, Landau, CernROOT', 'Arsenty Melnikov, Pavel Lisenkov, vvorob, krokovny', TRUE),
       ('Pavel Lisenkov', 'JetBrains', '79888888888', 'Build plugin', 'Manual', 'Daniil Yakovlev, Arsenty Melnikov', TRUE),
       ('Arsenty Melnikov', 'JetBrains', '79999999999', 'Optimization TensorFlow', 'TF, keras', 'Daniil Yakovlev, Pavel Lisenkov', TRUE);
