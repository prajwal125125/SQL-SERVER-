
-- ADVANCED SQL SERVER FUNCTIONS

-- 01. CAST
-- CAST converts one datatype into another. It follows ANSI SQL standards and is portable across databases.
-- Syntax : CAST(expression AS datatype)
SELECT StudentName,
       CAST(Fees AS VARCHAR(10)) AS Fees_Text
FROM StudentBasic;


-- 02. COALESCE
-- Returns the first non-NULL value from a list of expressions.
-- Syntax : COALESCE(value1, value2, ...)
SELECT StudentName,
       COALESCE(Email, 'Email Not Provided') AS EmailStatus
FROM StudentBasic;


-- 03. CONVERT
-- Converts one datatype to another and supports format styles (mainly for dates).
-- Syntax : CONVERT(datatype, expression, style)
SELECT StudentName,
       CONVERT(VARCHAR, AdmissionDate, 105) AS AdmissionDate_Formatted
FROM StudentBasic;


-- 04. CURRENT_USER
-- Returns the current database user executing the query.
-- Syntax : CURRENT_USER
SELECT StudentName,
       CURRENT_USER AS CurrentDBUser
FROM StudentBasic;


-- 05. IIF
-- Acts like a simple IF–ELSE condition. Returns one value if condition is TRUE, otherwise another.
-- Syntax : IIF(condition, true_value, false_value)
SELECT StudentName,
       IIF(Fees >= 60000, 'High Fees', 'Normal Fees') AS FeeCategory
FROM StudentBasic;


-- 06. ISNULL
-- Replaces NULL with a specified value. Accepts only two arguments.
-- Syntax : ISNULL(expression, replacement_value)
SELECT StudentName,
       ISNULL(Email, 'No Email') AS EmailStatus
FROM StudentBasic;


-- 07. ISNUMERIC
-- Checks whether a value can be treated as numeric. Returns 1 (Yes) or 0 (No).
-- Syntax : ISNUMERIC(expression)
SELECT StudentName,
       ISNUMERIC(Fees) AS IsFeesNumeric
FROM StudentBasic;


-- 08. NULLIF
-- Returns NULL if two expressions are equal, otherwise returns the first expression.
-- Syntax : NULLIF(value1, value2)
SELECT StudentName,
       NULLIF(Fees, 60000) AS FeesResult
FROM StudentBasic;


-- 09. SESSION_USER
-- Returns the database user for the current session.
-- Syntax : SESSION_USER
SELECT StudentName,
       SESSION_USER AS SessionUserName
FROM StudentBasic;


-- 10. SESSIONPROPERTY
-- Returns information about session-level settings.
-- Syntax : SESSIONPROPERTY(property_name)
SELECT StudentName,
       SESSIONPROPERTY('ANSI_NULLS') AS AnsiNullSetting
FROM StudentBasic;


-- 11. SYSTEM_USER
-- Returns the login name used to connect to SQL Server.
-- Syntax : SYSTEM_USER
SELECT StudentName,
       SYSTEM_USER AS LoginName
FROM StudentBasic;


-- 12. USER_NAME
-- Returns the database user name based on user ID.
-- Syntax : USER_NAME([user_id])
SELECT StudentName,
       USER_NAME() AS DatabaseUser
FROM StudentBasic;

--------------------------------------------------------+++++-------------------------------------------------

-- User defined function example

-- Scalar Function → returns single value
-- Inline Table-Valued Function → returns table
-- Multi-Statement Table-Valued Function → returns table with logic


GO
CREATE FUNCTION dbo.fn_FindAgeGroup
(
    @Age INT
)
RETURNS VARCHAR(20)
AS
BEGIN
    RETURN
    (
        CASE
            WHEN @Age < 18 THEN 'Minor'
            WHEN @Age BETWEEN 18 AND 20 THEN 'Young Adult'
            ELSE 'Adult'
        END
    );
END;
GO


SELECT StudentName,
       Age,
       dbo.fn_FindAgeGroup(Age) AS AgeGroup
FROM StudentBasic;