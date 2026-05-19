
-- SQL Server Date & Time Functions

-- 01. CURRENT_TIMESTAMP
-- Returns the current date and time of the SQL Server system. It is ANSI-SQL standard and works like
SELECT CURRENT_TIMESTAMP;

SELECT StudentName, AdmissionDate, CURRENT_TIMESTAMP AS TodayDate
FROM StudentBasic;


-- 02. DATEADD
-- Adds a specific time interval (days, months, years, etc.) to a given date and returns the new date.
-- Syntax : DATEADD(datepart, number, date)
SELECT DATEADD(MONTH, 15, '2024-01-01');

SELECT StudentName,
       AdmissionDate,
       DATEADD(YEAR, 1, AdmissionDate) AS NextYearDate
FROM StudentBasic;


-- 03. DATEDIFF
-- Returns the difference between two dates in terms of days, months, years, etc.
-- Syntax : DATEDIFF(datepart, startdate, enddate)
SELECT DATEDIFF(MONTH, '2004-12-28', '2026-12-28');

SELECT StudentName,
       DATEDIFF(MONTH, AdmissionDate, GETDATE()) AS DaysSinceAdmission
FROM StudentBasic;


-- 04. DATEFROMPARTS
-- Creates a date using year, month, and day values.
-- Syntax : DATEFROMPARTS(year, month, day)
SELECT DATEFROMPARTS(2024, 5, 10);

SELECT StudentName,
       DATEFROMPARTS(YEAR(AdmissionDate), 12, 31) AS YearEndDate
FROM StudentBasic;


-- 05. DATENAME
-- Returns a specific part of a date as text, such as month name or weekday.
-- Syntax : DATENAME(datepart, date)
SELECT DATENAME(MONTH, '2024-02-15');

SELECT StudentName,
       DATENAME(MONTH, AdmissionDate) AS AdmissionMonth
FROM StudentBasic;


-- 06. DATEPART
-- Returns a specific part of a date as a number, such as year, month, or day.
-- Syntax : DATEPART(datepart, date)
SELECT DATEPART(MONTH, '2024-02-15');

SELECT StudentName,
       DATEPART(YEAR, AdmissionDate) AS AdmissionYear
FROM StudentBasic;


-- 07. DAY
-- Returns the day number (1–31) from a date.
-- Syntax : DAY(date)
SELECT DAY('2024-02-15');

SELECT StudentName,
       DAY(AdmissionDate) AS AdmissionDay
FROM StudentBasic;


-- 08. GETDATE
-- Returns the current system date and time of SQL Server.
-- Syntax : GETDATE()
SELECT GETDATE();

SELECT StudentName,
       AdmissionDate,
       GETDATE() AS CurrentDate
FROM StudentBasic;


-- 09. GETUTCDATE
-- Returns the current UTC (Universal Time) date and time.
SELECT GETUTCDATE();

SELECT StudentName,
       GETUTCDATE() AS UTCDateTime
FROM StudentBasic;


-- 10. ISDATE
-- Checks whether a value is a valid date. Returns 1 if true, otherwise 0.
SELECT ISDATE('2024-02-30');

SELECT StudentName,
       ISDATE(AdmissionDate) AS IsValidDate
FROM StudentBasic;


-- 11. MONTH
-- Returns the month number (1–12) from a date.
SELECT MONTH('2024-02-15');

SELECT StudentName,
       MONTH(AdmissionDate) AS AdmissionMonthNo
FROM StudentBasic;


-- 12. SYSDATETIME
-- Returns the current system date and time with higher precision than GETDATE().
SELECT SYSDATETIME();

SELECT StudentName,
       SYSDATETIME() AS SystemDateTime
FROM StudentBasic;


-- 13. YEAR
-- Returns the year part of a given date.
SELECT YEAR('2024-02-15');

SELECT StudentName,
       YEAR(AdmissionDate) AS AdmissionYear
FROM StudentBasic;

-----------------------------------------------------+++++------------------------------------------------------