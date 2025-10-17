# American Electric Power (AEP) Data Analysis Project

## 📌: Project Overview
This project analyzes 15 years of hourly electricity consumption data from American Electric Power (AEP), spanning January 2004 to October 2018. The dataset, sourced from [Kaggle](https://www.kaggle.com/datasets/robikscube/hourly-energy-consumption/data), contains ~120,000 hourly records.

The goal is to uncover energy consumption patterns across times of day, seasons, years, and holidays—insights that are valuable for planning, maintenance, and demand forecasting. Using **SQL** for data preparation and **Tableau** for visualization, raw data is transformed into actionable insights.

---

## 📁 Repository Structure

- **data/**
  - `aep_hourly_raw.csv/` → Original dataset from kaggle
  - `aep_hourly_clean.csv/` → Processed datasets after SQL cleaning

- **scripts/**
  - `aep_data_cleaning.sql` → SQL script for cleaning and transforming data  
  - `aep_data_exploration.sql` → SQL script for exploratory queries  

- **outputs/**
  - `annual_aep.csv/` → Annual aggregated AEP data
  - `holiday_aep.csv/` → Holiday-specific aggregated AEP data
  - `hourly_aep.csv/` → Hourly aggregated AEP data
  - `seasonal_aep.csv/` → Seasonal aggregated AEP data

- **visuals/**
  - `AEP_charts.twbx/` → Tableau workbook file
  - `Dashboard 1.png/` → Contains hourly and seasonal charts
  - `Dashboard 2.png/` → Contains annual and holiday charts

- **README.md** → Project documentation

## ⚙️ Tools Used
- MySQL Workbench
- Tableau Public
- GitHub

## 🔑 Key Steps
1. Import raw dataset
2. Clean with SQL
3. Export summarized data
4. Visualize with Tableau

## 📊 Results
- Insights for Hourly Trend
    1. High energy demand occurs between 9:00 AM - 11:00 PM peaking at a load of 16,869 MW.
    2. Low energy demand occurs between 12:00 AM - 8:00 AM hitting the lowest value at 13,096 MW.
    3. The curve shows a daily load profile: low demand occurs overnight → rising through the day → peaks in the evening.
- Insights for Holiday Trend
    1. Christmas is not the peak which may be due to the some business establishments being closed.
    2. The top 2 demanding holidays occurs in the winter season which may be due to higher heating demands.
    3. The lowest demanding holiday is Columbus Day which occurs during fall where temperatures can be optimal to neither use heating/cooling
- Insights for Annual Trend
    1. There is an overall decline in annual and peak consumption starting on year 2008.
    2. The load factor peaked at  67.44% on 2010 and the trend continued to decline which meant that energy is used ineffienctly through out the years.
- Insights for Seasonal Trend
    1. There is a similarity between the cycle for energy demand for fall, spring, and winter: low demand occurs overnight → rising through the day → peaks in the evening.
    2.  Summer season energy demand cycle transitions from low to high at noon time.
       
## ✍️ Author
Alessandro Locsin — Registered Mechanical Engineer | Data Analyst Practitioner


