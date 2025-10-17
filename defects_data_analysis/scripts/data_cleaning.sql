-- DATA CLEANING

-- Creating duplicate table 
CREATE TABLE defects_data_staging1
LIKE defects_data;

INSERT INTO defects_data_staging1
SELECT *
FROM defects_data;

-- INSPECTION

-- Quick row count
SELECT 
		COUNT(*) AS total_rows,
        COUNT(DISTINCT product_id) AS unique_products   
FROM defects_data_staging1;

-- Standardization

-- ALTERING DATA TYPE for date column
-- Altering date format
SELECT 
		defect_date,
        STR_TO_DATE (defect_date, '%m/%d/%Y')
FROM defects_data_staging1;

UPDATE defects_data_staging1
SET defect_date = STR_TO_DATE (defect_date, '%m/%d/%Y');

-- Altering data type for defect_date column
ALTER TABLE defects_data_staging1
MODIFY COLUMN defect_date DATE;

-- Checking for NULLS
SELECT
		*
FROM defects_data_staging1
WHERE defect_id IS NULL;  -- NO NULLS


-- Checking for duplicate rows
WITH dupe_check AS
(
SELECT 
		*,
        ROW_NUMBER() OVER (PARTITION BY defect_id, product_id, defect_type, defect_date,
        defect_location, severity, inspection_method, repair_cost) AS dupes
FROM defects_data_staging1
)
SELECT *
FROM dupe_check
WHERE dupes > 1;  -- No duplicate rows present


