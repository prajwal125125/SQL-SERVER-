USE [AdventureWorks2022]
GO

SELECT [SystemInformationID]
      ,[Database Version]
      ,[VersionDate]
      ,[ModifiedDate]
  FROM [dbo].[AWBuildVersion]

GO

---------------------------------------------------------+++++++++++--------------------------------------------


SELECT * FROM AWBuildVersion;  -- Empty

SELECT * FROM DatabaseLog;     -- Contains : DatabaseLogID, Post Time, Database User, Event, Schema, Object, TSQL, XmlEvent

SELECT * FROM ErrorLog;        -- Empty

SELECT * FROM HumanResources.Department;           -- DepartmentID, Name, GroupName, ModifiedDate

SELECT * FROM HumanResources.Employee;             -- BusinessEntityID, NationalIDNumber, LoginID, OrganizationNode, OrganizationLevel, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours, CurrentFlag, rowguid, ModifiedDate

SELECT * FROM HumanResources.EmployeeDepartmentHistory;    -- BusinessEntityID, DepartmentID, ShiftID, StartDate, EndDate, Modifieddate

SELECT * FROM HumanResources.EmployeePayHistory;    -- BusinessEntityID, RateChangeDate, Rate, PayFrequency, ModifiedDate

SELECT * FROM HumanResources.JobCandidate;         -- JobCandidateID, BusinessEntityID, Resume, ModifiedDate

SELECT * FROM HumanResources.Shift;    -- ShiftID, Name, StartTime, EndTime, ModifiedDate

SELECT * FROM Production.Product;

SELECT * FROM Sales.SalesOrderDetail;

SELECT * FROM Sales.SalesOrderHeader;

SELECT * FROM Person.Person;
----------------------------------------------------------++++++----------------------------------------------

-- Assesment : SELECT Statements(AdventuresWork2022)

-- Part 1: Basic SELECT and Aliasing

-- 1. Retrieve all columns and all rows from the Production.Product table. 
SELECT * FROM Production.Product;

-- 2. Select only the Name, ProductNumber, and Color columns for all products.
SELECT Name, ProductNumber, Color FROM Production.Product;

-- 3. Select the Name and ListPrice of all products, but alias the Name column as 'ProductName' and the ListPrice column as 'RetailPrice'.
SELECT Name AS ProductName, ListPrice AS RetailPrice FROM Production.Product;

-- 4. Retrieve a list of all unique Color values that exist in the Production.Product table.
SELECT DISTINCT Color FROM Production.Product;

-- 5. Retrieve a list of all unique JobTitle values from the HumanResources.Employee table.
SELECT DISTINCT JobTitle FROM HumanResources.Employee;


-- Basic Filtering (WHERE Clause)

-- 6. Find all products where the Color is exactly 'Black'.
SELECT * FROM Production.Product
WHERE Color = 'Black';

-- 7. Find all products where the ListPrice is exactly $0.00.
SELECT * FROM Production.Product
WHERE ListPrice = 0.00;

-- 8. Find all employees who are marked as salaried (SalariedFlag = 1).
SELECT * FROM HumanResources.Employee
WHERE SalariedFlag = 1;

-- 9. Find all products that have a StandardCost strictly greater than $500.
SELECT * FROM Production.Product
WHERE StandardCost > 500;

-- 10. Find all sales orders in Sales.SalesOrderHeader where the TotalDue is less than $100.
SELECT * FROM Sales.SalesOrderHeader
WHERE TotalDue < 100;


-- Part 3: Multiple Conditions (AND / OR / NOT)

-- 11. Find all 'Black' products that have a ListPrice greater than $1,000. 
SELECT * FROM Production.Product
WHERE  Color = 'Black' AND ListPrice > 1000;

-- 12. Find all products that are either 'Red' or 'Silver'.
SELECT * FROM Production.Product
WHERE Color = 'Red' OR Color = 'silver';

-- 13. Find all employees who are both Female (Gender = 'F') and Single (MaritalStatus = 'S').
SELECT * FROM HumanResources.Employee
WHERE Gender = 'F' AND MaritalStatus = 'S';

