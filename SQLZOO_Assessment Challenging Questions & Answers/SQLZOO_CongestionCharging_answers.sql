----Solutions to all questions in Congestion Charging


---Congestion Charging Easy Questions

--1) Show the name and address of the keeper of vehicle SO 02 PSP.
SELECT k.name, k.address
FROM keeper AS k
JOIN vehicle AS v
ON k.id = v.keeper
WHERE v.id = 'SO 02 PSP'

--2) Show the number of cameras that take images for incoming vehicles.
SELECT COUNT(*)
FROM camera
WHERE perim = 'IN'

--3) List the image details taken by Camera 10 before 26 Feb 2007.
SELECT *
FROM image
WHERE DATE_FORMAT(whn, '%Y-%m-%d') < '2007-02-26' AND camera = 10

--4) List the number of images taken by each camera. Your answer should show how many images have been taken by camera 1, camera 2 etc. The list must NOT include the images taken by camera 15, 16, 17, 18 and 19.
SELECT camera, COUNT(*)
FROM image
WHERE camera NOT IN (15, 16, 17, 18, 19)
GROUP BY camera

--5) A number of vehicles have permits that start on 30th Jan 2007. List the name and address for each keeper in alphabetical order without duplication.
SELECT DISTINCT k.name, k.address
FROM vehicle AS v
JOIN permit AS p
ON v.id = p.reg
JOIN keeper AS k
ON v.keeper = k.id
WHERE DATE_FORMAT(p.sDate, '%Y-%m-%d') = '2007-01-30'
ORDER BY name


---Congestion Charging Medium Questions

--1) List the owners (name and address) of Vehicles caught by camera 1 or 18 without duplication.
SELECT DISTINCT k.name, k.address
FROM vehicle AS v
JOIN keeper AS k
ON v.keeper = k.id
JOIN image AS i
ON v.id = i.reg
WHERE i.camera IN (1, 18)

--2) Show keepers (name and address) who have more than 5 vehicles.
SELECT k.name, k.address, COUNT(v.id)
FROM keeper AS k
JOIN vehicle AS v
ON k.id = v.keeper
GROUP BY k.name, k.address
HAVING COUNT(v.id) > 5

--3) For each vehicle show the number of current permits (suppose today is the 1st of Feb 2007). The list should include the vehicle.s registration and the number of permits. Current permits can be determined based on charge types, e.g. for weekly permit you can use the date after 24 Jan 2007 and before 02 Feb 2007.
SELECT x.reg, COUNT(*)
FROM
(SELECT p.reg, p.chargeType, p.sDate, CASE p.chargeType WHEN 'Daily' THEN p.sDate + INTERVAL 1 DAY WHEN 'Weekly' THEN p.sDate + INTERVAL 1 WEEK WHEN 'Monthly' THEN p.sDate + INTERVAL 1 MONTH WHEN 'Annual' THEN p.sDate + INTERVAL 1 YEAR ELSE NULL END AS permit_expr
FROM vehicle AS v
JOIN permit AS p
ON v.id = p.reg) AS x
WHERE '2007-02-01' BETWEEN DATE_FORMAT(x.sDate, '%Y-%m-%d') AND DATE_FORMAT(x.permit_expr, '%Y-%m-%d')
GROUP BY x.reg

--4) Obtain a list of every vehicle passing camera 10 on 25th Feb 2007. Show the time, the registration and the name of the keeper if available.
SELECT DATE_FORMAT(i.whn, '%Y-%m-%d %H:%i:%S') AS time, i.reg, k.name
FROM vehicle AS v
JOIN image AS i
ON v.id = i.reg
JOIN keeper AS k
ON k.id = v.keeper
WHERE i.camera = 10 AND DATE_FORMAT(i.whn, '%Y-%m-%d') = '2007-02-25'

--5) List the keepers who have more than 4 vehicles and one of them must have more than 2 permits. The list should include the names and the number of vehicles.
SELECT x.name, x.NumVehic
FROM
(SELECT k.name, v.keeper, COUNT(*) AS NumVehic
FROM vehicle AS v
JOIN keeper AS k
ON v.keeper = k.id
GROUP BY k.name, k.address
HAVING COUNT(*) > 4) AS x
JOIN
(SELECT v.keeper, p.reg, COUNT(*) AS NumPermit
FROM vehicle AS v
JOIN permit AS p
ON v.id = p.reg
GROUP BY v.keeper, p.reg
HAVING COUNT(*) > 2) AS y
ON x.keeper = y.keeper


