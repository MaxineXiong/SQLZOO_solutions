----Solutions to all questions in AdventureWorks


---AdventureWorks Easy Questions

--1) Show the first name and the email address of customer with CompanyName 'Bike World'
SELECT FirstName, EmailAddress
FROM Customer
WHERE CompanyName = 'Bike World'

--2) Show the CompanyName for all customers with an address in City 'Dallas'.
SELECT c.CompanyName
FROM Customer AS c
JOIN CustomerAddress AS ca
ON c.CustomerID = ca.CustomerID
JOIN Address AS a
ON ca.AddressID = a.AddressID
WHERE a.City = 'Dallas'

--3) How many items with ListPrice more than $1000 have been sold?
SELECT COUNT(*)
FROM Product AS p
JOIN SalesOrderDetail AS sod
ON p.ProductID = sod.ProductID
WHERE p.ListPrice > 1000

--4) Give the CompanyName of those customers with orders over $100000. Include the subtotal plus tax plus freight.
SELECT c.CompanyName
FROM SalesOrderHeader AS soh
JOIN Customer AS c
ON soh.CustomerID = c.CustomerID
GROUP BY c.CompanyName, c.CustomerID
HAVING SUM(soh.SubTotal + soh.TaxAmt + soh.Freight) > 100000

--5) Find the number of left racing socks ('Racing Socks, L') ordered by CompanyName 'Riding Cycles'
SELECT SUM(sod.OrderQty)
FROM Customer AS c
JOIN SalesOrderHeader AS soh
ON c.CustomerID = soh.CustomerID
JOIN SalesOrderDetail AS sod
ON soh.SalesOrderID = sod.SalesOrderId
JOIN Product AS p
ON sod.ProductID = p.ProductID
WHERE p.Name = 'Racing Socks, L' AND c.CompanyName = 'Riding Cycles'


---AdventureWorks Medium Questions

--6) A "Single Item Order" is a customer order where only one item is ordered. Show the SalesOrderID and the UnitPrice for every Single Item Order.
SELECT SalesOrderID, UnitPrice
FROM SalesOrderDetail
WHERE OrderQty = 1

--7) Where did the racing socks go? List the product name and the CompanyName for all Customers who ordered ProductModel 'Racing Socks'.
SELECT p.Name, c.CompanyName
FROM Customer AS c
JOIN SalesOrderHeader AS soh
ON c.CustomerID = soh.CustomerID
JOIN SalesOrderDetail AS sod
ON soh.SalesOrderID = sod.SalesOrderId
JOIN Product AS p
ON sod.ProductID = p.ProductID
WHERE p.Name LIKE '%Racing Socks%'

--8) Show the product description for culture 'fr' for product with ProductID 736.
SELECT pd.Description
FROM ProductDescription AS pd
JOIN ProductModelProductDescription AS pmpd
ON pd.ProductDescriptionID = pmpd.ProductDescriptionID
JOIN Product AS p
ON pmpd.ProductModelID = p.ProductModelID
WHERE pmpd.Culture = 'fr' AND p.ProductID = 736

--9) Use the SubTotal value in SaleOrderHeader to list orders from the largest to the smallest. For each order show the CompanyName and the SubTotal and the total weight of the order.
SELECT sod.SalesOrderID, c.CompanyName, soh.SubTotal, SUM(p.Weight*sod.OrderQty)
FROM SalesOrderHeader AS soh
JOIN Customer AS c
ON soh.CustomerID = c.CustomerID
JOIN SalesOrderDetail AS sod
ON soh.SalesOrderID = sod.SalesOrderID 
JOIN Product AS p
ON sod.ProductID = p.ProductID
GROUP BY sod.SalesOrderID, c.CompanyName, soh.SubTotal
ORDER BY soh.SubTotal DESC

--10) How many products in ProductCategory 'Cranksets' have been sold to an address in 'London'?
SELECT SUM(sod.OrderQty)
FROM ProductCategory AS pc
JOIN Product AS p
ON pc.ProductCategoryID = p.ProductCategoryID
JOIN SalesOrderDetail AS sod
ON p.ProductID = sod.ProductID
JOIN SalesOrderHeader AS soh
ON sod.SalesOrderID = soh.SalesOrderID
JOIN Address AS a
ON soh.ShipToAddressID = a.AddressID
WHERE a.City = 'London' AND pc.Name = 'Cranksets'


