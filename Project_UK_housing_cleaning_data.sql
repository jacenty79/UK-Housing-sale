


--PAON_Primary_Addressable_Object_Name -- (typically the house number or name)
--SAON_Secondary_Addressable_Object_Name -- (if there is a sub-building, for example, the building is divided into flats)


-- checking if column Unique_code is for Unique 
SELECT 
COUNT(Unique_code) rowI , Unique_code
FROM [dbo].[pp-2020-part1]
GROUP BY Unique_code
HAVING COUNT (Unique_code) > 1
ORDER BY Unique_code


SELECT * FROM  [dbo].[pp-2020-part1] -- 441358 rows before cleaning 

-- remove duplicates :
-- looking for duplicates 
-- If  Price , date , postcode , Street , Town_City , District and County is same I can assume that data is duplicated 
GO ;
WITH CTE_duplicate as (
SELECT 
ROW_NUMBER () OVER (PARTITION BY  
							Price ,
							Date ,
							Postcode ,
							Street , 
							Town_City ,
							District ,
							County 
ORDER BY Unique_code) as Rnum
FROM [dbo].[pp-2022]
)
SELECT * FROM CTE_duplicate 
WHERE Rnum > 1    ----------------- !!!!!!!!!!!---------------- Found 5460 duplicated rows 



-- Now additional check in detail before deleting duplicates 
WITH CTE_duplicate as (
SELECT 
ROW_NUMBER () OVER (PARTITION BY  
							Price ,
							Date ,
							Postcode ,
							Street , 
							Town_City ,
							District ,
							County 
ORDER BY Unique_code) as Rnum
						   ,Price ,
							Date ,
							Postcode ,
							Street , 
							Town_City ,
							District ,
							County 
FROM [dbo].[pp-2022]
)
SELECT * FROM CTE_duplicate 
WHERE Rnum > 1


-- Removing duplicates from table 
GO ;
WITH CTE_duplicate as (
SELECT 
ROW_NUMBER () OVER (PARTITION BY  
							Price ,
							Date ,
							Postcode ,
							Street , 
							Town_City ,
							District ,
							County 
ORDER BY Unique_code) as Rnum
FROM [dbo].[pp-2022]
)
DELETE FROM CTE_duplicate 
WHERE Rnum > 1

SELECT * FROM  [dbo].[pp-2020-part1] -- 435898 rows after removing duplicates ### NO DUPLICATES AT THIS POINT 

-- !!!! THE TASK OF LOOKING FOR DUPLICATES AND REMOVING THEM WAS REPEATED IN ALL TABLES 
--      FOR SAVING SPACE THE TASK WAS DONE ONLY ONCE FOR TABLE [dbo].[pp-2020-part1] AS EXAMPLE 




-- Creating table to keep whole year 2020 in one table 

CREATE TABLE  UK_Sale_2021
 (
 Unique_code      nvarchar (50) ,
 Price			  decimal(15,2) ,
 SaleDate		  date        ,
 Postcode         nvarchar(20) ,
 x				  nvarchar(20) ,
 y				  nvarchar(20),
 z                nvarchar(20),
 PAON             nvarchar (200) ,
 SAON             nvarchar (200) ,
 Street           nvarchar (200) ,
 locality         nvarchar (200) ,
 Town_City        nvarchar (200),
 District         nvarchar (200)  ,
 County			  nvarchar (200) ,
 O			      nvarchar(20),
 P				  nvarchar(20),
 )


 -- CLEANING AND SORTING COLUMNS then INSERTING INTO ONE TABLE 
 --	 removing unnecessary curlly brackets { } form column Unique_code
 -- changing price column fron int to decimal 
 -- changing column Date from format datetime to date as time was incorrect always as  00:00:00.0000000
 --####  2020
 INSERT INTO  UK_Sale_2020 
       SELECT SUBSTRING(Unique_code ,CHARINDEX('{',Unique_code )+1,CHARINDEX('}',Unique_code )-2) AS [Unique_code] ,
       CAST(Price as DECIMAL(15,2))as [Price]  , 
	   CAST (Date as date ) as [SaleDate]      , 
	   Postcode , x,y,z,
	   PAON ,
	   SAON , Street , Locality , Town_City ,District ,County ,o,p  
	   FROM [dbo].[pp-2020-part1]
 UNION 
       SELECT SUBSTRING(Unique_code ,CHARINDEX('{',Unique_code )+1,CHARINDEX('}',Unique_code )-2) ,
       CAST(Price as DECIMAL(15,2))as [Price]  , 
	   CAST (Date as date ) as [SaleDate]      , 
	   Postcode , x,y,z,
	   PAON ,
	   SAON , Street , Locality , Town_City ,District ,County ,o,p 
	   FROM [dbo].[pp-2020-part2] 



