-- Data Cleaning Project

-- Dataset: https://www.kaggle.com/datasets/swaptr/layoffs-2022

select *
from layoffs;

-- 1. Remove dups
-- 2. Standardize data
-- 3. Null or blank values
-- 4. Remove any columns

-- Create RAW data, never work on the original table directly, create a staging copy to keep the raw data untouched.
create table layoffs_staging
like layoffs;

insert into layoffs_staging
select *
from layoffs;

select *
from layoffs_staging;

-- 1. Remove dups

-- Draft partition using fewer columns
-- select *,
-- row_number() over(partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
-- from layoffs_staging;

-- Preview duplicates using the full column partition before making any changes
with duplicate_cte as 
(
select *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;

-- select *
-- from layoffs_staging
-- where company = 'Casper';

-- The query below is intentionally commented out — it will not work.
-- with duplicate_cte as 
-- (select *,
-- row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
-- from layoffs_staging)
-- delete -- NOTE: MySQL does not allow DELETE directly from a CTE
-- from duplicate_cte
-- where row_num > 1;

-- Create a second staging table with row_num as a physical column so we can DELETE from it directly.

-- Create the table 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Populate the table
insert into layoffs_staging2
select *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

-- Preview the dups before deleting
select *
from layoffs_staging2
where row_num > 1;

-- Delete dups
delete
from layoffs_staging2
where row_num > 1;

-- Verify result
select *
from layoffs_staging2;


-- 2. Standardize data

-- Trim whitespace from company names
select company, trim(company)
from layoffs_staging2;

-- Apply whitespace trimming
update layoffs_staging2
set company = trim(company);

select distinct industry
from layoffs_staging2;

-- Update the table e.g. 'Crypto Currency', 'CryptoCurrency' → 'Crypto'.
update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

-- Remove trailing periods from country names
-- Targets any country ending in a period, not just known cases (e.g. 'United States.')
select distinct country, trim(trailing '.' from country) -- trim(trailing...... from): coming at the end
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like '%.';

-- Change text date to DATE, STR_TO_DATE parses the text format into a proper date value.
select `date`
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

-- ALTER table: Change the column type from TEXT to DATE now that values are properly formatted.
alter table layoffs_staging2
modify column `date` DATE;

-- Verify result
select *
from layoffs_staging2;
