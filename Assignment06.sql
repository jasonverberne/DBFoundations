--*************************************************************************--
-- Title: Assignment06
-- Author: JasonVerberne
-- Desc: This file demonstrates how to use Views
-- Change Log: 08/03/2024, Jason Verberne, Creation of initial scrip
-- 2017-01-01, JasonVerberne, Created File
-- GitHub: https://github.com/jasonverberne/DBFoundations
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_JasonVerberne')
	 Begin 
	  Alter Database [Assignment06DB_JasonVerberne] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_JasonVerberne;
	 End
	Create Database Assignment06DB_JasonVerberne;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_JasonVerberne;

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
,[UnitPrice] [mOney] NOT NULL
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
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
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
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

GO

CREATE VIEW vEmployees WITH SCHEMABINDING
	AS
		SELECT EmployeeID
		, EmployeeFirstName
		, EmployeeLastName
		, ManagerID
	FROM dbo.Employees;

GO

CREATE VIEW vInventories WITH SCHEMABINDING
	AS
		SELECT InventoryID
		, InventoryDate
		, EmployeeID
		, ProductID
		, [COUNT]
	FROM dbo.Inventories;

GO

CREATE VIEW vProducts WITH SCHEMABINDING
	AS
		SELECT ProductID
			, ProductName
			, CategoryID
			, UnitPrice
	FROM dbo.Products;

GO

CREATE VIEW vCategories WITH SCHEMABINDING
	AS
		SELECT CategoryID
		, CategoryName
	FROM dbo.Categories;

GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

DENY SELECT ON dbo.Employees TO PUBLIC;
GRANT SELECT ON dbo.vEmployees TO PUBLIC;

DENY SELECT ON dbo.Categories TO PUBLIC;
GRANT SELECT ON dbo.vCategories TO PUBLIC;

DENY SELECT ON dbo.Inventories TO PUBLIC;
GRANT SELECT ON dbo.vInventories TO PUBLIC;

DENY SELECT ON dbo.Products TO PUBLIC;
GRANT SELECT ON dbo.vProducts TO PUBLIC;

GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

GO

CREATE VIEW vProductsByCategories WITH SCHEMABINDING
	AS
	SELECT TOP 1000000 c.CategoryName
		, p.ProductName
		, p.UnitPrice 
	FROM dbo.Categories AS c INNER JOIN dbo.Products AS p
	ON c.CategoryID = p.CategoryID
	ORDER BY CategoryName, ProductName;

GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

GO

CREATE VIEW vInventoriesByProductsByDates WITH SCHEMABINDING
	AS
	SELECT TOP 1000000 p.ProductName
	, i.InventoryDate
	, i.Count
	FROM dbo.Products AS p INNER JOIN dbo.Inventories AS i
	ON p.ProductID = i.ProductID
	ORDER BY ProductName
		, InventoryDate
		, i.[Count];

GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

GO

CREATE VIEW vInventoriesByEmployeesByDates WITH SCHEMABINDING
	AS
	SELECT DISTINCT TOP 1000000 i.InventoryDate
		, CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName) AS EmployeeName
	FROM dbo.Inventories AS i INNER JOIN dbo.Employees AS e
	ON i.EmployeeID = e.EmployeeID
	ORDER BY InventoryDate;

GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

GO

CREATE VIEW vInventoriesByProductsByCategories WITH SCHEMABINDING
AS
	SELECT TOP 1000000 c.CategoryName
		, p.ProductName
		, i.InventoryDate
		, i.[Count]
	FROM dbo.Categories AS c INNER JOIN dbo.Products AS p 
	ON c.CategoryID = p.CategoryID
	INNER JOIN dbo.Inventories AS i
	ON p.ProductID = i.ProductID
	ORDER BY c.CategoryName
		, p.ProductName
		, i.InventoryDate
		, i.[Count];

GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

GO

CREATE VIEW vInventoriesByProductsByEmployees WITH SCHEMABINDING
AS
	SELECT TOP 1000000 c.CategoryName
		, p.ProductName
		, i.InventoryDate
		, i.[Count]
		, CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName) AS EmployeeName
	FROM dbo.Categories AS c INNER JOIN dbo.Products AS p 
	ON c.CategoryID = p.CategoryID
	INNER JOIN dbo.Inventories AS i
	ON p.ProductID = i.ProductID
	INNER JOIN dbo.Employees AS e
	ON i.EmployeeID = e.EmployeeID
	ORDER BY i.InventoryDate
		, c.CategoryName
		, p.ProductName;

GO


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

GO

CREATE VIEW vInventoriesForChaiAndChangByEmployees WITH SCHEMABINDING
	AS
	SELECT TOP 1000000 c.CategoryName
		, p.ProductName
		, i.InventoryDate
		, i.[Count], CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName) AS EmployeeName
	FROM dbo.Categories AS c INNER JOIN dbo.Products AS p 
	ON c.CategoryID = p.CategoryID
	INNER JOIN dbo.Inventories AS i
	ON p.ProductID = i.ProductID
	INNER JOIN dbo.Employees AS e
	ON i.EmployeeID = e.EmployeeID
	WHERE p.ProductID IN (SELECT p.ProductID WHERE ProductName IN ('Chai', 'Chang'))
	ORDER BY i.InventoryDate
		, c.CategoryName
		, p.ProductName;

GO


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

GO

CREATE VIEW vEmployeesByManager WITH SCHEMABINDING
	AS
	SELECT TOP 1000000 CONCAT(emp.EmployeeFirstName, ' ', emp.EmployeeLastName) AS Manager
		, CONCAT(mgr.EmployeeFirstName, ' ', mgr.EmployeeLastName) AS Employee
	FROM dbo.Employees AS emp INNER JOIN dbo.Employees AS mgr
	ON emp.EmployeeID = mgr.ManagerID
	ORDER BY Manager
		, Employee;

GO

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

GO

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees --WITH SCHEMABINDING
	AS
	SELECT TOP 1000000 vp.CategoryID
		, vc.CategoryName
		, vp.ProductID
		, vp.ProductName
		, vp.UnitPrice
		, vi.InventoryID
		, vi.InventoryDate
		, vi.[Count]
		, ve.EmployeeID
		, CONCAT(ve.EmployeeFirstName, ' ', ve.EmployeeLastName) AS Employee
		, CONCAT(vm.EmployeeFirstName, ' ', vm.EmployeeLastName) AS Manager
	FROM dbo.vCategories AS vc INNER JOIN dbo.vProducts AS vp
		ON vc.CategoryID = vp.CategoryID
		INNER JOIN dbo.vInventories as vi 
		ON vi.ProductID = vp.ProductID
		INNER JOIN dbo.Employees as ve 
		ON ve.EmployeeID = vi.EmployeeID
		INNER JOIN dbo.Employees as vm
		ON ve.ManagerID = vm.EmployeeID
	ORDER BY vc.CategoryID, vp.ProductName, vi.InventoryID, Employee;

GO

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/