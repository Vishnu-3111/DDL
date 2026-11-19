CREATE TABLE ThisTable
(FirstName CHAR, LastName CHAR);

CREATE TABLE MyTable
(FirstName CHAR, 
	LastName CHAR,  
	DateOfBirth DATETIME,
	CONSTRAINT MyTableConstraint UNIQUE (FirstName, LastName, DateOfBirth)
);

CREATE TABLE NewTable  
(FirstName CHAR,
	LastName CHAR, 
	SSN INTEGER CONSTRAINT MyFieldConstraint PRIMARY KEY
); 

CREATE TABLE [KitschnSync](
		[Auto]  COUNTER ,
		[Byte]  BYTE ,
		[Integer]  SMALLINT ,
		[Long]  INTEGER ,
		[Single] REAL ,
		[Double] FLOAT ,
		[Decimal] DECIMAL(18,5) ,
		[Currency]  MONEY ,
		[ShortText]  VARCHAR ,
		[LongText]  MEMO,
		[PlaceHolder1]  MEMO,
		[DateTime] DATETIME ,
		[YesNo] BIT ,
		[OleObject]  IMAGE ,
		[ReplicationID]  UNIQUEIDENTIFIER ,
		[Required]  INTEGER NOT NULL ,
		[UnicodeCompression]  MEMO WITH COMP ,
		[Indexed] INTEGER ,
		CONSTRAINT [PrimaryKey] PRIMARY KEY ([Auto]) ,
		CONSTRAINT [UniqueIndex] UNIQUE ([Byte],[Integer],[Long])
 ); 
 
 CREATE TABLE Customers (CustId INTEGER PRIMARY KEY, CLstNm NCHAR VARYING (50))
 
 CREATE TABLE Orders1 (
	OrderId INTEGER PRIMARY KEY, 
	CustId INTEGER, 
	OrderNotes NCHAR VARYING (255),
	FOREIGN KEY (CustId) REFERENCES Customers(CustId) ON UPDATE CASCADE ON DELETE CASCADE)
	
 CREATE TABLE Orders2 (
	OrderId INTEGER PRIMARY KEY,
	CustId INTEGER,
	OrderNotes NCHAR VARYING (255),
	CONSTRAINT FKOrdersCustId FOREIGN KEY (CustId) REFERENCES Customers(CustId) ON UPDATE SET NULL ON DELETE SET NULL) 
	
 CREATE VIEW EmployeesView AS
SELECT * FROM Employees;

CREATE VIEW CustomersView (CustomerID, CustomerName, City) AS
SELECT CustomerID, CustomerName, City FROM Customers;

CREATE VIEW OrdersView (OrderID, TotalPrice) AS
SELECT OrderID, UnitPrice * Quantity AS TotalPrice FROM Orders;

CREATE VIEW EmployeeOrdersView (EmployeeID, OrderID, OrderDate) AS
SELECT E.EmployeeID, O.OrderID, O.OrderDate
FROM Employees AS E
INNER JOIN Orders AS O ON E.EmployeeID = O.EmployeeID;

CREATE VIEW ProductSalesView (ProductID, TotalSales) AS
SELECT ProductID, SUM(UnitPrice * Quantity) AS TotalSales
FROM OrderDetails
GROUP BY ProductID;

CREATE VIEW HighValueCustomersView (CustomerID, TotalSpent) AS
SELECT CustomerID, SUM(TotalPrice) AS TotalSpent
FROM Orders
GROUP BY CustomerID
HAVING SUM(TotalPrice) > 1000;


Create Procedure CategoryList
As SELECT DISTINCTROW CategoryName, 
            CategoryID FROM Categories 
            ORDER BY CategoryName;
			
CREATE PROCEDURE GetEmployees AS
SELECT * FROM Employees;

CREATE PROCEDURE GetEmployeeByID (EmployeeID INT) AS
SELECT * FROM Employees WHERE EmployeeID = @EmployeeID;

CREATE PROCEDURE GetOrdersByDateRange (StartDate DATE, EndDate DATE) AS
SELECT * FROM Orders WHERE OrderDate BETWEEN @StartDate AND @EndDate;

create table Employees
(
	HomePhone Integer,
	Extension Integer
)

CREATE INDEX NewIndex ON Employees 
(HomePhone, Extension);

create table Customers1
(
CustomerID INTEGER
);