--####  2021
 INSERT INTO  UK_Sale_2021 
       SELECT SUBSTRING(Unique_code ,CHARINDEX('{',Unique_code )+1,CHARINDEX('}',Unique_code )-2) AS [Unique_code] ,
       CAST(Price as DECIMAL(15,2))as [Price]  , 
	   CAST (Date as date ) as [SaleDate]      , 
	   Postcode , x,y,z,
	   PAON ,
	   SAON , Street , Locality , Town_City ,District ,County ,o,p  
	   FROM [dbo].[pp-2021-part1]
 UNION 
       SELECT SUBSTRING(Unique_code ,CHARINDEX('{',Unique_code )+1,CHARINDEX('}',Unique_code )-2) ,
       CAST(Price as DECIMAL(15,2))as [Price]  , 
	   CAST (Date as date ) as [SaleDate]      , 
	   Postcode , x,y,z,
	   PAON ,
	   SAON , Street , Locality , Town_City ,District ,County ,o,p 
	   FROM [dbo].[pp-2021-part2] 

/* !!!!
Proccess looking for and deleting dupliucates need to be repated at this point
as both tables pp-2020-part1 and pp-2020-part2  could have duplicates 
UNION will NOT remove duplicates as column Unique_code is Unique for both tables 
or can be done once after Merging both parts ;-)
*/

  -- removing unnecessary columns
 ALTER TABLE UK_Sale_2021 DROP COLUMN x
 ALTER TABLE UK_Sale_2021 DROP COLUMN y
 ALTER TABLE UK_Sale_2021 DROP COLUMN Z
 ALTER TABLE UK_Sale_2021 DROP COLUMN O
 ALTER TABLE UK_Sale_2021 DROP COLUMN P


 -- NOW SORTING THIRD TABLE [dbo].[pp-2022] CREATING NEW TABLE WITH SAME STRUCTURE AS 2020 AND 2021
 SELECT  SUBSTRING(Unique_code ,CHARINDEX('{',Unique_code )+1,CHARINDEX('}',Unique_code )-2)AS [Unique_code] ,
       CAST(Price as DECIMAL(15,2))as [Price]  , 
	   CAST (Date as date ) as [SaleDate]      , 
	   Postcode , x,y,z,
	   PAON ,
	   SAON , Street , Locality , Town_City ,District ,County ,o,p 
	   INTO UK_Sale_2022
	   FROM [dbo].[pp-2022]
  -- removing unnecessary columns
 ALTER TABLE UK_Sale_2022 DROP COLUMN x
 ALTER TABLE UK_Sale_2022 DROP COLUMN y
 ALTER TABLE UK_Sale_2022 DROP COLUMN Z
 ALTER TABLE UK_Sale_2022 DROP COLUMN O
 ALTER TABLE UK_Sale_2022 DROP COLUMN P



-- checking structure of tables 
SELECT TOP(5) * FROM UK_Sale_2020
SELECT TOP(5) * FROM UK_Sale_2021
SELECT TOP(5) * FROM UK_Sale_2022

--#############################################################################################################################

 -- Whole market sale sum in pounds for 2020 
 -- Numbers of sold properties in 2020 in the UK
