/*
==============================================================================
Quality Checks: Silver Layer
==============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity,
    consistency, and accuracy of the Silver layer. It checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after executing 'proc_load_silver.sql'.
    - Investigate and resolve any discrepancies found by these queries.
==============================================================================
*/

-- ============================================================================
-- Checking 'silver.crm_cust_info'
-- ============================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces in string fields
-- Expectation: No Results
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Check data standardization and consistency for marital status and gender
-- Expectation: Only expected values ('Single', 'Married', 'n/a' / 'Male', 'Female', 'n/a')
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

-- ============================================================================
-- Checking 'silver.crm_prd_info'
-- ============================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted spaces in product name
-- Expectation: No Results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or negative values in cost
-- Expectation: No Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Check data standardization and consistency for product line
-- Expectation: Only expected values ('Mountain', 'Road', 'Other Sales', 'Touring', 'n/a')
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check for invalid date orders (start date after end date)
-- Expectation: No Results
SELECT *
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;

-- ============================================================================
-- Checking 'silver.crm_sales_details'
-- ============================================================================
-- Check for invalid dates (order date after ship date or due date)
-- Expectation: No Results
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

-- Check data consistency: sales = quantity * price, and no NULLs/negatives
-- Expectation: No Results
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0;

-- ============================================================================
-- Checking 'silver.erp_cust_az12'
-- ============================================================================
-- Check for out-of-range birthdates
-- Expectation: Birthdates between 1924-01-01 and today
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();

-- Check data standardization and consistency for gender
-- Expectation: Only expected values ('Male', 'Female', 'n/a')
SELECT DISTINCT gen
FROM silver.erp_cust_az12;

-- ============================================================================
-- Checking 'silver.erp_loc_a101'
-- ============================================================================
-- Check data standardization and consistency for country
-- Expectation: Only expected values (e.g., 'Germany', 'United States', 'n/a')
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ============================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ============================================================================
-- Check for unwanted spaces in category fields
-- Expectation: No Results
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

-- Check data standardization and consistency for maintenance
-- Expectation: Only expected values ('Yes', 'No')
SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2;
