CREATE TABLE UDTypeTable
(
    u UTF8STRING,
    ustr AS u.ToString() PERSISTED
);

CREATE TABLE dbo.PurchaseOrderDetail
(
    PurchaseOrderID int NOT NULL
        REFERENCES Purchasing.PurchaseOrderHeader(PurchaseOrderID),
    LineNumber smallint NOT NULL,
    ProductID int NULL
        REFERENCES Production.Product(ProductID),
    UnitPrice money NULL,
    OrderQty smallint NULL,
    ReceivedQty float NULL,
    RejectedQty float NULL,
    DueDate datetime NULL,
    rowguid uniqueidentifier ROWGUIDCOL NOT NULL
        CONSTRAINT DF_PurchaseOrderDetail_rowguid DEFAULT (NEWID()),
    ModifiedDate datetime NOT NULL
        CONSTRAINT DF_PurchaseOrderDetail_ModifiedDate DEFAULT (GETDATE()),
    LineTotal AS ((UnitPrice*OrderQty)),
    StockedQty AS ((ReceivedQty-RejectedQty)),
    CONSTRAINT PK_PurchaseOrderDetail_PurchaseOrderID_LineNumber
               PRIMARY KEY CLUSTERED (PurchaseOrderID, LineNumber)
               WITH (IGNORE_DUP_KEY = OFF)
)
ON PRIMARY;

CREATE TABLE HumanResources.EmployeeResumes
(
    LName nvarchar(25),
    FName nvarchar(25),
    Resume xml(DOCUMENT HumanResources.HRResumeSchemaCollection)
);

CREATE TABLE PartitionTable (col1 int, col2 char(10))
    ON myRangePS1 (col1);
GO


CREATE TABLE dbo.Globally_Unique_Data
(
    GUID UNIQUEIDENTIFIER
        CONSTRAINT Guid_Default DEFAULT
        NEWSEQUENTIALID() ROWGUIDCOL,
    Employee_Name VARCHAR(60)
    CONSTRAINT Guid_PK PRIMARY KEY (GUID)
);

CREATE TABLE dbo.mytable
(
    low INT,
    high INT,
    myavg AS (low + high)/2
);

CREATE TABLE UDTypeTable
(
    u UTF8STRING,
    ustr AS u.ToString() PERSISTED
);

CREATE TABLE dbo.mylogintable
(
    date_in DATETIME,
    user_id INT,
    myuser_name AS USER_NAME()
);

CREATE TABLE dbo.EmployeePhoto
(
    EmployeeId INT NOT NULL PRIMARY KEY,
    Photo VARBINARY(MAX) FILESTREAM NULL,
    MyRowGuidColumn UNIQUEIDENTIFIER NOT NULL ROWGUIDCOL UNIQUE DEFAULT NEWID()
);

CREATE TABLE dbo.T11
(
    c1 INT,
    c2 NVARCHAR(200)
)
WITH (DATA_COMPRESSION = ROW);

CREATE TABLE dbo.T12
(
    c1 INT,
    c2 XML
)
WITH (XML_COMPRESSION = ON);

CREATE TABLE dbo.T13
(
    c1 INT PRIMARY KEY,
    c2 VARCHAR(50) SPARSE NULL
);

CREATE TABLE T14
(
    c1 INT PRIMARY KEY,
    c2 VARCHAR(50) SPARSE NULL,
    c3 INT SPARSE NULL,
    CSet XML COLUMN_SET FOR ALL_SPARSE_COLUMNS
);

CREATE TABLE Department
(
    DepartmentNumber CHAR(10) NOT NULL PRIMARY KEY CLUSTERED,
    DepartmentName VARCHAR(50) NOT NULL,
    ManagerID INT NULL,
    ParentDepartmentNumber CHAR(10) NULL,
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON);

-- Existing table
CREATE TABLE Department_History
(
    DepartmentNumber CHAR(10) NOT NULL,
    DepartmentName VARCHAR(50) NOT NULL,
    ManagerID INT NULL,
    ParentDepartmentNumber CHAR(10) NULL,
    ValidFrom DATETIME2 NOT NULL,
    ValidTo DATETIME2 NOT NULL
);

-- Temporal table
CREATE TABLE Department1
(
    DepartmentNumber CHAR(10) NOT NULL PRIMARY KEY CLUSTERED,
    DepartmentName VARCHAR(50) NOT NULL,
    ManagerID INT NULL,
    ParentDepartmentNumber CHAR(10) NULL,
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Department_History, DATA_CONSISTENCY_CHECK = ON));

create table DepartmentHistory;

CREATE TABLE dbo.Department2
(
    DepartmentNumber CHAR(10) NOT NULL PRIMARY KEY NONCLUSTERED,
    DepartmentName VARCHAR(50) NOT NULL,
    ManagerID INT NULL,
    ParentDepartmentNumber CHAR(10) NULL,
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH
(
    MEMORY_OPTIMIZED = ON,
    DURABILITY = SCHEMA_AND_DATA,
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = History.DepartmentHistory)
);

CREATE TABLE Customers (
    CustName NVARCHAR(60)
        ENCRYPTED WITH (
            COLUMN_ENCRYPTION_KEY = MyCEK,
            ENCRYPTION_TYPE = RANDOMIZED,
            ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'
        ),
    SSN VARCHAR(11) COLLATE Latin1_General_BIN2
        ENCRYPTED WITH (
            COLUMN_ENCRYPTION_KEY = MyCEK,
            ENCRYPTION_TYPE = DETERMINISTIC ,
            ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'
        ),
    Age INT NULL,
	customer_id INT
);

CREATE TABLE t1
(
    c1 INT,
    index IX1 (c1) WHERE (c1 > 0)
);

CREATE TABLE t1
(
    c1 INT,
    INDEX ix_1 NONCLUSTERED (c1)
);

CREATE TABLE t2
(
    c1 INT,
    c2 INT INDEX ix_1 NONCLUSTERED
);

CREATE TABLE t3
(
    c1 INT,
    c2 INT,
    INDEX ix_1 NONCLUSTERED (c1,c2)
);

CREATE TABLE #tmp
(
    c1 INT,
    c2 INT,
    PRIMARY KEY CLUSTERED ([c1], [c2])
);
GO

CREATE TABLE ##test (
    a INT,
    b INT
);


CREATE TABLE [dbo].[data_retention_table]
(
  [dbdatetime2] datetime2(7),
  [product_code] int,
  [value] char(10)
)
WITH (DATA_DELETION = ON ( FILTER_COLUMN = [dbdatetime2], RETENTION_PERIOD = 1 WEEKS ))


CREATE TABLE [HR].[Employees]
(
    EmployeeID INT NOT NULL,
    Salary Money NOT NULL
)
WITH (SYSTEM_VERSIONING = ON, LEDGER = ON);
GO

CREATE TABLE [HR].[Employees]
(
    EmployeeID INT NOT NULL PRIMARY KEY,
    Salary Money NOT NULL,
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON, LEDGER = ON);
GO

create table EmployeesHistory;

CREATE TABLE [HR].[Employees]
(
    EmployeeID INT NOT NULL PRIMARY KEY,
    Salary Money NOT NULL,
    StartTransactionId BIGINT GENERATED ALWAYS AS TRANSACTION_ID START HIDDEN NOT NULL,
    EndTransactionId BIGINT GENERATED ALWAYS AS TRANSACTION_ID END HIDDEN NULL,
    StartSequenceNumber BIGINT GENERATED ALWAYS AS SEQUENCE_NUMBER START HIDDEN NOT NULL,
    EndSequenceNumber BIGINT GENERATED ALWAYS AS SEQUENCE_NUMBER END HIDDEN NULL,
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [HR].[EmployeesHistory]),
    LEDGER = ON (
        LEDGER_VIEW = [HR].[EmployeesLedger] (
            TRANSACTION_ID_COLUMN_NAME = TransactionId,
            SEQUENCE_NUMBER_COLUMN_NAME = SequenceNumber,
            OPERATION_TYPE_COLUMN_NAME = OperationId,
            OPERATION_TYPE_DESC_COLUMN_NAME = OperationTypeDescription
        )
    )
);
GO

CREATE TABLE [AccessControl].[KeyCardEvents]
(
    EmployeeID INT NOT NULL,
    AccessOperationDescription NVARCHAR (MAX) NOT NULL,
    [Timestamp] Datetime2 NOT NULL,
    StartTransactionId BIGINT GENERATED ALWAYS AS TRANSACTION_ID START HIDDEN NOT NULL,
    StartSequenceNumber BIGINT GENERATED ALWAYS AS SEQUENCE_NUMBER START HIDDEN NOT NULL
)
WITH (
    LEDGER = ON (
        LEDGER_VIEW = [AccessControl].[KeyCardEventsLedger] (
            TRANSACTION_ID_COLUMN_NAME = TransactionId,
            SEQUENCE_NUMBER_COLUMN_NAME = SequenceNumber,
            OPERATION_TYPE_COLUMN_NAME = OperationId,
            OPERATION_TYPE_DESC_COLUMN_NAME = OperationTypeDescription
        ),
        APPEND_ONLY = ON
    )
);
GO

CREATE TABLE [HR].[Employees]
(
    EmployeeID INT NOT NULL,
    Salary Money NOT NULL
)
GO

CREATE EXTERNAL TABLE ClickStream (
    url varchar(50),
    event_date date,
    user_IP varchar(50)
)
WITH (
        LOCATION='/webdata/employee.tbl',
        DATA_SOURCE = mydatasource,
        FILE_FORMAT = myfileformat
    )
;

 CREATE EXTERNAL TABLE customers2(
   [O_ORDERKEY] DECIMAL(38) NOT NULL,
   [O_CUSTKEY] DECIMAL(38) NOT NULL,
   [O_ORDERSTATUS] CHAR COLLATE Latin1_General_BIN NOT NULL,
   [O_TOTALPRICE] DECIMAL(15,2) NOT NULL,
   [O_ORDERDATE] DATETIME2(0) NOT NULL,
   [O_ORDERPRIORITY] CHAR(15) COLLATE Latin1_General_BIN NOT NULL,
   [O_CLERK] CHAR(15) COLLATE Latin1_General_BIN NOT NULL,
   [O_SHIPPRIORITY] DECIMAL(38) NOT NULL,
   [O_COMMENT] VARCHAR(79) COLLATE Latin1_General_BIN NOT NULL
   )
   WITH (
    LOCATION='DB1.mySchema.customer',
    DATA_SOURCE= external_data_source_name
   );
   
   CREATE EXTERNAL TABLE Region(
r_regionkey BIGINT,
r_name CHAR(25),
r_comment VARCHAR(152) )
WITH (LOCATION = '/region/', DATA_SOURCE = 's3_ds',
FILE_FORMAT = ParquetFileFormat);
GO

-- Example is based on AdventureWorks
CREATE EXTERNAL TABLE hdfsCustomer
    WITH (
            LOCATION = '/pdwdata/customer.tbl',
            DATA_SOURCE = customer_ds,
            FILE_FORMAT = customer_ff
            ) AS

SELECT *
FROM dimCustomer;
GO

-- Example is based on AdventureWorks
CREATE EXTERNAL TABLE dbo.FactInternetSalesNew
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

-- Example is based on AdventureWorks
CREATE EXTERNAL TABLE dbo.FactInternetSalesNew
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
FROM AdventureWorks2022.[Sales].[SalesOrderDetail];
GO

CREATE EXTERNAL TABLE Delta_to_Parquet
    WITH (
            LOCATION = '/backup/sales.parquet',
            DATA_SOURCE = s3_parquet,
            FILE_FORMAT = ParquetFileFormat
            ) AS

SELECT *
FROM OPENROWSET(BULK '/delta/sales_fy22/', FORMAT = 'DELTA', DATA_SOURCE = 's3_delta') AS [r];
GO

CREATE EXTERNAL TABLE [dbo].[<myexternaltable>] WITH (
        LOCATION = '<myoutputsubfolder>/',
        DATA_SOURCE = [SynapseSQLwriteable],
        FILE_FORMAT = [ParquetFF]
) AS
SELECT * FROM [<myview>];
GO

CREATE EXTERNAL TABLE [dbo].[<myexternaltable2>] WITH (
        LOCATION = '<myoutputsubfolder>/',
        DATA_SOURCE = [SynapseSQLwriteable],
        FILE_FORMAT = [ParquetFF]
) AS
SELECT * FROM [<myview>];
GO

CREATE TABLE friends (
    id INTEGER PRIMARY KEY,
    start_date DATe
 ) AS EDGE;
 
 -- Create a likes edge table, this table does not have any user defined attributes   
 CREATE TABLE likes AS EDGE;
 
 /* Create friend edge table with CONSTRAINT, restricts for nodes and it direction */
CREATE TABLE dbo.FriendOf(
  CONSTRAINT cnt_Person_FriendOf_Person
    CONNECTION (dbo.Person TO dbo.Person) 
)AS EDGE;

CREATE TABLE new_employees (
    id_num INT IDENTITY(1, 1),
    fname VARCHAR(20),
    minit CHAR(1),
    lname VARCHAR(30)
);


CREATE TABLE img (
    id_num INT IDENTITY(1, 1),
    company_name SYSNAME
);

CREATE VIEW Sales.SalesPersonPerform  
AS  
SELECT TOP (100) SalesPersonID, SUM(TotalDue) AS TotalSales  
FROM Sales.SalesOrderHeader  
WHERE OrderDate > CONVERT(DATETIME,'20001231',101)  
GROUP BY SalesPersonID;  
GO

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
GO

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


CREATE FUNCTION dbo.ufn_FindReports (@InEmpID INTEGER)
RETURNS @retFindReports TABLE
(
    EmployeeID int primary key NOT NULL,
    FirstName nvarchar(255) NOT NULL,
    LastName nvarchar(255) NOT NULL,
    JobTitle nvarchar(50) NOT NULL,
    RecursionLevel int NOT NULL
)
AS
BEGIN
WITH EMP_cte(EmployeeID, OrganizationNode, FirstName, LastName, JobTitle, RecursionLevel) -- CTE name and columns
    AS (
        -- Get the initial list of Employees for Manager n
        SELECT e.BusinessEntityID, OrganizationNode = ISNULL(e.OrganizationNode, CAST('/' AS hierarchyid)) 
        , p.FirstName, p.LastName, e.JobTitle, 0
        FROM HumanResources.Employee e
              INNER JOIN Person.Person p
              ON p.BusinessEntityID = e.BusinessEntityID
        WHERE e.BusinessEntityID = @InEmpID
        UNION ALL
        -- Join recursive member to anchor
        SELECT e.BusinessEntityID, e.OrganizationNode, p.FirstName, p.LastName, e.JobTitle, RecursionLevel + 1
        FROM HumanResources.Employee e
          INNER JOIN EMP_cte
          ON e.OrganizationNode.GetAncestor(1) = EMP_cte.OrganizationNode
          INNER JOIN Person.Person p
          ON p.BusinessEntityID = e.BusinessEntityID
        )
-- copy the required columns to the result of the function
    INSERT @retFindReports
    SELECT EmployeeID, FirstName, LastName, JobTitle, RecursionLevel
    FROM EMP_cte
    RETURN
END;
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

CREATE SEQUENCE Test.CountBy1  
    START WITH 1  
    INCREMENT BY 1 ;  
GO

CREATE SEQUENCE Test.CountByNeg1  
    START WITH 0  
    INCREMENT BY -1 ;  
GO

CREATE SEQUENCE Test.CountBy2  
    START WITH 5  
    INCREMENT BY 5 ;  
GO

CREATE SEQUENCE Test.ID_Seq  
    START WITH 24329  
    INCREMENT BY 1 ;  
GO

CREATE SEQUENCE Test.TestSequence ;

CREATE SEQUENCE SmallSeq 
    AS smallint ;
	
	CREATE SEQUENCE Test.DecSeq  
    AS decimal(3,0)   
    START WITH 125  
    INCREMENT BY 25  
    MINVALUE 100  
    MAXVALUE 200  
    CYCLE  
    CACHE 3  
;

create table UnitMeasure
(
	Name VARCHAR(50)
)

CREATE UNIQUE INDEX AK_UnitMeasure_Name
  ON Production.UnitMeasure(Name);

CREATE TABLE #Test1 (C1 NVARCHAR(10), C2 NVARCHAR(50), C3 DATETIME);
GO

CREATE UNIQUE INDEX AK_Index ON #Test1 (C2)
  WITH (IGNORE_DUP_KEY = ON);
GO

CREATE TABLE #Test2 (C1 NVARCHAR(10), C2 NVARCHAR(50), C3 DATETIME);
GO

CREATE UNIQUE INDEX AK_Index ON #Test2 (C2)
  WITH (IGNORE_DUP_KEY = OFF);
GO

create table WorkOrder
(
	ProductID int
);

CREATE NONCLUSTERED INDEX IX_WorkOrder_ProductID
  ON Production.WorkOrder(ProductID)
    WITH (FILLFACTOR = 80,
      PAD_INDEX = ON,
      DROP_EXISTING = ON);
GO

CREATE VIEW Sales.vOrders
  WITH SCHEMABINDING
AS
  SELECT SUM(UnitPrice * OrderQty * (1.00 - UnitPriceDiscount)) AS Revenue,
    OrderDate, ProductID, COUNT_BIG(*) AS COUNT
  FROM Sales.SalesOrderDetail AS od, Sales.SalesOrderHeader AS o
  WHERE od.SalesOrderID = o.SalesOrderID
  GROUP BY OrderDate, ProductID;
GO

-- Create an index on the view
CREATE UNIQUE CLUSTERED INDEX IDX_V1
  ON Sales.vOrders (OrderDate, ProductID);
GO


create table Address
(
	PostalCode varchar(50)
);

CREATE NONCLUSTERED INDEX IX_Address_PostalCode
  ON Person.Address (PostalCode)
  INCLUDE (AddressLine1, AddressLine2, City, StateProvinceID);
GO


create table TransactionHistory1
(
	ReferenceOrderID int
	
);

create table TransactionsPS1
(
	TransactionDate int
);

CREATE NONCLUSTERED INDEX IX_TransactionHistory_ReferenceOrderID
  ON Production.TransactionHistory1 (ReferenceOrderID)
  ON TransactionsPS1 (TransactionDate);
GO

create table BillOfMaterials
(
	ComponentID int ,
	StartDate int
	
);


CREATE NONCLUSTERED INDEX "FIBillOfMaterialsWithEndDate"
  ON Production.BillOfMaterials (ComponentID, StartDate)
  WHERE EndDate IS NOT NULL;
  
  
create table T111
(
	C2 int
);
  
 CREATE NONCLUSTERED INDEX IX_INDEX_1
  ON T111 (C2)
  WITH (DATA_COMPRESSION = ROW);
GO

create table PartitionTable1
(
	Col1 varchar(50)
);


CREATE CLUSTERED INDEX IX_PartTab2Col1
  ON PartitionTable1 (Col1)
  WITH (DATA_COMPRESSION = ROW);
GO

create table PartitionTable11
(
Col1 int
);

CREATE CLUSTERED INDEX IX_PartTab2Col1
  ON PartitionTable11 (Col1)
  WITH (
    DATA_COMPRESSION = PAGE ON PARTITIONS(1),
    DATA_COMPRESSION = ROW ON PARTITIONS (2 TO 4)
  );
