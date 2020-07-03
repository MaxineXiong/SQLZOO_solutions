----Solutions to all questions in Helpdesk


---Helpdesk Easy Questions

--1) There are three issues that include the words "index" and "Oracle". Find the call_date for each of them
SELECT call_date, call_ref
FROM Issue
WHERE DETAIL LIKE '%index%' 
AND DETAIL LIKE '%Oracle%'

--2) Samantha Hall made three calls on 2017-08-14. Show the date and time for each
SELECT DATE_FORMAT(Issue.Call_date, '%Y-%m-%d %H:%i:%s'), Caller.first_name, Caller.last_name
FROM Issue 
JOIN Caller 
ON Issue.Caller_id = Caller.Caller_id
WHERE DATE_FORMAT(Issue.call_date, '%Y-%m-%d') = '2017-08-14'
AND Caller.first_name = 'Samantha' AND Caller.last_name = 'Hall'

--3) There are 500 calls in the system (roughly). Write a query that shows the number that have each status.
SELECT status, COUNT(status) AS Volume
FROM Issue
GROUP BY status

--4) Calls are not normally assigned to a manager but it does happen. How many calls have been assigned to staff who are at Manager Level?
SELECT COUNT(*) AS mlcc
FROM Issue 
JOIN Staff
ON Issue.Assigned_to = Staff.Staff_code
JOIN Level
ON Staff.Level_code = Level.Level_code
WHERE Level.Manager = 'Y'

--5) Show the manager for each shift. Your output should include the shift date and type; also the first and last name of the manager.
SELECT DATE_FORMAT(Shift.Shift_date, '%Y-%m-%d') AS Shift_date, Shift.Shift_type, Staff.First_name, Staff.Last_name
FROM Shift
JOIN Staff
ON Shift.Manager = Staff.Staff_code
ORDER BY Shift.Shift_date


---Helpdesk Medium Questions

--6) List the Company name and the number of calls for those companies with more than 18 calls.
SELECT Customer.Company_name, COUNT(Call_date) AS cc
FROM Issue
JOIN Caller
ON Issue.Caller_id = Caller.Caller_id
JOIN Customer
ON Caller.Company_ref = Customer.Company_ref
GROUP BY Customer.Company_name
HAVING COUNT(Call_date)> 18

--7) Find the callers who have never made a call. Show first name and last name
SELECT Caller.First_name AS first_name, Caller.Last_name AS last_name
FROM Caller
LEFT JOIN Issue
ON Issue.Caller_id = Caller.Caller_id
WHERE Issue.Call_date IS NULL

--8) For each customer show: Company name, contact name, number of calls where the number of calls is fewer than 5
--Hint: 1 contact_id for 1 Company_name, 1 Caller_id for 1 First_name and 1 Last_name. Contact name can be found in Caller table.
SELECT a.Company_name, b.First_name, b.Last_name, a.nc
FROM
  (SELECT Customer.Company_name, Customer.Contact_id, COUNT(Issue.Call_date) AS nc
   FROM Issue
   JOIN Caller
   ON Issue.Caller_id = Caller.Caller_id
   JOIN Customer
   ON Caller.Company_ref = Customer.Company_ref
   GROUP BY Customer.Company_name
   HAVING COUNT(Issue.Call_date) < 5) AS a
   JOIN
   Caller AS b
   ON a.Contact_id = b.Caller_id

--9) For each shift show the number of staff assigned. 
--   Beware that some roles may be NULL and that the same person might have been assigned to multiple roles (The roles are 'Manager', 'Operator', 'Engineer1', 'Engineer2').
SELECT DATE_FORMAT(a.Shift_date, '%Y-%m-%d') AS Shift_date, a.Shift_type, COUNT(a.Manager) AS cw
FROM 
 (SELECT Shift_date, Shift_type, Manager FROM Shift
  UNION
  SELECT Shift_date, Shift_type, Operator FROM Shift
  UNION
  SELECT Shift_date, Shift_type, Engineer1 FROM Shift
  UNION
  SELECT Shift_date, Shift_type, Engineer2 FROM Shift) AS a
WHERE a.Manager IS NOT NULL
GROUP BY a.Shift_date, a.Shift_type

