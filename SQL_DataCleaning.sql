CREATE TABLE dim_calendar (
    DateKey INT,
    Date DATE,
    Day NVARCHAR(50),
    Month NVARCHAR(50),
    MonthShort NVARCHAR(3),
    MonthNo INT,
    Quarter INT,
    Year INT
);

INSERT INTO dim_calendar (DateKey, Date, Day, Month, MonthShort, MonthNo, Quarter, Year)
SELECT 
    DateKey,
    FullDateAlternateKey AS Date,
    EnglishDayNameOfWeek AS Day,
    EnglishMonthName AS Month,
    LEFT(EnglishMonthName, 3) AS MonthShort,
    MonthNumberOfYear AS MonthNo,
    CalendarQuarter AS Quarter,
    CalendarYear AS Year
FROM internetsales
WHERE CalendarYear >= 2019;

CREATE TABLE dim_customers (
    CustomerKey INT,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Gender NVARCHAR(10),
    DateFirstPurchase DATE,
    CustomerCity NVARCHAR(100)
);

INSERT INTO dim_customers (
    CustomerKey,
    FirstName,
    LastName,
    Gender,
    DateFirstPurchase,
    CustomerCity
)
SELECT C.CustomerKey
      ,C.FirstName
      ,C.LastName
      ,CASE C.Gender WHEN 'M' THEN 'Male' WHEN 'F' THEN 'Female' END AS Gender
      ,C.DateFirstPurchase
	  ,G.City as CustomerCity
  FROM internetsales.dim_customers AS C
  LEFT JOIN dimgeography AS g ON g.geographykey = c.geographykey
  ORDER BY 
  CustomerKey ASC;
  
CREATE table dim_products(
    ProductKey INT,
    ProductItemCode NVARCHAR(50),
    ProductName NVARCHAR(255),
    SubCategory NVARCHAR(255),
    ProductCategory NVARCHAR(255),
    ProductColor NVARCHAR(50),
    ProductSize NVARCHAR(50),
    ProductLine NVARCHAR(50),
    ProductModelName NVARCHAR(255),
    ProductDescription NVARCHAR(60),
    ProductStatus NVARCHAR(50)
);
INSERT INTO dim_products (
    ProductKey,
    ProductItemCode,
    ProductName,
    SubCategory,
    ProductCategory,
    ProductColor,
    ProductSize,
    ProductLine,
    ProductModelName,
    ProductDescription,
    ProductStatus
)
SELECT 
    p.ProductKey, 
    p.ProductAlternateKey AS ProductItemCode, 
    p.EnglishProductName AS ProductName, 
    ps.EnglishProductSubcategoryName AS SubCategory, 
    pc.EnglishProductCategoryName AS ProductCategory, 
    p.Color AS ProductColor, 
    p.Size AS ProductSize, 
    p.ProductLine AS ProductLine, 
    p.ModelName AS ProductModelName, 
    p.EnglishDescription AS ProductDescription, 
    ISNULL(p.Status, 'Outdated') AS ProductStatus
FROM 
    dim_products AS p
    LEFT JOIN DimProductSubcategory AS ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
    LEFT JOIN DimProductCategory AS pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
ORDER BY 
    p.ProductKey ASC; 

CREATE TABLE fact_internetsales (
    ProductKey INT,
    OrderDateKey INT,
    DueDateKey INT,
    ShipDateKey INT,
    CustomerKey INT,
    SalesOrderNumber NVARCHAR(50),
    SalesAmount DECIMAL(18, 2)
);
INSERT INTO fact_internetsales (
    ProductKey,
    OrderDateKey,
    DueDateKey,
    ShipDateKey,
    CustomerKey,
    SalesOrderNumber,
    SalesAmount
)
SELECT 
  ProductKey, 
  OrderDateKey, 
  DueDateKey, 
  ShipDateKey, 
  CustomerKey, 
  SalesOrderNumber, 
  SalesAmount
FROM 
 fact_internetsales
WHERE 
  LEFT (OrderDateKey, 4) >= 2019
ORDER BY
  OrderDateKey ASC



    
  
  
  
  
  