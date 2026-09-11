/*

Project: Uganda Manufacturing Business Performance Analysis — 2025 Survey
File: uganda_manufacturing_2025_Analysis.sql
Database: uganda_manufacturing_2025
Table: manufacturing_clean
SQL: MySQL 8+

Purpose:
Reproduce and validate the core Excel findings for three business questions.

Performance definition:
- Primary measure: Sales CAGR, FY2022–FY2024
- High Growth: top quartile of valid Sales CAGR
- Low Growth: bottom quartile of valid Sales CAGR

Interpretation:
The survey is observational. Results show associations, not causation.

*/


USE uganda_manufacturing_2025;


/*
BUSINESS QUESTION 1: What factors distinguish higher-performing manufacturers?
==============================================================================*/

/* 1.1 Average performance profile */

SELECT
    Performance_Group,
    COUNT(*) AS establishments,
    ROUND(AVG(Sales_CAGR_2022_2024_Pct), 2) AS avg_sales_cagr_pct,
    ROUND(AVG(Employment_Growth_2022_2024_Pct), 2) AS avg_employment_growth_pct,
    ROUND(AVG(Capacity_Utilization_Pct), 2) AS avg_capacity_utilization_pct,
    ROUND(AVG(Sales_per_Employee_UGX), 0) AS avg_sales_per_employee_ugx,
    ROUND(AVG(Establishment_Age_Years), 1) AS avg_firm_age_years,
    ROUND(AVG(Manager_Experience_Years), 1) AS avg_manager_experience_years
FROM manufacturing_clean
WHERE Performance_Group IN ('High Growth', 'Low Growth')
GROUP BY Performance_Group
ORDER BY Performance_Group;


/* 1.2 Median performance profile */

WITH metrics AS (
    SELECT Performance_Group, 'Sales CAGR (%)' AS Metric,
           Sales_CAGR_2022_2024_Pct AS Metric_Value
    FROM manufacturing_clean
    WHERE Performance_Group IN ('High Growth', 'Low Growth')
      AND Sales_CAGR_2022_2024_Pct IS NOT NULL

    UNION ALL
    SELECT Performance_Group, 'Employment Growth (%)',
           Employment_Growth_2022_2024_Pct
    FROM manufacturing_clean
    WHERE Performance_Group IN ('High Growth', 'Low Growth')
      AND Employment_Growth_2022_2024_Pct IS NOT NULL

    UNION ALL
    SELECT Performance_Group, 'Capacity Utilization (%)',
           Capacity_Utilization_Pct
    FROM manufacturing_clean
    WHERE Performance_Group IN ('High Growth', 'Low Growth')
      AND Capacity_Utilization_Pct IS NOT NULL

    UNION ALL
    SELECT Performance_Group, 'Sales per Employee (UGX)',
           Sales_per_Employee_UGX
    FROM manufacturing_clean
    WHERE Performance_Group IN ('High Growth', 'Low Growth')
      AND Sales_per_Employee_UGX IS NOT NULL

    UNION ALL
    SELECT Performance_Group, 'Firm Age (Years)',
           Establishment_Age_Years
    FROM manufacturing_clean
    WHERE Performance_Group IN ('High Growth', 'Low Growth')
      AND Establishment_Age_Years IS NOT NULL

    UNION ALL
    SELECT Performance_Group, 'Manager Experience (Years)',
           Manager_Experience_Years
    FROM manufacturing_clean
    WHERE Performance_Group IN ('High Growth', 'Low Growth')
      AND Manager_Experience_Years IS NOT NULL
),
ranked AS (
    SELECT
        Performance_Group,
        Metric,
        Metric_Value,
        ROW_NUMBER() OVER (
            PARTITION BY Performance_Group, Metric
            ORDER BY Metric_Value
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY Performance_Group, Metric
        ) AS total_rows
    FROM metrics
)
SELECT
    Metric,
    Performance_Group,
    ROUND(AVG(Metric_Value), 2) AS median_value
FROM ranked
WHERE row_num IN (
    FLOOR((total_rows + 1) / 2),
    FLOOR((total_rows + 2) / 2)
)
GROUP BY Metric, Performance_Group
ORDER BY Metric, Performance_Group;


/* 1.3 Performance by firm size */

SELECT
    Size_Category,
    COUNT(*) AS total_firms,
    SUM(Performance_Group = 'High Growth') AS high_growth_firms,
    SUM(Performance_Group = 'Low Growth') AS low_growth_firms,
    ROUND(100.0 * SUM(Performance_Group = 'High Growth') / COUNT(*), 1)
        AS high_growth_pct,
    ROUND(100.0 * SUM(Performance_Group = 'Low Growth') / COUNT(*), 1)
        AS low_growth_pct
FROM manufacturing_clean
GROUP BY Size_Category
ORDER BY high_growth_pct DESC;


/* 1.4 Performance by region */

