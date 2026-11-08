# Project Decisions

This document records the major architectural and technical decisions made during the development of the Enterprise Business Intelligence Suite.

## 1. Source Database Selection

**Decision:** Use the raw `AdventureWorks2025` OLTP database as the primary source instead of the prebuilt `AdventureWorksDW2025` data warehouse.

## 2. Separate Data Warehouse

**Decision:** Create a dedicated SQL Server database named `Enterprise BI DW` to store custom-designed fact and dimension tables using raw AdventureWorks2025 data.

## 3. Dimensional Modeling

**Decision:** Follow Star Schema principles.

**Implementation:** Develop fact and dimension tables for four business domains:

- Sales
- Finance
- Human Resources (HR)
- Supply Chain

## 4. SQL Script Organization

**Decision:** Maintain warehouse schema creation scripts separately from ETL and data loading scripts.

**Implementation:**
- Warehouse schema scripts: `sql/02_warehouse/`
- ETL, loading, and supporting validation SQL scripts: `03_SQL/`

## 5. Data Cleaning and Shaping

**Decision:** Use Power Query for cleaning and shaping the analytical data.

**Implementation:** Complete data cleaning and shaping for the Sales, Finance, HR, and Supply Chain fact and dimension tables.

## 6. Star Schema Documentation

**Decision:** Maintain separate departmental star schema diagrams and a combined Enterprise Overview.

**Implementation:** Five diagrams covering Sales, Finance, HR, Supply Chain, and the combined Enterprise Overview.

**Location:** `docs/diagrams/star_schema/`

## 7. ETL and Data Movement

**Decision:** Use Azure Data Factory to implement and orchestrate data movement between the source database and the analytical data warehouse.

**Implementation:**
- Configured Azure Data Factory.
- Established a Self-Hosted Integration Runtime for local SQL Server connectivity.
- Created source and destination linked services and datasets.
- Developed four departmental ETL pipelines.
- Used stored procedure activities for SQL-based processing and loading.
- Created a master orchestration pipeline with sequential execution and dependencies.
- Validated, published, and successfully tested all departmental and master pipelines.

**Status:** Implemented and tested.

---

*This document will be updated as additional architectural and technical decisions are made.*