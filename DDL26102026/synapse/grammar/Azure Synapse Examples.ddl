CREATE TABLE t1 ( c1 varchar(20) COLLATE Divehi_90_CI_AS_KS_WS) WITH (PARTITION (c1 RANGE FOR VALUES (N'')));

CREATE TABLE MyTable1   
  (  
    mycolumnnn1 nvarchar,  
    mycolumn2 nvarchar COLLATE Frisian_100_CS_AS )  
WITH ( CLUSTERED COLUMNSTORE INDEX )  
;


CREATE TABLE MyTable3
  (  
    colA int CONSTRAINT constraint_colA DEFAULT 0,  
    colB nvarchar COLLATE Frisian_100_CS_AS
  )  
WITH ( CLUSTERED COLUMNSTORE INDEX )  
;


CREATE TABLE AdventureWorks.dbo.#myTable4
  (  
   id int NOT NULL,  
   lastName varchar(20),  
   zipCode varchar(6)  
  )  
WITH  
  (   
    DISTRIBUTION = HASH (id),  
    CLUSTERED COLUMNSTORE INDEX
  )  
;

CREATE TABLE MyTable5
  (  
    colA int CONSTRAINT constraint_colA DEFAULT 0,  
    colB nvarchar COLLATE Frisian_100_CS_AS
  )  
WITH   
  (   
    DISTRIBUTION = HASH ( colB ),  
    CLUSTERED COLUMNSTORE INDEX
  )  
;

CREATE TABLE Lineitem  
WITH (DISTRIBUTION = ROUND_ROBIN, CLUSTERED COLUMNSTORE INDEX ORDER(SHIPDATE))  ;

CREATE TABLE myTable6
  (  
    id int NOT NULL,  
    lastName varchar(20),  
    zipCode varchar(6)  
  )  
WITH ( CLUSTERED COLUMNSTORE INDEX );

CREATE TABLE myTable7
  (  
    id int NOT NULL,  
    lastName varchar(20),  
    zipCode varchar(6)  
  )  
WITH  
  (   
    DISTRIBUTION = HASH (id, zipCode), 
    CLUSTERED COLUMNSTORE INDEX  
  );
  
CREATE TABLE myTable8
  (  
    id int NOT NULL,  
    lastName varchar(20),  
    zipCode varchar(6)  
  )  
WITH  
  (   
    DISTRIBUTION = REPLICATE,
    CLUSTERED INDEX (lastName)  
  );
  
CREATE TABLE myTable9
  (  
    id int NOT NULL,  
    lastName varchar(20),  
    zipCode int)  
WITH
  (

    PARTITION ( id RANGE LEFT FOR VALUES (10, 20, 30, 40 )),  
    CLUSTERED COLUMNSTORE INDEX
  );
  
CREATE TABLE myTable10 (  
    id int NOT NULL,  
    lastName varchar(20),  
    zipCode int)  
WITH
    (
      PARTITION ( id RANGE LEFT FOR VALUES ( )),  
      CLUSTERED COLUMNSTORE INDEX  
    )  ;
	
	
	
CREATE TABLE myTable11 (  
    l_orderkey      bigint,
    l_partkey       bigint,
    l_suppkey       bigint,
    l_linenumber    bigint,
    l_quantity      decimal(15,2),  
    l_extendedprice decimal(15,2),  
    l_discount      decimal(15,2),  
    l_tax           decimal(15,2),  
    l_returnflag    char(1),  
    l_linestatus    char(1),  
    l_shipdate      date,  
    l_commitdate    date,  
    l_receiptdate   date,  
    l_shipinstruct  char(25),  
    l_shipmode      char(10),  
    l_comment       varchar(44))  
WITH
  (
    DISTRIBUTION = HASH (l_orderkey),  
    CLUSTERED COLUMNSTORE INDEX,  
    PARTITION ( l_shipdate  RANGE RIGHT FOR VALUES
      (  
        '1992-01-01','1992-02-01','1992-03-01','1992-04-01','1992-05-01',
        '1992-06-01','1992-07-01','1992-08-01','1992-09-01','1992-10-01',
        '1992-11-01','1992-12-01','1993-01-01','1993-02-01','1993-03-01',
        '1993-04-01','1993-05-01','1993-06-01','1993-07-01','1993-08-01',
        '1993-09-01','1993-10-01','1993-11-01','1993-12-01','1994-01-01',
        '1994-02-01','1994-03-01','1994-04-01','1994-05-01','1994-06-01',
        '1994-07-01','1994-08-01','1994-09-01','1994-10-01','1994-11-01',
        '1994-12-01'  
      ))
  );
  
  
CREATE VIEW Customers  
AS  
SELECT *  
FROM CompanyData.dbo.Customers_33  
UNION ALL  
SELECT *  
FROM Server2.CompanyData.dbo.Customers_66  
UNION ALL  
SELECT *  
FROM Server3.CompanyData.dbo.Customers_99;

CREATE VIEW hiredate_view  
AS   
SELECT p.FirstName, p.LastName, e.BusinessEntityID, e.HireDate  
FROM HumanResources.Employee e   
JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID ;

CREATE VIEW Purchasing.PurchaseOrderReject  
WITH ENCRYPTION  
AS  
SELECT PurchaseOrderID, ReceivedQty, RejectedQty,   
    RejectedQty / ReceivedQty AS RejectRatio, DueDate  
FROM Purchasing.PurchaseOrderDetail  
WHERE RejectedQty / ReceivedQty > 0  
AND DueDate > CONVERT(DATETIME,'20010630',101) ;  

CREATE VIEW dbo.SeattleOnly  
AS  
SELECT p.LastName, p.FirstName, e.JobTitle, a.City, sp.StateProvinceCode  
FROM HumanResources.Employee e  
INNER JOIN Person.Person p  
ON p.BusinessEntityID = e.BusinessEntityID  
    INNER JOIN Person.BusinessEntityAddress bea   
    ON bea.BusinessEntityID = e.BusinessEntityID   
    INNER JOIN Person.Address a   
    ON a.AddressID = bea.AddressID  
    INNER JOIN Person.StateProvince sp   
    ON sp.StateProvinceID = a.StateProvinceID  
WHERE a.City = 'Seattle'  
WITH CHECK OPTION ;  

CREATE VIEW Sales.SalesPersonPerform  
AS  
SELECT TOP (100) SalesPersonID, SUM(TotalDue) AS TotalSales  
FROM Sales.SalesOrderHeader  
WHERE OrderDate > CONVERT(DATETIME,'20001231',101)  
GROUP BY SalesPersonID;

CREATE VIEW dbo.all_supplier_view  
WITH SCHEMABINDING  
AS  
SELECT supplyID, supplier  
  FROM dbo.SUPPLY1  
UNION ALL  
SELECT supplyID, supplier  
  FROM dbo.SUPPLY2  
UNION ALL  
SELECT supplyID, supplier  
  FROM dbo.SUPPLY3  
UNION ALL  
SELECT supplyID, supplier  
  FROM dbo.SUPPLY4; 
  
CREATE VIEW DimEmployeeBirthDates AS  
SELECT FirstName, LastName, BirthDate   
FROM DimEmployee; 


CREATE VIEW view1  
AS 
SELECT fis.CustomerKey, fis.ProductKey, fis.OrderDateKey, 
  fis.SalesTerritoryKey, dst.SalesTerritoryRegion  
FROM FactInternetSales AS fis   
LEFT OUTER JOIN DimSalesTerritory AS dst   
ON (fis.SalesTerritoryKey=dst.SalesTerritoryKey);

CREATE DATABASE TestDW
(EDITION = 'datawarehouse', SERVICE_OBJECTIVE='DW100c');

CREATE DATABASE TestDW COLLATE Latin1_General_100_CI_AS_KS_WS
(MAXSIZE = 10240 GB, EDITION = 'datawarehouse', SERVICE_OBJECTIVE = 'DW1000c');

CREATE DATABASE TestDW COLLATE Latin1_General_100_CI_AS_KS_WS ;

CREATE TABLE FactInternetSales
(
    ProductKey INT NOT NULL,
    OrderDateKey INT NOT NULL,
    DueDateKey INT NOT NULL,
    ShipDateKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    PromotionKey INT NOT NULL,
    CurrencyKey INT NOT NULL,
    SalesTerritoryKey INT NOT NULL,
    SalesOrderNumber NVARCHAR(20) NOT NULL,
    SalesOrderLineNumber TINYINT NOT NULL,
    RevisionNumber TINYINT NOT NULL,
    OrderQuantity SMALLINT NOT NULL,
    UnitPrice MONEY NOT NULL,
    ExtendedAmount MONEY NOT NULL,
    UnitPriceDiscountPct FLOAT NOT NULL,
    DiscountAmount FLOAT NOT NULL,
    ProductStandardCost MONEY NOT NULL,
    TotalProductCost MONEY NOT NULL,
    SalesAmount MONEY NOT NULL,
    TaxAmt MONEY NOT NULL,
    Freight MONEY NOT NULL,
    CarrierTrackingNumber NVARCHAR(25),
    CustomerPONumber NVARCHAR(25)
)
WITH( 
 HEAP, 
 DISTRIBUTION = ROUND_ROBIN 
);

