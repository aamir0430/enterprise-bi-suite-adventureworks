/*
    File: 02_finance_etl.sql
    Project: Enterprise Business Intelligence Suite - AdventureWorks
    Purpose: Incremental, repeatable ETL for Finance dimensions and facts.
    Source: AdventureWorks2025 (OLTP)
    Target: EnterpriseBI_DW

    IMPORTANT:
    - This script does NOT drop, truncate, or recreate warehouse tables.
    - Existing identity surrogate keys are preserved.
    - Dimensions are updated/inserted using their source business keys.
    - Facts are updated/inserted using their source transaction identifiers.
*/

USE EnterpriseBI_DW;
GO

SET NOCOUNT ON;
GO

/*
  0. ENSURING ETL SCHEMA EXISTS
*/
IF SCHEMA_ID(N'etl') IS NULL
    EXEC(N'CREATE SCHEMA etl AUTHORIZATION dbo;');
GO


/*
  1. LOADING FINANCE DIMENSIONS
     Dimensions:
       DimVendor, DimEmployee, DimProduct,
       DimShipMethod, DimCurrency

     DimDate is generated/maintained separately and is not rebuilt
     by this Finance procedure.
*/

CREATE OR ALTER PROCEDURE etl.usp_LoadFinanceDimensions
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1A. DimVendor

        UPDATE T
        SET
            T.AccountNumber = S.AccountNumber,
            T.VendorName = S.Name,
            T.CreditRating = S.CreditRating,
            T.PreferredVendorStatus = S.PreferredVendorStatus,
            T.ActiveFlag = S.ActiveFlag,
            T.PurchasingWebServiceURL = S.PurchasingWebServiceURL,
            T.SourceModifiedDate = S.ModifiedDate
        FROM Dim.DimVendor AS T
        INNER JOIN AdventureWorks2025.Purchasing.Vendor AS S
            ON T.VendorID = S.BusinessEntityID;

        INSERT INTO Dim.DimVendor
        (
            VendorID, AccountNumber, VendorName, CreditRating,
            PreferredVendorStatus, ActiveFlag,
            PurchasingWebServiceURL, SourceModifiedDate
        )
        SELECT
            S.BusinessEntityID, S.AccountNumber, S.Name, S.CreditRating,
            S.PreferredVendorStatus, S.ActiveFlag,
            S.PurchasingWebServiceURL, S.ModifiedDate
        FROM AdventureWorks2025.Purchasing.Vendor AS S
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Dim.DimVendor AS T
            WHERE T.VendorID = S.BusinessEntityID
        );


        /*------------------------------
          1B. DimEmployee
          EmployeeID = HumanResources.Employee.BusinessEntityID
          Person details come from Person.Person.
        ------------------------------*/
        UPDATE T
        SET
            T.FirstName = P.FirstName,
            T.MiddleName = P.MiddleName,
            T.LastName = P.LastName,
            T.EmployeeName = CONCAT(
                P.FirstName, N' ',
                COALESCE(P.MiddleName + N' ', N''),
                P.LastName
            ),
            T.JobTitle = E.JobTitle,
            T.BirthDate = E.BirthDate,
            T.MaritalStatus = E.MaritalStatus,
            T.Gender = E.Gender,
            T.HireDate = E.HireDate,
            T.SalariedFlag = E.SalariedFlag,
            T.VacationHours = E.VacationHours,
            T.SickLeaveHours = E.SickLeaveHours,
            T.CurrentFlag = E.CurrentFlag,
            T.ModifiedDate = E.ModifiedDate
        FROM Dim.DimEmployee AS T
        INNER JOIN AdventureWorks2025.HumanResources.Employee AS E
            ON T.EmployeeID = E.BusinessEntityID
        INNER JOIN AdventureWorks2025.Person.Person AS P
            ON E.BusinessEntityID = P.BusinessEntityID;

        INSERT INTO Dim.DimEmployee
        (
            EmployeeID, FirstName, MiddleName, LastName, EmployeeName,
            JobTitle, BirthDate, MaritalStatus, Gender, HireDate,
            SalariedFlag, VacationHours, SickLeaveHours,
            CurrentFlag, ModifiedDate
        )
        SELECT
            E.BusinessEntityID,
            P.FirstName,
            P.MiddleName,
            P.LastName,
            CONCAT(
                P.FirstName, N' ',
                COALESCE(P.MiddleName + N' ', N''),
                P.LastName
            ),
            E.JobTitle,
            E.BirthDate,
            E.MaritalStatus,
            E.Gender,
            E.HireDate,
            E.SalariedFlag,
            E.VacationHours,
            E.SickLeaveHours,
            E.CurrentFlag,
            E.ModifiedDate
        FROM AdventureWorks2025.HumanResources.Employee AS E
        INNER JOIN AdventureWorks2025.Person.Person AS P
            ON E.BusinessEntityID = P.BusinessEntityID
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Dim.DimEmployee AS T
            WHERE T.EmployeeID = E.BusinessEntityID
        );


        /*------------------------------
          1C. DimProduct
          Product category/subcategory/model are descriptive attributes.
        ------------------------------*/
        UPDATE T
        SET
            T.ProductName = P.Name,
            T.ProductNumber = P.ProductNumber,
            T.Color = P.Color,
            T.Size = P.Size,
            T.Weight = P.Weight,
            T.StandardCost = P.StandardCost,
            T.ListPrice = P.ListPrice,
            T.ProductLine = P.ProductLine,
            T.Class = P.Class,
            T.Style = P.Style,
            T.MakeFlag = P.MakeFlag,
            T.FinishedGoodsFlag = P.FinishedGoodsFlag,
            T.SafetyStockLevel = P.SafetyStockLevel,
            T.ReorderPoint = P.ReorderPoint,
            T.ProductSubcategoryID = P.ProductSubcategoryID,
            T.SubcategoryName = PSC.Name,
            T.ProductCategoryID = PC.ProductCategoryID,
            T.CategoryName = PC.Name,
            T.ProductModelID = P.ProductModelID,
            T.ProductModelName = PM.Name,
            T.SellStartDate = P.SellStartDate,
            T.SellEndDate = P.SellEndDate,
            T.DiscontinuedDate = P.DiscontinuedDate
        FROM Dim.DimProduct AS T
        INNER JOIN AdventureWorks2025.Production.Product AS P
            ON T.ProductID = P.ProductID
        LEFT JOIN AdventureWorks2025.Production.ProductSubcategory AS PSC
            ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
        LEFT JOIN AdventureWorks2025.Production.ProductCategory AS PC
            ON PSC.ProductCategoryID = PC.ProductCategoryID
        LEFT JOIN AdventureWorks2025.Production.ProductModel AS PM
            ON P.ProductModelID = PM.ProductModelID;

        INSERT INTO Dim.DimProduct
        (
            ProductID, ProductName, ProductNumber, Color, Size, Weight,
            StandardCost, ListPrice, ProductLine, Class, Style,
            MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint,
            ProductSubcategoryID, SubcategoryName,
            ProductCategoryID, CategoryName,
            ProductModelID, ProductModelName,
            SellStartDate, SellEndDate, DiscontinuedDate
        )
        SELECT
            P.ProductID, P.Name, P.ProductNumber, P.Color, P.Size, P.Weight,
            P.StandardCost, P.ListPrice, P.ProductLine, P.Class, P.Style,
            P.MakeFlag, P.FinishedGoodsFlag, P.SafetyStockLevel, P.ReorderPoint,
            P.ProductSubcategoryID, PSC.Name,
            PC.ProductCategoryID, PC.Name,
            P.ProductModelID, PM.Name,
            P.SellStartDate, P.SellEndDate, P.DiscontinuedDate
        FROM AdventureWorks2025.Production.Product AS P
        LEFT JOIN AdventureWorks2025.Production.ProductSubcategory AS PSC
            ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
        LEFT JOIN AdventureWorks2025.Production.ProductCategory AS PC
            ON PSC.ProductCategoryID = PC.ProductCategoryID
        LEFT JOIN AdventureWorks2025.Production.ProductModel AS PM
            ON P.ProductModelID = PM.ProductModelID
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Dim.DimProduct AS T
            WHERE T.ProductID = P.ProductID
        );


        
        -- 1D. DimShipMethod

        UPDATE T
        SET
            T.ShipMethodName = S.Name,
            T.ShipBase = S.ShipBase,
            T.ShipRate = S.ShipRate
        FROM Dim.DimShipMethod AS T
        INNER JOIN AdventureWorks2025.Purchasing.ShipMethod AS S
            ON T.ShipMethodID = S.ShipMethodID;

        INSERT INTO Dim.DimShipMethod
        (
            ShipMethodID, ShipMethodName, ShipBase, ShipRate
        )
        SELECT
            S.ShipMethodID, S.Name, S.ShipBase, S.ShipRate
        FROM AdventureWorks2025.Purchasing.ShipMethod AS S
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Dim.DimShipMethod AS T
            WHERE T.ShipMethodID = S.ShipMethodID
        );


        
        -- 1E. DimCurrency
      
        UPDATE T
        SET T.CurrencyName = S.Name
        FROM Dim.DimCurrency AS T
        INNER JOIN AdventureWorks2025.Sales.Currency AS S
            ON T.CurrencyCode = S.CurrencyCode;

        INSERT INTO Dim.DimCurrency
        (
            CurrencyCode, CurrencyName
        )
        SELECT
            S.CurrencyCode, S.Name
        FROM AdventureWorks2025.Sales.Currency AS S
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Dim.DimCurrency AS T
            WHERE T.CurrencyCode = S.CurrencyCode
        );

        COMMIT TRANSACTION;
        PRINT 'Finance dimensions loaded/updated successfully.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


