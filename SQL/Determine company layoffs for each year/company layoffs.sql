Create database Project1;
select* from Project1.layoffs;

-- 1. Remove duplicates
-- 2. Standadize the data (issues with spelling etc.) by checking through DISTINCT
-- 3. Null values or blank values
-- 4. Don't delete anything from raw data. Make the table and then delete columns in it. (Same data set is used by companies for different processes)

Select*, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions order by total_laid_off desc ) As `row` from layoffs_staging;
 
 With firstCTE  AS (Select*,
 row_number() over(
 partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as R
 From layoffs_staging)
 
 Select* From firstCTE where R>1;
 CREATE TABLE `layoffs2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL, `row-numb` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Select* From layoffs2;
Insert Into layoffs2 
Select*, row_number() over(
 partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as `row-numb`from layoffs;
 


Select DISTINCT location From layoffs2;

Select Distinct Company From layoffs2;
Update layoffs2
Set location='Malmö',
	location='Düsseldorf'
Where location IN ('MalmÃ¶','DÃ¼sseldorf');

Select Distinct industry From layoffs2;
Update layoffs2
Set industry='Crypto'
Where industry LIKE 'Crypto%';

Select Distinct* From layoffs2;

Select`date`from layoffs2;
Update layoffs2
SET `date`= str_TO_date (`date`,'%m/%d/%Y');
Alter table layoffs2
Modify `date`date;
Select DISTINCT country from layoffs2;
Update layoffs2
Set Country=trim(trailing'.'From Country); 

Select* from layoffs2
Where (total_laid_off IS NULL OR total_laid_ofF='') AND (percentage_laid_off IS NULL OR percentage_laid_ofF='');
 -- AND total_laid_ofF=''
 
 Select* from layoffs2
 Where industry IS NULL OR industry ='';
--  
 Select t1.company, t1.industry, t2.industry, t1.total_laid_off, t1.percentage_laid_off
 From layoffs2 t1
 Join layoffs2 t2
 ON t1.company=t2.company
 Where (t1.industry IS NULL OR t1.industry='')
 AND (t2.industry IS NOT NULL OR t2.industry<>'');

Update layoffs2 
Set industry=null
Where industry='';
Update layoffs2 t1
Join layoffs2 t2
 ON (t1.company=t2.company AND t1.location = t2.location)
 SET t1.industry=t2.industry
 Where (t1.industry IS NULL OR t1.industry='')
 AND (t2.industry IS NOT NULL OR t2.industry!='');
 
 Delete 
 From layoffs2 
 Where total_laid_off IS NULL AND percentage_laid_off IS NULL;
 
Select company, sum(total_laid_off) AS A, max(percentage_laid_off) From layoffs2
Group by company Order by A desc;

Select company, Substring(`date`,1,7) AS `year`, sum(total_laid_off) over(order by company) AS laid_off, max(percentage_laid_off) over (order by `date`) AS P from layoffs2;
With Rolling_sum As (Select Substring(`date`,1,7) as `year`, sum(total_laid_off) AS laid_off from layoffs2 Where  Substring(`date`,1,7) IS NOT NULL Group by 1 order by 1)
Select `year`, sum(laid_off) over(order by `year`) As rollingsum, laid_off 
From Rolling_sum ;

With Company_year (company, `date`,total_laid_off)
As (
Select company, year(`date`), Sum(total_laid_off) from layoffs2
Group by company,year(`date`)
), ranking AS (Select*, dense_rank() over(Order by total_laid_off DESC) As RANKED from Company_year Where total_laid_off IS NOT NULL) ;
Select* from ranking where Ranked<=5;
WITH RANKER AS
(Select sum(total_laid_off),
dense_rank() over( Partition by year(`date`) Order by sum(total_laid_off) desc) AS ranking, year(`date`),company From layoffs2 Where year(`date`) IS NOT NULL
-- OR (Select dense_rank() over(Partition by year(`date`) Order by sum(total_laid_off) desc) FROM layoffs2 Group by year(`date`), company ) <=5
Group by year(`date`), company)

Select* from Ranker
Where Ranking<=5;
