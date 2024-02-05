
--- Creating Date Dimension Table

Create table DimDate (
Datekey INt primary key, 
FullDate Date,
DayName Varchar (10), 
DayOfMonth Int,
MonthNumber INT,
MonthName Varchar (20),
Quarter varchar (10),
Year varchar (5),
)

--- Creating Customer Dimension Table

Create table DimCustomer (
Customerkey INT IDENTITY (1,1) Primary key,
CustomerCode Nvarchar (20) not null,
FirstName varchar (40) not null,
LastName varchar (40) not null,
BirthDate date not null, 
MaritalStatus varchar (20) not null,
Gender nvarchar (10) not null, 
PostCode nvarchar (20) not null,
City nvarchar (50) not null, 
Income int not null,  
)

--- Creating Payment Type Dimension Table

Create table DimPaymentType (
PaymentTypeKey int identity (1,1) primary key,
PaymentTypeName nVarchar (50) not null, 
PaymentTypeID int not null,
)

--- Creating Selling Channel Dimension Table

Create table DimSellingChannel (
SellingChannelKey INT IDENTITY (1,1) primary key,
SellingChannelName varchar (50) not null,
SellingChannelCode varchar (3) not null, 
Commission int not null, 
)

--- Creating Customer sales Transactions Fact Table

Create table CustomerSalesTransactionsFact (
FullDate date,
Datekey int foreign key References [dbo].[DimDate] not null,
Customerkey int foreign key references [dbo].[DimCustomer] not null, 
PaymentTypeKey int Foreign key references [dbo].[DimPaymentType] not null, 
SellingChannelKey int foreign key references [dbo].[DimSellingChannel] not null,
Invoicenumber nvarchar (50) not null, 
TotalCost float  not null,
TotalRetailPrice float not null,
CommissionRate nvarchar (50) not null, 
Profit float not null, 
PRIMARY KEY (Datekey, Customerkey,PaymentTypeKey,SellingChannelKey)
)



--- Populating Date Dimension Table

Insert into [DataWarehousingAssignment].[dbo].[DimDate] (DateKey, FullDate, DayName,DayOfMonth, MonthNumber, MonthName, Quarter, Year)
Select Convert(INT, CONVERT(VARCHAR, FullDate, 112)) AS DateKey,
FullDate as FullDate,
DayNameOfWeek as DayName,
DayOfMonth  as DayOfMonth,
MonthOfYear as MonthNumber, 
MonthName  as MonthName,
CalendarQuarter  as Quarter,
CalendarYear as Year
From [Staging Area].[dbo].[Generated DateTime]

--- Populating Payment Type Dimension Table

Insert into [dbo].[DimPaymentType](PaymentTypeName, PaymentTypeID)
select NAME,RetailerPaymentTypeId from [Staging Area].[dbo].[PaymentsData]

--- Populating Selling Channel Dimension Table
INSERT INTO [dbo].[DimSellingChannel]
SELECT Name, Code, CommissionRate FROM [Staging Area].[dbo].[Selling Channels]

--- Populating Customer Dimension Table

Insert into [DataWarehousingAssignment].[dbo].[DimCustomer]
select CustomerCode,cust1.FirstName, cust2.LastName, Birthdate,
MaritalStatus,Gender,PostCode,City,Income
from [Staging Area].[dbo].[CustomerDetails-1] cust1,[Staging Area].[dbo].[Customer Details 2] cust2
where cust1.FirstName=cust2.FirstName and cust1.LastName=cust2.LastName

--- Populating Customer Sales Transactions Fact Table

INSERT INTO [dbo].[CustomerSalesTransactionsFact] (FullDate, Datekey, Customerkey, PaymentTypeKey, 
SellingChannelKey, Invoicenumber, TotalCost, TotalRetailPrice, CommissionRate, Profit)
SELECT
    d.FullDate as Date,
    d.Datekey,
    c.Customerkey,
    pt.PaymentTypeKey,
    sc.SellingChannelKey,
    rs.InvoiceNumber,
    rs.TotalCost,
    rs.TotalRetailPrice,
    rs.CommissionRate,
    ((rs.TotalRetaiLPrice - rs.TotalCost) - TotalRetaiLPrice*CommissionRate/100) AS Profit
FROM
    [Staging Area].[dbo].[CustomerSaleTransactions] rs
    JOIN [DataWarehousingAssignment].[dbo].[DimDate] d ON rs.Date = d.FullDate
    JOIN [DataWarehousingAssignment].[dbo].[DimCustomer] c ON rs.CustomerCode = c.CustomerCode
    JOIN [DataWarehousingAssignment].[dbo].[DimPaymentType] pt ON rs.PaymentTypeID = pt.PaymentTypeID
	JOIN [DataWarehousingAssignment].[dbo].[DimSellingChannel] sc ON rs.SellingChannel = sc.SellingChannelCode

	
	

