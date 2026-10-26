# Enterprise Business Intelligence Suite for a Multi-Region Company: AdventureWorks

One reporting system combining sales, finance, HR and supply chain data with row-level security by region.

## Tech stack
Power BI, DAX, Power Query, SQL Server 2025, Azure Data Factory (or SQL Agent jobs)

## Setup
1. Install SQL Server 2025 and SSMS
2. Download AdventureWorks2025.bak and AdventureWorksDW2025.bak from Microsoft's sample databases page (not included in this repo)
3. Run sql/01_restore/restore_databases.sql
4. Run tests/01_restore_validation.sql to confirm the restore

## Status
Phase 0 (setup) complete. More sections will be added as the project progresses.