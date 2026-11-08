# Enterprise Business Intelligence Suite — AdventureWorks

An end-to-end Enterprise Business Intelligence and Data Engineering project designed to integrate Sales, Finance, Human Resources, and Supply Chain data into a centralized analytical reporting solution.

The project uses the raw `AdventureWorks2025` OLTP database as its source and a custom-built SQL Server data warehouse named `Enterprise BI DW` as its analytical database.

The objective is to develop a unified reporting system for a multi-region company, incorporating dimensional modeling, automated ETL pipelines, interactive Power BI dashboards, business KPIs, and region-based Row-Level Security (RLS).

## Project Objectives

- Develop a custom analytical data warehouse using raw operational data.
- Design fact and dimension tables using Star Schema principles.
- Integrate four business domains: Sales, Finance, HR, and Supply Chain.
- Clean and transform data using Power Query.
- Implement automated data movement and ETL pipelines using Azure Data Factory.
- Develop DAX measures and business KPIs.
- Build interactive Power BI dashboards.
- Implement regional Row-Level Security.
- Establish a reliable and repeatable data processing workflow.

## Technology Stack

| Technology | Purpose |
|---|---|
| SQL Server 2025 | Source database and analytical data warehouse |
| SSMS | Database management and SQL development |
| SQL | Data modeling, transformations, loading, and validation |
| Azure Data Factory | ETL orchestration and data movement |
| Self-Hosted Integration Runtime | Connectivity between Azure Data Factory and local SQL Server |
| Power Query | Data cleaning and transformation |
| Power BI Desktop | Data modeling and visualization |
| DAX | Business calculations and analytical KPIs |

## Database Architecture

The project uses two separate SQL Server databases.

| Database | Role |
|---|---|
| `AdventureWorks2025` | Raw OLTP source database |
| `Enterprise BI DW` | Custom-built analytical data warehouse |

### Source Database: AdventureWorks2025

The original AdventureWorks2025 OLTP database serves as the primary source of operational data.

Relevant source tables are used to develop custom fact and dimension tables according to the analytical requirements of the project.

### Target Database: Enterprise BI DW

A separate database named `Enterprise BI DW` has been created in SQL Server.

Raw operational data from AdventureWorks2025 is used to develop fact and dimension tables for four business domains:

- Sales
- Finance
- Human Resources (HR)
- Supply Chain

This separation keeps the operational source database independent from the analytical data warehouse.

## Dimensional Modeling

The analytical data warehouse follows Star Schema principles.

Fact tables store measurable business events, while dimension tables provide descriptive attributes for analytical reporting.

Fact and dimension tables have been developed for all four business domains.

### Sales

Supports sales-related analysis and business performance reporting.

### Finance

Supports financial and purchasing-related analysis.

### Human Resources

Supports employee-related analytics, including employee snapshots, department history, and pay history.

### Supply Chain

Supports inventory, inventory transaction, and work order analysis.

The existing purchase order fact model is also incorporated where appropriate.

## Star Schema Design

Five different star schema layouts have been designed in Power BI Model View.

| Diagram | Description |
|---|---|
| Sales Star Schema | Sales fact and dimension relationships |
| Finance Star Schema | Finance fact and dimension relationships |
| HR Star Schema | HR fact and dimension relationships |
| Supply Chain Star Schema | Supply Chain fact and dimension relationships |
| Enterprise Overview | Combined view of fact and dimension tables across all four business domains |

**Location:** `docs/diagrams/star_schema/`

## Data Cleaning and Shaping

Data cleaning and shaping have been completed in Power Query for fact and dimension tables across all four business domains.

Activities included:

- Data type verification and correction.
- Null and missing value analysis.
- Duplicate and distinct value checks.
- Column quality examination.
- Removal of unnecessary columns where appropriate.
- Investigation of inconsistent and invalid values.
- Application of required transformations.

## Phase 3: Data Movement and ETL Using Azure Data Factory

**Status: COMPLETED**

Azure Data Factory has been configured and implemented to orchestrate data movement between the AdventureWorks2025 source database and the `Enterprise BI DW` analytical database.

### Azure Data Factory Configuration

The following components have been configured:

- Azure Data Factory instance.
- Self-Hosted Integration Runtime for connectivity to the local SQL Server environment.
- Source linked service.
- Destination linked service.
- Source datasets.
- Destination datasets.

### Departmental ETL Pipelines

Four separate departmental ETL pipelines have been developed:

1. Sales ETL Pipeline
2. Finance ETL Pipeline
3. HR ETL Pipeline
4. Supply Chain ETL Pipeline

Stored procedure activities have been configured within the pipelines to execute the corresponding SQL-based data processing and loading operations.

### Master Orchestration Pipeline

A master orchestration pipeline has been developed to coordinate the execution of all four departmental pipelines.

