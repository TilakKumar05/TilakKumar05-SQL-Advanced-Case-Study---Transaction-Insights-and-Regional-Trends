--SQL Advance Case Study
Use Sql_Advanced_Casestudy
Select * From DIM_CUSTOMER
Select * from DIM_DATE
Select * From DIM_LOCATION
Select * From DIM_MANUFACTURER
Select * From DIM_MODEL
Select * From FACT_TRANSACTIONS

 

--Q1--BEGIN 
Select [State]
From DIM_LOCATION
	Inner Join FACT_TRANSACTIONS
		on DIM_LOCATION.IDLocation = FACT_TRANSACTIONS.IDLocation
Where Year([Date]) >= 2005
Group by [State]
--Q1--END


--Q2--BEGIN
Select Top 1 [State],sum(Quantity) as [Total_qty] 
From FACT_TRANSACTIONS 
	Inner Join DIM_LOCATION
		on DIM_LOCATION.IDLocation = FACT_TRANSACTIONS.IDLocation
	inner join DIM_MODEL 
		on Dim_model.IDModel=FACT_TRANSACTIONS.IDModel
	inner join DIM_MANUFACTURER 
		on DIM_MANUFACTURER.IDManufacturer=DIM_MODEL.IDManufacturer
Where DIM_MANUFACTURER.Manufacturer_Name='Samsung' and DIM_LOCATION.Country='US'
Group by DIM_LOCATION.[State]
Order by [Total_qty] desc 	
--Q2--END


--Q3--BEGIN      
Select ZipCode,DIM_MODEL.IDModel,[State],Count(IDCustomer) as [Total_Transaction] 
From FACT_TRANSACTIONS 
	inner join DIM_LOCATION 
		on FACT_TRANSACTIONS.IDLocation=DIM_LOCATION.IDLocation
	inner join DIM_MODEL  
		on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
Group by [State],ZipCode ,DIM_MODEL.IDModel 
--Q3--END


--Q4--BEGIN
Select  Manufacturer_Name,Model_Name,IDModel,Unit_price 
From DIM_MODEL 
	inner join DIM_MANUFACTURER  
		on DIM_MANUFACTURER.IDManufacturer=DIM_MODEL.IDManufacturer
Where Unit_price= (select  MIN(Unit_price) from DIM_MODEL)
--Q4--END


--Q5--BEGIN
With TB1 as (Select Top 5 Manufacturer_Name,DIM_MANUFACTURER.IDManufacturer,Sum(Quantity)as Total_qty ,AVG(TotalPrice) as [Avg_Price] 
From FACT_TRANSACTIONS  
inner join DIM_MODEL on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
inner join DIM_MANUFACTURER  on DIM_MANUFACTURER.IDManufacturer=DIM_MODEL.IDManufacturer
Group by Manufacturer_Name,DIM_MANUFACTURER.IDManufacturer
Order by Total_qty desc,[Avg_Price] desc),
TB2 as (Select Model_Name,IDManufacturer,AVG(TotalPrice) as [Avg] From FACT_TRANSACTIONS 
inner join DIM_MODEL on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
Group by Model_Name,IDManufacturer)
Select Model_Name,[Avg] as Average_Price From TB2 as T2 inner join TB1 as T1 on T2.IDManufacturer=T1.IDManufacturer
--Q5--END


--Q6--BEGIN
Select DIM_CUSTOMER.IDCustomer,Customer_Name, AVG(TotalPrice) as [Average_Amount] 
From DIM_CUSTOMER 
	inner join FACT_TRANSACTIONS 
		on DIM_CUSTOMER.IDCustomer=FACT_TRANSACTIONS.IDCustomer
Where YEAR([Date])=2009 
Group by Customer_Name,DIM_CUSTOMER.IDCustomer
Having  AVG(TotalPrice)>500
--Q6--END

	
--Q7--BEGIN  
Select T1.Model_Name  From (Select Top 5 Model_Name,DIM_MODEL.IDModel ,SUM(Quantity) as Total_Qty From FACT_TRANSACTIONS 
inner join DIM_MODEL  on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
Where YEAR([Date])=2008 
Group by Model_Name,DIM_MODEL.IDModel
Order by Total_Qty desc) as T1 inner join
(Select Top 5 Model_Name,DIM_MODEL.IDModel ,SUM(Quantity) as Total_Qty from FACT_TRANSACTIONS 
inner join DIM_MODEL  on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
Where YEAR([Date])=2009
Group by DIM_MODEL.Model_Name,DIM_MODEL.IDmodel
Order by Total_Qty desc) as T2 on T1.Model_Name=T2.Model_Name inner join
(Select Top 5 Model_Name, DIM_MODEL.IDModel ,SUM(Quantity) as Total_Qty from FACT_TRANSACTIONS 
inner join DIM_MODEL  on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
Where YEAR([Date])=2010
Group by DIM_MODEL.Model_Name,DIM_MODEL.IDmodel
Order by Total_Qty desc) as T3 on T3.Model_Name=T2.Model_Name	
--Q7--END


