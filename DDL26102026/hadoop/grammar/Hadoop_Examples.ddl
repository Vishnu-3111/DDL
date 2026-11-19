create table table_name (
  id                int,
  dtDontQuery       string,
  name              string
)
partitioned by (date string)


CREATE TABLE page_view(viewTime INT, userid BIGINT,
     page_url STRING, referrer_url STRING,
     ip STRING COMMENT 'IP Address of the User')
 COMMENT 'This is the page view table'
 PARTITIONED BY(dt STRING, country STRING)
 STORED AS SEQUENCEFILE;
 
 CREATE TABLE page_view(viewTime INT, userid BIGINT,
     page_url STRING, referrer_url STRING,
     ip STRING COMMENT 'IP Address of the User')
 COMMENT 'This is the page view table'
 PARTITIONED BY(dt STRING, country STRING)
 ROW FORMAT DELIMITED
   FIELDS TERMINATED BY '\001'
STORED AS SEQUENCEFILE;

CREATE EXTERNAL TABLE page_view(viewTime INT, userid BIGINT,
     page_url STRING, referrer_url STRING,
     ip STRING COMMENT 'IP Address of the User',
     country STRING COMMENT 'country of origination')
 COMMENT 'This is the staging page view table'
 ROW FORMAT DELIMITED FIELDS TERMINATED BY '\054'
 STORED AS TEXTFILE
 LOCATION '<hdfs_location>';

CREATE TABLE page_view(viewTime INT, userid BIGINT,
     page_url STRING, referrer_url STRING,
     ip STRING COMMENT 'IP Address of the User')
 COMMENT 'This is the page view table'
 PARTITIONED BY(dt STRING, country STRING)
 CLUSTERED BY(userid) SORTED BY(viewTime) INTO 32 BUCKETS
 ROW FORMAT DELIMITED
   FIELDS TERMINATED BY '\001'
   COLLECTION ITEMS TERMINATED BY '\002'
   MAP KEYS TERMINATED BY '\003'
 STORED AS SEQUENCEFILE;
 
 CREATE TABLE list_bucket_single (key STRING, value STRING)
  SKEWED BY (key) ON (1,5,6) [STORED AS DIRECTORIES];
  
CREATE TABLE list_bucket_multiple (col1 STRING, col2 int, col3 STRING)
  SKEWED BY (col1, col2) ON (('s1',1), ('s3',3), ('s13',13), ('s78',78)) [STORED AS DIRECTORIES]
  
CREATE TEMPORARY TABLE list_bucket_multiple (col1 STRING, col2 int, col3 STRING);

CREATE TRANSACTIONAL TABLE transactional_table_test(key string, value string) PARTITIONED BY(ds string) STORED AS ORC;


create table pk(id1 integer, id2 integer,
  primary key(id1, id2) disable novalidate);
 
create table fk(id1 integer, id2 integer,
  constraint c1 foreign key(id1, id2) references pk(id2, id1) disable novalidate);
  
create table constraints1(id1 integer UNIQUE disable novalidate, id2 integer NOT NULL,
  usr string DEFAULT current_user(), price double CHECK (price > 0 AND price <= 1000));
 
create table constraints3(id1 integer, id2 integer,
  constraint c1_unique UNIQUE(id1) disable novalidate);
  

CREATE VIEW onion_referrers(url COMMENT 'URL of Referring page')
  COMMENT 'Referrers to The Onion website'
  AS
  SELECT DISTINCT referrer_url
  FROM page_view
  WHERE page_url='http://www.theonion.com';
  
CREATE MATERIALIZED VIEW IF NOT EXISTS mydb.sales_summary
  COMMENT 'Materialized view for sales data summary'
  PARTITIONED ON (year, month)
  STORED AS ORC
  LOCATION '/user/hive/warehouse/mydb.db/sales_summary'
  TBLPROPERTIES (
    'retention' = '365',
    'created_by' = 'John Doe'
  )
AS
SELECT
  year,
  month,
  SUM(sales_amount) AS total_sales,
  AVG(sales_amount) AS avg_sales
FROM
  mydb.sales_data
GROUP BY
  year,
  month;
  
-- Create a permanent UDF named 'calculate_discount' from the Java class 'com.example.MyUDF'
-- The Java class should implement the UDF logic.

CREATE FUNCTION calculate_discount AS 'com.example.MyUDF' USING JAR 'hdfs:///path/to/udf.jar';