Implemented capabilities include:

- Integration of all four departmental pipelines.
- Sequential execution.
- Pipeline dependencies.
- Execution order management.

### Publishing and Testing

- Validated all pipelines.
- Published the configured pipelines.
- Successfully executed and tested all four departmental pipelines individually.
- Successfully executed and tested the master orchestration pipeline.

**Result:** The mandatory Azure Data Factory implementation tasks for Phase 3 have been completed successfully.

## SQL Development and Validation

SQL scripts have been developed to support warehouse creation, ETL processing, data loading, and validation.

The SQL development includes:

- Fact and dimension table creation.
- Dimension loading queries.
- Fact loading queries.
- ETL transformation queries.
- Stored procedure implementation.
- Dimension ETL validation.
- Dimension table verification.
- Fact and dimension loading validation.

The SQL scripts supporting ETL and loading activities are maintained in the `03_SQL` directory.

## Technical Challenges and Resolutions

### HR Date Dimension Mismatch

The dates in `FactEmployeeDepartmentHistory` and `FactEmployeePayHistory` initially did not match the available date range in `DimDate`.

**Resolution:** Extended and updated the date dimension and rewrote the SQL queries for both HR fact tables.

### Power BI Model Synchronization

Changes made to `DimDate` in Power Query were not initially reflected correctly in Power BI Desktop. The related HR fact tables also failed to reflect the expected updates.

**Resolution:** Resolved the refresh and model synchronization issues and verified the updated tables and relationships.

### SQL Server Collation Conflict

A collation conflict occurred while developing `FactInventoryTransaction`.

**Resolution:** Applied `COLLATE DATABASE_DEFAULT` to the relevant SQL operation.

## Next Phase: DAX Measures and Analytical Calculations

The next development phase focuses on creating DAX measures in Power BI.

Planned activities include:

- Total Sales and Revenue measures.
- Year-to-Date (YTD) calculations.
- Year-over-Year (YoY) growth.
- Profit and margin percentage calculations.
- Rolling averages.
- Department-specific analytical KPIs.
- Validation of DAX calculations against SQL results.

## Power BI Reporting and Security

Following DAX development, Power BI will be used to build the final analytical reporting solution.

Planned capabilities include:

- Sales performance dashboards.
- Financial and purchasing analysis.
- Human Resources analytics.
- Supply Chain and inventory reporting.
- Interactive filtering and drill-down analysis.
- Regional Row-Level Security.

## Repository Structure

```text
Enterprise-BI-Project/
│
├── README.md
│
├── docs/
│   ├── requirements.md
│   ├── decisions.md
│   ├── journal.md
│   ├── data_dictionary.md
│   ├── diagrams/
│   │   └── star_schema/
│   └── validation_results/
│
├── sql/
│   ├── 00_profiling/
│   ├── 001_restore/
│   ├── 02_warehouse/
│   └── 03_SQL/
│       ├── dimension_validation/
│       ├── dimension_load/
│       ├── fact_load/
│       └── etl_validation/
│
├── azure-data-factory/
│
├── powerbi/
│
└── tests/
```

The repository structure separates database development, documentation, ETL implementation, validation, and reporting assets.

## Project Progress

| Phase | Description | Status |
|---|---|---|
| 0 | Project setup and repository organization | Completed |
| 1 | Source database selection and setup | Completed |
| 2 | Data warehouse and dimensional modeling | Completed |
| 3 | Data cleaning, shaping, and star schema design | Completed |
| 4 | Azure Data Factory configuration and ETL implementation | Completed |
| 5 | DAX measures and analytical calculations | Next |
| 6 | Power BI dashboards and reporting | Upcoming |
| 7 | Regional Row-Level Security | Upcoming |
| 8 | End-to-end testing and final documentation | Upcoming |

## Design Principles

- **Source-first development:** Build the analytical model using raw operational data.
- **Separation of concerns:** Keep the OLTP source and analytical warehouse separate.
- **Dimensional modeling:** Organize analytical data using fact and dimension tables.
- **Data integrity:** Maintain appropriate keys, relationships, and validation rules.
- **Automation:** Use Azure Data Factory to orchestrate repeatable ETL workflows.
- **Reliability:** Validate departmental pipelines and master orchestration.
- **Security:** Implement regional access restrictions through RLS.
- **Documentation:** Maintain architectural decisions, implementation records, and validation evidence.

## Previous Implementation Archive

An earlier implementation was based on the prebuilt AdventureWorksDW2025 data warehouse.

The approach was subsequently changed to use the raw AdventureWorks2025 OLTP database and develop a custom analytical data warehouse.

Previous documentation and relevant work are retained separately for historical reference.

## Data Attribution

AdventureWorks sample databases are provided by Microsoft for learning and development purposes. Refer to Microsoft's official sample database documentation for source information and applicable terms.