--Q8--BEGIN
Select * From( Select row_number() over(order by Sum(TotalPrice) desc) as Rate, Manufacturer_Name ,sum(TotalPrice) as Total_Amt,
YEAR([Date]) as [Year]
From FACT_TRANSACTIONS 
inner join DIM_MODEL on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
inner join DIM_MANUFACTURER on DIM_MANUFACTURER.IDManufacturer=DIM_MODEL.IDManufacturer
Where YEAR([Date])=2009 
Group by  DIM_MANUFACTURER.Manufacturer_Name,YEAR([Date]))as T1
Where Rate=2 union all
Select * From (Select row_number() over(Order by sum(TotalPrice) desc) as Rate, Manufacturer_Name ,sum(TotalPrice) as Total_Amt,
YEAR([Date]) as [Year]
From FACT_TRANSACTIONS  
inner join DIM_MODEL on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
inner join DIM_MANUFACTURER on DIM_MANUFACTURER.IDManufacturer=DIM_MODEL.IDManufacturer
Where YEAR([Date])=2010 
Group by  DIM_MANUFACTURER.Manufacturer_Name,YEAR([Date])) as T2
Where Rate=2
--Q8--END


--Q9--BEGIN
Select Manufacturer_Name from (Select  Manufacturer_Name ,Sum(TotalPrice) as TotaL_Amt
From FACT_TRANSACTIONS  
inner join DIM_MODEL on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
inner join DIM_MANUFACTURER on DIM_MANUFACTURER.IDManufacturer=DIM_MODEL.IDManufacturer
Where YEAR([Date])=2010
Group by DIM_MANUFACTURER.Manufacturer_Name , YEAR([Date]))as T1
Except
Select Manufacturer_Name From (Select Manufacturer_Name ,Sum(TotalPrice) as Total_Amt
From FACT_TRANSACTIONS  
inner join DIM_MODEL on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
inner join DIM_MANUFACTURER on DIM_MANUFACTURER.IDManufacturer=DIM_MODEL.IDManufacturer
Where YEAR([Date])=2009
Group by Manufacturer_Name , YEAR([Date])) as T2
--Q9--END


--Q10--BEGIN
Select TBL1.IDCustomer,TBL1.Customer_Name , TBL1.[Year],TBL1.Avg_Spend,TBL1.Avg_Qty,case when TBL2.[Year] is not null then
((TBL1.Avg_Spend-TBL2.Avg_Spend)/TBL2.Avg_Spend )* 100 
else NULL
end as 'YOY in Average Spend' From
(Select DIM_CUSTOMER.IDCustomer,Customer_Name,AVG(TotalPrice) as Avg_Spend ,AVG(Quantity) as Avg_Qty ,
YEAR(Date) as [Year] From DIM_CUSTOMER  
left join FACT_TRANSACTIONS on FACT_TRANSACTIONS.IDCustomer=DIM_CUSTOMER.IDCustomer 
Where DIM_CUSTOMER.IDCustomer in (Select top 10 DIM_CUSTOMER.IDCustomer From DIM_CUSTOMER  
left join FACT_TRANSACTIONS on FACT_TRANSACTIONS.IDCustomer=DIM_CUSTOMER.IDCustomer 
Group by DIM_CUSTOMER.IDCustomer 
Order by Sum(TotalPrice) desc)
Group by DIM_CUSTOMER.IDcustomer,Customer_Name,YEAR(Date)) as TBL1 
left join 
(Select DIM_CUSTOMER.IDCustomer ,Customer_Name,AVG(TotalPrice) as Avg_Spend ,AVG(Quantity) as Avg_Qty ,
YEAR(Date) as [Year] From DIM_CUSTOMER  
left join FACT_TRANSACTIONS on FACT_TRANSACTIONS.IDCustomer=DIM_CUSTOMER.IDCustomer 
Where DIM_CUSTOMER.IDCustomer in (Select Top 10 DIM_CUSTOMER.IDCustomer From DIM_CUSTOMER 
left join FACT_TRANSACTIONS on FACT_TRANSACTIONS.IDCustomer=DIM_CUSTOMER.IDCustomer 
Group by DIM_CUSTOMER.IDCustomer 
Order by Sum(TotalPrice) desc)
Group by DIM_CUSTOMER.IDCustomer,Customer_Name,YEAR(Date)) as TBL2 
on TBL1.IDCustomer=TBL2.IDCustomer and TBL2.[Year]=TBL1.[Year]-1

	


















--Q10--END
	