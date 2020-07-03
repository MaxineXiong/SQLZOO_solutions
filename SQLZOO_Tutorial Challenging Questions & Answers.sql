--SELECT from Nobel Tutorial

----Q14
----The expression subject IN ('Chemistry','Physics') can be used as a value - it will be 0 or 1.
----Show the 1984 winners and subject ordered by subject and winner name; but list Chemistry and Physics last.
--Hint: the key is to create and order by an extra INDEX column

--Solution 1:
SELECT winner, subject
FROM nobel
WHERE yr = 1984
ORDER BY IF(subject IN ('Chemistry', 'Physics'), 1, 0), subject, winner

--Solution 2:
SELECT winner, subject
FROM nobel
WHERE yr = 1984
ORDER BY CASE subject IN ('Chemistry', 'Physics') WHEN 1 THEN 1 ELSE 0 END, subject, winner  -- remember to add 'END' at the end of CASE statement!





--SELECT within SELECT Tutorial

----Q5
----Germany (population 80 million) has the largest population of the countries in Europe. Austria (population 8.5 million) has 11% of the population of Germany.
----Show the name and the population of each country in Europe. Show the population as a percentage of the population of Germany.
--Hint: use CONCAT to add % symbol in MySQL
SELECT name, CONCAT(ROUND(population/(SELECT population FROM world WHERE name = 'Germany') * 100), '%')
FROM world 
WHERE continent = 'Europe'

----Q8
----List each continent and the name of the country that comes first alphabetically.
--Hint: use LIMIT n in MySQL to do SELECT TOP
SELECT w1.continent, w1.name
FROM world AS w1
WHERE w1.name = (SELECT w2.name FROM world AS w2 WHERE w2.continent = w1.continent ORDER BY w2.name LIMIT 1)

----Q9
----Find the continents where all countries have a population <= 25000000. 
----Then find the names of the countries associated with these continents. Show name, continent and population.
SELECT w1.name, w1.continent, w1.population
FROM world AS w1
WHERE (SELECT COUNT(w2.name) 
	   FROM world AS w2 
	   WHERE w2.continent = w1.continent) = (SELECT COUNT(w3.name)
											 FROM world AS w3 
											 WHERE w3.continent = w1.continent AND w3.population <= 25000000)

----Q10
----Some countries have populations more than three times that of any of their neighbours (in the same continent). 
----Give the countries and continents.
SELECT w1.name, w1.continent
FROM world AS w1
WHERE w1.population > (SELECT MAX(w2.population) * 3 FROM world AS w2 WHERE w2.continent = w1.continent AND w2.name <> w1.name)





--The JOIN operation

----Q13
----List every match with the goals scored by each team as shown. 
----This will use "CASE WHEN" which has not been explained in any previous exercises.
SELECT gm.mdate, gm.team1, SUM(IF(gl.teamid = gm.team1, 1, 0)) AS score1, gm.team2, SUM(IF(gl.teamid = gm.team2, 1, 0)) AS score2
FROM game AS gm
LEFT JOIN goal AS gl
ON gm.id = gl.matchid
GROUP BY gm.mdate, gl.matchid, gm.team1, gm.team2



--More JOIN operations
----Q12 Lead actor in Julie Andrews movies
----List the film title and the leading actor for all of the films 'Julie Andrews' played in.
----Did you get "Little Miss Marker twice"? Julie Andrews starred in the 1980 remake of Little Miss Marker and not the original(1934).

SELECT mv.title, ac.name
FROM movie AS mv 
JOIN casting AS cs 
ON mv.id = cs.movieid
JOIN actor AS ac 
ON cs.actorid = ac.id 
WHERE mv.title IN
(SELECT mv2.title
 FROM movie AS mv2
 JOIN casting AS cs2
 ON mv2.id = cs2.movieid
 JOIN actor AS ac2
 ON cs2.actorid = ac2.id
 WHERE ac2.name = 'Julie Andrews')
AND mv.yr IN
(SELECT mv2.yr
 FROM movie AS mv2
 JOIN casting AS cs2
 ON mv2.id = cs2.movieid
 JOIN actor AS ac2
 ON cs2.actorid = ac2.id
 WHERE ac2.name = 'Julie Andrews')
AND cs.ord = 1


