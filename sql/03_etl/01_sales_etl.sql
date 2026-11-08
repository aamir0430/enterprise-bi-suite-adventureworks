/*=============================================================================
  File:        01_sales_etl.sql
  Project:     Enterprise Business Intelligence Suite - AdventureWorks
  Database:    EnterpriseBI_DW
  Purpose:     Repeatable Sales ETL procedures for the existing warehouse.

  IMPORTANT
  - This script creates/updates stored procedure definitions only.
  - It does NOT execute the ETL procedures or delete/truncate warehouse data.
  - Existing surrogate identity keys are preserved; new dimension members are
    inserted and existing dimension members are updated by their business key.
  - Fact rows are updated by their natural/business key and new rows are added.
=============================================================================*/

USE [EnterpriseBI_DW];
GO

/* Create a dedicated schema for ETL procedures */
IF SCHEMA_ID(N'etl') IS NULL
    EXEC(N'CREATE SCHEMA etl AUTHORIZATION dbo;');
GO

/*=============================================================================
  1. Load / update Sales-related dimensions.
  DimDate is intentionally excluded: it is a generated calendar dimension,
  not a direct source-table dimension. Its date coverage is validated below.
=============================================================================*/
CREATE OR ALTER PROCEDURE etl.usp_LoadSalesDimensions
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        /* DimCustomer */
        UPDATE D
        SET
            D.PersonID       = S.PersonID,
            D.StoreID        = S.StoreID,
            D.TerritoryID    = S.TerritoryID,
            D.AccountNumber  = S.AccountNumber,
            D.PersonType     = S.PersonType,
            D.Title          = S.Title,
            D.FirstName      = S.FirstName,
            D.MiddleName     = S.MiddleName,
            D.LastName       = S.LastName,
            D.Suffix         = S.Suffix,
            D.StoreName      = S.StoreName,
            D.CustomerName   = S.CustomerName
        FROM Dim.DimCustomer AS D
        INNER JOIN
        (
            SELECT
                C.CustomerID,
                C.PersonID,
                C.StoreID,
                C.TerritoryID,
                C.AccountNumber,
                P.PersonType,
                P.Title,
                P.FirstName,
                P.MiddleName,
                P.LastName,
                P.Suffix,
                S.Name AS StoreName,
                CASE
                    WHEN C.PersonID IS NOT NULL THEN
                        CONCAT(P.FirstName, N' ',
                               COALESCE(P.MiddleName + N' ', N''), P.LastName)
                    WHEN C.StoreID IS NOT NULL THEN S.Name
                    ELSE N'Unknown Customer'
                END AS CustomerName
            FROM AdventureWorks2025.Sales.Customer AS C
            LEFT JOIN AdventureWorks2025.Person.Person AS P
                ON C.PersonID = P.BusinessEntityID
            LEFT JOIN AdventureWorks2025.Sales.Store AS S
                ON C.StoreID = S.BusinessEntityID
        ) AS S
            ON D.CustomerID = S.CustomerID;

        INSERT INTO Dim.DimCustomer
        (
            CustomerID, PersonID, StoreID, TerritoryID, AccountNumber,
            PersonType, Title, FirstName, MiddleName, LastName, Suffix,
            StoreName, CustomerName
        )
        SELECT
            S.CustomerID, S.PersonID, S.StoreID, S.TerritoryID, S.AccountNumber,
            S.PersonType, S.Title, S.FirstName, S.MiddleName, S.LastName,
            S.Suffix, S.StoreName, S.CustomerName
        FROM
        (
            SELECT
                C.CustomerID,
                C.PersonID,
                C.StoreID,
                C.TerritoryID,
                C.AccountNumber,
                P.PersonType,
                P.Title,
                P.FirstName,
                P.MiddleName,
                P.LastName,
                P.Suffix,
                S.Name AS StoreName,
                CASE
                    WHEN C.PersonID IS NOT NULL THEN
                        CONCAT(P.FirstName, N' ',
                               COALESCE(P.MiddleName + N' ', N''), P.LastName)
                    WHEN C.StoreID IS NOT NULL THEN S.Name
                    ELSE N'Unknown Customer'
                END AS CustomerName
            FROM AdventureWorks2025.Sales.Customer AS C
            LEFT JOIN AdventureWorks2025.Person.Person AS P
                ON C.PersonID = P.BusinessEntityID
            LEFT JOIN AdventureWorks2025.Sales.Store AS S
                ON C.StoreID = S.BusinessEntityID
        ) AS S
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Dim.DimCustomer AS D
            WHERE D.CustomerID = S.CustomerID
        );

        /* DimProduct */
        UPDATE D
        SET
            D.ProductName          = S.ProductName,
            D.ProductNumber        = S.ProductNumber,
            D.Color                = S.Color,
            D.Size                 = S.Size,
            D.Weight               = S.Weight,
            D.StandardCost         = S.StandardCost,
            D.ListPrice            = S.ListPrice,
            D.ProductLine          = S.ProductLine,
            D.Class                = S.Class,
            D.Style                = S.Style,
            D.MakeFlag             = S.MakeFlag,
            D.FinishedGoodsFlag    = S.FinishedGoodsFlag,
            D.SafetyStockLevel     = S.SafetyStockLevel,
            D.ReorderPoint         = S.ReorderPoint,
            D.ProductSubcategoryID = S.ProductSubcategoryID,
            D.SubcategoryName      = S.SubcategoryName,
            D.ProductCategoryID    = S.ProductCategoryID,
            D.CategoryName         = S.CategoryName,
            D.ProductModelID       = S.ProductModelID,
            D.ProductModelName     = S.ProductModelName,
            D.SellStartDate        = S.SellStartDate,
            D.SellEndDate          = S.SellEndDate,
            D.DiscontinuedDate     = S.DiscontinuedDate
        FROM Dim.DimProduct AS D
        INNER JOIN
        (
            SELECT
                P.ProductID, P.Name AS ProductName, P.ProductNumber,
                P.Color, P.Size, P.Weight, P.StandardCost, P.ListPrice,
                P.ProductLine, P.Class, P.Style, P.MakeFlag,
                P.FinishedGoodsFlag, P.SafetyStockLevel, P.ReorderPoint,
                P.ProductSubcategoryID, PSC.Name AS SubcategoryName,
                PC.ProductCategoryID, PC.Name AS CategoryName,
                P.ProductModelID, PM.Name AS ProductModelName,
                P.SellStartDate, P.SellEndDate, P.DiscontinuedDate
            FROM AdventureWorks2025.Production.Product AS P
            LEFT JOIN AdventureWorks2025.Production.ProductSubcategory AS PSC
                ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
            LEFT JOIN AdventureWorks2025.Production.ProductCategory AS PC
                ON PSC.ProductCategoryID = PC.ProductCategoryID
            LEFT JOIN AdventureWorks2025.Production.ProductModel AS PM
                ON P.ProductModelID = PM.ProductModelID
        ) AS S
            ON D.ProductID = S.ProductID;

        INSERT INTO Dim.DimProduct
        (
            ProductID, ProductName, ProductNumber, Color, Size, Weight,
            StandardCost, ListPrice, ProductLine, Class, Style, MakeFlag,
            FinishedGoodsFlag, SafetyStockLevel, ReorderPoint,
            ProductSubcategoryID, SubcategoryName, ProductCategoryID,
            CategoryName, ProductModelID, ProductModelName,
            SellStartDate, SellEndDate, DiscontinuedDate
        )
        SELECT
            S.ProductID, S.ProductName, S.ProductNumber, S.Color, S.Size,
            S.Weight, S.StandardCost, S.ListPrice, S.ProductLine, S.Class,
            S.Style, S.MakeFlag, S.FinishedGoodsFlag, S.SafetyStockLevel,
            S.ReorderPoint, S.ProductSubcategoryID, S.SubcategoryName,
            S.ProductCategoryID, S.CategoryName, S.ProductModelID,
            S.ProductModelName, S.SellStartDate, S.SellEndDate,
            S.DiscontinuedDate
        FROM
        (
            SELECT
                P.ProductID, P.Name AS ProductName, P.ProductNumber,
                P.Color, P.Size, P.Weight, P.StandardCost, P.ListPrice,
                P.ProductLine, P.Class, P.Style, P.MakeFlag,
                P.FinishedGoodsFlag, P.SafetyStockLevel, P.ReorderPoint,
                P.ProductSubcategoryID, PSC.Name AS SubcategoryName,
                PC.ProductCategoryID, PC.Name AS CategoryName,
                P.ProductModelID, PM.Name AS ProductModelName,
                P.SellStartDate, P.SellEndDate, P.DiscontinuedDate
            FROM AdventureWorks2025.Production.Product AS P
            LEFT JOIN AdventureWorks2025.Production.ProductSubcategory AS PSC
                ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
            LEFT JOIN AdventureWorks2025.Production.ProductCategory AS PC
                ON PSC.ProductCategoryID = PC.ProductCategoryID
            LEFT JOIN AdventureWorks2025.Production.ProductModel AS PM
                ON P.ProductModelID = PM.ProductModelID
        ) AS S
        WHERE NOT EXISTS
        (
            SELECT 1 FROM Dim.DimProduct AS D
            WHERE D.ProductID = S.ProductID
        );

        /* DimSalesTerritory */
        UPDATE D
        SET D.TerritoryName = S.Name,
            D.CountryRegionCode = S.CountryRegionCode,
            D.TerritoryGroup = S.[Group],
            D.SalesYTD = S.SalesYTD,
            D.SalesLastYear = S.SalesLastYear,
            D.CostYTD = S.CostYTD,
            D.CostLastYear = S.CostLastYear
        FROM Dim.DimSalesTerritory AS D
        INNER JOIN AdventureWorks2025.Sales.SalesTerritory AS S
            ON D.TerritoryID = S.TerritoryID;

        INSERT INTO Dim.DimSalesTerritory
        (TerritoryID, TerritoryName, CountryRegionCode, TerritoryGroup,
         SalesYTD, SalesLastYear, CostYTD, CostLastYear)
        SELECT S.TerritoryID, S.Name, S.CountryRegionCode, S.[Group],
               S.SalesYTD, S.SalesLastYear, S.CostYTD, S.CostLastYear
        FROM AdventureWorks2025.Sales.SalesTerritory AS S
        WHERE NOT EXISTS
        (
            SELECT 1 FROM Dim.DimSalesTerritory AS D
            WHERE D.TerritoryID = S.TerritoryID
        );

        /* DimSalesPerson */
        UPDATE D
        SET D.FirstName = P.FirstName,
            D.MiddleName = P.MiddleName,
            D.LastName = P.LastName,
            D.SalesPersonName = CONCAT(P.FirstName, N' ',
                                      COALESCE(P.MiddleName + N' ', N''), P.LastName),
            D.JobTitle = E.JobTitle,
            D.TerritoryID = SP.TerritoryID,
            D.SalesQuota = SP.SalesQuota,
            D.Bonus = SP.Bonus,
            D.CommissionPct = SP.CommissionPct,
            D.SalesYTD = SP.SalesYTD,
            D.SalesLastYear = SP.SalesLastYear
        FROM Dim.DimSalesPerson AS D
        INNER JOIN AdventureWorks2025.Sales.SalesPerson AS SP
            ON D.SalesPersonID = SP.BusinessEntityID
        INNER JOIN AdventureWorks2025.HumanResources.Employee AS E
            ON SP.BusinessEntityID = E.BusinessEntityID
        INNER JOIN AdventureWorks2025.Person.Person AS P
            ON E.BusinessEntityID = P.BusinessEntityID;

        INSERT INTO Dim.DimSalesPerson
        (SalesPersonID, FirstName, MiddleName, LastName, SalesPersonName,
         JobTitle, TerritoryID, SalesQuota, Bonus, CommissionPct,
         SalesYTD, SalesLastYear)
        SELECT SP.BusinessEntityID, P.FirstName, P.MiddleName, P.LastName,
               CONCAT(P.FirstName, N' ',
                      COALESCE(P.MiddleName + N' ', N''), P.LastName),
               E.JobTitle, SP.TerritoryID, SP.SalesQuota, SP.Bonus,
               SP.CommissionPct, SP.SalesYTD, SP.SalesLastYear
        FROM AdventureWorks2025.Sales.SalesPerson AS SP
        INNER JOIN AdventureWorks2025.HumanResources.Employee AS E
            ON SP.BusinessEntityID = E.BusinessEntityID
        INNER JOIN AdventureWorks2025.Person.Person AS P
            ON E.BusinessEntityID = P.BusinessEntityID
        WHERE NOT EXISTS
        (
            SELECT 1 FROM Dim.DimSalesPerson AS D
            WHERE D.SalesPersonID = SP.BusinessEntityID
        );

        /* DimPromotion */
        UPDATE D
        SET D.PromotionDescription = S.Description,
            D.DiscountPct = S.DiscountPct,
            D.PromotionType = S.Type,
            D.PromotionCategory = S.Category,
            D.StartDate = S.StartDate,
            D.EndDate = S.EndDate,
            D.MinQty = S.MinQty,
            D.MaxQty = S.MaxQty
        FROM Dim.DimPromotion AS D
        INNER JOIN AdventureWorks2025.Sales.SpecialOffer AS S
            ON D.SpecialOfferID = S.SpecialOfferID;

        INSERT INTO Dim.DimPromotion
        (SpecialOfferID, PromotionDescription, DiscountPct, PromotionType,
         PromotionCategory, StartDate, EndDate, MinQty, MaxQty)
        SELECT S.SpecialOfferID, S.Description, S.DiscountPct, S.Type,
               S.Category, S.StartDate, S.EndDate, S.MinQty, S.MaxQty
        FROM AdventureWorks2025.Sales.SpecialOffer AS S
        WHERE NOT EXISTS
        (
            SELECT 1 FROM Dim.DimPromotion AS D
            WHERE D.SpecialOfferID = S.SpecialOfferID
        );

        /* DimCurrency */
        UPDATE D
        SET D.CurrencyName = S.Name
        FROM Dim.DimCurrency AS D
        INNER JOIN AdventureWorks2025.Sales.Currency AS S
            ON D.CurrencyCode = S.CurrencyCode;

        INSERT INTO Dim.DimCurrency (CurrencyCode, CurrencyName)
        SELECT S.CurrencyCode, S.Name
        FROM AdventureWorks2025.Sales.Currency AS S
        WHERE NOT EXISTS
        (
            SELECT 1 FROM Dim.DimCurrency AS D
            WHERE D.CurrencyCode = S.CurrencyCode
        );

        /* DimShipMethod */
        UPDATE D
        SET D.ShipMethodName = S.Name,
            D.ShipBase = S.ShipBase,
            D.ShipRate = S.ShipRate
        FROM Dim.DimShipMethod AS D
        INNER JOIN AdventureWorks2025.Purchasing.ShipMethod AS S
            ON D.ShipMethodID = S.ShipMethodID;

        INSERT INTO Dim.DimShipMethod
        (ShipMethodID, ShipMethodName, ShipBase, ShipRate)
        SELECT S.ShipMethodID, S.Name, S.ShipBase, S.ShipRate
        FROM AdventureWorks2025.Purchasing.ShipMethod AS S
        WHERE NOT EXISTS
        (
            SELECT 1 FROM Dim.DimShipMethod AS D
            WHERE D.ShipMethodID = S.ShipMethodID
        );

        /* DimAddress */
        UPDATE D
        SET D.AddressLine1 = S.AddressLine1,
            D.AddressLine2 = S.AddressLine2,
            D.City = S.City,
            D.PostalCode = S.PostalCode,
            D.StateProvinceID = S.StateProvinceID,
            D.StateProvinceName = S.StateProvinceName,
            D.StateProvinceCode = S.StateProvinceCode,
            D.CountryRegionCode = S.CountryRegionCode,
            D.CountryName = S.CountryName,
            D.TerritoryID = S.TerritoryID
        FROM Dim.DimAddress AS D
        INNER JOIN
        (
            SELECT A.AddressID, A.AddressLine1, A.AddressLine2, A.City,
                   A.PostalCode, SP.StateProvinceID,
                   SP.Name AS StateProvinceName,
                   SP.StateProvinceCode, CR.CountryRegionCode,
                   CR.Name AS CountryName, SP.TerritoryID
            FROM AdventureWorks2025.Person.Address AS A
            LEFT JOIN AdventureWorks2025.Person.StateProvince AS SP
                ON A.StateProvinceID = SP.StateProvinceID
            LEFT JOIN AdventureWorks2025.Person.CountryRegion AS CR
                ON SP.CountryRegionCode = CR.CountryRegionCode
        ) AS S
            ON D.AddressID = S.AddressID;

        INSERT INTO Dim.DimAddress
        (AddressID, AddressLine1, AddressLine2, City, PostalCode,
         StateProvinceID, StateProvinceName, StateProvinceCode,
         CountryRegionCode, CountryName, TerritoryID)
        SELECT S.AddressID, S.AddressLine1, S.AddressLine2, S.City,
               S.PostalCode, S.StateProvinceID, S.StateProvinceName,
               S.StateProvinceCode, S.CountryRegionCode, S.CountryName,
               S.TerritoryID
        FROM
        (
            SELECT A.AddressID, A.AddressLine1, A.AddressLine2, A.City,
                   A.PostalCode, SP.StateProvinceID,
                   SP.Name AS StateProvinceName,
                   SP.StateProvinceCode, CR.CountryRegionCode,
                   CR.Name AS CountryName, SP.TerritoryID
            FROM AdventureWorks2025.Person.Address AS A
            LEFT JOIN AdventureWorks2025.Person.StateProvince AS SP
                ON A.StateProvinceID = SP.StateProvinceID
            LEFT JOIN AdventureWorks2025.Person.CountryRegion AS CR
                ON SP.CountryRegionCode = CR.CountryRegionCode
        ) AS S
        WHERE NOT EXISTS
        (
            SELECT 1 FROM Dim.DimAddress AS D
            WHERE D.AddressID = S.AddressID
        );

        /* DimCreditCardType - added to the order-header fact after initial build. */
        UPDATE D
        SET D.CreditCardType = S.CardType
        FROM Dim.DimCreditCardType AS D
        INNER JOIN
        (
            SELECT DISTINCT CardType
            FROM AdventureWorks2025.Sales.CreditCard
            WHERE CardType IS NOT NULL
        ) AS S
            ON D.CreditCardType = S.CardType;

        INSERT INTO Dim.DimCreditCardType (CreditCardType)
        SELECT DISTINCT S.CardType
        FROM AdventureWorks2025.Sales.CreditCard AS S
        WHERE S.CardType IS NOT NULL
          AND NOT EXISTS
          (
              SELECT 1 FROM Dim.DimCreditCardType AS D
              WHERE D.CreditCardType = S.CardType
          );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