GO

create table T1111
(
	C2 int
);

CREATE NONCLUSTERED INDEX IX_INDEX_1
  ON T1111 (C2)
  WITH (XML_COMPRESSION = ON);
GO


create table PartitionTable12
(
	Col1 int
);

CREATE CLUSTERED INDEX IX_PartTab2Col1
  ON PartitionTable12 (Col1)
  WITH (XML_COMPRESSION = ON);
GO


create table test_table1
(
	col1 int
);

CREATE INDEX test_idx1 ON test_table1 (col1) WITH (ONLINE = ON, MAXDOP = 1, RESUMABLE = ON);

-- Executing the same command again (see above) after an index operation was paused, resumes automatically the index create operation.

create table test_table2 
(
	col2 int
);

-- Execute a resumable online index creates operation with MAX_DURATION set to 240 minutes. After the time expires, the resumable index create operation is paused.
CREATE INDEX test_idx2 ON test_table2 (col2) WITH (ONLINE = ON, RESUMABLE = ON, MAX_DURATION = 240);


create table T21
(
	a int
);


--Kill this session after waiting 5 minutes
CREATE CLUSTERED INDEX idx_1 ON dbo.T21 (a) WITH (ONLINE = ON (WAIT_AT_LOW_PRIORITY (MAX_DURATION = 5 MINUTES, ABORT_AFTER_WAIT = SELF)));
GO

create table T22
(
	a int
);

--Kill blocker sessions
CREATE CLUSTERED INDEX idx_1 ON dbo.T22 (a) WITH (ONLINE = ON (WAIT_AT_LOW_PRIORITY (MAX_DURATION = 5 MINUTES, ABORT_AFTER_WAIT = BLOCKERS)));
GO


create table T23
(
	a int
);

--With resumable option; default locking behavior 
CREATE CLUSTERED INDEX idx_1 ON dbo.T23 (a) WITH (ONLINE = ON (WAIT_AT_LOW_PRIORITY (MAX_DURATION = 5 MINUTES, ABORT_AFTER_WAIT = NONE)), RESUMABLE = ON, MAX_DURATION = 240 MINUTES);


CREATE TABLE dbo.SimpleTable(
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

CREATE CLUSTERED INDEX cl_simple ON dbo.SimpleTable3 (ProductKey);
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX csindx_simple
ON dbo.SimpleTable3 (OrderDateKey, DueDateKey, ShipDateKey);
Go


Create table Production.ProductReview
(
	ReviewerName varchar(50),
	EmailAddress varchar(50)

);

CREATE FULLTEXT INDEX ON Production.ProductReview (
    ReviewerName LANGUAGE 1033,
    EmailAddress LANGUAGE 1033,
    Comments LANGUAGE 1033
) KEY INDEX PK_ProductReview_ProductReviewID ON production_catalog;
GO

Create table Production.Document
(
	Title VARCHAR(50),
	DocumentSummary VARCHAR(50),
	Document VARCHAR(50)

);


CREATE FULLTEXT INDEX ON Production.Document (
    Title LANGUAGE 1033,
    DocumentSummary LANGUAGE 1033,
    Document TYPE COLUMN FileExtension LANGUAGE 1033
) KEY INDEX PK_Document_DocumentID
WITH STOPLIST = SYSTEM,
    SEARCH PROPERTY LIST = DocumentPropertyList,
    CHANGE_TRACKING OFF,
    NO POPULATION;
GO

CREATE TABLE SpatialTable1(id int primary key, geometry_col geometry);
  
CREATE SPATIAL INDEX SIndx_SpatialTable_geometry_col1
   ON SpatialTable1(geometry_col)  
   WITH ( BOUNDING_BOX = ( 0, 0, 500, 200 ) );
   

CREATE TABLE SpatialTable2(id int primary key, geometry_col geometry);

   
 CREATE SPATIAL INDEX SIndx_SpatialTable_geometry_col2  
   ON SpatialTable2(geometry_col)  
   USING GEOMETRY_GRID  
   WITH (  
    BOUNDING_BOX = ( xmin=0, ymin=0, xmax=500, ymax=200 ),  
    GRIDS = (LOW, LOW, MEDIUM, HIGH),  
    CELLS_PER_OBJECT = 64,  
    PAD_INDEX  = ON );
	
CREATE TABLE SpatialTable3(id int primary key, geometry_col geometry);
	
CREATE SPATIAL INDEX SIndx_SpatialTable_geometry_col3  
   ON SpatialTable3(geometry_col)  
   WITH (  
    BOUNDING_BOX = ( 0, 0, 500, 200 ),  
    GRIDS = ( LEVEL_4 = HIGH, LEVEL_3 = MEDIUM ) );
	
CREATE TABLE SpatialTable4(id int primary key, geometry_col geometry);
	
CREATE SPATIAL INDEX SIndx_SpatialTable_geography_col3  
   ON SpatialTable4(geography_col)  
   WITH ( BOUNDING_BOX = ( 0, 0, 500, 200 ),  
        GRIDS = ( LEVEL_3 = LOW ),  
        DROP_EXISTING = ON );	
		
		
CREATE TABLE SpatialTable5(id int primary key, object GEOGRAPHY);  

CREATE SPATIAL INDEX SIndx_SpatialTable_geography_col1
   ON SpatialTable5(object);
 
CREATE TABLE SpatialTable6(id int primary key, object GEOGRAPHY);  
 
 CREATE SPATIAL INDEX SIndx_SpatialTable_geography_col2  
   ON SpatialTable6(object)  
   USING GEOGRAPHY_GRID  
   WITH (  
    GRIDS = (MEDIUM, LOW, MEDIUM, HIGH ),  
    CELLS_PER_OBJECT = 64,  
    PAD_INDEX  = ON );  
	

 
CREATE TABLE SpatialTable7(id int primary key, object GEOGRAPHY);  

	
CREATE SPATIAL INDEX SIndx_SpatialTable_geography_col3  
   ON SpatialTable7(object)  
   WITH ( GRIDS = ( LEVEL_3 = HIGH, LEVEL_2 = HIGH ) );
   
 
create table  Production.ProductModel1
(
	CatalogDescription VARCHAR(50)
);
 
CREATE PRIMARY XML INDEX PXML_ProductModel_CatalogDescription
    ON Production.ProductModel1 (CatalogDescription);  
GO

create table  Production.ProductModel2
(
	CatalogDescription VARCHAR(50)
);

CREATE PRIMARY XML INDEX PXML_ProductModel_CatalogDescription
    ON Production.ProductModel2 (CatalogDescription)
    WITH (XML_COMPRESSION = ON);  
GO


create table  Production.ProductModel3
(
	CatalogDescription VARCHAR(50)
);

CREATE XML INDEX IXML_ProductModel_CatalogDescription_Path
    ON Production.ProductModel3 (CatalogDescription)
    USING XML INDEX PXML_ProductModel_CatalogDescription FOR PATH ;
GO

create table  Production.ProductModel4
(
	CatalogDescription VARCHAR(50)
);

CREATE XML INDEX IXML_ProductModel_CatalogDescription_Path
    ON Production.ProductModel4 (CatalogDescription)
    USING XML INDEX PXML_ProductModel_CatalogDescription FOR PATH
    WITH (XML_COMPRESSION = ON);
GO

create table Tbl
(
	xmlcol VARCHAR(50)
);

CREATE XML INDEX filt_sxi_index_c  
ON Tbl(xmlcol)  
USING XML INDEX sxi_index  
FOR ( pathabc );

CREATE TABLE Tb2 ( id INT PRIMARY KEY, xmlcol XML );  
GO  
CREATE SELECTIVE XML INDEX sxi_index  
ON Tb2(xmlcol)  
FOR(  
    pathab   = '/a/b' as XQUERY 'node()',  
    pathabc  = '/a/b/c' as XQUERY 'xs:double',   
    pathdtext = '/a/b/d/text()' as XQUERY 'xs:string' MAXLENGTH(200) SINGLETON,  
    pathabe = '/a/b/e' as SQL NVARCHAR(100)  
);

create table Tbl_sxml
(
	C1 VARCHAR(50)
);

CREATE SELECTIVE XML INDEX index_sxml on Tbl_sxml(C1)  
WITH XMLNAMESPACES ('https://www.tempuri.org/' as myns)  
FOR ( path1 = '/myns:book/myns:author/text()' ); 



create table Sales.Customer3  ;

CREATE TRIGGER reminder1  
ON Sales.Customer3  
Instead Of INSERT, UPDATE   
AS RAISERROR ('Notify Customer Relations', 16, 10);  
GO


CREATE TRIGGER reminder2  
ON Sales.Customer3  
AFTER INSERT, UPDATE, DELETE   
AS  
   EXEC msdb.dbo.sp_send_dbmail  
        @profile_name = 'AdventureWorks2022 Administrator',  
        @recipients = 'danw@Adventure-Works.com',  
        @body = 'Don''t forget to print a report for the sales force.',  
        @subject = 'Reminder';  
GO

/*
create table Purchasing.PurchaseOrderHeader1 ;

CREATE TRIGGER Purchasing.LowCredit ON Purchasing.PurchaseOrderHeader  
AFTER INSERT  
AS  
IF (ROWCOUNT_BIG() = 0)
RETURN;
IF EXISTS (SELECT 1  
           FROM inserted AS i   
           JOIN Purchasing.Vendor AS v   
           ON v.BusinessEntityID = i.VendorID  
           WHERE v.CreditRating = 5  
          )  
BEGIN  
RAISERROR ('A vendor''s credit rating is too low to accept new  
purchase orders.', 16, 1);  
ROLLBACK TRANSACTION;  
RETURN   
END;  
GO 


CREATE TRIGGER safety   
ON DATABASE   
FOR DROP_SYNONYM  
AS   
IF (@@ROWCOUNT = 0)
RETURN;
   RAISERROR ('You must disable Trigger "safety" to remove synonyms!', 10, 1)  
   ROLLBACK  
GO  
DROP TRIGGER safety  
ON DATABASE;  
GO


CREATE TRIGGER ddl_trig_database   
ON ALL SERVER   
FOR CREATE_DATABASE   
AS   
    PRINT 'Database Created.'  
    SELECT EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','nvarchar(max)')  
GO  
DROP TRIGGER ddl_trig_database  
ON ALL SERVER;  
GO 

CREATE TRIGGER connection_limit_trigger  
ON ALL SERVER WITH EXECUTE AS 'login_test'  
FOR LOGON  
AS  
BEGIN  
IF ORIGINAL_LOGIN()= 'login_test' AND  
    (SELECT COUNT(*) FROM sys.dm_exec_sessions  
            WHERE is_user_process = 1 AND  
                original_login_name = 'login_test') > 3  
    ROLLBACK;  
END; 
*/

CREATE TABLE dbo.Orderstable (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    CONSTRAINT UC_OrderNumber UNIQUE (OrderID)
);

CREATE TABLE dbo.Employeetable (
    EmployeeID INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100) UNIQUE,
    HireDate DATE,
    CONSTRAINT CHK_HireDate CHECK (HireDate <= GETDATE())
);

CREATE TABLE dbo.Customerstable (
    CustomerID INT,
    CustomerName NVARCHAR(100),
    CONSTRAINT PK_Customers PRIMARY KEY (CustomerID)
);

CREATE TABLE dbo.Orderstable1 (
    OrderID INT,
    CustomerID INT,
    OrderDate DATE,
    CONSTRAINT PK_Orders PRIMARY KEY (OrderID),
    CONSTRAINT FK_CustomerOrder FOREIGN KEY (CustomerID) REFERENCES dbo.Customerstable(CustomerID) ON UPDATE CASCADE ON DELETE CASCADE
);

create table Purchasing.PurchaseOrderHeader (PurchaseOrderID int PRIMARY KEY );

create table Production.Product(ProductID int PRIMARY KEY );

CREATE AGGREGATE Concatenate(@input nvarchar(4000))  
RETURNS nvarchar(4000)  
EXTERNAL NAME [StringUtilities].[Microsoft.Samples.SqlServer.Concatenate];  

CREATE APPLICATION ROLE weekly_receipts   
    WITH PASSWORD = '987G^bv876sPY)Y5m23'   
    , DEFAULT_SCHEMA = Sales; 
	
 

CREATE ASSEMBLY HelloWorld   
FROM '<system_drive>:\Program Files\Microsoft SQL Server\100\Samples\HelloWorld\CS\HelloWorld\bin\debug\HelloWorld.dll'  
WITH PERMISSION_SET = SAFE; 

CREATE ASYMMETRIC KEY PacificSales09   
    WITH ALGORITHM = RSA_2048   
    ENCRYPTION BY PASSWORD = '<enterStrongPasswordHere>'; 

CREATE AVAILABILITY GROUP MyAg   
   WITH (  
      AUTOMATED_BACKUP_PREFERENCE = SECONDARY,  
      FAILURE_CONDITION_LEVEL  =  3,   
      HEALTH_CHECK_TIMEOUT = 600000  
       )  
  
   FOR   
      DATABASE  ThisDatabase, ThatDatabase   
   REPLICA ON   
      'COMPUTER01' WITH   
         (  
         ENDPOINT_URL = 'TCP://COMPUTER01:5022',  
         AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,  
         FAILOVER_MODE = AUTOMATIC,  
         BACKUP_PRIORITY = 30,  
         SECONDARY_ROLE (ALLOW_CONNECTIONS = NO,   
            READ_ONLY_ROUTING_URL = 'TCP://COMPUTER01:1433' ),
         PRIMARY_ROLE (ALLOW_CONNECTIONS = READ_WRITE,   
            READ_ONLY_ROUTING_LIST = ( COMPUTER03)  ) ,  
         SESSION_TIMEOUT = 10  
         ),   
  
      'COMPUTER02' WITH   
         (  
         ENDPOINT_URL = 'TCP://COMPUTER02:5022',  
         AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,  
         FAILOVER_MODE = AUTOMATIC,  
         BACKUP_PRIORITY = 30,  
         SECONDARY_ROLE (ALLOW_CONNECTIONS = NO,   
            READ_ONLY_ROUTING_URL = 'TCP://COMPUTER02:1433' ),  
         PRIMARY_ROLE (ALLOW_CONNECTIONS = READ_WRITE,   
            READ_ONLY_ROUTING_LIST = (COMPUTER03) ),  
         SESSION_TIMEOUT = 10  
         ),   
  
      'COMPUTER03' WITH   
         (  
         ENDPOINT_URL = 'TCP://COMPUTER03:5022',  
         AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,  
         FAILOVER_MODE =  MANUAL,  
         BACKUP_PRIORITY = 90,  
         SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY,   
            READ_ONLY_ROUTING_URL = 'TCP://COMPUTER03:1433' ),  
         PRIMARY_ROLE (ALLOW_CONNECTIONS = READ_WRITE,   
            READ_ONLY_ROUTING_LIST = NONE ),  
         SESSION_TIMEOUT = 10  
         );


CREATE BROKER PRIORITY TargetToInitiatorAPriority  
    FOR CONVERSATION  
    SET (CONTRACT_NAME = SimpleContract,  
         LOCAL_SERVICE_NAME = TargetService,  
         REMOTE_SERVICE_NAME = 'InitiatorServiceA',  
         PRIORITY_LEVEL = 3);  
		 
CREATE CERTIFICATE Shipping04   
   ENCRYPTION BY PASSWORD = 'pGFD4bb925DGvbd2439587y'  
   WITH SUBJECT = 'Sammamish Shipping Records',   
   EXPIRY_DATE = '20201031';
   
CREATE COLUMN ENCRYPTION KEY TwoValueCEK   
WITH VALUES  
(  
    COLUMN_MASTER_KEY = CMK1,   
    ALGORITHM = 'RSA_OAEP',   
    ENCRYPTED_VALUE = 0x016E000001630075007200720065006E00740075007300650072002F006D0079002F0037006300380061003100310033003400320037003800620037003000630038003100390062003900630039003400360061006600340039006500610030003200650038006200650038003400340065006C33A82ECF04A7185824B4545457AC5244CD9C219E64067B9520C0081B8399B58C2863F7494ABE3694BD87D55FFD7576FFDC47C28F94ECC99577DF4FB8FA19AA95764FEF889CDE0F176DA5897B74382FBB22756CE2921050A09201A0EB6AF3D6091014C30146EA62635EE8CBF0A8074DEDFF125CEA80D1C0F5E8C58750A07D270E2A8BF824EE4C0C156366BF26D38CCE49EBDD5639A2DF029A7DBAE5A5D111F2F2FA3246DF8C2FA83C1E542C10570FADA98F6B29478DC58CE5CBDD407CCEFCDB97814525F6F32BECA266014AC346AC39C4F185C6C0F0A24FEC4DFA015649624692DE7865B9827BA22C3B574C9FD169F822B609F902288C5880EB25F14BD990D871B1BC4BA3A5B237AF76D26354773FA2A25CF4511AF58C911E601CFCB1905128C997844EED056C2AE7F0B48700AB41307E470FF9520997D0EB0D887DE11AFE574FFE845B7DC6C03FEEE8D467236368FC0CB2FDBD54DADC65B10B3DE6C80DF8B7B3F8F3CE5BE914713EE7B1FA5B7A578359592B8A5FDFDDE5FF9F392BC87C3CD02FBA94582AC063BBB9FFAC803FD489E16BEB28C4E3374A8478C737236A0B232F5A9DDE4D119573F1AEAE94B2192B81575AD6F57E670C1B2AB91045124DFDAEC2898F3F0112026DFC93BF9391D667D1AD7ED7D4E6BB119BBCEF1D1ADA589DD3E1082C3DAD13223BE438EB9574DA04E9D8A06320CAC6D3EC21D5D1C2A0AA484C7C  
),  
(  
    COLUMN_MASTER_KEY = CMK2,   
    ALGORITHM = 'RSA_OAEP',   
    ENCRYPTED_VALUE = 0x016E000001630075007200720065006E00740075007300650072002F006D0079002F0064006500650063006200660034006100340031003000380034006200350033003200360066003200630062006200350030003600380065003900620061003000320030003600610037003800310066001DDA6134C3B73A90D349C8905782DD819B428162CF5B051639BA46EC69A7C8C8F81591A92C395711493B25DCBCCC57836E5B9F17A0713E840721D098F3F8E023ABCDFE2F6D8CC4339FC8F88630ED9EBADA5CA8EEAFA84164C1095B12AE161EABC1DF778C07F07D413AF1ED900F578FC00894BEE705EAC60F4A5090BBE09885D2EFE1C915F7B4C581D9CE3FDAB78ACF4829F85752E9FC985DEB8773889EE4A1945BD554724803A6F5DC0A2CD5EFE001ABED8D61E8449E4FAA9E4DD392DA8D292ECC6EB149E843E395CDE0F98D04940A28C4B05F747149B34A0BAEC04FFF3E304C84AF1FF81225E615B5F94E334378A0A888EF88F4E79F66CB377E3C21964AACB5049C08435FE84EEEF39D20A665C17E04898914A85B3DE23D56575EBC682D154F4F15C37723E04974DB370180A9A579BC84F6BC9B5E7C223E5CBEE721E57EE07EFDCC0A3257BBEBF9ADFFB00DBF7EF682EC1C4C47451438F90B4CF8DA709940F72CFDC91C6EB4E37B4ED7E2385B1FF71B28A1D2669FBEB18EA89F9D391D2FDDEA0ED362E6A591AC64EF4AE31CA8766C259ECB77D01A7F5C36B8418F91C1BEADDD4491C80F0016B66421B4B788C55127135DA2FA625FB7FD195FB40D90A6C67328602ECAF3EC4F5894BFD84A99EB4753BE0D22E0D4DE6A0ADFEDC80EB1B556749B4A8AD00E73B329C95827AB91C0256347E85E3C5FD6726D0E1FE82C925D3DF4A9  
); 

