
-- Assignment-II

-- AdventureWorks2022 – Join Focused SQL Scenario Questions

-- Customer & Order Analysis (1–10)

-- 1. Display customer full name, SalesOrderID, OrderDate, and TotalDue for all orders.
SELECT CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS FullName, H.SalesOrderID, H.OrderDate, H.TotalDue
FROM Sales.SalesOrderHeader H
JOIN Sales.Customer C
ON H.CustomerID = C.CustomerID
JOIN Person.Person P
ON C.PersonID = P.BusinessEntityID;


-- 2.	Display customer full name and total number of orders placed.
SELECT CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS FullName, COUNT(H.SalesOrderID) AS TotalOrders
FROM Sales.SalesOrderHeader H
JOIN Sales.Customer C
ON H.CustomerID = C.CustomerID
JOIN Person.Person P
ON C.PersonID = P.BusinessEntityID
GROUP BY FirstName,MiddleName,LastName
ORDER BY TotalOrders DESC; 


-- 3.	Display customers and their cities along with the total amount they spent.
SELECT CONCAT(' ', P.FirstName,P.MiddleName,P.LastName) AS CustomerName, A.City, SUM(H.TotalDue) as TotalAmount
FROM Sales.Customer C
JOIN Person.Person P
ON C.PersonID=P.BusinessEntityID
JOIN Person.BusinessEntityAddress B
ON P.BusinessEntityID=B.BusinessEntityID
JOIN Person.Address A
ON B.AddressID=A.AddressID
JOIN Sales.SalesOrderHeader H
ON C.CustomerID = H.CustomerID
GROUP BY P.FirstName, P.MiddleName, P.LastName, A.City


-- 4.	Show customers who placed orders in 2014 with order details.
SELECT CONCAT(P.FirstName,' ',P.MiddleName,' ',P.LastName) CustomerName, H.*
FROM Sales.Customer C
JOIN Person.Person P
ON P.BusinessEntityID = C.PersonID
JOIN Sales.SalesOrderHeader H
ON H.CustomerID = C.CustomerID
WHERE YEAR(OrderDate) = 2014;

SELECT C.CustomerID, H.SalesOrderID, H.OrderDate, H.TotalDue
FROM Sales.Customer C
JOIN Sales.SalesOrderHeader H 
ON H.CustomerID = C.CustomerID
WHERE H.OrderDate >= '2014-01-01' AND H.OrderDate < '2015-01-01';


-- 5.	Display customers who have never placed any orders.
SELECT C.CustomerID, H.SalesOrderID
FROM Sales.Customer C
LEFT JOIN Sales.SalesOrderHeader H
ON H.CustomerID = C.CustomerID
WHERE H.SalesOrderID IS NULL;


-- 6.	Show customer name, order ID, and total quantity of products in each order.
SELECT CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS CustomerName, H.SalesOrderID, SUM(D.OrderQty) AS TotalQuantity
FROM Sales.Customer C
JOIN Person.Person P 
ON P.BusinessEntityID = C.PersonID
JOIN Sales.SalesOrderHeader H 
ON H.CustomerID = C.CustomerID
JOIN Sales.SalesOrderDetail D 
ON D.SalesOrderID = H.SalesOrderID
GROUP BY P.FirstName, P.MiddleName, P.LastName, H.SalesOrderID;


-- 7.	Display top 10 customers based on total purchase amount.
SELECT TOP 10 CONCAT(P.FirstName,' ',P.MiddleName,' ',P.LastName) As CustomerName, SUM(H.TotalDue) AS TotalPurchaseAmount
FROM Sales.Customer C
JOIN Person.Person P
ON P.BusinessEntityID = C.PersonID
JOIN Sales.SalesOrderHeader H
ON C.CustomerID = H.CustomerID
GROUP BY P.FirstName, P.MiddleName, P.LastName
ORDER BY SUM(H.TotalDue) DESC;