CREATE TABLE FactInternetSales_new
WITH
(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = HASH(ProductKey),
    PARTITION
    (
        OrderDateKey RANGE RIGHT FOR VALUES
        (
        20000101,20010101,20020101,20030101,20040101,20050101,20060101,20070101,20080101,20090101,
        20100101,20110101,20120101,20130101,20140101,20150101,20160101,20170101,20180101,20190101,
        20200101,20210101,20220101,20230101,20240101,20250101,20260101,20270101,20280101,20290101
        )
    )
)
AS SELECT * FROM FactInternetSales;

CREATE TABLE test  
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN)  
AS  
SELECT  
    CustomerKey AS CustomerKeyNoChange,  
    CustomerKey*1 AS CustomerKeyChangeNullable,  
    CAST(CustomerKey AS DECIMAL(10,2)) AS CustomerKeyChangeDataTypeNullable,  
    ISNULL(CAST(CustomerKey AS DECIMAL(10,2)),0) AS CustomerKeyChangeDataTypeNotNullable,  
    GeographyKey AS GeographyKeyNoChange,  
    ISNULL(GeographyKey,0) AS GeographyKeyChangeNotNullable,  
    CustomerAlternateKey AS CustomerAlternateKeyNoChange,  
    CASE WHEN CustomerAlternateKey = CustomerAlternateKey 
        THEN CustomerAlternateKey END AS CustomerAlternateKeyNullable,  
    CustomerAlternateKey COLLATE Latin1_General_CS_AS_KS_WS AS CustomerAlternateKeyChangeCollation  
FROM [dbo].[DimCustomer2]  ;

CREATE TABLE [dbo].[myTable12]   
WITH   
  (   
    CLUSTERED COLUMNSTORE INDEX,  
    DISTRIBUTION = ROUND_ROBIN  
  )  
AS SELECT * FROM [dbo].[DimSalesTerritory]; 




CREATE TABLE myTable13  
WITH   
  (   
    CLUSTERED COLUMNSTORE INDEX,  
    DISTRIBUTION = ROUND_ROBIN  
  )  
AS SELECT CustomerKey AS c, LastName AS ln  
    FROM dimCustomer; 
	
CREATE TABLE dbo.FactInternetSalesNew  
WITH   
  (   
    CLUSTERED COLUMNSTORE INDEX,  
    DISTRIBUTION = ROUND_ROBIN   
  )  
AS SELECT T1.* FROM dbo.FactInternetSales T1 JOIN dbo.DimCustomer T2  
ON ( T1.CustomerKey = T2.CustomerKey )  
OPTION ( HASH JOIN ); 

CREATE TABLE ClickStreamData   
WITH  
  (  
    CLUSTERED COLUMNSTORE INDEX,  
    DISTRIBUTION = HASH (user_IP)  
  )  
AS SELECT * FROM ClickStreamExt  
;  

CREATE TABLE ClickStreamPDW   
WITH  
  (  
    CLUSTERED COLUMNSTORE INDEX,  
    DISTRIBUTION = HASH (user_IP)  
  )  
AS SELECT * FROM ClickStreamExt  
;  

CREATE TABLE #tmp_fct
WITH
(
    DISTRIBUTION = ROUND_ROBIN
)
AS
SELECT  *
FROM    [dbo].[FactInternetSales]
;

CREATE TABLE Table1 WITH (DISTRIBUTION = HASH(c1), CLUSTERED COLUMNSTORE INDEX ORDER(c1) )
AS SELECT * FROM ExampleTable
OPTION (MAXDOP 1);

CREATE TABLE [dbo].[Sales_in]
WITH    
(   DISTRIBUTION = HASH([product])
,   PARTITION   (   [date] RANGE RIGHT FOR VALUES
                    (20000101,20010101
                    )
                )
)
AS
SELECT
    [date]    
,   [product]
,   [store]
,   [quantity]
,   [price]   
,   ISNULL(CAST([quantity]*[price] AS MONEY),0) AS [amount]
FROM [stg].[source]
OPTION (LABEL = 'CTAS : Partition IN table : Create');

CREATE MATERIALIZED VIEW mv_test2  
WITH (distribution = hash(i_category_id), FOR_APPEND)  
AS
SELECT MAX(i.i_rec_start_date) as max_i_rec_start_date, MIN(i.i_rec_end_date) as min_i_rec_end_date, i.i_item_sk, i.i_item_id, i.i_category_id
FROM syntheticworkload.item i  
GROUP BY i.i_item_sk, i.i_item_id, i.i_category_id ;


CREATE FUNCTION dbo.CalculateTotalPrice
(
    @quantity INT,
    @unitPrice DECIMAL(10, 2),
    @discount DECIMAL(5, 2) = 0.1
)
RETURNS DECIMAL(10, 2)
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @totalPrice DECIMAL(10, 2)
    
    SET @totalPrice = (@quantity * @unitPrice) - (@quantity * @unitPrice * @discount)
    
    RETURN @totalPrice
END;

CREATE FUNCTION dbo.ConvertInput (@MyValueIn int)  
RETURNS decimal(10,2)  
AS  
BEGIN  
    DECLARE @MyValueOut int;  
    SET @MyValueOut= CAST( @MyValueIn AS decimal(10,2));  
    RETURN(@MyValueOut);  
END;  

CREATE EXTERNAL TABLE [dbo].[DimProduct_external]
( [ProductKey] [int] NOT NULL,
  [ProductLabel] nvarchar NULL,
  [ProductName] nvarchar NULL )
WITH
(
    LOCATION='/DimProduct/' ,
    DATA_SOURCE = AzureDataLakeStore ,
    FILE_FORMAT = TextFileFormat ,
    REJECT_TYPE = VALUE ,
    REJECT_VALUE = 0
);

CREATE FUNCTION dbo.ModulesByType(@objectType CHAR(2) = '%%')
RETURNS TABLE
AS
RETURN
(
    SELECT 
        sm.object_id AS 'Object Id',
        o.create_date AS 'Date Created',
        OBJECT_NAME(sm.object_id) AS 'Name',
        o.type AS 'Type',
        o.type_desc AS 'Type Description', 
        sm.definition AS 'Module Description'
    FROM sys.sql_modules AS sm  
    JOIN sys.objects AS o ON sm.object_id = o.object_id
    WHERE o.type like '%' + @objectType + '%'
);
GO

CREATE EXTERNAL TABLE census_external_table
(
    decennialTime varchar(20),
    stateName varchar(100),
    countyName varchar(100),
    population int,
    race varchar(50),
    sex    varchar(10),
    minAge int,
    maxAge int
)  
WITH (
    LOCATION = '/parquet/',
    DATA_SOURCE = population_ds,  
    FILE_FORMAT = census_file_format
);

CREATE EXTERNAL TABLE dbo.FactInternetSalesNew1
    WITH (
            LOCATION = '/files/Customer',
            DATA_SOURCE = customer_ds,
            FILE_FORMAT = customer_ff
            ) AS

SELECT T1.*
FROM dbo.FactInternetSales T1
INNER JOIN dbo.DimCustomer T2
    ON (T1.CustomerKey = T2.CustomerKey)
OPTION (HASH JOIN);
GO

CREATE EXTERNAL TABLE dbo.FactInternetSalesNew2
    WITH (
            LOCATION = '/files/Customer',
            DATA_SOURCE = customer_ds,
            FILE_FORMAT = customer_ff
            ) AS

SELECT T1.ProductKey AS ProductKeyNoChange,
    T1.OrderDateKey AS OrderDate,
    T1.ShipDateKey AS ShipDate,
    T1.CustomerKey AS CustomerKeyNoChange,
    T1.OrderQuantity AS Quantity,
    T1.SalesAmount AS MONEY
FROM dbo.FactInternetSales T1
INNER JOIN dbo.DimCustomer T2
    ON (T1.CustomerKey = T2.CustomerKey)
OPTION (HASH JOIN);
GO

CREATE EXTERNAL TABLE ext_sales
    WITH (
            LOCATION = '/cetas/sales.parquet',
            DATA_SOURCE = s3_eds,
            FILE_FORMAT = ParquetFileFormat
            ) AS

SELECT *
FROM AdventureWorks2019.[Sales].[SalesOrderDetail];
GO

CREATE EXTERNAL TABLE [dbo].[myexternaltable] WITH (
        LOCATION = 'myoutputsubfolder/',
        DATA_SOURCE = [SynapseSQLwriteable],
        FILE_FORMAT = [ParquetFF]
) AS
SELECT * FROM [myview];
GO





DROP TABLE ProductVendor1 ;

DROP EXTERNAL TABLE SalesPerson1;  
DROP EXTERNAL TABLE dbo.SalesPerson;  
DROP EXTERNAL TABLE EasternDivision.dbo.SalesPerson;

DROP EXTERNAL TABLE EasternDivision.dbo.SalesPerson;

DROP EXTERNAL TABLE ProductVendor1;

CREATE TABLE T1 (Col1 INT);  
GO  
DROP TABLE IF EXISTS T1;  
GO  
DROP TABLE IF EXISTS T1;


DROP VIEW IF EXISTS dbo.Reorder ;  
GO

DROP PROCEDURE IF EXISTS dbo.uspMyProc;  
GO

DROP PROCEDURE dbo.uspGetSalesbyMonth, dbo.uspUpdateSalesQuotes, dbo.uspGetSalesByYear;

