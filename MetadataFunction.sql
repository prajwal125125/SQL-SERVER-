
-- Metadata Functions

-- 01. COL_LENGTH()
-- Returns maximum length (in bytes) of a column.
-- Syntax : COL_LENGTH('table_name', 'column_name')
SELECT COL_LENGTH('StudentBasic', 'StudentName') AS NameLength;


-- 02. COL_NAME()
-- Returns column name using column ID.
-- Syntax : COL_NAME(object_id, column_id)
SELECT COL_NAME(OBJECT_ID('StudentBasic'), 2);


-- 03. COLUMNPROPERTY()
-- Returns properties of a column.
SELECT COLUMNPROPERTY(
       OBJECT_ID('StudentBasic'),
       'StudentId',
       'IsIdentity') AS IsIdentity;


-- 04. DATABASEPROPERTY()
-- Returns database-level property (older version).
SELECT DATABASEPROPERTY(DB_NAME(), 'Status');


-- 05. DATABASEPROPERTYEX()
-- Returns extended database properties.
SELECT DATABASEPROPERTYEX(DB_NAME(), 'Recovery');


-- 06. DB_ID()
-- Returns database ID.
SELECT DB_ID('StudentRecord');


-- 07. DB_NAME()
-- Returns database name from ID.
SELECT DB_NAME(2);


-- 08. FILE_ID()
-- Returns database file ID.
SELECT FILE_ID('StudentRecord');


-- 09. FILE_NAME()
-- Returns file name from file ID.
SELECT FILE_NAME(1);


-- 10. FILEGROUP_ID()
-- Returns filegroup ID.
SELECT FILEGROUP_ID('PRIMARY');


-- 11. FILEGROUP_NAME()
-- Returns filegroup name
SELECT FILEGROUP_NAME(1);


-- 12. FILEGROUPPROPERTY()
-- Returns properties of a filegroup.
SELECT FILEGROUPPROPERTY('PRIMARY', 'IsDefault');


-- 13. FILEPROPERTY()
-- Returns properties of database files.
SELECT FILEPROPERTY('StudentRecord', 'SpaceUsed');


-- 14. fn_listextendedproperty()
-- Returns custom metadata (descriptions, comments).
/*SELECT *
FROM fn_listextendedproperty (
     NULL, 'SCHEMA', 'dbo',
     'TABLE', 'StudentBasic',
     NULL, NULL
);*/


-- 15. FULLTEXTCATALOGPROPERTY()
-- Returns full-text catalog properties.
SELECT FULLTEXTCATALOGPROPERTY('YourCatalog', 'PopulateStatus');


-- 16. FULLTEXTSERVICEPROPERTY()
-- Returns full-text service settings.
SELECT FULLTEXTSERVICEPROPERTY('IsFullTextInstalled');


-- 17. INDEX_COL()
-- Returns column name in an index.
SELECT INDEX_COL('StudentBasic', 3, 1);


-- 18. INDEXKEY_PROPERTY()
-- Returns index key properties.
SELECT INDEXKEY_PROPERTY(
       OBJECT_ID('StudentBasic'),
       1, 1, 'IsDescending');


-- 19. INDEXPROPERTY()
-- Returns index-level properties.
SELECT INDEXPROPERTY(
       OBJECT_ID('StudentBasic'),
       'PK_StudentBasic',
       'IsUnique');


-- 20. OBJECT_ID()
-- Returns object ID of table/view/procedure.
SELECT OBJECT_ID('StudentBasic');


-- 21. OBJECT_NAME()
-- Returns object name from object ID.
SELECT OBJECT_NAME(1093578934);


-- 22. OBJECTPROPERTY()
-- Returns object-level properties.
SELECT OBJECTPROPERTY(
       OBJECT_ID('StudentBasic'),
       'TableHasPrimaryKey');
	   
	   
-- 23. OBJECTPROPERTYEX()
-- Extended object properties.
SELECT OBJECTPROPERTYEX(
       OBJECT_ID('StudentBasic'),
       'IsUserTable');


-- 24. @@PROCID
-- Returns current stored procedure ID.
SELECT @@PROCID;


-- 25. SQL_VARIANT_PROPERTY()
-- Returns base type of sql_variant.
SELECT SQL_VARIANT_PROPERTY(CAST(25 AS sql_variant), 'BaseType');


-- 26. TYPEPROPERTY()
-- Returns user-defined type properties.
SELECT TYPEPROPERTY('int', 'Precision');


-- 27. CHANGE_TRACKING_CURRENT_VERSION()
SELECT CHANGE_TRACKING_CURRENT_VERSION();

