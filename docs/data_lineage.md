# Data Lineage

## Purpose

This document traces how data moves and transforms across the three layers of the warehouse, from the original source file down to the final Gold layer field. It is intended to answer the question every BI stakeholder eventually asks: *"Where did this number actually come from?"*

---

## Customer Lineage (gold.dim_customers)

| Gold Column      | Silver Source                          | Bronze Source                         | Original Source File      | Transformation Applied                                   |
|-------------------|------------------------------------------|-----------------------------------------|-----------------------------|--------------------------------------------------------------|
| customer_key      | Generated (ROW_NUMBER)                  | -                                        | -                            | Surrogate key generated in Gold layer only.                  |
| customer_id       | silver.crm_cust_info.cst_id             | bronze.crm_cust_info.cst_id             | cust_info.csv                | Deduplicated (kept latest by cst_create_date).                |
| customer_number   | silver.crm_cust_info.cst_key            | bronze.crm_cust_info.cst_key            | cust_info.csv                | None.                                                          |
| first_name        | silver.crm_cust_info.cst_firstname      | bronze.crm_cust_info.cst_firstname      | cust_info.csv                | Trimmed.                                                       |
| last_name         | silver.crm_cust_info.cst_lastname       | bronze.crm_cust_info.cst_lastname       | cust_info.csv                | Trimmed.                                                       |
| country           | silver.erp_loc_a101.cntry               | bronze.erp_loc_a101.cntry               | LOC_A101.csv                 | Standardized (DE -> Germany, US/USA -> United States).         |
| marital_status    | silver.crm_cust_info.cst_marital_status | bronze.crm_cust_info.cst_marital_status | cust_info.csv                | Standardized (S -> Single, M -> Married, else n/a).            |
| gender            | silver.crm_cust_info.cst_gndr + silver.erp_cust_az12.gen | bronze equivalents      | cust_info.csv, CUST_AZ12.csv | CRM treated as master; ERP fills gaps when CRM = n/a.          |
| birthdate         | silver.erp_cust_az12.bdate              | bronze.erp_cust_az12.bdate              | CUST_AZ12.csv                | Future dates nulled out.                                       |
| create_date       | silver.crm_cust_info.cst_create_date    | bronze.crm_cust_info.cst_create_date    | cust_info.csv                | None.                                                           |

---

## Product Lineage (gold.dim_products)

| Gold Column     | Silver Source                        | Bronze Source                         | Original Source File   | Transformation Applied                                       |
|-------------------|-----------------------------------------|------------------------------------------|---------------------------|--------------------------------------------------------------|
| product_key       | Generated (ROW_NUMBER)                 | -                                          | -                          | Surrogate key generated in Gold layer only.                   |
| product_id        | silver.crm_prd_info.prd_id             | bronze.crm_prd_info.prd_id               | prd_info.csv               | None.                                                          |
| category_id       | silver.crm_prd_info.cat_id             | bronze.crm_prd_info.prd_key (split)      | prd_info.csv               | First 5 characters of prd_key, '-' replaced with '_'.         |
| product_number    | silver.crm_prd_info.prd_key            | bronze.crm_prd_info.prd_key (split)      | prd_info.csv               | Remaining characters of prd_key after category prefix removed.|
| category/subcategory/maintenance | silver.erp_px_cat_g1v2 | bronze.erp_px_cat_g1v2 | PX_CAT_G1V2.csv | Joined via category_id = id. No transformation.                |
| cost              | silver.crm_prd_info.prd_cost           | bronze.crm_prd_info.prd_cost             | prd_info.csv               | NULLs replaced with 0.                                          |
| product_line      | silver.crm_prd_info.prd_line           | bronze.crm_prd_info.prd_line             | prd_info.csv               | Standardized (M/R/S/T mapped to full names).                   |
| start_date        | silver.crm_prd_info.prd_start_dt       | bronze.crm_prd_info.prd_start_dt         | prd_info.csv               | Cast from DATETIME to DATE.                                     |

**Note:** Only rows where `prd_end_dt IS NULL` in the Silver layer flow into Gold, meaning only the current, active version of each product appears in `gold.dim_products`.

---

## Sales Lineage (gold.fact_sales)

| Gold Column   | Silver Source                              | Bronze Source                            | Original Source File | Transformation Applied                                          |
|-----------------|-----------------------------------------------|---------------------------------------------|--------------------------|-----------------------------------------------------------------|
| order_number    | silver.crm_sales_details.sls_ord_num          | bronze.crm_sales_details.sls_ord_num        | sales_details.csv         | None.                                                             |
| product_key     | Resolved via gold.dim_products.product_number | bronze.crm_sales_details.sls_prd_key        | sales_details.csv         | Joined to dimension, not a direct copy.                           |
| customer_key    | Resolved via gold.dim_customers.customer_id   | bronze.crm_sales_details.sls_cust_id        | sales_details.csv         | Joined to dimension, not a direct copy.                           |
| order_date, shipping_date, due_date | silver.crm_sales_details | bronze.crm_sales_details (raw INT, YYYYMMDD) | sales_details.csv | Converted from 8-digit integer to DATE. Invalid values set to NULL. |
| sales_amount     | silver.crm_sales_details.sls_sales            | bronze.crm_sales_details.sls_sales          | sales_details.csv         | Recalculated as quantity * ABS(price) when inconsistent or missing. |
| quantity         | silver.crm_sales_details.sls_quantity         | bronze.crm_sales_details.sls_quantity       | sales_details.csv         | None.                                                             |
| price            | silver.crm_sales_details.sls_price            | bronze.crm_sales_details.sls_price          | sales_details.csv         | Recalculated as sales / quantity when missing or invalid.         |

---

## How to Read This Document

Trace any Gold layer number back one column at a time: Gold → Silver → Bronze → Source File. If a reported value ever looks wrong, this table tells you exactly which layer to inspect first, and which transformation rule to check against the source data.