--10) Caller 'Harry' claims that the operator who took his most recent call was abusive and insulting. Find out who took the call (full name) and when.
SELECT Staff.First_name, Staff.Last_name, DATE_FORMAT(Issue.Call_date, '%Y-%m-%d %H:%i:%S') AS call_date
FROM Issue
JOIN Staff
ON Issue.Taken_by = Staff.Staff_code
WHERE Issue.Call_date = (SELECT MAX(Issue.Call_date)
                                                          FROM Issue
                                                          JOIN Caller
                                                          ON Issue.Caller_id = Caller.Caller_id
                                                          JOIN Staff
                                                          ON Issue.Assigned_to = Staff.Staff_code
                                                          WHERE Caller.First_name = 'Harry')


---Helpdesk Hard Questions

--11) Show the manager and number of calls received for each hour of the day on 2017-08-12
SELECT b.Manager, a.Hr, a.cc
FROM (SELECT Shift.Shift_type, Shift.Shift_date, DATE_FORMAT(Issue.Call_date, '%Y-%m-%d %H') AS Hr, COUNT(Issue.Call_date) AS cc
      FROM Issue
      JOIN Shift
      ON DATE_FORMAT(Issue.Call_date, '%Y-%m-%d') = DATE_FORMAT(Shift.Shift_date, '%Y-%m-%d')
      WHERE DATE_FORMAT(Shift.Shift_date, '%Y-%m-%d') = '2017-08-12'
      AND ((DATE_FORMAT(Issue.Call_date, '%H') < 14 AND Shift.Shift_type = 'Early') 
      OR (DATE_FORMAT(Issue.Call_date, '%H') >= 14 AND Shift.Shift_type = 'Late'))
      GROUP BY Shift.Shift_type, DATE_FORMAT(Issue.Call_date, '%Y-%m-%d %H')) AS a
      JOIN Shift AS b
      ON a.Shift_type = b.Shift_type AND a.Shift_date = b.Shift_date
ORDER BY a.Hr

--13) Annoying customers. Customers who call in the last five minutes of a shift are annoying. Find the most active customer who has never been annoying.
SELECT Customer.Company_name, COUNT(Issue.Call_date) AS abna
FROM Issue
JOIN Caller
ON Issue.Caller_id = Caller.Caller_id
JOIN Customer
ON Caller.Company_ref = Customer.Company_ref
WHERE Customer.Company_name NOT IN (SELECT Cu2.Company_name
                                    FROM Issue AS I2
                                    JOIN Caller AS C2
                                    ON I2.Caller_id = C2.Caller_id
                                    JOIN Customer AS Cu2
                                    ON C2.Company_ref = Cu2.Company_ref
                                    WHERE DATE_FORMAT(I2.Call_date, '%H') IN (13, 19) AND DATE_FORMAT(I2.Call_date, '%i') >= 55)
GROUP BY Customer.Company_name
ORDER BY COUNT(Issue.Call_date) DESC
LIMIT 1

--14) Maximal usage. If every caller registered with a customer makes a call in one day then that customer has "maximal usage" of the service. List the maximal customers for 2017-08-13.
SELECT a.Company_name, COUNT(a.call_count) AS issue_count, b.caller_count
FROM 
	(SELECT Customer.Company_name, Caller.Caller_id, COUNT(Issue.Call_date) AS call_count
	FROM Issue
	JOIN Caller
	ON Issue.Caller_id = Caller.Caller_id
	JOIN Customer
	ON Caller.Company_ref = Customer.Company_ref
	WHERE DATE_FORMAT(Issue.Call_date, '%Y-%m-%d') = '2017-08-13'
	GROUP BY Caller.Caller_id) AS a
	JOIN
	(SELECT Customer.Company_name, COUNT(Caller.Caller_id) AS caller_count
	FROM Caller
	JOIN Customer
	ON Caller.Company_ref = Customer.Company_ref
	GROUP BY Customer.Company_name) AS b
	ON a.Company_name = b.Company_name
WHERE a.Company_name NOT IN (SELECT DISTINCT x.Company_name
						 FROM
							(SELECT Customer.Company_name, Caller.Caller_id
							FROM Caller
							JOIN Customer
							ON Caller.Company_ref = Customer.Company_ref) AS x
							LEFT JOIN
							(SELECT Customer.Company_name, Caller.Caller_id, Issue.Call_date
							FROM Issue
							JOIN Caller
							ON Issue.Caller_id = Caller.Caller_id
							JOIN Customer
							ON Caller.Company_ref = Customer.Company_ref
							WHERE DATE_FORMAT(Issue.Call_date, '%Y-%m-%d') = '2017-08-13') AS y
							ON x.Company_name = y.Company_name AND x.Caller_id = y.Caller_id
						 WHERE y.Caller_id IS NULL)
GROUP BY a.Company_name, b.caller_count