/*=============================================================================
  2. Load / update Sales order header fact.
  Business key: SalesOrderID. Identity SalesOrderHeaderKey is not overwritten.
=============================================================================*/
CREATE OR ALTER PROCEDURE etl.usp_LoadFactSalesOrderHeader
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        /* Fail fast if required order dates are not present in DimDate. */
        IF EXISTS
        (
            SELECT 1
            FROM AdventureWorks2025.Sales.SalesOrderHeader AS H
            LEFT JOIN Dim.DimDate AS DD
                ON DD.DateKey = CONVERT(INT, CONVERT(CHAR(8), H.OrderDate, 112))
            WHERE DD.DateKey IS NULL
        )
            THROW 51001, 'Sales ETL stopped: one or more OrderDate values are missing from DimDate.', 1;

        IF EXISTS
        (
            SELECT 1
            FROM AdventureWorks2025.Sales.SalesOrderHeader AS H
            LEFT JOIN Dim.DimDate AS DD
                ON DD.DateKey = CONVERT(INT, CONVERT(CHAR(8), H.DueDate, 112))
            WHERE DD.DateKey IS NULL
        )
            THROW 51002, 'Sales ETL stopped: one or more DueDate values are missing from DimDate.', 1;

        IF EXISTS
        (
            SELECT 1
            FROM AdventureWorks2025.Sales.SalesOrderHeader AS H
            LEFT JOIN Dim.DimDate AS DD
                ON DD.DateKey = CONVERT(INT, CONVERT(CHAR(8), H.ShipDate, 112))
            WHERE H.ShipDate IS NOT NULL AND DD.DateKey IS NULL
        )
            THROW 51003, 'Sales ETL stopped: one or more ShipDate values are missing from DimDate.', 1;

        /* Update existing order rows. */
        UPDATE F
        SET
            F.SalesOrderNumber = H.SalesOrderNumber,
            F.PurchaseOrderNumber = H.PurchaseOrderNumber,
            F.AccountNumber = H.AccountNumber,
            F.CustomerKey = DC.CustomerKey,
            F.SalesTerritoryKey = DST.SalesTerritoryKey,
            F.SalesPersonKey = DSP.SalesPersonKey,
            F.ShipMethodKey = DSM.ShipMethodKey,
            F.BillToAddressKey = DBA.AddressKey,
            F.ShipToAddressKey = DSA.AddressKey,
            F.OrderDateKey = CONVERT(INT, CONVERT(CHAR(8), H.OrderDate, 112)),
            F.DueDateKey = CONVERT(INT, CONVERT(CHAR(8), H.DueDate, 112)),
            F.ShipDateKey = CASE WHEN H.ShipDate IS NULL THEN NULL
                                 ELSE CONVERT(INT, CONVERT(CHAR(8), H.ShipDate, 112)) END,
            F.RevisionNumber = H.RevisionNumber,
            F.Status = H.Status,
            F.OnlineOrderFlag = H.OnlineOrderFlag,
            F.CurrencyRateID = H.CurrencyRateID,
            F.FromCurrencyCode = CR.FromCurrencyCode,
            F.ToCurrencyCode = CR.ToCurrencyCode,
            F.AverageRate = CR.AverageRate,
            F.EndOfDayRate = CR.EndOfDayRate,
            F.SubTotal = H.SubTotal,
            F.TaxAmt = H.TaxAmt,
            F.Freight = H.Freight,
            F.TotalDue = H.TotalDue,
            F.Comment = H.Comment,
            F.ModifiedDate = H.ModifiedDate,
            F.CreditCardTypeKey = DCC.CreditCardTypeKey
        FROM Fact.FactSalesOrderHeader AS F
        INNER JOIN AdventureWorks2025.Sales.SalesOrderHeader AS H
            ON F.SalesOrderID = H.SalesOrderID
        LEFT JOIN Dim.DimCustomer AS DC
            ON H.CustomerID = DC.CustomerID
        LEFT JOIN Dim.DimSalesTerritory AS DST
            ON H.TerritoryID = DST.TerritoryID
        LEFT JOIN Dim.DimSalesPerson AS DSP
            ON H.SalesPersonID = DSP.SalesPersonID
        LEFT JOIN Dim.DimShipMethod AS DSM
            ON H.ShipMethodID = DSM.ShipMethodID
        LEFT JOIN Dim.DimAddress AS DBA
            ON H.BillToAddressID = DBA.AddressID
        LEFT JOIN Dim.DimAddress AS DSA
            ON H.ShipToAddressID = DSA.AddressID
        LEFT JOIN AdventureWorks2025.Sales.CurrencyRate AS CR
            ON H.CurrencyRateID = CR.CurrencyRateID
        LEFT JOIN AdventureWorks2025.Sales.CreditCard AS CC
            ON H.CreditCardID = CC.CreditCardID
        LEFT JOIN Dim.DimCreditCardType AS DCC
            ON CC.CardType = DCC.CreditCardType;

        /* Insert new order rows. */
        INSERT INTO Fact.FactSalesOrderHeader
        (
            SalesOrderID, SalesOrderNumber, PurchaseOrderNumber, AccountNumber,
            CustomerKey, SalesTerritoryKey, SalesPersonKey, ShipMethodKey,
            BillToAddressKey, ShipToAddressKey, OrderDateKey, DueDateKey,
            ShipDateKey, RevisionNumber, Status, OnlineOrderFlag,
            CurrencyRateID, FromCurrencyCode, ToCurrencyCode, AverageRate,
            EndOfDayRate, SubTotal, TaxAmt, Freight, TotalDue, Comment,
            ModifiedDate, CreditCardTypeKey
        )
        SELECT
            H.SalesOrderID, H.SalesOrderNumber, H.PurchaseOrderNumber,
            H.AccountNumber, DC.CustomerKey, DST.SalesTerritoryKey,
            DSP.SalesPersonKey, DSM.ShipMethodKey, DBA.AddressKey,
            DSA.AddressKey,
            CONVERT(INT, CONVERT(CHAR(8), H.OrderDate, 112)),
            CONVERT(INT, CONVERT(CHAR(8), H.DueDate, 112)),
            CASE WHEN H.ShipDate IS NULL THEN NULL
                 ELSE CONVERT(INT, CONVERT(CHAR(8), H.ShipDate, 112)) END,
            H.RevisionNumber, H.Status, H.OnlineOrderFlag, H.CurrencyRateID,
            CR.FromCurrencyCode, CR.ToCurrencyCode, CR.AverageRate,
            CR.EndOfDayRate, H.SubTotal, H.TaxAmt, H.Freight, H.TotalDue,
            H.Comment, H.ModifiedDate, DCC.CreditCardTypeKey
        FROM AdventureWorks2025.Sales.SalesOrderHeader AS H
        LEFT JOIN Dim.DimCustomer AS DC
            ON H.CustomerID = DC.CustomerID
        LEFT JOIN Dim.DimSalesTerritory AS DST
            ON H.TerritoryID = DST.TerritoryID
        LEFT JOIN Dim.DimSalesPerson AS DSP
            ON H.SalesPersonID = DSP.SalesPersonID
        LEFT JOIN Dim.DimShipMethod AS DSM
            ON H.ShipMethodID = DSM.ShipMethodID
        LEFT JOIN Dim.DimAddress AS DBA
            ON H.BillToAddressID = DBA.AddressID
        LEFT JOIN Dim.DimAddress AS DSA
            ON H.ShipToAddressID = DSA.AddressID
        LEFT JOIN AdventureWorks2025.Sales.CurrencyRate AS CR
            ON H.CurrencyRateID = CR.CurrencyRateID
        LEFT JOIN AdventureWorks2025.Sales.CreditCard AS CC
            ON H.CreditCardID = CC.CreditCardID
        LEFT JOIN Dim.DimCreditCardType AS DCC
            ON CC.CardType = DCC.CreditCardType
        WHERE NOT EXISTS
        (
            SELECT 1 FROM Fact.FactSalesOrderHeader AS F
            WHERE F.SalesOrderID = H.SalesOrderID
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

/*=============================================================================
  3. Load / update Sales line fact.
  Business key: (SalesOrderID, SalesOrderDetailID).
  Identity SalesFactKey is not overwritten.
=============================================================================*/
CREATE OR ALTER PROCEDURE etl.usp_LoadFactSales
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        /* Validate required date keys before changing the fact table. */
        IF EXISTS
        (
            SELECT 1
            FROM AdventureWorks2025.Sales.SalesOrderHeader AS H
            INNER JOIN AdventureWorks2025.Sales.SalesOrderDetail AS D
                ON H.SalesOrderID = D.SalesOrderID
            LEFT JOIN Dim.DimDate AS DD
                ON DD.DateKey = CONVERT(INT, CONVERT(CHAR(8), H.OrderDate, 112))
            WHERE DD.DateKey IS NULL
        )
            THROW 51011, 'Sales ETL stopped: one or more line-level OrderDate values are missing from DimDate.', 1;

        IF EXISTS
        (
            SELECT 1
            FROM AdventureWorks2025.Sales.SalesOrderHeader AS H
            INNER JOIN AdventureWorks2025.Sales.SalesOrderDetail AS D
                ON H.SalesOrderID = D.SalesOrderID
            LEFT JOIN Dim.DimDate AS DD
                ON DD.DateKey = CONVERT(INT, CONVERT(CHAR(8), H.DueDate, 112))
            WHERE DD.DateKey IS NULL
        )
            THROW 51012, 'Sales ETL stopped: one or more line-level DueDate values are missing from DimDate.', 1;

        IF EXISTS
        (
            SELECT 1
            FROM AdventureWorks2025.Sales.SalesOrderHeader AS H
            INNER JOIN AdventureWorks2025.Sales.SalesOrderDetail AS D
                ON H.SalesOrderID = D.SalesOrderID
            LEFT JOIN Dim.DimDate AS DD
                ON DD.DateKey = CONVERT(INT, CONVERT(CHAR(8), H.ShipDate, 112))
            WHERE H.ShipDate IS NOT NULL AND DD.DateKey IS NULL
        )
            THROW 51013, 'Sales ETL stopped: one or more line-level ShipDate values are missing from DimDate.', 1;

        /* Update existing sales lines. */
        UPDATE F
        SET
            F.SalesOrderNumber = H.SalesOrderNumber,
            F.OnlineOrderFlag = H.OnlineOrderFlag,
            F.CustomerKey = DC.CustomerKey,
            F.ProductKey = DP.ProductKey,
            F.SalesTerritoryKey = DST.SalesTerritoryKey,
            F.SalesPersonKey = DSP.SalesPersonKey,
            F.PromotionKey = DPR.PromotionKey,
            F.CurrencyKey = DCUR.CurrencyKey,
            F.ShipMethodKey = DSM.ShipMethodKey,
            F.BillToAddressKey = DBA.AddressKey,
            F.ShipToAddressKey = DSA.AddressKey,
            F.OrderDateKey = CONVERT(INT, CONVERT(CHAR(8), H.OrderDate, 112)),
            F.DueDateKey = CONVERT(INT, CONVERT(CHAR(8), H.DueDate, 112)),
            F.ShipDateKey = CASE WHEN H.ShipDate IS NULL THEN NULL
                                 ELSE CONVERT(INT, CONVERT(CHAR(8), H.ShipDate, 112)) END,
            F.CurrencyRateID = H.CurrencyRateID,
            F.OrderQty = D.OrderQty,
            F.UnitPrice = D.UnitPrice,
            F.UnitPriceDiscount = D.UnitPriceDiscount,
            F.LineTotal = D.LineTotal
        FROM Fact.FactSales AS F
        INNER JOIN AdventureWorks2025.Sales.SalesOrderHeader AS H
            ON F.SalesOrderID = H.SalesOrderID
        INNER JOIN AdventureWorks2025.Sales.SalesOrderDetail AS D
            ON F.SalesOrderID = D.SalesOrderID
           AND F.SalesOrderDetailID = D.SalesOrderDetailID
        LEFT JOIN Dim.DimCustomer AS DC
            ON H.CustomerID = DC.CustomerID
        LEFT JOIN Dim.DimProduct AS DP
            ON D.ProductID = DP.ProductID
        LEFT JOIN Dim.DimSalesTerritory AS DST
            ON H.TerritoryID = DST.TerritoryID
        LEFT JOIN Dim.DimSalesPerson AS DSP
            ON H.SalesPersonID = DSP.SalesPersonID
        LEFT JOIN Dim.DimPromotion AS DPR
            ON D.SpecialOfferID = DPR.SpecialOfferID
        LEFT JOIN AdventureWorks2025.Sales.CurrencyRate AS CR
            ON H.CurrencyRateID = CR.CurrencyRateID
        LEFT JOIN Dim.DimCurrency AS DCUR
            ON CR.ToCurrencyCode = DCUR.CurrencyCode
        LEFT JOIN Dim.DimShipMethod AS DSM
            ON H.ShipMethodID = DSM.ShipMethodID
        LEFT JOIN Dim.DimAddress AS DBA
            ON H.BillToAddressID = DBA.AddressID
        LEFT JOIN Dim.DimAddress AS DSA
            ON H.ShipToAddressID = DSA.AddressID;

        /* Insert new sales lines. */
        INSERT INTO Fact.FactSales
        (
            SalesOrderID, SalesOrderDetailID, SalesOrderNumber,
            OnlineOrderFlag, CustomerKey, ProductKey, SalesTerritoryKey,
            SalesPersonKey, PromotionKey, CurrencyKey, ShipMethodKey,
            BillToAddressKey, ShipToAddressKey, OrderDateKey, DueDateKey,
            ShipDateKey, CurrencyRateID, OrderQty, UnitPrice,
            UnitPriceDiscount, LineTotal
        )
        SELECT
            H.SalesOrderID, D.SalesOrderDetailID, H.SalesOrderNumber,
            H.OnlineOrderFlag, DC.CustomerKey, DP.ProductKey,
            DST.SalesTerritoryKey, DSP.SalesPersonKey, DPR.PromotionKey,
            DCUR.CurrencyKey, DSM.ShipMethodKey, DBA.AddressKey,
            DSA.AddressKey,
            CONVERT(INT, CONVERT(CHAR(8), H.OrderDate, 112)),
            CONVERT(INT, CONVERT(CHAR(8), H.DueDate, 112)),
            CASE WHEN H.ShipDate IS NULL THEN NULL
                 ELSE CONVERT(INT, CONVERT(CHAR(8), H.ShipDate, 112)) END,
            H.CurrencyRateID, D.OrderQty, D.UnitPrice,
            D.UnitPriceDiscount, D.LineTotal
        FROM AdventureWorks2025.Sales.SalesOrderHeader AS H
        INNER JOIN AdventureWorks2025.Sales.SalesOrderDetail AS D
            ON H.SalesOrderID = D.SalesOrderID
        LEFT JOIN Dim.DimCustomer AS DC
            ON H.CustomerID = DC.CustomerID
        LEFT JOIN Dim.DimProduct AS DP
            ON D.ProductID = DP.ProductID
        LEFT JOIN Dim.DimSalesTerritory AS DST
            ON H.TerritoryID = DST.TerritoryID
        LEFT JOIN Dim.DimSalesPerson AS DSP
            ON H.SalesPersonID = DSP.SalesPersonID
        LEFT JOIN Dim.DimPromotion AS DPR
            ON D.SpecialOfferID = DPR.SpecialOfferID
        LEFT JOIN AdventureWorks2025.Sales.CurrencyRate AS CR
            ON H.CurrencyRateID = CR.CurrencyRateID
        LEFT JOIN Dim.DimCurrency AS DCUR
            ON CR.ToCurrencyCode = DCUR.CurrencyCode
        LEFT JOIN Dim.DimShipMethod AS DSM
            ON H.ShipMethodID = DSM.ShipMethodID
        LEFT JOIN Dim.DimAddress AS DBA
            ON H.BillToAddressID = DBA.AddressID
        LEFT JOIN Dim.DimAddress AS DSA
            ON H.ShipToAddressID = DSA.AddressID
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Fact.FactSales AS F
            WHERE F.SalesOrderID = H.SalesOrderID
              AND F.SalesOrderDetailID = D.SalesOrderDetailID
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

/*=============================================================================
  4. One entry-point procedure for ADF's Sales pipeline.
  Execution order: dimensions -> order-header fact -> sales-line fact.
=============================================================================*/
CREATE OR ALTER PROCEDURE etl.usp_RunSalesETL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    EXEC etl.usp_LoadSalesDimensions;
    EXEC etl.usp_LoadFactSalesOrderHeader;
    EXEC etl.usp_LoadFactSales;

    /* Return a compact post-load count summary for logging/verification. */
    SELECT 'DimCustomer' AS TableName, COUNT_BIG(*) AS TotalRows FROM Dim.DimCustomer
    UNION ALL SELECT 'DimProduct', COUNT_BIG(*) FROM Dim.DimProduct
    UNION ALL SELECT 'DimSalesTerritory', COUNT_BIG(*) FROM Dim.DimSalesTerritory
    UNION ALL SELECT 'DimSalesPerson', COUNT_BIG(*) FROM Dim.DimSalesPerson
    UNION ALL SELECT 'DimPromotion', COUNT_BIG(*) FROM Dim.DimPromotion
    UNION ALL SELECT 'DimCurrency', COUNT_BIG(*) FROM Dim.DimCurrency
    UNION ALL SELECT 'DimShipMethod', COUNT_BIG(*) FROM Dim.DimShipMethod
    UNION ALL SELECT 'DimAddress', COUNT_BIG(*) FROM Dim.DimAddress
    UNION ALL SELECT 'DimCreditCardType', COUNT_BIG(*) FROM Dim.DimCreditCardType
    UNION ALL SELECT 'FactSalesOrderHeader', COUNT_BIG(*) FROM Fact.FactSalesOrderHeader
    UNION ALL SELECT 'FactSales', COUNT_BIG(*) FROM Fact.FactSales;
END;
GO

/*=============================================================================
  5. Read-only post-deployment checks.
=============================================================================*/
SELECT
    OBJECT_SCHEMA_NAME(object_id) AS ProcedureSchema,
    name AS ProcedureName,
    create_date,
    modify_date
FROM sys.procedures
WHERE schema_id = SCHEMA_ID(N'etl')
ORDER BY name;
GO

/* End of script. No ETL procedure is executed by this file. */