/*
  2. LOADING FACT PURCHASE ORDER HEADER
     Grain: one row per PurchaseOrderID.
*/
CREATE OR ALTER PROCEDURE etl.usp_LoadFactPurchaseOrderHeader
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        
        IF EXISTS
        (
            SELECT 1
            FROM AdventureWorks2025.Purchasing.PurchaseOrderHeader AS H
            LEFT JOIN Dim.DimVendor AS V
                ON H.VendorID = V.VendorID
            LEFT JOIN Dim.DimEmployee AS E
                ON H.EmployeeID = E.EmployeeID
            LEFT JOIN Dim.DimShipMethod AS SM
                ON H.ShipMethodID = SM.ShipMethodID
            LEFT JOIN Dim.DimDate AS OD
                ON OD.DateKey = CONVERT(INT, CONVERT(CHAR(8), H.OrderDate, 112))
            LEFT JOIN Dim.DimDate AS SD
                ON SD.DateKey = CASE
                    WHEN H.ShipDate IS NOT NULL
                    THEN CONVERT(INT, CONVERT(CHAR(8), H.ShipDate, 112))
                    ELSE NULL
                END
            WHERE V.VendorKey IS NULL
               OR E.EmployeeKey IS NULL
               OR SM.ShipMethodKey IS NULL
               OR OD.DateKey IS NULL
               OR (H.ShipDate IS NOT NULL AND SD.DateKey IS NULL)
        )
        BEGIN
            ;THROW 51001, 'Purchase order header dimension/date mapping check failed. Check DimVendor, DimEmployee, DimShipMethod and DimDate.', 1;
        END

        BEGIN TRANSACTION;

        UPDATE T
        SET
            T.RevisionNumber = H.RevisionNumber,
            T.VendorKey = V.VendorKey,
            T.EmployeeKey = E.EmployeeKey,
            T.ShipMethodKey = SM.ShipMethodKey,
            T.OrderDateKey = CONVERT(INT, CONVERT(CHAR(8), H.OrderDate, 112)),
            T.ShipDateKey = CASE
                WHEN H.ShipDate IS NOT NULL
                THEN CONVERT(INT, CONVERT(CHAR(8), H.ShipDate, 112))
                ELSE NULL
            END,
            T.Status = H.Status,
            T.SubTotal = H.SubTotal,
            T.TaxAmt = H.TaxAmt,
            T.Freight = H.Freight,
            T.TotalDue = H.TotalDue,
            T.ModifiedDate = H.ModifiedDate
        FROM Fact.FactPurchaseOrderHeader AS T
        INNER JOIN AdventureWorks2025.Purchasing.PurchaseOrderHeader AS H
            ON T.PurchaseOrderID = H.PurchaseOrderID
        LEFT JOIN Dim.DimVendor AS V
            ON H.VendorID = V.VendorID
        LEFT JOIN Dim.DimEmployee AS E
            ON H.EmployeeID = E.EmployeeID
        LEFT JOIN Dim.DimShipMethod AS SM
            ON H.ShipMethodID = SM.ShipMethodID;

        INSERT INTO Fact.FactPurchaseOrderHeader
        (
            PurchaseOrderID, RevisionNumber,
            VendorKey, EmployeeKey, ShipMethodKey,
            OrderDateKey, ShipDateKey,
            Status, SubTotal, TaxAmt, Freight, TotalDue, ModifiedDate
        )
        SELECT
            H.PurchaseOrderID,
            H.RevisionNumber,
            V.VendorKey,
            E.EmployeeKey,
            SM.ShipMethodKey,
            CONVERT(INT, CONVERT(CHAR(8), H.OrderDate, 112)),
            CASE
                WHEN H.ShipDate IS NOT NULL
                THEN CONVERT(INT, CONVERT(CHAR(8), H.ShipDate, 112))
                ELSE NULL
            END,
            H.Status,
            H.SubTotal,
            H.TaxAmt,
            H.Freight,
            H.TotalDue,
            H.ModifiedDate
        FROM AdventureWorks2025.Purchasing.PurchaseOrderHeader AS H
        LEFT JOIN Dim.DimVendor AS V
            ON H.VendorID = V.VendorID
        LEFT JOIN Dim.DimEmployee AS E
            ON H.EmployeeID = E.EmployeeID
        LEFT JOIN Dim.DimShipMethod AS SM
            ON H.ShipMethodID = SM.ShipMethodID
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Fact.FactPurchaseOrderHeader AS T
            WHERE T.PurchaseOrderID = H.PurchaseOrderID
        );

        COMMIT TRANSACTION;
        PRINT 'FactPurchaseOrderHeader loaded/updated successfully.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