DROP PROCEDURE dbo.uspMyProc;  
GO

DROP INDEX IX_ProductVendor_BusinessEntityID   
    ON Purchasing.ProductVendor;  
GO

DROP INDEX  
    IX_PurchaseOrderHeader_EmployeeID ON Purchasing.PurchaseOrderHeader,  
    IX_Address_StateProvinceID ON Person.Address;  
GO

DROP INDEX AK_BillOfMaterials_ProductAssemblyID_ComponentID_StartDate   
    ON Production.BillOfMaterials WITH (ONLINE = ON, MAXDOP = 2);  
GO


DROP INDEX PXML_ProductModel_CatalogDescription   
    ON Production.ProductModel;
	
DROP INDEX PK_MyClusteredIndex   
    ON dbo.MyTable   
    WITH (MOVE TO MyPartitionScheme,  
          FILESTREAM_ON MyPartitionScheme);  
GO

ALTER DATABASE AdventureWorks2012
MODIFY NAME = Northwind;

ALTER DATABASE dw1 MODIFY ( MAXSIZE=10240 GB );

ALTER DATABASE dw1 MODIFY ( MAXSIZE=10240 GB, SERVICE_OBJECTIVE= 'DW1200' );

ALTER DATABASE dw1 MODIFY ( SERVICE_OBJECTIVE= 'DW1200' );

ALTER DATABASE [database_name]
SET RECOVERY FULL PAGE_VERIFY CHECKSUM;
GO

ALTER DATABASE [database_name]
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO
ALTER DATABASE [database_name]
SET READ_ONLY
GO
ALTER DATABASE [database_name]
SET MULTI_USER;
GO

ALTER DATABASE [database_name]
SET ALLOW_SNAPSHOT_ISOLATION ON;
GO

ALTER DATABASE [database_name]
SET CHANGE_TRACKING = ON
(AUTO_CLEANUP = ON, CHANGE_RETENTION = 2 DAYS);

ALTER DATABASE [database_name]
SET CHANGE_TRACKING (CHANGE_RETENTION = 3 DAYS);

ALTER DATABASE [database_name]
SET CHANGE_TRACKING = OFF;

ALTER DATABASE [database_name]
SET CHANGE_TRACKING = OFF;


ALTER DATABASE [database_name]
SET QUERY_STORE = ON
    (
      OPERATION_MODE = READ_WRITE,
      CLEANUP_POLICY = ( STALE_QUERY_THRESHOLD_DAYS = 90 ),
      DATA_FLUSH_INTERVAL_SECONDS = 900,
      QUERY_CAPTURE_MODE = AUTO,
      MAX_STORAGE_SIZE_MB = 1024,
      INTERVAL_LENGTH_MINUTES = 60
    );
	
	
ALTER DATABASE [database_name]
SET QUERY_STORE = ON
    (
      OPERATION_MODE = READ_WRITE,
      CLEANUP_POLICY = ( STALE_QUERY_THRESHOLD_DAYS = 90 ),
      DATA_FLUSH_INTERVAL_SECONDS = 900,
      MAX_STORAGE_SIZE_MB = 1024,
      INTERVAL_LENGTH_MINUTES = 60,
      SIZE_BASED_CLEANUP_MODE = AUTO,
      MAX_PLANS_PER_QUERY = 200,
      WAIT_STATS_CAPTURE_MODE = ON
    );
	
ALTER DATABASE [database_name]
SET QUERY_STORE = ON
    (
      OPERATION_MODE = READ_WRITE,
      CLEANUP_POLICY = ( STALE_QUERY_THRESHOLD_DAYS = 90 ),
      DATA_FLUSH_INTERVAL_SECONDS = 900,
      MAX_STORAGE_SIZE_MB = 1024,
      INTERVAL_LENGTH_MINUTES = 60,
      SIZE_BASED_CLEANUP_MODE = AUTO,
      MAX_PLANS_PER_QUERY = 200,
      WAIT_STATS_CAPTURE_MODE = ON,
      QUERY_CAPTURE_MODE = CUSTOM,
      QUERY_CAPTURE_POLICY = (
        STALE_CAPTURE_POLICY_THRESHOLD = 24 HOURS,
        EXECUTION_COUNT = 30,
        TOTAL_COMPILE_CPU_TIME_MS = 1000,
        TOTAL_EXECUTION_CPU_TIME_MS = 100
      )
    );
	
ALTER TABLE Customer MERGE RANGE (10);

ALTER TABLE Customer SPLIT RANGE (75);

ALTER TABLE Orders SWITCH PARTITION 1 TO OrdersHistory PARTITION 1;

ALTER TABLE Orders MERGE RANGE ('2004-01-01');

ALTER TABLE OrdersHistory SPLIT RANGE ('2005-01-01');

ALTER MATERIALIZED VIEW My_Indexed_View DISABLE;

ALTER MATERIALIZED VIEW My_Indexed_View REBUILD;

DROP TABLE Sprockets.NineProngs;  
DROP SCHEMA Sprockets;  
GO


CREATE PROCEDURE Get10TopResellers
AS
BEGIN
    SELECT TOP (10) r.ResellerName, r.AnnualSales
    FROM DimReseller AS r
    ORDER BY AnnualSales DESC, ResellerName ASC;
END
;
GO

TRUNCATE TABLE HumanResources.JobCandidate;  
GO 

TRUNCATE TABLE PartitionTable1   
WITH (PARTITIONS (2, 4, 6 TO 8));  
GO  

ALTER SCHEMA HumanResources TRANSFER Person.Address;  
GO  

ALTER SCHEMA Person TRANSFER type::Production.TestType ;  
GO

ALTER SCHEMA Sales TRANSFER OBJECT::dbo.Region;  
GO

ALTER PROCEDURE schema_name.procedure_name
(
    @parameter1 INT,
    @parameter2 VARCHAR(50)
)
WITH RECOMPILE
AS
BEGIN
    -- SQL statements for the stored procedure go here
    -- You can include multiple statements
    SELECT column1, column2
    FROM table_name
    WHERE condition = @parameter1;
    
    UPDATE table_name
    SET column2 = @parameter2
    WHERE column1 = @parameter1;
    
    -- Additional statements...
END;


CREATE TABLE TestNew (C1 NVARCHAR(10), C2 NVARCHAR(50), C3 DATETIME)
GO
CREATE UNIQUE INDEX AK_Index ON TestNew (C2)  
WITH (DROP_EXISTING = ON)
GO

CREATE INDEX IX_VendorID ON ProductVendor (VendorID);


CREATE USER AbolrousHazem FOR LOGIN AbolrousHazem;  
GO

CREATE USER Wanida FOR LOGIN WanidaBenshoof   
    WITH DEFAULT_SCHEMA = Marketing;  
GO

CREATE USER JinghaoLiu FOR CERTIFICATE CarnationProduction50;  
GO  

CREATE USER CustomApp WITHOUT LOGIN ;  

CREATE USER Carlo  
WITH PASSWORD='RN92piTCh%$!~3K9844 Bl*'  
    , DEFAULT_LANGUAGE=[Brazilian]  
    , DEFAULT_SCHEMA=[dbo]  
GO  

CREATE USER [Contoso\Fritz] ;  
GO   

CREATE USER CarmenW WITH PASSWORD = 'a8ea v*(Rd##+'  
, SID = 0x01050000000000090300000063FF0451A9E7664BA705B10E37DDC4B7;

CREATE USER [Chin]   
WITH   
      DEFAULT_SCHEMA = dbo  
    , ALLOW_ENCRYPTED_VALUE_MODIFICATIONS = ON ; 
	
CREATE USER [bob@contoso.com] FROM LOGIN [bob@contoso.com];
GO

CREATE USER [AAD_group] FROM LOGIN [AAD_group];
GO

CREATE USER [bob@contoso.com] FROM LOGIN [AAD_group];
GO

CREATE USER [bob@contoso.com] FROM EXTERNAL PROVIDER;
GO

CREATE ROLE auditors AUTHORIZATION db_securityadmin;  
GO

CREATE ROLE buyers AUTHORIZATION BenMiller;  
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<strong password>';
GO

CREATE LOGIN <login_name> WITH PASSWORD = '<enterStrongPasswordHere>';
GO

CREATE LOGIN TestLogin WITH PASSWORD = 'SuperSecret52&&';

CREATE LOGIN TestLogin
WITH PASSWORD = 'SuperSecret52&&', SID = 0x241C11948AEEB749B0D22646DB1A19F2;

CREATE DATABASE ENCRYPTION KEY  
WITH ALGORITHM = AES_256  
ENCRYPTION BY SERVER CERTIFICATE MyServerCert;  
GO  

CREATE CERTIFICATE Shipping04   
   ENCRYPTION BY PASSWORD = 'pGFD4bb925DGvbd2439587y'  
   WITH SUBJECT = 'Sammamish Shipping Records',   
   EXPIRY_DATE = '20201031';  
GO 

CREATE CERTIFICATE Shipping11   
    FROM FILE = 'c:\Shipping\Certs\Shipping11.cer'   
    WITH PRIVATE KEY (FILE = 'c:\Shipping\Certs\Shipping11.pvk',   
    DECRYPTION BY PASSWORD = 'sldkflk34et6gs%53#v00');  
GO 

