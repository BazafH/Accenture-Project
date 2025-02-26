Select* from learning.walmart_sales;
ALTER table learning.wwalmart_sales
Rename TO walmart_sales;

CREATE TABLE `wal_sls` (
  `Store` int DEFAULT NULL,
  `Date` text,
  `Weekly_Sales` double DEFAULT NULL,
  `Holiday_Flag` int DEFAULT NULL,
  `Temperature` double DEFAULT NULL,
  `Fuel_Price` double DEFAULT NULL,
  `CPI` double DEFAULT NULL,
  `Unemployment` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Insert Into wal_sls
Select* From walmart_sales;
Select DISTINCT Store From wal_sls;
Update wal_sls
Set Store=trim(store)
Where Store is not Null or store <> '' ;

Select* From wal_sls;
Select `Date` From wal_sls;
Update wal_sls
Set `Date`=Str_to_date(`date`,'%d-%m-%Y');
Alter table wal_sls
Modify `date` date;
Select DISTINCT
Date_Format(`date`,'%d-%m-%Y'), `date` from wal_sls;
-- can't Changing data format permanently, it can be shown
Select DISTINCT round(Weekly_Sales,2) From wal_sls;

Select Temperature From wal_sls;

Update wal_sls
Set Temperature = (Temperature-32)*5/9;
-- Renaming column name change old column name without'' new column name without'' data type
Alter table wal_sls
change Temperature temp_C double; 

Select* from wal_sls;
Update wal_sls 
Set temp_C = round(temp_C,2); 

Select Fuel_Price from wal_sls;
Update wal_sls 
Set Fuel_Price = round(Fuel_Price,2); 

Select Fuel_Price from wal_sls;
Update wal_sls 
Set CPI = round(CPI,2); 

Select Unemployment AS U from wal_sls;
UPDATE wal_sls 
SET 
    Unemployment = ROUND(Unemployment, 2);
-- Removing duplicates
/*With CTE1 AS (Select *, row_number() over(  
partition by Store ,`date`, Weekly_Sales , Holiday_Flag , temp_C , Fuel_Price , CPI , Unemployment) As Ro From wal_sls)
Select* from CTE1;*/
-- We can't delete through CTE in MYSQL (Limitation)

/*Select row_number() over(  
partition by Store ,`date`, Weekly_Sales , Holiday_Flag , temp_C , Fuel_Price , CPI , Unemployment) As Ri From wal_sls ;
select*from wal_sls;*/

Select Store ,`date`, Weekly_Sales , Holiday_Flag , temp_C , Fuel_Price , CPI , Unemployment, count(*) from wal_sls 
Group by Store ,`date`, Weekly_Sales , Holiday_Flag , temp_C , Fuel_Price , CPI , Unemployment;

Select* from wal_sls;

Select date_format(`date`, '%d-%m-%Y') from wal_sls; 
-- How to count no. of columns in sql
SELECT count(*)
FROM information_schema.columns
WHERE table_name = 'wal_sls';

-- Exploratory data analytics
-- Determining sales per year for each store
-- max earning of the store
-- max earning of each store
-- min sales of each store and its relation with fuel_price, CPi and unemployment

/*Select round(avg(Weekly_sales),2), year(date), store from wal_sls
Where store in (Select store from wal_sls Group by year(date),Store Having avg(Weekly_sales)>
Group by year(date),Store ;*/

select store,`date`, avg(temp_C) over(partition by store, year(date)), avg(fuel_price) over(partition by store, year(date)) from wal_sls
where `date` like('2010%');

Select round(avg(temp_C),2),round(avg(fuel_price),2), substring(`date`,1,7), store from wal_sls

Group by substring(`date`,1,7),Store;

-- No correlation between temperature and fuel price
-- Ranking of max sales with respect to store
Select max(Weekly_sales), min(Weekly_sales),  store , dense_rank() over(order by max(Weekly_sales) desc) from Wal_sls
Group by store ;

/*With CTE1 AS (
Select dense_rank() over(), max(Weekly_sales) over(partition by store) ,min(Weekly_sales) over(partition by store), store  from Wal_sls order by max(Weekly_sales))
Select* from CTE1 group by store Order by max(Weekly_sales); */

Select * from wal_sls where  weekly_sales =  (Select max(Weekly_sales) from wal_sls);


Select store,year(`date`), round(avg(CPI),2), round(avg(Unemployment),2), round(avg(Weekly_sales),2) , round(avg(Fuel_Price),2) from wal_sls
Group by store, year(`date`) ;
-- Corelation between CPI and fuel, Fuel increases CPI increases.
Select store,year(`date`), round(avg(CPI),2), round(avg(Fuel_Price),2) from wal_sls group by store, year(`date`);

-- holidays affecting weekly sales High public holidays, more sales
Select  W1.store, avg(W1.weekly_sales), avg(W2.weekly_sales) from wal_sls W1
Join wal_sls W2
On W2.store = W1.store
Where W1.Holiday_Flag>=1 and W2.Holiday_Flag=0
Group by store  ;

