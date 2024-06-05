--6.1
drop table if exists team;

create table team(
team_id serial primary key,
team_name varchar(100),
team_points int);	

insert into team(team_name, team_points)
values
	('BirdsOfPrey', 10),
	('ComandorsFinest', 210),
	('BigKings', 120);

select * from team;

begin;
	select team_points  
	from team
	where team_id  = 1
	for update; -- 1-1)from top to this
	update team 
	set team_points = team_points - 2
	where team_id = 2;
commit; -- 1-2) from 1-1 to this, locks up

begin;
	select team_points  
	from team 
	where team_id = 2
	for update;-- 2-1)from top to this
	update team 
	set team_points = team_points + 2
	where team_id = 1;
commit;-- 2-2) from 2-1 to this, error
--2-3) commit here to unlock


--6.2
--6.2.1 trasnaction
delete from team where team_id = 22;

begin;
	insert into team(team_id, team_name, team_points) values (22, 'GhostBusters', 80);
	savepoint save_point;
	update team 
	set team_points = team_points - 2
	where team_id = 3;
	rollback to savepoint save_point;
commit;

select * from team;

--6.2.3 recursion +
CREATE OR REPLACE FUNCTION RecursiveProcedure(n INT)
RETURNS INT AS $$
DECLARE
    result INT;
BEGIN
    IF n <= 1 THEN
        RETURN 1;
    ELSE
        result := n * RecursiveProcedure(n - 1);
        RETURN result;\\\
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT RecursiveProcedure(5);


--6.2.2 infinite loop
--calling deletion func in itself in 6-4


--6.3
-- Nodes table
drop table if exists nodes;
CREATE TABLE Nodes (
    node_id SERIAL PRIMARY KEY,
    parent_id INTEGER REFERENCES Nodes(node_id),
    name VARCHAR(255),
    type VARCHAR(255)
);


