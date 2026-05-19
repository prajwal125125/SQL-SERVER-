
-- SQL Server Math/Numeric function

-- 01. ABS – Absolute Value

-- Returns the positive value of a number. If the number is negative, it removes the minus sign.
-- Syntax : ABS(number)
SELECT ABS(-10);

SELECT StudentName, ABS(Fees - 60000) AS FeeDifference
FROM StudentBasic;



-- 02. ACOS – Arc Cosine

-- Returns the inverse cosine (in radians). Input value must be between -1 and 1.
-- Syntax : ACOS(float_expression)
SELECT ACOS(0.5);

SELECT StudentName, ACOS(Age / 30.0) AS Result
FROM StudentBasic
WHERE Age <= 30;



-- 03. ASIN – Arc Sine

-- Returns the inverse sine (in radians). Value must be between -1 and 1.
-- Syntax : ASIN(float_expression)
SELECT ASIN(0.5);

SELECT StudentName, ASIN(Age / 30.0) AS Result
FROM StudentBasic
WHERE Age <= 30;



-- 04. ATAN – Arc Tangent

-- Returns the inverse tangent of a number (in radians).
-- Syntax : ATAN(float_expression)
SELECT ATAN(1);

SELECT StudentName, ATAN(Fees / 100000.0) AS Result
FROM StudentBasic;



-- 05. ATN2 – Arc Tangent of Two Numbers

-- Returns the angle (in radians) based on Y and X coordinates.
-- Syntax : ATN2(y, x)
SELECT ATN2(10, 20);

SELECT StudentName, ATN2(Fees, Age) AS Result
FROM StudentBasic;



-- 06. AVG – Average

-- Calculates the average value of a numeric column.
-- Syntax : AVG(expression)
SELECT AVG(Fees) AS AverageFees
FROM StudentBasic;



-- 07. CEILING

-- Rounds a number up to the nearest integer.
-- Syntax : CEILING(number)
SELECT CEILING(12.3);

SELECT StudentName, CEILING(Fees / 1000.0) AS RoundedFees
FROM StudentBasic;



-- 08. COUNT

-- Returns the number of rows that match the query.
-- Syntax : COUNT(column_name | *)
SELECT COUNT(*) AS TotalStudents
FROM StudentBasic;



-- 09. COS – Cosine

-- Returns the cosine of a number (value in radians).
-- Syntax : COS(number)
SELECT COS(1);

SELECT StudentName, COS(Age) AS CosValue
FROM StudentBasic;



-- 10. COT – Cotangent

-- Returns the cotangent of a number (1 / TAN).
-- Syntax : COT(number)
SELECT COT(1);

SELECT StudentName, COT(Age) AS CotValue
FROM StudentBasic;



-- 11. DEGREES

-- Converts radians to degrees.
-- Syntax : DEGREES(radians)
SELECT DEGREES(PI());

SELECT StudentName, DEGREES(ATAN(Age)) AS DegreeValue
FROM StudentBasic;



-- 12. EXP

-- Returns e raised to the power of a number.
-- Syntax : EXP(number)
SELECT EXP(1);

SELECT StudentName, EXP(Age / 100.0) AS ExpValue
FROM StudentBasic;



-- 13. FLOOR

-- Rounds a number down to the nearest integer.
-- Synatx : FLOOR(number)
SELECT FLOOR(12.9);

SELECT StudentName, FLOOR(Fees / 1000.0) AS FloorFees
FROM StudentBasic;



-- 14. LOG

-- Returns the natural log, or log with a specified base.
-- Syntax : LOG(number [, base])
SELECT LOG(10);

SELECT StudentName, LOG(Fees) AS LogFees
FROM StudentBasic;



-- 15. LOG10

-- Returns logarithm of a number to base 10.
-- Syntax : LOG10(number)
SELECT LOG10(100);

SELECT StudentName, LOG10(Fees) AS Log10Fees
FROM StudentBasic;



-- 16. MAX

-- Returns the highest value from a column.
-- Syntax : MAX(column)
SELECT MAX(Fees) AS MaxFees
FROM StudentBasic;



-- 17. MIN

-- Returns the lowest value from a column.
-- Syntax : MIN(column)
SELECT MIN(Age) AS MinAge
FROM StudentBasic;



-- 18. PI

-- Returns the constant value of π (3.14159...).
SELECT PI();


-- 19. POWER

-- Raises a number to the power of another number.
-- Syntax : POWER(number, power)
SELECT StudentName, POWER(Age, 2) AS AgeSquare
FROM StudentBasic;


-- 20. RADIANS

-- Converts degrees to radians.
-- Syntax : RADIANS(degrees)
SELECT RADIANS(56);

SELECT StudentName, RADIANS(Age) AS RadianValue
FROM StudentBasic;


-- 21. RAND

-- Generates a random number between 0 and 1.
-- Syntax : RAND()
SELECT RAND();


-- 22. ROUND

-- Rounds a number to a specified decimal place.
-- Syntax : ROUND(number, decimals)
SELECT StudentName, ROUND(Fees / 1000.0, 2) AS RoundedFees
FROM StudentBasic;


-- 23. SIGN

-- Returns -1, 0, or 1 depending on the sign of the number.
-- Syntax : SIGN(number)
SELECT StudentName, SIGN(Fees - 50000) AS FeeSign
FROM StudentBasic;


-- 24. SIN

-- Returns the sine of a number (in radians).
-- Syntax : SIN(number)
SELECT StudentName, SIN(Age) AS SinValue
FROM StudentBasic;


-- 25. SQRT

-- Returns the square root of a number.
-- Syntax : SQRT(number)
SELECT StudentName, SQRT(Fees) AS SqrtFees
FROM StudentBasic;


-- 26. SQUARE

-- Returns the square of a number.
-- Syntax : SQUARE(number)
SELECT StudentName, SQUARE(Age) AS AgeSquare
FROM StudentBasic;


-- 27. SUM

-- Returns the total sum of a column.
-- Syntax : SUM(column)
SELECT SUM(Fees) AS TotalFees
FROM StudentBasic;


-- 28. TAN

-- Returns the tangent of a number (in radians).
-- Syntax : TAN(number)
SELECT StudentName, TAN(Age) AS TanValue
FROM StudentBasic;

-----------------------------------------------------+++++------------------------------------------------------