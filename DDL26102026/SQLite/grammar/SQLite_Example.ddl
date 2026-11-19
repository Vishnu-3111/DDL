CREATE TABLE t1(a, b UNIQUE);

CREATE TABLE t2(a, b PRIMARY KEY);

CREATE TABLE t3(a, b);

CREATE TABLE t4(x INT CHECK( x>3 ));

CREATE TABLE t5(x INTEGER PRIMARY KEY ASC, y, z);
CREATE TABLE t6(x INTEGER, y, z, PRIMARY KEY(x ASC));
CREATE TABLE t7(x INTEGER, y, z, PRIMARY KEY(x DESC));

CREATE TABLE t8(x INTEGER PRIMARY KEY DESC, y, z);

CREATE TABLE t9(
   a INTEGER PRIMARY KEY,
   b INT,
   c TEXT,
   d INT GENERATED ALWAYS AS (a*abs(b)) VIRTUAL,
   e TEXT GENERATED ALWAYS AS (substr(c,b,b+1)) STORED
);

CREATE TABLE t10(
   a INTEGER PRIMARY KEY,
   b INT,
   c TEXT,
   d INT AS (a*abs(b)),
   e TEXT AS (substr(c,b,b+1)) STORED
);

CREATE TABLE IF NOT EXISTS wordcount(
  word TEXT PRIMARY KEY,
  cnt INTEGER
) WITHOUT ROWID;


CREATE TABLE IF NOT EXISTS db.tbl_with_unique
(
	cl1 INTEGER NOT NULL ON CONFLICT REPLACE,
	Constraint pk_tblname UNIQUE (cl1)
);

CREATE TABLE parent_table
(
	col1 INTEGER Generated Always as ( x < 2 ) Virtual,
	col2 VARCHAR (50) Default 2 ,
	col3 DECIMAL(10,20) Collate collation_name ,
	Constraint chk_parent_table CHECK ( x>2 ),
	Constraint pk_parent_table PRIMARY KEY (col1) ON CONFLICT FAIL

); 

CREATE TABLE child_table
(
	col1 INTEGER REFERENCES parent_table (col1) ON UPDATE CASCADE ON DELETE CASCADE,
	Constraint pk_child_table PRIMARY KEY (col1)
);

Create temporary table tem_table ( col INT primary key )
Without Rowid , STRICT
;

Create table if not exists db.exist_table 
As SELECT x FROM t1 WHERE a = b ;

Create View dbo.myview1 
( col1, col2) 
AS SELECT * FROM t_object where t_object.name = "t_name" ;


CREATE VIEW customer_address AS
   SELECT cust_id, cust_addr FROM customer;
   
CREATE TABLE purchaseorder (parent_po VARCHAR(266));
   
CREATE INDEX po_parent ON purchaseorder(parent_po) WHERE parent_po IS NOT NULL;

CREATE TABLE person (team_id INTEGER) ;

CREATE UNIQUE INDEX team_leader ON person(team_id) WHERE is_team_leader;

CREATE TABLE tab1 (a INT , b INT ) ;

CREATE INDEX ex1 ON tab1(a,b) WHERE a=5 OR b=6;

CREATE TABLE tab2 (b INT , c INT ) ;

CREATE INDEX ex2 ON tab2(b,c) WHERE c IS NOT NULL;

create table account(test int);

create table locations(test2 int);

CREATE TABLE account_change(
  chng_id INTEGER PRIMARY KEY,
  acct_no INTEGER REFERENCES account,
  location INTEGER REFERENCES locations,
  amt INTEGER,  -- in cents
  authority TEXT,
  comment TEXT
);
CREATE INDEX acctchng_magnitude ON account_change(acct_no, amt);

CREATE TABLE t21(x,y,z);
CREATE INDEX t2xy ON t21(x,y);

CREATE TABLE customers(address VARCHAR(266));


CREATE TRIGGER update_customer_address UPDATE OF address ON customers 
  BEGIN
    UPDATE orders SET address = new.address WHERE customer_name = old.name;
  END;
  
CREATE TABLE customer_address1 ( cust_addr VARCHAR(266));
  
  CREATE TRIGGER cust_addr_chng
INSTEAD OF UPDATE OF cust_addr ON customer_address1
BEGIN
  UPDATE customer SET cust_addr=NEW.cust_addr
   WHERE cust_id=NEW.cust_id;
END;


CREATE TEMP TRIGGER ex1 AFTER INSERT ON main.tab1 BEGIN UPDATE customer SET cust_addr=NEW.cust_addr
   WHERE cust_id=NEW.cust_id; END;
   
   
 CREATE VIRTUAL TABLE Virtual_tablename1 USING modulename;
 
 CREATE VIRTUAL TABLE Virtual_tablename2 USING modulename(arg1, arg2);

ALTER TABLE Employees
ADD COLUMN Email TEXT;

ALTER TABLE Employees
RENAME COLUMN Name TO FullName;

ALTER TABLE Employees
RENAME TO Staff;

