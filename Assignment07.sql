--*************************************************************************--
-- Title: Assignment07
-- Author: JTanase
-- Desc: This file demonstrates how to use Functions
-- Change Log:
-- 2017-01-01,RRoot,Created File
-- 2022-08-22,JTanase,Created File + Q1 - Q4
-- 2022-08-23,JTanase, Q5 - Q6
-- 2022-08-24,JTanase, Q7 - Q8
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_JTanase')
	 Begin 
	  Alter Database [Assignment07DB_JTanase] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_JTanase;
	 End
	Create Database Assignment07DB_JTanase;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_JTanase;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.
/*
--1. Show ProductName and UnitPrice
Select
	ProductName
	,UnitPrice
From dbo.vProducts;

--2. Format price as US dollar
Select
	ProductName
	,Format(UnitPrice, 'C', 'en-US') As UnitPRice
From dbo.vProducts;
*/

--3. Order by ProductName
Select
	ProductName
	,Format(UnitPrice, 'C', 'en-US') As UnitPrice
From dbo.vProducts
Order by ProductName;
go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
/*
--1. Show CategoryName, ProductName, UnitPrice
Select
	CategoryName
From dbo.vCategories;

Select
	ProductName
	,UnitPrice
From dbo.vProducts;
--2. Join Tables Categories and Products
Select
	C.CategoryName
	,P.ProductName
	,P.UnitPrice
From dbo.vCategories as C
Inner Join dbo.vProducts as P
	On C.CategoryID = P.CategoryID;
--3. Format price as US Dollar
Select
	C.CategoryName
	,P.ProductName
	,Format(P.UnitPrice, 'C', 'en-US') as UnitPrice
From dbo.vCategories as C
Inner Join dbo.vProducts as P
	On C.CategoryID = P.CategoryID;
*/

--4. Order by CategoryName, ProductName
Select
	C.CategoryName
	,P.ProductName
	,Format(P.UnitPrice, 'C', 'en-US') as UnitPrice
From dbo.vCategories as C
Inner Join dbo.vProducts as P
	On C.CategoryID = P.CategoryID
Order by CategoryName, ProductName;
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

/*
--1. Show ProductName, InventoryDate, Count
Select
	P.ProductName
	,I.InventoryDate
	,I.[Count] as InventoryCount
From dbo.vProducts as P
Join dbo.vInventories as I
	On P.ProductID = I.ProductID;
--2. Format date like 'January, 2017'
Select
	P.ProductName
	,DateName(month, I.InventoryDate) + ', ' + DateName(Year, I.InventoryDate) as InventoryDate
	,I.[Count] as InventoryCount
From dbo.vProducts as P
Join dbo.vInventories as I
	On P.ProductID = I.ProductID;
*/

--3. Order by ProductName, InventoryDate
Select
	P.ProductName
	,Datename(Month, I.InventoryDate) + ', ' + Datename(Year, I.InventoryDate) as InventoryDate
	,I.[Count] as InventoryCount
From dbo.vProducts as P
Inner Join dbo.Inventories as I
	On P.ProductID = I.ProductID
Order by ProductName, I.InventoryDate;
go
-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

--1. Create View vProductInventories from Q3
Create View vProductInventories
	As
		Select Top 100000
			P.ProductName
			,Datename(Month, I.InventoryDate) + ', ' + Datename(Year, I.InventoryDate) as InventoryDate
			,I.[Count] as InventoryCount
		From dbo.vProducts as P
		Inner Join dbo.Inventories as I
			On P.ProductID = I.ProductID
		Order by ProductName, I.InventoryDate;		
go
Select * From vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
/*
--1. Show CategoryName and InventoryDate and Inventory Count By Category seperately
Select
	CategoryName
From dbo.vCategories;

Select
	InventoryDate
	,[Count]
From dbo.vInventories;
--2. Join tables
Select
	C.CategoryName
	,I.InventoryDate
	,I.[Count]
From dbo.vCategories as C
Inner Join dbo.vProducts as P
	On C.CategoryID = P.CategoryID
Inner Join dbo.vInventories as I
	On P.ProductID = I.ProductID;
--3. Change to Total Inventory Count by Category and Group by InventoryDate, CategoryName (Following image on Assignment 07)
Select
	C.CategoryName
	,I.InventoryDate
	,Sum(I.[Count]) as InventoryCountByCategory
From dbo.vCategories as C
Inner Join dbo.vProducts as P
	On C.CategoryID = P.CategoryID
Inner Join dbo.vInventories as I
	On P.ProductID = I.ProductID
Group by InventoryDate, CategoryName;
--4. Format like 'January, 2017'
Select
	C.CategoryName
	,DateName(Month, I.InventoryDate) + ', ' + DateName(Year, I.InventoryDate) as InventoryDate
	,Sum(I.[Count]) as InventoryCountByCategory
From dbo.vCategories as C
Inner Join dbo.vProducts as P
	On C.CategoryID = P.CategoryID
Inner Join dbo.vInventories as I
	On P.ProductID = I.ProductID
Group by I.InventoryDate, CategoryName;
*/

