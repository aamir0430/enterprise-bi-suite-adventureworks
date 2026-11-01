USE EnterpriseBI_DW;
GO


--Validating the customer type
SELECT
    PersonType,
    COUNT(*) AS CustomerCount,
    SUM(CASE WHEN PersonID IS NOT NULL THEN 1 ELSE 0 END)
        AS CustomersWithPersonID,
    SUM(CASE WHEN StoreID IS NOT NULL THEN 1 ELSE 0 END)
        AS CustomersWithStoreID,
    SUM(CASE WHEN PersonID IS NULL AND StoreID IS NULL THEN 1 ELSE 0 END)
        AS CustomersWithNeither
FROM Dim.DimCustomer
GROUP BY PersonType
ORDER BY PersonType;

--Checking for customers who have these both IDs
SELECT *
FROM Dim.DimCustomer
WHERE PersonID IS NOT NULL
  AND StoreID IS NOT NULL;

--Checking for customers who have neither of the IDs
SELECT *
FROM Dim.DimCustomer
WHERE PersonID IS NULL
  AND StoreID IS NULL;

--Validating the customer keys and duplicates:
--Checking the primary key

SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT CustomerKey) AS DistinctCustomerKeys,
    SUM(CASE WHEN CustomerKey IS NULL THEN 1 ELSE 0 END)
        AS NullCustomerKeys
FROM Dim.DimCustomer;


--Checking duplicate CustomerID values
SELECT
    CustomerID,
    COUNT(*) AS DuplicateCount
FROM Dim.DimCustomer
GROUP BY CustomerID
HAVING COUNT(*) > 1;

--Checking duplicate account numbers
SELECT
    AccountNumber,
    COUNT(*) AS DuplicateCount
FROM Dim.DimCustomer
GROUP BY AccountNumber
HAVING COUNT(*) > 1;