USE EnterpriseBI_DW
GO

-- A. CostRate

SELECT
    CostRate,
    COUNT(*) AS LocationCount
FROM Dim.DimLocation
GROUP BY CostRate
ORDER BY CostRate;

-- Checking the range
SELECT
    MIN(CostRate) AS MinimumCostRate,
    MAX(CostRate) AS MaximumCostRate,
    AVG(CostRate) AS AverageCostRate
FROM Dim.DimLocation;

-- B. Availability

SELECT
    Availability,
    COUNT(*) AS LocationCount
FROM Dim.DimLocation
GROUP BY Availability
ORDER BY Availability;

-- Checking for negative values
SELECT *
FROM Dim.DimLocation
WHERE Availability < 0;