pSELECT 
FORMAT ( SUM(Price),'C','EN-GB'  )as [Whole_market_sale]
,COUNT (*) as [Numbers_of_sold_properties_in_2020_in_Uk]
FROM UK_Sale_2020


 -- Whole market sale sum in pounds for 2021
 -- Numbers of sold properties in 2021 in the UK
SELECT 
FORMAT ( SUM(Price),'C','EN-GB'  )as [Whole_market_sale]
,COUNT (*) as [Numbers_of_sold_properties_in_2020_in_Uk]
FROM UK_Sale_2021


 -- Whole market sale sum in pounds for 2022
 -- Numbers of sold properties in 2022 in the UK
SELECT 
FORMAT ( SUM(Price),'C','EN-GB'  )as [Whole_market_sale]
,COUNT (*) as [Numbers_of_sold_properties_in_2020_in_Uk]
FROM UK_Sale_2022




--################################################   Sale by Town / City #############################################################################
-- GroupingFlag = 1 Sum of whole sale

--  2020
SELECT 
 FORMAT ( SUM(Price),'C','EN-GB'  )as [Sale by region]
,GROUPING (Town_City) as [GroupingFlag]
, Town_City
FROM UK_Sale_2020
GROUP BY ROLLUP  ( Town_City )
ORDER BY [Sale by region] DESC


--2021
SELECT 
 FORMAT ( SUM(Price),'C','EN-GB'  )as [Sale by region]
,GROUPING (Town_City) as [GroupingFlag]
, Town_City
FROM UK_Sale_2021
GROUP BY ROLLUP  ( Town_City )
ORDER BY [Sale by region] DESC
  

--2022
SELECT 
 FORMAT ( SUM(Price),'C','EN-GB'  )as [Sale by region]
,GROUPING (Town_City) as [GroupingFlag]
, Town_City
FROM UK_Sale_2022
GROUP BY ROLLUP  ( Town_City )
ORDER BY [Sale by region] DESC







--################################################   Sale by County #############################################################################
-- GroupingFlag = 1 Sum of whole sale 

--2020
SELECT 
 FORMAT ( SUM(Price),'C','EN-GB'  )as [Sale by region]
,GROUPING (County) as [GroupingFlag]
, County
FROM UK_Sale_2020
GROUP BY ROLLUP  ( County )

----2021
SELECT 
FORMAT ( SUM(Price),'C','EN-GB'  )as [Sale by region]
,GROUPING (County) as [GroupingFlag]
, County
FROM UK_Sale_2021
GROUP BY ROLLUP  ( County )

----2022
SELECT 
FORMAT ( SUM(Price),'C','EN-GB'  )as [Sale by region]
,GROUPING (County) as [GroupingFlag]
, County
FROM UK_Sale_2022
GROUP BY ROLLUP  ( County )



--################################################   Average house price by year #############################################################################
select Format(avg(Price),'C','en-GB' )as [AveragePricein2020]  from UK_Sale_2020
select Format(avg(Price),'C','en-GB' )as [AveragePricein2021]  from UK_Sale_2021
select Format(avg(Price),'C','en-GB' )as [AveragePricein2022]  from UK_Sale_2022




-- CALCULATE DIFFERENCE BETWEEN YEARS  calculation patern  >>>>>   select ( Val1- Val2 ) / Val2  * 100
-- percentage value ROUNDED 
-- percentage value CONVERTED into  DECIMAL(3,2) or NUMERIC(3,2)
SELECT  
[AveragePricein2020] = (select FORMAT( avg(Price) ,'C','en-GB' )  from UK_Sale_2020),
[AveragePricein2021] = (select FORMAT( avg(Price) ,'C','en-GB' )  from UK_Sale_2020),
[AveragePricein2022] = (select FORMAT( avg(Price) ,'C','en-GB' )  from UK_Sale_2020),
 CONVERT( DECIMAL(3,2) ,ROUND(( (select avg(Price)  from UK_Sale_2021)- (select avg(Price)  from UK_Sale_2020) ) / (select avg(Price)  from UK_Sale_2020) *  100 ,2) )AS [Difference%Between2020and2021]