CREATE COLUMN MASTER KEY MyCMK
WITH (
	KEY_STORE_PROVIDER_NAME = 'AZURE_KEY_VAULT',
	KEY_PATH ='https://myvault.vault.azure.net:443/keys/MyCMK/4c05f1a41b12488f9cba2ea964b6a700',
	ENCLAVE_COMPUTATIONS(SIGNATURE = 0xA80F5B123F5E092FFBD6014FC2226D792746468C901D9404938E9F5A0972F38DADBC9FCBA94D9E740F3339754991B6CE26543DEB0D094D8A2FFE8B43F0C7061A1FFF65E30FDDF39A1B954F5BA206AAC3260B0657232020582413990261D878318CC38EF4E853970ED69A8D4A306693B8659AAC1C4E4109DE5EB148FD0E1FDBBC32F002C1D8199D313227AD689279D8DEEF91064DF122C19C3767C463723AB663A6F8412AE17E745922C0E3A257EAEF215532588ACCBD440A03C7BC100A38BD0609A119E1EF7C5C6F1B086C68AB8873DBC6487B270340E868F9203661AFF0492CEC436ABF7C4713CE64E38CF66C794B55636BFA55E5B6554AF570CF73F1BE1DBD)
);

CREATE CONTRACT            
              
    ( [//Adventure-Works.com/Expenses/SubmitExpense]           
          SENT BY INITIATOR,           
      [//Adventure-Works.com/Expenses/ExpenseApprovedOrDenied]           
          SENT BY TARGET,           
      [//Adventure-Works.com/Expenses/ExpenseReimbursed]           
          SENT BY TARGET           
    ) ; 
	
CREATE CREDENTIAL CredentialForEKM
    WITH IDENTITY='User1OnEKM', SECRET='<EnterStrongPasswordHere>'
    FOR CRYPTOGRAPHIC PROVIDER MyEKMProvider;
	
	-- Install the provider  
CREATE CRYPTOGRAPHIC PROVIDER SecurityProvider  
    FROM FILE = 'C:\SecurityProvider\SecurityProvider_v1.dll';
	
CREATE DATABASE Sales
ON
( NAME = Sales_dat,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\saledat.mdf',
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5 )
LOG ON
( NAME = Sales_log,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\salelog.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB ) ;
	
CREATE DATABASE AdventureWorks2022 ON
    (FILENAME = 'c:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data\AdventureWorks2022_data.mdf'),
    (FILENAME = 'c:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data\AdventureWorks2022_log.ldf'),
    (FILENAME = 'c:\myFTCatalogs\AdvWksFtCat')
FOR ATTACH;


CREATE DATABASE sales_snapshot0600 ON
    ( NAME = SPri1_dat, FILENAME = 'D:\SalesData\SPri1dat_0600.ss'),
    ( NAME = SPri2_dat, FILENAME = 'D:\SalesData\SPri2dt_0600.ss'),
    ( NAME = SGrp1Fi1_dat, FILENAME = 'D:\SalesData\SG1Fi1dt_0600.ss'),
    ( NAME = SGrp1Fi2_dat, FILENAME = 'D:\SalesData\SG1Fi2dt_0600.ss'),
    ( NAME = SGrp2Fi1_dat, FILENAME = 'D:\SalesData\SG2Fi1dt_0600.ss'),
    ( NAME = SGrp2Fi2_dat, FILENAME = 'D:\SalesData\SG2Fi2dt_0600.ss')
AS SNAPSHOT OF Sales ;

CREATE DATABASE AUDIT SPECIFICATION Audit_Data_Modification_On_All_Sales_Tables  
FOR SERVER AUDIT DataModification_Security_Audit  
ADD ( INSERT, UPDATE, DELETE  
     ON Schema::Sales BY SalesUK )  
WITH (STATE = ON) ; 


  
CREATE DATABASE ENCRYPTION KEY  
WITH ALGORITHM = AES_256  
ENCRYPTION BY SERVER CERTIFICATE MyServerCert;  

CREATE DATABASE SCOPED CREDENTIAL AppCred WITH IDENTITY = 'Mary5',
    SECRET = '<EnterStrongPasswordHere>';
	
CREATE DEFAULT phonedflt AS 'unknown';

CREATE ENDPOINT ipv4_endpoint_special
STATE = STARTED
AS TCP (
    LISTENER_PORT = 55555, LISTENER_IP = (10.0.75.1)
)
FOR TSQL ();

CREATE EVENT NOTIFICATION Notify_ALTER_T1  
ON DATABASE  
FOR ALTER_TABLE  
TO SERVICE 'NotifyService',  
    '8140a771-3c4b-4479-8ac0-81008ab17984'; 


CREATE EVENT SESSION test_session
ON SERVER
    ADD EVENT sqlos.async_io_requested,
    ADD EVENT sqlserver.lock_acquired
    ADD TARGET package0.etw_classic_sync_target
        (SET default_etw_session_logfile_path = N'C:\demo\traces\sqletw.etl' )
    WITH (MAX_MEMORY=4MB, MAX_EVENT_SIZE=4MB);	
 
 CREATE EXTERNAL DATA SOURCE [OracleSalesSrvr]
WITH (
    LOCATION = 'oracle://145.145.145.145:1521',
    CONNECTION_OPTIONS = 'ImpersonateUser=%CURRENT_USER',
    CREDENTIAL = [OracleProxyCredential]
);

CREATE EXTERNAL LANGUAGE Java
FROM
(CONTENT = N'<path-to-zip>', FILE_NAME = 'javaextension.dll', PLATFORM = WINDOWS),
(CONTENT = N'<path-to-tar.gz>', FILE_NAME = 'javaextension.so', PLATFORM = LINUX);


CREATE EXTERNAL LIBRARY customPackage
FROM (CONTENT = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\customPackage.zip') WITH (LANGUAGE = 'R');


CREATE EXTERNAL FILE FORMAT textdelimited1
WITH (
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS (
        FIELD_TERMINATOR = '|',
        DATE_FORMAT = 'MM/dd/yyyy' ),
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.GzipCodec'
);

CREATE EXTERNAL RESOURCE POOL ep_1
WITH (  
    MAX_CPU_PERCENT = 75
    , MAX_MEMORY_PERCENT = 30
);

CREATE FULLTEXT CATALOG ftCatalog AS DEFAULT; 

CREATE FULLTEXT STOPLIST myStoplist2 FROM AdventureWorks.otherStoplist; 

CREATE LOGIN TestLogin WITH PASSWORD = 'SuperSecret52&&';

CREATE LOGIN TestLogin
WITH PASSWORD = 'SuperSecret52&&', SID = d0x241C11948AEEB749B0D22646DB1A19F2;

CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<strong password>';

CREATE MESSAGE TYPE  
  [dfg]  
  VALIDATION = WELL_FORMED_XML ;
  
  
CREATE PARTITION FUNCTION myRangePF1 (int)  
AS RANGE LEFT FOR VALUES (1, 100, 1000); 

CREATE PARTITION FUNCTION myRangePF1 (INT)  
AS RANGE LEFT FOR VALUES (1, 100, 1000);  


CREATE PARTITION SCHEME myRangePS1  
AS PARTITION myRangePF1  
TO (test1fg, test2fg, test3fg, test4fg);

CREATE QUEUE ExpenseQueue
    WITH STATUS=ON,
    ACTIVATION (
        PROCEDURE_NAME = expense_procedure
        , MAX_QUEUE_READERS = 5
        , EXECUTE AS 'ExpenseUser' );
		
CREATE REMOTE SERVICE BINDING APBinding  
    TO SERVICE '//Adventure-Works.com/services/AccountsPayable'  
    WITH USER = APUser ; 
	
	
CREATE RESOURCE POOL PoolAdmin  
WITH (  
     MIN_CPU_PERCENT = 10,  
     MAX_CPU_PERCENT = 20,  
     CAP_CPU_PERCENT = 30,  
     AFFINITY SCHEDULER = (0 TO 63, 128 TO 191),  
     MIN_MEMORY_PERCENT = 5,  
     MAX_MEMORY_PERCENT = 15  
      );
	 
CREATE ROLE buyers AUTHORIZATION BenMiller; 

CREATE ROUTE ExpenseRoute  
    WITH  
    SERVICE_NAME = '//Adventure-Works.com/Expenses',  
    BROKER_INSTANCE = 'D8D4D268-00A3-4C62-8F91-634B89C1E315',  
    ADDRESS = 'TCP://www.Adventure-Works.com:1234' ; 
	
CREATE RULE range_rule  
AS   
@range >= $1000 AND @range <$20000;


CREATE RULE list_rule  
AS   
@list IN ('1389', '0736', '0877');

CREATE SCHEMA Sprockets AUTHORIZATION Annik  
    CREATE TABLE NineProngs (source int, cost int, partnumber int)  
    GRANT SELECT ON SCHEMA::Sprockets TO Mandar  
    DENY SELECT ON SCHEMA::Sprockets TO Prasanna; 
	
CREATE SEARCH PROPERTY LIST JobCandidateProperties 
FROM AdventureWorks2022.DocumentPropertyList;  

CREATE SECURITY POLICY rls.SecPol  
    ADD FILTER PREDICATE rls.tenantAccessPredicate(TenantId) ON dbo.Sales,  
    ADD BLOCK PREDICATE rls.tenantAccessPredicate(TenantId) ON dbo.Sales AFTER INSERT;


CREATE SELECTIVE XML INDEX sample on T1(C1)  
WITH XMLNAMESPACES ('https://www.tempuri.org/' as myns)  
FOR ( path1 = '/myns:book/myns:author/text()' );

CREATE SERVER AUDIT AuditDataAccess
    TO FILE ( FILEPATH ='C:\SQLAudit\ ' ) 
    WHERE object_name = 'SensitiveData' ;

CREATE SERVER ROLE auditors AUTHORIZATION securityadmin;

/*CREATE SERVICE bfd ON QUEUE ExpenseQueue  
    ([//Adventure-Works.com/Expenses/ExpenseSubmission],  
     [//Adventure-Works.com/Expenses/ExpenseProcessing]) ;*/  
	 
CREATE SYMMETRIC KEY MarketingXXV
WITH ALGORITHM = AES_128,
KEY_SOURCE
     = 'The square of the hypotenuse is equal to the sum of the squares of the sides',
IDENTITY_VALUE = 'Pythagoras'
ENCRYPTION BY CERTIFICATE Marketing25;

CREATE SYNONYM MyEmployee FOR Server_Remote.AdventureWorks2022.HumanResources.Employee;

CREATE TYPE Utf8String
EXTERNAL NAME utf8string.[Microsoft.Samples.SqlServer.utf8string];

CREATE TYPE LocationTableType AS TABLE (
    LocationName VARCHAR(50),
    CostRate INT
);

CREATE TYPE dbo.udt_money FROM varchar(11) NOT NULL;


CREATE USER Carlo  
WITH PASSWORD='RN92piTCh%$!~3K9844 Bl*'  
    , DEFAULT_LANGUAGE=[Brazilian]  
    , DEFAULT_SCHEMA=[dbo]
	
	
CREATE WORKLOAD GROUP newReports
WITH
    (REQUEST_MAX_MEMORY_GRANT_PERCENT = 2.5
      , REQUEST_MAX_CPU_TIME_SEC = 100
      , MAX_DOP = 4)
USING "default" ;

CREATE XML SCHEMA COLLECTION ManuInstructionsSchemaCollection AS  
'<?xml version="1.0" encoding="UTF-16"?>  
<xsd:schema targetNamespace="https://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions"   
   xmlns          ="https://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions"   
   elementFormDefault="qualified"   
   attributeFormDefault="unqualified"  
   xmlns:xsd="http://www.w3.org/2001/XMLSchema" >  
  
    <xsd:complexType name="StepType" mixed="true" >  
        <xsd:choice  minOccurs="0" maxOccurs="unbounded" >   
            <xsd:element name="tool" type="xsd:string" />  
            <xsd:element name="material" type="xsd:string" />  
            <xsd:element name="blueprint" type="xsd:string" />  
            <xsd:element name="specs" type="xsd:string" />  
            <xsd:element name="diag" type="xsd:string" />  
        </xsd:choice>   
    </xsd:complexType>  
  
    <xsd:element  name="root">  
        <xsd:complexType mixed="true">  
            <xsd:sequence>  
                <xsd:element name="Location" minOccurs="1" maxOccurs="unbounded">  
                    <xsd:complexType mixed="true">  
                        <xsd:sequence>  
                            <xsd:element name="step" type="StepType" minOccurs="1" maxOccurs="unbounded" />  
                        </xsd:sequence>  
                        <xsd:attribute name="LocationID" type="xsd:integer" use="required"/>  
                        <xsd:attribute name="SetupHours" type="xsd:decimal" use="optional"/>  
                        <xsd:attribute name="MachineHours" type="xsd:decimal" use="optional"/>  
                        <xsd:attribute name="LaborHours" type="xsd:decimal" use="optional"/>  
                        <xsd:attribute name="LotSize" type="xsd:decimal" use="optional"/>  
                    </xsd:complexType>  
                </xsd:element>  
            </xsd:sequence>  
        </xsd:complexType>  
    </xsd:element>  
</xsd:schema>' ;


COLLATE Latin1_General_CS_AS_KS_WS ASC;

DROP AGGREGATE dbo.Concatenate;

DROP APPLICATION ROLE weekly_ledger;

DROP ASSEMBLY Helloworld ; 

DROP ASYMMETRIC KEY MirandaXAsymKey6;

DROP AVAILABILITY GROUP AccountsAG;  

DROP BROKER PRIORITY InitiatorAToTargetPriority;

DROP CERTIFICATE Shipping04; 

DROP COLUMN MASTER KEY key_name;  

DROP CREDENTIAL Saddles;

DROP CONTRACT [//Adventure-Works.com/Expenses/ExpenseSubmission] ; 

DROP CRYPTOGRAPHIC PROVIDER SecurityProvider; 

DROP DATABASE Sales, NewSales;

DROP DATABASE ENCRYPTION KEY; 

DROP DATABASE AUDIT SPECIFICATION HIPAA_Audit_DB_Specification;

DROP DEFAULT datedflt;
 
DROP ENDPOINT sql_endpoint;

DROP EXTERNAL DATA SOURCE mydatasource;

DROP EXTERNAL TABLE EasternDivision.dbo.SalesPerson;  

DROP EXTERNAL FILE FORMAT myfileformat;

DROP EXTERNAL LANGUAGE Java;

DROP EXTERNAL LIBRARY customPackage;

DROP EXTERNAL RESOURCE POOL ex_pool; 

DROP EVENT NOTIFICATION NotifyALTER_T1  
ON DATABASE;  

DROP EVENT SESSION evt_spin_lock_diagnosis ON SERVER ;

DROP FULLTEXT CATALOG catalogdf ;

DROP FULLTEXT INDEX ON HumanResources.JobCandidate;

DROP FULLTEXT STOPLIST myStoplist;

DROP FUNCTION Sales.fn_SalesByStore; 

DROP LOGIN WilliJo; 

DROP MASTER KEY;

DROP MESSAGE TYPE [//Adventure-Works.com/Expenses/SubmitExpense] ; 

DROP PARTITION FUNCTION myRangePF;

DROP PARTITION SCHEME myRangePS1;

DROP QUEUE ExpenseQueue ; 

DROP PROCEDURE
    dbo.uspGetSalesbyMonth,
    dbo.uspUpdateSalesQuotes,
    dbo.uspGetSalesByYear;
	
DROP REMOTE SERVICE BINDING APBinding ;

DROP RESOURCE POOL big_pool;

DROP ROLE purchasing;

DROP ROUTE ExpenseRoute ; 

DROP RULE VendorID_rule;

DROP SCHEMA Sprockets;

DROP SEARCH PROPERTY LIST JobCandidateProperties; 

DROP SECURITY POLICY secPolicy; 

DROP SENSITIVITY CLASSIFICATION FROM
    dbo.sales.price
	
DROP SEQUENCE CountBy1 ; 

DROP SERVER AUDIT HIPAA_Audit;

DROP SERVER AUDIT SPECIFICATION HIPAA_Audit_Specification;  

DROP SERVER ROLE purchasing;

DROP SIGNATURE FROM HumanResources.uspUpdateEmployeeLogin   
    BY CERTIFICATE HumanResourcesDP;

DROP STATISTICS Purchasing.Vendor.VendorCredit, Sales.SalesOrderHeader.CustomerTotal; 

DROP SYMMETRIC KEY GailSammamishKey6;

DROP SYNONYM MyProduct;

DROP TABLE ProductVendor1 ;

DROP TRIGGER employee_insupd;

DROP TYPE ssn ;

DROP USER AbolrousHazem; 

DROP VIEW IF EXISTS dbo.Reorder ;

DROP WORKLOAD GROUP adhoc;

DROP XML SCHEMA COLLECTION ManuInstructionsSchemaCollection; 

ADD SIGNATURE TO [sp_signature_demo]   
    BY CERTIFICATE [cert_signature_demo]   
    WITH PASSWORD = 'pGFD4bb925DGvbd2439587y' ;
	
CLOSE MASTER KEY  

CLOSE SYMMETRIC KEY ShippingSymKey04; 

DENY TAKE OWNERSHIP ON AVAILABILITY GROUP::MyAg TO PKomosinski   
    CASCADE; 
	
DENY EXECUTE ON ASSEMBLY::MyAssembly TO User, Role CASCADE AS dbo;

DENY CONTROL ON ASYMMETRIC KEY::MyAsymmetricKey    TO UserA, RoleB    CASCADE    AS dbo;

DENY VIEW DEFINITION ON CERTIFICATE::MyCertificate    TO UserX, RoleY    CASCADE    AS dbo;

DENY VIEW DEFINITION TO CarmineEs CASCADE;

DENY IMPERSONATE ON USER::HamithaL TO AccountsPayable17;

DENY ALTER ON DATABASE SCOPED CREDENTIAL::MyCredential   TO UserA, RoleB   CASCADE   AS dbo;

DENY TAKE OWNERSHIP ON ENDPOINT::Shipping83 TO PKomosinski CASCADE; 

DENY ALTER ON FULLTEXT CATALOG::MyFullTextCatalog    TO User1, Role1    CASCADE    AS dbo;

-- Deny ALTER permission on the full-text stoplist
DENY ALTER ON FULLTEXT STOPLIST::MyStopList    TO User1, Role1  CASCADE AS dbo;

DENY EXECUTE ON OBJECT::HumanResources.uspUpdateEmployeeHireInfo  TO Recruiting11; 

DENY INSERT, UPDATE ON SCHEMA::SalesSchema TO UserX, RoleY CASCADE AS dbo;

DENY ALTER ON SEARCH PROPERTY LIST::MySearchPropertyList  TO User1, Role2 CASCADE AS dbo;

DENY CREATE ENDPOINT TO ArifS AS MandarP;

DENY VIEW DEFINITION ON SERVER ROLE::Sales TO Auditors ;  

DENY SEND ON REMOTE SERVICE BINDING::MyRemoteBinding  TO UserA, RoleB CASCADE  AS dbo; 

DENY ALTER ON SYMMETRIC KEY::SamInventory42 TO HamidS;   

DENY EXECUTE ON sys.xp_cmdshell TO public; 

DENY VIEW DEFINITION ON TYPE::Telemarketing.PhoneNumber  TO KhalidR CASCADE; 

DENY EXECUTE ON XML SCHEMA COLLECTION::Sales.Invoices4 TO Wanida;  

GRANT EXECUTE ON TestProc TO User2;

GRANT EXECUTE ON TestProc TO TesterRole WITH GRANT OPTION;

GRANT EXECUTE ON ASSEMBLY::MyAssembly  TO User1, Role1 WITH GRANT OPTION AS dbo;

GRANT CONTROL ON ASYMMETRIC KEY::MyAsymmetricKey  TO UserA, RoleB  WITH GRANT OPTION AS dbo;

GRANT VIEW DEFINITION ON AVAILABILITY GROUP::MyAg TO ZArifin;  

GRANT CONTROL ON CERTIFICATE::PaymentCert  TO Sarah, John  WITH GRANT OPTION  AS dbo;

GRANT CREATE VIEW TO CarmineEs WITH GRANT OPTION;

GRANT VIEW DEFINITION ON ROLE::SammamishParking TO JinghaoLiu WITH GRANT OPTION;  

GRANT USE ON DATABASE SCOPED CREDENTIAL::MyDbScopedCredential  TO Jane, DataTeam  WITH GRANT OPTION  AS dbo;

GRANT TAKE OWNERSHIP ON ENDPOINT::Shipping83 TO PKomosinski  WITH GRANT OPTION;

GRANT CONTROL ON FULLTEXT CATALOG :: ProductCatalog  TO Ted ; 
	
GRANT VIEW DEFINITION  ON FULLTEXT STOPLIST :: ProductStoplist  TO Mary ;  

GRANT REFERENCES (BusinessEntityID) ON OBJECT::HumanResources.vEmployee  TO Wanida WITH GRANT OPTION;

GRANT SELECT ON SCHEMA :: Person TO WilJo WITH GRANT OPTION; 

GRANT VIEW DEFINITION ON SEARCH PROPERTY LIST :: DocumentTablePropertyList  TO Mary ; 

GRANT ALTER ANY EVENT NOTIFICATION TO JanethEsteves WITH GRANT OPTION; 

GRANT VIEW DEFINITION ON LOGIN::EricKurjan TO RMeyyappan  WITH GRANT OPTION; 

GRANT IMPERSONATE ON LOGIN::WanidaBenshoof to [AdvWorksYoonM];

GRANT VIEW DEFINITION ON SERVER ROLE::Sales TO Auditors ;

GRANT SEND ON CONTRACT::OrderContract  TO Alice, OrderProcessors   WITH GRANT OPTION  AS dbo;

GRANT SEND ON SERVICE::OrderService  TO [Alice], [OrderProcessors] WITH GRANT OPTION AS [dbo];

GRANT SEND ON ROUTE::OrderRoute TO [Alice], [OrderProcessors] WITH GRANT OPTION AS [dbo];

GRANT SEND ON REMOTE SERVICE BINDING::OrderServiceBinding  TO [Alice], [OrderProcessors] WITH GRANT OPTION  AS [dbo];

GRANT ALTER ON SYMMETRIC KEY::SamInventory42 TO HamidS; 

GRANT SELECT ON sys.sql_logins TO Sylvester1;
GRANT VIEW SERVER STATE to Sylvester1;

GRANT VIEW DEFINITION ON TYPE::Telemarketing.PhoneNumber  TO KhalidR WITH GRANT OPTION;

GRANT EXECUTE ON XML SCHEMA COLLECTION::Sales.Invoices4 TO Wanida; 

OPEN MASTER KEY DECRYPTION BY PASSWORD = '43987hkhj4325tsku7';  

OPEN SYMMETRIC KEY HarnpadoungsatayaSE3  DECRYPTION BY CERTIFICATE sariyaCert01;  

REVERT WITH COOKIE = @cookie;

REVOKE SELECT ON SCHEMA :: Sales TO Vendors;

REVOKE GRANT OPTION FOR EXECUTE ON ASSEMBLY::MyAssembly FROM [UserA], [RoleB] CASCADE AS [dbo];

REVOKE GRANT OPTION FOR CONTROL ON ASYMMETRIC KEY::MyAsymmetricKey FROM [UserX], [RoleY] CASCADE AS [dbo] ;

REVOKE VIEW DEFINITION ON AVAILABILITY GROUP::MyAg TO ZArifin; 

REVOKE GRANT OPTION FOR CONTROL ON CERTIFICATE::MyCertificate  FROM [UserA], [RoleB] CASCADE  AS [dbo];

REVOKE REFERENCES FROM AuditMonitor;  

REVOKE CONTROL ON USER::Wanida FROM RolandX; 

REVOKE GRANT OPTION FOR USE ON DATABASE SCOPED CREDENTIAL::MyDbScopedCredential FROM [UserX], [RoleY] CASCADE AS [dbo];

REVOKE TAKE OWNERSHIP ON ENDPOINT::Shipping83 FROM PKomosinski  CASCADE; 

REVOKE GRANT OPTION FOR ALTER ON FULLTEXT CATALOG::MyFullTextCatalog FROM [UserA], [RoleB] CASCADE AS [dbo];

REVOKE GRANT OPTION FOR ALTER ON FULLTEXT STOPLIST::MyStoplist  FROM [UserA], [RoleB] CASCADE  AS [dbo];

REVOKE EXECUTE ON OBJECT::HumanResources.uspUpdateEmployeeHireInfo  FROM Recruiting11; 

REVOKE GRANT OPTION FOR ALTER ON SCHEMA::Sales  FROM [UserA], [RoleB] CASCADE AS [dbo];

REVOKE GRANT OPTION FOR ALTER ON SEARCH PROPERTY LIST::MySearchPropertyList  FROM [UserA], [RoleB] CASCADE AS [dbo];

REVOKE GRANT OPTION FOR CONNECT SQL FROM JanethEsteves; 

REVOKE IMPERSONATE ON LOGIN::WanidaBenshoof FROM [AdvWorksYoonM]; 

REVOKE GRANT OPTION FOR ALTER ON CONTRACT::MyContract    FROM [UserA], [RoleB]  CASCADE  AS [dbo];

REVOKE GRANT OPTION FOR ALTER ON SERVICE::MyService FROM [UserA], [RoleB] CASCADE  AS [dbo];

REVOKE ALTER ON SYMMETRIC KEY::SamInventory42 TO HamidS CASCADE;

REVOKE EXECUTE ON sys.sp_addlinkedserver FROM public;

REVOKE VIEW DEFINITION ON TYPE::Telemarketing.PhoneNumber FROM KhalidR CASCADE;

REVOKE EXECUTE ON XML SCHEMA COLLECTION::Sales.Invoices4 FROM Wanida; 

SETUSER 'mary';

BEGIN CONVERSATION TIMER (@dialog_handle)  
TIMEOUT = 120 ;  

END CONVERSATION @dialog_handle WITH ERROR = @ErrorSave DESCRIPTION = @ErrorDesc;

WAITFOR (  
 GET CONVERSATION GROUP @conversation_group_id  
     FROM ExpenseQueue  
) ; 

GET CONVERSATION GROUP @conversation_group_id  
FROM AdventureWorks.dbo.ExpenseQueue ; 

MOVE CONVERSATION @conversation_handle TO @conversation_group_id ; 

RECEIVE *  FROM ExpenseQueue  WHERE conversation_handle = @conversation_handle ;

SET ANSI_DEFAULTS ON ;

SET CONCAT_NULL_YIELDS_NULL ON ;

SET IMPLICIT_TRANSACTIONS OFF;

SET NUMERIC_ROUNDABORT ON; 

ADD SENSITIVITY CLASSIFICATION TO dbo.sales.price,
    dbo.sales.discount
WITH (
    LABEL = 'Highly Confidential',
    INFORMATION_TYPE = 'Financial',
    RANK = CRITICAL
);


BULK INSERT AdventureWorks2022.Sales.SalesOrderDetail
   FROM 'f:\orders\lineitem.tbl'
   WITH
     (
         FIELDTERMINATOR = ' |'
         , ROWTERMINATOR = ':\n'
         , FIRE_TRIGGERS
      );
	  
	  
DISABLE TRIGGER safety ON DATABASE; 

TRUNCATE TABLE HumanResources.JobCandidate;

DELETE FROM Production.ProductCostHistory  
WHERE StandardCost > 1000.00;  

DELETE FROM Sales.SalesPersonQuotaHistory   
FROM Sales.SalesPersonQuotaHistory AS spqh  
INNER JOIN Sales.SalesPerson AS sp  
ON spqh.BusinessEntityID = sp.BusinessEntityID  
WHERE sp.SalesYTD > 2500000.00;

DELETE FROM HumanResources.EmployeePayHistory  
WHERE CURRENT OF complex_cursor; 

DELETE FROM Sales.SalesPersonQuotaHistory   
WHERE BusinessEntityID IN   
    (SELECT BusinessEntityID   
     FROM Sales.SalesPerson   
     WHERE SalesYTD > 2500000.00); 
	 
DELETE OPENQUERY (MyLinkServer, 'SELECT Name, GroupName 
FROM AdventureWorks2022.HumanResources.Department  
WHERE DepartmentID = 18'); 

DELETE FROM OPENDATASOURCE('SQLNCLI',  
    'Data Source= <server_name>; Integrated Security=SSPI')  
    .AdventureWorks2022.HumanResources.Department   
WHERE DepartmentID = 17;

INSERT INTO DimCurrency   
VALUES (500, N'C1', N'Currency1')  
OPTION ( LABEL = N'label1' );

INSERT INTO EmployeeTitles  
    SELECT EmployeeKey, LastName, Title   
    FROM ssawPDW.dbo.DimEmployee  
    WHERE EndDate IS NULL;  
	
	
	INSERT INTO Production.ZeroInventory (DeletedProductID, RemovedOnDate)  
SELECT ProductID, GETDATE()  
FROM  
(   MERGE Production.ProductInventory AS pi  
    USING (SELECT ProductID, SUM(OrderQty) FROM Sales.SalesOrderDetail AS sod  
           JOIN Sales.SalesOrderHeader AS soh  
           ON sod.SalesOrderID = soh.SalesOrderID  
           AND soh.OrderDate = '20070401'  
           GROUP BY ProductID) AS src (ProductID, OrderQty)  
    ON (pi.ProductID = src.ProductID)  
    WHEN MATCHED AND pi.Quantity - src.OrderQty <= 0  
        THEN DELETE  
    WHEN MATCHED  
        THEN UPDATE SET pi.Quantity = pi.Quantity - src.OrderQty  
    OUTPUT $action, deleted.ProductID) AS Changes (Action, ProductID)  
WHERE Action = 'DELETE';

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
	
	
INSERT INTO dbo.Points (PointValue) VALUES (CONVERT(Point, '3,4'));  
INSERT INTO dbo.Points (PointValue) VALUES (CONVERT(Point, '1,5'));  
INSERT INTO dbo.Points (PointValue) VALUES (CAST ('1,99' AS Point));


INSERT INTO Production.UnitMeasure  
VALUES (N'FT2', N'Square Feet ', '20080923'), (N'Y', N'Yards', '20080923')
    , (N'Y3', N'Cubic Yards', '20080923');  
	
INSERT INTO dbo.friend VALUES ((SELECT $node_id FROM dbo.Person WHERE name = 'Alice'),
        (SELECT $node_id FROM dbo.Person WHERE name = 'John'), '9/15/2011');
		
UPDATE Person.Address  
SET ModifiedDate = GETDATE();

UPDATE Sales.SalesPerson  
SET Bonus = 6000, CommissionPct = 10, SalesQuota = NULL; 

UPDATE Production.Product  
SET Color = 'Metallic Red'  
WHERE Name LIKE 'Road-250%' AND Color = 'Red';  

UPDATE TOP (10) HumanResources.Employee
SET VacationHours = VacationHours * 1.25 ;

UPDATE Production.BillOfMaterials  
SET PerAssemblyQty = c.PerAssemblyQty * 2  
FROM Production.BillOfMaterials AS c  
JOIN Parts AS d ON c.ProductAssemblyID = d.AssemblyID  
WHERE d.ComponentLevel = 0; 

MERGE Production.ProductInventory AS tgt
USING (
    SELECT ProductID,
        SUM(OrderQty)
    FROM Sales.SalesOrderDetail AS sod
    INNER JOIN Sales.SalesOrderHeader AS soh
        ON sod.SalesOrderID = soh.SalesOrderID
            AND soh.OrderDate = @OrderDate
    GROUP BY ProductID
    ) AS src(ProductID, OrderQty)
    ON (tgt.ProductID = src.ProductID)
WHEN MATCHED
    AND tgt.Quantity - src.OrderQty 
    THEN
        DELETE
WHEN MATCHED
    THEN
        UPDATE
        SET tgt.Quantity = tgt.Quantity - src.OrderQty,
            tgt.ModifiedDate = GETDATE()
OUTPUT $action,
    Inserted.ProductID,
    Inserted.Quantity,
    Inserted.ModifiedDate,
    Deleted.ProductID,
    Deleted.Quantity,
    Deleted.ModifiedDate;
	
	
UPDATE STATISTICS Sales.SalesOrderDetail;

UPDATE STATISTICS t1 (a) WITH stats_stream = g01; 

ALTER APPLICATION ROLE weekly_receipts   
    WITH NAME = receipts_ledger;
	
ALTER ASSEMBLY ComplexNumber WITH PERMISSION_SET = EXTERNAL_ACCESS; 

ALTER ASSEMBLY ComplexNumber 
FROM 'C:\Program Files\Microsoft SQL Server\130\Tools\Samples\1033\Engine\Programmability\CLR\UserDefinedDataType\CS\ComplexNumber\obj\Debug\ComplexNumber.dll'


ALTER ASYMMETRIC KEY PacificSales09   
    WITH PRIVATE KEY (  
    DECRYPTION BY PASSWORD = '<oldPassword>',  
    ENCRYPTION BY PASSWORD = '<enterStrongPasswordHere>'); 
	
ALTER AUTHORIZATION ON database::testdb TO DisabledLogin;

ALTER AVAILABILITY GROUP AccountsAG FORCE_FAILOVER_ALLOW_DATA_LOSS;
ALTER AVAILABILITY GROUP AccountsAG JOIN;  
GO

ALTER BROKER PRIORITY SimpleContractDefaultPriority  
    FOR CONVERSATION  
    SET (PRIORITY_LEVEL = 3);
	
ALTER BROKER PRIORITY SimpleContractPriority  
    FOR CONVERSATION  
    SET (CONTRACT_NAME = SimpleContractB,  
         LOCAL_SERVICE_NAME = TargetServiceB,  
         REMOTE_SERVICE_NAME = N'InitiatorServiceB',  
         PRIORITY_LEVEL = 8); 
		 
ALTER CERTIFICATE Shipping13   
    WITH PRIVATE KEY (FILE = 'c:\importedkeys\Shipping13',  
    DECRYPTION BY PASSWORD = 'GDFLKl8^^GGG4000%');  
GO

ALTER CREDENTIAL Saddles WITH IDENTITY = 'RettigB',   
    SECRET = 'sdrlk8$40-dksli87nNN8'; 
	
ALTER CRYPTOGRAPHIC PROVIDER SecurityProvider  
FROM FILE = 'c:\SecurityProvider\SecurityProvider_v2.dll' ;  
GO 

ALTER CRYPTOGRAPHIC PROVIDER SecurityProvider   
DISABLE;

ALTER DATABASE AdventureWorks2022
Modify Name = Northwind ;

ALTER DATABASE testDB
COLLATE French_CI_AI ;

ALTER DATABASE AUDIT SPECIFICATION HIPAA_Audit_DB_Specification  
FOR SERVER AUDIT HIPAA_Audit  
    ADD (SELECT  
         ON OBJECT::dbo.Table1  
         BY dbo)  
    WITH (STATE = ON);  
GO 

ALTER DATABASE AdventureWorks2022
SET compatibility_level = 110;
GO

ALTER DATABASE AdventureWorks2022 SET PARTNER FAILOVER;

-- Uses AdventureWorks  
  
ALTER DATABASE ENCRYPTION KEY  
REGENERATE WITH ALGORITHM = AES_256;  
GO

ALTER DATABASE AccountsDb1 SET HADR AVAILABILITY GROUP = AccountsAG; 

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY ;
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = ON ;


ALTER ENDPOINT endPointName
    FOR TSQL ( 
        AUTHENTICATION = WINDOWS,
        ENCRYPTION = REQUIRED 
    );
	
ALTER EVENT SESSION test_session ON SERVER  
ADD EVENT sqlserver.database_transaction_begin,  
ADD EVENT sqlserver.database_transaction_end;  
GO 

ALTER EXTERNAL DATA SOURCE hadoop_eds SET
     LOCATION = 'hdfs://10.10.10.10:8020',
     RESOURCE_MANAGER_LOCATION = '10.10.10.10:8032'
    ;
	
ALTER EXTERNAL DATA SOURCE AzureStorage_west SET
   LOCATION = 'wasbs://loadingdemodataset@updatedproductioncontainer.blob.core.windows.net',
   CREDENTIAL = AzureStorageCredential
   
ALTER EXTERNAL LANGUAGE Java 
SET (CONTENT = N'<path-to-zip>', FILE_NAME = 'javaextension.dll');
GO

ALTER EXTERNAL LIBRARY customPackage 
SET 
  (CONTENT = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\customPackage.zip')
WITH (LANGUAGE = 'R');

ALTER EXTERNAL RESOURCE POOL ep_1
WITH (
    MAX_CPU_PERCENT = 50
    , MAX_MEMORY_PERCENT = 25
);
GO

ALTER FULLTEXT CATALOG ftCatalog   
REBUILD WITH ACCENT_SENSITIVITY=OFF;  
GO 


ALTER FULLTEXT INDEX ON table_1
    SET SEARCH PROPERTY LIST OFF WITH NO POPULATION;
	
ALTER FULLTEXT STOPLIST CombinedFunctionWordList ADD 'en' LANGUAGE 'Spanish';  
ALTER FULLTEXT STOPLIST CombinedFunctionWordList ADD 'en' LANGUAGE 'French';


ALTER FUNCTION dbo.CalculateTax
(
    @Amount DECIMAL(10, 2)
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    -- Updated tax calculation logic
    RETURN @Amount * 0.10
END;

ALTER FUNCTION dbo.GetFormattedDate
(
    @InputDate DATETIME,
    @Format NVARCHAR(20) = 'yyyy-MM-dd'
)
RETURNS NVARCHAR(50)
WITH EXECUTE_AS_Clause 
AS EXTERNAL NAME YourAssembly.YourNamespace.GetFormattedDate;



ALTER FUNCTION dbo.GetEmployeeDetails()
RETURNS @EmployeeDetails TABLE 
(
    EmployeeID INT,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Department NVARCHAR(50),
    Email NVARCHAR(100)
)
AS
BEGIN
    INSERT INTO @EmployeeDetails
    SELECT EmployeeID, FirstName, LastName, Department, Email
    FROM Employees;

    RETURN;
END;



ALTER FUNCTION dbo.CalculateDiscountPrice
(
    @OriginalPrice DECIMAL(10, 2),
    @DiscountRate DECIMAL(5, 2),
    @TaxRate DECIMAL(5, 2) = 0.00
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @DiscountedPrice DECIMAL(10, 2);
    DECLARE @FinalPrice DECIMAL(10, 2);

    -- Calculate the price after discount
    SET @DiscountedPrice = @OriginalPrice - (@OriginalPrice * @DiscountRate / 100);

    -- Calculate the final price after adding tax
    SET @FinalPrice = @DiscountedPrice + (@DiscountedPrice * @TaxRate / 100);

    RETURN @FinalPrice;
END;


ALTER INDEX ALL ON dbo.table1 REBUILD;

ALTER INDEX idxcci_cci_target ON cci_target REORGANIZE WITH (COMPRESS_ALL_ROW_GROUPS = ON);

-- REORGANIZE a specific partition
ALTER INDEX cci_FactInternetSales2 ON FactInternetSales2 REORGANIZE PARTITION = 0;

ALTER INDEX sxi_index  
ON Tbl  
FOR   
(  
    ADD pathm = '/a/b/m' as XQUERY 'node()' ,  
    REMOVE pathabe  
);

ALTER INDEX sxi_index  
ON Tbl  
PAD_INDEX = ON;  

ALTER LOGIN Mary5 WITH PASSWORD = '<enterStrongPasswordHere>' OLD_PASSWORD = '<oldWeakPasswordHere>';

ALTER LOGIN TestUser WITH
PASSWORD = 0x01000CF35567C60BFB41EBDE4CF700A985A13D773D6B45B90900 HASHED ;
GO

ALTER MASTER KEY REGENERATE WITH ENCRYPTION BY PASSWORD = 'dsjdkflJ435907NnmM#sX003';
GO


ALTER MESSAGE TYPE  
    [/Adventure-Works.com/Expenses/SubmitExpense] 
    VALIDATION = WELL_FORMED_XML ;


ALTER PARTITION FUNCTION myRangePF1 ()  
SPLIT RANGE (500);

ALTER PARTITION SCHEME MyRangePS1  
NEXT USED test5fg;
GO  
ALTER PROCEDURE Purchasing.uspVendorAllInfo  
    @Product VARCHAR(25)   
AS  
	BEGIN
    SET NOCOUNT ON;  
    SELECT LEFT(v.Name, 25) AS Vendor, LEFT(p.Name, 25) AS 'Product name',   
    'Rating' = CASE v.CreditRating   
        WHEN 1 THEN 'Superior'  
        WHEN 2 THEN 'Excellent'  
        WHEN 3 THEN 'Above average'  
        WHEN 4 THEN 'Average'  
        WHEN 5 THEN 'Below average'  
        ELSE 'No rating'  
        
    , Availability = CASE v.ActiveFlag  
        WHEN 1 THEN 'Yes'  
        ELSE 'No'  
      
    FROM Purchasing.Vendor AS v   
    INNER JOIN Purchasing.ProductVendor AS pv  
      ON v.BusinessEntityID = pv.BusinessEntityID   
    INNER JOIN Production.Product AS p   
      ON pv.ProductID = p.ProductID   
    WHERE p.Name LIKE @Product  
    ORDER BY v.Name ASC 
	END 
	;
GO

ALTER QUEUE ExpenseQueue WITH ACTIVATION (MAX_QUEUE_READERS = 7) ;  

ALTER QUEUE ExpenseQueue  
    WITH ACTIVATION (  
        PROCEDURE_NAME = new_stored_proc,  
        EXECUTE AS SELF) ; 
		
ALTER REMOTE SERVICE BINDING APBinding  
    WITH USER = SecurityAccount ;
	
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL);  
GO  
ALTER RESOURCE GOVERNOR RECONFIGURE;  

ALTER RESOURCE POOL "default"  
WITH  
     ( MAX_CPU_PERCENT = 25);  
GO  
ALTER RESOURCE GOVERNOR RECONFIGURE;  
GO  

ALTER ROLE Sales ADD MEMBER Barry;  
ALTER ROLE Sales DROP MEMBER Barry;

ALTER ROUTE ExpenseRoute  
   WITH   
     SERVICE_NAME = '//Adventure-Works.com/Expenses';
	 
ALTER ROUTE ExpenseRoute  
   WITH   
     BROKER_INSTANCE = 'D8D4D268-00A3-4C62-8F91-634B89B1E317',  
     ADDRESS = 'TCP://www.Adventure-Works.com:1234'; 
	 
ALTER SCHEMA HumanResources TRANSFER Person.Address; 

ALTER SCHEMA Person TRANSFER type::Production.TestType ;  
GO  

ALTER SCHEMA Sales TRANSFER OBJECT::dbo.Region;  
GO

ALTER SEARCH PROPERTY LIST CVitaProperties  
ADD 'System.Author'   
WITH (   
      PROPERTY_DESCRIPTION = 'Author or authors of a given document.',  
      PROPERTY_SET_GUID   = 'F29F85E0-4FF9-1068-AB91-08002B27B3D9',   
      PROPERTY_INT_ID = 4   
      );  
	  
ALTER SECURITY POLICY pol1  
ADD FILTER PREDICATE schema_preds.SecPredicate1(column1)   
    ON myschema.mytable1,  
DROP FILTER PREDICATE   
    ON myschema.mytable2,  
ADD FILTER PREDICATE schema_preds.SecPredicate2(column2, 1)   
    ON myschema.mytable3;
	
ALTER SEQUENCE Test. TestSeq  
    RESTART WITH 100  
    INCREMENT BY 50  
    MINVALUE 50  
    MAXVALUE 200  
    NO CYCLE  
    NO CACHE  
;  
GO

ALTER SERVER AUDIT HIPAA_Audit  
WITH (STATE = OFF);  
GO  

ALTER SERVER AUDIT HIPAA_Audit  
MODIFY NAME = HIPAA_Audit_Old;  
GO  
ALTER SERVER AUDIT HIPAA_Audit_Old  
WITH (STATE = ON);  
GO 

ALTER SERVER AUDIT [FilterForSensitiveData] WITH (STATE = OFF)  
GO 
 
ALTER SERVER AUDIT [FilterForSensitiveData]  
WHERE user_defined_event_id = 27;  
GO  
ALTER SERVER AUDIT [FilterForSensitiveData] WITH (STATE = ON);  
GO 
  
ALTER SERVER AUDIT HIPAA_Audit  
WITH (STATE = OFF);  
GO  
ALTER SERVER AUDIT HIPAA_Audit  
TO FILE (FILEPATH ='\\SQLPROD_1\Audit\ ',  
          MAXSIZE = 1000 MB,  
          RESERVE_DISK_SPACE=OFF)  
WITH (QUEUE_DELAY = 1000,  
       ON_FAILURE = CONTINUE);  
GO  
ALTER SERVER AUDIT HIPAA_Audit  
WITH (STATE = ON);  
GO

ALTER SERVER AUDIT SPECIFICATION HIPAA_Audit_Specification  
FOR SERVER AUDIT HIPAA_Audit  
    DROP (FAILED_LOGIN_GROUP),  
    ADD (DATABASE_OBJECT_ACCESS_GROUP)  
    WITH (STATE=ON);  
GO

ALTER SERVER CONFIGURATION   
SET PROCESS AFFINITY NUMANODE=0, 7;

ALTER SERVER CONFIGURATION   
SET PROCESS AFFINITY CPU=60 TO 200;

ALTER SERVER CONFIGURATION SET PROCESS AFFINITY CPU=0;

ALTER SERVER CONFIGURATION  
SET DIAGNOSTICS LOG PATH = 'C:\logs';

ALTER SERVER CONFIGURATION SET DIAGNOSTICS LOG OFF;

ALTER SERVER CONFIGURATION   
SET DIAGNOSTICS LOG MAX_SIZE = 10 MB;

ALTER SERVER CONFIGURATION   
SET FAILOVER CLUSTER PROPERTY HealthCheckTimeout = 15000;

ALTER SERVER CONFIGURATION SET HADR CLUSTER CONTEXT = 'clus01.xyz.com';

ALTER SERVER ROLE Production ADD MEMBER [adventure-works\roberto0] ;

ALTER SERVICE [Adventure-WorkscomExpenses]  
    ON QUEUE NewQueue ;
	
ALTER SERVICE MASTER KEY REGENERATE;  
GO

ALTER SYMMETRIC KEY JanainaKey043   
    ADD ENCRYPTION BY PASSWORD = '<enterStrongPasswordHere>';  
-- Now remove encryption by the certificate.  
ALTER SYMMETRIC KEY JanainaKey043   
    DROP ENCRYPTION BY CERTIFICATE Shipping04;  
	
	ALTER TABLE dbo.doc_exa ADD column_b VARCHAR(20) NULL ;
GO



ALTER TABLE Person.ContactBackup
DROP CONSTRAINT FK_ContactBackup_Contact ;

ALTER TABLE dbo.doc_exy ALTER COLUMN col_b decimal (10,4) ;


ALTER TRIGGER Sales.bonus_reminder  
ON Sales.SalesPersonQuotaHistory  
AFTER INSERT  
AS RAISERROR ('Notify Compensation', 16, 10);  
GO  

ALTER USER Mary51 WITH DEFAULT_SCHEMA = Purchasing ;
GO

ALTER VIEW HumanResources.EmployeeHireDate  
AS  
SELECT p.FirstName, p.LastName, e.HireDate  
FROM HumanResources.Employee AS e JOIN Person.Person AS p  
ON e.BusinessEntityID = p.BusinessEntityID  
WHERE HireDate < CONVERT(DATETIME,'20020101',101) ;  
GO 


ALTER WORKLOAD GROUP "default"
WITH (IMPORTANCE = LOW);

ALTER WORKLOAD GROUP adHoc
USING default;
GO

ALTER XML SCHEMA COLLECTION MyColl ADD '  
  <schema xmlns="http://www.w3.org/2001/XMLSchema"   
         targetNamespace="https://MySchema/test_xml_schema">   
     <element name="anotherElement" type="byte"/>   
 </schema>';
 
BACKUP DATABASE AdventureWorks2022
 TO DISK = 'Z:\SQLServerBackups\AdvWorksData.bak'
    WITH FORMAT;
GO

BACKUP LOG AdventureWorks2022
    TO AdvWorksLog;
	
--Back up the files in SalesGroup1:
BACKUP DATABASE Sales
    FILEGROUP = 'SalesGroup1',
    FILEGROUP = 'SalesGroup2'
    TO DISK = 'Z:\SQLServerBackups\SalesFiles.bck';
GO

BACKUP DATABASE AdventureWorks2022
TO TAPE = '\\.\tape0'
MIRROR TO TAPE = '\\.\tape1'
MIRROR TO TAPE = '\\.\tape2'
MIRROR TO TAPE = '\\.\tape3'
WITH
    FORMAT,
    MEDIANAME = 'AdventureWorksSet0';
	
BACKUP CERTIFICATE sales05 TO FILE = 'c:\storedcerts\sales05cert'  
    WITH PRIVATE KEY ( FILE = 'c:\storedkeys\sales05key' ,   
    ENCRYPTION BY PASSWORD = '997jkhUbhk$w4ez0876hKHJH5gh' );  
GO

BACKUP MASTER KEY TO FILE = 'c:\temp\AdventureWorks2022_master_key'   
    ENCRYPTION BY PASSWORD = 'sd092735kjn$&adsg';  
GO 

BACKUP SERVICE MASTER KEY TO FILE = 'c:\temp_backups\keys\service_master_key' ENCRYPTION BY PASSWORD = '3dH85Hhk003GHk2597gheij4';


BACKUP SYMMETRIC KEY symmetric_key 
   TO URL = 'https://mydocsteststorage.blob.core.windows.net/mytestcontainer/symmetric_key.bak'
   ENCRYPTION BY PASSWORD = '3dH85Hhk003GHk2597gheij4'
   
BACKUP SYMMETRIC KEY symmetric_key
   TO FILE = 'c:\temp_backups\keys\symmetric_key' 
   ENCRYPTION BY PASSWORD = '3dH85Hhk003GHk2597gheij4';
   
RESTORE DATABASE AdventureWorks2022
    FROM DISK = 'Z:\SQLServerBackups\AdventureWorks2022.bak'
    WITH FILE = 6,
      NORECOVERY;
RESTORE DATABASE AdventureWorks2022
    FROM DISK = 'Z:\SQLServerBackups\AdventureWorks2022.bak'
    WITH FILE = 9,
      RECOVERY;
	  
RESTORE DATABASE AdventureWorks2022
    FROM AdventureWorksBackups;
-- Here is the RESTORE RESTART operation.
RESTORE DATABASE AdventureWorks2022
    FROM AdventureWorksBackups WITH RESTART;
	
RESTORE FILELISTONLY FROM AdventureWorksBackups   
   WITH FILE=2;  
GO

RESTORE HEADERONLY
FROM DISK = 'C:\AdventureWorks-FullBackup.bak';
GO
  
RESTORE MASTER KEY   
    FROM FILE = 'c:\backups\keys\AdventureWorks2022_master_key'   
    DECRYPTION BY PASSWORD = '3dH85Hhk003#GHkf02597gheij04'   
    ENCRYPTION BY PASSWORD = '259087M#MyjkFkjhywiyedfgGDFD';  
GO


RESTORE SERVICE MASTER KEY   
    FROM FILE = 'c:\temp_backups\keys\service_master_key'   
    DECRYPTION BY PASSWORD = '3dH85Hhk003GHk2597gheij4';  
GO

RESTORE SYMMETRIC KEY symmetric_key 
   FROM URL = 'https://mydocsteststorage.blob.core.windows.net/mytestcontainer/symmetric_key.bak'
   DECRYPTION BY PASSWORD = '3dH85Hhk003#GHkf02597gheij04'   
   ENCRYPTION BY PASSWORD = '259087M#MyjkFkjhywiyedfgGDFD';
   
   RESTORE VERIFYONLY FROM DISK = 'D:\AdventureWorks.bak';
GO

CREATE TABLE [HR].[Employees23]
(
    EmployeeID INT ,
    Salary Money NOT NULL
) ;

ALTER TABLE EmployeeResumes
ADD CONSTRAINT pk_employee_id PRIMARY KEY (LName);

ALTER TABLE Employees23
ADD CONSTRAINT pk_employee_id PRIMARY KEY (EmployeeID);

CREATE TABLE orders
(
    customer_id UTF8STRING,
    ustr AS u.ToString() PERSISTED
);

ALTER TABLE orders
ADD CONSTRAINT fk_customer_id FOREIGN KEY (customer_id)
REFERENCES Customers(customer_id);


CREATE TABLE test_weight_null (
    weight_grams INT NULL,
    CONSTRAINT chk_weight CHECK (weight_grams IS NULL OR weight_grams >= 0)
);

CREATE TABLE test_weight_not_null (
    weight_grams INT NOT NULL,
    CONSTRAINT chk_weight CHECK (weight_grams >= 0)
);

ALTER TABLE test_weight_null
ADD CONSTRAINT chk_weight_null
CHECK (weight_grams IS NULL OR weight_grams >= 0);

ALTER TABLE test_weight_not_null
ADD CONSTRAINT chk_weight_not_null
CHECK (weight_grams >= 0);

USE [EDU-Dev]
GO
/****** Object:  Table [dbo].[Dataset_Bathy_Data_Collection_PurposeHistory]    Script Date: 09/04/2026 16:39:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Bathy_Data_Collection_PurposeHistory](
	[DatasetBathyDataCollPurposeId] [bigint] NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[BathyDataCollPurposeId] [int] NOT NULL,
	[OtherBathyDataCollPurpose] [varchar](100) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Dataset_Bathy_Data_Collection_PurposeHistory]    Script Date: 09/04/2026 16:39:53 ******/
CREATE CLUSTERED INDEX [ix_Dataset_Bathy_Data_Collection_PurposeHistory] ON [dbo].[Dataset_Bathy_Data_Collection_PurposeHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dataset_Bathy_Data_Collection_Purpose]    Script Date: 09/04/2026 16:39:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Bathy_Data_Collection_Purpose](
	[DatasetBathyDataCollPurposeId] [bigint] IDENTITY(1,1) NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[BathyDataCollPurposeId] [int] NOT NULL,
	[OtherBathyDataCollPurpose] [varchar](100) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_Dataset_Bathy_Data_Collection_Purpose] PRIMARY KEY CLUSTERED 
(
	[DatasetBathyDataCollPurposeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Dataset_Bathy_Data_Collection_PurposeHistory])
)
GO
/****** Object:  Table [dbo].[Dataset_Bathy_Survey_CategoryHistory]    Script Date: 09/04/2026 16:39:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Bathy_Survey_CategoryHistory](
	[DatasetBathySrvyCtgryId] [bigint] NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[BathySurveyCategoryId] [int] NOT NULL,
	[OtherBathySurveyCategory] [varchar](100) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Dataset_Bathy_Survey_CategoryHistory]    Script Date: 09/04/2026 16:39:53 ******/
CREATE CLUSTERED INDEX [ix_Dataset_Bathy_Survey_CategoryHistory] ON [dbo].[Dataset_Bathy_Survey_CategoryHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dataset_Bathy_Survey_Category]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Bathy_Survey_Category](
	[DatasetBathySrvyCtgryId] [bigint] IDENTITY(1,1) NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[BathySurveyCategoryId] [int] NOT NULL,
	[OtherBathySurveyCategory] [varchar](100) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_Dataset_Bathy_Survey_Category] PRIMARY KEY CLUSTERED 
(
	[DatasetBathySrvyCtgryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Dataset_Bathy_Survey_CategoryHistory])
)
GO
/****** Object:  Table [dbo].[Dataset_Bathy_Survey_MethodHistory]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Bathy_Survey_MethodHistory](
	[DatasetBathySurveyMthdId] [bigint] NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[BathySurveyMthdId] [int] NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL,
	[ConductedCrosslinesInd] [bit] NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Dataset_Bathy_Survey_MethodHistory]    Script Date: 09/04/2026 16:39:54 ******/
CREATE CLUSTERED INDEX [ix_Dataset_Bathy_Survey_MethodHistory] ON [dbo].[Dataset_Bathy_Survey_MethodHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dataset_Bathy_Survey_Method]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Bathy_Survey_Method](
	[DatasetBathySurveyMthdId] [bigint] IDENTITY(1,1) NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[BathySurveyMthdId] [int] NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
	[ConductedCrosslinesInd] [bit] NULL,
 CONSTRAINT [PK_Dataset_Bathy_Survey_Method] PRIMARY KEY CLUSTERED 
(
	[DatasetBathySurveyMthdId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Dataset_Bathy_Survey_MethodHistory])
)
GO
/****** Object:  Table [dbo].[Dataset_Bathy_Survey_StandardHistory]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Bathy_Survey_StandardHistory](
	[DatasetBathySrvyStndrdId] [bigint] NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[BathySrvyStndId] [int] NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Dataset_Bathy_Survey_StandardHistory]    Script Date: 09/04/2026 16:39:54 ******/
CREATE CLUSTERED INDEX [ix_Dataset_Bathy_Survey_StandardHistory] ON [dbo].[Dataset_Bathy_Survey_StandardHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dataset_Bathy_Survey_Standard]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Bathy_Survey_Standard](
	[DatasetBathySrvyStndrdId] [bigint] IDENTITY(1,1) NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[BathySrvyStndId] [int] NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_Dataset_Bathy_Survey_Standard] PRIMARY KEY CLUSTERED 
(
	[DatasetBathySrvyStndrdId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Dataset_Bathy_Survey_StandardHistory])
)
GO
/****** Object:  Table [dbo].[Dataset_Coordinate_TypeHistory]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Coordinate_TypeHistory](
	[DatasetCoordinateTypeId] [bigint] NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[CoordinateTypeId] [int] NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Dataset_Coordinate_TypeHistory]    Script Date: 09/04/2026 16:39:54 ******/
CREATE CLUSTERED INDEX [ix_Dataset_Coordinate_TypeHistory] ON [dbo].[Dataset_Coordinate_TypeHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dataset_Coordinate_Type]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Coordinate_Type](
	[DatasetCoordinateTypeId] [bigint] IDENTITY(1,1) NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[CoordinateTypeId] [int] NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_Dataset_Coordinate_Type] PRIMARY KEY CLUSTERED 
(
	[DatasetCoordinateTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Dataset_Coordinate_TypeHistory])
)
GO
/****** Object:  Table [dbo].[Dataset_H275_Horizontal_DatumHistory]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_H275_Horizontal_DatumHistory](
	[DatasetH275HorizontalDatumId] [int] NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[H275HorizontalDatumId] [int] NOT NULL,
	[OtherH275HorizontalDatum] [varchar](100) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Dataset_H275_Horizontal_DatumHistory]    Script Date: 09/04/2026 16:39:54 ******/