CREATE CERTIFICATE Shipping19   
    FROM EXECUTABLE FILE = 'c:\Shipping\Certs\Shipping19.dll';  
GO


CREATE CERTIFICATE Shipping19 FROM ASSEMBLY Shipping19;  
GO

CREATE CERTIFICATE Shipping04   
   WITH SUBJECT = 'Sammamish Shipping Records';  
GO

CREATE CERTIFICATE Shipping04
    FROM FILE = 'c:\storedcerts\shipping04cert.pfx'
    WITH 
    FORMAT = 'PFX', 
	PRIVATE KEY (
        DECRYPTION BY PASSWORD = '9n34khUbhk$w4ecJH5gh'
	);
	
CREATE WORKLOAD CLASSIFIER wcELTLoads WITH  
( WORKLOAD_GROUP = 'wgDataLoad'
 ,MEMBERNAME     = 'ELTRole'  
 ,WLM_LABEL      = 'dimension_loads' )
 
 CREATE WORKLOAD CLASSIFIER wcDataLoad WITH  
( WORKLOAD_GROUP = 'wgDataLoad'
 ,MEMBERNAME     = 'ELTRole'
 ,WLM_CONTEXT    = 'dim_load' )
 
 CREATE WORKLOAD CLASSIFIER wcELTLoads WITH  
( WORKLOAD_GROUP = 'wgDataLoads'
 ,MEMBERNAME     = 'ELTRole'  
 ,START_TIME     = '22:00'
 ,END_TIME       = '02:00' )
 
 CREATE WORKLOAD CLASSIFIER classifierA WITH  
( WORKLOAD_GROUP = 'wgDashboards'  
 ,MEMBERNAME     = 'userloginA'
 ,IMPORTANCE     = HIGH
 ,WLM_LABEL      = 'salereport' )

CREATE WORKLOAD CLASSIFIER classifierB WITH  
( WORKLOAD_GROUP = 'wgUserQueries'  
 ,MEMBERNAME     = 'userloginA'
 ,IMPORTANCE     = LOW
 ,START_TIME     = '18:00'
 ,END_TIME       = '07:00' )
 
 CREATE WORKLOAD CLASSIFIER wgcELTRole
  WITH (WORKLOAD_GROUP = 'staticrc20'
       ,MEMBERNAME = 'ELTRole'
      ,IMPORTANCE = above_normal);
	  
CREATE STATISTICS ContactMail1
    ON Person.Person (BusinessEntityID, EmailPromotion)
    WITH SAMPLE 5 PERCENT;
	
CREATE STATISTICS NamePurchase
    ON AdventureWorks2012.Person.Person (BusinessEntityID, EmailPromotion)
    WITH FULLSCAN, NORECOMPUTE;
	
CREATE STATISTICS ContactPromotion1
    ON Person.Person (BusinessEntityID, LastName, EmailPromotion)
WHERE EmailPromotion = 2
WITH SAMPLE 50 PERCENT;
GO

CREATE STATISTICS CustomerStats1 ON DimCustomer (CustomerKey, EmailAddress);

CREATE STATISTICS CustomerStats1 ON DimCustomer (CustomerKey, EmailAddress) WITH FULLSCAN;

CREATE STATISTICS NamePurchase
    ON AdventureWorks2012.Person.Person (BusinessEntityID, EmailPromotion)
    WITH FULLSCAN, PERSIST_SAMPLE_PERCENT = ON;


CREATE STATISTICS CustomerStats1 ON DimCustomer (CustomerKey, EmailAddress);


CREATE STATISTICS CustomerStatsFullScan
ON DimCustomer (CustomerKey, EmailAddress) WITH FULLSCAN;

CREATE STATISTICS CustomerStatsSampleScan
ON DimCustomer (CustomerKey, EmailAddress) WITH SAMPLE 50 PERCENT;


CREATE STATISTICS CustomerStats1 ON DimCustomer (CustomerKey, EmailAddress) WITH AUTO_DROP = ON


CREATE EXTERNAL FILE FORMAT textdelimited1
WITH (
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS (
        FIELD_TERMINATOR = '|',
        DATE_FORMAT = 'MM/dd/yyyy' ),
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.GzipCodec'
);


CREATE EXTERNAL FILE FORMAT rcfile1
WITH (
    FORMAT_TYPE = RCFILE,
    SERDE_METHOD = 'org.apache.hadoop.hive.serde2.columnar.LazyBinaryColumnarSerDe',
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.DefaultCodec'
);


CREATE EXTERNAL FILE FORMAT orcfile1
WITH (
    FORMAT_TYPE = ORC,
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
);
  
CREATE EXTERNAL FILE FORMAT parquetfile1
WITH (
    FORMAT_TYPE = PARQUET,
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
); 
  

CREATE EXTERNAL FILE FORMAT skipHeader_CSV
WITH (FORMAT_TYPE = DELIMITEDTEXT,
      FORMAT_OPTIONS(
          FIELD_TERMINATOR = ',',
          STRING_DELIMITER = '"',
          FIRST_ROW = 2,
          USE_TYPE_DEFAULT = True)
);


CREATE EXTERNAL FILE FORMAT jsonFileFormat
WITH (
    FORMAT_TYPE = JSON,
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
);

CREATE EXTERNAL FILE FORMAT DeltaFileFormat
WITH (
    FORMAT_TYPE = DELTA
);

CREATE EXTERNAL DATA SOURCE MyAzureStorage
WITH
  ( LOCATION = 'wasbs://daily@logs.blob.core.windows.net/' ,
    CREDENTIAL = AzureStorageCredential ,
    TYPE = HADOOP
  ) ;
  
  CREATE EXTERNAL DATA SOURCE AzureDataLakeStore
WITH
  ( LOCATION = 'adl://newyorktaxidataset.azuredatalakestore.net' ,
    CREDENTIAL = ADLS_credential ,
    TYPE = HADOOP
  ) ;
  
  CREATE EXTERNAL DATA SOURCE AzureDataLakeStore
WITH
  
  ( LOCATION = 'abfss://data@newyorktaxidataset.dfs.core.windows.net' ,
    CREDENTIAL = ADLS_credential ,
    TYPE = HADOOP
  ) ;
  
 CREATE EXTERNAL DATA SOURCE data_source_name
WITH
  ( LOCATION = 'abfss://2013@newyorktaxidataset.dfs.core.windows.net' ,
    CREDENTIAL = ADLS_credential ,
    TYPE = HADOOP
  ) ;
  
CREATE EXTERNAL DATA SOURCE ext_datasource_with_abfss
WITH
  ( TYPE = HADOOP ,
    LOCATION = 'abfss://myfile@mystorageaccount.dfs.core.windows.net' ,
    CREDENTIAL = msi_cred
  ) ;
  
CREATE DATABASE SCOPED CREDENTIAL AppCred WITH IDENTITY = 'Mary5',
    SECRET = '<EnterStrongPasswordHere>';
	
CREATE DATABASE SCOPED CREDENTIAL MyCredentials
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'QLYMgmSXMklt%2FI1U6DcVrQixnlU5Sgbtk1qDRakUBGs%3D';

CREATE DATABASE SCOPED CREDENTIAL ADL_User
WITH
    IDENTITY = '<client_id>@<OAuth_2.0_Token_EndPoint>',
    SECRET = '<key>'
;

CREATE CLUSTERED COLUMNSTORE INDEX cci ON Sales.OrderLines
WITH (DROP_EXISTING = ON);

CREATE CLUSTERED COLUMNSTORE INDEX cci ON Sales.OrderLines
WITH ( COMPRESSION_DELAY = 10 MINUTES );

CREATE CLUSTERED COLUMNSTORE INDEX cci ON Sales.OrderLines
WITH ( DATA_COMPRESSION = COLUMNSTORE_ARCHIVE );

CREATE CLUSTERED COLUMNSTORE INDEX cci ON Sales.OrderLines
WITH ( ONLINE = ON );

CREATE COLUMNSTORE INDEX ncci ON Sales.OrderLines (StockItemID, Quantity, UnitPrice, TaxRate)
WITH ( ONLINE = ON );

CREATE TABLE dbo.SimpleTable1(
    ProductKey [INT] NOT NULL,
    OrderDateKey [INT] NOT NULL,
    DueDateKey [INT] NOT NULL,
    ShipDateKey [INT] NOT NULL);
GO
CREATE CLUSTERED COLUMNSTORE INDEX cci_Simple ON dbo.SimpleTable;
GO

CREATE TABLE dbo.SimpleTable2 (
    ProductKey [INT] NOT NULL,
    OrderDateKey [INT] NOT NULL,
    DueDateKey [INT] NOT NULL,
    ShipDateKey [INT] NOT NULL);
GO
CREATE CLUSTERED INDEX cl_simple ON dbo.SimpleTable2 (ProductKey);
GO
CREATE CLUSTERED COLUMNSTORE INDEX cl_simple ON dbo.SimpleTable2
WITH (DROP_EXISTING = ON);
GO

CREATE TABLE dbo.SimpleTable3 (
    ProductKey [INT] NOT NULL,
    OrderDateKey [INT] NOT NULL,
    DueDateKey [INT] NOT NULL,
    ShipDateKey [INT] NOT NULL);
GO

