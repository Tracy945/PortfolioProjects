-- Original table includes house price data of areas from all across NSW. 
-- Use sub-query "not in (select distinct postalCode from [dbo].[SydneyHousePrices] join dbo.GreaterSydneyLGA on postalCode = PostCode)"
-- to find the data that are not in the Greater Sydney Region using post codes and delete them. 

Delete from SydneyHousePrices
where  postalCode not in (
  select distinct postalCode 
  from SydneyHousePrices 
  join dbo.GreaterSydneyLGA on postalCode = PostCode
  )


-- Find the 10 suburbs with the highest average sell price in year 2019 in descending order. 

select top 10 suburb, postalCode, Round(Avg(sellPrice)/1000000, 3) as SellPriceInMillion$ 
from SydneyHousePrices 
where  Date >= '2019-01-01' 
Group by suburb, postalCode
Order by 3 DESC

-- Find the property with the lowest sell price with at least 3 bedrooms in Randwick in year 2013.

Select * from SydneyHousePrices
Where suburb = 'Randwick' AND
bed >= 3 AND
Year(Date) = 2013 AND
sellPrice = (
  select Min(sellPrice)
  from SydneyHousePrices
  Where suburb = 'Randwick' AND bed >= 3 AND Year(Date) =2013
  )
   

-- Let's find out the average house price difference between 2010 and 2019 in each suburb using temporary table.

Create Table #2010Price
(
    suburb VARCHAR(255),
	postalCode float,
	SellPrice2010 float
)
INSERT INTO #2010Price
select  suburb, postalCode, Round(Avg(sellPrice)/1000000, 3) 
from SydneyHousePrices
where (Date >= '2010-01-01' and Date < '2011-01-01') 
Group by suburb, postalCode

Create Table #2019Price
(
    suburb VARCHAR(255),
	postalCode float,
	SellPrice2019 float
)
INSERT INTO #2019Price
select  suburb, postalCode, Round(Avg(sellPrice)/1000000, 3) 
from SydneyHousePrices
where Date >= '2019-01-01'  
Group by suburb, postalCode

Select #2019Price.suburb, #2019Price.postalCode, #2019Price.SellPrice2019 - #2010Price.SellPrice2010
From #2019Price Join #2010Price On #2010Price.suburb = #2019Price.suburb
Where #2019Price.SellPrice2019 is not NULL AND #2010Price.SellPrice2010 is not NULL
Order by 3 Desc


-- Create a table that shows the average house price in Maroubra each year.  

create table dbo.avgprice (
  price float null,
  suburb varchar(100) null,
  yr int null
)

insert into avgprice 
Select distinct CAST(Avg(SydneyHousePrices.sellPrice) OVER (Partition by YEAR(Date)) as int), SydneyHousePrices.suburb, Year(Date)  
From SydneyHousePrices
Where suburb = 'Maroubra'
Order by 3









 