--5. Create View vCategoryInventories
Create View vCategoryInventories
As
	Select
		C.CategoryName
		,DateName(Month, I.InventoryDate) + ', ' + DateName(Year, I.InventoryDate) as InventoryDate
		,Sum(I.[Count]) as InventoryCountByCategory
	From dbo.vCategories as C
	Inner Join dbo.vProducts as P
		On C.CategoryID = P.CategoryID
	Inner Join dbo.vInventories as I
		On P.ProductID = I.ProductID
	Group by I.InventoryDate, CategoryName;
go
Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.
/*
--1. Show ProductNames, InventoryDates, InventoryCount from vProductInventories
Select
	ProductName
	,InventoryDate
	,InventoryCount
From dbo.vProductInventories;
--2. Add Previous Month Count and order by Product Name and InventoryDates
Select
	ProductName
	,DateName(Month, InventoryDate) + ', ' + DateName(Year, InventoryDate) as InventoryDate
	,InventoryCount
	,Lag(InventoryCount) Over(Order By ProductName, Cast(InventoryDate as Date)) as PreviousMonthCount
From dbo.vProductInventories
--3. Use IFF Function to set any January Null counts to zero and set January 2017 as 0
Select
	ProductName
	,DateName(Month, InventoryDate) + ', ' + DateName(Year, InventoryDate) as InventoryDate
	,InventoryCount
	,IIF(InventoryDate = 'January, 2017', 0, Lag(InventoryCount) Over(Order By ProductName, Cast(InventoryDate as Date))) as PreviousMonthCount
From dbo.vProductInventories;
*/
--4. Create View vProductInventoriesWithPreviousMonthCounts
Create View vProductInventoriesWithPreviousMonthCounts
As
	Select
		ProductName
		,DateName(Month, InventoryDate) + ', ' + DateName(Year, InventoryDate) as InventoryDate
		,InventoryCount
		,IIF(InventoryDate = 'January, 2017', 0, Lag(InventoryCount) Over(Order By ProductName, Cast(InventoryDate as Date))) as PreviousMonthCount
	From dbo.vProductInventories;
go
Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.
/*
--1. Show Product names, Inventory Dates, Inventory Count, Previous Month Count
Select
	ProductName
	,InventoryDate
	,InventoryCount
	,PreviousMonthCount
From dbo.vProductInventoriesWithPreviousMonthCounts;
--2. Create column KPI 1, 0, -1
Select
	ProductName
	,InventoryDate
	,InventoryCount
	,PreviousMonthCount
	,CountVsPreviousCountKPI = Case
When InventoryCount > PreviousMonthCount Then 1
When InventoryCount = PreviousMonthCount Then 0
When InventoryCount < PreviousMonthCount Then -1
End
From dbo.vProductInventoriesWithPreviousMonthCounts;
*/
--3. Create View vProductInventoriesWithPreviousMonthCountsWithKPIs
Create View vProductInventoriesWithPreviousMonthCountsWithKPIs
As
	Select
		ProductName
		,InventoryDate
		,InventoryCount
		,PreviousMonthCount
		,CountVsPreviousCountKPI = Case
	When InventoryCount > PreviousMonthCount Then 1
	When InventoryCount = PreviousMonthCount Then 0
	When InventoryCount < PreviousMonthCount Then -1
	End
	From dbo.vProductInventoriesWithPreviousMonthCounts;
go
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

/*
--1. Show ProductNames, InventoryDate, InventoryCount, PreviousMonthCount, CountVsPreviousCountKPI
Select 
	ProductName
	,InventoryDate
	,InventoryCount
	,PreviousMonthCount
	,CountVsPreviousCountKPI
From dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs;
go
--2. Create UDF fProductInventoriesWithPreviousMonthCountsWithKPIs
Create Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs (@KPI int)
Returns Table
As
	Return(
		Select 
			ProductName
			,InventoryDate
			,InventoryCount
			,PreviousMonthCount
			,CountVsPreviousCountKPI
		From dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs);
go
*/
--3. Add Where to filter for KPI value to @KPI
Create Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs (@KPI int)
Returns Table
As
	Return(
		Select 
			ProductName
			,InventoryDate
			,InventoryCount
			,PreviousMonthCount
			,CountVsPreviousCountKPI
		From dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
		Where CountVsPreviousCountKPI = @KPI);
go

Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);

go

/***************************************************************************************/