---AdventureWorks Hard Questions

--11) For every customer with a 'Main Office' in Dallas show AddressLine1 of the 'Main Office' and AddressLine1 of the 'Shipping' address - if there is no shipping address leave it blank. Use one row per customer.
SELECT a.CustomerID, b.AddressLine1 AS MainOffice, IFNULL(c.AddressLine1, '') AS Shipping
FROM
	(SELECT DISTINCT c.CustomerID
	FROM Customer AS c
	JOIN CustomerAddress AS ca
	ON c.CustomerID = ca.CustomerID
	JOIN Address AS a
	ON ca.AddressID = a.AddressID
	WHERE a.City = 'Dallas') AS a
	LEFT JOIN
	(SELECT c.CustomerID, a.AddressLine1, ca.AddressType
	FROM Customer AS c
	JOIN CustomerAddress AS ca
	ON c.CustomerID = ca.CustomerID
	JOIN Address AS a
	ON ca.AddressID = a.AddressID
	WHERE ca.AddressType = 'Main Office') AS b
	ON a.CustomerID = b.CustomerID
	LEFT JOIN
	(SELECT c.CustomerID, a.AddressLine1, ca.AddressType
	FROM Customer AS c
	JOIN CustomerAddress AS ca
	ON c.CustomerID = ca.CustomerID
	JOIN Address AS a
	ON ca.AddressID = a.AddressID
	WHERE ca.AddressType = 'Shipping') AS c
	ON a.CustomerID = c.CustomerID
ORDER BY a.CustomerID

--12) For each order show the SalesOrderID and SubTotal calculated three ways:
--    A) From the SalesOrderHeader
--    B) Sum of OrderQty*UnitPrice
--    C) Sum of OrderQty*ListPrice
SELECT sod.SalesOrderID, soh.SubTotal, SUM(sod.OrderQty*sod.UnitPrice), SUM(sod.OrderQty*p.ListPrice)
FROM SalesOrderDetail AS sod
JOIN SalesOrderHeader AS soh
ON sod.SalesOrderID = soh.SalesOrderID
JOIN Product AS p
ON sod.ProductID = p.ProductID
GROUP BY sod.SalesOrderID, soh.SubTotal
ORDER BY sod.SalesOrderID

--13) Show the best selling item by value.
SELECT p.Name, SUM(sod.UnitPrice * sod.OrderQty)
FROM Product AS p
JOIN SalesOrderDetail AS sod
ON p.ProductID = sod.ProductID
GROUP BY p.Name
ORDER BY SUM(sod.UnitPrice * sod.OrderQty) DESC

--14) Show how many orders are in the following ranges (in $): 0-99, 100-999, 1000-9999, 10000-
SELECT a.`RANGE`, COUNT(a.SalesOrderID), SUM(a.TotalValue)
FROM
	(SELECT SalesOrderID, SUM(OrderQty * UnitPrice) AS TotalValue, CASE WHEN SUM(OrderQty * UnitPrice) BETWEEN 0 AND 99 THEN '0-99' WHEN SUM(OrderQty * UnitPrice) BETWEEN 100 AND 999 THEN '100-999' WHEN SUM(OrderQty * UnitPrice) BETWEEN 1000 AND 9999 THEN '1000-9999' ELSE '10000-' END AS `RANGE`
	FROM SalesOrderDetail
	GROUP BY SalesOrderID) AS a
GROUP BY a.`RANGE`

--15) Identify the three most important cities. Show the break down of top level product category against city.
SELECT x.City, y.Name, y.Total_Value
FROM
	(SELECT a.City
	FROM SalesOrderDetail AS sod
	JOIN Product AS p
	ON sod.ProductID = p.ProductID
	JOIN ProductCategory AS pc
	ON p.ProductCategoryID = pc.ProductCategoryID
	JOIN SalesOrderHeader AS soh
	ON sod.SalesOrderID = soh.SalesOrderID
	JOIN Address AS a
	ON soh.ShipToAddressID = a.AddressID
	GROUP BY a.City
	ORDER BY SUM(sod.OrderQty * sod.UnitPrice) DESC
	LIMIT 3) AS x
	JOIN
	(SELECT a.City, pc.Name, SUM(sod.OrderQty * sod.UnitPrice) AS Total_Value
	FROM SalesOrderDetail AS sod
	JOIN Product AS p
	ON sod.ProductID = p.ProductID
	JOIN ProductCategory AS pc
	ON p.ProductCategoryID = pc.ProductCategoryID
	JOIN SalesOrderHeader AS soh
	ON sod.SalesOrderID = soh.SalesOrderID
	JOIN Address AS a
	ON soh.ShipToAddressID = a.AddressID
	GROUP BY a.City, pc.Name) AS y
	ON x.City = y.City
