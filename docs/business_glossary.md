# Business Glossary

## Purpose

Defines business terms used throughout the warehouse in plain language, so that technical and non-technical stakeholders share a common understanding of what each term means. This is the kind of reference a BI Analyst maintains alongside a data dictionary, since column names describe structure, but a glossary describes meaning.

---

| Term              | Definition                                                                                                   |
|--------------------|-----------------------------------------------------------------------------------------------------------------|
| Customer           | An individual who has placed at least one order, tracked across both the CRM and ERP systems using a shared customer number. |
| Customer Number    | The business key used to uniquely identify a customer across systems (CRM `cst_key`, ERP `cid`). Not to be confused with the internal `customer_id`. |
| Master Source      | The system treated as authoritative for a given attribute when two sources disagree. CRM is the master source for gender; ERP supplements missing values. |
| Product            | An item that can be ordered by a customer, uniquely identified by its product number and current category classification. |
| Active Product     | A product whose Silver-layer `prd_end_dt` is NULL, meaning it is the current version and the only one exposed in the Gold layer. |
| Category           | The top-level classification of a product (e.g., Bikes, Components), sourced from the ERP product category reference table. |
| Product Line       | A CRM-specific classification of a product (Mountain, Road, Touring, Other Sales), distinct from Category. |
| Order              | A single sales transaction, identified by an order number, which may include one or more line items (rows in `fact_sales`). |
| Sales Amount       | The total monetary value of a line item, expected to equal quantity multiplied by price. Recalculated in the Silver layer if the source value is missing or inconsistent. |
| Surrogate Key      | A warehouse-generated identifier (e.g., `customer_key`, `product_key`) used to join fact and dimension tables. Has no meaning outside this warehouse and should never be shown to business users directly. |
| Business Key       | An identifier that originates from a source system and has meaning outside the warehouse (e.g., `customer_number`, `product_number`). |
| n/a                | A standardized placeholder value used across the warehouse to represent missing, unknown, or unmapped categorical data (e.g., gender, marital status, country), instead of leaving the field NULL or blank. |
| Bronze Layer       | The raw landing zone for source data, unmodified from the original CSV export. |
| Silver Layer       | The cleaned and standardized layer where business rules, deduplication, and data quality fixes are applied. |
| Gold Layer         | The final, business-ready layer, modeled as a Star Schema and exposed as views for reporting tools. |
| Star Schema        | A data modeling pattern with a central fact table (`fact_sales`) connected to surrounding dimension tables (`dim_customers`, `dim_products`) via surrogate keys. |