drop procedure if exists InsertNode(integer,varchar,varchar);
CREATE OR REPLACE PROCEDURE InsertNode(
    IN _parent_id INTEGER,
    IN _name VARCHAR(255),
    IN _type VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Nodes(parent_id, name, type)
    VALUES (_parent_id, _name, _type);
END;
$$;


DROP PROCEDURE IF EXISTS DeleteNode(INTEGER);
CREATE OR REPLACE PROCEDURE DeleteNode(
    IN arg_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    child_id INTEGER;
BEGIN
    -- getting id of the first child
    SELECT node_id INTO child_id FROM Nodes WHERE parent_id = arg_id LIMIT 1;
    
    -- recursively deleting child's children
    IF child_id IS NOT NULL THEN
        CALL DeleteNode(child_id);
        DELETE FROM Nodes WHERE node_id = child_id;
    END IF;
    
    -- deleting current node
    DELETE FROM Nodes WHERE node_id = arg_id;
END;
$$;


DROP PROCEDURE IF EXISTS MoveNode(INTEGER, INTEGER);
CREATE OR REPLACE PROCEDURE MoveNode(
    IN arg_id INTEGER,
    IN new_parent_id INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Nodes SET parent_id = new_parent_id WHERE node_id = arg_id;
END;
$$;


DROP function if exists GetPathToRoot(integer);
CREATE OR REPLACE FUNCTION GetPathToRoot(arg_id INTEGER)
RETURNS VARCHAR(255)
LANGUAGE plpgsql
AS $$
DECLARE
    path_to_root CHAR(255) := '';
    current_node_id INTEGER := arg_id;
    node_name CHAR(255);
    parent_node_id INTEGER;
BEGIN
    WHILE current_node_id IS NOT NULL LOOP
        SELECT name, parent_id INTO node_name, parent_node_id
        FROM Nodes
        WHERE node_id = current_node_id;
        path_to_root := '/' || node_name || path_to_root;

        current_node_id := parent_node_id;
    END LOOP;
    
    RETURN path_to_root;
END;
$$;


call InsertNode(null, 'root', 'folder');
call InsertNode(12, 'home', 'folder');
call InsertNode(13, 'test', 'folder');
call InsertNode(14, 'test2', 'folder');
call InsertNode(15, 'test3', 'folder');
call DeleteNode(15);
call MoveNode(14, 13);
select GetPathToRoot(100);

select * from Nodes;




--6.4
select * from users2;
select * from projects2;

drop table if exists task;

create table task(
id bigserial not null primary key,
project_id bigint not null,
title varchar(30) not null,
priority bigint not null,
description varchar(100),
status varchar(30) check(status in ('Новое','Переоткрыта','Выполняется','Закрыта')),
evaluation decimal(8,2) not null,
task_cost interval hour not null,
date_start date not null,
date_finish date,
creator_id bigint not null,
producer_id bigint,
foreign key (creator_id) references users2 (userid) on delete cascade,
foreign key (project_id) references projects2 (projectid) on delete cascade,
foreign key (producer_id) references users2 (userid) on delete set null
)




insert into task(project_id, title, priority, description, status, evaluation, task_cost, date_start, date_finish, creator_id, producer_id )
values 
	(3, 'Newage rocket', 10, 'To dominate in Universe we ...', 'Выполняется', 1000.00,  '70','2016-01-02', null, 1, 7),
	(6, 'Experience', 7, 'Have fun with Airbnb.', 'Новое', 570.00, '30','2022-01-01', null,  3, null),
	(2, 'Salary', 2, 'Reestimate employees salaries', 'Переоткрыта', 321.50, '40','2022-02-12', null,  3, 2),
	(5, 'Открытое окно', 57, null, 'Переоткрыта', 37000.00, '140','2016-01-03', '2017-03-02' , 1, 6),
	(4, 'Чат-бот', 70, 'Нужен для улучшения взаимодействия клиента с приложением', 'Выполняется', 57000.00, '240','2021-11-21', null,  3, 5),
	(3, 'Кабель', 51, 'На чиле', 'Закрыта', 321.50, '40', '2016-01-01', '2016-03-01', 1, 7),
	(2, 'C1', 57, null, 'Новое', 300.00, '140', '2022-02-12', null, 2, 7),
	(4, 'Кряк', 70, 'Хайп', 'Выполняется', 57.00, '240', '2021-07-07', '2023-06-27', 3, 5),
	(3, 'Чат-бот тесты', 51, 'Тестировка', 'Новое', 321.50, '40', '2022-01-02', '2022-03-02', 5, 5),
	(4, 'Бух.учет', 70, null, 'Закрыта', 57.00, '240', '2021-07-07', '2021-07-27', 4, 2),
	(3, 'Налоговая Декларация', 51, 'Экспорт товара', 'Новое', 321.50, '40', '2022-02-02', '2022-03-02', 6, 2);
	
select * from task;

select * from projects;
drop table if exists history;
create table history(
id serial not null primary key,
task_id int,
task_history_status varchar(30),
modification_date date,
project_id bigint not null,
title varchar(30) not null,
priority bigint not null,
description varchar(100),
status varchar(30) check(status in ('Новое','Переоткрыта','Выполняется','Закрыта')),
evaluation decimal(8,2) not null,
task_cost interval hour not null,
date_start date not null,
date_finish date,
creator_id bigint not null,
producer_id bigint,
foreign key (creator_id) references users2 (userid) on delete cascade,
foreign key (project_id) references projects2 (projectid) on delete cascade,
foreign key (producer_id) references users2 (userid) on delete set null
)


-- save on modification
create or replace function save_changes() returns trigger as $$ -- function that is called by trigger or smth
declare
tid int;
help_str varchar;
prid int;
ttitle varchar(30);
tpriority int;
tdesc varchar(30);
tstat varchar(30);
teval decimal(8,2);
tcost interval hour;
tsd date;
tdf date;
tcid int;
tpid int;
begin 
	select task.id from task into tid where task.id = old.id;
	select task.project_id from task into prid where task.id = old.id;
	select task.title from task into ttitle where task.id = old.id;
	select task.priority from task into tpriority where task.id = old.id;
	select task.description from task into tdesc where task.id = old.id;
	select task.status from task into tstat where task.id = old.id;
	select task.evaluation from task into teval where task.id = old.id;
	select task.task_cost from task into tcost where task.id = old.id;
	select task.date_start from task into tsd where task.id = old.id;
	select task.date_finish from task into tdf where task.id = old.id;
	select task.creator_id from task into tcid where task.id = old.id;
	select task.producer_id from task into tpid where task.id = old.id;
	delete from task where id = old.id;
	insert into history(task_id, task_in_status, modification_date, project_id, title, priority, description, status, evaluation, task_cost, date_start, date_finish, creator_id, producer_id)
	values (tid, 'Сохранено', now()::date, prid, ttitle, tpriority, tdesc, tstat, teval, tcost, tsd, tdf, tcid, tpid);
	return new;
end;
$$ language plpgsql 


drop trigger if exists trigger_save on task;
create trigger trigger_save
	before update
	on task 
	for each row
execute procedure save_changes();

update task set priority = priority + 2 where id = 7; -- trigger triggers
select * from task where id = 7;
select * from task;
select * from history 


-- deleting task and saving as a change
create or replace function delete_and_save() returns trigger as $$
declare
    task_row task%rowtype;
begin
    select * into task_row from task where id = old.id;
	delete from task where id = old.id;
    insert into history(task_id, task_in_status, modification_date, project_id, title, priority, description, status, evaluation, task_cost, date_start, date_finish, creator_id, producer_id)
    values (task_row.id, 'Удалено', now()::date, task_row.project_id, task_row.title, task_row.priority, task_row.description, task_row.status, task_row.evaluation, task_row.task_cost, task_row.date_start, task_row.date_finish, task_row.creator_id, task_row.producer_id);
	
   	--for 6.2.2
   	--execute delete_and_save();
   
    return old;
end;
$$ language plpgsql;


drop trigger if exists trigger_delete on task;
create trigger trigger_delete
	before delete
	on task 
	for each row
execute procedure delete_and_save();

delete from task where id = 4; 
select * from task where id = 4;
select * from history


DROP function if exists deleted_tasks_list();
create or replace function deleted_tasks_list()
returns table(task_id int, task_history_status varchar(20), modification_date date) as $$
begin 
	return query select history.task_id, history.task_history_status, history.modification_date from history
	where history.task_history_status = 'Удалено';
	if not found then 
	raise exception 'No file found'; -- if we didn't deleted anything yet
	end if;
end;
$$ language plpgsql 


select deleted_tasks_list();


CREATE OR REPLACE FUNCTION restore_deleted_tasks()
RETURNS VOID AS $$
DECLARE
    task_record history%ROWTYPE; -- single full (all cols) row from table
BEGIN
    -- iterating through history table, where task status is "Удалено"
    FOR task_record IN
        SELECT DISTINCT ON (task_id) * FROM history WHERE task_in_status = 'Удалено'
    LOOP
        -- restoring task in Task table
        INSERT INTO task(id, project_id, title, priority, description, status, evaluation, task_cost, date_start, date_finish, creator_id, producer_id)
        VALUES (task_record.task_id, task_record.project_id, task_record.title, task_record.priority, task_record.description, task_record.status, task_record.evaluation, task_record.task_cost, task_record.date_start, task_record.date_finish, task_record.creator_id, task_record.producer_id);
    END LOOP;
END;
$$ LANGUAGE plpgsql;


select restore_deleted_tasks();
select * from task