ORDER BY x.City

---AdventureWorks Resit Questions

--1) List the SalesOrderNumber for the customer 'Good Toys' 'Bike World'
SELECT soh.SalesOrderID, c.CompanyName
FROM Customer AS c
LEFT JOIN SalesOrderHeader AS soh
ON c.CustomerID = soh.CustomerID
WHERE c.CompanyName LIKE '%Good Toys%'
OR c.CompanyName LIKE '%Bike World%'

--2) List the ProductName and the quantity of what was ordered by 'Futuristic Bikes'
SELECT p.Name, sod.OrderQty
FROM Customer AS c
JOIN SalesOrderHeader AS soh
ON c.CustomerID = soh.CustomerID
JOIN SalesOrderDetail AS sod
ON soh.SalesOrderID = sod.SalesOrderID
JOIN Product AS p
ON sod.ProductID = p.ProductID
WHERE c.CompanyName = 'Futuristic Bikes'

--3) List the name and addresses of companies containing the word 'Bike' (upper or lower case) and companies containing 'cycle' (upper or lower case). Ensure that the 'bike's are listed before the 'cycles's.
SELECT c.CompanyName, a.AddressLine1, a.AddressLine2, a.City, a.StateProvince, a.CountyRegion, a.PostalCode
FROM Customer AS c
JOIN CustomerAddress AS ca
ON c.CustomerID = ca.CustomerID
JOIN Address AS a
ON ca.AddressID = a.AddressID
WHERE c.CompanyName LIKE '%bike%'
OR c.CompanyName LIKE '%Bike%'
UNION
SELECT c.CompanyName, a.AddressLine1, a.AddressLine2, a.City, a.StateProvince, a.CountyRegion, a.PostalCode
FROM Customer AS c
JOIN CustomerAddress AS ca
ON c.CustomerID = ca.CustomerID
JOIN Address AS a
ON ca.AddressID = a.AddressID
WHERE c.CompanyName LIKE '%cycle%'
OR c.CompanyName LIKE '%Cycle%'

--4) Show the total order value for each CountryRegion. List by value with the highest first.
SELECT a.CountyRegion, SUM(sod.OrderQty * sod.UnitPrice) AS Total_Value
FROM SalesOrderHeader AS soh
JOIN Address AS a
ON soh.ShipToAddressID = a.AddressID
JOIN SalesOrderDetail AS sod
ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY a.CountyRegion
ORDER BY Total_Value

--5) Find the best customer in each region.
SELECT y.CountyRegion, z.CompanyName, y.HighestValue
FROM
	(SELECT x.CountyRegion, MAX(x.Total) AS HighestValue
	FROM
		(SELECT a.CountyRegion, c.CompanyName, SUM(sod.OrderQty * sod.UnitPrice) AS Total
		FROM SalesOrderHeader AS soh
		JOIN Address AS a
		ON soh.ShipToAddressID = a.AddressID
		JOIN Customer AS c
		ON c.CustomerID = soh.CustomerID
		JOIN SalesOrderDetail AS sod
		ON soh.SalesOrderID = sod.SalesOrderID
		GROUP BY a.CountyRegion, c.CompanyName) AS x
	WHERE x.CountyRegion IN (SELECT DISTINCT CountyRegion FROM Address)
	GROUP BY x.CountyRegion) AS y
	JOIN 
	(SELECT a.CountyRegion, c.CompanyName, SUM(sod.OrderQty * sod.UnitPrice) AS Total
	FROM SalesOrderHeader AS soh
	JOIN Address AS a
	ON soh.ShipToAddressID = a.AddressID
	JOIN Customer AS c
	ON c.CustomerID = soh.CustomerID
	JOIN SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
	GROUP BY a.CountyRegion, c.CompanyName) AS z
	ON y.CountyRegion = z.CountyRegion AND y.HighestValue = z.Total