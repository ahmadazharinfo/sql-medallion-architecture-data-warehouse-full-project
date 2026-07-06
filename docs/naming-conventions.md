# Naming Conventions

## Project: sql-medallion-architecture-data-warehouse-full-project

A comprehensive SQL Data Warehouse featuring a structured Medallion ETL pipeline and optimized data modeling to drive a full business intelligence analysis.

---

## Table of Contents

1. [General Principles](#general-principles)
2. [Database and Schema Naming Conventions](#database-and-schema-naming-conventions)
3. [Table Naming Conventions](#table-naming-conventions)
   - [Bronze Rules](#bronze-rules)
   - [Silver Rules](#silver-rules)
   - [Gold Rules](#gold-rules)
   - [Glossary of Category Patterns](#glossary-of-category-patterns)
4. [Column Naming Conventions](#column-naming-conventions)
   - [Surrogate Keys](#surrogate-keys)
   - [Technical Columns](#technical-columns)
   - [General Columns](#general-columns)
5. [View Naming Conventions](#view-naming-conventions)
6. [Stored Procedure Naming Conventions](#stored-procedure-naming-conventions)
7. [Function Naming Conventions](#function-naming-conventions)
8. [Index Naming Conventions](#index-naming-conventions)
9. [Constraint Naming Conventions](#constraint-naming-conventions)
10. [ETL and Pipeline Object Naming Conventions](#etl-and-pipeline-object-naming-conventions)
11. [File and Folder Naming Conventions](#file-and-folder-naming-conventions)
12. [Reserved Words Reference](#reserved-words-reference)

---

## General Principles

- **Naming Conventions**: Use snake_case, with lowercase letters and underscores (`_`) to separate words.
- **Language**: Use English for all names.
- **Avoid Reserved Words**: Do not use SQL reserved words as object names.
- **Clarity Over Brevity**: A name should describe what the object holds or does, even if it is a few characters longer.
- **Consistency**: The same concept must be named the same way everywhere it appears (bronze, silver, gold, procedures, views).
- **No Special Characters**: Only lowercase letters, digits, and underscores are allowed. No spaces, hyphens, or symbols.
- **No Abbreviated Guesswork**: Only use abbreviations that are defined in this document (e.g., `dim`, `fact`, `agg`, `dwh`, `key`). Do not invent new ones.

---

## Database and Schema Naming Conventions

- **Database name**: `<project_domain>_dwh`
  - Example: `sales_dwh` for a sales-focused warehouse.
- **Schema names** must match the medallion layer they represent:
  - `bronze`: Raw, unprocessed data ingested as-is from source systems.
  - `silver`: Cleaned, standardized, and conformed data.
  - `gold`: Business-ready, dimensional model data for reporting and analytics.

Example: `bronze.crm_customer_info`, `silver.crm_customer_info`, `gold.dim_customers`.

---

## Table Naming Conventions

### Bronze Rules

- All names must start with the source system name, and table names must match their original names without renaming.
- **Pattern**: `<sourcesystem>_<entity>`
  - `<sourcesystem>`: Name of the source system (e.g., `crm`, `erp`).
  - `<entity>`: Exact table name from the source system.
  - Example: `crm_customer_info` → Customer information from the CRM system.

### Silver Rules

- All names must start with the source system name, and table names must match their original names without renaming.
- **Pattern**: `<sourcesystem>_<entity>`
  - `<sourcesystem>`: Name of the source system (e.g., `crm`, `erp`).
  - `<entity>`: Exact table name from the source system.
  - Example: `crm_customer_info` → Customer information from the CRM system, cleaned and standardized.

### Gold Rules

- All names must use meaningful, business-aligned names for tables, starting with the category prefix.
- **Pattern**: `<category>_<entity>`
  - `<category>`: Describes the role of the table, such as `dim` (dimension), `fact` (fact table), or `agg` (aggregated table).
  - `<entity>`: Descriptive name of the table, aligned with the business domain (e.g., `customers`, `products`, `sales`).
  - Examples:
    - `dim_customers` → Dimension table for customer data.
    - `fact_sales` → Fact table containing sales transactions.

### Glossary of Category Patterns

| Pattern | Meaning              | Example(s)                          |
|---------|----------------------|--------------------------------------|
| `dim_`  | Dimension table       | `dim_customers`, `dim_products`      |
| `fact_` | Fact table            | `fact_sales`                         |
| `agg_`  | Aggregated table      | `agg_customers`, `agg_sales_monthly` |

---

## Column Naming Conventions

### Surrogate Keys

- All primary keys in dimension tables must use the suffix `_key`.
- **Pattern**: `<table_name>_key`
  - `<table_name>`: Refers to the name of the table or entity the key belongs to.
  - `_key`: A suffix indicating that this column is a surrogate key.
  - Example: `customer_key` → Surrogate key in the `dim_customers` table.

### Technical Columns

- All technical columns must start with the prefix `dwh_`, followed by a descriptive name indicating the column's purpose.
- **Pattern**: `dwh_<column_name>`
  - `dwh`: Prefix exclusively for system-generated metadata.
  - `<column_name>`: Descriptive name indicating the column's purpose.
  - Example: `dwh_load_date` → System-generated column used to store the date when the record was loaded.
  - Other examples: `dwh_source_system`, `dwh_batch_id`, `dwh_updated_at`.

### General Columns

- Use singular, descriptive nouns for regular attribute columns (e.g., `first_name`, `order_date`, `unit_price`).
- Boolean columns must start with `is_` or `has_` (e.g., `is_active`, `has_discount`).
- Date columns must end with `_date` (e.g., `birth_date`, `hire_date`).
- Datetime/timestamp columns must end with `_at` (e.g., `created_at`, `updated_at`).
- Foreign keys in fact tables must match the surrogate key name of the referenced dimension (e.g., `customer_key` in `fact_sales` referencing `dim_customers.customer_key`).

---

## View Naming Conventions

- Views must follow the same pattern as the layer and table they expose.
- **Pattern**: `v_<layer>_<entity>` (used only when a view is needed outside standard layer naming, such as reporting-layer views).
  - Example: `v_gold_sales_summary` → Reporting view summarizing gold-layer sales data.
- Views that expose gold-layer tables directly may reuse the gold table name if the view acts as the primary access point (e.g., `dim_customers` as both table and view name is acceptable when using a view-based gold layer).

---

## Stored Procedure Naming Conventions

- All stored procedures used for loading data must follow the naming pattern: `load_<layer>`.
  - `<layer>`: Represents the layer being loaded, such as `bronze`, `silver`, or `gold`.
  - Examples:
    - `load_bronze` → Stored procedure for loading data into the Bronze layer.
    - `load_silver` → Stored procedure for loading data into the Silver layer.
    - `load_gold` → Stored procedure for loading data into the Gold layer.
- Utility or maintenance procedures follow the pattern: `<action>_<object>`.
  - Examples: `truncate_bronze_tables`, `validate_silver_data`, `archive_gold_snapshots`.

---

## Function Naming Conventions

- Scalar functions follow the pattern: `fn_<action>_<entity>`.
  - Example: `fn_calculate_age` → Returns a calculated age from a birth date.
- Table-valued functions follow the pattern: `fn_get_<entity>`.
  - Example: `fn_get_active_customers` → Returns a set of active customer records.

---

## Index Naming Conventions

- **Pattern**: `ix_<table_name>_<column_name>`
  - Example: `ix_fact_sales_customer_key` → Index on the `customer_key` column in `fact_sales`.
- Unique indexes use the prefix `uq_` instead of `ix_`.
  - Example: `uq_dim_customers_customer_key`.
- Covering indexes may append `_covering` to indicate purpose.
  - Example: `ix_fact_sales_order_date_covering`.

---

## Constraint Naming Conventions

| Constraint Type   | Pattern                              | Example                              |
|--------------------|---------------------------------------|----------------------------------------|
| Primary Key        | `pk_<table_name>`                     | `pk_dim_customers`                     |
| Foreign Key         | `fk_<table_name>_<referenced_table>`  | `fk_fact_sales_dim_customers`          |
| Check               | `ck_<table_name>_<column_name>`       | `ck_fact_sales_quantity`               |
| Default             | `df_<table_name>_<column_name>`       | `df_fact_sales_dwh_load_date`          |
| Unique              | `uq_<table_name>_<column_name>`       | `uq_dim_products_product_key`          |

---

## ETL and Pipeline Object Naming Conventions

- **Batch job names**: `job_<layer>_<frequency>` (e.g., `job_bronze_daily`, `job_gold_monthly`).
- **Staging tables**: `stg_<sourcesystem>_<entity>` (e.g., `stg_crm_customer_info`).
- **Error/quarantine tables**: `err_<sourcesystem>_<entity>` (e.g., `err_erp_sales_orders`).
- **Log tables**: `log_<process_name>` (e.g., `log_load_bronze`).
- **Audit tables**: `audit_<layer>_<entity>` (e.g., `audit_silver_customer_info`).

---

## File and Folder Naming Conventions

- SQL script files: `<order_number>_<layer>_<action>.sql`
  - Example: `01_bronze_create_tables.sql`, `02_bronze_load_data.sql`, `03_silver_transform.sql`.
- Documentation files: lowercase with underscores, `.md` extension.
  - Example: `naming_conventions.md`, `data_dictionary.md`, `etl_architecture.md`.
- Folder structure by layer:
  ```
  /scripts
    /bronze
    /silver
    /gold
  /docs
  /tests
  ```

---

## Reserved Words Reference

Avoid using the following as object names (non-exhaustive, common SQL Server reserved words):

`select`, `insert`, `update`, `delete`, `table`, `key`, `index`, `view`, `procedure`, `function`, `order`, `group`, `user`, `date`, `year`, `level`, `check`, `default`, `identity`, `transaction`, `rule`, `type`

If a business term collides with a reserved word, append a qualifying suffix (e.g., use `order_date` instead of `date`, or `user_account` instead of `user`).

---

*This document defines the single source of truth for all naming decisions across the Bronze, Silver, and Gold layers of the sql-medallion-architecture-data-warehouse-full-project. Any new object introduced to the project must follow one of the patterns defined here before being merged into the codebase.*