-- 14. Find all products that either have a Color of 'Blue' or a StandardCost under $50,
--     but explicitly exclude any products with a ListPrice of exactly $0.
SELECT * FROM Production.Product
WHERE Color = 'Blue' OR (StandardCost < 50 AND ListPrice <> 0);

-- 15. Find all sales orders that were placed online (OnlineOrderFlag = 1) and have a 
--     freight cost (Freight) greater than $50.
SELECT * FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 1 AND Freight > 50;


-- Part 4: Ranges and Lists (BETWEEN / IN)

-- 16. Find all products whose ListPrice is between $100 and $500, inclusive.
SELECT * FROM Production.Product
WHERE ListPrice BETWEEN 100 AND 500;

-- 17. Find all employees who were hired between January 1, 2010, and December 31, 2012.
SELECT * FROM HumanResources.Employee
WHERE HireDate BETWEEN '2010-01-01' AND '2012-12-31';

-- 18. Using the IN operator, find all products whose Color is 'Red', 'Black', or 'White'.
SELECT * FROM Production.Product
WHERE Color IN ('Red', 'Black', 'White');

-- 19. Using the IN operator, find all sales orders with a Status of 1, 3, or 5.
SELECT * From Sales.SalesOrderHeader
WHERE Status IN (1, 3, 5);

-- 20. Find all products whose Weight is not between 10 and 50.
SELECT * FROM Production.Product
WHERE Weight NOT BETWEEN 10 AND 50;

-- Part 5: Pattern Matching (LIKE)

-- 21. Find all people in Person.Person whose FirstName starts with the letter 'A'.
SELECT * FROM Person.Person
WHERE FirstName LIKE 'A%';

-- 22. Find all products whose Name contains the word 'Bike' anywhere within it.
SELECT * FROM Production.Product
WHERE Name LIKE '%Bike%';

-- 23. Find all people whose LastName ends with 'son'.
SELECT * FROM Person.Person
WHERE LastName LIKE '%son';

-- 24. Find all products whose ProductNumber starts with 'BK-' followed by any other characters.
SELECT * FROM Production.Product
WHERE ProductNumber LIKE 'BK-%';

-- 25. Find all people whose FirstName is exactly four characters long and starts with the letter 'J'.
SELECT * FROM Person.Person
WHERE FirstName LIKE 'J___';


-- Part 6: Handling NULL Values

-- 26. Find all products that do not have a defined color (Color is NULL).
SELECT * FROM Production.Product
WHERE Color IS NULL;

-- 27. Find all products that have a recorded weight (Weight is NOT NULL).
SELECT * FROM Production.Product
WHERE Weight IS NOT NULL;

-- 28. Find all people in Person.Person who do not have a MiddleName.
SELECT * FROM Person.Person
WHERE MiddleName IS NULL;

-- 29. Find all products where the Size is NULL but the Weight is NOT NULL.
SELECT * FROM Production.Product
WHERE Size IS NULL AND Weight IS NOT NULL;

-- 30. Find all sales orders in Sales.SalesOrderHeader where the SalesPersonID is NULL (indicating an online or unassigned order).
SELECT * FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NULL;


-- Part 7: Sorting and Limiting (ORDER BY / TOP)

-- 31. Select the top 10 most expensive products based on their ListPrice.
SELECT TOP 10 * FROM Production.Product
ORDER BY ListPrice DESC;

-- 32. Select all employees and order the results by HireDate from oldest to newest.
SELECT * FROM HumanResources.Employee
ORDER BY HireDate ASC;

-- 33. List all products ordered alphabetically by Color, and then by ListPrice descending for products of the same color.
SELECT * FROM Production.Product
ORDER BY Color ASC, ListPrice DESC;

-- 34. Find the top 5 sales orders with the highest TotalDue.
SELECT TOP 5 * FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

-- 35. Display the 15 products with the lowest StandardCost, but only include products where the StandardCost is greater than $0.
SELECT TOP 15 * FROM Production.Product
WHERE StandardCost > 0
ORDER BY StandardCost ASC;


-- Part 8: Calculated Columns and String/Date Functions

