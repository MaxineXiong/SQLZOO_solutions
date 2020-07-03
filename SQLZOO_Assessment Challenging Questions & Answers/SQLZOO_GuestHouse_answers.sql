----Solutions to all questions in Guest House


---Guest House Easy Questions

--1) Guest 1183. Give the booking_date and the number of nights for guest 1183.
SELECT DATE_FORMAT(booking_date, '%Y-%m-%d') AS booking_date, nights
FROM booking
WHERE guest_id = '1183'

--2) When do they get here? List the arrival time and the first and last names for all guests due to arrive on 2016-11-05, order the output by time of arrival.
SELECT bk.arrival_time, gst.first_name, gst.last_name
FROM booking AS bk
JOIN guest AS gst
ON bk.guest_id = gst.id
WHERE bk.booking_date = '2016-11-05'
ORDER BY arrival_time

--3) Look up daily rates. Give the daily rate that should be paid for bookings with ids 5152, 5165, 5154 and 5295. Include booking id, room type, number of occupants and the amount.
SELECT bk.booking_id, bk.room_type_requested, bk.occupants, ROUND(rt.amount, 2) AS amount
FROM booking AS bk
JOIN rate AS rt
ON bk.room_type_requested = rt.room_type AND bk.occupants = rt.occupancy
WHERE bk.booking_id IN (5152, 5165, 5154, 5295)

--4) Who’s in 101? Find who is staying in room 101 on 2016-12-03, include first name, last name and address.
SELECT gst.first_name, gst.last_name, gst.address
FROM booking AS bk
JOIN guest AS gst
ON bk.guest_id = gst.id
WHERE bk.room_no = 101 AND DATE_FORMAT(bk.booking_date, '%Y-%m-%d') = '2016-12-03'

--5) How many bookings, how many nights? For guests 1185 and 1270 show the number of bookings made and the total number of nights. Your output should include the guest id and the total number of bookings and the total number of nights.
SELECT guest_id, COUNT(nights), SUM(nights)
FROM booking
WHERE guest_id IN (1185, 1270)
GROUP BY guest_id


---Guest House Medium Questions

--6) Ruth Cadbury. Show the total amount payable by guest Ruth Cadbury for her room bookings. You should JOIN to the rate table using room_type_requested and occupants.
SELECT SUM(bk.nights * rt.amount)
FROM booking AS bk
JOIN guest AS gst
ON bk.guest_id = gst.id
JOIN rate AS rt
ON bk.room_type_requested = rt.room_type AND bk.occupants = rt.occupancy
WHERE gst.first_name = 'Ruth' AND gst.last_name = 'Cadbury'
GROUP BY gst.first_name, gst.last_name

--7) Including Extras. Calculate the total bill for booking 5346 including extras.
SELECT a.extra + b.standard
FROM
	(SELECT gst.first_name, gst.last_name, SUM(ext.amount) AS extra
	FROM booking AS bk
	JOIN guest AS gst
	ON bk.guest_id = gst.id
	JOIN rate AS rt
	ON bk.room_type_requested = rt.room_type AND bk.occupants = rt.occupancy
	JOIN extra AS ext
	ON bk.booking_id = ext.booking_id
	WHERE bk.booking_id = 5346
	GROUP BY gst.first_name, gst.last_name) AS a
	JOIN
	(SELECT gst.first_name, gst.last_name, bk.nights * rt.amount AS standard
	FROM booking AS bk
	JOIN guest AS gst
	ON bk.guest_id = gst.id
	JOIN rate AS rt
	ON bk.room_type_requested = rt.room_type AND bk.occupants = rt.occupancy
	WHERE bk.booking_id = 5346) AS b
	ON a.first_name = b.first_name AND a.last_name = b.last_name

--8) Edinburgh Residents. For every guest who has the word “Edinburgh” in their address show the total number of nights booked. Be sure to include 0 for those guests who have never had a booking. Show last name, first name, address and number of nights. Order by last name then first name.
SELECT gst.last_name, gst.first_name, gst.address, SUM(IFNULL(bk.nights, 0))
FROM guest AS gst
LEFT JOIN booking AS bk
ON gst.id = bk.guest_id
WHERE gst.address LIKE '%Edinburgh%'
GROUP BY gst.last_name, gst.first_name, gst.address

--9) How busy are we? For each day of the week beginning 2016-11-25 show the number of bookings starting that day. Be sure to show all the days of the week in the correct order.
SELECT DATE_FORMAT(booking_date, '%Y-%m-%d'), COUNT(booking_id)
FROM booking
WHERE DATE_FORMAT(booking_date, '%Y-%m-%d') BETWEEN '2016-11-25' AND '2016-12-01' 
GROUP BY DATE_FORMAT(booking_date, '%Y-%m-%d')
ORDER BY booking_date