-- Create a permanent UDF named 'calculate_sales_tax' from the Python script 'my_udf.py'
-- The Python script should implement the UDF logic.

CREATE FUNCTION calculate_sales_tax AS 'my_udf.py' USING FILE '/path/to/my_udf.py';

-- Create a temporary UDF named 'calculate_discount' from the Java class 'com.example.MyUDF'

CREATE TEMPORARY FUNCTION temp_calculate_discount AS 'com.example.MyUDF';

CREATE TABLE employee_data (
  employee_id INT,
  first_name STRING,
  last_name STRING,
  department_id INT
);

CREATE INDEX idx_employee_department
ON TABLE employee_data (department_id, last_name)
AS 'COMPACT'
WITH DEFERRED REBUILD
IDXPROPERTIES ('index_type'='composite', 'compression'='ZLIB')
COMMENT "Composite index on department and last name";

CREATE TABLE orders (
  order_id INT,
  customer_id INT,
  order_date STRING,
  total_amount DOUBLE
);

CREATE INDEX customer_index
  ON TABLE orders (customer_id)
  AS 'COMPACT'
  WITH DEFERRED REBUILD
  IDXPROPERTIES ('index_version'='1.0', 'index_type'='B-tree')
  IN TABLE customer_index_table
  STORED AS ORC
  LOCATION '/user/hive/indexes/customer_index'
  TBLPROPERTIES ('key'='value')
  COMMENT "Index on customer_id for faster customer-specific queries";
  
  CREATE TABLE IF NOT EXISTS my_database.my_table (
  id INT,
  name STRING,
  age INT,
  salary DOUBLE,
  CONSTRAINT check_age_range CHECK (age >= 18 AND age <= 65)
);

DROP TABLE employee;

DROP TABLE IF EXISTS customer;

DROP TABLE sales PURGE;

DROP TABLE IF EXISTS logs PURGE;

DROP VIEW onion_referrers;

DROP MATERIALIZED VIEW mydb.sales_summary;

DROP MATERIALIZED VIEW default.customer_stats;

DROP MATERIALIZED VIEW IF EXISTS mydb.product_summary;

DROP TEMPORARY FUNCTION my_udf;

DROP TEMPORARY FUNCTION IF EXISTS my_udf;

CREATE TEMPORARY MACRO fixed_number() 42;
CREATE TEMPORARY MACRO string_len_plus_two(x string) length(x) + 2;
CREATE TEMPORARY MACRO simple_add (x int, y int) x + y;

-- Create a role named 'data_analyst'
CREATE ROLE data_analyst;


CREATE ROLE role_name;

CREATE DATABASE database_name;

CREATE SCHEMA IF NOT EXISTS database_name COMMENT 'This is a remote schema.';

CREATE DATABASE IF NOT EXISTS database_name
LOCATION 'hdfs://<hdfs_path>';

CREATE SCHEMA database_name
MANAGEDLOCATION 'hdfs://<managed_hdfs_path>';

CREATE DATABASE IF NOT EXISTS database_name
WITH DBPROPERTIES ('property_name' = 'property_value', 'another_property' = 'value');

CREATE SCHEMA IF NOT EXISTS database_name
COMMENT 'This is a remote schema.'
MANAGEDLOCATION 'hdfs://<managed_hdfs_path>';

CREATE DATABASE IF NOT EXISTS database_name
WITH DBPROPERTIES ('property1' = 'value1', 'property2' = 'value2');


-- Create a Hive connector named 'my_mysql_connector' of type 'jdbc' for a MySQL database.
CREATE CONNECTOR IF NOT EXISTS my_mysql_connector
  TYPE jdbc
  URL 'jdbc:mysql://localhost:3306/mydatabase'
  COMMENT 'Connector for connecting to MySQL database'
  WITH DCPROPERTIES (
    username='myuser',
    password='mypassword',
    driverClassName='com.mysql.jdbc.Driver'
  );

-- Create a Hive connector named 'my_s3_connector' of type 's3' for Amazon S3 storage.
CREATE CONNECTOR IF NOT EXISTS my_s3_connector
  TYPE s3
  URL 's3://mybucket/mydata'
  COMMENT 'Connector for accessing data in Amazon S3'
  WITH DCPROPERTIES (
    accessKey='my_access_key',
    secretKey='my_secret_key'
  );

DROP DATABASE mydb;

DROP DATABASE IF EXISTS mydb CASCADE;

DROP DATABASE mydb RESTRICT;

DROP SCHEMA mydb;

