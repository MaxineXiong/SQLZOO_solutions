----Solutions to all questions in Neeps


---Neeps Easy Questions

--1) Give the room id in which the event co42010.L01 takes place.
SELECT room
FROM event
WHERE id = 'co42010.L01'

--2) For each event in module co72010 show the day, the time and the place.
SELECT dow, tod, room
FROM event
WHERE modle = 'co72010'

--3) List the names of the staff who teach on module co72010.
SELECT DISTINCT stf.name
FROM event AS e
JOIN teaches AS t
ON e.id = t.event
JOIN staff AS stf
ON stf.id = t.staff
WHERE e.modle = 'co72010'

--4)  Give a list of the staff and module number associated with events using room cr.132 on Wednesday, include the time each event starts.
SELECT stf.name, e.modle, e.tod 
FROM event AS e
JOIN teaches AS t
ON e.id = t.event
JOIN modle AS m
ON e.modle = m.id
JOIN staff AS stf
ON stf.id = t.staff
WHERE e.room = 'cr.132' AND dow = 'Wednesday'

--5) Give a list of the student groups which take modules with the word 'Database' in the name.
SELECT DISTINCT std.name
FROM event AS e
JOIN attends AS at
ON e.id = at.event
JOIN student AS std
ON at.student = std.id
JOIN modle AS m
ON e.modle = m.id
WHERE m.name LIKE '%Database%'


---Neeps Medium Questions

--6) Show the 'size' of each of the co72010 events. Size is the total number of students attending each event.
SELECT e.id, SUM(std.sze)
FROM event AS e
JOIN attends AS at
ON e.id = at.event
JOIN student AS std
ON at.student = std.id
WHERE e.modle = 'co72010'
GROUP BY e.id

--7) For each post-graduate module, show the size of the teaching team. (post graduate modules start with the code co7).
SELECT a.modle, COUNT(a.staff)
FROM 
	(SELECT DISTINCT e.modle, t.staff
	FROM event AS e
	JOIN teaches AS t
	ON e.id = t.event
	WHERE LEFT(e.modle, 3) = 'co7') AS a
GROUP BY a.modle

--8) Give the full name of those modules which include events taught for fewer than 10 weeks.
SELECT DISTINCT m.name
FROM event AS e
JOIN occurs AS o
ON e.id = o.event
JOIN modle AS m
ON e.modle = m.id
GROUP BY m.name, e.id
HAVING COUNT(o.week) < 10
ORDER BY e.id

--9) Identify those events which start at the same time as one of the co72010 lectures.
SELECT DISTINCT e1.id
FROM event AS e1
WHERE CONCAT(e1.dow, e1.tod) IN (SELECT CONCAT(e2.dow, e2.tod) FROM event AS e2 WHERE e2.modle = 'co72010')

--10) How many members of staff have contact time which is greater than the average?
SELECT COUNT(*)
FROM
	(SELECT t.staff, e.duration * COUNT(o.week) AS TotalHours
	FROM event AS e
	JOIN occurs AS o
	ON e.id = o.event
	JOIN teaches AS t
	ON e.id = t.event
	GROUP BY t.staff
	HAVING TotalHours > (SELECT AVG(a.TotalHours)
						FROM
						(SELECT t2.staff, e2.duration * COUNT(o2.week) AS TotalHours
						FROM event AS e2
						JOIN occurs AS o2
						ON e2.id = o2.event
						JOIN teaches AS t2
						ON e2.id = t2.event
						GROUP BY t2.staff) AS a)) AS b


---Neeps Hard Questions

--11) co.CHt is to be given all the teaching that co.ACg currently does. Identify those events which will clash.
SELECT DISTINCT z.ACg_id, z.CHt_id
FROM
	(SELECT x.id AS ACg_id, y.id AS CHt_id, x.week, x.dow, x.EventStart AS EventStart_ACg, x.EventEnd AS EventEnd_ACg, y.EventStart AS EventStart_CHt, y.EventEnd AS EventEnd_CHt
	FROM
		(SELECT e.id, o.week, e.dow, DATE_FORMAT(CASE e.dow WHEN 'Monday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR WHEN 'Tuesday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL 1 DAY WHEN 'Wednesday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL 2 DAY WHEN 'Thursday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL 3 DAY WHEN 'Friday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL 4 DAY ELSE NULL END, '%Y-%m-%d %H:%i:%S') AS EventStart, 
		DATE_FORMAT(CASE e.dow WHEN 'Monday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL e.duration HOUR WHEN 'Tuesday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL e.duration HOUR + INTERVAL 1 DAY WHEN 'Wednesday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL e.duration HOUR + INTERVAL 2 DAY WHEN 'Thursday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL e.duration HOUR + INTERVAL 3 DAY WHEN 'Friday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL e.duration HOUR + INTERVAL 4 DAY ELSE NULL END, '%Y-%m-%d %H:%i:%S') AS EventEnd
		FROM event AS e
		JOIN teaches AS t
		ON e.id = t.event
		JOIN occurs AS o
		ON e.id = o.event
		JOIN week AS w
		ON w.id = o.week
		WHERE t.staff = 'co.ACg'
		ORDER BY e.id, o.week, e.dow) AS x
		JOIN
		(SELECT e.id, o.week, e.dow, DATE_FORMAT(CASE e.dow WHEN 'Monday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR WHEN 'Tuesday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL 1 DAY WHEN 'Wednesday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL 2 DAY WHEN 'Thursday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL 3 DAY WHEN 'Friday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL 4 DAY ELSE NULL END, '%Y-%m-%d %H:%i:%S') AS EventStart, 
		DATE_FORMAT(CASE e.dow WHEN 'Monday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL e.duration HOUR WHEN 'Tuesday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL e.duration HOUR + INTERVAL 1 DAY WHEN 'Wednesday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL e.duration HOUR + INTERVAL 2 DAY WHEN 'Thursday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL e.duration HOUR + INTERVAL 3 DAY WHEN 'Friday' THEN w.wkstart + INTERVAL LEFT(e.tod, 2) HOUR + INTERVAL e.duration HOUR + INTERVAL 4 DAY ELSE NULL END, '%Y-%m-%d %H:%i:%S') AS EventEnd
		FROM event AS e
		JOIN teaches AS t
		ON e.id = t.event
		JOIN occurs AS o
		ON e.id = o.event
		JOIN week AS w
		ON w.id = o.week
		WHERE t.staff = 'co.CHt'
		ORDER BY e.id, o.week, e.dow) AS y
		ON x.week = y.week AND x.dow = y.dow
		WHERE (x.EventStart >= y.EventStart AND x.EventStart < y.EventEnd)
		OR (x.EventEnd > y.EventStart AND x.EventEnd <= y.EventEnd)
		OR (x.EventStart <= y.EventStart AND x.EventEnd >= y.EventEnd)) AS z
		