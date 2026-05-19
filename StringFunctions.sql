
-- SQL SERVER FUNCTIONS (String Function)

-- 01. ASCII()

/*
> The ASCII() function in SQL Server is a handy tool for identifying the numeric representation of a character.
> If you provide a longer string, SQL Server only evaluates the very first character.
> Syntax : ASCII ( character_expression )
*/
SELECT 
    StudentName, 
    ASCII(StudentName) AS FirstCharAscii
FROM StudentBasic;

/*
Sometimes names might have leading spaces that are hard to see. You can use ASCII()
to check if a name starts with a space (ASCII value 32).
*/
SELECT StudentId, StudentName
FROM StudentBasic
WHERE ASCII(StudentName) = 32;

--------------------------------------------------+++++--------------------------------------------------------

-- 02. CHAR()

/*
> The CHAR() function converts an int ASCII code into a character.
> An integer from 0 through 255. If the number is outside this range, it usually returns NULL.
> Syntax : CHAR ( integer_expression )
Common Control Characters :
  CHAR(10): Line Feed (New line)
  CHAR(9): Tab
  CHAR(44): Comma
*/
SELECT CHAR(100);

SELECT         -- char(13) is for two separate lines within a single cell
    StudentName + CHAR(13) + Email AS ContactCard
FROM StudentBasic
WHERE StudentId = 1;

-- char(40) for '(' and char(41) for ')'
SELECT 
    StudentName, 
    CHAR(40) + Course + CHAR(41) AS FormattedCourse
FROM StudentBasic;

--------------------------------------------------+++++--------------------------------------------------------

-- 03. CHARINDEX()

/*
> It is essentially a "search" tool that tells you the starting position
  of a specific character or substring within a larger string.
> If the search term isn't found, it returns 0.
> Syntax : CHARINDEX ( expression_to_find , expression_to_search [ , start_location ] )
*/
SELECT 
    StudentName, 
    Email, 
    CHARINDEX('@', Email) AS AtSymbolPosition
FROM StudentBasic;

SELECT 
    Email,
    LEFT(Email, CHARINDEX('@', Email) - 1) AS Username
FROM StudentBasic
WHERE CHARINDEX('@', Email) > 0;

--------------------------------------------------+++++--------------------------------------------------------

-- 04. CONCAT()
/*
> The CONCAT() function joins (concatenates) two or more strings into one single string.
> Unlike the + operator, CONCAT() automatically converts NULL values into empty strings.
> Syntax : CONCAT(string1, string2, ...., string_n)
*/
SELECT 
    StudentName, 
    Course,
    CONCAT(StudentName, ' is enrolled in ', Course) AS EnrollmentStatus
FROM StudentBasic;

SELECT 
    CONCAT('ID #', StudentId, ': ', StudentName) AS StudentLabel
FROM StudentBasic;

--------------------------------------------------+++++--------------------------------------------------------

-- 05. CONCAT_WS()
-- The CONCAT_WS() function adds two or more strings together with a separator.
-- Syntax : CONCAT_WS('separator', string1, string2, ...)
SELECT CONCAT_WS(' - ', StudentName, Course, Email) AS QuickSummary
FROM StudentBasic;

--------------------------------------------------+++++--------------------------------------------------------

-- 06. DATALENGTH()
-- The DATALENGTH() function returns the number of bytes used to represent any expression.
-- Syntax : DATALENGTH ( expression )
SELECT 
    StudentName, 
    LEN(StudentName) AS CharacterCount, 
    DATALENGTH(StudentName) AS ByteCount
FROM StudentBasic
WHERE StudentId = 2; 

SELECT StudentName
FROM StudentBasic
WHERE LEN(StudentName) <> DATALENGTH(StudentName);

--------------------------------------------------+++++--------------------------------------------------------

-- 07. DIFFERANCE()
-- It is used to compare how similar two strings sound when spoken in English.
-- The DIFFERENCE() function compares two SOUNDEX values, and returns an integer.
-- The integer value indicates the match for the two SOUNDEX values, from 0 to 4.
SELECT DIFFERENCE('Paartha', 'Prajwal');

SELECT StudentName,
       DIFFERENCE(StudentName, 'Namith') AS SimilarityScore
FROM StudentBasic;

--------------------------------------------------+++++--------------------------------------------------------

-- 08. FORMAT()
-- Formats date/number into specific pattern (culture aware).
-- Syntax : FORMAT(value, format [, culture])
SELECT FORMAT(GETDATE(),'dd-MM-yyyy');

SELECT StudentName,
       FORMAT(AdmissionDate,'dd MMM yyyy') AS FormattedDate,
       FORMAT(Fees,'C','en-IN') AS FeesInRupee
