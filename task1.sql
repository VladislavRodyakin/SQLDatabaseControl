-- N1
--get this into another create script
DROP TABLE IF EXISTS Users, Tasks, Projects;  -- to be able to run this multiple times

CREATE TABLE Users(
	name VARCHAR(32) NOT NULL,
	login VARCHAR(32),
	email VARCHAR(32),
	department VARCHAR(16) CHECK (department in ('Production', 'Support', 'Accounting', 'Administration')),
	is_fired INTEGER,
	PRIMARY KEY (login)
);

CREATE TABLE Projects(
	prj_index SERIAL,
	name VARCHAR(32), -- better index by serial
	description TEXT,
	date_on DATE NOT NULL,
	date_off DATE,
	PRIMARY KEY (prj_index) -- cant use pjr_index because foregein key must be char ??? why so
);

CREATE TABLE Tasks(
	project_index integer,
	project VARCHAR(32),
	header VARCHAR(32) NOT NULL,
	priority INTEGER NOT NULL,
	description TEXT,
	status VARCHAR(16) CHECK (status in ('new', 'reopened', 'closed', 'in process')) DEFAULT 'new' NOT NULL,
	estimate INTEGER,
	spent INTEGER,
	creator VARCHAR(32),
	responsible VARCHAR(32),
	sur_key SERIAL, -- autoincrement
	date_on DATE,
	FOREIGN KEY (project_index) REFERENCES Projects (prj_index) on delete CASCADE,
	FOREIGN KEY (creator) REFERENCES Users (login) on delete CASCADE,
	FOREIGN KEY (responsible) REFERENCES Users (login) on delete CASCADE,
	PRIMARY KEY (sur_key)
);



-- N2
INSERT INTO Users(name, login, email, department, is_fired)
VALUES ('Касаткин Артем', 'a.kasatkin', 'a.kasatkin@ya.ru', 'Administration', NULL),
	('Петрова София', 's.petrova', 's.petrova@ya.ru', 'Accounting', NULL),
	('Дроздов Федр', 'f.drozdov', 'f.drozdov@ya.ru', 'Production', NULL),
	('Иванова Василина', 'v.ivanova', 'v.ivanova@ya.ru', 'Accounting', NULL),
	('Беркут Алексей', 'a.berkut', 'a.berkut@ya.ru', 'Support', NULL),
	('Белова Вера', 'v.belova', 'v.belova@ya.ru', 'Support', NULL),
	('Макенрой Алексей', 'a.makenroy', 'a.makenroy@ya.ru', 'Administration', NULL);

INSERT INTO Projects(name, date_on, date_off)
VALUES ('РТК', '2016/01/31', NULL),
	('СС.Контент', '2015/02/23', '2016/12/31'),
	('Демо-Сибирь', '2015/05/11', '2015/01/31'),
	('МВД-Онлайн', '2015/05/22', '2016/01/31'),
	('Поддержка', '2016/06/07', NULL);

INSERT INTO Tasks(project, header, priority, status, creator, responsible, date_on, estimate, spent)
VALUES ('Поддержка', 'Task1', 12, 'new', 'a.berkut', 's.petrova', NULL, 10, 15),
	('Демо-Сибирь', 'Task2', 228, 'new', 'v.belova', 's.petrova', NULL, 52, 22),
	('Демо-Сибирь', 'Task3', 10, 'new', 'v.ivanova', 'a.makenroy', NULL, 1, 100),
	('РТК', 'Task4', 1337, 'new', 'a.makenroy', 's.petrova', NULL, 12, 12),
	('МВД-Онлайн', 'Task5', 61, 'new', 'a.berkut', NULL, NULL, 12, 22),
	('Поддержка', 'Task6', 127, 'new', 'a.makenroy', 's.petrova', NULL, 12, 12),
	('РТК', 'Task7', 19, 'new', 'a.makenroy', 'v.belova', NULL, 22, 35),
	('Демо-Сибирь', 'Task8', 1, 'new', 'a.makenroy', 's.petrova', NULL, 94, 12),
	('МВД-Онлайн', 'Task9', 1, 'new', 'v.ivanova', 'f.drozdov', NULL, 88, 24),
	('Демо-Сибирь', 'Task10', 11, 'new', 'a.makenroy', 'a.kasatkin', '2015/1/1', 99, 2),
	('РТК', 'Task11', 22, 'new', 'v.ivanova', 'a.berkut', '2016/4/1', NULL, NULL),
	('СС.Контент', 'Task12', 1, 'new', 'a.makenroy', 'a.kasatkin', '2015/8/2', 99, 2),
	('СС.Контент', 'Task13', 20, 'new', 'a.makenroy', 'a.kasatkin', '2015/8/3', 22, 3),
	('СС.Контент', 'Task14', 20, 'new', 'a.makenroy', NULL, '2015/12/3', NULL, NULL),
	('Демо-Сибирь', 'Task15', 3, 'new', 'a.makenroy', NULL, '2015/8/1', 66, 32);
	