SELECT
    Region,
    COUNT(*) AS total_firms,
    SUM(Performance_Group = 'High Growth') AS high_growth_firms,
    SUM(Performance_Group = 'Low Growth') AS low_growth_firms,
    ROUND(100.0 * SUM(Performance_Group = 'High Growth') / COUNT(*), 1)
        AS high_growth_pct,
    ROUND(100.0 * SUM(Performance_Group = 'Low Growth') / COUNT(*), 1)
        AS low_growth_pct
FROM manufacturing_clean
GROUP BY Region
ORDER BY high_growth_pct DESC;



/*
BUSINESS QUESTION 2: How do financing and investment patterns relate to performance?
==============================================================================*/

/* 2.1 Average working-capital financing patterns */

SELECT
    Performance_Group,
    COUNT(*) AS establishments,
    ROUND(AVG(Working_Capital_Internal_Pct), 1) AS avg_internal_financing_pct,
    ROUND(AVG(Working_Capital_Bank_Pct), 1) AS avg_bank_financing_pct,
    ROUND(AVG(Working_Capital_Supplier_Credit_Pct), 1) AS avg_supplier_credit_pct
FROM manufacturing_clean
WHERE Performance_Group IN ('High Growth', 'Low Growth')
GROUP BY Performance_Group
ORDER BY Performance_Group;


/* 2.2 Loan ownership and fixed-asset purchasing */

SELECT
    Performance_Group,
    COUNT(*) AS establishments,
    SUM(Has_Financial_Institution_Loan = 'Yes') AS firms_with_loan,
    ROUND(
        100.0 * SUM(Has_Financial_Institution_Loan = 'Yes')
        / COUNT(Has_Financial_Institution_Loan),
        1
    ) AS firms_with_loan_pct,
    SUM(Purchased_Fixed_Assets = 'Yes') AS fixed_asset_purchasers,
    ROUND(
        100.0 * SUM(Purchased_Fixed_Assets = 'Yes')
        / COUNT(Purchased_Fixed_Assets),
        1
    ) AS fixed_asset_purchasers_pct
FROM manufacturing_clean
WHERE Performance_Group IN ('High Growth', 'Low Growth')
GROUP BY Performance_Group
ORDER BY Performance_Group;


/* 2.3 Number of actual fixed-asset investors */

SELECT
    Performance_Group,
    COUNT(*) AS investing_firms
FROM manufacturing_clean
WHERE Performance_Group IN ('High Growth', 'Low Growth')
  AND Purchased_Fixed_Assets = 'Yes'
GROUP BY Performance_Group
ORDER BY Performance_Group;


/* 2.4 Median equipment investment among actual investors */

WITH investment_metrics AS (
    SELECT
        Performance_Group,
        'Equipment Investment UGX' AS Metric,
        Equipment_Investment_UGX AS Metric_Value
    FROM manufacturing_clean
    WHERE Performance_Group IN ('High Growth', 'Low Growth')
      AND Purchased_Fixed_Assets = 'Yes'
      AND Equipment_Investment_UGX IS NOT NULL

    UNION ALL

    SELECT
        Performance_Group,
        'Investment % of Sales',
        Equipment_Investment_Pct_of_Sales
    FROM manufacturing_clean
    WHERE Performance_Group IN ('High Growth', 'Low Growth')
      AND Purchased_Fixed_Assets = 'Yes'
      AND Equipment_Investment_Pct_of_Sales IS NOT NULL
),
ranked AS (
    SELECT
        Performance_Group,
        Metric,
        Metric_Value,
        ROW_NUMBER() OVER (
            PARTITION BY Performance_Group, Metric
            ORDER BY Metric_Value
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY Performance_Group, Metric
        ) AS total_rows
    FROM investment_metrics
)
SELECT
    Metric,
    Performance_Group,
    ROUND(AVG(Metric_Value), 2) AS median_value
FROM ranked
WHERE row_num IN (
    FLOOR((total_rows + 1) / 2),
    FLOOR((total_rows + 2) / 2)
)
GROUP BY Metric, Performance_Group
ORDER BY Metric, Performance_Group;


/* 2.5 Loan ownership among actual investors */

SELECT
    Performance_Group,
    COUNT(*) AS investing_firms,
    SUM(Has_Financial_Institution_Loan = 'Yes') AS investors_with_loan,
    ROUND(
        100.0 * SUM(Has_Financial_Institution_Loan = 'Yes')
        / COUNT(Has_Financial_Institution_Loan),
        1
    ) AS investors_with_loan_pct
FROM manufacturing_clean
WHERE Performance_Group IN ('High Growth', 'Low Growth')
  AND Purchased_Fixed_Assets = 'Yes'
GROUP BY Performance_Group
ORDER BY Performance_Group;



/*
BUSINESS QUESTION 3: Which operational constraints are most associated with weaker performance?
==============================================================================*/

/* 3.1 Major / Very Severe operational constraint rates */