CREATE CLUSTERED INDEX [ix_Dataset_H275_Horizontal_DatumHistory] ON [dbo].[Dataset_H275_Horizontal_DatumHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dataset_H275_Horizontal_Datum]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_H275_Horizontal_Datum](
	[DatasetH275HorizontalDatumId] [int] IDENTITY(1,1) NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[H275HorizontalDatumId] [int] NOT NULL,
	[OtherH275HorizontalDatum] [varchar](100) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_Dataset_H275_Horizontal_Datum] PRIMARY KEY CLUSTERED 
(
	[DatasetH275HorizontalDatumId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Dataset_H275_Horizontal_DatumHistory])
)
GO
/****** Object:  Table [dbo].[Dataset_H275_Vertical_DatumHistory]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_H275_Vertical_DatumHistory](
	[DatasetH275VerticalDatumId] [int] NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[H275VerticalDatumId] [int] NOT NULL,
	[OtherH275VerticalDatum] [varchar](100) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Dataset_H275_Vertical_DatumHistory]    Script Date: 09/04/2026 16:39:54 ******/
CREATE CLUSTERED INDEX [ix_Dataset_H275_Vertical_DatumHistory] ON [dbo].[Dataset_H275_Vertical_DatumHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dataset_H275_Vertical_Datum]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_H275_Vertical_Datum](
	[DatasetH275VerticalDatumId] [int] IDENTITY(1,1) NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[H275VerticalDatumId] [int] NOT NULL,
	[OtherH275VerticalDatum] [varchar](100) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_Dataset_H275_Vertical_Datum] PRIMARY KEY CLUSTERED 