-- N3
SELECT project, header, priority, status, creator, responsible, date_on, estimate, spent
FROM tasks;

-- N3b
SELECT name, department
FROM Users;

-- N3c
SELECT login, email
FROM Users;

-- N3d
SELECT project, header, priority, status, creator, responsible, date_on, estimate, spent
FROM tasks
WHERE priority > 50;

-- N3e
SELECT DISTINCT responsible
FROM tasks
WHERE responsible IS NOT NULL;

-- N3f
SELECT creator
FROM tasks
UNION
SELECT responsible
FROM tasks;

-- N3k
SELECT sur_key, header
FROM tasks
WHERE creator != 's.petrova'
  AND (responsible IN ('v.ivanova', 'a.makenroy', 'a.berkut'));
  
 
 
-- N4
SELECT project, header, priority, status, creator, responsible, date_on, estimate, spent
FROM tasks
WHERE responsible LIKE '%kasatkin%'
  AND date_on BETWEEN '2016/01/01%' AND '2016/01/03%';
 
 
-- N5
SELECT t.sur_key, t.header, d.department
FROM tasks t,
     users d
WHERE t.responsible LIKE '%petrov%'
  AND t.creator = d.login
  AND d.department IN ('Production', 'Accounting', 'Administration');
  
 
-- N6
SELECT project, header, priority, status, creator, responsible, date_on, estimate, spent
FROM tasks
WHERE responsible IS NULL;

UPDATE tasks
SET responsible = 's.petrova'
WHERE responsible IS NULL;


-- N7
DROP TABLE IF EXISTS tasks2;

CREATE TABLE tasks2 AS
select project, header, priority, status, creator, responsible, date_on, estimate, spent
FROM tasks;


-- N8
SELECT name, login, email, department, is_fired
FROM users
WHERE name NOT LIKE '%a'
  AND login LIKE 's%r%';
  
 
 
 
 
 
 
 
 
--for 6-4
DROP TABLE IF EXISTS Users2, Projects2, Task cascade;
CREATE TABLE Users2(
	userid bigserial not null primary key,
	name VARCHAR(32) NOT NULL,
	login VARCHAR(32),
	email VARCHAR(32),
	department VARCHAR(16) CHECK (department in ('Production', 'Support', 'Accounting', 'Administration')),
	is_fired INTEGER
);

CREATE TABLE Projects2(
	projectid SERIAL,
	name VARCHAR(32), -- better index by serial
	description TEXT,
	date_on DATE NOT NULL,
	date_off DATE,
	PRIMARY KEY (projectid) -- cant use pjr_index because foregein key must be char ??? why so
);
INSERT INTO Users2(name, login, email, department, is_fired)
VALUES ('Касаткин Артем', 'a.kasatkin', 'a.kasatkin@ya.ru', 'Administration', NULL),
	('Петрова София', 's.petrova', 's.petrova@ya.ru', 'Accounting', NULL),
	('Дроздов Федр', 'f.drozdov', 'f.drozdov@ya.ru', 'Production', NULL),
	('Иванова Василина', 'v.ivanova', 'v.ivanova@ya.ru', 'Accounting', NULL),
	('Беркут Алексей', 'a.berkut', 'a.berkut@ya.ru', 'Support', NULL),
	('Белова Вера', 'v.belova', 'v.belova@ya.ru', 'Support', NULL),
	('Макенрой Алексей', 'a.makenroy', 'a.makenroy@ya.ru', 'Administration', NULL);

INSERT INTO Projects2(name, date_on, date_off)
VALUES ('РТК', '2016/01/31', NULL),
	('СС.Контент', '2015/02/23', '2016/12/31'),
	('Демо-Сибирь', '2015/05/11', '2015/01/31'),
	('МВД-Онлайн', '2015/05/22', '2016/01/31'),
	('Алибаба-Эксп', '2015/05/22', '2016/01/31'),
	('Борова', '2015/05/22', '2016/01/31'),
	('Поддержка', '2016/06/07', NULL);