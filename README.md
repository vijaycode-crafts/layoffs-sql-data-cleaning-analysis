
# Layoffs Data Cleaning & Exploratory Analysis

This project cleans and analyzes a global layoffs dataset using SQL. It demonstrates an end-to-end data workflow: preparing raw data for analysis, resolving quality issues, and exploring trends in layoffs across companies, industries, countries, and time.

## Project objectives

- Clean and standardize the raw layoffs dataset.
- Remove duplicate and unusable records.
- Prepare a reliable dataset for analysis.
- Explore layoff trends by company, industry, country, funding stage, and time period.
- Identify companies and periods with the highest reported layoffs.

## Dataset

The dataset contains reported layoff events, including:

- Company
- Location
- Industry
- Total layoffs
- Percentage laid off
- Date
- Company stage
- Country
- Funds raised

> The dataset is used for learning and portfolio purposes. Results depend on the completeness and accuracy of the source data.

## Project structure

```text
layoffs-data-project/
├── data/
│   ├── raw/
│       └── layoffs.csv
│   
├── sql/
│   ├── layoffs_project_data_cleaning.sql
│   └── layoffs_data_analysis.sql
├── README.md
└── .gitignore
```

## Data-cleaning process

The cleaning script performs the following steps:

1. Creates a staging table to preserve the original dataset.
2. Identifies and removes duplicate records.
3. Standardizes inconsistent text values, including company names, industries, and countries.
4. Converts date values to the correct date format.
5. Replaces blank values with `NULL` where appropriate.
6. Fills missing industry values when reliable information is available from related records.
7. Removes records that do not contain meaningful layoff information.

## Exploratory analysis

The analysis script answers questions such as:

- Which companies reported the largest layoffs?
- Which industries were most affected?
- Which countries had the highest number of layoffs?
- How did layoffs change over time?
- Which year and month had the most reported layoffs?
- Which funding stages were associated with higher layoffs?
- Which companies had the highest layoffs within each year?

## Tools used

- SQL
- MySQL
- Git and GitHub

## How to run the project

1. Create a database in MySQL.
2. Import the raw dataset into a table.
3. Run `sql/layoffs_project_data_cleaning.sql` to create and clean the staging table.
4. Run `sql/layoffs_data_analysis.sql` to explore the cleaned data.

## Key skills demonstrated

- Data cleaning and transformation
- Duplicate detection
- Missing-value handling
- SQL joins and window functions
- Common table expressions (CTEs)
- Aggregations and trend analysis
- Data exploration and business-focused questions

## Author

**Your Name**  
[GitHub Profile](https://github.com/vijaycode-crafts)