,CONVERT( DECIMAL(3,2) ,ROUND(( (select avg(Price)  from UK_Sale_2022)- (select avg(Price)  from UK_Sale_2021) ) / (select avg(Price)  from UK_Sale_2022) *  100 ,2) )AS [Difference%Between2021and2022]
,CONVERT( DECIMAL(3,2) ,ROUND(( (select avg(Price)  from UK_Sale_2022)- (select avg(Price)  from UK_Sale_2020) ) / (select avg(Price)  from UK_Sale_2020) *  100 ,2) )AS [Difference%Between2022and2020]

-- Sales price increased by 2.94 compared to the previous year in 2021 
-- Sales price increased by 3.38 compared to the previous year in 2022 
-- Sales price increased by 6.54 in two years -  between 2020 and 2022





-- CREATING FIRST VIEW 

-- assuming that postcode ,Paon , Saon , Street , City collumns are same we dealing with the same property 
-- is  any property was sold more than one time in 3 years if so then whether with profit or loss
-- logic for FULL OUTER JOIN : Example if propert was sold in 2020 and 2021 but not in 2022 we want to see it 
-- where s20.SaleDate is not null and s21.SaleDate is not null is needed to exclude property sold only once 
-- result 67 properties was sold more than once in three years period time 
GO
CREATE VIEW Difference_for_proprty_that_was_sold_more_than_once_2020_2022 as 
SELECT 
s20.Price as [Price2020] ,s20.SaleDate as [SaleDate_2020] ,
--s20.Postcode ,s20.PAON ,s20.SAON ,s20.Street,s20.locality,s20.Town_City,s20.District,s20.County  ,
s21.Price as [Price2021] ,s21.SaleDate as [SaleDate_2021] ,
--s21.Postcode ,s21.PAON ,s21.SAON ,s21.Street,s21.locality,s21.Town_City,s21.District,s21.County ,
s22.Price as [Price2022],s22.SaleDate  as [SaleDate_2022]
--s22.Postcode ,s22.PAON ,s22.SAON ,s22.Street,s22.locality,s22.Town_City,s22.District,s22.County
,[2020_TO_2021] = (s21.Price - s20.Price ) 
, ( s21.Price -  s20.Price) /s20.Price * 100 as [%_between_2020_and_2021]
,[2021_TO_2022] = (s22.Price - s21.Price)
, ( s22.Price -  s21.Price) /s21.Price * 100 as [%_between_2021_and_2022]
,[2022_TO_2020] = (s22.Price - s20.Price) 
, ( s22.Price -  s20.Price) /s20.Price * 100 as [%_between_2022_and_2020]
FROM UK_Sale_2020 AS s20
full outer JOIN  UK_Sale_2021 AS s21
ON  s20.Postcode  = s21.Postcode
AND s20.PAON      = s21.PAON
AND s20.SAON      = s21.SAON
AND s20.Street    = s21.Street
AND s20.Town_City = s21.Town_City
full outer join UK_Sale_2022 as s22
ON  (s22.Postcode  = s21.Postcode  and s22.Postcode  = s20.Postcode)
AND (s22.PAON      = s21.PAON      and s22.PAON      = s20.PAON)
AND (s22.SAON      = s21.SAON      and s22.SAON      = s20.SAON)
AND (s22.Street    = s21.Street    and s22.Street    = s20.Street)
AND (s22.Town_City = s21.Town_City and s22.Town_City = s20.Town_City )
where s20.SaleDate is not null and s21.SaleDate is not null and s22.SaleDate is not null




