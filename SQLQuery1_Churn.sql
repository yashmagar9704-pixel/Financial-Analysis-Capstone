CREATE DATABASE CUSTOMER_CHURN;
USE CUSTOMER_CHURN;

select * from Telco;

--NUMBER OF RECORDS
SELECT COUNT(*) as Total_count FROM Telco;
--7043

--COUNT OF CUSTOMERS CHURNED
SELECT
    COUNT(*) AS TOTALCUST,
    SUM(CHURN_VALUE) AS CHURNEDCUSTOMERS,
    SUM(CHURN_VALUE) * 100.0 / COUNT(*) AS CHURN_RATE
FROM TELCO;
--TOTALCUST    CHURNEDCUST    CHURN_RATE
--  7043         1869         26.536987079369

--GENDER WISE CHURNED CUSTOMERS COUNT
SELECT COUNT(*) as GENDER_WISE_CHURNED_CUSTOMER_COUNT FROM Telco WHERE Churn_Label='YES'
GROUP BY Gender;
--930

/*
Top Revenue Customers
Revenue Percentile Groups
Top Churned Cities
*/

SELECT TOP 10 *
FROM TELCO
ORDER BY Monthly_Charges DESC;

SELECT column1, CustomerID
FROM TELCO;

Alter Table Telco
DROP COLUMN COLUMN_1

--Advanced SQL Analysis Using Window Functions

-- ROW_NUMBER() Rank customers by monthly charges-
SELECT
    CustomerID,
    Monthly_Charges,
    ROW_NUMBER() OVER (
        ORDER BY Monthly_Charges DESC
    ) AS Row_Num
FROM Telco;

--RANK() – Rank customers by monthly charges
SELECT
    CustomerID,
    Monthly_Charges,
    RANK() OVER (
        ORDER BY Monthly_Charges DESC
    ) AS Customer_Rank
FROM Telco;

--DENSE_RANK() – Dense ranking of customer
SELECT
    CustomerID,
    Monthly_Charges,
    DENSE_RANK() OVER (
        ORDER BY Monthly_Charges DESC
    ) AS Dense_Rank
FROM Telco;

--LAG() – Compare with the previous customer
SELECT
    CustomerID,
    Monthly_Charges,
    LAG(Monthly_Charges) OVER (
        ORDER BY Monthly_Charges DESC, CustomerID
    ) AS Previous_Charges
FROM Telco;

--LEAD() – Compare with the next customer
SELECT
    CustomerID,
    Monthly_Charges,
    LEAD(Monthly_Charges) OVER (
        ORDER BY Monthly_Charges DESC, CustomerID
    ) AS Next_Charges
FROM Telco;

--NTILE() – Divide customers into four groups
SELECT
    CustomerID,
    Monthly_Charges,
    NTILE(4) OVER (
        ORDER BY Monthly_Charges DESC
    ) AS Revenue_Group
FROM Telco;

--Customer Segmentation Using SQL

SELECT
    CustomerID,
    Tenure_Months,
    Monthly_Charges,
    CLTV,
    CASE
        WHEN Tenure_Months >= 48
             AND CLTV >= 5000
             AND Monthly_Charges >= 80
            THEN 'Champions'

        WHEN Tenure_Months >= 24
             AND CLTV >= 3500
            THEN 'Loyal'

        WHEN Tenure_Months < 12
             AND Monthly_Charges >= 80
            THEN 'At Risk'

        ELSE 'Potential Churn'
    END AS Customer_Segment
FROM Telco;

--SQL Views – Customer Churn Analysis

CREATE VIEW vw_customer_Churn AS
SELECT
    CustomerID,
    Gender,
    City,
    Tenure_Months,
    Monthly_Charges,
    CLTV,
    Churn_Label,
    Churn_Value
FROM Telco;
GO

SELECT * FROM vw_customer_churn;

--vw_revenue_summary – Revenue summary and churn analysis.
CREATE VIEW vw_revenue_summary AS
SELECT
    COUNT(*) AS Total_Customers,
    SUM(Monthly_Charges) AS Total_Monthly_Charges,
    AVG(Monthly_Charges) AS Average_Monthly_Charges,
    SUM(CASE
        WHEN Churn_Value = 1 THEN Monthly_Charges
        ELSE 0
    END) AS Churned_Customer_Charges
FROM Telco;
GO

SELECT * FROM vw_revenue_summary;

--vw_city_performance – Customer and revenue performance by city.
CREATE VIEW vw_city_performance AS
SELECT
    City,
    COUNT(*) AS Total_Customers,
    SUM(Monthly_Charges) AS Total_Monthly_Charges,
    AVG(Monthly_Charges) AS Average_Monthly_Charges,
    SUM(Churn_Value) AS Churned_Customers,
    CAST(
        SUM(Churn_Value) * 100.0 / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Churn_Rate_Percent
FROM Telco
GROUP BY City;
GO

SELECT * FROM vw_city_performance;

--vw_retention_metrics – Customer retention and churn metrics.

CREATE VIEW vw_retention_metrics AS
SELECT
    COUNT(*) AS Total_Customers,

    SUM(CASE
        WHEN Churn_Value = 0 THEN 1
        ELSE 0
    END) AS Retained_Customers,

    SUM(CASE
        WHEN Churn_Value = 1 THEN 1
        ELSE 0
    END) AS Churned_Customers,

    CAST(
        SUM(CASE WHEN Churn_Value = 0 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Retention_Rate_Percent,

    CAST(
        SUM(Churn_Value) * 100.0 / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Churn_Rate_Percent

FROM Telco;
GO

SELECT * FROM vw_retention_metrics;

--Sp_daily_kpi_report – Daily KPI Report

CREATE OR ALTER PROCEDURE sp_daily_kpi_report
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CAST(GETDATE() AS DATE) AS Report_Date,
        COUNT(*) AS Total_Customers,
        SUM(Monthly_Charges) AS Total_Monthly_Charges,
        AVG(Monthly_Charges) AS Average_Monthly_Charges,
        SUM(CASE
            WHEN Churn_Value = 1 THEN 1
            ELSE 0
        END) AS Churned_Customers,
        CAST(
            SUM(CASE WHEN Churn_Value = 1 THEN 1 ELSE 0 END)
            * 100.0 / NULLIF(COUNT(*), 0)
            AS DECIMAL(10,2)
        ) AS Churn_Rate_Percent
    FROM Telco;
END;
GO

EXEC sp_daily_kpi_report;
