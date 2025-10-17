-- QUALITY CONTROL ANALYSIS

-- Daily defect trend
WITH daily AS
(
SELECT
		DATE_FORMAT(defect_date, '%d') AS day,
        defect_type,
        COUNT(*) AS defect_count
FROM defects_data_staging1
GROUP BY day, defect_type
)
SELECT
		day,
        ROUND(SUM(defect_count), 2) AS total_defect
FROM daily
GROUP BY day
ORDER BY day;


-- Monthly defect trend
WITH monthly AS
(
SELECT
		MONTH(defect_date) AS month_num,
		DATE_FORMAT(defect_date, '%M') AS month,
        defect_type,
        COUNT(*) AS defect_count
FROM defects_data_staging1
GROUP BY month_num, month, defect_type
)
SELECT
		month,
        ROUND(SUM(defect_count), 2) AS total_defect
FROM monthly
GROUP BY month_num, month
ORDER BY month_num;


-- Defects by severity
SELECT
        severity,
        COUNT(*) AS defect_count
FROM defects_data staging1
GROUP BY severity;


-- Defect type frequency for pareto analysis
WITH defect_summary AS
(
SELECT
		defect_type,
        COUNT(*) AS defect_count,
        ROUND((100 * COUNT(*) / (SELECT
									COUNT(*) 
                            FROM defects_data_staging1)), 2) AS pct_of_total
FROM defects_data_staging1
GROUP BY defect_type
)
SELECT 
		defect_type,
        defect_count,
        pct_of_total,
        SUM(pct_of_total) OVER(	ORDER BY defect_count DESC ROWS BETWEEN 
								UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_pct
FROM defect_summary;
        


-- PROCESS IMPROVEMENT


/** Using defect location to determine which production
stage need process improvement.**/

WITH location_summary AS
(
SELECT
		defect_location,
        COUNT(*) AS defect_count,
        ROUND((100 * COUNT(*) / (SELECT
									COUNT(*) 
                            FROM defects_data_staging1)), 2) AS pct_of_total
FROM defects_data_staging1
GROUP BY defect_location
)
SELECT
		defect_location,
        defect_count,
        pct_of_total,
        SUM(pct_of_total) OVER (ORDER BY defect_count DESC ROWS BETWEEN 
								UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_pct
FROM location_summary;



-- COST ANALYSIS

-- Total cost and average cost per defect type 
SELECT
		defect_type,
        ROUND(SUM(repair_cost), 2) AS total_cost,
        ROUND(AVG(repair_cost), 2) AS avg_cost
FROM defects_data_staging1
GROUP BY defect_type
ORDER BY total_cost DESC; 


-- Defect type and repair cost for pareto analysis
WITH cost_summary AS
(
SELECT
		defect_type,
        ROUND(SUM(repair_cost), 2) as total_cost,
        (100 * SUM(repair_cost)/( SELECT
									SUM(repair_cost)
							FROM defects_data_staging1))AS pct_of_total
FROM defects_data_staging1
GROUP BY defect_type
)
SELECT 
		defect_type,
        total_cost,
        ROUND(pct_of_total, 2) AS pct_of_total,
        ROUND(SUM(pct_of_total) OVER (	ORDER BY total_cost DESC ROWS BETWEEN 
										UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS cumulative_pct
FROM cost_summary;


-- Severtiy and repair cost for pareto analysis
WITH sev_sum AS
(
SELECT
		severity,
        ROUND(SUM(repair_cost), 2) AS total_cost,
        ROUND((100 * SUM(repair_cost)/(
								SELECT SUM(repair_cost)
								FROM defects_data_staging1)), 2) AS pct_of_total
FROM defects_data_staging1
GROUP BY severity
)
SELECT
		severity,
        total_cost,
        pct_of_total,
		ROUND(SUM(pct_of_total) OVER(	ORDER BY total_cost DESC ROWS BETWEEN 
										UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS cumulative_pct
FROM sev_sum;


-- Defect type, severity and cost relation for Pareto Analysis

/**  Searching for the specific combination of defect type 
and its severity that account for significant repair cost. **/

WITH cost_sum AS
(
SELECT
		defect_type,
		severity,
		ROUND(SUM(repair_cost), 2) AS total_cost
FROM defects_data_staging1
GROUP BY defect_type, severity
),
cost_pct AS
(
SELECT
		defect_type,
        severity,
        total_cost,
        ROUND((100 * total_cost/( SELECT	
									SUM(total_cost)
							FROM cost_sum)), 2) AS pct_of_total
FROM cost_sum
)
SELECT 
		defect_type,
        severity,
		total_cost,
        pct_of_total,
        ROUND(SUM(pct_of_total) OVER (	ORDER BY total_cost DESC ROWS BETWEEN 
										UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS cumulative_pct
FROM cost_pct;


-- Inspection method and repair cost for Pareto Analysis
WITH ins_sum AS
(
SELECT
		inspection_method,
        ROUND(SUM(repair_cost), 2) AS total_cost,
        ROUND((100 * SUM(repair_cost)/(
								SELECT SUM(repair_cost)
                                FROM defects_data_staging1)), 2) AS pct_of_total
FROM defects_data_staging1
GROUP BY inspection_method
)
SELECT
		inspection_method,
        total_cost,
        pct_of_total,
        ROUND(SUM(pct_of_total) OVER (	ORDER BY total_cost DESC ROWS BETWEEN
										UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS cumulative_pct
FROM ins_sum;
        

-- Inspection method, severity and repair cost relation for Pareto Analysis

/** Searching for the inspection method that are most effective at detecting 
high-impact defects **/

WITH ins_sev AS
(
SELECT
		inspection_method,
        severity,
        ROUND(SUM(repair_cost), 2) AS total_cost
FROM defects_data_staging1
GROUP BY inspection_method, severity
),
pct AS
(
SELECT
		inspection_method,
        severity,
        total_cost,
        ROUND((100 * total_cost/ (
							SELECT SUM(total_cost)
                            FROM ins_sev)), 2) AS pct_of_total
FROM ins_sev
)
SELECT
		inspection_method,
        severity,
        total_cost,
        pct_of_total,
        ROUND(SUM(pct_of_total) OVER (	ORDER BY total_cost DESC ROWS BETWEEN 
										UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS cumulative_pct
FROM pct;


-- Pinpointing the specific products that has high-impact defects and costs
-- Product ID defect frequency for Pareto Analysis

WITH product AS
(
SELECT
		product_id,
        COUNT(*) AS defect_count,
        ROUND((100 * COUNT(*)/ (
							SELECT COUNT(*)
                            FROM defects_data_staging1)), 2) AS pct_of_total
FROM defects_data_staging1
GROUP BY product_id
)
SELECT
		product_id,
        defect_count,
        pct_of_total,
        SUM(pct_of_total) OVER(	ORDER BY defect_count DESC ROWS BETWEEN 
								UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_pct
FROM product;


-- Product ID and repair cost for Pareto Analysis
WITH prod_cost AS
(
SELECT
		product_id,
        ROUND(SUM(repair_cost), 2) AS total_cost,
        ROUND((100 * SUM(repair_cost)/(
									SELECT SUM(repair_cost)
                                    FROM defects_data_staging1)), 4) AS pct_of_total
FROM defects_data_staging1
GROUP BY product_id
)
SELECT
		product_id,
        total_cost,
        pct_of_total,
        ROUND(SUM(pct_of_total) OVER (ORDER BY total_cost DESC ROWS BETWEEN 
								UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS cumulative_pct
FROM prod_cost;

	
        






