CREATE UNIQUE INDEX CustID 
ON Customers1 (CustomerID) 
WITH DISALLOW NULL;

CREATE TABLE Employees1 (
    EmployeeID AUTOINCREMENT PRIMARY KEY,
    FirstName TEXT(50),
    LastName TEXT(50),
    Email TEXT(100) UNIQUE
);

CREATE TABLE Departments (
    DepartmentID AUTOINCREMENT PRIMARY KEY,
    DepartmentName TEXT(100) UNIQUE
);


CREATE TABLE EmployeeDetails (
    DetailID AUTOINCREMENT PRIMARY KEY,
    EmployeeID LONG REFERENCES Employees1(EmployeeID),
    DepartmentID LONG REFERENCES Departments(DepartmentID),
    Position TEXT(50),
    Salary CURRENCY
);

CREATE TABLE Projects (
    ProjectID AUTOINCREMENT PRIMARY KEY,
    ProjectName TEXT(100) UNIQUE,
    ManagerID LONG REFERENCES Employees1(EmployeeID)
);

ADD USER Alice, Bob TO Editors;

ALTER TABLE Employees ADD COLUMN Notes TEXT(25)

ALTER TABLE Employees ALTER COLUMN ZipCode TEXT(10)

ALTER TABLE Employees1 ADD CONSTRAINT NameIndex UNIQUE (FirstName, LastName);


ALTER DATABASE PASSWORD newPass456 oldPass123;

ALTER USER JaneDoe PASSWORD newPass456 oldPass123;


CREATE USER Alice passAlice 67890, Bob passBob 54321;

CREATE GROUP Editors 1002, Viewers 1003;

DROP TABLE Employees;

DROP INDEX EmpIndex ON Employees;

DROP PROCEDURE UpdateSalaries;

DROP VIEW EmployeeView;


DROP USER David, Eve FROM Viewers;

DROP USER Alice, Bob;

DROP GROUP Editors, Viewers;


GRANT SELECT, UPDATE ON TABLE Employees TO JohnDoe;

GRANT READ, WRITE ON OBJECT EmployeeForm TO Editors;

GRANT FULL CONTROL ON CONTAINER HRContainer TO Alice;

GRANT INSERT, DELETE ON TABLE Projects TO Bob, Charlie;

REVOKE INSERT, DELETE ON TABLE Projects FROM Bob, Charlie;

REVOKE FULL CONTROL ON CONTAINER HRContainer FROM Alice;

REVOKE READ, WRITE ON OBJECT EmployeeForm FROM Editors;

REVOKE SELECT, UPDATE ON TABLE Employees FROM JohnDoe;

DELETE FROM Employees WHERE Department NOT IN (SELECT DepartmentName FROM Departments);

DELETE FROM Employees WHERE Department = 'Sales' AND Salary < 50000;

DELETE FROM Employees WHERE Department = 'Sales';

-- Without parameters
EXECUTE GenerateReport;

-- With parameters
EXECUTE GenerateReport '2024-01-01', '2024-12-31';

EXECUTE UpdateEmployeeInfo 101, 75000, 'Marketing';


PROCEDURE Sales_By_Country [Beginning Date] DateTime, [Ending Date] DateTime;


BEGIN TRANSACTION 

COMMIT TRANSACTION

ROLLBACK WORK 

TRANSFORM SUM(SaleAmount) AS TotalSales
SELECT SalesPerson
FROM Sales
GROUP BY SalesPerson
PIVOT FORMAT(SaleDate, "mmm") IN ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");


TABLE [New Accounts] UNION ALL 
SELECT * 
FROM Customers 
WHERE OrderAmount > 1000;


UPDATE Orders 
SET OrderAmount = OrderAmount * 1.1, 
Freight = Freight * 1.03 
WHERE ShipCountry = 'UK';

UPDATE Employees
SET Salary = 55000
WHERE EmployeeID = 123;

UPDATE Customers
SET ContactName = 'Alfred Schmidt', City = 'Frankfurt'
WHERE CustomerID = 1;

SELECT LastName, 
FirstName, Salary
FROM Employees 
ORDER BY LastName 
WITH OWNERACCESS OPTION;


INSERT INTO Customers SELECT * FROM [New Customers];


INSERT INTO Employees (FirstName,LastName, Title) VALUES ('Harry', 'Washington', 'Trainee');






			






	
	
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 