# Enterprise Business Intelligence Suite — AdventureWorks

An end-to-end Enterprise Business Intelligence and Data Engineering project designed to integrate Sales, Finance, Human Resources, and Supply Chain data into a centralized analytical reporting solution.

The project uses the raw `AdventureWorks2025` OLTP database as its source and a custom-built SQL Server data warehouse named `Enterprise BI DW` as its analytical database.

The objective is to develop a unified reporting system for a multi-region company, incorporating data integration, dimensional modeling, ETL pipelines, interactive Power BI dashboards, and region-based Row-Level Security (RLS).

## Project Objectives

* Develop a custom analytical data warehouse using raw operational data.
* Design fact and dimension tables using Star Schema principles.
* Integrate four business domains: Sales, Finance, HR, and Supply Chain.
* Clean, transform, and validate data using Power Query and SQL.
* Implement data movement and ETL pipelines using Azure Data Factory.
* Develop interactive Power BI dashboards using DAX.
* Implement regional Row-Level Security to control report access.
* Establish a reliable and repeatable data processing workflow.

## Technology Stack

| Technology         | Purpose                                        |
| ------------------ | ---------------------------------------------- |
| SQL Server 2025    | Source database and analytical data warehouse  |
| SSMS               | Database management and SQL development        |
| SQL                | Data modeling, schema creation, and validation |
| Azure Data Factory | Data movement and ETL orchestration            |
| Power Query        | Data cleaning and transformation               |
| Power BI Desktop   | Data modeling and visualization                |
| DAX                | Business calculations and analytical KPIs      |

## Database Architecture

The project uses two separate SQL Server databases.

| Database             | Role                                   |
| -------------------- | -------------------------------------- |
| `AdventureWorks2025` | Raw OLTP source database               |
| `Enterprise BI DW`   | Custom-built analytical data warehouse |

### Source Database: AdventureWorks2025

The original AdventureWorks2025 OLTP database serves as the primary source of operational data.

Relevant source tables are used to develop custom fact and dimension tables based on the analytical requirements of the project.

### Target Database: Enterprise BI DW

A separate database named `Enterprise BI DW` has been created in SQL Server.

Raw operational data from AdventureWorks2025 has been used to develop custom fact and dimension tables for four business domains:

* Sales
* Finance
* Human Resources (HR)
* Supply Chain

This separation keeps the original operational database independent from the analytical data warehouse.

## Dimensional Modeling

The analytical data warehouse follows Star Schema principles.

Fact tables store measurable business events, while dimension tables provide descriptive attributes for analytical reporting.

Fact and dimension tables have been created for all four business domains.

### Sales

The Sales model supports sales-related analysis and business performance reporting.

### Finance

The Finance model supports financial and purchasing-related analysis.

### Human Resources (HR)

The HR model supports employee-related analysis, including employee snapshots, department history, and pay history.

### Supply Chain

The Supply Chain model supports inventory, inventory transactions, and work order analysis.

It includes dimensions such as:

* `DimLocation`
* `DimScrapReason`
* `DimTransactionType`

Its fact tables include:

* `FactInventorySnapshot`
* `FactInventoryTransaction`
* `FactWorkOrder`

The existing `FactPurchaseOrders` table is also reused where appropriate.

## Star Schema Diagrams

Five different star schema layouts have been designed in Power BI Model View to document the analytical data model.

| Diagram                  | Description                                                                 |
| ------------------------ | --------------------------------------------------------------------------- |
| Sales Star Schema        | Sales fact and dimension relationships                                      |
| Finance Star Schema      | Finance fact and dimension relationships                                    |
| HR Star Schema           | HR fact and dimension relationships                                         |
| Supply Chain Star Schema | Supply Chain fact and dimension relationships                               |
| Enterprise Overview      | Combined view of fact and dimension tables across all four business domains |

The Enterprise Overview provides an integrated view of the analytical model and its relationships.

**Diagram location:** `docs/diagrams/star_schema/`

## Data Cleaning and Shaping

Data cleaning and shaping have been completed in Power Query for the fact and dimension tables across all four business domains:

* Sales
* Finance
* HR
* Supply Chain

The data preparation process included:

* Verifying and assigning appropriate data types.
* Examining missing and null values.
* Checking duplicates and distinct values.
* Reviewing column quality.
* Removing unnecessary columns where appropriate.
* Investigating inconsistent or invalid values.
* Applying the required transformations.
* Reviewing the resulting tables before modeling.

Data cleaning decisions were made based on the structure and requirements of the individual tables.