--10) How many guests? Show the number of guests in the hotel on the night of 2016-11-21. Include all occupants who checked in that day but not those who checked out.
SELECT SUM(occupants)
FROM booking
WHERE DATE_FORMAT(booking_date + INTERVAL nights DAY, '%Y-%m-%d') > '2016-11-21' 
AND DATE_FORMAT(booking_date, '%Y-%m-%d') <= '2016-11-21'


---Guest House Hard Questions

--11) Coincidence. Have two guests with the same surname ever stayed in the hotel on the evening? Show the last name and both first names. Do not include duplicates.
SELECT x.last_name, x.name1 AS first_name, x.name2 AS first_name
FROM
	(SELECT DISTINCT a.last_name, a.first_name AS name1, b.first_name AS name2, LAG(CONCAT(b.first_name, a.first_name), 1) OVER (PARTITION BY a.last_name ORDER BY a.first_name) AS label1
	 FROM
		(SELECT DISTINCT gst.first_name, gst.last_name, bk.nights, bk.booking_date AS first_night, booking_date + INTERVAL nights-1 DAY AS last_night
		 FROM booking AS bk
		 JOIN guest AS gst
		 ON bk.guest_id = gst.id) AS a
		 JOIN
		(SELECT DISTINCT gst.first_name, gst.last_name, bk.booking_date AS first_night, booking_date + INTERVAL nights-1 DAY AS last_night
		 FROM booking AS bk
		 JOIN guest AS gst
		 ON bk.guest_id = gst.id) AS b
		 WHERE a.last_name = b.last_name AND a.first_name <> b.first_name 
		 AND (NOT (a.last_night < b.first_night OR a.first_night > b.last_night))
	 ORDER BY a.last_name) AS x
WHERE CONCAT(x.name1, x.name2) = x.label1

--12) Check out per floor. The first digit of the room number indicates the floor – e.g. room 201 is on the 2nd floor. For each day of the week beginning 2016-11-14 show how many rooms are being vacated that day by floor number. Show all days in the correct order.
SELECT a.checkout_date, a.room_count AS 1st, b.room_count AS 2nd, c.room_count AS 3rd
FROM
	(SELECT x.checkout_date, x.room_count
	FROM 
		(SELECT DATE_FORMAT(bk.booking_date + INTERVAL bk.nights DAY, '%Y-%m-%d') AS checkout_date, LEFT(bk.room_no, 1) AS level, COUNT(bk.room_no) AS room_count
		FROM booking AS bk
		WHERE bk.booking_date + INTERVAL bk.nights DAY BETWEEN '2016-11-14' AND '2016-11-20'
		GROUP BY DATE_FORMAT(bk.booking_date + INTERVAL bk.nights DAY, '%Y-%m-%d'), LEFT(bk.room_no, 1)
		ORDER BY checkout_date, level, bk.room_no) AS x
	WHERE x.level = 1) AS a
	JOIN
	(SELECT x.checkout_date, x.room_count
	FROM 
		(SELECT DATE_FORMAT(bk.booking_date + INTERVAL bk.nights DAY, '%Y-%m-%d') AS checkout_date, LEFT(bk.room_no, 1) AS level, COUNT(bk.room_no) AS room_count
		FROM booking AS bk
		WHERE bk.booking_date + INTERVAL bk.nights DAY BETWEEN '2016-11-14' AND '2016-11-20'
		GROUP BY DATE_FORMAT(bk.booking_date + INTERVAL bk.nights DAY, '%Y-%m-%d'), LEFT(bk.room_no, 1)
		ORDER BY checkout_date, level, bk.room_no) AS x
	WHERE x.level = 2) AS b
	ON a.checkout_date = b.checkout_date
	JOIN
	(SELECT x.checkout_date, x.room_count
	FROM 
		(SELECT DATE_FORMAT(bk.booking_date + INTERVAL bk.nights DAY, '%Y-%m-%d') AS checkout_date, LEFT(bk.room_no, 1) AS level, COUNT(bk.room_no) AS room_count
		FROM booking AS bk
		WHERE bk.booking_date + INTERVAL bk.nights DAY BETWEEN '2016-11-14' AND '2016-11-20'
		GROUP BY DATE_FORMAT(bk.booking_date + INTERVAL bk.nights DAY, '%Y-%m-%d'), LEFT(bk.room_no, 1)
		ORDER BY checkout_date, level, bk.room_no) AS x
	WHERE x.level = 3) AS c
	ON b.checkout_date = c.checkout_date

--13) Free rooms? List the rooms that are free on the day 25th Nov 2016.
SELECT rm.id
FROM
room AS rm
LEFT JOIN
(SELECT room_no, booking_date
FROM booking
WHERE DATE_FORMAT(booking_date + INTERVAL nights-1 DAY, '%Y-%m-%d') >= '2016-11-25'
AND DATE_FORMAT(booking_date, '%Y-%m-%d') <= '2016-11-25'
ORDER BY room_no) AS ocp
ON rm.id = ocp.room_no
WHERE ocp.booking_date IS NULL


