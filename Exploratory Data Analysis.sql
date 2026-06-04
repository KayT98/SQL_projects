-- Exploratory Data Analysis

select *
from layoffs_staging2;

--

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

--

select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- what company has the most lay offs
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

-- what industry has the most lay offs
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

-- what country has the most lay offs
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

-- what year has the most lay offs
select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;

-- shwo the stage of the company
select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;
-- 

select min(`date`), max(`date`)
from layoffs_staging2;

-- rolling total laid off

select substring(`date`, 1,7) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`, 1,7) is not null
group by `month`
order by 1 asc;

-- CTE

with rolling_total as 
(
select substring(`date`, 1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`, 1,7) is not null
group by `month`
order by 1 asc
)
select `month`, total_off, sum(total_off) over(order by `month`) as rolling_Total
from rolling_total;

--

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

-- 
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;

-- CTE

with company_year (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), company_year_rank as
(select *, dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
)

select *
from company_year_rank
where ranking <= 5;

from rolling_total;

