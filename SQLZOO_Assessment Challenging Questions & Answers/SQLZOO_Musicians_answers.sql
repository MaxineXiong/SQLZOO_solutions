----Solutions to all questions in Musicians


---Musicians Easy Questions

--1) Give the organiser's name of the concert in the Assembly Rooms after the first of Feb, 1997.
SELECT m.m_name
FROM concert AS c
JOIN musician AS m
ON c.concert_orgniser = m.m_no
WHERE c.concert_venue = 'Assembly Rooms' AND DATE_FORMAT(c.con_date, '%d/%m/%Y') > '01/02/1997'

--2) Find all the performers who played guitar or violin and were born in England.
SELECT m.m_name
FROM performer AS p
JOIN musician AS m
ON p.perf_is = m.m_no
JOIN place AS plc
ON m.born_in = plc.place_no
WHERE plc.place_country = 'England' AND p.instrument IN ('guitar', 'violin')

--3) List the names of musicians who have conducted concerts in USA together with the towns and dates of these concerts.
SELECT DISTINCT m.m_name, plc.place_town, cct.con_date
FROM musician AS m
JOIN performance AS pfm
ON m.m_no = pfm.conducted_by
JOIN concert AS cct
ON pfm.performed_in = cct.concert_no
JOIN place AS plc
ON cct.concert_in = plc.place_no
WHERE plc.place_country = 'USA'

--4) How many concerts have featured at least one composition by Andy Jones? List concert date, venue and the composition's title.
SELECT cct.concert_no, cct.con_date, cct.concert_venue, cps.c_title
FROM concert AS cct
JOIN performance AS pfm
ON cct.concert_no = pfm.performed_in
JOIN composition AS cps
ON pfm.performed = cps.c_no
LEFT JOIN has_composed AS hcp
ON cps.c_no = hcp.cmpn_no
JOIN composer AS cpr
ON hcp.cmpr_no = cpr.comp_no
JOIN musician AS m
ON cpr.comp_is = m.m_no
WHERE m.m_name = 'Andy Jones'

--5) list the different instruments played by the musicians and avg number of musicians who play the instrument.
SELECT p.instrument, COUNT(m.m_name)
FROM musician AS m
JOIN performer AS p
ON m.m_no = p.perf_is
GROUP BY p.instrument
ORDER BY p.instrument



---Musicians Medium Questions

--6) List the names, dates of birth and the instrument played of living musicians who play a instrument which Theo also plays.
SELECT m.m_name, m.born, p.instrument
FROM musician AS m
JOIN performer AS p
ON m.m_no = p.perf_is
WHERE m.m_name IN (SELECT m1.m_name
				   FROM musician AS m1
				   JOIN performer AS p1
				   ON m1.m_no = p1.perf_is
				   WHERE m1.died IS NULL AND m1.m_name <> 'Theo Mengel' AND p1.instrument IN (SELECT p2.instrument
																							  FROM musician AS m2
																							  JOIN performer AS p2
																							  ON m2.m_no = p2.perf_is
																							  WHERE m2.m_name = 'Theo Mengel'))
ORDER BY m.m_name

--7) List the name and the number of players for the band whose number of players is greater than the average number of players in each band.
SELECT x.band_name, SUM(x.player)
FROM
(SELECT b.band_name, m.m_name, pi.player
FROM band AS b
JOIN plays_in AS pi
ON b.band_no = pi.band_id
JOIN performer AS p
ON pi.player = p.perf_no
JOIN musician AS m
ON p.perf_is = m.m_no
ORDER BY b.band_name) AS x
JOIN
(SELECT b.band_name, AVG(pi.player) AS AvgPlayer
FROM band AS b
JOIN plays_in AS pi
ON b.band_no = pi.band_id
JOIN performer AS p
ON pi.player = p.perf_no
JOIN musician AS m
ON p.perf_is = m.m_no
GROUP BY b.band_name) AS y
ON x.band_name = y.band_name
WHERE x.player > y.AvgPlayer
GROUP BY x.band_name
ORDER BY x.band_name

--8) List the names of musicians who both conduct and compose and live in Britain.
SELECT x.m_name
FROM
(SELECT DISTINCT m.m_name
FROM performance AS pfm
JOIN musician AS m
ON pfm.conducted_by = m.m_no) AS x
JOIN
(SELECT DISTINCT m.m_name
FROM composition AS cps
JOIN has_composed AS hcp
ON cps.c_no = hcp.cmpn_no
JOIN composer AS cpr
ON hcp.cmpr_no = cpr.comp_no
JOIN musician AS m
ON cpr.comp_is = m.m_no) AS y
ON x.m_name = y.m_name
JOIN
(SELECT DISTINCT m.m_name
FROM musician AS m
JOIN place AS plc
ON m.living_in = plc.place_no
WHERE m.died IS NULL AND plc.place_country IN ('England', 'Scotland')) AS z
ON y.m_name = z.m_name

--9) Show the least commonly played instrument and the number of musicians who play it.
SELECT x.instrument, x.NumMusicians
FROM
(SELECT p.instrument, COUNT(m.m_name) AS NumMusicians
FROM musician AS m
JOIN performer AS p
ON m.m_no = p.perf_is
GROUP BY p.instrument) AS x
JOIN
(SELECT p.instrument
FROM concert AS cct
JOIN performance AS pfm
ON cct.concert_no = pfm.performed_in
JOIN band AS bd
ON pfm.gave = bd.band_no
JOIN plays_in AS pi
ON bd.band_no = pi.band_id
JOIN performer AS p
ON pi.player = p.perf_no
GROUP BY p.instrument
ORDER BY COUNT(*)
LIMIT 1) AS y
ON x.instrument = y.instrument

