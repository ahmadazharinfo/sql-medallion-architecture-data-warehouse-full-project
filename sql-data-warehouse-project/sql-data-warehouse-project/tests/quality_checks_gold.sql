/*
==============================================================================
Quality Checks: Gold Layer
==============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity,
    consistency, and accuracy of the Gold layer. It checks for:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Run these checks after building the Gold layer views.
    - Investigate and resolve any discrepancies found by these queries.
==============================================================================
*/

-- ============================================================================
-- Checking 'gold.dim_customers'
-- ============================================================================
-- Check for uniqueness of customer_key
-- Expectation: No Results
SELECT
    customer_key,
    COUNT(*)
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ============================================================================
-- Checking 'gold.dim_products'
-- ============================================================================
-- Check for uniqueness of product_key
-- Expectation: No Results
SELECT
    product_key,
    COUNT(*)
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ============================================================================
-- Checking 'gold.fact_sales'
-- ============================================================================
-- Check the data model connectivity between fact and dimensions
-- Expectation: No Results (every fact row must resolve to a valid customer
-- and product)
SELECT
    f.order_number,
    f.customer_key,
    f.product_key
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
WHERE c.customer_key IS NULL
   OR p.product_key IS NULL;