DROP SCHEMA IF EXISTS mydb;

-- Set properties for a database
ALTER DATABASE mydb SET DBPROPERTIES ('property_name' = 'property_value', 'another_property' = 'another_value');

-- Set properties for a schema
ALTER SCHEMA myschema SET DBPROPERTIES ('property_name' = 'property_value', 'another_property' = 'another_value');


-- Set the owner of a database to a specific user
ALTER DATABASE mydb SET OWNER USER johndoe;

-- Set the owner of a schema to a specific role
ALTER SCHEMA myschema SET OWNER ROLE data_admin;


-- Change the location of a database
ALTER DATABASE mydb SET LOCATION '/user/hive/warehouse/new_location';

-- Change the location of a schema
ALTER SCHEMA myschema SET LOCATION '/user/hive/warehouse/new_location';


-- Change the managed location of a database
ALTER DATABASE mydb SET MANAGEDLOCATION '/user/hive/managed_location';

-- Change the managed location of a schema
ALTER SCHEMA myschema SET MANAGEDLOCATION '/user/hive/managed_location';

-- Switch back to the default database
USE DEFAULT;

-- Switch to a database named "mydb"
USE mydb;

-- Drop a connector named "my-connector" without checking if it exists
DROP CONNECTOR my-connector;

-- Drop a connector named "my-connector" and check if it exists
DROP CONNECTOR IF EXISTS my-connector;

-- Set data connector properties for a connector named "my-connector"
ALTER CONNECTOR my-connector SET DCPROPERTIES ('property_name' = 'property_value', 'another_property' = 'another_value');

-- Set a new URL for a connector named "my-connector"
ALTER CONNECTOR my-connector SET URL 'new_url';

-- Set the owner of a connector named "my-connector" to a specific user
ALTER CONNECTOR my-connector SET OWNER USER johndoe;

-- Set the owner of a connector named "my-connector" to a specific role
ALTER CONNECTOR my-connector SET OWNER ROLE data_admin;

DROP TABLE employees;

DROP TABLE IF EXISTS products;

DROP TABLE audit_log PURGE;

TRUNCATE TABLE employees;

TRUNCATE TABLE sales PARTITION (month = '2023-01');

TRUNCATE TABLE sales PARTITION (month = '2023-01', region = 'North');

ALTER TABLE table_name SET SERDEPROPERTIES ('field.delim' = ',');

ALTER TABLE table_name UNSET SERDEPROPERTIES ('field.delim');

ALTER TABLE page_view ADD PARTITION (dt='2008-08-08', country='us') location '/path/to/us/part080808' ,
                          PARTITION (dt='2008-08-09', country='us') location '/path/to/us/part080809';
						  
ALTER TABLE table_name ADD PARTITION (partCol = 'value1') location 'loc1';
ALTER TABLE table_name ADD PARTITION (partCol = 'value2') location 'loc2';

ALTER TABLE page_view DROP PARTITION (dt='2008-08-08', country='us');

CREATE TABLE test_change (a int, b int, c int);
 
// First change column a's name to a1.
ALTER TABLE test_change CHANGE a a1 INT;
 
// Next change column a1's name to a2, its data type to string, and put it after column b.
ALTER TABLE test_change CHANGE a1 a2 STRING AFTER b;
// The new table's structure is:  b int, a2 string, c int.
  
// Then change column c's name to c1, and put it as the first column.
ALTER TABLE test_change CHANGE c c1 INT FIRST;
// The new table's structure is:  c1 int, b int, a2 string.
  
// Add a comment to column a1
ALTER TABLE test_change CHANGE a1 a1 INT COMMENT 'this is column a1';

ALTER TABLE foo PARTITION (ds='2008-04-08', hr=11) CHANGE COLUMN dec_column_name dec_column_name DECIMAL(38,18);
ALTER TABLE foo PARTITION (ds='2008-04-08', hr=12) CHANGE COLUMN dec_column_name dec_column_name DECIMAL(38,18);


ALTER TABLE logging_table TOUCH;

ALTER TABLE archive_table DISABLE NO_DROP CASCADE;

ALTER TABLE logs SET LOCATION '/new/hdfs/path/';

ALTER TABLE files SET FILEFORMAT ORC;

ALTER TABLE employee ORDER BY last_name, first_name;

ALTER TABLE sales CLUSTERED BY (product_id) SORTED BY (sale_date) INTO 100 BUCKETS;

ALTER TABLE logs COMPACT 'MAJOR' AND WAIT;

