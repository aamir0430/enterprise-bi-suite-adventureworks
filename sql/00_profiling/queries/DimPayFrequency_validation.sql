USE EnterpriseBI_DW
GO

-- Validating the DimPayFrequency table:

-- 1. Checking row count and key uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT PayFrequencyKey) AS DistinctPayFrequencyKeys,
    COUNT(DISTINCT PayFrequencyCode) AS DistinctPayFrequencyCodes,
    COUNT(DISTINCT PayFrequencyName) AS DistinctPayFrequencyNames,
    COUNT(*) - COUNT(PayFrequencyKey) AS NullKeys
FROM Dim.DimPayFrequency;

-- 2. Checking the pay-frequency code distribution
SELECT
    PayFrequencyCode,
    PayFrequencyName
FROM Dim.DimPayFrequency
ORDER BY PayFrequencyCode;