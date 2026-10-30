USE EnterpriseBI_DW
GO

--Checking missing Dimension mappings for FactSales

SELECT
    SUM(CASE WHEN CustomerKey IS NULL THEN 1 ELSE 0 END)
        AS MissingCustomer,

    SUM(CASE WHEN ProductKey IS NULL THEN 1 ELSE 0 END)
        AS MissingProduct,

    SUM(CASE WHEN SalesTerritoryKey IS NULL THEN 1 ELSE 0 END)
        AS MissingTerritory,

    SUM(CASE WHEN SalesPersonKey IS NULL THEN 1 ELSE 0 END)
        AS MissingSalesPerson,

    SUM(CASE WHEN PromotionKey IS NULL THEN 1 ELSE 0 END)
        AS MissingPromotion

FROM Fact.FactSales;

--Checking missing Dimension mappings for FactSalesOrderHeader
SELECT
    SUM(CASE WHEN CustomerKey IS NULL THEN 1 ELSE 0 END)
        AS MissingCustomer,

    SUM(CASE WHEN SalesTerritoryKey IS NULL THEN 1 ELSE 0 END)
        AS MissingTerritory,

    SUM(CASE WHEN SalesPersonKey IS NULL THEN 1 ELSE 0 END)
        AS MissingSalesPerson,

    SUM(CASE WHEN ShipMethodKey IS NULL THEN 1 ELSE 0 END)
        AS MissingShipMethod,

    SUM(CASE WHEN BillToAddressKey IS NULL THEN 1 ELSE 0 END)
        AS MissingBillingAddress,

    SUM(CASE WHEN ShipToAddressKey IS NULL THEN 1 ELSE 0 END)
        AS MissingShippingAddress

FROM Fact.FactSalesOrderHeader;