ALTER TABLE products SET TBLPROPERTIES ("compression"="gzip", "comment"="Product data");

ALTER TABLE customers ADD COLUMNS (phone_number STRING, email STRING);

ALTER TABLE logs DROP PARTITION (date='2022-01-01');

ALTER TABLE data_archive EXCHANGE PARTITION (date='2023-10-10') WITH TABLE current_data;

ALTER TABLE sales ADD PARTITION (dt='2023-10-10') LOCATION '/path/to/partition/';

CREATE TEMPORARY TABLE order_items (order_id STRING, product_id int, col3 STRING);

CREATE  TABLE products ( product_id int, col3 STRING);

ALTER TABLE order_items ADD CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products (product_id);

ALTER TABLE orders ADD CONSTRAINT pk_order_id PRIMARY KEY (order_id);

ALTER TABLE employee CHANGE COLUMN age new_age INT;
ALTER TABLE my_table RENAME TO new_table;

-- Set table properties for a view named "daily_sales_report" in the "sales_db" database.
ALTER VIEW sales_db.daily_sales_report SET TBLPROPERTIES ("creator" = "John Doe", "source" = "Sales Data 2023");

-- Alter the view "monthly_sales_report" in the "sales_db" database by changing its underlying query.
ALTER VIEW sales_db.monthly_sales_report AS
SELECT month, year, SUM(sales_amount) AS total_sales
FROM sales
GROUP BY month, year;

-- Disable the rewrite capability for a materialized view named "daily_report" in the "reporting_db" database.
ALTER MATERIALIZED VIEW reporting_db.daily_report DISABLE REWRITE;

-- Rebuild the "idx_product_price" index on the "products" table for a specific partition.
ALTER INDEX idx_product_price ON products
PARTITION (category = 'Electronics')
REBUILD;

-- Drop a temporary macro named "generate_report" if it exists.
DROP TEMPORARY MACRO IF EXISTS generate_report;

reload function;

DROP ROLE my_role;

GRANT ROLE analyst TO USER user_john;

GRANT ROLE analyst TO GROUP analytics_team;

GRANT ROLE junior_analyst TO ROLE analyst;

GRANT ROLE admin_role TO USER admin_user WITH ADMIN OPTION;

GRANT ROLE admin_role TO GROUP administrators WITH ADMIN OPTION;

GRANT ROLE junior_analyst TO ROLE analyst WITH ADMIN OPTION;

REVOKE ROLE analyst FROM USER user_john;

REVOKE ROLE analyst, data_scientist FROM USER user_jane;

REVOKE ADMIN OPTION FOR ROLE admin_role FROM USER admin_user;

REVOKE ROLE analyst FROM GROUP analytics_team;

REVOKE ROLE analyst, data_scientist FROM GROUP analytics_team;

REVOKE ADMIN OPTION FOR ROLE admin_role FROM GROUP administrators;

REVOKE ROLE junior_analyst FROM ROLE analyst;

REVOKE ROLE junior_analyst, intern FROM ROLE analyst;

REVOKE ADMIN OPTION FOR ROLE junior_analyst FROM ROLE analyst;

GRANT SELECT ON table_name TO USER username WITH GRANT OPTION;

GRANT INSERT, UPDATE ON view_name TO ROLE rolename;

GRANT DELETE ON table_name TO USER user1, USER user2, USER user3;

GRANT ALL ON table_name TO USER username;

GRANT SELECT ON table_name TO ROLE role_name, USER user_name;

REVOKE SELECT ON table_name FROM USER username;

REVOKE DELETE, UPDATE ON view_name FROM ROLE rolename;

REVOKE ALL ON table_name FROM USER user1, USER user2, USER user3;

REVOKE SELECT ON table_name FROM ROLE role_name, USER user_name;

REVOKE GRANT OPTION FOR INSERT ON table_name FROM USER username;

SHOW ROLES;

SHOW CURRENT ROLES;

SHOW ROLE GRANT ROLE '`my_role`';

SHOW ROLE GRANT USER current_user;

SHOW ROLE GRANT ROLE 'analyst_role';

SHOW ROLE GRANT USER 'john_doe';

SET ROLE 'analyst_role';

SET ROLE ALL;

SET ROLE NONE;

SHOW PRINCIPALS 'analyst_role';

SHOW DATABASES;

SHOW DATABASES LIKE 'data%';

SHOW SCHEMAS;

SHOW SCHEMAS LIKE 'sales%';