SELECT
    Performance_Group,
    ROUND(
        100.0 * SUM(
            Electricity_Obstacle IN ('Major obstacle', 'Very severe obstacle')
        ) / COUNT(Electricity_Obstacle),
        1
    ) AS electricity_severe_pct,
    ROUND(
        100.0 * SUM(
            Access_to_Finance_Obstacle IN ('Major obstacle', 'Very severe obstacle')
        ) / COUNT(Access_to_Finance_Obstacle),
        1
    ) AS finance_severe_pct,
    ROUND(
        100.0 * SUM(
            Workforce_Skills_Obstacle IN ('Major obstacle', 'Very severe obstacle')
        ) / COUNT(Workforce_Skills_Obstacle),
        1
    ) AS workforce_skills_severe_pct,
    ROUND(
        100.0 * SUM(
            Informal_Competition_Obstacle IN ('Major obstacle', 'Very severe obstacle')
        ) / COUNT(Informal_Competition_Obstacle),
        1
    ) AS informal_competition_severe_pct
FROM manufacturing_clean
WHERE Performance_Group IN ('High Growth', 'Low Growth')
GROUP BY Performance_Group
ORDER BY Performance_Group;


/* 3.2 Power outage exposure */

SELECT
    Performance_Group,
    COUNT(*) AS establishments,
    SUM(Experienced_Power_Outages = 'Yes') AS firms_with_outages,
    ROUND(
        100.0 * SUM(Experienced_Power_Outages = 'Yes')
        / COUNT(Experienced_Power_Outages),
        1
    ) AS outage_exposure_pct,
    ROUND(AVG(Power_Outages_Per_Month), 2) AS avg_outages_per_month
FROM manufacturing_clean
WHERE Performance_Group IN ('High Growth', 'Low Growth')
GROUP BY Performance_Group
ORDER BY Performance_Group;


/* 3.3 Median monthly power outages */

WITH outage_data AS (
    SELECT
        Performance_Group,
        Power_Outages_Per_Month,
        ROW_NUMBER() OVER (
            PARTITION BY Performance_Group
            ORDER BY Power_Outages_Per_Month
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY Performance_Group
        ) AS total_rows
    FROM manufacturing_clean
    WHERE Performance_Group IN ('High Growth', 'Low Growth')
      AND Power_Outages_Per_Month IS NOT NULL
)
SELECT
    Performance_Group,
    ROUND(AVG(Power_Outages_Per_Month), 2) AS median_outages_per_month
FROM outage_data
WHERE row_num IN (
    FLOOR((total_rows + 1) / 2),
    FLOOR((total_rows + 2) / 2)
)
GROUP BY Performance_Group
ORDER BY Performance_Group;


/* 3.4 Median outages among affected firms only */

WITH affected_firms AS (
    SELECT
        Performance_Group,
        Power_Outages_Per_Month,
        ROW_NUMBER() OVER (
            PARTITION BY Performance_Group
            ORDER BY Power_Outages_Per_Month
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY Performance_Group
        ) AS total_rows
    FROM manufacturing_clean
    WHERE Performance_Group IN ('High Growth', 'Low Growth')
      AND Experienced_Power_Outages = 'Yes'
      AND Power_Outages_Per_Month IS NOT NULL
)
SELECT
    Performance_Group,
    ROUND(AVG(Power_Outages_Per_Month), 2) AS median_outages_among_affected
FROM affected_firms
WHERE row_num IN (
    FLOOR((total_rows + 1) / 2),
    FLOOR((total_rows + 2) / 2)
)
GROUP BY Performance_Group
ORDER BY Performance_Group;


/* 3.5 Single biggest obstacle by performance group */

SELECT
    Performance_Group,
    Biggest_Obstacle,
    COUNT(*) AS establishments,
    ROUND(
        100.0 * COUNT(*)
        / SUM(COUNT(*)) OVER (PARTITION BY Performance_Group),
        1
    ) AS pct_of_growth_group
FROM manufacturing_clean
WHERE Performance_Group IN ('High Growth', 'Low Growth')
  AND Biggest_Obstacle IS NOT NULL
GROUP BY Performance_Group, Biggest_Obstacle
ORDER BY Performance_Group, pct_of_growth_group DESC;


/* 3.6 Focused electricity comparison */

SELECT
    Performance_Group,
    ROUND(
        100.0 * SUM(Experienced_Power_Outages = 'Yes')
        / COUNT(Experienced_Power_Outages),
        1
    ) AS experienced_outages_pct,
    ROUND(
        100.0 * SUM(
            Electricity_Obstacle IN ('Major obstacle', 'Very severe obstacle')
        ) / COUNT(Electricity_Obstacle),
        1
    ) AS severe_electricity_obstacle_pct,
    ROUND(
        100.0 * SUM(Biggest_Obstacle = 'Electricity')
        / COUNT(Biggest_Obstacle),
        1
    ) AS electricity_biggest_obstacle_pct
FROM manufacturing_clean
WHERE Performance_Group IN ('High Growth', 'Low Growth')
GROUP BY Performance_Group
ORDER BY Performance_Group;


/* END OF ANALYSIS 
==============================================================================*/
