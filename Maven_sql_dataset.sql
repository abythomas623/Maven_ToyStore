-- selecting sales table
select *
from MavensToyStore..sales


-- selecting stores table
select *
from MavensToyStore..stores


-- selecting products table
select *
from MavensToyStore..products


-- selecting products table
select *
from MavensToyStore..inventory


-- checking for duplication in sales table--
select
 distinct store_id
 from MavensToyStore..sales
 -- total store = 50 so no dulpicates

select
 distinct Product_ID
 from MavensToyStore..sales
 -- total products = 35 so no dulpicates

select
 sum(Units) as totalunits
 from MavensToyStore..sales
 -- total units = 1090565 so no dulpicates


-- combining Products, Sales and Stores data

select *
from 
 (
  MavensToyStore..sales
  left join MavensToyStore..stores on sales.Store_ID = stores.Store_ID
  left join MavensToyStore..products on sales.Product_ID = products.product_id
 )

-- preparing data for anaylsis by calculating and arranging data 

select Sale_ID, 
       Date, 
       sales.Store_ID, 
	   sales.Product_ID, 
	   sales.Units, 
	   Store_Name, 
	   Store_City, 
	   Store_Location, 
	   Product_Name, 
	   Product_Category, 
	   Product_Cost * Units as Expenses, 
	   Product_Price * Units as Revenue, 
	   Product_Price * Units - Product_Cost * Units  as Profits
from 
 (
  MavensToyStore..sales
  left join MavensToyStore..stores on sales.Store_ID = stores.Store_ID
  left join MavensToyStore..products on sales.Product_ID = products.product_id
 )


-- Finding Total expenses, profits and revenue
select  
	   sum (cast (Product_Cost * Units as decimal (10,2)))as Total_Expenses, 
	   sum (cast (Product_Price * Units as decimal (10,2))) as Total_Revenue, 
	   sum (Product_Price * Units - Product_Cost * Units) as Total_Profits,
	   sum (units) as Total_units_sold
from 
 (
  MavensToyStore..sales
  left join MavensToyStore..stores on sales.Store_ID = stores.Store_ID
  left join MavensToyStore..products on sales.Product_ID = products.product_id
 )


-- product wise deatils - sorted based on profits 
select  
	   sales.Product_ID, 
	   Product_Name,
	   Product_Category,
	   sum (units) as Total_units_sold,
	   sum (cast (Product_Cost * Units as decimal (10,2)))as Total_Expenses, 
	   sum (cast (Product_Price * Units as decimal (10,2))) as Total_Revenue, 
	   sum (Product_Price * Units - Product_Cost * Units) as Total_Profits
from 
 (
  MavensToyStore..sales
  left join MavensToyStore..stores on sales.Store_ID = stores.Store_ID
  left join MavensToyStore..products on sales.Product_ID = products.product_id
 )
group by sales.Product_ID, Product_Name, Product_Category
order by Total_Profits DESC


-- product category wise details 
select 
	   Product_Category,
	   sum (units) as Total_units_sold,
	   sum (cast (Product_Cost * Units as decimal (10,2)))as Total_Expenses, 
	   sum (cast (Product_Price * Units as decimal (10,2))) as Total_Revenue, 
	   sum (Product_Price * Units - Product_Cost * Units) as Total_Profits
from 
 (
  MavensToyStore..sales
  left join MavensToyStore..stores on sales.Store_ID = stores.Store_ID
  left join MavensToyStore..products on sales.Product_ID = products.product_id
 )
group by Product_Category
order by Total_Profits DESC



-- Profits based on store location
select 
	   Store_Location,
	   sum (Product_Price * Units - Product_Cost * Units) as Total_Profits,
	   count (distinct sales.Store_ID) as Count_of_stores
from 
 (
  MavensToyStore..sales
  left join MavensToyStore..stores on sales.Store_ID = stores.Store_ID
  left join MavensToyStore..products on sales.Product_ID = products.product_id
 )
group by Store_Location
order by Total_Profits DESC


-- best performing cities and based on highest profit generating location
select Top 5
       sales.Store_ID, 
	   Store_Name, 
	   Store_City, 
	   Store_Location, 
	   sum (cast (Product_Price * Units as decimal (10,2))) as Total_Revenue, 
	   sum (Product_Price * Units - Product_Cost * Units) as Total_Profits,
	   sum (units) as Total_units_sold
from 
 (
  MavensToyStore..sales
  left join MavensToyStore..stores on sales.Store_ID = stores.Store_ID
  left join MavensToyStore..products on sales.Product_ID = products.product_id
 )
where Store_Location = 'Airport' or Store_Location = 'Downtown'  
group by  sales.Store_ID, Store_Name, Store_City, Store_Location
order by Total_Profits DESC


-- Store with most Stocks in hand
select Top 10
       Store_ID,
	   Sum (Stock_on_hand) as Stock_in_hand
from MavensToyStore..inventory
group by Store_ID
order by Stock_in_hand DESC


-- products with zero stock in hand
select 
       Product_ID,
	   Sum (Stock_on_hand) as Stock_in_hand