-- 8.	Show customers and the number of different products they purchased.
SELECT CONCAT(P.FirstName,' ',P.MiddleName,' ',P.LastName) As CustomerName, COUNT(DISTINCT D.ProductID) as NoOfDiffProduct
FROM Sales.Customer C
JOIN Person.Person P
ON P.BusinessEntityID = C.PersonID
JOIN Sales.SalesOrderHeader H
ON C.CustomerID = H.CustomerID
JOIN Sales.SalesOrderDetail D
ON H.SalesOrderID = D.SalesOrderID
GROUP BY P.FirstName,P.MiddleName,P.LastName; 


-- 9.	Display customer full name, city, and number of orders placed.
SELECT CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) As CustomerName, A.City, COUNT(H.SalesOrderID) as TotalOrder
FROM Sales.Customer C
JOIN Person.Person P
ON C.PersonID=P.BusinessEntityID
JOIN Person.BusinessEntityAddress B
ON P.BusinessEntityID=B.BusinessEntityID
JOIN Person.Address A
ON B.AddressID=A.AddressID
JOIN Sales.SalesOrderHeader H
ON C.CustomerID = H.CustomerID
GROUP BY P.FirstName, P.MiddleName, P.LastName, A.City


-- 10.	Identify customers whose total purchase amount exceeds 50,000.
SELECT CONCAT(P.FirstName,' ',P.MiddleName,' ',P.LastName) As CustomerName, Sum(H.TotalDue) as TotalAmount
FROM Sales.Customer C
JOIN Person.Person P
ON P.BusinessEntityID = C.PersonID
JOIN Sales.SalesOrderHeader H
ON C.CustomerID = H.CustomerID
GROUP BY P.FirstName, P.MiddleName, P.LastName
HAVING Sum(H.TotalDue) > 50000;


-- Product Sales Analysis (11–20)

-- 11.	Display product name, order ID, and quantity sold.
SELECT P.Name, D.SalesOrderID, D.OrderQty
FROM Production.Product P
JOIN Sales.SalesOrderDetail D
ON P.ProductID = D.ProductID


-- 12.	Display product name and total quantity sold across all orders.
SELECT P.Name AS ProductName, SUM(D.OrderQty) AS TotalQuantitySold
FROM Production.Product P
JOIN Sales.SalesOrderDetail D
ON P.ProductID = D.ProductID
GROUP BY P.Name
ORDER BY TotalQuantitySold DESC;


--13.	Identify top 10 products based on total sales revenue.
SELECT TOP 10 P.Name AS ProductName, SUM(D.LineTotal) AS TotalRevenue
FROM Production.Product P
JOIN Sales.SalesOrderDetail D
ON P.ProductID = D.ProductID
GROUP BY P.Name
ORDER BY TotalRevenue DESC;


-- 14.	Display products that have never been sold.
SELECT P.ProductID, P.Name AS ProductName
FROM Production.Product P
LEFT JOIN Sales.SalesOrderDetail D
ON P.ProductID = D.ProductID
WHERE D.ProductID IS NULL;


-- 15.	Display product name, number of orders it appears in, and total revenue generated.
SELECT P.Name AS ProductName, COUNT(DISTINCT D.SalesOrderID) AS NumberOfOrders, SUM(D.LineTotal) AS TotalRevenue
FROM Production.Product P
JOIN Sales.SalesOrderDetail D
ON P.ProductID = D.ProductID
GROUP BY P.Name
ORDER BY TotalRevenue DESC;


-- 16.	Show products with 'Bike' in their name and the total quantity sold.
SELECT P.Name AS ProductName, SUM(D.OrderQty) AS TotalQuantitySold FROM Production.Product P
JOIN Sales.SalesOrderDetail D
ON P.ProductID = D.ProductID
WHERE P.Name LIKE '%Bike%'
GROUP BY P.Name
ORDER BY TotalQuantitySold DESC;