----Q15 Lead actor in Julie Andrews movies
----List all the people who have worked with 'Art Garfunkel'.
SELECT ac.name
FROM movie AS mv 
JOIN casting AS cs 
ON mv.id = cs.movieid
JOIN actor AS ac  
ON cs.actorid = ac.id
WHERE mv.title IN 
(SELECT mv2.title 
 FROM movie AS mv2 
 JOIN casting AS cs2 
 ON mv2.id = cs2.movieid
 JOIN actor AS ac2  
 ON cs2.actorid = ac2.id
 WHERE ac2.name = 'Art Garfunkel')
AND ac.name <> 'Art Garfunkel'




--Window functions

----Q5 Winners Only
----You can use SELECT within SELECT to pick out only the winners in Edinburgh.
----Show the parties that won for each Edinburgh constituency in 2017.
SELECT ge1.constituency, ge1.party 
FROM ge AS ge1 
WHERE ge1.constituency BETWEEN 'S14000021' AND 'S14000026'
AND ge1.votes = (SELECT MAX(ge2.votes) FROM ge AS ge2 WHERE ge2.constituency = ge1.constituency AND ge2.yr = 2017)
AND ge1.yr = 2017
ORDER BY ge1.constituency

----Q6 Scottish seats
----You can use COUNT and GROUP BY to see how each party did in Scotland. Scottish constituencies start with 'S'
----Show how many seats for each party in Scotland in 2017.
SELECT ge1.party, COUNT(ge1.constituency)
FROM ge AS ge1 
WHERE ge1.constituency LIKE 'S%'
AND ge1.votes = (SELECT MAX(ge2.votes) FROM ge AS ge2 WHERE ge2.constituency = ge1.constituency AND ge2.yr = 2017)
AND ge1.yr = 2017
GROUP BY ge1.party
ORDER BY ge1.party



--Window LAG

----Q2 Introducing the LAG function
----The LAG function is used to show data from the preceding row or the table. When lining up rows the data is partitioned by country name and ordered by the data whn. That means that only data from Italy is considered.
----Modify the query to show confirmed for the day before.
SELECT name, DAY(whn), confirmed,
       LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY DAY(whn))
FROM covid
WHERE name = 'Italy'
AND MONTH(whn) = 3
ORDER BY whn


----Q4 Weekly changes
----The data gathered are necessarily estimates and are inaccurate. However by taking a longer time span we can mitigate some of the effects.
----You can filter the data to view only Monday's figures WHERE WEEKDAY(whn) = 0
----Show the number of new cases in Italy for each week - show Monday only.
SELECT name, DATE_FORMAT(whn, "%Y-%m%-%d"), confirmed-LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY WEEK(whn))
FROM covid
WHERE name = 'Italy'
AND WEEKDAY(whn) = 0
ORDER BY whn


----Q8 Turning the corner
----For each country that has had at last 1000 new cases in a single day, show the date of the peak number of new cases.
----Hint: window function is not allowed to use within another window function
SELECT name, DATE_FORMAT(whn, '%Y-%m-%d'), newCases AS peakNewCases
FROM
(
SELECT name, whn, newCases, RANK() OVER (PARTITION BY name ORDER BY newCases DESC) AS rank_newCases
FROM
(SELECT name, whn, confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) AS newCases
 FROM covid) AS derivedTable1
) AS derivedTable2
WHERE rank_newCases = 1 AND newCases > 1000
ORDER BY whn




--Self join

----Q10
----Find the routes involving two buses that can go from Craiglockhart to Lochend.
----Show the bus no. and company for the first bus, the name of the stop for the transfer, and the bus no. and company for the second bus.
SELECT dt1.num, dt1.company, dt1.name, dt2.num, dt2.company
FROM
(SELECT DISTINCT r1.num, r1.company, st2.name
FROM route AS r1
JOIN route AS r2
ON r1.num = r2.num AND r1.company = r2.company
JOIN stops AS st1
ON r1.stop = st1.id
JOIN stops AS st2
ON r2.stop = st2.id
WHERE st1.name = 'Craiglockhart') AS dt1
JOIN
(SELECT DISTINCT sta.name, ra.num, ra.company
FROM route AS ra
JOIN route AS rb
ON ra.num = rb.num AND ra.company = rb.company
JOIN stops AS sta
ON ra.stop = sta.id
JOIN stops AS stb
ON rb.stop = stb.id
WHERE stb.name = 'Lochend') AS dt2
ON dt1.name = dt2.name
ORDER BY dt1.num, dt1.name, dt2.company, dt2.num