CREATE INDEX nc1_simple ON dbo.SimpleTable (OrderDateKey);
CREATE INDEX nc2_simple ON dbo.SimpleTable (DueDateKey);
GO

CREATE CLUSTERED COLUMNSTORE INDEX cci_simple ON dbo.SimpleTable;
GO

CREATE TABLE dbo.MyFactTable (
    ProductKey [INT] NOT NULL,
    OrderDateKey [INT] NOT NULL,
    DueDateKey [INT] NOT NULL,
    ShipDateKey [INT] NOT NULL

);

CREATE INDEX my_index ON dbo.MyFactTable ( ProductKey, OrderDateKey )
;

CREATE CLUSTERED COLUMNSTORE
INDEX IDX_CCL_MyFactTable ON dbo.MyFactTable;
GO

CREATE CLUSTERED COLUMNSTORE
INDEX [IDX_CL_MyFactTable]
ON dbo.MyFactTable
WITH (DROP_EXISTING = ON);

CREATE CLUSTERED INDEX [IDX_CL_MyFactTable]
ON dbo.[MyFactTable] ( ProductKey )
WITH ( DROP_EXISTING = ON );

CREATE TABLE dbo.SimpleTable4 (
    ProductKey [INT] NOT NULL,
    OrderDateKey [INT] NOT NULL,
    DueDateKey [INT] NOT NULL,
    ShipDateKey [INT] NOT NULL);
GO

CREATE CLUSTERED INDEX cl_simple ON dbo.SimpleTable (ProductKey);
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX csindx_simple
ON dbo.SimpleTable (OrderDateKey, DueDateKey, ShipDateKey);
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX csindx_simple
ON SimpleTable (OrderDateKey, DueDateKey, ShipDateKey)
WITH (DROP_EXISTING =  ON,
    MAXDOP = 2)
ON "DEFAULT";
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX "FIBillOfMaterialsWithEndDate"
    ON Production.BillOfMaterials (ComponentID, StartDate)
    WHERE EndDate IS NOT NULL;
	
CREATE CLUSTERED COLUMNSTORE INDEX [ClusteredIndex_1bd8af8797f7453182903cc68df48541]
ON xdimProduct
WITH ( DROP_EXISTING = ON );
GO


CREATE CLUSTERED COLUMNSTORE INDEX cci_xDimProduct
ON xdimProduct
WITH ( DROP_EXISTING = ON );

CREATE CLUSTERED COLUMNSTORE INDEX mycci_xDimProduct
ON xdimProduct
WITH ( DROP_EXISTING = OFF );

CREATE CLUSTERED INDEX cci_xDimProduct
ON xdimProduct (ProductKey, ProductAlternateKey, ProductSubcategoryKey, WeightUnitMeasureCode)
WITH ( DROP_EXISTING = ON);

CREATE CLUSTERED COLUMNSTORE INDEX cci ON Sales.OrderLines
ORDER (SHIPDATE);

CREATE CLUSTERED COLUMNSTORE INDEX cci ON Sales.OrderLines
ORDER (SHIPDATE)
WITH (DROP_EXISTING = ON);

CREATE CLUSTERED COLUMNSTORE INDEX cci ON Sales.OrderLines
ORDER (SHIPDATE, PRODUCTKEY)
WITH (DROP_EXISTING = ON);

CREATE CLUSTERED COLUMNSTORE INDEX cci ON Sales.OrderLines
ORDER (PRODUCTKEY,SHIPDATE)
WITH (DROP_EXISTING = ON);

CREATE CLUSTERED COLUMNSTORE INDEX [OrderedCCI] ON dbo.FactResellerSalesPartCategoryFull
ORDER (EnglishProductSubcategoryName, EnglishProductName)
WITH (MAXDOP = 1, DROP_EXISTING = ON);

DROP USER AbolrousHazem;  
GO

DROP ROLE purchasing;  
GO

DROP MASTER KEY;  
GO  

DROP LOGIN WilliJo;  
GO

DROP DATABASE ENCRYPTION KEY;  
GO 

DROP CERTIFICATE Shipping04; 

DROP STATISTICS Purchasing.Vendor.VendorCredit, Sales.SalesOrderHeader.CustomerTotal; 

DROP STATISTICS Customer.CustomerStats1;  
DROP STATISTICS dbo.Customer.CustomerStats1;

DROP WORKLOAD CLASSIFIER wgcELTRole;

DROP EXTERNAL DATA SOURCE mydatasource;

DROP EXTERNAL FILE FORMAT myfileformat;

ALTER USER Mary5 WITH NAME = Mary51;
GO

ALTER USER Mary51 WITH DEFAULT_SCHEMA = Purchasing;
GO

ALTER ROLE buyers WITH NAME = purchasing;

CREATE ROLE Sales;  
ALTER ROLE Sales ADD MEMBER Barry;  
ALTER ROLE Sales DROP MEMBER Barry;

CREATE LOGIN sqllogin_nlastname WITH password='aah3%#om1os';
    
 CREATE USER sqllogin_nlastname FOR LOGIN sqllogin_nlastname 
 WITH DEFAULT_SCHEMA = master;
    
 ALTER ROLE [dbmanager] add member sqllogin_nlastname;
 
ALTER MASTER KEY REGENERATE WITH ENCRYPTION BY PASSWORD = 'dsjdkflJ435907NnmM#sX003';
GO

ALTER MASTER KEY REGENERATE WITH ENCRYPTION BY PASSWORD = 'dsjdkflJ435907NnmM#sX003';
GO

ALTER LOGIN Mary5 ENABLE;

ALTER LOGIN Mary5 WITH PASSWORD = '<enterStrongPasswordHere>';

ALTER LOGIN Mary5 WITH NAME = John2;

ALTER LOGIN John2 WITH CREDENTIAL = Custodian04;

ALTER LOGIN Mary5
ADD CREDENTIAL EKMProvider1;
GO

ALTER LOGIN [Mary5] WITH PASSWORD = '****' UNLOCK ;
GO

ALTER LOGIN TestUser WITH
PASSWORD = 0x01000CF35567C60BFB41EBDE4CF700A985A13D773D6B45B90900 HASHED ;
GO

  
ALTER DATABASE ENCRYPTION KEY  
REGENERATE WITH ALGORITHM = AES_256;  
GO

ALTER CERTIFICATE Shipping04   
    REMOVE PRIVATE KEY;  
GO

ALTER CERTIFICATE Shipping11   
    WITH PRIVATE KEY (DECRYPTION BY PASSWORD = '95hkjdskghFDGGG4%',  
    ENCRYPTION BY PASSWORD = '34958tosdgfkh##38');  
GO

ALTER CERTIFICATE Shipping13   
    WITH PRIVATE KEY (FILE = 'c:\importedkeys\Shipping13',  
    DECRYPTION BY PASSWORD = 'GDFLKl8^^GGG4000%');  
GO

ALTER CERTIFICATE Shipping13   
    WITH PRIVATE KEY (FILE = 'c:\importedkeys\Shipping13',  
    DECRYPTION BY PASSWORD = 'GDFLKl8^^GGG4000%');  
GO

ALTER CERTIFICATE Shipping15   
    WITH PRIVATE KEY (DECRYPTION BY PASSWORD = '95hk000eEnvjkjy#F%');  
GO

ALTER AUTHORIZATION ON database::testdb TO DisabledLogin;

ALTER AUTHORIZATION ON OBJECT::Parts.Sprockets TO MichikoOsada;
GO
 
 
ALTER AUTHORIZATION ON Parts.Sprockets TO MichikoOsada;
GO
 
ALTER AUTHORIZATION ON Sprockets TO MichikoOsada;
ALTER AUTHORIZATION ON OBJECT::Sprockets TO MichikoOsada;

ALTER AUTHORIZATION ON OBJECT::Production.ProductionView06 TO SCHEMA OWNER;
GO

ALTER AUTHORIZATION ON SCHEMA::SeattleProduction11 TO SandraAlayo;
GO

ALTER AUTHORIZATION ON ENDPOINT::CantabSalesServer1 TO JaePak;
GO

ALTER AUTHORIZATION ON Sprockets TO MichikoOsada;
ALTER AUTHORIZATION ON dbo.Sprockets TO MichikoOsada;
ALTER AUTHORIZATION ON OBJECT::Sprockets TO MichikoOsada;
ALTER AUTHORIZATION ON OBJECT::dbo.Sprockets TO MichikoOsada;

ALTER AUTHORIZATION ON DATABASE::Parts TO MichikoOsada;

ALTER AUTHORIZATION ON database::targetDB TO [rachel@cqclinic.onmicrosoft.com];

GRANT CONTROL ON USER::Wanida TO RolandX;  
GO

GRANT VIEW DEFINITION ON ROLE::SammamishParking   
    TO JinghaoLiu WITH GRANT OPTION;  
GO

GRANT IMPERSONATE ON USER::HamithaL TO AccountsPayable17;  
GO

GRANT TAKE OWNERSHIP ON AVAILABILITY GROUP::MyAg TO PKomosinski   
    WITH GRANT OPTION;  
GO  

GRANT CONTROL ON AVAILABILITY GROUP::MyAg TO PKomosinski;  
GO  

GRANT CREATE TABLE TO MelanieK;
GO

GRANT SHOWPLAN TO AuditMonitor;
GO