-- 17.	Display product name, order date, and quantity sold.
SELECT P.Name AS ProductName, H.OrderDate, D.OrderQty
FROM Production.Product P
JOIN Sales.SalesOrderDetail D
ON P.ProductID = D.ProductID
JOIN Sales.SalesOrderHeader H
ON D.SalesOrderID = H.SalesOrderID
ORDER BY H.OrderDate;


-- 18.	Show products whose total quantity sold exceeds 100 units.
SELECT P.Name AS ProductName, SUM(D.OrderQty) AS TotalQuantitySold
FROM Production.Product P
JOIN Sales.SalesOrderDetail D
ON P.ProductID = D.ProductID
GROUP BY P.Name
HAVING SUM(D.OrderQty) > 100
ORDER BY TotalQuantitySold DESC;


-- 19.	Display product name and average order quantity.
SELECT P.Name AS ProductName, AVG(D.OrderQty) AS AvgOrderQuantity
FROM Production.Product P
JOIN Sales.SalesOrderDetail D
ON P.ProductID = D.ProductID
GROUP BY P.Name
ORDER BY AvgOrderQuantity DESC;


-- 20.	Identify products whose total revenue exceeds 100,000.
SELECT P.Name AS ProductName, SUM(D.LineTotal) AS TotalRevenue
FROM Production.Product P
JOIN Sales.SalesOrderDetail D
ON P.ProductID = D.ProductID
GROUP BY P.Name
HAVING SUM(D.LineTotal) > 100000
ORDER BY TotalRevenue DESC;


-- Order & Revenue Analysis (21–30)

-- 21.	Display order ID, customer name, and total number of products in each order.
SELECT H.SalesOrderID, CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS CustomerName, COUNT(D.ProductID) AS TotalProducts
FROM Sales.SalesOrderHeader H
JOIN Sales.Customer C
ON H.CustomerID = C.CustomerID
JOIN Person.Person P
ON C.PersonID = P.BusinessEntityID
JOIN Sales.SalesOrderDetail D
ON H.SalesOrderID = D.SalesOrderID
GROUP BY H.SalesOrderID, P.FirstName, P.MiddleName, P.LastName;


-- 22.	Show orders where the total order amount exceeds 10,000.
SELECT SalesOrderID, TotalDue
FROM Sales.SalesOrderHeader
WHERE TotalDue > 10000
ORDER BY TotalDue DESC;


