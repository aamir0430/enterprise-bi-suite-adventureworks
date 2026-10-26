/* ============================================================
   01_restore_validation.sql
   Purpose : Confirm AdventureWorks2025 and AdventureWorksDW2025
             were restored correctly on SQL Server 2025.
   Run in  : SSMS, connected to localhost (any database context).
   Output  : Result sets 1-5.
             Result set 6 is DBCC CHECKDB: no rows and a
             "Commands completed successfully" message = no errors.
   ============================================================ */
SET NOCOUNT ON;

/* 1. Both databases present and online? */
SELECT name                 AS DatabaseName,
       state_desc           AS [State],
       compatibility_level  AS CompatLevel,
       recovery_model_desc  AS RecoveryModel
FROM sys.databases
WHERE name IN (N'AdventureWorks2025', N'AdventureWorksDW2025')
ORDER BY name;

/* 2. Row counts for every table used in the project.
      Status: PASS = exists and has rows, EMPTY = exists but 0 rows,
              MISSING = table not found (name differs or restore problem). */
IF OBJECT_ID('tempdb..#Checks') IS NOT NULL DROP TABLE #Checks;

CREATE TABLE #Checks (
    DatabaseName SYSNAME     NOT NULL,
    SchemaName   SYSNAME     NOT NULL,
    TableName    SYSNAME     NOT NULL,
    [Status]     VARCHAR(10) NULL,
    [Rows]       BIGINT      NULL
);

INSERT INTO #Checks (DatabaseName, SchemaName, TableName) VALUES
 (N'AdventureWorks2025', N'Sales',          N'SalesOrderHeader'),
 (N'AdventureWorks2025', N'Sales',          N'SalesOrderDetail'),
 (N'AdventureWorks2025', N'Sales',          N'SalesTerritory'),
 (N'AdventureWorks2025', N'Sales',          N'SalesPerson'),
 (N'AdventureWorks2025', N'Sales',          N'Customer'),
 (N'AdventureWorks2025', N'Person',         N'Person'),
 (N'AdventureWorks2025', N'Production',     N'Product'),
 (N'AdventureWorks2025', N'Production',     N'ProductSubcategory'),
 (N'AdventureWorks2025', N'Production',     N'ProductCategory'),
 (N'AdventureWorks2025', N'Production',     N'ProductCostHistory'),
 (N'AdventureWorks2025', N'Production',     N'ProductInventory'),
 (N'AdventureWorks2025', N'Production',     N'Location'),
 (N'AdventureWorks2025', N'Purchasing',     N'PurchaseOrderHeader'),
 (N'AdventureWorks2025', N'Purchasing',     N'PurchaseOrderDetail'),
 (N'AdventureWorks2025', N'Purchasing',     N'Vendor'),
 (N'AdventureWorks2025', N'HumanResources', N'Employee'),
 (N'AdventureWorks2025', N'HumanResources', N'EmployeePayHistory'),
 (N'AdventureWorks2025', N'HumanResources', N'EmployeeDepartmentHistory'),
 (N'AdventureWorks2025', N'HumanResources', N'Department'),
 (N'AdventureWorksDW2025', N'dbo',          N'DimDate'),
 (N'AdventureWorksDW2025', N'dbo',          N'DimProduct'),
 (N'AdventureWorksDW2025', N'dbo',          N'DimCustomer'),
 (N'AdventureWorksDW2025', N'dbo',          N'DimSalesTerritory'),
 (N'AdventureWorksDW2025', N'dbo',          N'DimEmployee'),
 (N'AdventureWorksDW2025', N'dbo',          N'FactInternetSales'),
 (N'AdventureWorksDW2025', N'dbo',          N'FactResellerSales'),
 (N'AdventureWorksDW2025', N'dbo',          N'FactFinance');

DECLARE @db  SYSNAME,
        @sch SYSNAME,
        @tbl SYSNAME,
        @sql NVARCHAR(MAX),
        @cnt BIGINT;

DECLARE chk CURSOR LOCAL STATIC FOR
    SELECT DatabaseName, SchemaName, TableName FROM #Checks;

OPEN chk;
FETCH NEXT FROM chk INTO @db, @sch, @tbl;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF OBJECT_ID(QUOTENAME(@db) + N'.' + QUOTENAME(@sch) + N'.' + QUOTENAME(@tbl), N'U') IS NULL
    BEGIN
        UPDATE #Checks
        SET [Status] = 'MISSING'
        WHERE DatabaseName = @db AND SchemaName = @sch AND TableName = @tbl;
    END
    ELSE
    BEGIN
        SET @cnt = NULL;
        SET @sql = N'SELECT @n = COUNT_BIG(*) FROM '
                 + QUOTENAME(@db) + N'.' + QUOTENAME(@sch) + N'.' + QUOTENAME(@tbl) + N';';
        EXEC sys.sp_executesql @sql, N'@n BIGINT OUTPUT', @n = @cnt OUTPUT;

        UPDATE #Checks
        SET [Rows]   = @cnt,
            [Status] = CASE WHEN @cnt > 0 THEN 'PASS' ELSE 'EMPTY' END
        WHERE DatabaseName = @db AND SchemaName = @sch AND TableName = @tbl;
    END

    FETCH NEXT FROM chk INTO @db, @sch, @tbl;
END

CLOSE chk;
DEALLOCATE chk;

SELECT DatabaseName,
       SchemaName + N'.' + TableName AS [Table],
       [Status],
       [Rows]
FROM #Checks
ORDER BY DatabaseName, SchemaName, TableName;

/* 3. Summary (NeedsAttention should be 0) */
SELECT COUNT(*)                                         AS TablesChecked,
       SUM(CASE WHEN [Status] = 'PASS' THEN 1 ELSE 0 END) AS Passed,
       SUM(CASE WHEN [Status] <> 'PASS' THEN 1 ELSE 0 END) AS NeedsAttention
FROM #Checks;

/* 4. Order date range in the source data */
SELECT MIN(OrderDate) AS FirstOrderDate,
       MAX(OrderDate) AS LastOrderDate,
       COUNT(*)       AS TotalOrders
FROM AdventureWorks2025.Sales.SalesOrderHeader;

/* 5. Integrity check (prints nothing if clean) */
DBCC CHECKDB (N'AdventureWorks2025')   WITH NO_INFOMSGS;
DBCC CHECKDB (N'AdventureWorksDW2025') WITH NO_INFOMSGS;

DROP TABLE #Checks;
