# Project Development Journal

This journal documents the major development milestones, implementation activities, and technical challenges encountered during the development of the Enterprise Business Intelligence Suite.

## 1. Database Setup and Dimensional Modeling

- Selected the raw `AdventureWorks2025` OLTP database as the primary source.
- Created a separate SQL Server database named `Enterprise BI DW`.
- Used raw source data to create custom fact and dimension tables for Sales, Finance, and Human Resources (HR).
- Extended the dimensional model to include Supply Chain.
- Created fact and dimension tables for all four business domains.
- Organized warehouse schema creation scripts in `sql/02_warehouse/`.

## 2. Data Cleaning and Shaping

Completed data cleaning and shaping in Power Query for fact and dimension tables across all four business domains:

- Sales
- Finance
- Human Resources (HR)
- Supply Chain

Activities included data type verification, null value analysis, duplicate checks, column quality examination, removal of unnecessary columns, and other required transformations.

## 3. Star Schema Design

Designed five different star schema layouts in Power BI Model View:

1. Sales Star Schema
2. Finance Star Schema
3. HR Star Schema
4. Supply Chain Star Schema
5. Enterprise Overview – Combined view of fact and dimension tables across all four business domains.

The diagrams are maintained in `docs/diagrams/star_schema/`.

## 4. Technical Challenges and Resolutions

### HR Date Dimension Mismatch

The dates in `FactEmployeeDepartmentHistory` and `FactEmployeePayHistory` did not match the available date range in `DimDate`.

**Resolution:** Extended and updated `DimDate`, rewrote the SQL queries for both HR fact tables, and verified the updated data and relationships.

### Power BI Model Synchronization

Changes made to `DimDate` in Power Query were not initially reflected correctly in Power BI Desktop. The two related HR fact tables also failed to reflect the expected updates.

**Resolution:** Resolved the model refresh and synchronization issues and verified the updated tables and relationships.

### SQL Server Collation Conflict

A collation conflict occurred while developing `FactInventoryTransaction`.

**Resolution:** Applied `COLLATE DATABASE_DEFAULT` to the relevant SQL operation, resolving the issue.

## 5. Phase 3 – Data Movement and ETL Implementation Using Azure Data Factory

**Status: COMPLETED**

Implemented the end-to-end data movement and ETL orchestration infrastructure using Azure Data Factory.

### Azure Data Factory Configuration

- Configured Azure Data Factory.
- Configured and established a Self-Hosted Integration Runtime to connect to the local SQL Server environment.
- Created source and destination linked services.
- Configured source and destination datasets.

### Departmental ETL Pipelines

Created four separate departmental ETL pipelines:

1. Sales ETL Pipeline
2. Finance ETL Pipeline
3. HR ETL Pipeline
4. Supply Chain ETL Pipeline

### Stored Procedure Activities

- Configured stored procedure activities within the departmental pipelines.
- Connected the pipelines to the corresponding SQL stored procedures.
- Established the required execution sequence for the data loading operations.

### Master Orchestration Pipeline

- Created a master orchestration pipeline.
- Integrated all four departmental ETL pipelines.
- Configured sequential execution and pipeline dependencies.
- Established the execution order between departmental pipelines.

### Publishing and Testing

- Validated the ADF pipelines.
- Published all configured pipelines.
- Successfully executed and tested all four departmental pipelines individually.
- Successfully executed and tested the master orchestration pipeline.
- Verified that the departmental pipelines execute through the master pipeline according to the configured dependencies.

**Outcome:** The Azure Data Factory implementation is complete. All four departmental pipelines and the master orchestration pipeline have been successfully tested. No mandatory Phase 3 implementation tasks remain.

## 6. SQL ETL and Validation Documentation

Developed and organized SQL scripts supporting the ETL implementation and data validation in the `03_SQL` folder.

The SQL development work includes:

- Dimension ETL validation queries.
- Dimension table verification queries.
- Dimension loading SQL queries.
- Fact loading SQL queries.
- ETL transformation queries.
- Fact and dimension loading procedures.
- Validation queries for verifying departmental ETL operations and loaded data.

These scripts provide supporting evidence for the data movement, loading, and validation processes.

## Current Project Milestone

The following major stages have been completed:

- Source database selection and target warehouse creation.
- Fact and dimension table development for Sales, Finance, HR, and Supply Chain.
- Data cleaning and shaping across all four business domains.
- Five star schema layouts in Power BI.
- SQL-based ETL development and validation.
- Azure Data Factory configuration and integration.
- Four departmental ETL pipelines.
- Master orchestration pipeline with sequential dependencies.
- Successful individual and master pipeline execution and testing.

**Phase 3 – Building Data Movement with Azure Data Factory: COMPLETED.**

**Next Phase: DAX Measures and Analytical Calculations in Power BI.**