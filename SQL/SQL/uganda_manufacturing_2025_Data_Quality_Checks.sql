/*
Project: Uganda Manufacturing Business Performance Analysis — 2025 Survey
File: uganda_manufacturing_2025_Data_Quality_Checks.sql
Database: uganda_manufacturing_2025
Table: manufacturing_clean
SQL: MySQL 8+

Purpose:
Validate the cleaned manufacturing dataset before analysis.

Expected:
- 217 total establishments
- 186 valid Sales CAGR records
- 31 missing Sales CAGR records
- Performance groups: High Growth 47, Low Growth 47, Middle 92, Missing 31

Notes:
- Percentage fields are stored as percentage points (e.g. 15.5 = 15.5%).
- Missing numeric values should be SQL NULL.
*/


/*
1. CREATE PROJECT DATABASE
==============================================================================*/

CREATE DATABASE IF NOT EXISTS uganda_manufacturing_2025
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE uganda_manufacturing_2025;


/*
2. CREATE CLEAN MANUFACTURING TABLE

DROP TABLE is included so the setup can be rerun during development.
Do not run this after analysis unless you intend to recreate the table.
*/

DROP TABLE IF EXISTS manufacturing_clean;

CREATE TABLE manufacturing_clean (

    Establishment_ID INT PRIMARY KEY,

    Region VARCHAR(20) NOT NULL,
    Size_Category VARCHAR(10) NOT NULL,
    Screener_Employees INT NOT NULL,

    ISIC_Rev4_Code INT NOT NULL,
    ISIC_Division TINYINT NOT NULL,
    Manufacturing_Subsector VARCHAR(120) NOT NULL,

    Year_Started SMALLINT NULL,
    Manager_Experience_Years DECIMAL(6,1) NULL,
    Survey_Weight_Median DECIMAL(15,6) NOT NULL,

    Annual_Sales_2024_UGX BIGINT NULL,
    Annual_Sales_2022_UGX BIGINT NULL,
    Capacity_Utilization_Pct DECIMAL(6,2) NULL,

    Permanent_FT_Employees_2024 INT NOT NULL,
    Permanent_FT_Employees_2022 INT NULL,

    Labor_Cost_2024_UGX BIGINT NULL,
    Raw_Materials_Cost_2024_UGX BIGINT NULL,
    Machinery_Replacement_Value_UGX BIGINT NULL,

    Direct_Exports_Pct DECIMAL(6,2) NOT NULL,

    Monitors_Performance_Indicators VARCHAR(80) NOT NULL,
    Introduced_New_Product_Service VARCHAR(3) NOT NULL,
    Introduced_Improved_Process VARCHAR(3) NOT NULL,

    Working_Capital_Internal_Pct DECIMAL(6,2) NULL,
    Working_Capital_Bank_Pct DECIMAL(6,2) NULL,
    Working_Capital_Supplier_Credit_Pct DECIMAL(6,2) NULL,

    Purchased_Fixed_Assets VARCHAR(3) NOT NULL,
    Equipment_Investment_Raw_UGX BIGINT NULL,

    Has_Financial_Institution_Loan VARCHAR(3) NULL,
    Applied_For_Loan_2024 VARCHAR(3) NOT NULL,

    Experienced_Power_Outages VARCHAR(3) NULL,
    Power_Outages_Per_Month_Raw DECIMAL(8,2) NULL,

    Electricity_Obstacle VARCHAR(30) NULL,
    Access_to_Finance_Obstacle VARCHAR(30) NULL,
    Workforce_Skills_Obstacle VARCHAR(30) NOT NULL,
    Informal_Competition_Obstacle VARCHAR(30) NULL,
    Biggest_Obstacle VARCHAR(100) NULL,

    Figures_Response_Quality VARCHAR(100) NOT NULL,

    Establishment_Age_Years DECIMAL(6,1) NULL,
    Equipment_Investment_UGX BIGINT NOT NULL,
    Power_Outages_Per_Month DECIMAL(8,2) NULL,

    Direct_Exporter VARCHAR(3) NOT NULL,

    Sales_Growth_2022_2024_Pct DECIMAL(12,4) NULL,
    Sales_CAGR_2022_2024_Pct DECIMAL(12,4) NULL,
    Employment_Growth_2022_2024_Pct DECIMAL(12,4) NULL,

    Sales_per_Employee_UGX BIGINT NULL,

    Labor_Cost_Pct_of_Sales DECIMAL(12,4) NULL,
    Raw_Materials_Cost_Pct_of_Sales DECIMAL(12,4) NULL,

    Machinery_Value_per_Employee_UGX BIGINT NULL,
    Equipment_Investment_Pct_of_Sales DECIMAL(12,4) NULL,

    Sales_Outlier_Flag VARCHAR(10) NOT NULL,
    Firm_Age_Band VARCHAR(20) NOT NULL,
    Performance_Group VARCHAR(20) NOT NULL

);


/*
3. CONFIRM DATABASE AND TABLE CREATION
*/

SELECT DATABASE() AS active_database;

SHOW TABLES;


/*
7. QUICK IMPORT CONFIRMATION

Run this AFTER importing the CSV.
Expected result: 217
*/

SELECT
    COUNT(*) AS imported_rows
FROM manufacturing_clean;


/*
END OF DATABASE SETUP
==============================================================================*/




/* DATA QUALITY CHECKS 
===============================================================================*/


USE uganda_manufacturing_2025;


/* 1. TOTAL ROW COUNT — expected 217 */
SELECT
    COUNT(*) AS total_rows
FROM manufacturing_clean;


/* 2. DUPLICATE ESTABLISHMENT IDs — expected no rows */
SELECT
    Establishment_ID,
    COUNT(*) AS duplicate_count
FROM manufacturing_clean
GROUP BY Establishment_ID
HAVING COUNT(*) > 1;


/* 3. SALES CAGR COMPLETENESS — expected 217 / 186 / 31 */
SELECT
    COUNT(*) AS total_rows,
    COUNT(Sales_CAGR_2022_2024_Pct) AS valid_cagr,
    SUM(Sales_CAGR_2022_2024_Pct IS NULL) AS missing_cagr
FROM manufacturing_clean;


/* 4. PERFORMANCE GROUP DISTRIBUTION */
SELECT
    Performance_Group,
    COUNT(*) AS establishments
FROM manufacturing_clean
GROUP BY Performance_Group
ORDER BY establishments DESC;


/* 5. NULL IMPORT CHECK FOR STRUCTURALLY MISSING NUMERIC FIELDS */
SELECT
    SUM(Equipment_Investment_Raw_UGX IS NULL) AS null_equipment_investment_raw,
    SUM(Power_Outages_Per_Month_Raw IS NULL) AS null_power_outages_raw
FROM manufacturing_clean;


/* 6. PERCENTAGE FIELD IMPORT SPOT CHECK
   Values should be percentage points, not fractions.
*/
SELECT
    Establishment_ID,
    Sales_CAGR_2022_2024_Pct,
    Employment_Growth_2022_2024_Pct,
    Equipment_Investment_Pct_of_Sales
FROM manufacturing_clean
LIMIT 10;


/* END OF DATA QUALITY CHECKS 
==============================================================================*/