(
	[DatasetH275VerticalDatumId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Dataset_H275_Vertical_DatumHistory])
)
GO
/****** Object:  Table [dbo].[Dataset_ProjectionHistory]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_ProjectionHistory](
	[DatasetProjectionId] [int] NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[Projection] [varchar](1024) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Dataset_ProjectionHistory]    Script Date: 09/04/2026 16:39:54 ******/
CREATE CLUSTERED INDEX [ix_Dataset_ProjectionHistory] ON [dbo].[Dataset_ProjectionHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dataset_Projection]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Projection](
	[DatasetProjectionId] [int] IDENTITY(1,1) NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[Projection] [varchar](1024) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_Dataset_Projection] PRIMARY KEY CLUSTERED 
(
	[DatasetProjectionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Dataset_ProjectionHistory])
)
GO
/****** Object:  Table [dbo].[Dataset_Sounding_To_Datum_Reduction_MethodHistory]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Sounding_To_Datum_Reduction_MethodHistory](
	[DatasetSndingToDatumRdctMthdId] [bigint] NOT NULL,
	[SndingToDatumRdctMthdId] [int] NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[OtherSndingToDatumRdctMthd] [varchar](150) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Dataset_Sounding_To_Datum_Reduction_MethodHistory]    Script Date: 09/04/2026 16:39:54 ******/