SHOW CONNECTORS;

SHOW TABLES;
SHOW TABLES IN mydatabase;
SHOW TABLES LIKE 'prefix_*';
SHOW TABLES IN mydatabase LIKE 'prefix_*';
SHOW TABLES LIKE '*data*';

SHOW VIEWS;                                
SHOW VIEWS 'test_*';                      
SHOW VIEWS '*view2';                       
SHOW VIEWS LIKE 'test_view1|test_view2';   
SHOW VIEWS FROM test1;                   
SHOW VIEWS IN test1;                      
SHOW VIEWS IN test1 "test_*";            

SHOW PARTITIONS table_name PARTITION(ds='2010-03-03');          
SHOW PARTITIONS table_name PARTITION(hr='12');                    
SHOW PARTITIONS table_name PARTITION(ds='2010-03-03', hr='12'); 

SHOW PARTITIONS databaseFoo.tableBar PARTITION(ds='2010-03-03', hr='12');  

SHOW PARTITIONS databaseFoo.tableBar LIMIT 10;                                                               
SHOW PARTITIONS databaseFoo.tableBar PARTITION(ds='2010-03-03') LIMIT 10;                                   
SHOW PARTITIONS databaseFoo.tableBar PARTITION(ds='2010-03-03') ORDER BY hr DESC LIMIT 10;                   
SHOW PARTITIONS databaseFoo.tableBar PARTITION(ds='2010-03-03') WHERE hr >= 10 ORDER BY hr DESC LIMIT 10;    
SHOW PARTITIONS databaseFoo.tableBar WHERE hr >= 10 AND ds='2010-03-03' ORDER BY hr DESC LIMIT 10;           

show table extended like part_table;

SHOW TBLPROPERTIES mytable;

SHOW CREATE TABLE table_name;
SHOW CREATE TABLE db_name.table_name;
SHOW CREATE TABLE view_name;

-- Show indexes on a table in the default database
SHOW INDEXES ON table_with_index;

-- Show indexes on a table in a specific database
SHOW INDEXES ON table_with_index FROM db_name;

-- Show formatted indexes on a table in the default database
SHOW FORMATTED INDEXES ON table_with_index;

-- Show formatted indexes on a table in a specific database
SHOW FORMATTED INDEXES ON table_with_index FROM db_name;

SHOW COLUMNS FROM foo;  
SHOW COLUMNS FROM foo "*";  
SHOW COLUMNS IN foo "col*"; 
SHOW COLUMNS FROM foo '*c';     
SHOW COLUMNS FROM foo LIKE "col1|cola";  
SHOW COLUMNS FROM foo FROM test_db LIKE 'col*';  
SHOW COLUMNS IN foo IN test_db LIKE 'col*'; 

-- Show all available functions
SHOW FUNCTIONS;

-- Show functions that start with 'udf_' in their names
SHOW FUNCTIONS LIKE 'udf_%';

-- Show functions that contain the word 'substring' in their names
SHOW FUNCTIONS LIKE '%substring%';

show grant user ashutosh on table hivejiratable;

show grant user ashutosh on all;   

show grant on table hivejiratable;

SHOW CURRENT ROLES;

SHOW LOCKS my_table;

SHOW LOCKS my_table EXTENDED;

SHOW LOCKS my_table PARTITION (dt='2023-01-01');

SHOW LOCKS my_table PARTITION (dt='2023-01-01') EXTENDED;

SHOW LOCKS DATABASE my_database;

SHOW CONF hive.exec.dynamic.partition.mode;

SHOW TRANSACTIONS;

SHOW COMPACTIONS;

SHOW COMPACTIONS DATABASE db1;

SHOW COMPACTIONS SCHEMA db1;

SHOW COMPACTIONS tbl0;

SHOW COMPACTIONS db1.tbl0 PARTITION (p=101,day='Monday') POOL 'pool0' TYPE 'minor' STATUS 'ready for clean' ORDER BY cq_table DESC, cq_state LIMIT 42;

DESCRIBE DATABASE my_db;
DESCRIBE DATABASE EXTENDED my_db;
DESCRIBE SCHEMA my_db;
DESCRIBE SCHEMA EXTENDED my_db;

DESCRIBE CONNECTOR my_connector;
DESCRIBE CONNECTOR EXTENDED your_connector;