--10) List the bands that have played music composed by Sue Little; Give the titles of the composition in each case.
SELECT b.band_name, cps.c_title
FROM performance AS pfm
JOIN composition AS cps
ON pfm.performed = cps.c_no
JOIN has_composed AS hcp
ON cps.c_no = hcp.cmpn_no
JOIN composer AS cpr
ON hcp.cmpr_no = cpr.comp_no
JOIN musician AS m
ON m.m_no = cpr.comp_is
JOIN band AS b
ON b.band_no = pfm.gave
WHERE m.m_name = 'Sue Little'
ORDER BY b.band_name



---Musicians Hard Questions

--11) List the name and town of birth of any performer born in the same city as James First.
SELECT m.m_name, plc.place_town
FROM musician AS m
JOIN place AS plc
ON m.born_in = plc.place_no
WHERE plc.place_town = (SELECT plc1.place_town FROM musician AS m1 JOIN place AS plc1 ON m1.born_in = plc1.place_no WHERE m1.m_name = 'James First')

--12) Create a list showing for EVERY musician born in Britain the number of compositions and the number of instruments played.
SELECT a.m_name, b.NumInstru, c.NumComposi
FROM
(SELECT m.m_name
FROM musician AS m
JOIN place AS plc
ON m.born_in = plc.place_no
WHERE plc.place_country IN ('England', 'Scotland')) AS a
JOIN
(SELECT m.m_name, COUNT(p.instrument) AS NumInstru
FROM musician AS m
JOIN performer AS p
ON m.m_no = p.perf_is
GROUP BY m.m_name) AS b
ON a.m_name = b.m_name
JOIN
(SELECT m.m_name, COUNT(cps.c_title) AS NumComposi
FROM composition AS cps
JOIN has_composed AS hcp
ON cps.c_no = hcp.cmpn_no
JOIN composer AS cpr
ON hcp.cmpr_no = cpr.comp_no
JOIN musician AS m
ON cpr.comp_is = m.m_no
GROUP BY m.m_name) AS c
ON b.m_name = c.m_name

--13) Give the band name, conductor and contact of the bands performing at the most recent concert in the Royal Albert Hall.
SELECT x.band_name, x.m_name AS conductor, m.m_name AS contact 
FROM
(SELECT b.band_name, m.m_name, b.band_contact
FROM concert AS c
JOIN performance AS pfm
ON pfm.performed_in = c.concert_no
JOIN band AS b
ON pfm.gave = b.band_no
JOIN musician AS m
ON m.m_no = pfm.conducted_by
WHERE c.concert_venue = 'Royal Albert Hall') AS x
JOIN musician AS m
ON x.band_contact = m.m_no

--14) Give a list of musicians associated with Glasgow. Include the name of the musician and the nature of the association - one or more of 'LIVES_IN', 'BORN_IN', 'PERFORMED_IN' AND 'IN_BAND_IN'.
SELECT m.m_name, 'LIVES_IN' AS nature
FROM musician AS m
JOIN place AS plc
ON m.living_in = plc.place_no
WHERE plc.place_town = 'Glasgow'
UNION
SELECT m.m_name, 'BORN_IN' AS nature
FROM musician AS m
JOIN place AS plc
ON m.born_in = plc.place_no
WHERE plc.place_town = 'Glasgow'
UNION
SELECT DISTINCT m.m_name, 'PERFORMED_IN' AS nature
FROM performance AS pfm
JOIN concert AS c
ON pfm.performed_in = c.concert_no
JOIN place AS plc
ON c.concert_in = plc.place_no
JOIN musician AS m
ON pfm.conducted_by = m.m_no
WHERE plc.place_town = 'Glasgow'
UNION
SELECT m.m_name, 'IN_BAND_IN' AS nature
FROM band AS b
JOIN place AS plc
ON b.band_home = plc.place_no
JOIN plays_in AS pi
ON b.band_no = pi.band_id
JOIN performer AS pfr
ON pi.player = pfr.perf_no
JOIN musician AS m
ON pfr.perf_is = m.m_no
WHERE plc.place_town = 'Glasgow'

--15) Jeff Dawn plays in a band with someone who plays in a band with Sue Little. Who is it and what are the bands?
SELECT x.m_name, x.band1, y.band2
FROM
(
SELECT DISTINCT a.m_name, b.band_name AS band1
FROM
(SELECT m.m_name, b.band_name
FROM plays_in AS pi
JOIN performer AS pfr
ON pi.player = pfr.perf_no
JOIN musician AS m
ON m.m_no = pfr.perf_is
JOIN band AS b
ON b.band_no = pi.band_id) AS a
JOIN
(SELECT b.band_name
FROM plays_in AS pi
JOIN performer AS pfr
ON pi.player = pfr.perf_no
JOIN musician AS m
ON m.m_no = pfr.perf_is
JOIN band AS b
ON b.band_no = pi.band_id
WHERE m.m_name = 'Sue Little') AS b
ON a.band_name = b.band_name
) AS x
JOIN 
(
SELECT DISTINCT a.m_name, b.band_name AS band2
FROM
(SELECT m.m_name, b.band_name
FROM plays_in AS pi
JOIN performer AS pfr
ON pi.player = pfr.perf_no
JOIN musician AS m
ON m.m_no = pfr.perf_is
JOIN band AS b
ON b.band_no = pi.band_id) AS a
JOIN
(SELECT b.band_name
FROM plays_in AS pi
JOIN performer AS pfr
ON pi.player = pfr.perf_no
JOIN musician AS m
ON m.m_no = pfr.perf_is
JOIN band AS b
ON b.band_no = pi.band_id
WHERE m.m_name = 'Jeff Dawn') AS b
ON a.band_name = b.band_name
) AS y
ON x.m_name = y.m_name

