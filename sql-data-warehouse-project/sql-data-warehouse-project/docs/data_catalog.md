# Data Catalog for Gold Layer

## Overview

The Gold layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of **dimension tables** and **fact tables** for specific business metrics, following a Star Schema model.

---

## 1. gold.dim_customers

**Purpose**: Stores customer details enriched with demographic and geographic data, combining the CRM system (master source) with ERP supplementary attributes.

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-------------------------------------------------------------------------------------------------|
| customer_key    | INT           | Surrogate key uniquely identifying each customer record in the Gold layer.                     |
| customer_id     | INT           | Original customer identifier from the CRM system.                                              |
| customer_number | NVARCHAR(50)  | Alphanumeric business key used to track and reference the customer across systems.             |
| first_name      | NVARCHAR(50)  | Customer's first name, as recorded in the CRM system.                                          |
| last_name       | NVARCHAR(50)  | Customer's last name, as recorded in the CRM system.                                           |
| country         | NVARCHAR(50)  | Customer's country of residence (e.g., 'Australia', 'Germany'), sourced from the ERP system.     |
| marital_status  | NVARCHAR(50)  | Customer's marital status (e.g., 'Married', 'Single').                                          |
| gender          | NVARCHAR(50)  | Customer's gender (e.g., 'Male', 'Female', 'n/a'). CRM is the master source; ERP fills gaps.    |
| birthdate       | DATE          | Customer's date of birth, sourced from the ERP system.                                          |
| create_date     | DATE          | Date the customer record was first created in the source CRM system.                            |

---

## 2. gold.dim_products

**Purpose**: Provides current, active product information enriched with category and subcategory details from the ERP system. Historical/inactive product versions are excluded.

| Column Name     | Data Type     | Description                                                                                    |
|-----------------|---------------|--------------------------------------------------------------------------------------------------|
| product_key     | INT           | Surrogate key uniquely identifying each product record in the Gold layer.                       |
| product_id      | INT           | Original product identifier from the CRM system.                                                |
| product_number  | NVARCHAR(50)  | Alphanumeric code identifying the product, used for categorization or inventory tracking.        |
| product_name    | NVARCHAR(50)  | Descriptive name of the product, including key details such as type or color.                    |
| category_id     | NVARCHAR(50)  | Identifier linking the product to its high-level category.                                       |
| category        | NVARCHAR(50)  | Broader classification of the product (e.g., Bikes, Components) from the ERP system.             |
| subcategory     | NVARCHAR(50)  | More detailed classification within the category.                                                |
| maintenance     | NVARCHAR(50)  | Indicates whether the product requires maintenance (e.g., 'Yes', 'No').                          |
| cost            | INT           | Cost or base price of the product, measured in whole currency units.                             |
| product_line    | NVARCHAR(50)  | Product line or series (e.g., 'Road', 'Mountain', 'Touring', 'Other Sales').                     |
| start_date      | DATE          | Date the product became available for sale.                                                      |

---

## 3. gold.fact_sales

**Purpose**: Stores transactional sales data, connecting the customer and product dimensions for business intelligence and reporting.

| Column Name  | Data Type     | Description                                                                            |
|--------------|---------------|------------------------------------------------------------------------------------------|
| order_number | NVARCHAR(50)  | Unique identifier for each sales order (e.g., 'SO54496').                               |
| product_key  | INT           | Surrogate key linking to `gold.dim_products.product_key`.                                |
| customer_key | INT           | Surrogate key linking to `gold.dim_customers.customer_key`.                              |
| order_date   | DATE          | Date the order was placed.                                                               |
| shipping_date| DATE          | Date the order was shipped to the customer.                                              |
| due_date     | DATE          | Date the order payment was due.                                                          |
| sales_amount | INT           | Total value of the sale for the line item, in whole currency units.                      |
| quantity     | INT           | Quantity of units ordered for the line item.                                             |
| price        | INT           | Unit price of the product for the line item, in whole currency units.                    |

---

## Notes

- All Gold layer objects are **views**, not physical tables. They are always queried live against the Silver layer and require no separate load step.
- Surrogate keys (`customer_key`, `product_key`) exist only in the Gold layer and are generated using `ROW_NUMBER()`. They should be used for all joins between `gold.fact_sales` and its dimension tables.
- `gold.dim_products` only includes currently active products (`prd_end_dt IS NULL` in the Silver source). Historical product versions are intentionally excluded from reporting.