-- SELECTING VIEW 
-- changing view to see is property was sold with profit or loss 
-- what difference between selling in Pounds and procentage 
-- separate column to pint first , second and third sales 
-- separate column to flag if ptoperty was sold with profit or loss
SELECT
'FirstSellIn2020--->>>' as [Info]
, FORMAT ([2020_TO_2021] , 'C','en-GB' ) as [2020_2021]
,CAST ( [%_between_2020_and_2021] AS DECIMAL(6,2) ) AS [Percentage20_21]
, CASE WHEN [2020_TO_2021] < 0 THEN 'SaleWithLoss' 
       WHEN [2020_TO_2021] > 0 THEN 'SaleWithProfit'
	   ELSE 'SoldForTheSamePrice' END  AS [Sales_Result_2020_and_2021]
,
'SecondSellIn2021--->>>' as [Info]
, FORMAT ([2021_TO_2022] , 'C','en-GB' ) as [2021_2022]
,CAST ( [%_between_2021_and_2022] AS DECIMAL(6,2) )  AS [Percentage21_22]
, CASE WHEN [2021_TO_2022] < 0 THEN 'SaleWithLoss' 
       WHEN [2021_TO_2022] > 0 THEN 'SaleWithProfit'
	   ELSE 'SoldForTheSamePrice' END  AS [Sales_Result_2021_and_2022]
,
'ThirdSellIn2022--->>>' as [Info]
, FORMAT ([2022_TO_2020], 'C','en-GB' ) as [2022_2020]
,CAST ( [%_between_2022_and_2020] AS DECIMAL(6,2) ) AS [Percentage20_22]
, CASE WHEN [2022_TO_2020] < 0 THEN 'SaleWithLoss' 
       WHEN [2022_TO_2020] > 0 THEN 'SaleWithProfit'
	   ELSE 'SoldForTheSamePrice' END  AS [Result_between_2020_and_2022]
FROM Difference_for_proprty_that_was_sold_more_than_once_2020_2022



/*
 SELECTING DATA PER YEAR TO GET MORE CLEAR VIEW OF TRANSACTION  
 here is result for 2020 :
 Property that was sold twice between 2020 and 2021   = 67 Properies 
 Result of sels of this property (profit / loss)
 How much was profit or loss in pounds 
 How much was profit or loss in percentage  
 How long the property was occupied
 According to data proivided by gov one property ( Flat 10, 25–29 High Street, Leatherhead, KT22 8AB ) 
 in 2020 was sold with loss -£890,000.00 which is -80.91% loss
 this was confirmed by zoopla ---   https://www.zoopla.co.uk/property/uprn/10010537263/
 */
SELECT  
SaleDate_2020, Price2020 
, CASE WHEN [2020_TO_2021] < 0 THEN 'SaleWithLoss' 
       WHEN [2020_TO_2021] > 0 THEN 'SaleWithProfit'
	   ELSE 'SoldForTheSamePrice' END  AS [Sales_Result_2020_and_2021]
 ,SaleDate_2021, Price2021
,'----------->' as [Transaction_result]
, FORMAT ([2020_TO_2021] , 'C','en-GB' ) as [2020_2021]
,CAST ( [%_between_2020_and_2021] AS DECIMAL(6,2) ) AS [Percentage20_21]
,DATEDIFF (Month , SaleDate_2020 , SaleDate_2021) AS [Sold_after_months:]
FROM Difference_for_proprty_that_was_sold_more_than_once_2020_2022
ORDER BY Percentage20_21



SELECT * FROM [dbo].[UK_Sale_2020] where SaleDate = '2020-01-10' and Price = 1100000.00 order by Postcode
--2020-01-10	1100000.00
--9DBAD222-B234-6EB3-E053-6B04A8C0F257	1100000.00	2020-01-10	KT22 8AB	25 - 29
SELECT * FROM  [dbo].[UK_Sale_2021]where Postcode ='KT22 8AB'  order by Postcode
--2021-04-08    210000.00

SELECT * FROM  [dbo].[UK_Sale_2020] where Unique_code = '9DBAD222-B234-6EB3-E053-6B04A8C0F257'
SELECT * FROM  [dbo].[UK_Sale_2021] where Unique_code = 'CB0035E6-3CA3-58AE-E053-6B04A8C091AF'












