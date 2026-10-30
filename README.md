# Enterprise Business Intelligence Suite — AdventureWorks

An end-to-end Enterprise Business Intelligence and Data Engineering project designed to integrate Sales, Finance, Human Resources, and Supply Chain data into a centralized analytical reporting solution.

The project uses the raw AdventureWorks2025 OLTP database as its source and a separately developed data warehouse to support dimensional modeling, ETL pipelines, and Power BI reporting.

The ultimate objective is to build a unified reporting system for a multi-region company, incorporating regional Row-Level Security (RLS).

## Project Objectives

* Develop a custom data warehouse using raw operational data.
* Design fact and dimension tables using star schema principles.
* Build analytical models for Sales, Finance, and Human Resources.
* Perform data cleaning, transformation, and quality validation.
* Implement ETL and data movement pipelines using Azure Data Factory.
* Develop interactive Power BI dashboards using DAX and Power Query.
* Implement regional Row-Level Security to control report access.
* Establish a reliable and repeatable data processing workflow.

## Technology Stack

| Technology         | Purpose                                          |
| ------------------ | ------------------------------------------------ |
| SQL Server 2025    | Source database and data warehouse               |
| SSMS               | Database management and SQL development          |
| SQL                | Schema creation, transformations, and validation |
| Azure Data Factory | ETL orchestration and data movement              |
| Power Query        | Data preparation and transformation              |
| Power BI           | Business intelligence and reporting              |
| DAX                | KPIs, calculations, and analytical measures      |

## Database Architecture

The project uses two separate databases:

| Database             | Role                                   |
| -------------------- | -------------------------------------- |
| `AdventureWorks2025` | Raw OLTP source database               |
| `Enterprise BI DW`   | Custom-built analytical data warehouse |

### Source Database: AdventureWorks2025

The original AdventureWorks2025 OLTP database serves as the primary source of operational data.

Relevant source tables are analyzed and used to develop the analytical model.

### Target Database: Enterprise BI DW

A separate database named `Enterprise BI DW` has been created in SQL Server.

Operational data from AdventureWorks2025 is used to develop custom fact and dimension tables within this database.

The data warehouse is being designed to support analytical reporting across multiple business domains.

## Dimensional Modeling

The analytical data warehouse follows star schema principles.

Fact and dimension tables have been created for the following business domains:

### Sales

The Sales data model captures sales-related business information and provides the foundation for sales performance analysis.

### Finance

The Finance data model supports financial and purchasing-related analysis.

### Human Resources

The HR data model supports employee-related analytics, including employee snapshots, department history, and pay history.

The dimensional model uses appropriate keys and relationships to connect fact tables with their corresponding dimensions.

The complete table definitions and implementation scripts are maintained in the repository.

## Data Cleaning and Quality Validation

Data cleaning and validation will be performed to ensure that the analytical data is accurate, consistent, and reliable.

Planned checks include:

* Missing values in important columns.
* Duplicate records and business keys.
* Invalid or suspicious numeric values.
* Data type consistency.
* Primary key uniqueness.
* Foreign key integrity.
* Unmatched dimension keys.
* Record count reconciliation.
* Aggregated measure reconciliation between source and warehouse.

SQL-based validation and Power Query transformations will be used where appropriate.

No records will be deleted without a documented justification or business rule.

## ETL and Data Movement

Azure Data Factory will be used to implement and orchestrate the data movement process between the source and target environments.

Planned activities include:

1. Configure source and destination connections.
2. Extract relevant data from AdventureWorks2025.
3. Apply required transformations.
4. Load data into the appropriate warehouse dimensions and fact tables.
5. Implement pipeline dependencies and execution order.
6. Configure error handling and monitoring.
7. Validate the loaded data against the source.

Incremental loading and other optimization techniques will be considered where appropriate.

## Power BI Reporting and Security

Power BI will serve as the primary analytical and visualization layer.

Planned reporting capabilities include:

* Sales performance dashboards.
* Financial reporting and analysis.
* Human Resources analytics.
* Supply chain reporting.
* Business KPIs and DAX measures.
* Interactive filters and drill-down analysis.
* Regional Row-Level Security (RLS).

RLS will ensure that users can access only the regional data they are authorized to view.

## Repository Structure

The repository is organized to separate documentation, database development, ETL, reporting, and validation activities.

```text
Enterprise-BI-Project/
│
├── README.md
│
├── docs/
│   ├── decisions.md
│   ├── journal.md
│   └── archive/
│       └── PREVIOUS_APPROACH_ARCHIVE.md
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

### SQL Folder Responsibilities

| Folder         | Purpose                                                                    |
| -------------- | -------------------------------------------------------------------------- |
| `00_profiling` | Source database analysis and profiling                                     |
| `001_restore`  | Database restoration scripts                                               |
| `02_warehouse` | Fact and dimension table creation, keys, constraints, and warehouse schema |
| `03_ETL`       | Data extraction, transformation, and loading scripts                       |

The `02_warehouse` folder contains the SQL scripts developed for the Sales, Finance, and HR dimensional models.

The `03_ETL` folder will contain the scripts and supporting SQL logic used for data movement and loading.

## Setup and Prerequisites

Required software and resources:

* SQL Server 2025
* SQL Server Management Studio (SSMS)
* AdventureWorks2025 sample database backup
* Power BI Desktop
* Azure Data Factory environment

### Initial Setup

1. Install SQL Server 2025 and SSMS.
2. Download the official AdventureWorks2025 backup from Microsoft's sample database resources.
3. Restore the AdventureWorks2025 database.
4. Create a separate database named `Enterprise BI DW`.
5. Execute the relevant SQL scripts from `sql/02_warehouse/` to create the warehouse schema.

The database backup files are not included in this repository.

Additional setup instructions for ETL pipelines and Power BI will be documented as those phases are implemented.

## Project Progress

| Phase | Description                                 | Status    |
| ----- | ------------------------------------------- | --------- |
| 0     | Project setup and repository organization   | Completed |
| 1     | Source database selection and setup         | Completed |
| 2     | Creation of Enterprise BI DW database       | Completed |
| 3     | Sales, Finance, and HR dimensional modeling | Completed |
| 4     | Data cleaning and quality validation        | Upcoming  |
| 5     | ETL development using Azure Data Factory    | Upcoming  |
| 6     | Data loading and warehouse validation       | Upcoming  |
| 7     | Power BI semantic model and dashboards      | Upcoming  |
| 8     | DAX measures and KPI development            | Upcoming  |
| 9     | Regional Row-Level Security implementation  | Upcoming  |
| 10    | End-to-end testing and documentation        | Upcoming  |

*Status reflects the work completed so far. Individual phases may require further validation before being considered fully finalized.*

## Design Principles

* **Source-first development:** Build the analytical model using the raw operational database.
* **Separation of concerns:** Keep the OLTP source and analytical warehouse separate.
* **Dimensional modeling:** Use fact and dimension tables to support analytical workloads.
* **Data integrity:** Maintain appropriate keys, relationships, and validation rules.
* **Repeatability:** Develop reproducible ETL and data validation workflows.
* **Security:** Implement regional access restrictions through RLS.
* **Documentation:** Maintain records of architectural decisions and implementation progress.

## Previous Implementation Archive

An earlier implementation was based on the AdventureWorksDW2025 prebuilt data warehouse.

That approach was replaced with a source-first implementation using AdventureWorks2025 OLTP.

Previous documentation, SQL scripts, and related work are retained separately in the project archive for historical reference. They are not the specification for the current implementation.

## License and Data Attribution

AdventureWorks sample databases are provided by Microsoft for learning and development purposes.

Refer to Microsoft's official documentation for sample database information and applicable licensing terms.

Project-specific scripts, documentation, and original implementation work are maintained in this repository.