ALTER TABLE Employees
ADD COLUMN Email TEXT NOT NULL DEFAULT 'example@example.com';


ANALYZE idx_Employees_Name;

ANALYZE;

ANALYZE Employees;

ATTACH DATABASE 'file_path' AS database_name;

ATTACH DATABASE 'C:/path/to/auxiliary.db' AS auxiliary;

BEGIN TRANSACTION;

COMMIT;

ROLLBACK;

ROLLBACK TO SAVEPOINT savepoint_name;


DELETE FROM Employees
WHERE EmployeeID IN (
    SELECT EmployeeID
    FROM Employees
    ORDER BY HireDate ASC
    LIMIT 5
);

DELETE FROM Employees
WHERE Department = 'HR'
LIMIT 10;


DETACH DATABASE auxiliary;

DROP TABLE Employees;

DROP INDEX index_name;

DROP TRIGGER trg_EmployeeUpdates;

DROP VIEW EmployeeDetails;

INSERT INTO Products (ProductName, Price, Stock)
VALUES ('Laptop', 999.99, 10),
       ('Smartphone', 599.99, 25),
       ('Tablet', 299.99, 15);

INSERT INTO Employees (EmployeeID, Name, Department)
VALUES (5, 'Eva', DEFAULT);


INSERT INTO Employees (EmployeeID, Name, Department, Salary)
SELECT ID, FullName, Dept, Salary
FROM TempEmployees
WHERE Status = 'Active';

INSERT INTO Employees (EmployeeID, Name, Department, Salary)
VALUES (2, 'Bob', 'IT', 60000),
       (3, 'Charlie', 'Finance', 55000),
       (4, 'Diana', 'Marketing', 62000);
	   
PRAGMA temp_store = MEMORY;

PRAGMA table_info(Employees);

PRAGMA cache_size = 1000;

PRAGMA index_info('idx52');

REINDEX;

REINDEX index_name;

SAVEPOINT savepoint_name;

RELEASE SAVEPOINT risky_operation;

UPDATE Employees
SET Employees.Salary = Departments.NewSalary
FROM Employees
JOIN Departments ON Employees.Department = Departments.DepartmentName
WHERE Employees.EmployeeID = Departments.ManagerID;


UPDATE target_table
SET target_table.column1 = cte_name.column1
FROM cte_name
WHERE target_table.column2 = cte_name.column2;


VACUUM INTO 'new_database.db';

CREATE TABLE test_weight_null (
    weight_grams INTEGER,
    CONSTRAINT chk_weight CHECK (weight_grams IS NOT NULL OR weight_grams >= 0)
);

CREATE TABLE test_weight_not_null (
    weight_grams INTEGER NOT NULL,
    CONSTRAINT chk_weight CHECK (weight_grams >= 0)
);

-- 1. Rename table
ALTER TABLE test_weight_null
RENAME TO test_weight_null_new;

-- 2. Rename column
ALTER TABLE test_weight_null
RENAME COLUMN weight_grams TO weight_grams_new;

-- 3. Add column
ALTER TABLE test_weight_null
ADD COLUMN weight_grams_new INTEGER;

-- 4. Add column with NOT NULL + DEFAULT
ALTER TABLE test_weight_null
ADD COLUMN weight_grams_new INTEGER NOT NULL DEFAULT 0;

-- 5. Add column with CHECK
ALTER TABLE test_weight_null
ADD COLUMN weight_grams_new INTEGER CONSTRAINT named
CHECK (weight_grams_new IS NULL OR weight_grams_new >= 0);

-- 6. Add column with named CHECK
ALTER TABLE test_weight_null
ADD COLUMN weight_grams_new INTEGER
CONSTRAINT chk_weight_new
CHECK (weight_grams_new IS NULL OR weight_grams_new >= 0);

-- 7. Add column with NOT NULL + DEFAULT + CHECK
ALTER TABLE test_weight_null
ADD COLUMN weight_grams_new INTEGER NOT NULL;

-- 8. Drop column
ALTER TABLE test_weight_null
DROP COLUMN weight_grams;

-- 9. Set NOT NULL (SQLite 3.53.0+)
ALTER TABLE test_weight_null
ALTER COLUMN weight_grams SET NOT NULL ON CONFLICT ROLLBACK;

-- 10. Drop NOT NULL (SQLite 3.53.0+)
ALTER TABLE test_weight_null
ALTER COLUMN weight_grams DROP NOT NULL;

create table main.product_variants
(
variant_id INTEGER
primary key,
product_id INTEGER not null
references main.products
on update cascade on delete cascade,
sku TEXT not null
unique,
price_cents INTEGER not null,
currency_code TEXT default 'USD' not null,
weight_grams INTEGER,
is_active INTEGER default 1 not null,
created_at TEXT default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) not null,
updated_at TEXT default (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) not null,
check (is_active IN (0, 1)),
check (length(currency_code) = 3),
check (price_cents >= 0),
check (weight_grams IS NULL OR weight_grams >= 0)
)
strict;
 
create index main.idx_product_variants_product_id
on main.product_variants (product_id);














