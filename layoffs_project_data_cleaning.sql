create database layoff_project;
use layoff_project;
select * from layoffs;
-- 1.deleting the duplicates
-- 2.standardizing the data
-- 3.replacing with relevent data
-- 4.remove rows
 
 select *, row_number() over ( partition by company , 
location , 
industry , 
total_laid_off , 
percentage_laid_off , 
`date` , 
stage , 
country , 
funds_raised_millions ) as row_num from layoffs;

create table layoffs_staging
like layoffs;
 
alter table layoffs_staging
add column row_num int;

insert into layoffs_staging
select *, row_number() over ( partition by company , 
location , 
industry , 
total_laid_off , 
percentage_laid_off , 
`date` , 
stage , 
country , 
funds_raised_millions ) as row_num from layoffs;

select * from layoffs_staging;

select * from layoffs_staging 
where row_num > 1 ;


select * from layoffs_staging
where company='cazoo' and location = 'london'; # checking the given data are really duplicates # used & updated many times

delete from layoffs_staging 
where row_num > 1;   # deleting the duplicate rows

select * from layoffs_staging
where total_laid_off is null and percentage_laid_off is null; # the data is not useful

delete from layoffs_staging
where total_laid_off is null and percentage_laid_off is null;

select * from layoffs_staging where industry ='' or industry is null;             # --> 1
select distinct country from layoffs_staging where country like 'united states%'; # --> 2
-- # I repeatedly used 1 & 2 queries and updated numerous times to find the data that has to be Updated or Deleted.

update layoffs_staging set company = trim(company);
update layoffs_staging set industry = 'Crypto' where industry like 'Crypto%';
update layoffs_staging set country = 'United States' where country like 'united states%';
update layoffs_staging set industry = null where industry ='';

select * from layoffs_staging where company= 'airbnb' and location = 'SF Bay Area';
select * from layoffs_staging t1 join layoffs_staging t2
	on t1.company=t2.company and t1.location=t2.location;

select t1.company , t1.location , t1.industry , t2.industry  from layoffs_staging t1 join layoffs_staging t2
	on t1.company=t2.company and t1.location=t2.location
    where t1.industry is not null and t2.industry is null ;
    
update layoffs_staging t1 join layoffs_staging t2
	on t1.company=t2.company and t1.location=t2.location 
    set t2.industry = t1.industry
    where t1.industry is not null and t2.industry is null ;

 select * from layoffs_staging where company = "Bally's Interactive" and location ='Providence'; # it only has single matching to their company & location.
 
 alter table layoffs_staging
 drop column row_num; # droping column which is not required.
 
 select `date` , str_to_date(`date`, '%m/%d/%Y') from layoffs_staging;
 update layoffs_staging set `date` = str_to_date(`date`, '%m/%d/%Y'); #the date column has been converted into it required form
 alter table layoffs_staging 
modify `date` date; -- > # modify the date column components from Text to Date.
 
select * from layoffs_staging;