from MavensToyStore..inventory
where Stock_on_hand = 0
group by Product_ID
order by Stock_in_hand DESC


-- quater wise data for each year
select 
       convert (varchar(10),date, 103) as Dates,
	   Datepart(year, Date) as Fin_year,
	   Datepart(quarter, Date) as Quarter_year,
	   sum (units) as Total_units_sold,
	   sum (cast (Product_Cost * Units as decimal (10,2)))as Total_Expenses, 
	   sum (cast (Product_Price * Units as decimal (10,2))) as Total_Revenue, 
	   sum (Product_Price * Units - Product_Cost * Units) as Total_Profits
from 
 (
  MavensToyStore..sales
  left join MavensToyStore..stores on sales.Store_ID = stores.Store_ID
  left join MavensToyStore..products on sales.Product_ID = products.product_id
 )
group by Date
order by Fin_year DESC


-- creating views for later visulisation


-- creating view for product wise details
create view Product_wise_details as
select Sale_ID, 
       Date, 
       sales.Store_ID, 
	   sales.Product_ID, 
	   sales.Units, 
	   Store_Name, 
	   Store_City, 
	   Store_Location, 
	   Product_Name, 
	   Product_Category, 
	   Product_Cost * Units as Expenses, 
	   Product_Price * Units as Revenue, 
	   Product_Price * Units - Product_Cost * Units  as Profits
from 
 (
  MavensToyStore..sales
  left join MavensToyStore..stores on sales.Store_ID = stores.Store_ID
  left join MavensToyStore..products on sales.Product_ID = products.product_id
 )

-- selecting Product_wise_details
select *
from Product_wise_details

-- creating view for Location_wise_comparsion
create view Location_wise_comparsion as
select 
	   Store_Location,
	   sum (Product_Price * Units - Product_Cost * Units) as Total_Profits,
	   count (distinct sales.Store_ID) as Count_of_stores
from 
 (
  MavensToyStore..sales
  left join MavensToyStore..stores on sales.Store_ID = stores.Store_ID
  left join MavensToyStore..products on sales.Product_ID = products.product_id
 )
group by Store_Location
--order by Total_Profits DESC

-- selecting Location_wise_comparsion
select *
from Location_wise_comparsion

-- Creating view for Category_wise_product_comprasion
create view Category_wise_product_comprasion as
select 
	   Product_Category,
	   sum (units) as Total_units_sold,
	   sum (cast (Product_Cost * Units as decimal (10,2)))as Total_Expenses, 
	   sum (cast (Product_Price * Units as decimal (10,2))) as Total_Revenue, 
	   sum (Product_Price * Units - Product_Cost * Units) as Total_Profits
from 
 (
  MavensToyStore..sales
  left join MavensToyStore..stores on sales.Store_ID = stores.Store_ID
  left join MavensToyStore..products on sales.Product_ID = products.product_id
 )
group by Product_Category
--order by Total_Profits DESC

-- selecting Location_wise_comparsion
select *
from Category_wise_product_comprasion

-- Creating view for Quarter_wise_data
create view Quarter_wise_data as
select 
       convert (varchar(10),date, 103) as Dates,
	   Datepart(year, Date) as Fin_year,
	   Datepart(quarter, Date) as Quarter_year,
	   sum (units) as Total_units_sold,
	   sum (cast (Product_Cost * Units as decimal (10,2)))as Total_Expenses, 
	   sum (cast (Product_Price * Units as decimal (10,2))) as Total_Revenue, 
	   sum (Product_Price * Units - Product_Cost * Units) as Total_Profits
from 
 (
  MavensToyStore..sales
  left join MavensToyStore..stores on sales.Store_ID = stores.Store_ID
  left join MavensToyStore..products on sales.Product_ID = products.product_id
 )

group by Date
--order by Fin_year DESC

-- selecting Location_wise_comparsion
select *
from Quarter_wise_data

-- creating view stock_in_hands
create view stock_in_hands as
select
       Store_ID,
	   Sum (Stock_on_hand) as Stock_in_hand
from MavensToyStore..inventory
group by Store_ID
--order by Stock_in_hand DESC

-- selecting stock_in_hand
select *
from stock_in_hands

-- Creating view for store_city_performance
create view store_city_performance as
select 
       sales.Store_ID, 
	   Store_Name, 
	   Store_City, 
	   Store_Location, 
	   sum (cast (Product_Price * Units as decimal (10,2))) as Total_Revenue, 
	   sum (Product_Price * Units - Product_Cost * Units) as Total_Profits,
	   sum (units) as Total_units_sold
from 
 (
  MavensToyStore..sales
  left join MavensToyStore..stores on sales.Store_ID = stores.Store_ID
  left join MavensToyStore..products on sales.Product_ID = products.product_id
 )
where Store_Location = 'Airport' or Store_Location = 'Downtown'  
group by  sales.Store_ID, Store_Name, Store_City, Store_Location
--order by Total_Profits DESC

-- selecting store_city_performance
select *
from store_city_performance