CREATE CLUSTERED INDEX [ix_Dataset_Sounding_To_Datum_Reduction_MethodHistory] ON [dbo].[Dataset_Sounding_To_Datum_Reduction_MethodHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dataset_Sounding_To_Datum_Reduction_Method]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Sounding_To_Datum_Reduction_Method](
	[DatasetSndingToDatumRdctMthdId] [bigint] IDENTITY(1,1) NOT NULL,
	[SndingToDatumRdctMthdId] [int] NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[OtherSndingToDatumRdctMthd] [varchar](150) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_Dataset_Sounding_To_Datum_Reduction_Method] PRIMARY KEY CLUSTERED 
(
	[DatasetSndingToDatumRdctMthdId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Dataset_Sounding_To_Datum_Reduction_MethodHistory])
)
GO
/****** Object:  Table [dbo].[Dataset_Source_Data_PermissionHistory]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Source_Data_PermissionHistory](
	[DatasetSrcePermId] [bigint] NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[DatasetSrceDataPermInd] [bit] NOT NULL,
	[SourceDataPermId] [int] NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Dataset_Source_Data_PermissionHistory]    Script Date: 09/04/2026 16:39:54 ******/
CREATE CLUSTERED INDEX [ix_Dataset_Source_Data_PermissionHistory] ON [dbo].[Dataset_Source_Data_PermissionHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dataset_Source_Data_Permission]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Source_Data_Permission](
	[DatasetSrcePermId] [bigint] IDENTITY(1,1) NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[DatasetSrceDataPermInd] [bit] NOT NULL,
	[SourceDataPermId] [int] NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_Dataset_Source_Data_Permission] PRIMARY KEY CLUSTERED 
(
	[DatasetSrcePermId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Dataset_Source_Data_PermissionHistory])
)
GO
/****** Object:  Table [dbo].[Dataset_Survey_PlatformHistory]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Survey_PlatformHistory](
	[DatasetSurveyPlatformId] [int] NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[DatasetSurveyPlatform] [varchar](150) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Dataset_Survey_PlatformHistory]    Script Date: 09/04/2026 16:39:54 ******/
CREATE CLUSTERED INDEX [ix_Dataset_Survey_PlatformHistory] ON [dbo].[Dataset_Survey_PlatformHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dataset_Survey_Platform]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Survey_Platform](
	[DatasetSurveyPlatformId] [int] IDENTITY(1,1) NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[DatasetSurveyPlatform] [varchar](150) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_Dataset_Survey_Platform] PRIMARY KEY CLUSTERED 
(
	[DatasetSurveyPlatformId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Dataset_Survey_PlatformHistory])
)
GO
/****** Object:  Table [dbo].[Dataset_XYZ_FormatHistory]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_XYZ_FormatHistory](
	[DatasetXYZFormatId] [bigint] NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[XYZFileXFormatId] [int] NULL,
	[XYZFileYFormatId] [int] NULL,
	[XYZFileZFormatId] [int] NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Dataset_XYZ_FormatHistory]    Script Date: 09/04/2026 16:39:54 ******/
CREATE CLUSTERED INDEX [ix_Dataset_XYZ_FormatHistory] ON [dbo].[Dataset_XYZ_FormatHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dataset_XYZ_Format]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_XYZ_Format](
	[DatasetXYZFormatId] [bigint] IDENTITY(1,1) NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[XYZFileXFormatId] [int] NULL,
	[XYZFileYFormatId] [int] NULL,
	[XYZFileZFormatId] [int] NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_Dataset_XYZ_Format] PRIMARY KEY CLUSTERED 
(
	[DatasetXYZFormatId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Dataset_XYZ_FormatHistory])
)
GO
/****** Object:  Table [dbo].[InstrumentHistory]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InstrumentHistory](
	[InstrumentId] [int] NOT NULL,
	[DatasetSurveyPlatformId] [int] NOT NULL,
	[InstrumentTypeMkeModel] [varchar](150) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_InstrumentHistory]    Script Date: 09/04/2026 16:39:54 ******/
CREATE CLUSTERED INDEX [ix_InstrumentHistory] ON [dbo].[InstrumentHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Instrument]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Instrument](
	[InstrumentId] [int] IDENTITY(1,1) NOT NULL,
	[DatasetSurveyPlatformId] [int] NOT NULL,
	[InstrumentTypeMkeModel] [varchar](150) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_Instrument] PRIMARY KEY CLUSTERED 
(
	[InstrumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[InstrumentHistory])
)
GO
/****** Object:  Table [dbo].[Metadata_DatafileHistory]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Metadata_DatafileHistory](
	[id] [bigint] NOT NULL,
	[Dataset_Id] [uniqueidentifier] NOT NULL,
	[sourcefile] [varchar](255) NULL,
	[createdtimestampdate] [datetime2](7) NOT NULL,
	[createdtimestamptimezone] [varchar](255) NOT NULL,
	[uu_id] [uniqueidentifier] NOT NULL,
	[dataformatversion] [varchar](50) NULL,
	[size] [bigint] NULL,
	[datetimerange_id] [bigint] NULL,
	[dataformat_id] [bigint] NULL,
	[DataFileStatusId] [int] NOT NULL,
	[CreatedBy] [varchar](100) NULL,
	[CreatedTS] [datetime2](7) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Metadata_DatafileHistory]    Script Date: 09/04/2026 16:39:54 ******/
CREATE CLUSTERED INDEX [ix_Metadata_DatafileHistory] ON [dbo].[Metadata_DatafileHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Metadata_Datafile]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Metadata_Datafile](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[Dataset_Id] [uniqueidentifier] NOT NULL,
	[sourcefile] [varchar](255) NULL,
	[createdtimestampdate] [datetime2](7) NOT NULL,
	[createdtimestamptimezone] [varchar](255) NOT NULL,
	[uu_id] [uniqueidentifier] NOT NULL,
	[dataformatversion] [varchar](50) NULL,
	[size] [bigint] NULL,
	[datetimerange_id] [bigint] NULL,
	[dataformat_id] [bigint] NULL,
	[DataFileStatusId] [int] NOT NULL,
	[CreatedBy] [varchar](100) NULL,
	[CreatedTS] [datetime2](7) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_Metadata_Datafile] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Metadata_DatafileHistory])
)
GO
/****** Object:  Table [dbo].[D365_Parties_RefHistory]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[D365_Parties_RefHistory](
	[D365ExternalSystemId] [varchar](255) NOT NULL,
	[Name] [varchar](160) NOT NULL,
	[FastTrackInd] [bit] NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL,
	[D365AccountTypeCode] [varchar](160) NOT NULL,
	[IsDACPartyInd] [bit] NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_D365_Parties_RefHistory]    Script Date: 09/04/2026 16:39:54 ******/
CREATE CLUSTERED INDEX [ix_D365_Parties_RefHistory] ON [dbo].[D365_Parties_RefHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[D365_Parties_Ref]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[D365_Parties_Ref](
	[D365ExternalSystemId] [varchar](255) NOT NULL,
	[Name] [varchar](160) NOT NULL,
	[FastTrackInd] [bit] NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
	[D365AccountTypeCode] [varchar](160) NOT NULL,
	[IsDACPartyInd] [bit] NOT NULL,
 CONSTRAINT [PK_D365_Parties_Ref] PRIMARY KEY CLUSTERED 
(
	[D365ExternalSystemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[D365_Parties_RefHistory])
)
GO
/****** Object:  Table [dbo].[Metadata_DatasetHistory]    Script Date: 09/04/2026 16:39:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Metadata_DatasetHistory](
	[DatasetId] [uniqueidentifier] NOT NULL,
	[ResourceTitle] [varchar](1024) NULL,
	[DataCollectionStartDate] [datetime2](7) NULL,
	[DataCollectionEndDate] [datetime2](7) NULL,
	[CreatedBy] [varchar](100) NULL,
	[CreatedTS] [datetime2](7) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[Dataset_Type] [varchar](255) NOT NULL,
	[FeatureId] [bigint] NOT NULL,
	[MetadataStandardId] [bigint] NOT NULL,
	[ResourceTypeId] [bigint] NOT NULL,
	[AdditionalInfo] [varchar](4096) NULL,
	[FullSurveyRprtIncInd] [bit] NULL,
	[UnresolvedCleansingComments] [varchar](1024) NULL,
	[NotShoalBiasedDepthsDtls] [varchar](400) NULL,
	[ShoalBiasedDepthsInd] [bit] NULL,
	[XYZDataSubmittedInd] [bit] NOT NULL,
	[LastModifiedTimestamp] [datetimeoffset](7) NOT NULL,
	[WrecksPresentInd] [bit] NULL,
	[WCDWreckInvestigInd] [bit] NULL,
	[FastTrackInd] [bit] NULL,
	[FileSharingMethodId] [int] NULL,
	[GriddedThinnedDataInd] [bit] NULL,
	[DatasetStatusId] [int] NOT NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL,
	[DeletedDatasetInd] [bit] NOT NULL,
	[DeletedDatasetReason] [varchar](400) NULL,
	[DeletedTS] [datetime2](7) NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Metadata_DatasetHistory]    Script Date: 09/04/2026 16:39:54 ******/
CREATE CLUSTERED INDEX [ix_Metadata_DatasetHistory] ON [dbo].[Metadata_DatasetHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Metadata_Dataset]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Metadata_Dataset](
	[DatasetId] [uniqueidentifier] NOT NULL,
	[ResourceTitle] [varchar](1024) NULL,
	[DataCollectionStartDate] [datetime2](7) NULL,
	[DataCollectionEndDate] [datetime2](7) NULL,
	[CreatedBy] [varchar](100) NULL,
	[CreatedTS] [datetime2](7) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[Dataset_Type] [varchar](255) NOT NULL,
	[FeatureId] [bigint] NOT NULL,
	[MetadataStandardId] [bigint] NOT NULL,
	[ResourceTypeId] [bigint] NOT NULL,
	[AdditionalInfo] [varchar](4096) NULL,
	[FullSurveyRprtIncInd] [bit] NULL,
	[UnresolvedCleansingComments] [varchar](1024) NULL,
	[NotShoalBiasedDepthsDtls] [varchar](400) NULL,
	[ShoalBiasedDepthsInd] [bit] NULL,
	[XYZDataSubmittedInd] [bit] NOT NULL,
	[LastModifiedTimestamp] [datetimeoffset](7) NOT NULL,
	[WrecksPresentInd] [bit] NULL,
	[WCDWreckInvestigInd] [bit] NULL,
	[FastTrackInd] [bit] NULL,
	[FileSharingMethodId] [int] NULL,
	[GriddedThinnedDataInd] [bit] NULL,
	[DatasetStatusId] [int] NOT NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
	[DeletedDatasetInd] [bit] NOT NULL,
	[DeletedDatasetReason] [varchar](400) NULL,
	[DeletedTS] [datetime2](7) NULL,
 CONSTRAINT [PK_Bathymetry_Data_Collection_Purpose] PRIMARY KEY CLUSTERED 
(
	[DatasetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Metadata_DatasetHistory])
)
GO
/****** Object:  Table [dbo].[Metadata_Dataset_Responsible_PartyHistory]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Metadata_Dataset_Responsible_PartyHistory](
	[DatasetRespPartyId] [bigint] NOT NULL,
	[PartyId] [bigint] NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[RespPartyRoleTypeId] [bigint] NOT NULL,
	[PrimaryContactInd] [bit] NULL,
	[CreatedBy] [varchar](100) NULL,
	[CreatedTS] [datetime2](7) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Metadata_Dataset_Responsible_PartyHistory]    Script Date: 09/04/2026 16:39:55 ******/
CREATE CLUSTERED INDEX [ix_Metadata_Dataset_Responsible_PartyHistory] ON [dbo].[Metadata_Dataset_Responsible_PartyHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Metadata_Dataset_Responsible_Party]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Metadata_Dataset_Responsible_Party](
	[DatasetRespPartyId] [bigint] IDENTITY(1,1) NOT NULL,
	[PartyId] [bigint] NOT NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[RespPartyRoleTypeId] [bigint] NOT NULL,
	[PrimaryContactInd] [bit] NULL,
	[CreatedBy] [varchar](100) NULL,
	[CreatedTS] [datetime2](7) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_Metadata_Dataset_Responsible_Party] PRIMARY KEY CLUSTERED 
(
	[DatasetRespPartyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Metadata_Dataset_Responsible_PartyHistory])
)
GO
/****** Object:  Table [dbo].[Survey_Positioning_SystemHistory]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Survey_Positioning_SystemHistory](
	[SurveyPosSystemId] [int] NOT NULL,
	[DatasetSurveyPlatformId] [int] NOT NULL,
	[SurveyPosSystem] [varchar](200) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Survey_Positioning_SystemHistory]    Script Date: 09/04/2026 16:39:55 ******/
CREATE CLUSTERED INDEX [ix_Survey_Positioning_SystemHistory] ON [dbo].[Survey_Positioning_SystemHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Survey_Positioning_System]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Survey_Positioning_System](
	[SurveyPosSystemId] [int] IDENTITY(1,1) NOT NULL,
	[DatasetSurveyPlatformId] [int] NOT NULL,
	[SurveyPosSystem] [varchar](200) NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_Survey_Positioning_System] PRIMARY KEY CLUSTERED 
(
	[SurveyPosSystemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Survey_Positioning_SystemHistory])
)
GO
/****** Object:  Table [dbo].[Dataset_Bathy_Gridding_MethodHistory]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Bathy_Gridding_MethodHistory](
	[DatasetBathyGriddingMethodId] [bigint] NOT NULL,
	[BathyGriddingMethodId] [int] NOT NULL,
	[OtherBathyGriddingMethod] [varchar](200) NULL,
	[BathyGriddingResolution] [decimal](10, 2) NOT NULL,
	[DataInterpolatedInd] [bit] NOT NULL,
	[DataInterpolatedDtls] [varchar](400) NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[PeriodEnd] [datetime2](7) NOT NULL,
	[PeriodStart] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_Dataset_Bathy_Gridding_MethodHistory]    Script Date: 09/04/2026 16:39:55 ******/
