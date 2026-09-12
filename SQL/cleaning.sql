-- ============================================================
-- Blinkit Sales Analysis
-- File    : cleaning.sql
-- Purpose : Clean and validate raw blinkit data before analysis
-- ============================================================


-- Allow updates (disable safe mode) \\
SET SQL_SAFE_UPDATES = 0;


-- Standardize Item_Fat_Content 
UPDATE blinkit
SET Item_Fat_Content = CASE
    WHEN LOWER(TRIM(Item_Fat_Content)) IN ('lf', 'low fat') 
    THEN 'Low Fat'
    WHEN LOWER(TRIM(Item_Fat_Content)) IN ('reg', 'regular')
    THEN 'Regular'
    ELSE Item_Fat_Content
END;

-- Validate: should only see 'Low Fat' and 'Regular' after update
SELECT
    Item_Fat_Content,
    COUNT(*) AS total_count
FROM blinkit
GROUP BY Item_Fat_Content;

-- FIXED COLUMNS NAME 
ALTER TABLE blinkit 
RENAME COLUMN Outlet_dentifier TO Outlet_Identifier;

-- Show the actual duplicate rows (if any)
SELECT
    Item_Identifier,
    Outlet_Identifier,
    COUNT(*) AS occurrences
FROM blinkit
GROUP BY Item_Identifier, Outlet_Identifier
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;



-- Identify which columns have missing data and how many rows are affected
SELECT
    SUM(CASE WHEN Item_Fat_Content   IS NULL OR TRIM(Item_Fat_Content)   = '' THEN 1 ELSE 0 END) AS null_item_fat_content,
    SUM(CASE WHEN Item_Identifier   IS NULL OR TRIM(Item_Identifier)    = '' THEN 1 ELSE 0 END) AS null_item_identifier,
    SUM(CASE WHEN Item_Type         IS NULL OR TRIM(Item_Type)          = '' THEN 1 ELSE 0 END) AS null_item_type,
    SUM(CASE WHEN Outlet_Establishment_Year IS NULL                                THEN 1 ELSE 0 END) AS null_outlet_year,
    SUM(CASE WHEN Outlet_Identifier       IS NULL OR TRIM(Outlet_Identifier)  = '' THEN 1 ELSE 0 END) AS null_outlet_identifier,
    SUM(CASE WHEN Outlet_Location_Type    IS NULL OR TRIM(Outlet_Location_Type)='' THEN 1 ELSE 0 END) AS null_outlet_location,
    SUM(CASE WHEN Outlet_Size         IS NULL OR TRIM(Outlet_Size)        = '' THEN 1 ELSE 0 END) AS null_outlet_size,
    SUM(CASE WHEN Outlet_Type       IS NULL OR TRIM(Outlet_Type)        = '' THEN 1 ELSE 0 END) AS null_outlet_type,
    SUM(CASE WHEN Item_Visibility     IS NULL   THEN 1 ELSE 0 END) AS null_item_visibility,
    SUM(CASE WHEN Item_Weight      IS NULL  THEN 1 ELSE 0 END) AS null_item_weight,
    SUM(CASE WHEN Sales   IS NULL  THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN Rating   IS NULL  THEN 1 ELSE 0 END) AS null_rating
FROM blinkit;


-- Catch any unrealistic values that could skew analysis
SELECT
    MIN(Sales)   AS min_sales,
    MAX(Sales)      AS max_sales,
    AVG(Sales)   AS avg_sales,
    MIN(Item_Weight)  AS min_weight,
    MAX(Item_Weight)  AS max_weight,
    MIN(Item_Visibility)  AS min_visibility,
    MAX(Item_Visibility)  AS max_visibility,
    MIN(Rating)   AS min_rating,
    MAX(Rating)    AS max_rating
FROM blinkit;

-- Flag rows with negative or zero sales (should not exist)
SELECT COUNT(*) AS invalid_sales_count
FROM blinkit
WHERE Sales <= 0;

-- Flag rows with visibility = 0 (item never shown — may need investigation)
SELECT COUNT(*) AS zero_visibility_count
FROM blinkit
WHERE Item_Visibility = 0;


--  Final row count after cleaning 
SELECT COUNT(*) AS total_cleaned_rows FROM blinkit;