DESCRIBE formatted mydb.mytable;
DESCRIBE mydb.mytable mycolumn;
DESCRIBE mydb.mytable mystructfield.field_name;
DESCRIBE mydb.mytable myarraycolumn.'$elem$';
DESCRIBE mydb.mytable mymapcolumn.'$key$';
DESCRIBE mydb.mytable mymapcolumn.'$value$';
DESCRIBE FORMATTED mydb.mytable mycolumn PARTITION (year=2023, month=10, day=11);

ABORT TRANSACTIONS 0000007 0000008 0000010 0000015;

LOAD DATA LOCAL INPATH '/path/to/localfile.csv' INTO TABLE mytable;

LOAD DATA INPATH '/user/hive/input/data.csv' OVERWRITE INTO TABLE mytable;

LOAD DATA INPATH '/user/hive/input/data.csv' INTO TABLE mytable PARTITION (year=2023, month=10, day=11);

LOAD DATA INPATH '/user/hive/input/customdata.txt' INTO TABLE mytable
INPUTFORMAT 'org.apache.hadoop.mapred.TextInputFormat'
SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde';

INSERT INTO TABLE students
  VALUES ('fred flintstone', 35, 1.28), ('barney rubble', 32, 2.32);
  
 INSERT INTO TABLE pageviews PARTITION (datestamp = '2014-09-23')
  VALUES ('jsmith', 'mail.com', 'sports.com'), ('jdoe', 'mail.com', null);
  
INSERT INTO TABLE pageviews PARTITION (datestamp)
  VALUES ('tjohnson', 'sports.com', 'finance.com', '2014-09-23'), ('tlee', 'finance.com', null, '2014-09-21');
  
INSERT INTO TABLE pageviews
  VALUES ('tjohnson', 'sports.com', 'finance.com', '2014-09-23'), ('tlee', 'finance.com', null, '2014-09-21');
  
-- Hypothetical example 1: Update a specific column for all rows
UPDATE mytable
SET age = 30;

-- Hypothetical example 2: Update multiple columns for a specific row
UPDATE mytable
SET name = 'Jane', salary = 60000
WHERE id = 2;

-- Hypothetical example 3: Conditional update
UPDATE mytable
SET status = 'Active'
WHERE joining_year <= 2020;

-- Hypothetical example 4: Update multiple rows
UPDATE mytable
SET department = 'HR'
WHERE location = 'New York';

DELETE FROM mytable WHERE age > 30;
DELETE FROM mytable;

MERGE INTO my_target_table AS T
USING (
    SELECT id, name, age
    FROM my_source_table
) AS S
ON T.id = S.id
WHEN MATCHED THEN UPDATE SET
  T.name = S.name,
  T.age = S.age
WHEN NOT MATCHED THEN INSERT VALUES
  (S.id, S.name, S.age);

CREATE TABLE example_table (
  id INT,
  name STRING,
  age INT
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
  'field.delim' = ','
)
STORED AS INPUTFORMAT 'org.apache.hadoop.hive.ql.io.orc.OrcInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.orc.OrcOutputFormat'
LOCATION '/user/hive/warehouse/example_table';


-- ============================================================
-- HIVE / HADOOP ALTER TABLE - COMPLETE SYNTAX TEST
-- ============================================================

CREATE TABLE test_alter (
    id INT,
    quantity BIGINT,
    name STRING,
    category STRING,
    category_id INT,
    code STRING,
    amount DECIMAL(10,2),
    new_col1 INT,
    new_col2 STRING,
    new_col3 DECIMAL(10,2)
)
PARTITIONED BY (
    year STRING,
    month STRING
)
CLUSTERED BY (id, quantity)
SORTED BY (id, quantity)
INTO 4 BUCKETS
STORED AS ORC
TBLPROPERTIES (
    'comment' = 'Hive ALTER TABLE test table'
);

-- 11. Add PRIMARY KEY
ALTER TABLE test_alter_new
    ADD CONSTRAINT pk_test_alter
    PRIMARY KEY (id)
    DISABLE NOVALIDATE;

CREATE TABLE test_weight_null (
    weight_grams INT CHECK (weight_grams IS NULL OR weight_grams >= 0),
weight_gramss int,
CONSTRAINT named check (weight_grams IS NULL OR weight_grams >= 0)
);

CREATE TABLE test_weight_not_null (
    weight_grams INT ,
    CONSTRAINT chk_weight CHECK (weight_grams >= 0)
);

ALTER TABLE test_weight_null change COLUMN test again int
CONSTRAINT chk_weight_null
CHECK (weight_grams IS NULL OR weight_grams >= 0);