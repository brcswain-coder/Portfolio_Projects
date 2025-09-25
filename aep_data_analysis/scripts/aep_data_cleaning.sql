-- 1.0 DUPLICATING THE PRIMARY DATA SOURCE
CREATE TABLE aep_hourly_staging1
LIKE aep_hourly;

INSERT INTO aep_hourly_staging1
SELECT *
FROM aep_hourly;

-- 2.0 STANDARDIZATION
-- 2.1 Datetime format
	
SELECT 
		*
FROM aep_hourly_staging1
WHERE Datetime NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}'; -- Datetime has consistent format

-- 2.2 NULL Values
SELECT 
		COUNT(*)
FROM aep_hourly_staging1
WHERE Datetime IS NULL;

SELECT 
		COUNT(*)
FROM aep_hourly_staging1
WHERE AEP_MW IS NULL;  -- NO NULL VALUES

-- 2.3 Checking for gaps in hours
-- Creating hourly table for reference

SELECT 
    MIN(DATE_FORMAT(Datetime, '%Y-%m-%d %H:00:00')) AS min_dt,
    MAX(DATE_FORMAT(Datetime, '%Y-%m-%d %H:00:00')) AS max_dt
FROM aep_hourly_staging1;

-- result: 2004-10-01 01:00:00	2018-08-03 00:00:00


-- Create a numbers table with at least 130,000 integers
CREATE TEMPORARY TABLE nums (n INT NOT NULL);

INSERT INTO nums (n)
SELECT a.N + b.N*10 + c.N*100 + d.N*1000 + e.N*10000 + f.N*100000
FROM (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
      UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
CROSS JOIN (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
      UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
CROSS JOIN (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
      UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c
CROSS JOIN (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
      UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d
CROSS JOIN (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
      UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) e
CROSS JOIN (SELECT 0 N UNION ALL SELECT 1) f; 

SET @start_dt = '2004-10-01 01:00:00';
SET @end_dt   = '2018-08-03 00:00:00';

-- Creating hour reference table

CREATE TABLE hour_reference AS
SELECT 
    DATE_ADD(@start_dt, INTERVAL n HOUR) AS Datetime
FROM nums
WHERE DATE_ADD(@start_dt, INTERVAL n HOUR) <= @end_dt
ORDER BY Datetime;

-- Checking the datetime with missing hours
SELECT c.Datetime
FROM hour_reference c
LEFT JOIN aep_hourly_staging1 a
    ON c.Datetime = a.Datetime
WHERE a.Datetime IS NULL
ORDER BY c.Datetime;

SELECT COUNT(*)
FROM hour_reference c
LEFT JOIN aep_hourly_staging1 a
	ON c.Datetime = a.Datetime
WHERE a.Datetime IS NULL;           -- DETECTED 27 missing hourly records


-- Checking how many hours are missing per datetime with known gaps
SELECT 
    DATE(Datetime) AS date,
    COUNT(*) AS missing_hours
FROM (
    SELECT c.Datetime
    FROM hour_reference c
    LEFT JOIN aep_hourly_staging1 a
        ON c.Datetime = a.Datetime
    WHERE a.Datetime IS NULL
) AS missing
GROUP BY DATE(Datetime)
ORDER BY missing_hours DESC;

-- FILLING MISSING VALUES
-- Create another table for insertions
CREATE TABLE aep_hourly_staging2
LIKE aep_hourly_staging1;

INSERT INTO aep_hourly_staging2
SELECT * 
FROM aep_hourly_staging1;

-- INSERT missing Datetime

INSERT INTO aep_hourly_staging2 (Datetime)
SELECT c.Datetime
FROM hour_reference c
LEFT JOIN aep_hourly_staging1 a
    ON c.Datetime = a.Datetime
WHERE a.Datetime IS NULL
ORDER BY c.Datetime;

-- Check inserted Datetime
SELECT *
FROM aep_hourly_staging2
WHERE Datetime ='2004-10-31 02:00:00';


-- Interpolate and insert missing values 
UPDATE aep_hourly_staging2 AS t
JOIN (
SELECT 
	s.Datetime,
	(
        (
			SELECT AEP_MW
			FROM aep_hourly_staging2 
			WHERE Datetime < s.Datetime
			AND AEP_MW IS NOT NULL
            ORDER BY Datetime DESC
			LIMIT 1
        ) 
        +
        (
         SELECT AEP_MW
        FROM aep_hourly_staging2 
        WHERE Datetime > s.Datetime
			AND AEP_MW IS NOT NULL
		ORDER BY Datetime 
		LIMIT 1
        ) 
	)/2 as interpolated_value
FROM aep_hourly_staging2 s
WHERE AEP_MW IS NULL
) AS calc_table
ON t.Datetime = calc_table.Datetime
SET t.AEP_MW = calc_table.interpolated_value;

-- double checking the insertion
WITH to_check AS
(
SELECT c.Datetime
FROM hour_reference c
LEFT JOIN aep_hourly_staging1 a
    ON c.Datetime = a.Datetime
WHERE a.Datetime IS NULL
ORDER BY c.Datetime
),
updated AS
(
SELECT *
FROM aep_hourly_staging2
)
SELECT 
		u.Datetime,
        AEP_MW
FROM to_check c
LEFT JOIN updated u
	ON c.Datetime = u.Datetime
ORDER BY u.Datetime;



-- 2.4 CHECKING FOR BAD DATA 
-- Duplicates

WITH dupe_table AS
(
SELECT *,
	ROW_NUMBER () OVER (PARTITION BY Datetime, AEP_MW) as row_num
FROM aep_hourly_staging2
)
SELECT
		*
FROM dupe_table
WHERE row_num > 1;   -- NO duplicates for both columns




-- INCONSISTENCIES

SELECT 
    Datetime,
    COUNT(*) AS total_records,
    GROUP_CONCAT(DISTINCT AEP_MW) AS distinct_values
FROM aep_hourly_staging2
GROUP BY Datetime
HAVING COUNT(*) > 1;		-- conflicting values present


-- Getting the average for each datetime with conflicting values to merge into one row
CREATE TABLE aep_hourly_staging3 AS
SELECT 
		Datetime,
        ROUND(AVG(AEP_MW)) as AEP_MW
FROM aep_hourly_staging2
GROUP BY Datetime;


-- Checking result of averaging
SELECT 
    Datetime,
    COUNT(*) AS total_records,
    GROUP_CONCAT(DISTINCT AEP_MW) AS distinct_values
FROM aep_hourly_staging3
GROUP BY Datetime
HAVING COUNT(*) > 1;	-- Conflicting values resolved


-- Check for any remaining duplicates
SELECT Datetime, COUNT(*) AS dupes
FROM aep_hourly_staging3
GROUP BY Datetime
HAVING dupes > 1;

-- Check total row count matches hour_reference
SELECT 
    (SELECT COUNT(*) FROM aep_hourly_staging3) AS cleaned_rows,
    (SELECT COUNT(*) FROM hour_reference) AS reference_rows;
    
    















