-- 36. Calculate the gross profit margin (ListPrice minus StandardCost) for all products, aliasing the new column as 'ProfitMargin'.
SELECT ListPrice - StandardCost AS ProfitMargin FROM Production.Product;

-- 37. Display the FirstName and LastName from Person.Person concatenated together with a space in between, aliased as 'FullName'.
SELECT FirstName + ' ' + LastName AS FullName FROM Person.Person;

SELECT CONCAT(FirstName, ' ', LastName) AS FullName,  LEFT(LastName, 3) AS LastnameChar FROM Person.Person

-- 38. Calculate the total line value in Sales.SalesOrderDetail by multiplying UnitPrice by OrderQty, aliased as 'LineValue'.
SELECT SalesOrderID, UnitPrice * OrderQty AS LineValue
FROM Sales.SalesOrderDetail;

-- 39. Display the BusinessEntityID and the year the employee was hired (using a function to extract the year from HireDate). 
SELECT BusinessEntityID, 
YEAR(HireDate) AS HireYear
FROM HumanResources.Employee;

-- 40. Display the Name of all products converted entirely to UPPERCASE.
SELECT UPPER(Name) AS ProductName
FROM Production.Product;


-- Part 9: Basic Aggregation

-- 41. Count the total number of rows in the Production.Product table.
SELECT COUNT(*) AS NumberOfRows
FROM Production.Product;

-- 42. Calculate the average ListPrice of all products.
SELECT AVG(ListPrice) AS AverageListPrice
FROM Production.Product;

-- 43. Find the maximum number of VacationHours any single employee has.
SELECT MAX(VacationHours)
FROM HumanResources.Employee;

-- 44. Find the minimum StandardCost among all products (excluding those with a cost of 0).
SELECT MIN(StandardCost)
FROM Production.Product
WHERE StandardCost > 0;

-- 45. Calculate the grand total sum of TotalDue for all orders combined in Sales.SalesOrderHeader.
SELECT SUM(TotalDue)
FROM Sales.SalesOrderHeader;


-- Part 10: Grouping and Filtering Groups (GROUP BY / HAVING)

-- 46. Count how many products exist for each Color in the Production.Product table.
SELECT Color, COUNT(*)
FROM Production.Product
WHERE Color IS NOT NULL
GROUP BY Color;


-- 47. Calculate the average ListPrice of products, grouped by their ProductLine.
SELECT ProductLine, AVG(ListPrice)
FROM Production.Product
GROUP BY ProductLine;

-- 48. Count how many employees share each JobTitle.
SELECT JobTitle, COUNT(*)
FROM HumanResources.Employee
GROUP BY JobTitle;

-- 49. Find the total order quantity (OrderQty) for each ProductID in Sales.SalesOrderDetail, 
--     but only show products that have a total lifetime order quantity greater than 1,000.
SELECT ProductID, SUM(OrderQty)
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING SUM(OrderQty) > 1000;

-- 50. Group sales orders by SalesPersonID and calculate the total TotalDue for each salesperson, 
--     but only include salespeople who have generated over $1,000,000 in total sales.
SELECT SalesPersonID, SUM(TotalDue)
FROM Sales.SalesOrderHeader
GROUP BY SalesPersonID
HAVING SUM(TotalDue) > 1000000;  -- Total sales is not mention in table so If total Due is greater than 1000000 than obviously sales is also greater than 1000000.

----------------------------------------------------+++++-------------------------------------------------------

SELECT NationalIDNumber, BirthDate, DATEDIFF(YEAR, BirthDate, GETDATE()) AS Age FROM HumanResources.Employee
ORDER BY Age DESC;



SELECT BirthDate, DATEDIFF(YEAR, BirthDate, GETDATE()) FROM HumanResources.Employee



SELECT NationalIDNumber, VacationHours, SickLeaveHours 
FROM HumanResources.Employee
WHERE VacationHours >= 16 OR SickLeaveHours >= 16;


SELECT NationalIDNumber, VacationHours, SickLeaveHours 
FROM HumanResources.Employee
WHERE (VacationHours + SickLeaveHours) >= 16;
