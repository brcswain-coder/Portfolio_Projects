# American Electric Power (AEP) Data Analysis Project

## 📌 Project Overview
This project analyzes 15 years of hourly electricity consumption data from American Electric Power (AEP), spanning January 2004 to October 2018. The dataset, sourced from [Kaggle](https://www.kaggle.com/datasets/robikscube/hourly-energy-consumption/data), contains ~120,000 hourly records.

The goal is to uncover energy consumption patterns across times of day, seasons, years, and holidays—insights that are valuable for planning, maintenance, and demand forecasting. Using **SQL** for data preparation and **Tableau** for visualization, raw data is transformed into actionable insights.

---

## 🗂️ Repository Structure

- **data/**
  - `raw/` → Original dataset from kaggle
  - `cleaned/` → Processed datasets after SQL cleaning

- **scripts/**
  - `aep_data_cleaning.sql` → SQL script for cleaning and transforming data  
  - `aep_data_exploration.sql` → SQL script for exploratory queries  

- **outputs/**
  - `charts/` → Visualizations exported from Tableau or Python  
  - `summary_tables/` → Aggregated tables or CSVs  

- **README.md** → Project documentation