---Congestion Charging Hard Questions

--2) There are four types of permit. The most popular type means that this type has been issued the highest number of times. Find out the most popular type, together with the total number of permits issued.
SELECT chargeType, COUNT(*) AS NumTimes
FROM permit
GROUP BY chargeType
ORDER BY NumTimes DESC
LIMIT 1

--3) For each of the vehicles caught by camera 19 - show the registration, the earliest time at camera 19 and the time and camera at which it left the zone.
SELECT x.reg, x.EarlyCaught, y.LeftCamera, y.LeftTime
FROM
(SELECT i.reg, MIN(i.whn) AS EarlyCaught
FROM vehicle AS v
JOIN image AS i
ON v.id = i.reg
JOIN camera AS c
ON i.camera = c.id
WHERE i.camera = 19
GROUP BY v.id) AS x
JOIN
(SELECT i.reg, i.camera AS LeftCamera, i.whn AS LeftTime
FROM vehicle AS v
JOIN image AS i
ON v.id = i.reg
JOIN camera AS c
ON c.id = i.camera
WHERE c.perim = 'OUT') AS y
ON x.reg = y.reg
WHERE y.LeftTime > x.EarlyCaught

--4) For all 19 cameras - show the position as IN, OUT or INTERNAL and the busiest hour for that camera.
SELECT a.id, a.position, b.Hour AS BusyHour
FROM
(SELECT DISTINCT c.id, IFNULL(c.perim, 'INTERNAL') AS position
FROM camera AS c
JOIN image AS i
ON c.id = i.camera
ORDER BY c.id, position) AS a
JOIN
(SELECT x.id, x.Hour
FROM
(SELECT c.id, DATE_FORMAT(whn, '%H') AS Hour, COUNT(whn) AS HourCount, RANK() OVER (PARTITION BY c.id ORDER BY COUNT(whn) DESC) AS Rank
FROM camera AS c
JOIN image AS i
ON c.id = i.camera
GROUP BY c.id, DATE_FORMAT(whn, '%H')) AS x
WHERE x.Rank = 1) AS b
ON a.id = b.id
ORDER BY a.id, a.position, BusyHour

--5) Anomalous daily permits. Daily permits should not be issued for non-charging days. Find a way to represent charging days. Identify the anomalous daily permits.
SELECT *
FROM permit
WHERE chargeType = 'Daily' AND DAYOFWEEK(sDate) IN (1, 7);

--6) Issuing fines: Vehicles using the zone during the charge period, on charging days must be issued with fine notices unless they have a permit covering that day. List the name and address of such culprits, give the camera and the date and time of the first offence.
SELECT y.name, y.address, y.reg, y.FirstTime, i2.camera
FROM
(SELECT x.name, x.address, x.reg, MIN(x.whn) AS FirstTime 
FROM
(SELECT a.name, a.address, a.reg, a.whn, b.sDate, b.permit_expr
FROM
(SELECT k.name, k.address, i.reg, c.id, i.whn
FROM vehicle AS v
JOIN image AS i
ON v.id = i.reg
JOIN keeper AS k
ON v.keeper = k.id
JOIN camera AS c
ON c.id = i.camera
WHERE DAYOFWEEK(i.whn) NOT IN (1, 7)
ORDER BY k.name, k.address, i.reg) AS a
LEFT JOIN
(SELECT DISTINCT k.name, k.address, p.reg, p.sDate, CASE p.chargeType WHEN 'Daily' THEN p.sDate + INTERVAL 1 DAY WHEN 'Weekly' THEN p.sDate + INTERVAL 1 WEEK WHEN 'Monthly' THEN p.sDate + INTERVAL 1 MONTH WHEN 'Annual' THEN p.sDate + INTERVAL 1 YEAR ELSE NULL END AS permit_expr
FROM vehicle AS v
JOIN permit AS p
ON v.id = p.reg
JOIN keeper AS k
ON k.id = v.keeper
WHERE DAYOFWEEK(p.sDate) NOT IN (1, 7)) AS b
ON a.name = b.name AND a.address = b.address AND a.reg = b.reg
WHERE b.sDATE IS NULL) AS x
GROUP BY x.name, x.address, x.reg) AS y
JOIN image AS i2
ON y.reg = i2.reg AND y.FirstTime = i2.whn