/*
  3. LOADING FACT PURCHASE ORDER DETAILS
     Grain: one row per PurchaseOrderDetailID.
*/
CREATE OR ALTER PROCEDURE etl.usp_LoadFactPurchaseOrders
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF EXISTS
        (
            SELECT 1
            FROM AdventureWorks2025.Purchasing.PurchaseOrderHeader AS H
            INNER JOIN AdventureWorks2025.Purchasing.PurchaseOrderDetail AS D
                ON H.PurchaseOrderID = D.PurchaseOrderID
            LEFT JOIN Dim.DimVendor AS V
                ON H.VendorID = V.VendorID
            LEFT JOIN Dim.DimProduct AS P
                ON D.ProductID = P.ProductID
            LEFT JOIN Dim.DimEmployee AS E
                ON H.EmployeeID = E.EmployeeID
            LEFT JOIN Dim.DimShipMethod AS SM
                ON H.ShipMethodID = SM.ShipMethodID
            LEFT JOIN Dim.DimDate AS OD
                ON OD.DateKey = CONVERT(INT, CONVERT(CHAR(8), H.OrderDate, 112))
            LEFT JOIN Dim.DimDate AS DD
                ON DD.DateKey = CONVERT(INT, CONVERT(CHAR(8), D.DueDate, 112))
            WHERE V.VendorKey IS NULL
               OR P.ProductKey IS NULL
               OR E.EmployeeKey IS NULL
               OR SM.ShipMethodKey IS NULL
               OR OD.DateKey IS NULL
               OR DD.DateKey IS NULL
        )
        BEGIN
            ;THROW 51002, 'Purchase order detail dimension/date mapping check failed. Check Finance dimensions and DimDate.', 1;
        END

        BEGIN TRANSACTION;

        UPDATE T
        SET
            T.PurchaseOrderID = H.PurchaseOrderID,
            T.VendorKey = V.VendorKey,
            T.ProductKey = P.ProductKey,
            T.EmployeeKey = E.EmployeeKey,
            T.ShipMethodKey = SM.ShipMethodKey,
            T.OrderDateKey = CONVERT(INT, CONVERT(CHAR(8), H.OrderDate, 112)),
            T.DueDateKey = CONVERT(INT, CONVERT(CHAR(8), D.DueDate, 112)),
            T.Status = H.Status,
            T.OrderQty = D.OrderQty,
            T.ReceivedQty = D.ReceivedQty,
            T.RejectedQty = D.RejectedQty,
            T.StockedQty = D.StockedQty,
            T.UnitPrice = D.UnitPrice,
            T.LineTotal = D.LineTotal,
            T.OrderedAmount = D.OrderQty * D.UnitPrice
        FROM Fact.FactPurchaseOrders AS T
        INNER JOIN AdventureWorks2025.Purchasing.PurchaseOrderDetail AS D
            ON T.PurchaseOrderDetailID = D.PurchaseOrderDetailID
        INNER JOIN AdventureWorks2025.Purchasing.PurchaseOrderHeader AS H
            ON D.PurchaseOrderID = H.PurchaseOrderID
        LEFT JOIN Dim.DimVendor AS V
            ON H.VendorID = V.VendorID
        LEFT JOIN Dim.DimProduct AS P
            ON D.ProductID = P.ProductID
        LEFT JOIN Dim.DimEmployee AS E
            ON H.EmployeeID = E.EmployeeID
        LEFT JOIN Dim.DimShipMethod AS SM
            ON H.ShipMethodID = SM.ShipMethodID;

        INSERT INTO Fact.FactPurchaseOrders
        (
            PurchaseOrderID, PurchaseOrderDetailID,
            VendorKey, ProductKey, EmployeeKey, ShipMethodKey,
            OrderDateKey, DueDateKey, Status,
            OrderQty, ReceivedQty, RejectedQty, StockedQty,
            UnitPrice, LineTotal, OrderedAmount
        )
        SELECT
            H.PurchaseOrderID,
            D.PurchaseOrderDetailID,
            V.VendorKey,
            P.ProductKey,
            E.EmployeeKey,
            SM.ShipMethodKey,
            CONVERT(INT, CONVERT(CHAR(8), H.OrderDate, 112)),
            CONVERT(INT, CONVERT(CHAR(8), D.DueDate, 112)),
            H.Status,
            D.OrderQty,
            D.ReceivedQty,
            D.RejectedQty,
            D.StockedQty,
            D.UnitPrice,
            D.LineTotal,
            D.OrderQty * D.UnitPrice
        FROM AdventureWorks2025.Purchasing.PurchaseOrderDetail AS D
        INNER JOIN AdventureWorks2025.Purchasing.PurchaseOrderHeader AS H
            ON D.PurchaseOrderID = H.PurchaseOrderID
        LEFT JOIN Dim.DimVendor AS V
            ON H.VendorID = V.VendorID
        LEFT JOIN Dim.DimProduct AS P
            ON D.ProductID = P.ProductID
        LEFT JOIN Dim.DimEmployee AS E
            ON H.EmployeeID = E.EmployeeID
        LEFT JOIN Dim.DimShipMethod AS SM
            ON H.ShipMethodID = SM.ShipMethodID
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Fact.FactPurchaseOrders AS T
            WHERE T.PurchaseOrderDetailID = D.PurchaseOrderDetailID
        );

        COMMIT TRANSACTION;
        PRINT 'FactPurchaseOrders loaded/updated successfully.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