GRANT CREATE VIEW TO CarmineEs WITH GRANT OPTION;
GO

GRANT CONTROL ON DATABASE::AdventureWorks2012 TO Sarah;
GO

GRANT TAKE OWNERSHIP ON ENDPOINT::Shipping83 TO PKomosinski   
    WITH GRANT OPTION;  
GO  

GRANT VIEW DEFINITION ON ENDPOINT::Mirror7 TO ZArifin;  
GO  

GRANT CONTROL  
    ON FULLTEXT CATALOG :: ProductCatalog  
    TO Ted ;
	
GRANT VIEW DEFINITION  
    ON FULLTEXT STOPLIST :: ProductStoplist  
    TO Mary ;
	
GRANT SELECT ON OBJECT::Person.Address TO RosaQdM;  
GO  

GRANT EXECUTE ON OBJECT::HumanResources.uspUpdateEmployeeHireInfo  
    TO Recruiting11;  
GO

GRANT REFERENCES (BusinessEntityID) ON OBJECT::HumanResources.vEmployee   
    TO Wanida WITH GRANT OPTION;  
GO 

GRANT SELECT ON Person.Address TO RosaQdM;  
GO

GRANT SELECT ON Person.Address TO [AdventureWorks2012\RosaQdM];  
GO

CREATE ROLE newrole ;  
GRANT EXECUTE ON dbo.uspGetBillOfMaterials TO newrole ;  
GO

GRANT IMPERSONATE ON LOGIN::WanidaBenshoof to [AdvWorks\YoonM];  
GO  

GRANT VIEW DEFINITION ON LOGIN::EricKurjan TO RMeyyappan   
    WITH GRANT OPTION;  
GO   

GRANT VIEW DEFINITION ON SERVER ROLE::Sales TO Auditors ;  
GO  

GRANT SELECT ON OBJECT::Person.Address TO RosaQdM;  
GO 

GRANT EXECUTE ON OBJECT::HumanResources.uspUpdateEmployeeHireInfo  
    TO Recruiting11;  
GO 

GRANT CONTROL ON USER::Wanida TO RolandX;  
GO

GRANT VIEW DEFINITION ON ROLE::SammamishParking   
    TO JinghaoLiu WITH GRANT OPTION;  
GO

GRANT VIEW DEFINITION ON ROLE::SammamishParking   
    TO JinghaoLiu WITH GRANT OPTION;  
GO

GRANT IMPERSONATE ON USER::HamithaL TO AccountsPayable17;  
GO

GRANT SELECT ON SCHEMA :: Person TO WilJo WITH GRANT OPTION;

GRANT CONTROL SERVER TO TerryEminhizer;  
GO  

GRANT ALTER ANY EVENT NOTIFICATION TO JanethEsteves WITH GRANT OPTION;  
GO  

CREATE SERVER ROLE ITDevelopers ;  
GRANT ALTER ANY DATABASE TO ITDevelopers ;  
GO

GRANT SELECT ON sys.sql_logins TO Sylvester1;  
GRANT VIEW SERVER STATE to Sylvester1;  
GO  

GRANT EXECUTE ON xp_readmail TO Sylvester1;  
GO

GRANT VIEW DEFINITION ON TYPE::Telemarketing.PhoneNumber   
    TO KhalidR WITH GRANT OPTION;  
GO

GRANT CONTROL ON USER::Wanida TO RolandX;  
GO

GRANT IMPERSONATE ON USER::HamithaL TO AccountsPayable17;  
GO

GRANT VIEW DEFINITION ON ROLE::SammamishParking   
    TO JinghaoLiu WITH GRANT OPTION;  
GO

GRANT EXECUTE ON XML SCHEMA COLLECTION::Sales.Invoices4 TO Wanida;  
GO

DENY CONTROL ON USER::Wanida TO RolandX;  
GO 

DENY VIEW DEFINITION ON ROLE::SammamishParking   
    TO JinghaoLiu CASCADE;  
GO  

DENY IMPERSONATE ON USER::HamithaL TO AccountsPayable17;  
GO  

DENY VIEW DEFINITION ON ROLE::SammamishParking   
    TO JinghaoLiu CASCADE;  
GO 

DENY IMPERSONATE ON USER::HamithaL TO AccountsPayable17;  
GO

DENY VIEW DEFINITION ON AVAILABILITY GROUP::MyAg TO ZArifin;  
GO  

DENY TAKE OWNERSHIP ON AVAILABILITY GROUP::MyAg TO PKomosinski   
    CASCADE;  
GO  

DENY CREATE CERTIFICATE TO MelanieK;
GO

DENY REFERENCES TO AuditMonitor;
GO

DENY VIEW DEFINITION TO CarmineEs CASCADE;
GO

DENY VIEW DEFINITION ON ENDPOINT::Mirror7 TO ZArifin;  
GO

DENY TAKE OWNERSHIP ON ENDPOINT::Shipping83 TO PKomosinski   
    CASCADE;  
GO  

DENY SELECT ON OBJECT::Person.Address TO RosaQdM;  
GO

DENY EXECUTE ON OBJECT::HumanResources.uspUpdateEmployeeHireInfo  
    TO Recruiting11;  
GO

DENY REFERENCES (BusinessEntityID) ON OBJECT::HumanResources.vEmployee   
    TO Wanida CASCADE;  
GO

DENY VIEW DEFINITION ON LOGIN::EricKurjan TO RMeyyappan   
    CASCADE;  
GO   

DENY VIEW DEFINITION ON SERVER ROLE::Sales TO Auditors ;  
GO   

DENY CONNECT SQL TO Annika CASCADE;  
GO  

DENY CREATE ENDPOINT TO ArifS AS MandarP;  
GO 

DENY SELECT ON OBJECT::Person.Address TO RosaQdM;  
GO 

DENY EXECUTE ON OBJECT::HumanResources.uspUpdateEmployeeHireInfo  
    TO Recruiting11;  
GO

DENY REFERENCES (BusinessEntityID) ON OBJECT::HumanResources.vEmployee   
    TO Wanida CASCADE;  
GO

DENY ALTER ON SYMMETRIC KEY::SamInventory42 TO HamidS;  
GO 

DENY EXECUTE ON sys.xp_cmdshell TO public;  
GO  

DENY VIEW DEFINITION ON TYPE::Telemarketing.PhoneNumber   
    TO KhalidR CASCADE;  
GO

DENY EXECUTE ON XML SCHEMA COLLECTION::Sales.Invoices4 TO Wanida;  
GO  

REVOKE CONTROL ON USER::Wanida FROM RolandX;  
GO  

REVOKE VIEW DEFINITION ON ROLE::SammamishParking   
    FROM JinghaoLiu CASCADE;  
GO  

REVOKE IMPERSONATE ON USER::HamithaL FROM AccountsPayable17;  
GO 

REVOKE VIEW DEFINITION ON AVAILABILITY GROUP::MyAg TO ZArifin;  
GO  

REVOKE TAKE OWNERSHIP ON AVAILABILITY GROUP::MyAg TO PKomosinski   
    CASCADE;  
GO 

GRANT CONTROL ON AVAILABILITY GROUP::MyAg TO PKomosinski   
    WITH GRANT OPTION;  
GO  
REVOKE GRANT OPTION FOR CONTROL ON AVAILABILITY GROUP::MyAg TO PKomosinski  
CASCADE  
GO  

REVOKE VIEW DEFINITION ON ENDPOINT::Mirror7 FROM ZArifin;  
GO 

REVOKE TAKE OWNERSHIP ON ENDPOINT::Shipping83 FROM PKomosinski   
    CASCADE;  
GO  

REVOKE SELECT ON OBJECT::Person.Address FROM RosaQdM;  
GO  

REVOKE EXECUTE ON OBJECT::HumanResources.uspUpdateEmployeeHireInfo  
    FROM Recruiting11;  
GO

REVOKE REFERENCES (BusinessEntityID) ON OBJECT::HumanResources.vEmployee   
    FROM Wanida CASCADE;  
GO  

REVOKE IMPERSONATE ON LOGIN::WanidaBenshoof FROM [AdvWorks\YoonM];  
GO  

REVOKE VIEW DEFINITION ON LOGIN::EricKurjan FROM RMeyyappan   
    CASCADE;  
GO 

REVOKE VIEW DEFINITION ON SERVER ROLE::Sales TO Auditors ;  
GO 

REVOKE VIEW SERVER STATE FROM WanidaBenshoof;  
GO 

REVOKE GRANT OPTION FOR CONNECT SQL FROM JanethEsteves;  
GO  

REVOKE EXECUTE ON OBJECT::HumanResources.uspUpdateEmployeeHireInfo  
    FROM Recruiting11;  
GO 

REVOKE REFERENCES (BusinessEntityID) ON OBJECT::HumanResources.vEmployee   
    FROM Wanida CASCADE;  
GO  

REVOKE EXECUTE ON sys.sp_addlinkedserver FROM public;  
GO  

REVOKE VIEW DEFINITION ON TYPE::Telemarketing.PhoneNumber   
    FROM KhalidR CASCADE;  
GO 

REVOKE EXECUTE ON XML SCHEMA COLLECTION::Sales.Invoices4 FROM Wanida;  
GO