--########################## top 10 most expensive prtoperty #########################
-- Varchar declaration for formating large numbers
-- DENSE_RANK to include properties sold for same amount 
-- SELECT INTO NEW TABLE
;

declare @LargeNumberFormat varchar(20)
set @LargeNumberFormat = '0,000#####'  
SELECT TOP(10)
 YEAR(SaleDate)  AS [Year]
 ,DENSE_RANK() OVER ( ORDER BY Price DESC ) AS [Rank]
,'£'++FORMAT (Price ,@LargeNumberFormat,'en-GB') AS [Price]
,CONCAT(PAON,'',Street,'',SAON ) AS [Address]
,Postcode
,Town_City
,District
INTO Most_expensive2020
FROM [dbo].[UK_Sale_2020] ORDER BY Price DESC

-- adding column for google link location 
BEGIN TRANSACTION 
ALTER TABLE Most_expensive2020
ADD Google_Map_location_Link  XML
COMMIT TRANSACTION 




-- This task can be repeated for tables 2021 and 2022

BEGIN TRANSACTION
UPDATE Most_expensive2020 SET Map_location = 'https://www.google.com/maps/place/InterContinental+London+-+the+O2,+an+IHG+Hotel/@51.5030175,-0.0001832,696m/data=!3m2!1e3!4b1!4m9!3m8!1s0x487602a786d042e1:0xe75c7debf7b59834!5m2!4m1!1i2!8m2!3d51.5030175!4d-0.0001832!16s%2Fg%2F11bxfj0ct4?entry=ttu' WHERE [Rank] = 1
UPDATE Most_expensive2020 SET Map_location = 'https://www.google.com/maps/place/159+New+Bond+St,+London+W1S+2UB/@51.5105741,-0.1437854,123m/data=!3m1!1e3!4m6!3m5!1s0x4876052a30b69fb1:0x9b128821daa5ed58!8m2!3d51.5106088!4d-0.1431962!16s%2Fg%2F11bw3hq1t3?entry=ttu' WHERE [Rank] = 2 and Postcode = 'W1S 2UD' 
UPDATE Most_expensive2020 SET Map_location = 'https://www.google.com/maps/place/158+New+Bond+St,+London+W1S+2UB/@51.5107107,-0.1452726,696m/data=!3m2!1e3!4b1!4m6!3m5!1s0x4876052a30c8915d:0xf3600536cf25dcda!8m2!3d51.5107107!4d-0.1430839!16s%2Fg%2F11c24g8j42?entry=ttu' WHERE [Rank] = 2 and Postcode = 'W1S 2UB'
UPDATE Most_expensive2020 SET Map_location = 'https://www.google.com/maps/place/158+New+Bond+St,+London+W1S+2UB/@51.5107107,-0.1452726,696m/data=!3m2!1e3!4b1!4m6!3m5!1s0x4876052a30c8915d:0xf3600536cf25dcda!8m2!3d51.5107107!4d-0.1430839!16s%2Fg%2F11c24g8j42?entry=ttu' WHERE [Rank] = 3
UPDATE Most_expensive2020 SET Map_location = 'https://www.google.com/maps/search/PEAR+TREE+COURTBASTWICK+STREET%09EC1V+3PS%09LONDON%09ISLINGTON/@51.5243233,-0.1006,348m/data=!3m2!1e3!4b1?entry=ttu'  WHERE [Rank] = 4 
UPDATE Most_expensive2020 SET Map_location = 'https://www.google.com/maps/search/LONDON+CITY+AIRWAYS+LONDON+CITY+AIRPORT%09E16+2QQ%09LONDON%09NEWHAM/@51.5037948,0.0486568,696m/data=!3m2!1e3!4b1?entry=ttu' WHERE [Rank] = 5
UPDATE Most_expensive2020 SET Map_location = 'https://www.google.com/maps/place/8+Harpur+St,+London+WC1N+3PA/@51.5206246,-0.1208,696m/data=!3m2!1e3!4b1!4m6!3m5!1s0x48761b399454d0f9:0x26056169e40d0747!8m2!3d51.5206246!4d-0.1186113!16s%2Fg%2F11ppj9_jc3?entry=ttu' WHERE [Rank] = 6
UPDATE Most_expensive2020 SET Map_location = 'https://www.google.com/maps/place/BP+plc/@51.5076602,-0.1366991,696m/data=!3m2!1e3!4b1!4m6!3m5!1s0x487604d13a8e7071:0xfbb5478f2350f02f!8m2!3d51.5070325!4d-0.134066!16s%2Fg%2F1hc0xlcbz?entry=ttu' WHERE [Rank] = 7
UPDATE Most_expensive2020 SET Map_location = 'https://www.google.com/maps/place/2-8a+Rutland+Gate/@51.5015666,-0.1708535,696m/data=!3m2!1e3!4b1!4m6!3m5!1s0x487605942cfc3003:0x8474e94e7073879f!8m2!3d51.5015666!4d-0.1686648!16s%2Fg%2F11bwjcdd4y?entry=ttu' WHERE [Rank] = 8
UPDATE Most_expensive2020 SET Map_location = 'https://www.google.com/maps/place/20+St+''James''s''+Square,+St.+''James''s'',+London/@51.5063597,-0.1386265,696m/data=!3m2!1e3!4b1!4m6!3m5!1s0x487604d73ca8f117:0xf9e14b542c35586c!8m2!3d51.5063597!4d-0.1364378!16s%2Fg%2F11c43w5bkl?entry=ttu' WHERE [Rank] = 9
COMMIT TRANSACTION