/*
  4. LOADING FACT CURRENCY RATE
     Grain: one row per CurrencyRateID.
     Two currency role-playing keys:
       FromCurrencyKey and ToCurrencyKey.
*/
CREATE OR ALTER PROCEDURE etl.usp_LoadFactCurrencyRate
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF EXISTS
        (
            SELECT 1
            FROM AdventureWorks2025.Sales.CurrencyRate AS CR
            LEFT JOIN Dim.DimCurrency AS FC
                ON CR.FromCurrencyCode = FC.CurrencyCode
            LEFT JOIN Dim.DimCurrency AS TC
                ON CR.ToCurrencyCode = TC.CurrencyCode
            LEFT JOIN Dim.DimDate AS DD
                ON DD.DateKey = CONVERT(
                    INT, CONVERT(CHAR(8), CR.CurrencyRateDate, 112)
                )
            WHERE FC.CurrencyKey IS NULL
               OR TC.CurrencyKey IS NULL
               OR DD.DateKey IS NULL
        )
        BEGIN
            ;THROW 51003, 'Currency rate dimension/date mapping check failed. Check DimCurrency and DimDate coverage.', 1;
        END

        BEGIN TRANSACTION;

        UPDATE T
        SET
            T.CurrencyRateDateKey =
                CONVERT(INT, CONVERT(CHAR(8), CR.CurrencyRateDate, 112)),
            T.FromCurrencyKey = FC.CurrencyKey,
            T.ToCurrencyKey = TC.CurrencyKey,
            T.AverageRate = CR.AverageRate,
            T.EndOfDayRate = CR.EndOfDayRate,
            T.CurrencyRateDate = CR.CurrencyRateDate
        FROM Fact.FactCurrencyRate AS T
        INNER JOIN AdventureWorks2025.Sales.CurrencyRate AS CR
            ON T.CurrencyRateID = CR.CurrencyRateID
        LEFT JOIN Dim.DimCurrency AS FC
            ON CR.FromCurrencyCode = FC.CurrencyCode
        LEFT JOIN Dim.DimCurrency AS TC
            ON CR.ToCurrencyCode = TC.CurrencyCode;

        INSERT INTO Fact.FactCurrencyRate
        (
            CurrencyRateID, CurrencyRateDateKey,
            FromCurrencyKey, ToCurrencyKey,
            AverageRate, EndOfDayRate, CurrencyRateDate
        )
        SELECT
            CR.CurrencyRateID,
            CONVERT(INT, CONVERT(CHAR(8), CR.CurrencyRateDate, 112)),
            FC.CurrencyKey,
            TC.CurrencyKey,
            CR.AverageRate,
            CR.EndOfDayRate,
            CR.CurrencyRateDate
        FROM AdventureWorks2025.Sales.CurrencyRate AS CR
        LEFT JOIN Dim.DimCurrency AS FC
            ON CR.FromCurrencyCode = FC.CurrencyCode
        LEFT JOIN Dim.DimCurrency AS TC
            ON CR.ToCurrencyCode = TC.CurrencyCode
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Fact.FactCurrencyRate AS T
            WHERE T.CurrencyRateID = CR.CurrencyRateID
        );

        COMMIT TRANSACTION;
        PRINT 'FactCurrencyRate loaded/updated successfully.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


/*
  5. MASTER FINANCE ETL PROCEDURE
     ADF will execute only this entry-point procedure.
*/
CREATE OR ALTER PROCEDURE etl.usp_RunFinanceETL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    PRINT 'Starting Finance ETL...';

    EXEC etl.usp_LoadFinanceDimensions;
    EXEC etl.usp_LoadFactPurchaseOrderHeader;
    EXEC etl.usp_LoadFactPurchaseOrders;
    EXEC etl.usp_LoadFactCurrencyRate;

    PRINT 'Finance ETL completed successfully.';
END;
GO


/*
  6. PROCEDURE INVENTORY CHECK
     Expected: five procedures.
*/
SELECT
    SCHEMA_NAME(S.schema_id) AS ProcedureSchema,
    S.name AS ProcedureName,
    S.create_date,
    S.modify_date
FROM sys.procedures AS S
WHERE S.schema_id = SCHEMA_ID(N'etl')
  AND S.name IN
  (
      N'usp_LoadFinanceDimensions',
      N'usp_LoadFactPurchaseOrderHeader',
      N'usp_LoadFactPurchaseOrders',
      N'usp_LoadFactCurrencyRate',
      N'usp_RunFinanceETL'
  )
ORDER BY S.name;
GO