----Solutions to challenging questions in White Christmas

--3) Minimum Temp Before Christmas
SELECT DISTINCT h1.yr-1812+1 AS age, CASE h1.yr IN (SELECT h2.yr FROM hadcet AS h2 WHERE h2.yr BETWEEN 1812 AND 1812+11 AND h2.dy BETWEEN 21 AND 25 GROUP BY h2.yr HAVING MIN(h2.m12/10) < 0) WHEN 1 THEN 'White Christmas' ELSE 'No Snow' END
FROM hadcet AS h1
WHERE h1.yr BETWEEN 1812 AND 1812+11
AND h1.dy BETWEEN 21 AND 25

--4) White Christmas Count
SELECT yob, COUNT(wc)
FROM
(SELECT DISTINCT h2.yr AS yob, h1.yr AS yr, CASE h1.yr IN (SELECT h3.yr FROM hadcet AS h3 WHERE h3.yr BETWEEN 1812 AND 1812+11 AND h3.dy BETWEEN 21 AND 25 GROUP BY h3.yr HAVING MIN(h3.m12/10) < 0) WHEN 1 THEN 'White Christmas' ELSE NULL END AS wc
FROM hadcet AS h1 
CROSS JOIN (SELECT DISTINCT yr FROM hadcet) AS h2
WHERE h1.yr BETWEEN h2.yr+2 AND h2.yr+11 
AND h1.dy BETWEEN 21 AND 25) AS wcc
GROUP BY yob
HAVING COUNT(wc)>=7

--5) Climate Change
SELECT CONCAT(LEFT(yr,3), 0) AS decade, ROUND(AVG(NULLIF(m8, -999)/10), 1)
FROM hadcet
GROUP BY CONCAT(LEFT(yr,3), 0)