## Technical Challenges and Resolutions

Several technical issues were encountered during database development and Power BI modeling.

### 1. Date Range Mismatch in HR Fact Tables

The dates in `FactEmployeeDepartmentHistory` and `FactEmployeePayHistory` were outside the available date range in `DimDate`.

**Resolution:**

* Extended and updated the `DimDate` table.
* Rewrote the SQL queries for both HR fact tables.
* Verified the updated date relationships.

### 2. Power Query and Power BI Synchronization

Changes made to `DimDate` in Power Query were not initially reflected correctly in Power BI Desktop. The two related HR fact tables also failed to reflect the expected updates.

**Resolution:** Addressed the model synchronization and refresh issues and verified the updated tables and relationships.

### 3. SQL Server Collation Conflict

A collation conflict occurred while creating `FactInventoryTransaction`.

**Resolution:** Applied `COLLATE DATABASE_DEFAULT` to the relevant transaction type join, resolving the issue.

## ETL and Data Movement

Azure Data Factory will be used to implement and orchestrate the data movement process between the source and target databases.

Planned activities include:

1. Configure source and destination connections.
2. Extract relevant data from AdventureWorks2025.
3. Apply required transformations.
4. Load data into the appropriate warehouse tables.
5. Establish pipeline dependencies and execution order.
6. Configure error handling and monitoring.
7. Validate loaded data against the source.

## Power BI Reporting and Security

Power BI will serve as the primary analytical and visualization layer.

Planned reporting capabilities include:

* Sales performance dashboards.
* Financial and purchasing analysis.
* Human Resources analytics.
* Supply Chain and inventory reporting.
* DAX-based business KPIs.
* Interactive filtering and drill-down analysis.
* Regional Row-Level Security (RLS).

The existing star schema layouts provide the foundation for developing the reporting model.

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
│   │
│   ├── diagrams/
│   │   └── star_schema/
│   │       ├── sales_star_schema.png
│   │       ├── finance_star_schema.png
│   │       ├── hr_star_schema.png
│   │       ├── supply_chain_star_schema.png
│   │       └── enterprise_overview.png
│   │
│   └── validation_results/
│
├── sql/
│   ├── 00_profiling/
│   ├── 001_restore/
│   ├── 02_warehouse/
│   └── 03_ETL/
│
├── azure-data-factory/
│
├── powerbi/
│
└── tests/
```

The repository structure separates database development, documentation, data preparation, ETL, and reporting activities.

## Project Progress

| Phase | Description                                                    | Status    |
| ----- | -------------------------------------------------------------- | --------- |
| 0     | Project setup and repository organization                      | Completed |
| 1     | Source database selection and setup                            | Completed |
| 2     | Creation of Enterprise BI DW                                   | Completed |
| 3     | Sales, Finance, HR, and Supply Chain fact and dimension tables | Completed |
| 4     | Data cleaning and shaping in Power Query                       | Completed |
| 5     | Five star schema layouts in Power BI                           | Completed |
| 6     | ETL development using Azure Data Factory                       | Upcoming  |
| 7     | Data movement and warehouse loading                            | Upcoming  |
| 8     | DAX measures and KPI development                               | Upcoming  |
| 9     | Power BI dashboards and reporting                              | Upcoming  |
| 10    | Regional Row-Level Security implementation                     | Upcoming  |
| 11    | End-to-end testing and documentation                           | Upcoming  |

*Completed status reflects the implementation work described above. Further validation and integration testing will continue as the project progresses.*

## Design Principles

* **Source-first development:** Build the analytical model using raw operational data.
* **Separation of concerns:** Keep the OLTP source and analytical warehouse separate.
* **Dimensional modeling:** Organize analytical data using fact and dimension tables.
* **Data integrity:** Maintain appropriate keys, relationships, and validation rules.
* **Repeatability:** Develop reproducible data processing workflows.
* **Security:** Implement regional access restrictions through RLS.
* **Documentation:** Maintain records of architectural decisions, schema diagrams, and implementation progress.

## Previous Implementation Archive

An earlier implementation was based on the prebuilt AdventureWorksDW2025 data warehouse.

The approach was subsequently changed to use the raw AdventureWorks2025 OLTP database and develop a custom analytical data warehouse.

Previous documentation and relevant work are retained separately for historical reference and are not the specification for the current implementation.

## Data Attribution

AdventureWorks sample databases are provided by Microsoft for learning and development purposes.

Refer to Microsoft's official sample database documentation for source information and applicable terms.