CREATE CLUSTERED INDEX [ix_Dataset_Bathy_Gridding_MethodHistory] ON [dbo].[Dataset_Bathy_Gridding_MethodHistory]
(
	[PeriodEnd] ASC,
	[PeriodStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dataset_Bathy_Gridding_Method]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_Bathy_Gridding_Method](
	[DatasetBathyGriddingMethodId] [bigint] IDENTITY(1,1) NOT NULL,
	[BathyGriddingMethodId] [int] NOT NULL,
	[OtherBathyGriddingMethod] [varchar](200) NULL,
	[BathyGriddingResolution] [decimal](10, 2) NOT NULL,
	[DataInterpolatedInd] [bit] NOT NULL,
	[DataInterpolatedDtls] [varchar](400) NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[DatasetId] [uniqueidentifier] NOT NULL,
	[PeriodEnd] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[PeriodStart] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_Dataset_Bathy_Gridding_Method] PRIMARY KEY CLUSTERED 
(
	[DatasetBathyGriddingMethodId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([PeriodStart], [PeriodEnd])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Dataset_Bathy_Gridding_MethodHistory])
)
GO
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__EFMigrationsHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Bathy_Data_Collection_Purpose]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bathy_Data_Collection_Purpose](
	[BathyDataCollPurposeId] [int] IDENTITY(1,1) NOT NULL,
	[BathyDataCollPurpose] [varchar](100) NOT NULL,
	[DeprecatedInd] [bit] NULL,
	[DisplayOrder] [smallint] NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
 CONSTRAINT [PK_Bathy_Data_Collection_Purpose] PRIMARY KEY CLUSTERED 
(
	[BathyDataCollPurposeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Bathy_Gridding_Method]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bathy_Gridding_Method](
	[BathyGriddingMethodId] [int] IDENTITY(1,1) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[BathyGriddingMethod] [varchar](100) NOT NULL,
	[DeprecatedInd] [bit] NULL,
	[DisplayOrder] [smallint] NULL,
 CONSTRAINT [PK_Bathy_Gridding_Method] PRIMARY KEY CLUSTERED 
(
	[BathyGriddingMethodId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Bathy_Survey_Category]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bathy_Survey_Category](
	[BathySurveyCategoryId] [int] IDENTITY(1,1) NOT NULL,
	[BathySurveyCategory] [varchar](100) NOT NULL,
	[DeprecatedInd] [bit] NULL,
	[DisplayOrder] [smallint] NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
 CONSTRAINT [PK_Bathy_Survey_Category] PRIMARY KEY CLUSTERED 
(
	[BathySurveyCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Bathy_Survey_Method]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bathy_Survey_Method](
	[BathySurveyMthdId] [int] IDENTITY(1,1) NOT NULL,
	[BathySurveyMthd] [varchar](100) NOT NULL,
	[DeprecatedInd] [bit] NULL,
	[DisplayOrder] [smallint] NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
 CONSTRAINT [PK_Bathy_Survey_Method] PRIMARY KEY CLUSTERED 
(
	[BathySurveyMthdId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Bathy_Survey_Standard]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bathy_Survey_Standard](
	[BathySrvyStndId] [int] IDENTITY(1,1) NOT NULL,
	[BathySrvyStnd] [varchar](100) NOT NULL,
	[DeprecatedInd] [bit] NULL,
	[DisplayOrder] [smallint] NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
 CONSTRAINT [PK_Bathy_Survey_Standard] PRIMARY KEY CLUSTERED 
(
	[BathySrvyStndId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Coordinate_Type]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Coordinate_Type](
	[CoordinateTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CoordinateType] [varchar](100) NOT NULL,
	[DeprecatedInd] [bit] NULL,
	[DisplayOrder] [smallint] NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
 CONSTRAINT [PK_Coordinate_Type] PRIMARY KEY CLUSTERED 
(
	[CoordinateTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[File_Sharing_Method]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[File_Sharing_Method](
	[FileSharingMethodId] [int] IDENTITY(1,1) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[FileSharingMethod] [varchar](50) NOT NULL,
	[DeprecatedInd] [bit] NULL,
	[DisplayOrder] [smallint] NULL,
	[DirectUploadViaUDUInd] [bit] NOT NULL,
	[FileSharingDesc] [varchar](150) NOT NULL,
	[InitialDatasetStatusId] [int] NOT NULL,
 CONSTRAINT [PK_File_Sharing_Method] PRIMARY KEY CLUSTERED 
(
	[FileSharingMethodId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[H275_Horizontal_Datum]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[H275_Horizontal_Datum](
	[H275HorizontalDatumId] [int] IDENTITY(1,1) NOT NULL,
	[H275HorizontalDatumName] [varchar](100) NOT NULL,
	[DeprecatedInd] [bit] NULL,
	[DisplayOrder] [smallint] NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
 CONSTRAINT [PK_H275_Horizontal_Datum] PRIMARY KEY CLUSTERED 
(
	[H275HorizontalDatumId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[H275_Vertical_Datum]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[H275_Vertical_Datum](
	[H275VerticalDatumId] [int] IDENTITY(1,1) NOT NULL,
	[H275VerticalDatumName] [varchar](100) NOT NULL,
	[DeprecatedInd] [bit] NULL,
	[DisplayOrder] [smallint] NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
 CONSTRAINT [PK_H275_Vertical_Datum] PRIMARY KEY CLUSTERED 
(
	[H275VerticalDatumId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Metadata_DataFile_Status]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Metadata_DataFile_Status](
	[DataFileStatusId] [int] IDENTITY(1,1) NOT NULL,
	[DataFileStatusName] [varchar](50) NOT NULL,
	[Deprecated] [bit] NULL,
	[DisplayOrder] [smallint] NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
 CONSTRAINT [PK_Metadata_DataFile_Status] PRIMARY KEY CLUSTERED 
(
	[DataFileStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Metadata_Dataset_Status]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Metadata_Dataset_Status](
	[DatasetStatusId] [int] IDENTITY(1,1) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[DatasetStatusName] [varchar](50) NOT NULL,
	[DeprecatedInd] [bit] NULL,
	[DisplayOrder] [smallint] NULL,
 CONSTRAINT [PK_Metadata_Dataset_Status] PRIMARY KEY CLUSTERED 
(
	[DatasetStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Metadata_Party]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Metadata_Party](
	[PartyId] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](160) NULL,
	[EmailAddress] [varchar](100) NULL,
	[D365ExternalSystemId] [varchar](255) NULL,
	[AbbreviatedName] [varchar](160) NULL,
	[TelephoneNumber] [varchar](50) NULL,
	[CreatedBy] [varchar](100) NULL,
	[CreatedTS] [datetime2](7) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
 CONSTRAINT [PK_Metadata_Party] PRIMARY KEY CLUSTERED 
(
	[PartyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sounding_To_Datum_Reduction_Method]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sounding_To_Datum_Reduction_Method](
	[SndingToDatumRdctMthdId] [int] IDENTITY(1,1) NOT NULL,
	[SndingToDatumRdctMthd] [varchar](100) NOT NULL,
	[DeprecatedInd] [bit] NULL,
	[DisplayOrder] [smallint] NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
 CONSTRAINT [PK_Sounding_To_Datum_Reduction_Method] PRIMARY KEY CLUSTERED 
(
	[SndingToDatumRdctMthdId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Source_Data_Permission]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Source_Data_Permission](
	[SourceDataPermId] [int] IDENTITY(1,1) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[UpdatedTS] [datetime2](7) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[SourceDataPermDesc] [varchar](500) NOT NULL,
	[DeprecatedInd] [bit] NULL,
	[DisplayOrder] [smallint] NULL,
 CONSTRAINT [PK_Source_Data_Permission] PRIMARY KEY CLUSTERED 
(
	[SourceDataPermId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Source_Data_Permission_Default]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Source_Data_Permission_Default](
	[SourceDataPermDefaultsId] [int] IDENTITY(1,1) NOT NULL,
	[SourceDataPermId] [int] NOT NULL,
	[D365AccountTypeCode] [varchar](160) NOT NULL,
	[IsDACPartyInd] [bit] NULL,
	[DefaultDatasetSrceDataPermInd] [bit] NOT NULL,
	[IsEnabledOnUI] [bit] NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Source_Data_Permission_Default] PRIMARY KEY CLUSTERED 
(
	[SourceDataPermDefaultsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[XYZ_File_XY_Format]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[XYZ_File_XY_Format](
	[XYZFileXYFormatId] [int] IDENTITY(1,1) NOT NULL,
	[XYZFileXYFormat] [varchar](50) NOT NULL,
	[DeprecatedInd] [bit] NULL,
	[DisplayOrder] [smallint] NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
 CONSTRAINT [PK_XYZ_File_XY_Format] PRIMARY KEY CLUSTERED 
(
	[XYZFileXYFormatId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[XYZ_File_Z_Format]    Script Date: 09/04/2026 16:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[XYZ_File_Z_Format](
	[XYZFileZFormatId] [int] IDENTITY(1,1) NOT NULL,
	[XYZFileZFormat] [varchar](100) NOT NULL,
	[DeprecatedInd] [bit] NULL,
	[DisplayOrder] [smallint] NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[CreatedTS] [datetime2](7) NOT NULL,
	[UpdatedBy] [varchar](100) NULL,
	[UpdatedTS] [datetime2](7) NULL,
 CONSTRAINT [PK_XYZ_File_Z_Format] PRIMARY KEY CLUSTERED 
(
	[XYZFileZFormatId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_D365_Parties_Ref_D365AccountTypeCode_IsDACPartyInd]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_D365_Parties_Ref_D365AccountTypeCode_IsDACPartyInd] ON [dbo].[D365_Parties_Ref]
(
	[D365AccountTypeCode] ASC,
	[IsDACPartyInd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_D365_Parties_Ref_Name]    Script Date: 09/04/2026 16:39:55 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_D365_Parties_Ref_Name] ON [dbo].[D365_Parties_Ref]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Bathy_Data_Collection_Purpose_BathyDataCollPurposeId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_Bathy_Data_Collection_Purpose_BathyDataCollPurposeId] ON [dbo].[Dataset_Bathy_Data_Collection_Purpose]
(
	[BathyDataCollPurposeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Bathy_Data_Collection_Purpose_DatasetId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Dataset_Bathy_Data_Collection_Purpose_DatasetId] ON [dbo].[Dataset_Bathy_Data_Collection_Purpose]
(
	[DatasetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Bathy_Gridding_Method_BathyGriddingMethodId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_Bathy_Gridding_Method_BathyGriddingMethodId] ON [dbo].[Dataset_Bathy_Gridding_Method]
(
	[BathyGriddingMethodId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Bathy_Gridding_Method_DatasetId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Dataset_Bathy_Gridding_Method_DatasetId] ON [dbo].[Dataset_Bathy_Gridding_Method]
(
	[DatasetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Bathy_Survey_Category_BathySurveyCategoryId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_Bathy_Survey_Category_BathySurveyCategoryId] ON [dbo].[Dataset_Bathy_Survey_Category]
(
	[BathySurveyCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Bathy_Survey_Category_DatasetId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Dataset_Bathy_Survey_Category_DatasetId] ON [dbo].[Dataset_Bathy_Survey_Category]
(
	[DatasetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Bathy_Survey_Method_BathySurveyMthdId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_Bathy_Survey_Method_BathySurveyMthdId] ON [dbo].[Dataset_Bathy_Survey_Method]
(
	[BathySurveyMthdId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Bathy_Survey_Method_DatasetId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_Bathy_Survey_Method_DatasetId] ON [dbo].[Dataset_Bathy_Survey_Method]
(
	[DatasetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Bathy_Survey_Standard_BathySrvyStndId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_Bathy_Survey_Standard_BathySrvyStndId] ON [dbo].[Dataset_Bathy_Survey_Standard]
(
	[BathySrvyStndId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Bathy_Survey_Standard_DatasetId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Dataset_Bathy_Survey_Standard_DatasetId] ON [dbo].[Dataset_Bathy_Survey_Standard]
(
	[DatasetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Coordinate_Type_CoordinateTypeId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_Coordinate_Type_CoordinateTypeId] ON [dbo].[Dataset_Coordinate_Type]
(
	[CoordinateTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Coordinate_Type_DatasetId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Dataset_Coordinate_Type_DatasetId] ON [dbo].[Dataset_Coordinate_Type]
(
	[DatasetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_H275_Horizontal_Datum_DatasetId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Dataset_H275_Horizontal_Datum_DatasetId] ON [dbo].[Dataset_H275_Horizontal_Datum]
(
	[DatasetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_H275_Horizontal_Datum_H275HorizontalDatumId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_H275_Horizontal_Datum_H275HorizontalDatumId] ON [dbo].[Dataset_H275_Horizontal_Datum]
(
	[H275HorizontalDatumId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_H275_Vertical_Datum_DatasetId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Dataset_H275_Vertical_Datum_DatasetId] ON [dbo].[Dataset_H275_Vertical_Datum]
(
	[DatasetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_H275_Vertical_Datum_H275VerticalDatumId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_H275_Vertical_Datum_H275VerticalDatumId] ON [dbo].[Dataset_H275_Vertical_Datum]
(
	[H275VerticalDatumId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Projection_DatasetId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Dataset_Projection_DatasetId] ON [dbo].[Dataset_Projection]
(
	[DatasetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Sounding_To_Datum_Reduction_Method_DatasetId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Dataset_Sounding_To_Datum_Reduction_Method_DatasetId] ON [dbo].[Dataset_Sounding_To_Datum_Reduction_Method]
(
	[DatasetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Sounding_To_Datum_Reduction_Method_SndingToDatumRdctMthdId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_Sounding_To_Datum_Reduction_Method_SndingToDatumRdctMthdId] ON [dbo].[Dataset_Sounding_To_Datum_Reduction_Method]
(
	[SndingToDatumRdctMthdId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Source_Data_Permission_DatasetId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_Source_Data_Permission_DatasetId] ON [dbo].[Dataset_Source_Data_Permission]
(
	[DatasetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Source_Data_Permission_SourceDataPermId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_Source_Data_Permission_SourceDataPermId] ON [dbo].[Dataset_Source_Data_Permission]
(
	[SourceDataPermId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Survey_Platform_DatasetId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_Survey_Platform_DatasetId] ON [dbo].[Dataset_Survey_Platform]
(
	[DatasetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_XYZ_Format_DatasetId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_XYZ_Format_DatasetId] ON [dbo].[Dataset_XYZ_Format]
(
	[DatasetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_XYZ_Format_XYZFileXFormatId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_XYZ_Format_XYZFileXFormatId] ON [dbo].[Dataset_XYZ_Format]
(
	[XYZFileXFormatId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_XYZ_Format_XYZFileYFormatId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_XYZ_Format_XYZFileYFormatId] ON [dbo].[Dataset_XYZ_Format]
(
	[XYZFileYFormatId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_XYZ_Format_XYZFileZFormatId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_XYZ_Format_XYZFileZFormatId] ON [dbo].[Dataset_XYZ_Format]
(
	[XYZFileZFormatId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_File_Sharing_Method_InitialDatasetStatusId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_File_Sharing_Method_InitialDatasetStatusId] ON [dbo].[File_Sharing_Method]
(
	[InitialDatasetStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Instrument_DatasetSurveyPlatformId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Instrument_DatasetSurveyPlatformId] ON [dbo].[Instrument]
(
	[DatasetSurveyPlatformId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Metadata_Datafile_DataFileStatusId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Metadata_Datafile_DataFileStatusId] ON [dbo].[Metadata_Datafile]
(
	[DataFileStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Metadata_Datafile_DatasetId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Metadata_Datafile_DatasetId] ON [dbo].[Metadata_Datafile]
(
	[Dataset_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_DeletedCreated_Ascending]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_DeletedCreated_Ascending] ON [dbo].[Metadata_Dataset]
(
	[DeletedDatasetInd] ASC,
	[CreatedTS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Metadata_Dataset_DatasetStatusId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Metadata_Dataset_DatasetStatusId] ON [dbo].[Metadata_Dataset]
(
	[DatasetStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Metadata_Dataset_FileSharingMethodId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Metadata_Dataset_FileSharingMethodId] ON [dbo].[Metadata_Dataset]
(
	[FileSharingMethodId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IXU_ResourceTitleAndDeletedTS]    Script Date: 09/04/2026 16:39:55 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IXU_ResourceTitleAndDeletedTS] ON [dbo].[Metadata_Dataset]
(
	[ResourceTitle] ASC,
	[DeletedTS] ASC
)
WHERE [ResourceTitle] IS NOT NULL
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Dataset_Responsible_Party_DatasetId_RoleTypeId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Dataset_Responsible_Party_DatasetId_RoleTypeId] ON [dbo].[Metadata_Dataset_Responsible_Party]
(
	[DatasetId] ASC,
	[RespPartyRoleTypeId] ASC
)
INCLUDE([PartyId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Metadata_Dataset_Responsible_Party_PartyId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Metadata_Dataset_Responsible_Party_PartyId] ON [dbo].[Metadata_Dataset_Responsible_Party]
(
	[PartyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Metadata_Party_D365ExternalSystemId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Metadata_Party_D365ExternalSystemId] ON [dbo].[Metadata_Party]
(
	[D365ExternalSystemId] ASC
)
WHERE ([D365ExternalSystemId] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Metadata_Party_EmailAddress]    Script Date: 09/04/2026 16:39:55 ******/
CREATE NONCLUSTERED INDEX [IX_Metadata_Party_EmailAddress] ON [dbo].[Metadata_Party]
(
	[EmailAddress] ASC
)
WHERE ([EmailAddress] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Source_Data_Permission_Default_SourceDataPermId_D365AccountTypeCode_IsDACPartyInd]    Script Date: 09/04/2026 16:39:55 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Source_Data_Permission_Default_SourceDataPermId_D365AccountTypeCode_IsDACPartyInd] ON [dbo].[Source_Data_Permission_Default]
(
	[SourceDataPermId] ASC,
	[D365AccountTypeCode] ASC,
	[IsDACPartyInd] ASC
)
WHERE ([IsDACPartyInd] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Survey_Positioning_System_DatasetSurveyPlatformId]    Script Date: 09/04/2026 16:39:55 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Survey_Positioning_System_DatasetSurveyPlatformId] ON [dbo].[Survey_Positioning_System]
(
	[DatasetSurveyPlatformId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Bathy_Data_Collection_Purpose] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Bathy_Gridding_Method] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Bathy_Survey_Category] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Bathy_Survey_Method] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Bathy_Survey_Standard] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Coordinate_Type] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[D365_Parties_Ref] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[D365_Parties_Ref] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[D365_Parties_Ref] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[D365_Parties_Ref] ADD  DEFAULT ('') FOR [D365AccountTypeCode]
GO
ALTER TABLE [dbo].[D365_Parties_Ref] ADD  DEFAULT (CONVERT([bit],(0))) FOR [IsDACPartyInd]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Data_Collection_Purpose] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Data_Collection_Purpose] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Data_Collection_Purpose] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Gridding_Method] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Gridding_Method] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Gridding_Method] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Category] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Category] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Category] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Method] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Method] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Method] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Standard] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Standard] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Standard] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[Dataset_Coordinate_Type] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Dataset_Coordinate_Type] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Dataset_Coordinate_Type] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[Dataset_H275_Horizontal_Datum] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Dataset_H275_Horizontal_Datum] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Dataset_H275_Horizontal_Datum] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[Dataset_H275_Vertical_Datum] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Dataset_H275_Vertical_Datum] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Dataset_H275_Vertical_Datum] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[Dataset_Projection] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Dataset_Projection] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Dataset_Projection] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[Dataset_Sounding_To_Datum_Reduction_Method] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Dataset_Sounding_To_Datum_Reduction_Method] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Dataset_Sounding_To_Datum_Reduction_Method] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[Dataset_Source_Data_Permission] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Dataset_Source_Data_Permission] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Dataset_Source_Data_Permission] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[Dataset_Survey_Platform] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Dataset_Survey_Platform] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Dataset_Survey_Platform] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[Dataset_XYZ_Format] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Dataset_XYZ_Format] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Dataset_XYZ_Format] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[File_Sharing_Method] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[File_Sharing_Method] ADD  DEFAULT (CONVERT([bit],(0))) FOR [DirectUploadViaUDUInd]
GO
ALTER TABLE [dbo].[File_Sharing_Method] ADD  DEFAULT ('') FOR [FileSharingDesc]
GO
ALTER TABLE [dbo].[File_Sharing_Method] ADD  DEFAULT ((0)) FOR [InitialDatasetStatusId]
GO
ALTER TABLE [dbo].[H275_Horizontal_Datum] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[H275_Vertical_Datum] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Instrument] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Instrument] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Instrument] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[Metadata_Datafile] ADD  DEFAULT (newid()) FOR [uu_id]
GO
ALTER TABLE [dbo].[Metadata_Datafile] ADD  DEFAULT ('Unknown') FOR [dataformatversion]
GO
ALTER TABLE [dbo].[Metadata_Datafile] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Metadata_Datafile] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[Metadata_DataFile_Status] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Metadata_Dataset] ADD  DEFAULT ('OSD') FOR [Dataset_Type]
GO
ALTER TABLE [dbo].[Metadata_Dataset] ADD  DEFAULT (CONVERT([bigint],(17))) FOR [FeatureId]
GO
ALTER TABLE [dbo].[Metadata_Dataset] ADD  DEFAULT (CONVERT([bigint],(4))) FOR [MetadataStandardId]
GO
ALTER TABLE [dbo].[Metadata_Dataset] ADD  DEFAULT (CONVERT([bigint],(1))) FOR [ResourceTypeId]
GO
ALTER TABLE [dbo].[Metadata_Dataset] ADD  DEFAULT (getutcdate()) FOR [LastModifiedTimestamp]
GO
ALTER TABLE [dbo].[Metadata_Dataset] ADD  DEFAULT ((0)) FOR [DatasetStatusId]
GO
ALTER TABLE [dbo].[Metadata_Dataset] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Metadata_Dataset] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[Metadata_Dataset] ADD  DEFAULT (CONVERT([bit],(0))) FOR [DeletedDatasetInd]
GO
ALTER TABLE [dbo].[Metadata_Dataset_Responsible_Party] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Metadata_Dataset_Responsible_Party] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[Metadata_Dataset_Status] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Sounding_To_Datum_Reduction_Method] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Source_Data_Permission] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Source_Data_Permission_Default] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Survey_Positioning_System] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Survey_Positioning_System] ADD  DEFAULT ('9999-12-31T23:59:59.9999999') FOR [PeriodEnd]
GO
ALTER TABLE [dbo].[Survey_Positioning_System] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [PeriodStart]
GO
ALTER TABLE [dbo].[XYZ_File_XY_Format] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[XYZ_File_Z_Format] ADD  DEFAULT (getutcdate()) FOR [CreatedTS]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Data_Collection_Purpose]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Bathy_Data_Collection_Purpose_Bathy_Data_Collection_Purpose] FOREIGN KEY([BathyDataCollPurposeId])
REFERENCES [dbo].[Bathy_Data_Collection_Purpose] ([BathyDataCollPurposeId])
GO
ALTER TABLE [dbo].[Dataset_Bathy_Data_Collection_Purpose] CHECK CONSTRAINT [FK_Dataset_Bathy_Data_Collection_Purpose_Bathy_Data_Collection_Purpose]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Data_Collection_Purpose]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Bathy_Data_Collection_Purpose_Metadata_Dataset] FOREIGN KEY([DatasetId])
REFERENCES [dbo].[Metadata_Dataset] ([DatasetId])
GO
ALTER TABLE [dbo].[Dataset_Bathy_Data_Collection_Purpose] CHECK CONSTRAINT [FK_Dataset_Bathy_Data_Collection_Purpose_Metadata_Dataset]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Gridding_Method]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Bathy_Gridding_Method_Bathy_Gridding_Method] FOREIGN KEY([BathyGriddingMethodId])
REFERENCES [dbo].[Bathy_Gridding_Method] ([BathyGriddingMethodId])
GO
ALTER TABLE [dbo].[Dataset_Bathy_Gridding_Method] CHECK CONSTRAINT [FK_Dataset_Bathy_Gridding_Method_Bathy_Gridding_Method]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Gridding_Method]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Bathy_Gridding_Method_Metadata_Dataset] FOREIGN KEY([DatasetId])
REFERENCES [dbo].[Metadata_Dataset] ([DatasetId])
GO
ALTER TABLE [dbo].[Dataset_Bathy_Gridding_Method] CHECK CONSTRAINT [FK_Dataset_Bathy_Gridding_Method_Metadata_Dataset]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Category]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Bathy_Survey_category_Bathy_Survey_Categor] FOREIGN KEY([BathySurveyCategoryId])
REFERENCES [dbo].[Bathy_Survey_Category] ([BathySurveyCategoryId])
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Category] CHECK CONSTRAINT [FK_Dataset_Bathy_Survey_category_Bathy_Survey_Categor]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Category]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Bathy_Survey_category_Metadata_Dataset] FOREIGN KEY([DatasetId])
REFERENCES [dbo].[Metadata_Dataset] ([DatasetId])
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Category] CHECK CONSTRAINT [FK_Dataset_Bathy_Survey_category_Metadata_Dataset]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Method]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Bathy_Survey_Method_Bathy_Survey_Method] FOREIGN KEY([BathySurveyMthdId])
REFERENCES [dbo].[Bathy_Survey_Method] ([BathySurveyMthdId])
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Method] CHECK CONSTRAINT [FK_Dataset_Bathy_Survey_Method_Bathy_Survey_Method]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Method]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Bathy_Survey_Method_Metadata_Dataset] FOREIGN KEY([DatasetId])
REFERENCES [dbo].[Metadata_Dataset] ([DatasetId])
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Method] CHECK CONSTRAINT [FK_Dataset_Bathy_Survey_Method_Metadata_Dataset]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Standard]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Bathy_Survey_Standard_Bathy_Survey_Standard] FOREIGN KEY([BathySrvyStndId])
REFERENCES [dbo].[Bathy_Survey_Standard] ([BathySrvyStndId])
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Standard] CHECK CONSTRAINT [FK_Dataset_Bathy_Survey_Standard_Bathy_Survey_Standard]
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Standard]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Bathy_Survey_Standard_Metadata_Dataset] FOREIGN KEY([DatasetId])
REFERENCES [dbo].[Metadata_Dataset] ([DatasetId])
GO
ALTER TABLE [dbo].[Dataset_Bathy_Survey_Standard] CHECK CONSTRAINT [FK_Dataset_Bathy_Survey_Standard_Metadata_Dataset]
GO
ALTER TABLE [dbo].[Dataset_Coordinate_Type]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Coordinate_Type_Coordinate_Type] FOREIGN KEY([CoordinateTypeId])
REFERENCES [dbo].[Coordinate_Type] ([CoordinateTypeId])
GO
ALTER TABLE [dbo].[Dataset_Coordinate_Type] CHECK CONSTRAINT [FK_Dataset_Coordinate_Type_Coordinate_Type]
GO
ALTER TABLE [dbo].[Dataset_Coordinate_Type]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Coordinate_Type_metadata_dataset] FOREIGN KEY([DatasetId])
REFERENCES [dbo].[Metadata_Dataset] ([DatasetId])
GO
ALTER TABLE [dbo].[Dataset_Coordinate_Type] CHECK CONSTRAINT [FK_Dataset_Coordinate_Type_metadata_dataset]
GO
ALTER TABLE [dbo].[Dataset_H275_Horizontal_Datum]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_H275_Horizontal_Datum_H275_Horizontal_Datum] FOREIGN KEY([H275HorizontalDatumId])
REFERENCES [dbo].[H275_Horizontal_Datum] ([H275HorizontalDatumId])
GO
ALTER TABLE [dbo].[Dataset_H275_Horizontal_Datum] CHECK CONSTRAINT [FK_Dataset_H275_Horizontal_Datum_H275_Horizontal_Datum]
GO
ALTER TABLE [dbo].[Dataset_H275_Horizontal_Datum]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_H275_Horizontal_Datum_Metadata_Dataset] FOREIGN KEY([DatasetId])
REFERENCES [dbo].[Metadata_Dataset] ([DatasetId])
GO
ALTER TABLE [dbo].[Dataset_H275_Horizontal_Datum] CHECK CONSTRAINT [FK_Dataset_H275_Horizontal_Datum_Metadata_Dataset]
GO
ALTER TABLE [dbo].[Dataset_H275_Vertical_Datum]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_H275_Vertical_Datum_H275_Vertical_Datum] FOREIGN KEY([H275VerticalDatumId])
REFERENCES [dbo].[H275_Vertical_Datum] ([H275VerticalDatumId])
GO
ALTER TABLE [dbo].[Dataset_H275_Vertical_Datum] CHECK CONSTRAINT [FK_Dataset_H275_Vertical_Datum_H275_Vertical_Datum]
GO
ALTER TABLE [dbo].[Dataset_H275_Vertical_Datum]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_H275_Vertical_Datum_Metadata_Dataset] FOREIGN KEY([DatasetId])
REFERENCES [dbo].[Metadata_Dataset] ([DatasetId])
GO
ALTER TABLE [dbo].[Dataset_H275_Vertical_Datum] CHECK CONSTRAINT [FK_Dataset_H275_Vertical_Datum_Metadata_Dataset]
GO
ALTER TABLE [dbo].[Dataset_Projection]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Projection_Metadata_Dataset] FOREIGN KEY([DatasetId])
REFERENCES [dbo].[Metadata_Dataset] ([DatasetId])
GO
ALTER TABLE [dbo].[Dataset_Projection] CHECK CONSTRAINT [FK_Dataset_Projection_Metadata_Dataset]
GO
ALTER TABLE [dbo].[Dataset_Sounding_To_Datum_Reduction_Method]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Sounding_To_Datum_Reduction_Method_Metadata_Dataset] FOREIGN KEY([DatasetId])
REFERENCES [dbo].[Metadata_Dataset] ([DatasetId])
GO
ALTER TABLE [dbo].[Dataset_Sounding_To_Datum_Reduction_Method] CHECK CONSTRAINT [FK_Dataset_Sounding_To_Datum_Reduction_Method_Metadata_Dataset]
GO
ALTER TABLE [dbo].[Dataset_Sounding_To_Datum_Reduction_Method]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Sounding_To_Datum_Reduction_Method_Sounding_To_Datum_Reduction_Method] FOREIGN KEY([SndingToDatumRdctMthdId])
REFERENCES [dbo].[Sounding_To_Datum_Reduction_Method] ([SndingToDatumRdctMthdId])
GO
ALTER TABLE [dbo].[Dataset_Sounding_To_Datum_Reduction_Method] CHECK CONSTRAINT [FK_Dataset_Sounding_To_Datum_Reduction_Method_Sounding_To_Datum_Reduction_Method]
GO
ALTER TABLE [dbo].[Dataset_Source_Data_Permission]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Source_Data_Permission_Metadata_Dataset] FOREIGN KEY([DatasetId])
REFERENCES [dbo].[Metadata_Dataset] ([DatasetId])
GO
ALTER TABLE [dbo].[Dataset_Source_Data_Permission] CHECK CONSTRAINT [FK_Dataset_Source_Data_Permission_Metadata_Dataset]
GO
ALTER TABLE [dbo].[Dataset_Source_Data_Permission]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Source_Data_Permission_Source_Data_Permission] FOREIGN KEY([SourceDataPermId])
REFERENCES [dbo].[Source_Data_Permission] ([SourceDataPermId])
GO
ALTER TABLE [dbo].[Dataset_Source_Data_Permission] CHECK CONSTRAINT [FK_Dataset_Source_Data_Permission_Source_Data_Permission]
GO
ALTER TABLE [dbo].[Dataset_Survey_Platform]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Survey_Platform_Metadata_Dataset] FOREIGN KEY([DatasetId])
REFERENCES [dbo].[Metadata_Dataset] ([DatasetId])
GO
ALTER TABLE [dbo].[Dataset_Survey_Platform] CHECK CONSTRAINT [FK_Dataset_Survey_Platform_Metadata_Dataset]
GO
ALTER TABLE [dbo].[Dataset_XYZ_Format]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_XYZ_Format_metadata_dataset] FOREIGN KEY([DatasetId])
REFERENCES [dbo].[Metadata_Dataset] ([DatasetId])
GO
ALTER TABLE [dbo].[Dataset_XYZ_Format] CHECK CONSTRAINT [FK_Dataset_XYZ_Format_metadata_dataset]
GO
ALTER TABLE [dbo].[Dataset_XYZ_Format]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_XYZ_Format_XYZFileXYFormat] FOREIGN KEY([XYZFileXFormatId])
REFERENCES [dbo].[XYZ_File_XY_Format] ([XYZFileXYFormatId])
GO
ALTER TABLE [dbo].[Dataset_XYZ_Format] CHECK CONSTRAINT [FK_Dataset_XYZ_Format_XYZFileXYFormat]
GO
ALTER TABLE [dbo].[Dataset_XYZ_Format]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_XYZ_Format_XYZFileXYFormat_02] FOREIGN KEY([XYZFileYFormatId])
REFERENCES [dbo].[XYZ_File_XY_Format] ([XYZFileXYFormatId])
GO
ALTER TABLE [dbo].[Dataset_XYZ_Format] CHECK CONSTRAINT [FK_Dataset_XYZ_Format_XYZFileXYFormat_02]
GO
ALTER TABLE [dbo].[Dataset_XYZ_Format]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_XYZ_Format_XYZFileZFormat] FOREIGN KEY([XYZFileZFormatId])
REFERENCES [dbo].[XYZ_File_Z_Format] ([XYZFileZFormatId])
GO
ALTER TABLE [dbo].[Dataset_XYZ_Format] CHECK CONSTRAINT [FK_Dataset_XYZ_Format_XYZFileZFormat]
GO
ALTER TABLE [dbo].[File_Sharing_Method]  WITH CHECK ADD  CONSTRAINT [FK_Initial_Dataset_Status_File_Sharing_Method] FOREIGN KEY([InitialDatasetStatusId])
REFERENCES [dbo].[Metadata_Dataset_Status] ([DatasetStatusId])
GO
ALTER TABLE [dbo].[File_Sharing_Method] CHECK CONSTRAINT [FK_Initial_Dataset_Status_File_Sharing_Method]
GO
ALTER TABLE [dbo].[Instrument]  WITH CHECK ADD  CONSTRAINT [FK_Instrument_Dataset_Survey_Platform] FOREIGN KEY([DatasetSurveyPlatformId])
REFERENCES [dbo].[Dataset_Survey_Platform] ([DatasetSurveyPlatformId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Instrument] CHECK CONSTRAINT [FK_Instrument_Dataset_Survey_Platform]
GO
ALTER TABLE [dbo].[Metadata_Datafile]  WITH CHECK ADD  CONSTRAINT [FK_metadata_datafile_DataFile_Status] FOREIGN KEY([DataFileStatusId])
REFERENCES [dbo].[Metadata_DataFile_Status] ([DataFileStatusId])
GO
ALTER TABLE [dbo].[Metadata_Datafile] CHECK CONSTRAINT [FK_metadata_datafile_DataFile_Status]
GO
ALTER TABLE [dbo].[Metadata_Datafile]  WITH CHECK ADD  CONSTRAINT [FK_metadata_datafile_metadata_dataset] FOREIGN KEY([Dataset_Id])
REFERENCES [dbo].[Metadata_Dataset] ([DatasetId])
GO
ALTER TABLE [dbo].[Metadata_Datafile] CHECK CONSTRAINT [FK_metadata_datafile_metadata_dataset]
GO
ALTER TABLE [dbo].[Metadata_Dataset]  WITH CHECK ADD  CONSTRAINT [FK_Dataset_Status_Metadata_Dataset] FOREIGN KEY([DatasetStatusId])
REFERENCES [dbo].[Metadata_Dataset_Status] ([DatasetStatusId])
GO
ALTER TABLE [dbo].[Metadata_Dataset] CHECK CONSTRAINT [FK_Dataset_Status_Metadata_Dataset]
GO
ALTER TABLE [dbo].[Metadata_Dataset]  WITH CHECK ADD  CONSTRAINT [FK_File_Sharing_Method_Metadata_Dataset] FOREIGN KEY([FileSharingMethodId])
REFERENCES [dbo].[File_Sharing_Method] ([FileSharingMethodId])
GO
ALTER TABLE [dbo].[Metadata_Dataset] CHECK CONSTRAINT [FK_File_Sharing_Method_Metadata_Dataset]
GO
ALTER TABLE [dbo].[Metadata_Dataset_Responsible_Party]  WITH CHECK ADD  CONSTRAINT [FK_metadata_dataset_responsible_party_metadata_dataset] FOREIGN KEY([DatasetId])
REFERENCES [dbo].[Metadata_Dataset] ([DatasetId])
GO
ALTER TABLE [dbo].[Metadata_Dataset_Responsible_Party] CHECK CONSTRAINT [FK_metadata_dataset_responsible_party_metadata_dataset]
GO
ALTER TABLE [dbo].[Metadata_Dataset_Responsible_Party]  WITH CHECK ADD  CONSTRAINT [FK_metadata_dataset_responsible_party_metadata_party] FOREIGN KEY([PartyId])
REFERENCES [dbo].[Metadata_Party] ([PartyId])
GO
ALTER TABLE [dbo].[Metadata_Dataset_Responsible_Party] CHECK CONSTRAINT [FK_metadata_dataset_responsible_party_metadata_party]
GO
ALTER TABLE [dbo].[Source_Data_Permission_Default]  WITH CHECK ADD  CONSTRAINT [FK_Source_Data_Permission_Default_Source_Data_Permission_SourceDataPermId] FOREIGN KEY([SourceDataPermId])
REFERENCES [dbo].[Source_Data_Permission] ([SourceDataPermId])
GO
ALTER TABLE [dbo].[Source_Data_Permission_Default] CHECK CONSTRAINT [FK_Source_Data_Permission_Default_Source_Data_Permission_SourceDataPermId]
GO
ALTER TABLE [dbo].[Survey_Positioning_System]  WITH CHECK ADD  CONSTRAINT [FK_Survey_Positioning_System_Dataset_Survey_Platform] FOREIGN KEY([DatasetSurveyPlatformId])
REFERENCES [dbo].[Dataset_Survey_Platform] ([DatasetSurveyPlatformId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Survey_Positioning_System] CHECK CONSTRAINT [FK_Survey_Positioning_System_Dataset_Survey_Platform]
GO