CREATE SCHEMA Sprockets AUTHORIZATION Annik  
    CREATE TABLE NineProngs (source int, cost int, partnumber int)  
    GRANT SELECT ON SCHEMA::Sprockets TO Mandar  
    DENY SELECT ON SCHEMA::Sprockets TO Prasanna;  
GO  

CREATE SCHEMA Sales;  
GO
  
CREATE TABLE Sales.Region   
(Region_id INT NOT NULL,  
Region_Name CHAR(5) NOT NULL)  
WITH (DISTRIBUTION = REPLICATE);  
GO

CREATE SCHEMA Production AUTHORIZATION [Contoso\Mary];  
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '43987hkhj4325tsku7';  
GO  

OPEN MASTER KEY DECRYPTION BY PASSWORD = '43987hkhj4325tsku7';  
GO 


OPEN MASTER KEY DECRYPTION BY PASSWORD = '43987hkhj4325tsku7';  
GO   
CLOSE MASTER KEY;  
GO  

CLOSE MASTER KEY;  
GO 

BACKUP CERTIFICATE sales05 TO FILE = 'c:\storedcerts\sales05cert';  
GO

BACKUP CERTIFICATE sales05 TO FILE = 'c:\storedcerts\sales05cert'  
    WITH PRIVATE KEY ( FILE = 'c:\storedkeys\sales05key' ,   
    ENCRYPTION BY PASSWORD = '997jkhUbhk$w4ez0876hKHJH5gh' );  
GO

BACKUP CERTIFICATE sales09 TO FILE = 'c:\storedcerts\sales09cert'   
    WITH PRIVATE KEY ( DECRYPTION BY PASSWORD = '9875t6#6rfid7vble7r' ,  
    FILE = 'c:\storedkeys\sales09key' ,   
    ENCRYPTION BY PASSWORD = '9n34khUbhk$w4ecJH5gh' );  
GO

BACKUP CERTIFICATE Shipping04 TO FILE = 'c:\storedcerts\shipping04cert.pfx'
WITH  
    FORMAT = 'PFX',  
    PRIVATE KEY ( 
ENCRYPTION BY PASSWORD = '9n34khUbhk$w4ecJH5gh',  
ALGORITHM = 'AES_256'
    )
	
RENAME DATABASE AdWorks to AdWorks2;

RENAME OBJECT Customer TO Customer1;

RENAME OBJECT mydb.dbo.Customer TO Customer1;

ALTER SCHEMA dbo TRANSFER OBJECT::product.item;

RENAME OBJECT::Customer COLUMN FName TO FirstName;

RENAME OBJECT mydb.dbo.Customer COLUMN FName TO FirstName;

UPDATE STATISTICS t1 (a,b);

UPDATE STATISTICS t1 (a) WITH SAMPLE 10 ROWS;

UPDATE STATISTICS t1 (a) WITH NORECOMPUTE;

UPDATE STATISTICS t1 (a) WITH INCREMENTAL = ON;

UPDATE STATISTICS t1 (a) WITH stats_stream = 0x01;

UPDATE STATISTICS Sales.SalesOrderDetail;  
GO  

UPDATE STATISTICS Sales.SalesOrderDetail AK_SalesOrderDetail_rowguid;  
GO

CREATE STATISTICS Products
    ON Production.Product ([Name], ProductNumber)
    WITH SAMPLE 50 PERCENT

UPDATE STATISTICS Production.Product(Products)
    WITH SAMPLE 50 PERCENT;
	
UPDATE STATISTICS Production.Product(Products)  
	WITH FULLSCAN, NORECOMPUTE;  
	GO 
	
UPDATE STATISTICS Customer (CustomerStats1);

UPDATE STATISTICS Customer (CustomerStats1) WITH FULLSCAN;

UPDATE STATISTICS Customer;

UPDATE STATISTICS Customer (CustomerStats1) WITH AUTO_DROP = ON;

DELETE FROM Sales.SalesPersonQuotaHistory;  
GO

DELETE FROM Production.ProductCostHistory  
WHERE StandardCost > 1000.00;  
GO

DELETE FROM HumanResources.EmployeePayHistory  
WHERE CURRENT OF complex_cursor;  

DELETE FROM Sales.SalesPersonQuotaHistory   
WHERE BusinessEntityID IN   
    (SELECT BusinessEntityID   
     FROM Sales.SalesPerson   
     WHERE SalesYTD > 2500000.00);  
GO 

DELETE FROM Sales.SalesPersonQuotaHistory   
FROM Sales.SalesPersonQuotaHistory AS spqh  
INNER JOIN Sales.SalesPerson AS sp  
ON spqh.BusinessEntityID = sp.BusinessEntityID  
WHERE sp.SalesYTD > 2500000.00;  
GO  

DELETE spqh  
  FROM  
        Sales.SalesPersonQuotaHistory AS spqh  
    INNER JOIN Sales.SalesPerson AS sp  
        ON spqh.BusinessEntityID = sp.BusinessEntityID  
  WHERE  sp.SalesYTD > 2500000.00;
  
DELETE TOP (20)   
FROM Purchasing.PurchaseOrderDetail  
WHERE DueDate < '20020701';  
GO  

DELETE FROM Purchasing.PurchaseOrderDetail  
WHERE PurchaseOrderDetailID IN  
   (SELECT TOP 10 PurchaseOrderDetailID   
    FROM Purchasing.PurchaseOrderDetail   
    ORDER BY DueDate ASC);  
GO 

DELETE MyLinkServer.AdventureWorks2012.HumanResources.Department 
WHERE DepartmentID > 16;  
GO  

