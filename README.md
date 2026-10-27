# Enterprise Business Intelligence Suite for a Multi-Region Company: AdventureWorks

One reporting system combining sales, finance, HR and supply chain data with row-level security by region.

## Tech stack
Power BI, DAX, Power Query, SQL Server 2025, Azure Data Factory (or SQL Agent jobs)

## Setup
1. Install SQL Server 2025 and SSMS
2. Download AdventureWorks2025.bak and AdventureWorksDW2025.bak from Microsoft's sample databases page (not included in this repo)
3. Run sql/01_restore/restore_databases.sql
4. Run tests/01_restore_validation.sql to confirm the restore

## Data source and design
The star schema is designed from the **AdventureWorksDW2025** data warehouse, which is already organised into fact and dimension tables.

| Type | Tables |
|---|---|
| Fact | `FactInternetSales` |
| Dimensions | `DimDate`, `DimCustomer`, `DimProduct`, `DimPromotion`, `DimSalesTerritory` |
| Merged in Power Query | `DimProductSubcategory` and `DimProductCategory` are merged into `DimProduct` to form a single product dimension |

See `docs/decisions.md` for the reasons behind each choice.

## Status
| Phase | State |
|---|---|
| 0. Setup and repo | Complete |
| 1. Requirements and design | In progress: tables selected and product hierarchy merged; data cleaning and shaping in Power Query still to finish |
| 2 onward | Not started |