FROM StudentBasic;

--------------------------------------------------+++++--------------------------------------------------------

-- 09 LEFT()
-- Extracts characters from left side.
-- Syntax : LEFT(string, length)
SELECT LEFT('Database',4);

SELECT RIGHT('Kem Chho mota bhai',9);

SELECT StudentName,
       LEFT(StudentName,3) AS ShortName
FROM StudentBasic;

--------------------------------------------------+++++--------------------------------------------------------

-- 10. LEN()
-- Returns string length (excluding trailing spaces).
-- Syntax : LEN(string)
SELECT LEN('Amith');

SELECT StudentName,
       LEN(StudentName) AS NameLength
FROM StudentBasic;

--------------------------------------------------+++++--------------------------------------------------------

-- 11. LOWER()
-- Converts to lowercase
-- Syntax : LOWER(string)
SELECT LOWER(StudentName) AS LowerName
FROM StudentBasic
WHERE StudentName = 'Amith';


-- 12. LTRIM()
-- Removes leading spaces
-- Syntax : LTRIM(string)
SELECT LTRIM('   Hello');

SELECT LTRIM(StudentName) 
FROM StudentBasic;


-- 13. NCHAR()
-- Returns Unicode character from numeric code
-- Syntax : NCHAR(number)
SELECT NCHAR(65);

SELECT StudentName + NCHAR(9733) AS NameWithStar
FROM StudentBasic;


-- 14. PATINDEX()
-- Finds pattern position (supports wildcards)
-- Syntax : PATINDEX('%pattern%', string)
SELECT PATINDEX('%esh%','Yogesh');

SELECT StudentName,
       PATINDEX('%a%',StudentName) AS PositionOfA
FROM StudentBasic;


-- 15. QUOTENAME()
-- Adds delimiters ([] by default)
-- Syntax : QUOTENAME(string [,quote_char])
SELECT QUOTENAME('Student Name');

SELECT QUOTENAME(StudentName) 
FROM StudentBasic;


-- 16. REPLACE()
-- It replace substring
-- Syntax : REPLACE(string, old, new)
SELECT REPLACE('SQL Server','Server','Database');

SELECT REPLACE(Email,'gmail.com','outlook.com')
FROM StudentBasic;


-- 17. REPLICATES()
-- Repeats string N times
-- Syntax : REPLICATE(string, count)
SELECT REPLICATE('*',5);

SELECT StudentName,
       REPLICATE('*',5) + StudentName AS Masked
FROM StudentBasic;


-- 18. REVERSE()
-- it reverse the string
-- Syntax : REVERSE(string)
SELECT StudentName,
       REVERSE(StudentName)
FROM StudentBasic;


-- 19. RIGHT()
-- Extract from right
-- Syntax : RIGHT(string, length)
SELECT RIGHT(Email,10) AS DomainPart
FROM StudentBasic;


-- 20. RTRIM()
-- Remove trailing spaces
SELECT RTRIM(StudentName)
FROM StudentBasic;


-- 21. SPACE()
-- Return n spaces
SELECT 'Yogesh' + SPACE(5) + 'Rebari';

SELECT StudentName + SPACE(3) + Course
FROM StudentBasic;


-- 22. STR()
-- Converts numeric to string
-- Syntax : STR(number, length, decimals)
SELECT STR(Fees,10,2)
FROM StudentBasic;


-- 23. STUFF()
-- Delete + insert string
-- Syntax : STUFF(string, start, length, new_string)
SELECT STUFF('Database',5,2,'XY');

SELECT STUFF(StudentName,2,3,'***')
FROM StudentBasic;


-- 24. SUBSTRING()
-- Extract part of string
-- Syntax : SUBSTRING(string, start, length)
SELECT SUBSTRING(StudentName,1,4)
FROM StudentBasic;

-- 25. TRANSLATE()
-- Character-by-character replace (multiple at once)
-- Syntax : TRANSLATE(input, from_chars, to_chars)
SELECT TRANSLATE('123-456','-','/');

SELECT TRANSLATE(Email,'@.','##_')
FROM StudentBasic;


-- 26. TRIM()
-- Removes leading & trailing spaces
SELECT TRIM('.' FROM '...Hello...');

SELECT TRIM(StudentName)
FROM StudentBasic;


-- 27. UNICODE()
-- Returns Unicode value of first character
SELECT UNICODE('A');

SELECT StudentName,
       UNICODE(StudentName) AS FirstCharCode
FROM StudentBasic;


-- 28. UPPER()
-- Convert to upper
SELECT UPPER(StudentName)
FROM StudentBasic;