SELECT * FROM Most_expensive2020 ORDER BY [Rank]



-- which month was best for sale property 
--  SELECT INTO #TEMP TBLE for additional formating 
SELECT 
MONTH(SaleDate ) as [Month_2020]
,COUNT(Unique_code) as [Quantity]
INTO #Best_sale_of_the_year_2020
FROM [dbo].[UK_Sale_2020]
GROUP BY ROLLUP  (MONTH(SaleDate)  )

SELECT 
CASE
WHEN Month_2020 =  1 THEN 'January'
WHEN Month_2020 =  2 THEN 'February'
WHEN Month_2020 =  3 THEN 'March'
WHEN Month_2020 =  4 THEN 'April'
WHEN Month_2020 =  5 THEN 'May'
WHEN Month_2020 =  6 THEN 'June'
WHEN Month_2020 =  7 THEN 'July'
WHEN Month_2020 =  8 THEN 'August'
WHEN Month_2020 =  9 THEN 'September'
WHEN Month_2020 = 10 THEN 'October'
WHEN Month_2020 = 11 THEN 'November'
WHEN Month_2020 = 12 THEN 'December'
		ELSE  'Year Summary' 
		END AS [M_2020]
,Quantity
,CONVERT (DECIMAL (5,2) ,CAST (Quantity as numeric) / (select Quantity from #Best_sale_of_the_year_2020 where Month_2020 is null ) * 100 ) AS [%_ percentage]
FROM #Best_sale_of_the_year_2020
ORDER BY Month_2020

 
  
-- Another good way to introduce sale data is PIVOT table 
Go;
WITH CTE_Pivot_20_21_22 AS (
SELECT 
price 
,MONTH(SaleDate) as [Mth]
,YEAR (SaleDate) as [Yr]
FROM (
  SELECT * FROM [dbo].[UK_Sale_2020] AS t1
  UNION ALL 
  SELECT * FROM  [dbo].[UK_Sale_2021] AS t2
  UNION ALL  
  SELECT * FROM  [dbo].[UK_Sale_2022] AS t3
  ) AS TemP
) SELECT  *  FROM CTE_Pivot_20_21_22
      PIVOT ( SUM (price) FOR Mth IN ( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) AS Pvt
	  ORDER BY Yr


-- It will be useful to write procedure where we can get data only from provided postcode or Town >>> location 

-- for this task I need join 3 tables 
SELECT * 
        INTO Whole3YearsSale20_21_22 
        FROM (
 SELECT * FROM [dbo].[UK_Sale_2020] AS t1
  UNION ALL 
  SELECT * FROM  [dbo].[UK_Sale_2021] AS t2
  UNION ALL  
  SELECT * FROM  [dbo].[UK_Sale_2022] AS t3
  )  as x



-- ########  TESTING PERFORMANCE ######

-- With such large table there may be performance issues , I need test it 
SELECT * FROM Whole3YearsSale20_21_22 -- This table have now 2 930 416 rows , Table Scan = 23.596 sec
SELECT * FROM Whole3YearsSale20_21_22  where postcode   = 'EN2 8FJ'  -- Table Scan >> Missing Index (Impact 99.9501) -- need create NONCLUSTERED INDEX !
SELECT * FROM Whole3YearsSale20_21_22  where  Town_City = 'LONDON' -- Table Scan 1.441s / 194911 rows / -- No Index necessary  !


CREATE NONCLUSTERED INDEX Indx_Tbl_Whole3YearsSale20_21_22
ON Whole3YearsSale20_21_22 (Postcode) 






-- Creating simple Procedure for Postcode :
GO;
CREATE PROCEDURE prc_postcode_20_21_22
(@Postcode  Nvarchar (10) )
AS
IF EXISTS 
        ( SELECT * FROM Whole3YearsSale20_21_22 WHERE Postcode = @Postcode) 
BEGIN
SELECT * FROM Whole3YearsSale20_21_22 WHERE Postcode = @Postcode
END 
ELSE 
	BEGIN
		 SELECT 'Postcode not exists please check and insert again ' as [Info] , CAST (GETDATE() AS nvarchar (40) ) AS [Date] 
	END 


-- TESTING  
 EXEC prc_postcode_20_21_22 'EN2 8FJ' 
 EXEC prc_postcode_20_21_22 'xxxxxx'







 -- Creating proceddure for Town_City with date parameters 

 go;
 CREATE PROCEDURE prc_Town_City_20_21_22
(@Town_City  Nvarchar (10)  , 
 @Date_from  Date          ,
 @Date_To    Date 
 )
AS
IF EXISTS 
        ( SELECT * FROM Whole3YearsSale20_21_22 WHERE Town_City = @Town_City 
		                                              and SaleDate between @Date_from and @Date_To) 
BEGIN
SELECT * FROM Whole3YearsSale20_21_22 WHERE Town_City = @Town_City 
 and SaleDate between @Date_from and @Date_To
 oRDER BY SaleDate 
END 


-- TESTING 
EXEC prc_Town_City_20_21_22 'LONDON','2020-01-01','2020-01-31'
EXEC prc_Town_City_20_21_22 'Mansfield','2020-01-01','2020-01-31'








--To keep oour data cleac and valuable it will be good idea to prevent any deletion or update on database as data once downloaded for years 2020 - 2022 shouldn`t be changed 

GO
CREATE   TRIGGER trg_TO_PREVENT_DELETE_UPDATE ON  [dbo].[UK_Sale_2020]
INSTEAD OF DELETE , UPDATE 
AS
SET NOCOUNT ON 
declare @ERROR_MESSAGE varchar(400)
SELECT 	@ERROR_MESSAGE		= 
	'Trigger trg_TO_PREVENT_DELETE_UPDATE ON TABLE UK_Sale_2020 - '+
	'Delete or update not allowed on table [dbo].[UK_Sale_2020]'
raiserror( @ERROR_MESSAGE, 16, 1 )

IF @@trancount > 0 BEGIN ROLLBACK END 

RETURN
GO


--drop trigger trg_TO_PREVENT_DELETE_UPDATE
--DISABLE TRIGER trg_TO_PREVENT_DELETE_UPDATE ON [dbo].[UK_Sale_2020]




UPDATE [dbo].[UK_Sale_2020] SET Postcode = 'XXXXX' WHERE Unique_code = '9DBAD221-491E-6EB3-E053-6B04A8C0F257'