# Manufacturing Defects Data Analysis

## 📌Project Overview
This project contains simulated data related to manufacturing defects observed during quality control processes. The dataset is sourced from [Kaggle](https://www.kaggle.com/datasets/fahmidachowdhury/manufacturing-defects?select=defects_data.csv) and contains the defect records of over 100 product IDs.

The objective is to analyze the patterns and to identify various problems in the workflow process. Using Structured Query Language (**SQL**) for data preparation and **Tableau** for data visualization, the raw data is transformed into insightful data.

This project demonstrates key elements of a Quality Management System (QMS)—including Quality Control Analysis, Process Improvement, Cost Analysis, and Product Quality Assurance—applied to manufacturing data for actionable insights.


---

## 📁 Repository Structure
- `data/` – raw and processed datasets
- `scripts/` – cleaning, analysis and processing scripts
- `outputs/` – aggregated tables and CSVs
- `visuals/` – charts and dashboards

## ⚙️ Tools Used
- MySQL Workbench
- Tableau Public
- GitHub

## 🔑 Key Steps
1. Import raw dataset
2. Clean and explore with SQL
3. Export summarized data
4. Visualize with Tableau

## 📊 Results
- **Quality Control Analysis**
    1. Daily and monthly trend analysis revealed a drop in defect counts, indicating greater process stability and proactive quality control.
    2. Pareto analysis of defect type frequency indicates that **structural** and **functional** defect types account for ~70% of all defect types. Prioritizing these categories would yield significant impact on overall defect reduction.
- **Process Improvement**
    1. Defect location Pareto analysis revealed that nearly ~70% of all defects originated at the **surface** and **component** stages. Prioritizing corrective actions on the machines associated with these locations would significantly enhance process efficiency.
    2. Pareto analysis revealed that defects detected through **manual testing** and **visual inspection** account for ~70% of repair costs. Prioritizing improvements on these methods would provide long-term reduction in repair costs.
    3. Pareto analysis indicates the **top seven** defect type-severity combination that amount to 81% of overall repair costs. The remaining combinations that account for nearly 20% can be deprioritized for later improvement cycles.
- **Cost Analysis**
    1. The cost analysis for defect type repair cost aligns with the defect type frequency results, showing that **structural** and **functional** defects together represent the largest share of total repair costs. This consistency highlights these categories as the most critical targets for quality improvement initiatives.
    2. Contrary to the norm that **critical** defects are the primary cost drivers, Pareto analysis revealed that **minor** defects actually contribute the highest share of repair costs along with critical defects to account for ~70% of the total repair expenses. Prioritizing both would yield the greatest cost reduction impact.
    3. Cost analysis by inspection-severity coincides with inspection method results. It is observed that **manual testing** and **visual inspection** account for ~80% of the total repair cost. Automated testing contributes less and can be deprioritized for later investment cycles.
- **Product Quality Assurance**
    1. Inspection method analysis revealed that **manual testing** and **visual inspection** was most effective at detecting  defects with high cost impacts making it a strong candidate for expanded use in QA strategy.
    2. Severity‑based analysis suggested that reallocating QA resources toward **minor** and **critical** defects could significantly improve both product reliability and cost efficiency.

- A separate dashboard for Product IDs was created for pinpointing the specific products that account for 80% of the defects and repair costs.

       
## ✍️ Author
Alessandro Locsin — Registered Mechanical Engineer | Data Analyst Practitioner