DELETE OPENQUERY (MyLinkServer, 'SELECT Name, GroupName 
FROM AdventureWorks2012.HumanResources.Department  
WHERE DepartmentID = 18');  
GO 

DELETE FROM OPENDATASOURCE('SQLNCLI',  
    'Data Source= <server_name>; Integrated Security=SSPI')  
    .AdventureWorks2012.HumanResources.Department   
WHERE DepartmentID = 17;

DELETE Sales.ShoppingCartItem  
OUTPUT DELETED.*   
WHERE ShoppingCartID = 20621;


	
DELETE FROM Table1;

DELETE FROM Table1  
WHERE StandardCost > 1000.00;

DELETE FROM Table1  
OPTION ( LABEL = N'label1' );

DELETE FROM dbo.FactInternetSales  
WHERE ProductKey IN (   
    SELECT T1.ProductKey FROM dbo.DimProduct T1   
    JOIN dbo.DimProductSubcategory T2  
    ON T1.ProductSubcategoryKey = T2.ProductSubcategoryKey  
    WHERE T2.EnglishProductSubcategoryName = 'Road Bikes' )  
OPTION ( LABEL = N'CustomJoin', HASH JOIN ) ;  


DELETE tableA WHERE EXISTS (
SELECT TOP 1 1 FROM tableB tb WHERE tb.col1 = tableA.col1
)

DELETE Production.ProductProductPhoto  
OUTPUT DELETED.ProductID,  
       p.Name,  
       p.ProductModelID,  
       DELETED.ProductPhotoID  
    INTO @MyTableVar  
FROM Production.ProductProductPhoto AS ph  
JOIN Production.Product as p   
    ON ph.ProductID = p.ProductID   
    WHERE p.ProductModelID BETWEEN 120 and 130;  
	
	
INSERT INTO Cities (Location)  
VALUES ( CONVERT(Point, '12.3:46.2') );

INSERT INTO Cities (Location)  
VALUES ( dbo.CreateNewPoint(x, y) );

INSERT INTO Production.UnitMeasure  
VALUES (N'FT', N'Feet', '20080414');

INSERT INTO Production.UnitMeasure  
VALUES (N'FT2', N'Square Feet', '20080923'), (N'Y', N'Yards', '20080923')
    , (N'Y3', N'Cubic Yards', '20080923');
	
INSERT INTO Production.UnitMeasure (Name, UnitMeasureCode,  
    ModifiedDate)  
VALUES (N'Square Yards', N'Y2', GETDATE());

INSERT INTO dbo.T1 (column_4)   
    VALUES ('Explicit value');  
INSERT INTO dbo.T1 (column_2, column_4)   
    VALUES ('Explicit value', 'Explicit value');  
INSERT INTO dbo.T1 (column_2)   
    VALUES ('Explicit value');  
INSERT INTO T1 DEFAULT VALUES;   
GO  

INSERT T1 VALUES ('Row #1');  
INSERT T1 (column_2) VALUES ('Row #2');  
GO  

INSERT INTO T1 (column_1,column_2)   
    VALUES (-99, 'Explicit identity value');  
GO 

 
INSERT INTO dbo.T1 (column_2)   
    VALUES (NEWID());  
INSERT INTO T1 DEFAULT VALUES;   
GO   

INSERT INTO dbo.Points (PointValue) VALUES (CONVERT(Point, '3,4'));  
INSERT INTO dbo.Points (PointValue) VALUES (CONVERT(Point, '1,5'));  
INSERT INTO dbo.Points (PointValue) VALUES (CAST ('1,99' AS Point));
	
INSERT INTO dbo.EmployeeSales  
    SELECT 'SELECT', sp.BusinessEntityID, c.LastName, sp.SalesYTD   
    FROM Sales.SalesPerson AS sp  
    INNER JOIN Person.Person AS c  
        ON sp.BusinessEntityID = c.BusinessEntityID  
    WHERE sp.BusinessEntityID LIKE '2%'  
    ORDER BY sp.BusinessEntityID, c.LastName;  
GO  

INSERT INTO dbo.EmployeeSales   
EXECUTE dbo.uspGetEmployeeSales;  
GO	

INSERT INTO dbo.EmployeeSales   
EXECUTE   
('  
SELECT ''EXEC STRING'', sp.BusinessEntityID, c.LastName,   
    sp.SalesYTD   
    FROM Sales.SalesPerson AS sp   
    INNER JOIN Person.Person AS c  
        ON sp.BusinessEntityID = c.BusinessEntityID  
    WHERE sp.BusinessEntityID LIKE ''2%''  
    ORDER BY sp.BusinessEntityID, c.LastName  
');  
GO  

INSERT INTO HumanResources.NewEmployee   
    SELECT EmpID, LastName, FirstName, Phone,   
           Address, City, StateProvince, PostalCode, CurrentFlag  
    FROM EmployeeTemp;  
GO  

INSERT TOP(5)INTO dbo.EmployeeSales  
    OUTPUT inserted.EmployeeID, inserted.FirstName, 
        inserted.LastName, inserted.YearlySales  
    SELECT sp.BusinessEntityID, c.LastName, c.FirstName, sp.SalesYTD   
    FROM Sales.SalesPerson AS sp  
    INNER JOIN Person.Person AS c  
        ON sp.BusinessEntityID = c.BusinessEntityID  
    WHERE sp.SalesYTD > 250000.00  
    ORDER BY sp.SalesYTD DESC; 
	
INSERT INTO dbo.EmployeeSales  
    OUTPUT inserted.EmployeeID, inserted.FirstName, 
        inserted.LastName, inserted.YearlySales  
    SELECT TOP (5) sp.BusinessEntityID, c.LastName, c.FirstName, sp.SalesYTD   
    FROM Sales.SalesPerson AS sp  
    INNER JOIN Person.Person AS c  
        ON sp.BusinessEntityID = c.BusinessEntityID  
    WHERE sp.SalesYTD > 250000.00  
    ORDER BY sp.SalesYTD DESC;
	
INSERT INTO V1   
    VALUES ('Row 1',1);  
GO  

INSERT INTO @MyTableVar (LocationID, CostRate, ModifiedDate)  
    SELECT LocationID, CostRate, GETDATE() 
    FROM Production.Location  
    WHERE CostRate > 0;  
	
INSERT INTO MyLinkServer.AdventureWorks2012.HumanResources.Department (Name, GroupName)  
VALUES (N'Public Relations', N'Executive General and Administration');  
GO  

INSERT OPENQUERY (MyLinkServer, 
    'SELECT Name, GroupName 
     FROM AdventureWorks2012.HumanResources.Department')  
VALUES ('Environmental Impact', 'Engineering');  
GO 

INSERT INTO OPENDATASOURCE('SQLNCLI',  
    'Data Source= <server_name>; Integrated Security=SSPI')  
    .AdventureWorks2012.HumanResources.Department (Name, GroupName)  
    VALUES (N'Standards and Methods', 'Quality Assurance');  
GO  

INSERT INTO dbo.FastCustomer2009  
SELECT T.* FROM Insured_Customers T1 JOIN CarSensor_Data T2  
ON (T1.CustomerKey = T2.CustomerKey)  
WHERE T2.YearMeasured = 2009 and T2.Speed > 40; 

INSERT INTO HumanResources.Department WITH (IGNORE_TRIGGERS) (Name, GroupName)  
SELECT b.Name, b.GroupName   
FROM OPENROWSET (  
    BULK 'C:SQLFilesDepartmentData.txt',  
    FORMATFILE = 'C:SQLFilesBulkloadFormatFile.xml',  
    ROWS_PER_BATCH = 15000)AS b ;  
	
INSERT INTO Production.Location WITH (XLOCK)  
(Name, CostRate, Availability)  
VALUES ( N'Final Inventory', 15.00, 80.00);

INSERT Production.ScrapReason  
    OUTPUT INSERTED.ScrapReasonID, INSERTED.Name, INSERTED.ModifiedDate  
        INTO @MyTableVar  
VALUES (N'Operator error', GETDATE());  

  
INSERT INTO dbo.EmployeeSales (LastName, FirstName, CurrentSales)  
  OUTPUT INSERTED.LastName,   
         INSERTED.FirstName,   
         INSERTED.CurrentSales  
  INTO @MyTableVar  
    SELECT c.LastName, c.FirstName, sp.SalesYTD  
    FROM Sales.SalesPerson AS sp  
    INNER JOIN Person.Person AS c  
        ON sp.BusinessEntityID = c.BusinessEntityID  
    WHERE sp.BusinessEntityID LIKE '2%'  
    ORDER BY c.LastName, c.FirstName; 
	
INSERT INTO DimCurrency   
VALUES (500, N'C1', N'Currency1')  
OPTION ( LABEL = N'label1' ); 


  
INSERT INTO DimCustomer (CustomerKey, CustomerAlternateKey, 
    FirstName, MiddleName, LastName )   
SELECT ProspectiveBuyerKey, ProspectAlternateKey, 
    FirstName, MiddleName, LastName  
FROM ProspectiveBuyer p JOIN DimGeography g ON p.PostalCode = g.PostalCode  
WHERE g.CountryRegionCode = 'FR'  
OPTION ( LABEL = 'Add French Prospects', HASH JOIN);


CREATE TABLE new_myTable
  (  
   id int NOT NULL,  
   lastName varchar(20),  
   zipCode varchar(6)  
  )  
WITH  
  (   
    DISTRIBUTION = ROUND_ROBIN
  )  
;

CREATE VIEW nwe_Customers  
AS  
    SELECT TOP (10) r.ResellerName, r.AnnualSales
    FROM DimReseller;

;
GO
 

CREATE TABLE dbo.doc_exd (column_a INT) ;
GO
ALTER TABLE dbo.doc_exd 
ADD CONSTRAINT exd_check CHECK (column_a > 1) ;
GO



CREATE TABLE table_pk ( mycolumnnn1 nvarchar , mycolumnnn2 INT);

ALTER TABLE table_pk
ADD 
	CONSTRAINT PK_Constrain PRIMARY KEY CLUSTERED (mycolumnnn1)
	,CONSTRAINT unique_Constrain unique CLUSTERED (mycolumnnn2)
	;

-- Create the parent table
CREATE TABLE dbo.ParentTable
(
    ParentID INT NOT NULL PRIMARY KEY,
    ParentName NVARCHAR(100) NOT NULL
);

-- Create the child table without the foreign key
CREATE TABLE dbo.ChildTable
(
    ChildID INT NOT NULL PRIMARY KEY,
    ChildName NVARCHAR(100) NOT NULL,
    ParentID INT NOT NULL
);


-- Add the foreign key constraint
ALTER TABLE dbo.ChildTable
ADD CONSTRAINT FK_ChildTable_ParentTable
FOREIGN KEY (ParentID) REFERENCES dbo.ParentTable(ParentID); 

CREATE TABLE dbo.ExampleTable
(
    ID INT NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    Age INT,
    CreatedDate DATETIME DEFAULT GETDATE()
);

ALTER INDEX index1 ON table1 REBUILD;
ALTER INDEX ALL ON table1 REBUILD;
ALTER INDEX ALL ON dbo.table1 REBUILD;


ALTER INDEX idxcci_cci_target ON cci_target REORGANIZE WITH (COMPRESS_ALL_ROW_GROUPS = ON);

-- REORGANIZE a specific partition
ALTER INDEX cci_FactInternetSales2 ON FactInternetSales2 REORGANIZE PARTITION = 0;

ALTER INDEX cci_FactInternetSales2 ON FactInternetSales2 REORGANIZE PARTITION = 0 WITH (COMPRESS_ALL_ROW_GROUPS = ON);

UPDATE dbo.Table2   
SET dbo.Table2.ColB = dbo.Table2.ColB + dbo.Table1.ColB  
FROM dbo.Table2   
    INNER JOIN dbo.Table1   
    ON (dbo.Table2.ColA = dbo.Table1.ColA);  
	
UPDATE dbo.Table1   
SET c2 = c2 + d2   
FROM dbo.Table2   
WHERE CURRENT OF abc; 


UPDATE Cities  
SET Location.SetXY(23.5, 23.5)  
WHERE Name = 'Anchorage';

WITH cte AS (SELECT * FROM @x)  
UPDATE x  
SET Value = y.Value  
FROM cte AS x  
INNER JOIN @y AS y ON y.ID = x.ID;  

WITH cte AS (SELECT * FROM @x)  
UPDATE cte   -- cte is not referenced by the alias.  
SET Value = y.Value  
FROM cte AS x  -- cte is assigned an alias.  
INNER JOIN @y AS y ON y.ID = x.ID;   

UPDATE Sales.SalesPerson  
SET Bonus = 6000, CommissionPct = 0.10, SalesQuota = NULL; 

CREATE TABLE test_weight_null (
    weight_grams INT NULL
);

CREATE TABLE test_weight_not_null (
    weight_grams INT NOT NULL
);

ALTER TABLE test_weight_null ADD CONSTRAINT exd_check CHECK (weight_grams IS NULL OR weight_grams >= 0);