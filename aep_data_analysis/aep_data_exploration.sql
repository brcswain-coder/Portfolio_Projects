-- 1.0 HOUR OF THE DAY TREND

WITH hourly_table AS
(
SELECT
		DATE_FORMAT(Datetime, '%I:%i %p') as hour,
        AVG(AEP_MW) as hourly_consumption_mw
FROM aep_hourly_staging3
GROUP BY hour
),
baseline AS
(
SELECT 
		AVG(AEP_MW) as overall_avg_consumption_mw
FROM aep_hourly_staging3
)
SELECT 
		hour,
		hourly_consumption_mw,
        overall_avg_consumption_mw,
        ROUND(((hourly_consumption_mw - overall_avg_consumption_mw)/overall_avg_consumption_mw)*100, 2) AS pct_diff
FROM hourly_table 
CROSS JOIN baseline 
ORDER BY hourly_consumption_mw DESC;

-- 2.0 HOLIDAY TREND

-- 2.1 Create holiday table (U.S. Calendar) for reference 

CREATE TABLE us_holidays ( 
	holiday_date Date PRIMARY KEY,
    holiday_name VARCHAR(100)
);

INSERT INTO us_holidays
VALUES 
('2024-01-01', 'New Year''s Day'),
('2024-01-15', 'Martin Luther King Jr. Day'),
('2024-02-19', 'Presidents Day'),
('2024-05-27', 'Memorial Day'),
('2024-06-19', 'Juneteenth'),
('2024-07-04', 'Independence Day'),
('2024-09-02', 'Labor Day'),
('2024-10-14', 'Columbus Day'),
('2024-11-11', 'Veterans Day'),
('2024-11-28', 'Thanksgiving Day'),
('2024-12-25', 'Christmas Day');

-- 2.2 Proceeding to query

WITH holiday_cons AS
(
SELECT
		DATE_FORMAT(Datetime, '%M-%d') as month_day,
        holiday_name,
        AVG(AEP_MW) as holiday_avg_mw
FROM aep_hourly_staging3 
INNER JOIN us_holidays 
	ON DATE_FORMAT(Datetime, '%M-%d') = DATE_FORMAT(holiday_date, '%M-%d')
GROUP BY DATE_FORMAT(Datetime, '%M-%d'), holiday_name 
),
baseline AS
(
SELECT
        ROUND(AVG(holiday_avg_mw), 4) AS overall_holiday_avg
FROM holiday_cons
)
SELECT
		*,
		ROUND(((holiday_avg_mw - overall_holiday_avg)/overall_holiday_avg)*100, 2) as pct_diff
FROM holiday_cons
CROSS JOIN baseline
ORDER BY holiday_avg_mw DESC;


-- 3.0 LONG TERM TREND

WITH annual_table AS
(
	SELECT
			YEAR(Datetime) AS year,
            AVG(AEP_MW) AS annual_mw
	FROM aep_hourly_staging3
    GROUP BY year
),
peak_table AS
(
	SELECT
			YEAR(Datetime) AS year,
            MAX(AEP_MW) as peak_mw
	FROM aep_hourly_staging3
    GROUP BY year
),
-- baselines
avg_baseline AS
(
	SELECT 
			AVG(annual_mw) as overall_annual_mw
	FROM annual_table
),
peak_baseline AS
(
	SELECT
			AVG(peak_mw) as overall_peak_mw
	FROM peak_table
)
SELECT
		a.year,
        annual_mw,
        ROUND(overall_annual_mw, 4) as overall_annual_mw,
        ROUND(((annual_mw - overall_annual_mw)/overall_annual_mw)*100, 2) as pct_diff_annual,
        peak_mw,
        overall_peak_mw,
        ROUND(((peak_mw - overall_peak_mw)/overall_peak_mw)*100, 2) as  pct_diff_peak,
        ROUND((annual_mw/peak_mw)*100, 2) AS load_factor
FROM annual_table as a
JOIN peak_table as p
	ON a.year = p.year
CROSS JOIN avg_baseline 
CROSS join peak_baseline 
ORDER BY a.year;

-- 4.0 SEASONAL TREND (hourly)

WITH season_table AS
(
	SELECT 
		DATE_FORMAT(Datetime, '%I:%i %p') as hour_of_day,
		CASE
		WHEN MONTH(Datetime) IN (3, 4, 5) THEN 'Spring'
		WHEN MONTH(Datetime) IN (6, 7, 8) THEN 'Summer'
		WHEN MONTH(Datetime) IN (9, 10, 11) THEN 'Fall'
		WHEN MONTH(Datetime) IN (12, 1, 2) THEN 'Winter'
	END AS season,
		AVG(AEP_MW) AS season_avg_mw
	FROM aep_hourly_staging3
	GROUP BY season, hour_of_day
),
ssn_baseline AS
(
	SELECT
		season,
		ROUND(AVG(season_avg_mw), 4) AS season_avg_all_hrs
	FROM season_table
    GROUP BY season
)
SELECT 
		hour_of_day,
		st.season,
        season_avg_mw,
        season_avg_all_hrs,
        ROUND(((season_avg_mw - season_avg_all_hrs)/season_avg_all_hrs)*100, 2) as pct_diff_season
FROM season_table st
JOIN ssn_baseline sb
	ON st.season = sb.season
ORDER BY season, hour_of_day;