-- 23.	Display total revenue generated per year.
SELECT YEAR(OrderDate) AS OrderYear, SUM(TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY OrderYear;


-- 24.	Display monthly order count along with total sales revenue.
SELECT YEAR(OrderDate) AS Year, MONTH(OrderDate) AS Month,
COUNT(SalesOrderID) AS TotalOrders, SUM(TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Year, Month;


-- 25.	Identify orders containing more than 5 different products.
SELECT SalesOrderID, COUNT(DISTINCT ProductID) AS NumberOfProducts
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING COUNT(DISTINCT ProductID) > 5;


-- 26.	Display order ID, customer name, and number of products purchased in that order.
SELECT H.SalesOrderID,
CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS CustomerName,
SUM(D.OrderQty) AS TotalProductsPurchased
FROM Sales.SalesOrderHeader H
JOIN Sales.Customer C
ON H.CustomerID = C.CustomerID
JOIN Person.Person P
ON C.PersonID = P.BusinessEntityID
JOIN Sales.SalesOrderDetail D
ON H.SalesOrderID = D.SalesOrderID
GROUP BY H.SalesOrderID, P.FirstName, P.MiddleName, P.LastName;


-- 27.	Show orders where the total quantity of products exceeds 20.
SELECT SalesOrderID, SUM(OrderQty) AS TotalQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(OrderQty) > 20;


-- 28.	Display top 10 highest value orders with customer names.
SELECT TOP 10 H.SalesOrderID, CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS CustomerName, H.TotalDue
FROM Sales.SalesOrderHeader H
JOIN Sales.Customer C
ON H.CustomerID = C.CustomerID
JOIN Person.Person P
ON C.PersonID = P.BusinessEntityID
ORDER BY H.TotalDue DESC;


-- 29.	Show average order value per customer.
SELECT CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS CustomerName, AVG(H.TotalDue) AS AvgOrderValue
FROM Sales.SalesOrderHeader H
JOIN Sales.Customer C
ON H.CustomerID = C.CustomerID
JOIN Person.Person P
ON C.PersonID = P.BusinessEntityID
GROUP BY P.FirstName, P.MiddleName, P.LastName
ORDER BY AvgOrderValue DESC;


-- 30.	Identify customers whose average order value exceeds 2000.
SELECT CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS CustomerName, AVG(H.TotalDue) AS AvgOrderValue
FROM Sales.SalesOrderHeader H
JOIN Sales.Customer C
ON H.CustomerID = C.CustomerID
JOIN Person.Person P
ON C.PersonID = P.BusinessEntityID
GROUP BY P.FirstName, P.MiddleName, P.LastName
HAVING AVG(H.TotalDue) > 2000
ORDER BY AvgOrderValue DESC;


-- Employee & Department Reporting (31–40)

-- 31.	Display employee full name, job title, and department name.
SELECT CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS EmployeeName, E.JobTitle, D.Name AS DepartmentName
FROM HumanResources.Employee E
JOIN Person.Person P
ON E.BusinessEntityID = P.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory EDH
ON E.BusinessEntityID = EDH.BusinessEntityID
JOIN HumanResources.Department D
ON EDH.DepartmentID = D.DepartmentID
WHERE EDH.EndDate IS NULL;


-- 32.	Show department name and number of employees in each department.
SELECT D.Name AS DepartmentName, COUNT(EDH.BusinessEntityID) AS EmployeeCount
FROM HumanResources.Department D
LEFT JOIN HumanResources.EmployeeDepartmentHistory EDH
ON D.DepartmentID = EDH.DepartmentID AND EDH.EndDate IS NULL  --AND works here as where condition 
GROUP BY D.Name
ORDER BY EmployeeCount DESC;


-- 33.	Identify departments with more than 10 employees.
SELECT D.Name AS DepartmentName, COUNT(EDH.BusinessEntityID) AS EmployeeCount
FROM HumanResources.Department D
JOIN HumanResources.EmployeeDepartmentHistory EDH
ON D.DepartmentID = EDH.DepartmentID
WHERE EDH.EndDate IS NULL
GROUP BY D.Name
HAVING COUNT(EDH.BusinessEntityID) > 10;


-- 34.	Display employees hired after 2012 with their department names.
SELECT CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS EmployeeName, D.Name AS DepartmentName, E.HireDate
FROM HumanResources.Employee E
JOIN Person.Person P
ON E.BusinessEntityID = P.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory EDH
ON E.BusinessEntityID = EDH.BusinessEntityID
JOIN HumanResources.Department D
ON EDH.DepartmentID = D.DepartmentID
WHERE E.HireDate >= '2013-01-01' 

-- 35.	Show employees working in the Sales department.
SELECT CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS EmployeeName, E.JobTitle
FROM HumanResources.Employee E
JOIN Person.Person P
ON E.BusinessEntityID = P.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory EDH
ON E.BusinessEntityID = EDH.BusinessEntityID
JOIN HumanResources.Department D
ON EDH.DepartmentID = D.DepartmentID
WHERE D.Name = 'Sales' AND EDH.EndDate IS NULL;

-- 36.	Display employee name and number of years they have worked in the company.
SELECT CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS EmployeeName, DATEDIFF(YEAR, E.HireDate, GETDATE()) AS YearsWorked
FROM HumanResources.Employee E
JOIN Person.Person P
ON E.BusinessEntityID = P.BusinessEntityID
ORDER BY YearsWorked DESC;

-- 37.	Show department names and average employee tenure.
SELECT D.Name AS DepartmentName, AVG(DATEDIFF(YEAR, E.HireDate, GETDATE())) AS AvgTenure
FROM HumanResources.Employee E
JOIN HumanResources.EmployeeDepartmentHistory EDH
ON E.BusinessEntityID = EDH.BusinessEntityID
JOIN HumanResources.Department D
ON EDH.DepartmentID = D.DepartmentID
WHERE EDH.EndDate IS NULL
GROUP BY D.Name
ORDER BY AvgTenure DESC;

-- 38.	Identify departments with no employees assigned.
SELECT D.Name AS DepartmentName
FROM HumanResources.Department D
LEFT JOIN HumanResources.EmployeeDepartmentHistory EDH
ON D.DepartmentID = EDH.DepartmentID AND EDH.EndDate IS NULL
WHERE EDH.BusinessEntityID IS NULL;

-- 39.	Display employees and their department names ordered by hire date.
SELECT CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS EmployeeName, D.Name AS DepartmentName, E.HireDate
FROM HumanResources.Employee E
JOIN Person.Person P
ON E.BusinessEntityID = P.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory EDH
ON E.BusinessEntityID = EDH.BusinessEntityID
JOIN HumanResources.Department D
ON EDH.DepartmentID = D.DepartmentID
WHERE EDH.EndDate IS NULL
ORDER BY E.HireDate;

-- 40.	Show top 5 departments with the highest number of employees.
SELECT TOP 5 D.Name AS DepartmentName, COUNT(EDH.BusinessEntityID) AS EmployeeCount
FROM HumanResources.Department D
JOIN HumanResources.EmployeeDepartmentHistory EDH
ON D.DepartmentID = EDH.DepartmentID
WHERE EDH.EndDate IS NULL
GROUP BY D.Name
ORDER BY EmployeeCount DESC;


-- Advanced Multi?Join Business Scenarios (41–50)

-- 41.	Display customer name, product name, order date, and quantity purchased.
SELECT CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS CustomerName, PR.Name AS ProductName, H.OrderDate, D.OrderQty
FROM Sales.SalesOrderHeader H
JOIN Sales.Customer C
ON H.CustomerID = C.CustomerID
JOIN Person.Person P
ON C.PersonID = P.BusinessEntityID
JOIN Sales.SalesOrderDetail D
ON H.SalesOrderID = D.SalesOrderID
JOIN Production.Product PR
ON D.ProductID = PR.ProductID;

-- 42.	Identify customers who purchased more than 3 different products in a single order.
SELECT H.SalesOrderID, CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS CustomerName, COUNT(DISTINCT D.ProductID) AS ProductCount
FROM Sales.SalesOrderHeader H
JOIN Sales.Customer C
ON H.CustomerID = C.CustomerID
JOIN Person.Person P
ON C.PersonID = P.BusinessEntityID
JOIN Sales.SalesOrderDetail D
ON H.SalesOrderID = D.SalesOrderID
GROUP BY H.SalesOrderID, P.FirstName, P.MiddleName, P.LastName
HAVING COUNT(DISTINCT D.ProductID) > 3;

-- 43.	Display product name, total quantity sold, and total revenue generated.
SELECT PR.Name AS ProductName, SUM(D.OrderQty) AS TotalQuantitySold, SUM(D.LineTotal) AS TotalRevenue
FROM Production.Product PR
JOIN Sales.SalesOrderDetail D
ON PR.ProductID = D.ProductID
GROUP BY PR.Name
ORDER BY TotalRevenue DESC;

-- 44.	Identify customers who purchased the most expensive products.
SELECT DISTINCT CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS CustomerName, PR.Name AS ProductName, PR.ListPrice
FROM Sales.SalesOrderHeader H
JOIN Sales.Customer C
ON H.CustomerID = C.CustomerID
JOIN Person.Person P
ON C.PersonID = P.BusinessEntityID
JOIN Sales.SalesOrderDetail D
ON H.SalesOrderID = D.SalesOrderID
JOIN Production.Product PR
ON D.ProductID = PR.ProductID
WHERE PR.ListPrice = (
        SELECT MAX(ListPrice)
        FROM Production.Product
);

-- 45.	Display city?wise total sales revenue.
SELECT A.City, SUM(H.TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader H
JOIN Sales.Customer C
ON H.CustomerID = C.CustomerID
JOIN Person.Person P
ON C.PersonID = P.BusinessEntityID
JOIN Person.BusinessEntityAddress BEA
ON P.BusinessEntityID = BEA.BusinessEntityID
JOIN Person.Address A
ON BEA.AddressID = A.AddressID
GROUP BY A.City
ORDER BY TotalRevenue DESC;

-- 46.	Show customers along with their most recent order date.
SELECT CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS CustomerName, MAX(H.OrderDate) AS MostRecentOrder
FROM Sales.SalesOrderHeader H
JOIN Sales.Customer C
ON H.CustomerID = C.CustomerID
JOIN Person.Person P
ON C.PersonID = P.BusinessEntityID
GROUP BY P.FirstName, P.MiddleName, P.LastName
ORDER BY MostRecentOrder DESC;

-- 47.	Identify products whose total revenue is greater than the average revenue of all products.
SELECT PR.Name AS ProductName, SUM(D.LineTotal) AS TotalRevenue
FROM Production.Product PR
JOIN Sales.SalesOrderDetail D
ON PR.ProductID = D.ProductID
GROUP BY PR.Name
HAVING SUM(D.LineTotal) >
(
    SELECT AVG(ProductRevenue)
    FROM
    (
        SELECT SUM(LineTotal) AS ProductRevenue
        FROM Sales.SalesOrderDetail
        GROUP BY ProductID
    ) AS RevenueTable
);

-- 48.	Display top 5 cities generating the highest sales revenue.
SELECT TOP 5 A.City, SUM(H.TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader H
JOIN Sales.Customer C
ON H.CustomerID = C.CustomerID
JOIN Person.Person P
ON C.PersonID = P.BusinessEntityID
JOIN Person.BusinessEntityAddress BEA
ON P.BusinessEntityID = BEA.BusinessEntityID
JOIN Person.Address A
ON BEA.AddressID = A.AddressID
GROUP BY A.City
ORDER BY TotalRevenue DESC;

-- 49.	Show customers who purchased products from more than 5 different product categories.
SELECT 
    CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS CustomerName,
    COUNT(DISTINCT PC.ProductCategoryID) AS CategoryCount
FROM Sales.SalesOrderHeader H
JOIN Sales.Customer C
    ON H.CustomerID = C.CustomerID
JOIN Person.Person P
    ON C.PersonID = P.BusinessEntityID
JOIN Sales.SalesOrderDetail D
    ON H.SalesOrderID = D.SalesOrderID
JOIN Production.Product PR
    ON D.ProductID = PR.ProductID
JOIN Production.ProductSubcategory PSC
    ON PR.ProductSubcategoryID = PSC.ProductSubcategoryID
JOIN Production.ProductCategory PC
    ON PSC.ProductCategoryID = PC.ProductCategoryID
GROUP BY P.FirstName, P.MiddleName, P.LastName
HAVING COUNT(DISTINCT PC.ProductCategoryID) > 5;

-- 50.	Identify customers who placed orders every year.
SELECT CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS CustomerName
FROM Sales.SalesOrderHeader H
JOIN Sales.Customer C
ON H.CustomerID = C.CustomerID
JOIN Person.Person P
ON C.PersonID = P.BusinessEntityID
GROUP BY P.FirstName, P.MiddleName, P.LastName
HAVING COUNT(DISTINCT YEAR(H.OrderDate)) =
(
    SELECT COUNT(DISTINCT YEAR(OrderDate))
    FROM Sales.SalesOrderHeader
);
