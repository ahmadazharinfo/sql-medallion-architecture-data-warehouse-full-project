# Architecture Decision Records (ADR)

## Purpose

Documents the key design decisions made while building this warehouse, why they were made, and what alternatives were considered. This is standard practice on professional data teams so future contributors (or future you) understand the reasoning, not just the result.

---

## ADR 001: Medallion Architecture (Bronze / Silver / Gold)

**Decision**: Structure the warehouse into three progressive layers rather than transforming source data directly into the final model.

**Reasoning**:
- Keeps raw data traceable and re-processable. If a transformation rule turns out to be wrong, the original untouched data is still available in Bronze.
- Separates concerns cleanly: Bronze = ingestion, Silver = data quality, Gold = business logic.
- Matches the industry-standard pattern used across most modern data platforms (Databricks, Microsoft Fabric, Snowflake reference architectures).

**Alternative considered**: Single-layer ETL directly from source to reporting tables. Rejected because it makes debugging data quality issues significantly harder, since there is no intermediate checkpoint.

---

## ADR 002: Full Load (Truncate and Insert) instead of Incremental Load

**Decision**: Bronze and Silver layers are fully truncated and reloaded on every run.

**Reasoning**:
- Source files are static CSV exports for this project, with no reliable "last modified" or change-tracking column.
- Full load guarantees consistency and avoids the complexity of merge/upsert logic for a dataset of this size.

**Trade-off accepted**: This approach does not scale efficiently to very large or frequently-updated source systems. In a production environment with millions of daily transactions, an incremental load strategy (using `MERGE` or CDC) would be preferred.

---

## ADR 003: Views for the Gold Layer instead of Materialized Tables

**Decision**: Gold layer objects (`dim_customers`, `dim_products`, `fact_sales`) are implemented as views, not physical tables.

**Reasoning**:
- Always reflects the latest Silver layer data with no separate load step or scheduling needed.
- Simpler to maintain for a project of this scale, no risk of the Gold layer becoming stale relative to Silver.

**Trade-off accepted**: Every query against Gold re-computes joins live. For very large fact tables or heavy concurrent reporting load, materializing these as indexed tables (or indexed views) would improve query performance.

---

## ADR 004: Surrogate Keys Generated with ROW_NUMBER()

**Decision**: `customer_key` and `product_key` are generated using `ROW_NUMBER() OVER (ORDER BY ...)` rather than reusing source system IDs directly.

**Reasoning**:
- Decouples the warehouse's internal keys from any single source system, which matters since customer and product data is integrated from two systems (CRM and ERP).
- Standard Star Schema practice: fact tables should join on warehouse-generated surrogate keys, not business or source keys.

**Trade-off accepted**: Surrogate keys are not stable across full reloads if the underlying row order changes (e.g., new customers inserted out of ID order). For this project's scope (static, full-refresh CSVs) this is acceptable; a production system would use a persistent key-generation strategy (e.g., an identity table) to keep keys stable across loads.

---

## ADR 005: CRM as Master Source for Overlapping Attributes

**Decision**: Where CRM and ERP both provide a value for the same customer attribute (currently: gender), CRM's value takes precedence, and ERP is used only to fill gaps.

**Reasoning**:
- CRM is the system of record for direct customer interaction and was assessed to have more complete, better-maintained data for this attribute.
- Establishes a clear, documented tie-breaking rule instead of leaving overlapping source conflicts to be resolved ad hoc at query time.

---

## ADR 006: Business Rule Validation for Sales Amount

**Decision**: In the Silver layer, `sales_amount` is recalculated as `quantity * ABS(price)` whenever the source value is missing, zero, negative, or inconsistent with `quantity * price`.

**Reasoning**:
- Source sales data contained rows where the reported sales amount didn't match the arithmetic of quantity and price, a common real-world data quality issue.
- Enforcing this rule in Silver, rather than leaving it to reporting tools, ensures every consumer of the Gold layer sees the same corrected number.
