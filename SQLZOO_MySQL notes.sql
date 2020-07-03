---POSITION() in MySQL = CHARINDEX() in T-SQL
SELECT POSITION('A' IN '15426Afdsfd')


---ALTER TABLE
--add column
ALTER TABLE testTable
ADD customer varchar(25)
--drop column
ALTER TABLE testTable
DROP COLUMN customer
--ALTER COLUMN in T-SQL
ALTER TABLE testTable
ALTER COLUMN customer nvarchar(max)
--ALTER COLUMN in MySQL
ALTER TABLE testTable
MODIFY COLUMN customer nvarchar(max)


---CREATE TABLE in MySQL when multiple columns are set to be PRIMARY KEY
CREATE TABLE track (album char(10) NOT NULL, dsk int NOT NULL, posn int NOT NULL, song varchar(255), PRIMARY KEY(album, dsk, posn))

----identity column in different SQLs
--1) T-SQL
CREATE TABLE t_sql_test(id int IDENTITY PRIMARY KEY, name varchar(10), city varchar(10))
INSERT INTO t_sql_test
VALUES
('Andrew', 'Paris'),
('Gordon', 'LA')
--2) SQLITE
CREATE TABLE sql_lite_test(id INTEGER PRIMARY KEY, name varchar(10), city varchar(10))
INSERT INTO sql_lite_test
VALUES
(NULL, 'Andrew', 'Paris'),
(NULL, 'Gordon', 'LA')
--3) PostgreSQL
CREATE TABLE postgre_sql_test(id SERIAL PRIMARY KEY, name varchar(10), city varchar(10))
INSERT INTO postgre_sql_test(name, city)
VALUES
('Andrew', 'Paris'),
('Gordon', 'LA')
--4) MySQL
CREATE TABLE mysql_test(id int AUTO_INCREMENT PRIMARY KEY, name varchar(10), city varchar(10))
INSERT INTO mysql_test(name, city)
VALUES
('Andrew', 'Paris'),
('Gordon', 'LA')


----Rename Column in MySQL
CREATE TABLE a(x int)

INSERT INTO a
VALUES
(2)

ALTER TABLE a
CHANGE x y int

SELECT * FROM a


----String contains a quote '
INSERT INTO t_q
VALUE
('O''Brian')


----Unpivot in T-SQL vs MySQL
--1) Unpivot in T-SQL
CREATE TABLE #TestTable1(ProductCategoryID int, Black decimal(10, 2), Blue decimal(10, 2), Grey decimal(10, 2), Multi decimal(10, 2), None decimal(10, 2), Red decimal(10, 2), Silver decimal(10, 2), Silver_Black decimal(10, 2), White decimal(10, 2), Yellow decimal(10, 2))
INSERT INTO #TestTable1
SELECT *
FROM
	(SELECT ProductCategoryID, ISNULL(Color, 'None') AS Color, ListPrice
	 FROM SalesLT.Product) AS BP
	PIVOT
	(AVG(ListPrice) FOR Color IN ([Black], [Blue], [Grey], [Multi], [None], [Red], [Silver], [Silver/Black], [White], [Yellow])) AS AP

SELECT * FROM #TestTable1

SELECT ProductCategoryID, Color, AvgListPrice
FROM
	(SELECT ProductCategoryID, Black, Blue, Grey, Multi, None, Red, Silver, Silver_Black, White, Yellow
	 FROM #TestTable1) AS BUP
	UNPIVOT
	(AvgListPrice FOR Color IN (Black, Blue, Grey, Multi, None, Red, Silver, Silver_Black, White, Yellow)) AS AUP

--2) Unpivot in MySQL
CREATE TABLE normal(Line varchar(1), Col int, Val int, PRIMARY KEY(Line, Col));

INSERT INTO normal
SELECT Line, 'F1', F1 FROM unnormal
UNION
SELECT Line, 'F2', F2 FROM unnormal
UNION
SELECT Line, 'F3', F3 FROM unnormal
UNION
SELECT Line, 'F4', F4 FROM unnormal;

SELECT * FROM normal ORDER BY Line



----Pivot in T-SQL vs MySQL
--1) Pivot in T-SQL
CREATE TABLE #TestTable2(ProductCategoryID int, Black decimal(10, 2), Blue decimal(10, 2), Grey decimal(10, 2), Multi decimal(10, 2), None decimal(10, 2), Red decimal(10, 2), Silver decimal(10, 2), Silver_Black decimal(10, 2), White decimal(10, 2), Yellow decimal(10, 2))
INSERT INTO #TestTable2
SELECT *
FROM
	(SELECT ProductCategoryID, ISNULL(Color, 'None') AS Color, ListPrice
	 FROM SalesLT.Product) AS BP
	 PIVOT
	(AVG(ListPrice) FOR Color IN ([Black], [Blue], [Grey], [Multi], [None], [Red], [Silver], [Silver/Black], [White], [Yellow])) AS AP

--2) Pivot in MySQL
SELECT name, MAX(IF(course='Java', grade, NULL)) AS Java, MAX(IF(course='Database', grade, NULL)) AS DB, MAX(IF(course='Algebra', grade, NULL)) AS Algebra
FROM exam AS ex
JOIN courseGrade AS cg
ON ex.name = cg.student
GROUP BY name



----DATEDIFF in MySQL vs T-SQL
--1) T-SQL
PRINT DATEDIFF(mm, GETDATE(), '2011/08/25')
--2) MySQL
SELECT DATEDIFF(NOW(), '2011/08/25')



----INTERVAL in MySQL
SELECT *
FROM totp
WHERE '1976-05-20' BETWEEN wk - INTERVAL 7 DAY AND wk 


----DATENAME in T-SQL vs DAYNAME, MONTHNAME in MySQL
--1a) Day of Week name in T-SQL 
PRINT DATENAME(dw, GETDATE())
--1b) Day of Week name in MySQL
SELECT DAYNAME(NOW())
--2a) Month Name in T-SQL
PRINT DATENAME(mm, GETDATE())
--2b) Month Name in MySQL
SELECT MONTHNAME(NOW())



----TOP in T-SQL vs LIMIT in MySQL
--1) TOP in T-SQL
SELECT TOP 3 *
FROM people
ORDER BY birthday ASC
--2) LIMIT in MySQL
SELECT *
FROM people
ORDER BY birthday ASC
LIMIT 3


----OFFSET...FETCH... in T-SQL vs LIMIT in MySQL
--1) OFFSET...FETCH... in T-SQL
SELECT *
FROM bbc
ORDER BY population DESC
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY
--2) LIMIT in MySQL
SELECT *
FROM bbc
ORDER BY population DESC
LIMIT 11, 10



----GROUP BY ROLLUP in T-SQL vs GROUP BY...WITH ROLLUP in MySQL
--1) GROUP BY ROLLUP in T-SQL
SELECT item, serialnumber, SUM(price)
FROM serial
GROUP BY ROLLUP(item, serialnumber)
--2) GROUP BY...WITH ROLLUP in MySQL
SELECT item, serialnumber, SUM(price)
FROM serial
GROUP BY item, serialnumber WITH ROLLUP

