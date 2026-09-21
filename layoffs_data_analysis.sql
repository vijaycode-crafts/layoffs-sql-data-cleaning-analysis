USE layoff_project ;
SELECT * FROM layoffs_staging;

# Total Layoffs Records
SELECT COUNT(*) FROM layoffs_staging;

# How many companies which had layoffs
SELECT DISTINCT company FROM layoffs_staging;

# Total number of layoffs
SELECT SUM(total_laid_off) FROM layoffs_staging;

# Minimum , Maximum and Average of workforce laid off
SELECT MAX(total_laid_off) , MIN(total_laid_off) , AVG(total_laid_off) FROM layoffs_staging;

#How many layoffs occurred in each year?
SELECT YEAR(date) as Laid_Year, SUM(total_laid_off) as Total_Laid FROM layoffs_staging 
WHERE YEAR(date) IS NOT NULL GROUP BY Laid_Year ORDER BY Laid_Year;

#How many layoffs occurred in each month?
SELECT MONTH(date) as Laid_Month, SUM(total_laid_off) as Total_Laid FROM layoffs_staging 
WHERE MONTH(date) IS NOT NULL 
GROUP BY Laid_Month ORDER BY Laid_Month;

#Find the top 10 companies with the highest total layoffs.
SELECT company , SUM(total_laid_off) as Total_layoffs FROM layoffs_staging
GROUP BY company ORDER BY Total_layoffs DESC
LIMIT 10;

#Find the top 10 industries with the highest layoffs.
SELECT industry , SUM(total_laid_off) as Total_layoffs FROM layoffs_staging
GROUP BY industry ORDER BY Total_layoffs DESC
LIMIT 10;

#Find companies where total layoffs exceed 1,000 employees
SELECT company , SUM(total_laid_off) as Total_layoffs FROM layoffs_staging
GROUP BY company HAVING Total_layoffs > 1000;

#Find the average number of employees laid off per company 
SELECT company , AVG(total_laid_off) as Avg_layoffs FROM layoffs_staging
GROUP BY company ;

#Find the first company in the dataset to report layoffs.
SELECT company , date FROM layoffs_staging 
WHERE date =( SELECT MIN(date) FROM layoffs_staging);

#Find the most recent layoff record.
SELECT company ,date FROM layoffs_staging 
WHERE date =( SELECT MAX(date) FROM layoffs_staging);

#Find the companies that conducted layoffs in multiple years.----------------------------------------------------------------------------------------
WITH CTE AS
(SELECT company , YEAR(date) as laidyear, ROW_NUMBER() OVER ( PARTITION BY company ) as countyears FROM layoffs_staging)
SELECT company FROM CTE 
WHERE countyears >1 GROUP BY company;

#Rolling total of total layoffs over year-----------------------------------------------------------------------------------------------------------------
WITH Rolling_total AS
(SELECT YEAR(date) as laidyear,SUM(total_laid_off) as layoffs FROM layoffs_staging
WHERE YEAR(date) IS NOT NULL
GROUP BY YEAR(date) ORDER BY laidyear)
SELECT laidyear , layoffs , SUM(layoffs) OVER (ORDER BY laidyear) AS Rolling_year FROM Rolling_total;

#Year to year change percentage in layoffs------------------------------------------------------------------------------------------------------------------
WITH yearly_layoffs AS (
SELECT YEAR(date) as laidyear,SUM(total_laid_off) as total_layoffs FROM layoffs_staging
WHERE YEAR(date) IS NOT NULL
GROUP BY YEAR(date) ORDER BY laidyear),
previous_year_layoffs AS (
SELECT laidyear , total_layoffs , LAG(total_layoffs) OVER () as previous_year FROM yearly_layoffs)
SELECT laidyear , total_layoffs , (total_layoffs-previous_year) as yoy_change , 
CONCAT(
ROUND(((total_layoffs-previous_year)/previous_year)*100,2) , '%')
as yoy_change_per FROM previous_year_layoffs ;

#Categorize companies based on number of employees laid off:--------------------------------------------------------------------------------------------
-- 0–100       → Small
-- 101–500     → Medium
-- 501–1000    → Large
-- 1000+       → Very Large
WITH Categorize AS (
SELECT company, SUM(total_laid_off) as total_laid FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
GROUP BY company ORDER BY total_laid )
SELECT company , total_laid ,
CASE
	 WHEN total_laid BETWEEN 0 AND 100 THEN 'Small'
     WHEN total_laid BETWEEN 101 AND 500 THEN 'Medium'
     WHEN total_laid BETWEEN 501 AND 1000 THEN 'Large'
     WHEN total_laid > 1000 THEN 'Very Large'
END as layoffs_size_category
FROM Categorize;

#Count how many companies fall into each category.------------------------------------------------------------------------------------------
WITH Categorize AS (
SELECT company, SUM(total_laid_off) as total_laid FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
GROUP BY company ORDER BY total_laid ),
category AS
(SELECT company , total_laid ,
CASE
	 WHEN total_laid BETWEEN 0 AND 100 THEN 'Small'
     WHEN total_laid BETWEEN 101 AND 500 THEN 'Medium'
     WHEN total_laid BETWEEN 501 AND 1000 THEN 'Large'
     WHEN total_laid > 1000 THEN 'Very Large'
END as layoffs_size_category
FROM Categorize)
SELECT layoffs_size_category , COUNT(*) as company_count FROM category GROUP BY layoffs_size_category;

#Rank companies by total layoffs.----------------------------------------------------------------------------------------------------------------
SELECT company , SUM(total_laid_off) total_laid, RANK() OVER( ORDER BY SUM(total_laid_off) DESC) rankings FROM layoffs_staging 
GROUP BY company;

#Find the top 3 companies with the highest layoffs in each year.----------------------------------------------------------------------------------
WITH highest_layoffs AS
(	SELECT company , YEAR(date) laidyear , SUM(total_laid_off) total_laid, 
	RANK() OVER( PARTITION BY YEAR(date) ORDER BY SUM(total_laid_off) DESC) rankings 
	FROM layoffs_staging WHERE date IS NOT NULL
	GROUP BY company , laidyear )
SELECT company , laidyear , total_laid , rankings FROM highest_layoffs
WHERE rankings IN (1,2,3);

#Find companies whose layoffs are above the overall average.-----------------------------------------------------------------------------------------
SELECT company , AVG(total_laid_off) as avg_layoffs FROM layoffs_staging 
GROUP BY company 
HAVING avg_layoffs > ( SELECT  AVG(total_laid_off) FROM layoffs_staging );

#Find industries whose layoffs are above the overall average.-------------------------------------------------------------------------------------------
SELECT industry , AVG(total_laid_off) as avg_layoffs FROM layoffs_staging 
GROUP BY industry 
HAVING avg_layoffs > ( SELECT  AVG(total_laid_off) FROM layoffs_staging );

#cumulative  percentage of total layoffs among top 10 companies---------------------------------------------------------------------------------- 
WITH laying_total AS (
	SELECT company , SUM( total_laid_off ) total_laid FROM layoffs_staging
	WHERE total_laid_off IS NOT NULL
	GROUP BY company ORDER BY total_laid DESC 
    LIMIT 10),
cumulative  AS (
	SELECT * ,  SUM(total_laid) OVER () as overall_layoffs ,SUM( total_laid ) OVER ( ORDER BY total_laid ASC ) as Cumulative_increase FROM laying_total
	)
SELECT * , CONCAT(ROUND( (Cumulative_increase/overall_layoffs)*100,2 ), '%') as cum_inc_per FROM cumulative;
