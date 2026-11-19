-------------------------
-- USE commands
-------------------------

USE WAREHOUSE mywarehouse;
USE mytestdb.testschema;
USE testschema;

USE DATABASE mydb;

-------------------------
-- DROP <objects>
-------------------------

DROP SCHEMA myschema;
DROP SCHEMA IF EXISTS myschema2 CASCADE;

DROP VIEW myview;

DROP SEQUENCE IF EXISTS invoice_sequence_number;

DROP PROCEDURE add_accounting_user(varchar);

DROP FUNCTION multiply(number, number); 

DROP TABLE IF EXISTS t2;


-------------------------------------------
-- Create Database
-------------------------------------------
CREATE DATABASE mytestdb;
CREATE DATABASE mytestdb2 DATA_RETENTION_TIME_IN_DAYS = 10;
-- SHOW DATABASES LIKE 'my%';

CREATE TRANSIENT DATABASE mytransientdb;
-- SHOW DATABASES LIKE 'my%';

-- Shared Database 
CREATE DATABASE snow_sales FROM SHARE ab67890.sales_s;


-- Database Replication 
CREATE DATABASE mydb1
  AS REPLICA OF myorg.account1.mydb1
  DATA_RETENTION_TIME_IN_DAYS = 10;


-------------------------------------------
-- Create Tables
-------------------------------------------

CREATE TABLE mytable_1 (amount NUMBER)
COMMENT = "tagged value";


CREATE TABLE example (col1 number comment 'a column comment') COMMENT='a table comment';



CREATE TABLE mytable_copy (b) AS SELECT * from mytable;


CREATE TABLE mytable_copy2 AS SELECT b+1 AS c FROM mytable_copy;


CREATE TABLE testtable_summary (name, summary_amount) AS SELECT name, amount1 + amount2 FROM testtable;



CREATE OR REPLACE TABLE parquet_col (
  custKey number default NULL,
  orderDate date default NULL,
  orderStatus varchar(100) default NULL,
  price varchar(255)
)
AS SELECT
  $1:o_custkey::number,
  $1:o_orderdate::date,
  $1:o_orderstatus::text,
  $1:o_totalprice::text
FROM @my_stage;


CREATE TABLE mytable_2 (amount NUMBER);


CREATE TABLE mytable_3 LIKE mytable_2;

CREATE TABLE mytable_4 (date timestamp_ntz, id number, content variant) CLUSTER BY (date, id);


CREATE TABLE collation_demo (
  uncollated_phrase VARCHAR, 
  utf8_phrase VARCHAR COLLATE 'utf8',
  english_phrase VARCHAR COLLATE 'en',
  spanish_phrase VARCHAR COLLATE 'sp'
  );

CREATE TABLE mytable_5
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
    WITHIN GROUP (ORDER BY ORDER_ID)
      FROM TABLE(
        INFER_SCHEMA(
          LOCATION=>'@mystage',
          FILE_FORMAT=>'my_parquet_format'
        )
      ));

create temporary table demo_temporary (i integer);
create temp      table demo_temp      (i integer);



create local temporary table demo_local_temporary (i integer);

create local temp      table demo_local_temp      (i integer);

create global temporary table demo_global_temporary (i integer);

create global temp      table demo_global_temp      (i integer);

create volatile table demo_volatile (i integer);


create or replace table TABLE1 clone mytable_2;

-----------------------------
-- Create View
-----------------------------




------------------------------
-- Create Sequence
------------------------------

CREATE OR REPLACE SEQUENCE seq_01 START = 1 INCREMENT = 1;
CREATE OR REPLACE TABLE sequence_test_table (i INTEGER);

CREATE OR REPLACE SEQUENCE seq_5 START = 1 INCREMENT = 5;

CREATE OR REPLACE SEQUENCE seq90;
CREATE OR REPLACE TABLE sequence_demo (i INTEGER DEFAULT seq90.nextval, dummy SMALLINT);


--------------------------------
-- Create Procedure
--------------------------------

CREATE or replace PROCEDURE proc3()
  RETURNS VARCHAR
  LANGUAGE javascript
  AS
  $$
  var rs = snowflake.execute( { sqlText: 
      `INSERT INTO table1 ("column 1") 
           SELECT 'value 1' AS "column 1" ;`
       } );
  return 'Done.';
  $$;


create or replace procedure sp_pi()
    returns float not null
    language javascript
    as
    $$
    return 3.1415926;
    $$
    ;
	
create or replace procedure stproc1(FLOAT_PARAM1 FLOAT)
    returns string
    language javascript
    strict
    execute as owner
    as
    $$
    var sql_command = 
     "INSERT INTO stproc_test_table1 (num_col1) VALUES (" + FLOAT_PARAM1 + ")";
    try {
        snowflake.execute (
            {sqlText: sql_command}
            );
        return "Succeeded.";   // Return a success/error indicator.
        }
    catch (err)  {
        return "Failed: " + err;   // Return a success/error indicator.
        }
    $$
    ;

------------------------------
-- Create Function
------------------------------

-- Java : Create Function
create or replace function echo_varchar(x varchar)
returns varchar
language java
called on null input
handler='TestFunc.echoVarchar'
target_path='@~/testfunc.jar'
as
'class TestFunc {
  public static String echoVarchar(String x) {
    return x;
  }
}';

create function my_decrement_udf(i numeric(9, 0))
    returns numeric
    language java
    imports = ('@~/my_decrement_udf_package_dir/my_decrement_udf_jar.jar')
    handler = 'my_decrement_udf_package.my_decrement_udf_class.my_decrement_udf_method'
    ;

-- JavaScript : Create Function
CREATE OR REPLACE FUNCTION js_factorial(d double)
  RETURNS double
  LANGUAGE JAVASCRIPT
  STRICT
  AS '
  if (D <= 0) {
    return 1;
  } else {
    var result = 1;
    for (var i = 2; i <= D; i++) {
      result = result * i;
    }
    return result;
  }
  ';
  
-- Python : Create Function
create or replace function py_udf()
  returns variant
  language python
  runtime_version = '3.8'
  packages = ('numpy','pandas','xgboost==1.5.0')
  handler = 'udf'
as $$
import numpy as np
import pandas as pd
import xgboost as xgb
def udf():
    return [np.__version__, pd.__version__, xgb.__version__]
$$;
 
create or replace function dream(i int)
  returns variant
  language python
  runtime_version = '3.8'
  handler = 'sleepy.snore'
  imports = ('@my_stage/sleepy.py'); 
  

-- Scala : Create Function
CREATE OR REPLACE FUNCTION echo_varchar(x VARCHAR)
RETURNS VARCHAR
LANGUAGE SCALA
RUNTIME_VERSION = 2.12
HANDLER='Echo.echoVarchar'
AS
$$
class Echo {
  def echoVarchar(x : String): String = {
    return x
  }
}
$$;

CREATE OR REPLACE FUNCTION echo_varchar(x VARCHAR)
RETURNS VARCHAR
LANGUAGE SCALA
RUNTIME_VERSION = 2.12
IMPORTS = ('@udf_libs/echohandler.jar')
HANDLER='Echo.echoVarchar';

-- SQL : Create Function
CREATE FUNCTION pi_udf()
  RETURNS FLOAT
  AS '3.141592654::FLOAT'
  ;
  
CREATE FUNCTION simple_table_function ()
  RETURNS TABLE (x INTEGER, y INTEGER)
  AS
  $$
    SELECT 1, 2
    UNION ALL
    SELECT 3, 4
  $$
  ;
  

------------------------------
-- Alter Sequence
------------------------------
ALTER SEQUENCE myseq RENAME TO newseq;


------------------------------
-- Alter Procedure
------------------------------

ALTER PROCEDURE IF EXISTS procedure1(FLOAT) RENAME TO procedure2;


--------------------------------
-- Alter function 
-- (https://docs.snowflake.com/en/sql-reference/sql/alter-function)
--------------------------------

ALTER FUNCTION IF EXISTS function1(number) RENAME TO function2;
ALTER FUNCTION function2(number) SET SECURE;

ALTER FUNCTION function4(number) SET api_integration = api_integration_2;
ALTER FUNCTION function5(number) SET max_batch_rows = 100;


-----------------------------
-- Alter Table
-----------------------------
ALTER TABLE t1 ADD SEARCH OPTIMIZATION ON EQUALITY(c1), EQUALITY(c2, c3);
ALTER TABLE t1 ADD SEARCH OPTIMIZATION ON EQUALITY(c1, c2);
ALTER TABLE t1 ADD SEARCH OPTIMIZATION ON EQUALITY(c3, c4);
ALTER TABLE t1 ADD SEARCH OPTIMIZATION ON EQUALITY(c1, c2, c3, c4);

ALTER TABLE t1 RENAME TO tt1;
ALTER TABLE t1 SWAP WITH t2;

DROP INDEX t0.c_idx;

ALTER TABLE t1 ADD COLUMN a2 number;
ALTER TABLE t1 ADD COLUMN a3 number NOT NULL;
ALTER TABLE t1 ADD COLUMN a4 number DEFAULT 0 NOT NULL;

ALTER TABLE t1 RENAME COLUMN a1 TO b1;
ALTER TABLE t1 DROP COLUMN a2;

ALTER TABLE exttable1 ADD COLUMN a1 varchar AS (value:a1::varchar);
ALTER TABLE exttable1 ADD COLUMN mycol varchar as (value:"b"."c"::varchar);


ALTER TABLE exttable1 RENAME COLUMN a1 TO b1;

ALTER TABLE exttable1 DROP COLUMN b1;

ALTER TABLE t1 CLUSTER BY (date, id);

alter table t1 add row access policy rap_t1 on (empl_id);
alter table t1 add row access policy rap_test2 on (cost, item);

alter table t1 drop row access policy rap_v1;

alter table t1
  drop row access policy rap_t1_version_1,
  add row access policy rap_t1_version_2 on (empl_id);


-----------------------------
-- Alter View
-----------------------------

ALTER VIEW view1 RENAME TO view2;
ALTER VIEW view1 SET SECURE;
ALTER VIEW view1 UNSET SECURE;

-- single column
ALTER VIEW user_info_v MODIFY COLUMN ssn_number SET MASKING POLICY ssn_mask_v;

-- multiple columns
ALTER VIEW user_info_v MODIFY
    COLUMN ssn_number SET MASKING POLICY ssn_mask_v
  , COLUMN dob SET MASKING POLICY dob_mask_v
;

-- single column
ALTER VIEW user_info_v modify column ssn_number unset masking policy;

-- multiple columns
ALTER VIEW user_info_v modify
    column ssn_number unset masking policy
  , column dob unset masking policy
;

alter view v1
  add row access policy rap_v1 on (empl_id);

alter view v1
  drop row access policy rap_v1;
  
alter view v1
  drop row access policy rap_v1_version_1,
  add row access policy rap_v1_version_2 on (empl_id);  


-------------------------------------------------
-- Alter Schame
------------------------------------------------

ALTER SCHEMA IF EXISTS schema1 RENAME TO schema2;

ALTER SCHEMA schema2 ENABLE MANAGED ACCESS;


-------------------------------------------------
-- Alter Database
------------------------------------------------

ALTER DATABASE IF EXISTS db1 RENAME TO db2;

ALTER DATABASE mydb1 ENABLE REPLICATION TO ACCOUNTS myorg.account2, myorg.account3;

ALTER DATABASE mydb1 DISABLE REPLICATION;


---------------------------------------------
-- Describe <object>
---------------------------------------------

DESC FUNCTION multiply(number, number);

DESC PROCEDURE my_pi();

DESC PROCEDURE area_of_circle(FLOAT);

DESC SEQUENCE my_sequence;

CREATE TABLE emp (id NUMBER NOT NULL PRIMARY KEY, fname VARCHAR(50), lname VARCHAR(50), location VARCHAR(100));
DESC TABLE emp;
DESC TABLE emp TYPE = STAGE;
desc table ssn_record;

CREATE VIEW emp_view AS SELECT id "Employee Number", lname "Last Name", location "Home Base" FROM emp;
DESC VIEW emp_view;

CREATE SCHEMA sample_schema_2;
USE SCHEMA sample_schema_2;
CREATE TABLE sample_table_1 (i INTEGER);
CREATE VIEW sample_view_1 AS
    SELECT i FROM sample_table_1;
-- CREATE MATERIALIZED VIEW sample_mview_1 AS
--    SELECT i FROM sample_table_1 WHERE i < 100;
DESCRIBE SCHEMA sample_schema_2;

DESC FUNCTION multiply(number, number);

DESC PROCEDURE my_pi();
DESC PROCEDURE area_of_circle(FLOAT);

DESCRIBE SCHEMA sample_schema_2;
DESC SEQUENCE my_sequence;

CREATE TABLE emp (id NUMBER NOT NULL PRIMARY KEY, fname VARCHAR(50), lname VARCHAR(50), location VARCHAR(100));
DESC TABLE emp;
DESC TABLE emp TYPE = STAGE;

desc table ssn_record;

CREATE VIEW emp_view AS SELECT id "Employee Number", lname "Last Name", location "Home Base" FROM emp;
DESC VIEW emp_view;


DESCRIBE DATABASE desc_demo;


-----------------------------------------------------------
-- COMMENT commands
-----------------------------------------------------------

COMMENT ON SCHEMA my_schema IS 'now comment2';

COMMENT ON COLUMN my_table.my_column IS 'now comment4';

COMMENT ON VIEW my_view IS 'now comment6';



-----------------------------------------------------------
-- Show commands
-----------------------------------------------------------

show columns in table dt_test;

SHOW PROCEDURES;
SHOW PROCEDURES LIKE 'area_of_%'; 

SHOW SCHEMAS;
SHOW SCHEMAS HISTORY; 

SHOW TABLES LIKE 'line%' IN tpch.public;
SHOW TABLES HISTORY IN tpch.public;

show primary keys;
show primary keys in account;
show primary keys in database;
show primary keys in database my_database;
show primary keys in schema;
show primary keys in schema my_schema;
show primary keys in schema my_database.my_schema;
show primary keys in my_table;
show primary keys in my_database.my_schema.my_table;

show user functions like 'ALLOWED_REGIONS%' in schema;

SHOW VIEWS LIKE 'line%' IN mydb.public;


SHOW DATABASES; 
SHOW DATABASES HISTORY; 


-----------------------------------------------------------
-- Example of 'Primary Key'
-- From: https://hevodata.com/learn/snowflake-primary-key/
-----------------------------------------------------------

CREATE TABLE pk_tutorial_tab 
( 
	id      INT PRIMARY KEY, 
	FULL_NAME    VARCHAR(10), 
	Location VARCHAR(100) 
); 

CREATE TABLE pk_tutorial_tab1 
( 
	id      INT, 
	FULL_NAME    VARCHAR(10), 
	Location VARCHAR(100) 
); 
ALTER TABLE pk_tutorial_tab1 ADD PRIMARY KEY (id);

-- From: https://docs.snowflake.com/en/sql-reference/sql/create-table-constraint
CREATE TABLE table1 (
    col1 INTEGER NOT NULL
    );
ALTER TABLE table1 
    ADD COLUMN col2 VARCHAR NOT NULL;

ALTER TABLE table1 
    ADD COLUMN col3 VARCHAR NOT NULL CONSTRAINT uniq_col3 UNIQUE NOT ENFORCED;
	
CREATE TABLE table2 (
    col1 INTEGER NOT NULL,
    col2 INTEGER NOT NULL,
    CONSTRAINT pkey_1 PRIMARY KEY (col1, col2) NOT ENFORCED
    );

CREATE TABLE table3 (
    col_a INTEGER NOT NULL,
    col_b INTEGER NOT NULL,
    CONSTRAINT fkey_1 FOREIGN KEY (col_a, col_b) REFERENCES table2 (col1, col2) NOT ENFORCED
    );

-- PK/FK at the same constraint line (out of line PK+FK constraint)
CREATE TABLE order_list (
  order_id INT NOT NULL,
  customer_id INT NOT NULL,
  constraint constraint_name primary key (order_id),
							 foreign key (customer_id) references customer_list (customer_id)
);

create table customer_list
(
	customer_id INT,
	Constraint pk_cust PRIMARY KEY (customer_id)
);

create table orders(customer_id integer primary key);

-- PK/FK at the same column line (in line PK+FK constraint)
CREATE TABLE customers (
  customer_id INT NOT NULL PRIMARY KEY FOREIGN KEY REFERENCES orders (customer_id)
);

CREATE TABLE departments (
    department_id INT ,
    department_name VARCHAR(50),
	CONSTRAINT pk_employees PRIMARY KEY (department_id)
);

CREATE TABLE employees (
    department_id INT ,
    employee_name VARCHAR(50),  	
	CONSTRAINT pk_employees PRIMARY KEY (department_id),
    CONSTRAINT fk_employees
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- https://dwgeek.com/snowflake-primary-key-constraint-and-syntax.html/
CREATE TABLE pk_demo_table1 
  ( 
     id      INT PRIMARY KEY, 
     NAME    VARCHAR(10), 
     address VARCHAR(100),  
	 constraint myPK primary key (id)
  ); 
-- https://dwgeek.com/snowflake-foreign-key-constraint-and-syntax.html/
CREATE TABLE fk_demo_table
  ( 
     id      INT , 
     NAME    VARCHAR(10), 
    address VARCHAR(100)
	-- , constraint myFK foreign key (id) references pk_demo_table1(id)
  );

-- Add FK through 'Alter Table' clause
Alter Table fk_demo_table
	ADD constraint myFK foreign key (id) references pk_demo_table1(id) ; 
	
	
CREATE OR REPLACE DYNAMIC TABLE product
 TARGET_LAG = '20 minutes'
  WAREHOUSE = mywh
  AS
    SELECT product_id, product_name FROM staging_table;
	
CREATE EXTERNAL TABLE et11(
 date_part date AS TO_DATE(SPLIT_PART(metadata$filename, '/', 3)
   || '/' || SPLIT_PART(metadata$filename, '/', 4)
   || '/' || SPLIT_PART(metadata$filename, '/', 5), 'YYYY/MM/DD'),
 timestamp bigint AS (value:timestamp::bigint),
 col2 varchar AS (value:col2::varchar))
 PARTITION BY (date_part)
 LOCATION=@s1/logs/
 AUTO_REFRESH = true
 FILE_FORMAT = (TYPE = PARQUET)
 AWS_SNS_TOPIC = 'arn:aws:sns:us-west-2:001234567890:s3_mybucket';
 
 CREATE EXTERNAL TABLE et12(
  date_part date AS TO_DATE(SPLIT_PART(metadata$filename, '/', 3)
    || '/' || SPLIT_PART(metadata$filename, '/', 4)
    || '/' || SPLIT_PART(metadata$filename, '/', 5), 'YYYY/MM/DD'),
  timestamp bigint AS (value:timestamp::bigint),
  col2 varchar AS (value:col2::varchar))
  PARTITION BY (date_part)
  LOCATION=@s1/logs/
  AUTO_REFRESH = true
  FILE_FORMAT = (TYPE = PARQUET);
  
  CREATE EXTERNAL TABLE et13(
  date_part date AS TO_DATE(SPLIT_PART(metadata$filename, '/', 3)
    || '/' || SPLIT_PART(metadata$filename, '/', 4)
    || '/' || SPLIT_PART(metadata$filename, '/', 5), 'YYYY/MM/DD'),
  timestamp bigint AS (value:timestamp::bigint),
  col2 varchar AS (value:col2::varchar))
  PARTITION BY (date_part)
  INTEGRATION = 'MY_INT'
  LOCATION=@s1/logs/
  AUTO_REFRESH = true
  FILE_FORMAT = (TYPE = PARQUET);
  
  create external table et2(
  col1 date as (parse_json(metadata$external_table_partition):COL1::date),
  col2 varchar as (parse_json(metadata$external_table_partition):COL2::varchar),
  col3 number as (parse_json(metadata$external_table_partition):COL3::number))
  partition by (col1,col2,col3)
  location=@s2/logs/
  partition_type = user_specified
  file_format = (type = parquet);
  
  CREATE EXTERNAL TABLE ext_twitter_feed(
 date_part date AS TO_DATE(SPLIT_PART(metadata$filename, '/', 3)
   || '/' || SPLIT_PART(metadata$filename, '/', 4)
   || '/' || SPLIT_PART(metadata$filename, '/', 5), 'YYYY/MM/DD'),
 timestamp bigint AS (value:timestamp::bigint),
 col2 varchar AS (value:col2::varchar))
 PARTITION BY (date_part)
 LOCATION=@mystage/daily/
 REFRESH_ON_CREATE =  FALSE
 AUTO_REFRESH = FALSE
 FILE_FORMAT = (TYPE = PARQUET)
 TABLE_FORMAT = DELTA;
 
 CREATE EXTERNAL TABLE mytable
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
    FROM TABLE(
      INFER_SCHEMA(
        LOCATION=>'@mystage',
        FILE_FORMAT=>'my_parquet_format'
      )
    )
  )
  LOCATION=@mystage
  FILE_FORMAT=my_parquet_format
  AUTO_REFRESH=false;
  
  CREATE EVENT TABLE my_events;
  
  CREATE ICEBERG TABLE myTable  (amount NUMBER)
  CATALOG='SNOWFLAKE'
  EXTERNAL_VOLUME='myIcebergVolume'
  BASE_LOCATION='relative_path_from_external_volume';
  
  CREATE ICEBERG TABLE myGlueTable
  EXTERNAL_VOLUME='glueCatalogVolume'
  CATALOG='glueCatalogInt'
  CATALOG_TABLE_NAME='myGlueTable'
  CATALOG_NAMESPACE='icebergcatalogdb2';
  
  CREATE ICEBERG TABLE myIcebergTable
  EXTERNAL_VOLUME='icebergMetadataVolume'
  CATALOG='icebergCatalogInt'
  METADATA_FILE_PATH='path/to/metadata/v1.metadata.json';
  
  CREATE OR REPLACE ICEBERG TABLE itable_with_quoted_catalog
  EXTERNAL_VOLUME = '"exvol_lower"'
  CATALOG = '"catint_lower"'
  METADATA_FILE_PATH='path/to/metadata/v1.metadata.json';
  
  CREATE MATERIALIZED VIEW mymv
    COMMENT='Test view'
    AS
    SELECT col1, col2 FROM mytable;
	

CREATE OR REPLACE EXTERNAL FUNCTION local_echo(string_col VARCHAR)
  RETURNS VARIANT
  API_INTEGRATION = demonstration_external_api_integration_01
  AS 'https://xyz.execute-api.us-west-2.amazonaws.com/prod/remote_echo';
  
 CREATE TABLE unique_example_table (
    id INT,
    name VARCHAR(50),
    email VARCHAR(100),
    CONSTRAINT uc_email UNIQUE (email) ENFORCED DISABLE VALIDATE RELY
);


CREATE OR REPLACE PROCEDURE table_returning_procedure(
    start_date DATE,
    end_date DATE
)
RETURNS TABLE (id INT, name STRING, date DATE)
LANGUAGE JAVA
RUNTIME_VERSION = '11'
PACKAGES = ( 'com.snowflake:snowpark:1.2.0' )
IMPORTS = ( '@my_stage/my_library.jar' )
HANDLER = 'com.mycompany.MyClass.getRecords'
EXTERNAL_ACCESS_INTEGRATIONS = ( 'my_integration' )
SECRETS = ('MY_SECRET' = 'my_secret_key')
COMMENT = 'This procedure returns a table with records between start_date and end_date'
AS
$$
    List<Record> records = MyLibrary.getRecords(start_date, end_date, secrets.get("MY_SECRET"));
    return records.stream().map(record -> Row.create(record.getId(), record.getName(), record.getDate())).collect(Collectors.toList());
$$;

CREATE OR REPLACE SECURE TEMPORARY VIEW IF NOT EXISTS secure_temp_view
sensitive_col WITH MASKING POLICY my_masking_policy USING (sensitive_col, condition_col)
                WITH PROJECTION POLICY my_projection_policy
                WITH TAG ( 'sensitivity' = 'high', 'owner' = 'team_xyz' )
COMMENT = 'This is a secure temporary view with masking and projection policies and tags'
AS
SELECT
  col1,
  sensitive_col,
  col3
FROM
  my_database.my_schema.source_table;


CREATE OR REPLACE RECURSIVE GLOBAL TEMPORARY VIEW IF NOT EXISTS recursive_global_temp_view
(
  user_id,
  aggregated_col
)
WITH ROW ACCESS POLICY my_row_access_policy ON (user_id)
WITH AGGREGATION POLICY my_aggregation_policy ENTITY KEY (user_id)
WITH TAG ( 'created_by' = 'admin', 'purpose' = 'data_analysis' )
COPY GRANTS
COMMENT = 'This is a recursive global temporary view with row access and aggregation policies'
AS 
  SELECT
    user_id,
    aggregated_col
  FROM
    my_database.my_schema.source_table;
  
  
CREATE OR REPLACE SECURE MATERIALIZED VIEW secure_materialized_view
(
  col1 ,
  sensitive_col
)
CLUSTER BY (col1)
AS
SELECT
  col1,
  sensitive_col,
  col3
FROM
  source_table;
  
  
  CREATE EXTERNAL TABLE IF NOT EXISTS sales_data
(
  transaction_id INTEGER,
  transaction_date DATE,
  amount DECIMAL(10, 2),
  customer_id INTEGER
)
  LOCATION = 's3://my-snowflake-bucket/data/'
  PARTITION BY (transaction_date, transaction_date)
  PARTITION_TYPE = USER_SPECIFIED
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
  )
  COMMENT = 'External table for sales data stored in S3'
  WITH TAG ( environment = 'production' );


CREATE OR REPLACE EXTERNAL TABLE FormatnameTable
(
  transaction_id INTEGER,
  transaction_date DATE,
  amount DECIMAL(10, 2),
  customer_id INTEGER
)
  LOCATION = '@my_stage/'
  FILE_FORMAT = (
    FORMAT_NAME = 'my_csv_format'
  )
  PARTITION BY (transaction_date,transaction_date)
  PARTITION_TYPE = USER_SPECIFIED
  COMMENT = 'External table for sales data stored in S3'
  WITH TAG ( environment = 'production' );

 ALTER TABLE tables.empl_info SET
  DATA_METRIC_SCHEDULE = '5 MINUTE';
  
  
  ALTER DYNAMIC TABLE product SET TARGET_LAG = DOWNSTREAM;
  
  ALTER DYNAMIC TABLE product CLUSTER BY (date);
  
  ALTER TABLE t1 CLUSTER BY (date, id);
  
  
ALTER EXTERNAL TABLE exttable1 ADD FILES ('path1/sales4.json.gz', 'path1/sales5.json.gz');

ALTER EXTERNAL TABLE exttable1 REMOVE FILES ('path1/sales4.json.gz', 'path1/sales5.json.gz');


ALTER EXTERNAL TABLE et2 ADD PARTITION(col1='2022-01-24', col2='a', col3='12') LOCATION '2022/01';


ALTER MATERIALIZED VIEW my_mv RESUME RECLUSTER;

ALTER MATERIALIZED VIEW my_mv SUSPEND RECLUSTER;

ALTER MATERIALIZED VIEW my_mv DROP CLUSTERING KEY;


INSERT INTO employees
  VALUES
  ('Lysandra','Reeves','1-212-759-3751','New York',10018),
  ('Michael','Arnett','1-650-230-8467','San Francisco',94116);
  
  
  INSERT ALL
  INTO t1
  INTO t1 (c1, c2, c3) VALUES (n2, n1, DEFAULT)
  INTO t2 (c1, c2, c3)
  INTO t2 VALUES (n3, n2, n1)
SELECT n1, n2, n3 from src;

-- If t1 and t2 need to be truncated before inserting, OVERWRITE must be specified
INSERT OVERWRITE ALL
  INTO t1
  INTO t1 (c1, c2, c3) VALUES (n2, n1, DEFAULT)
  INTO t2 (c1, c2, c3)
  INTO t2 VALUES (n3, n2, n1)
SELECT n1, n2, n3 from src;


INSERT ALL
  WHEN n1 > 100 THEN
    INTO t1
  WHEN n1 > 10 THEN
    INTO t1
    INTO t2
  ELSE
    INTO t2
SELECT n1 from src;



MERGE INTO t1 USING t2 ON t1.t1Key = t2.t2Key
    WHEN MATCHED AND t2.marked = 1 THEN DELETE
    WHEN MATCHED AND t2.isNewStatus = 1 THEN UPDATE SET val = t2.newVal, status = t2.newStatus
    WHEN MATCHED THEN UPDATE SET val = t2.newVal
    WHEN NOT MATCHED THEN INSERT (val, status) VALUES (t2.newVal, t2.newStatus);
	
	
UPDATE target SET v = b.v
  FROM (SELECT k, MIN(v) v FROM src GROUP BY k) b
  WHERE target.k = b.k;
  
 DELETE FROM leased_bicycles WHERE bicycle_ID = 105;
 
 
 DELETE FROM leased_bicycles 
    USING returned_bicycles
    WHERE leased_bicycles.bicycle_ID = returned_bicycles.bicycle_ID;
	
TRUNCATE TABLE IF EXISTS temp;

//Undrop
---------
UNDROP DATABASE mydb;

UNDROP DYNAMIC TABLE product;

UNDROP ACCOUNT myaccount123;

UNDROP EXTERNAL VOLUME my_external_volume;

UNDROP ICEBERG TABLE my_iceberg_table;

UNDROP SCHEMA myschema;

UNDROP TABLE t2;

UNDROP TAG cost_center;

CREATE DATABASE restored_db CLONE my_db
  AT (TIMESTAMP => TO_TIMESTAMP_TZ('04/05/2013 01:02:03', 'mm/dd/yyyy hh24:mi:ss'))
  IGNORE TABLES WITH INSUFFICIENT DATA RETENTION;
  
 CREATE SEQUENCE IF NOT EXISTS colnesequence CLONE seq_5;
 
 CREATE CONNECTION myconnection AS REPLICA OF myorg.myaccount1.myconnection;
 
 CREATE USER user1 PASSWORD='abc123' DEFAULT_ROLE = myrole DEFAULT_SECONDARY_ROLES = ('ALL') MUST_CHANGE_PASSWORD = TRUE;
 
CREATE OR REPLACE FILE FORMAT my_csv_format
  TYPE = CSV
  FIELD_DELIMITER = '|'
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null')
  EMPTY_FIELD_AS_NULL = true
  COMPRESSION = gzip;
  
DROP CONNECTION t2;
  
  
ALTER CONNECTION myconnection SET COMMENT = 'New comment for connection';
  
ALTER USER user1 RENAME TO user2;
  
ALTER FILE FORMAT my_format SET FIELD_DELIMITER=',';
  
CREATE SHARE sales_s;
  
CREATE TAG cost_center COMMENT = 'cost_center tag';


CREATE PIPE mypipe2
  AS
  COPY INTO mytable(C1, C2)
  FROM (SELECT $5, $4 FROM @mystage)
  FILE_FORMAT = (TYPE = 'JSON');
  
CREATE PIPE mypipe
  AS
  COPY INTO mytable
  FROM @mystage
  FILE_FORMAT = (TYPE = 'JSON');
  
create or replace api integration demonstration_external_api_integration_01
    api_provider=aws_api_gateway
    api_aws_role_arn='arn:aws:iam::123456789012:role/my_cloud_account_role'
    api_allowed_prefixes=('https://xyz.execute-api.us-west-2.amazonaws.com/production')
    enabled=true;

CREATE APPLICATION hello_snowflake_app
  FROM APPLICATION PACKAGE hello_snowflake_package
  USING VERSION v1;
  
CREATE APPLICATION hello_snowflake_app
  FROM APPLICATION PACKAGE hello_snowflake_package
  USING '@hello_snowflake_code.core.hello_snowflake_stage';
  
CREATE APPLICATION PACKAGE hello_snowflake_package;


CREATE AUTHENTICATION POLICY restrict_client_types_policy
  CLIENT_TYPES = ('SNOWFLAKE_UI')
  COMMENT = 'Auth policy that only allows access through the web interface';
  
CREATE CATALOG INTEGRATION glueCatalogInt
  CATALOG_SOURCE=GLUE
  CATALOG_NAMESPACE='<catalog-namespace>'
  TABLE_FORMAT=ICEBERG
  GLUE_AWS_ROLE_ARN='<arn-for-aws-role-to-assume>'
  GLUE_CATALOG_ID='<catalog-id>'
  GLUE_REGION='<optional-aws-region-of-the-glue-catalog>'
  ENABLED=TRUE;
  
CREATE COMPUTE POOL tutorial_compute_pool
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = CPU_X64_XS;
  
CREATE COMPUTE POOL tutorial_compute_pool
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = CPU_X64_XS
  AUTO_RESUME = FALSE;
  
CREATE DATABASE ROLE d1.dr1 ;


CREATE EXTERNAL VOLUME exvol
  STORAGE_LOCATIONS =
    (
      (
        NAME = 'my-us-east-1'
        STORAGE_PROVIDER = 'GCS'
        STORAGE_BASE_URL = 'gcs://mybucket1/path1/'
        ENCRYPTION=(TYPE='GCS_SSE_KMS' KMS_KEY_ID = '1234abcd-12ab-34cd-56ef-1234567890ab')
      )
    );

CREATE FAILOVER GROUP myfg
    OBJECT_TYPES = DATABASES
    ALLOWED_DATABASES = db1
    ALLOWED_ACCOUNTS = myorg.myaccount2
    REPLICATION_SCHEDULE = '10 MINUTE';
	
CREATE FAILOVER GROUP myfg
    OBJECT_TYPES = USERS, ROLES, WAREHOUSES, RESOURCE MONITORS, INTEGRATIONS
    ALLOWED_INTEGRATION_TYPES = STORAGE INTEGRATIONS, NOTIFICATION INTEGRATIONS
    ALLOWED_ACCOUNTS = myorg.myaccount2
    REPLICATION_SCHEDULE = '10 MINUTE';
	
	
CREATE NETWORK POLICY mypolicy1 ALLOWED_IP_LIST=('192.168.1.0/24')
                                BLOCKED_IP_LIST=('192.168.1.99');

CREATE REPLICATION GROUP myrg
    OBJECT_TYPES = DATABASES
    ALLOWED_DATABASES = db1
    ALLOWED_ACCOUNTS = myorg.myaccount2
    REPLICATION_SCHEDULE = '10 MINUTE';
	
CREATE OR REPLACE RESOURCE MONITOR limiter
  WITH CREDIT_QUOTA = 5000
       NOTIFY_USERS = (JDOE, "Jane Smith", "John Doe")
  TRIGGERS ON 75 PERCENT DO NOTIFY
           ON 100 PERCENT DO SUSPEND
           ON 110 PERCENT DO SUSPEND_IMMEDIATE;
		   
CREATE ROLE myrole;

CREATE STORAGE INTEGRATION gcs_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'GCS'
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('*')
  STORAGE_BLOCKED_LOCATIONS = ('gcs://mybucket3/path3/', 'gcs://mybucket4/path4/');
  
  
CREATE OR REPLACE WAREHOUSE my_wh
  WAREHOUSE_SIZE = 'XSMALL';
  
CREATE OR REPLACE WAREHOUSE my_wh WAREHOUSE_SIZE=LARGE INITIALLY_SUSPENDED=TRUE;

CREATE OR REPLACE CORTEX SEARCH SERVICE mysvc
  ON transcript_text
  ATTRIBUTES region,agent_id
  WAREHOUSE = mywh
  TARGET_LAG = '1 hour'
AS (
  SELECT
      transcript_text,
      date,
      region,
      agent_id
  FROM support_db.public.transcripts_etl
);


CREATE OR REPLACE GIT REPOSITORY snowflake_extensions
  API_INTEGRATION = git_api_integration
  GIT_CREDENTIALS = git_secret
  ORIGIN = 'https://github.com/my-account/snowflake-extensions.git';
  
CREATE OR REPLACE IMAGE REPOSITORY tutorial_repository;

CREATE EXTERNAL LISTING MYLISTING
SHARE MySHARE AS
$$
title: "MyListing"
subtitle: "Subtitle for MyListing"
description: "Description for MyListing"
listing_terms:
  type: "OFFLINE"
targets:
   regions: ["PUBLIC.AWS_US_EAST_1", "PUBLIC.AZURE_WESTUS2"]
usage_examples:
   - title: "this is a test sql"
     description: "Simple example"
     query: "select *"
$$ PUBLISH=FALSE REVIEW=FALSE;

create or replace masking policy json_location_mask as (val variant) returns variant ->
    CASE
      WHEN current_role() IN ('ANALYST') THEN val
      else full_location_masking(val)
      -- else object_insert(val, 'latitude', '**locationMask**', true) -- limited to one value at a time
    END;

CREATE NETWORK RULE corporate_network
  TYPE = AWSVPCEID
  VALUE_LIST = ('vpce-123abc3420c1931')
  MODE = INTERNAL_STAGE
  COMMENT = 'corporate privatelink endpoint';
  
CREATE NOTEBOOK mynotebook
 FROM '@my_db.my_schema.my_stage'
 MAIN_FILE = 'my_notebook_file.ipynb'
 QUERY_WAREHOUSE = my_warehouse;
 
CREATE PACKAGES POLICY yourdb.yourschema.packages_policy_prod_1
  LANGUAGE PYTHON
  ALLOWLIST = ('numpy', 'pandas==1.2.3', ...)
  BLOCKLIST = ('numpy==1.2.3', 'bad_package', ...)
  COMMENT = 'Packages policy for the prod_1 environment';
  
CREATE PASSWORD POLICY PASSWORD_POLICY_PROD_1
    PASSWORD_MIN_LENGTH = 12
    PASSWORD_MAX_LENGTH = 24
    PASSWORD_MIN_UPPER_CASE_CHARS = 2
    PASSWORD_MIN_LOWER_CASE_CHARS = 2
    PASSWORD_MIN_NUMERIC_CHARS = 2
    PASSWORD_MIN_SPECIAL_CHARS = 2
    PASSWORD_MIN_AGE_DAYS = 1
    PASSWORD_MAX_AGE_DAYS = 30
    PASSWORD_MAX_RETRIES = 3
    PASSWORD_LOCKOUT_TIME_MINS = 30
    PASSWORD_HISTORY = 5
    COMMENT = 'production account password policy';
	
CREATE OR REPLACE PROJECTION POLICY project_analyst_only AS ()
  RETURNS PROJECTION_CONSTRAINT ->
    CASE
      WHEN CURRENT_ROLE() = 'ANALYST'
        THEN PROJECTION_CONSTRAINT(ALLOW => true)
      ELSE PROJECTION_CONSTRAINT(ALLOW => false)
    END;
	
create or replace row access policy rap_it as (empl_id varchar) returns boolean ->
  case
      when 'it_admin' = current_role() then true
      else false
  end
;

CREATE OR REPLACE SECRET mysecret
    TYPE = OAUTH2
    API_AUTHENTICATION = mysecurityintegration
    OAUTH_SCOPES = ('useraccount')
    COMMENT = 'secret for the service now connector'
	
CREATE SECRET service_now_creds_oauth_code
    TYPE = OAUTH2
    OAUTH_REFRESH_TOKEN = '34n;vods4nQsdg09wee4qnfvadH'
    OAUTH_REFRESH_TOKEN_EXPIRY_TIME = '2022-01-06 20:00:00'
    API_AUTHENTICATION = sn_oauth;
	
CREATE SECRET service_now_creds_pw
    TYPE = password
    USERNAME = 'jsmith1'
    PASSWORD = 'W3dr@fg*7B1c4j';
	
CREATE SERVICE echo_service
  IN COMPUTE POOL tutorial_compute_pool
  FROM @tutorial_stage
  SPECIFICATION_FILE='echo_spec.yaml'
  MIN_INSTANCES=2
  MAX_INSTANCES=2
  
CREATE SESSION POLICY session_policy_prod_1
  SESSION_IDLE_TIMEOUT_MINS = 30
  SESSION_UI_IDLE_TIMEOUT_MINS = 30
  COMMENT = 'session policy for use in the prod_1 environment'
;

CREATE SNAPSHOT snapshot_0
  FROM SERVICE example_service
  VOLUME "data"
  INSTANCE 0
  COMMENT='new snapshot';
  
CREATE STAGE my_int_stage
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');
  
CREATE TEMPORARY STAGE my_temp_int_stage;

CREATE TEMPORARY STAGE my_int_stage
  FILE_FORMAT = my_csv_format;
  
CREATE STAGE mystage
   DIRECTORY = (ENABLE = TRUE)
   FILE_FORMAT = myformat;
   
CREATE STAGE my_ext_stage1
  URL='s3://load/files/ '
  CREDENTIALS=(AWS_KEY_ID='1a2b3c' AWS_SECRET_KEY='4x5y6z');
  
CREATE STAGE my_ext_stage
  URL='s3://load/files/ '
  STORAGE_INTEGRATION = myint;
  
CREATE STREAM mystream ON TABLE mytable;

CREATE STREAM mystream ON TABLE mytable BEFORE (TIMESTAMP => TO_TIMESTAMP(40*365*86400));

CREATE STREAM mystream ON VIEW myview;

CREATE STREAMLIT hello_streamlit
ROOT_LOCATION = '@streamlit_db.streamlit_schema.streamlit_stage'
MAIN_FILE = '/streamlit_main.py'
QUERY_WAREHOUSE = my_warehouse;

CREATE TAG cost_center COMMENT = 'cost_center tag';

/* CREATE TASK t1
  SCHEDULE = 'USING CRON 0 9-17 * * SUN America/Los_Angeles'
  USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
  AS
    SELECT CURRENT_TIMESTAMP;
	
CREATE TASK mytask_hour
  WAREHOUSE = mywh
  SCHEDULE = 'USING CRON 0 9-17 * * SUN America/Los_Angeles'
  AS
    SELECT CURRENT_TIMESTAMP;
	
CREATE TASK t1
  SCHEDULE = '60 MINUTE'
  TIMESTAMP_INPUT_FORMAT = 'YYYY-MM-DD HH24'
  USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
  AS
    INSERT INTO mytable(ts) VALUES(CURRENT_TIMESTAMP);
	
CREATE TASK mytask1
  WAREHOUSE = mywh
  SCHEDULE = '5 minute'
  WHEN
    SYSTEMSTREAM_HAS_DATA('MYSTREAM')
  AS
    INSERT INTO mytable1(id,name) SELECT id, name FROM mystream WHERE METADATA$ACTION = 'INSERT';
	
CREATE TASK task5
  AFTER task2, task3, task4
AS
  INSERT INTO t1(ts) VALUES(CURRENT_TIMESTAMP);
  
CREATE TASK my_copy_task
  WAREHOUSE = mywh
  SCHEDULE = '60 minute'
  AS
    CALL my_unload_sp();
	
CREATE OR REPLACE TASK test_logging
  USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
  SCHEDULE = 'USING CRON  0 * * * * America/Los_Angeles'
  AS
    BEGIN
      ALTER SESSION SET TIMESTAMP_OUTPUT_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF';
      SELECT CURRENT_TIMESTAMP;
    END;
	
CREATE TASK t1
  USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
  SCHEDULE = '2 minute'
  AS
    EXECUTE IMMEDIATE
    $$
    DECLARE
      radius_of_circle float;
      area_of_circle float;
    BEGIN
      radius_of_circle := 3;
      area_of_circle := pi() * radius_of_circle * radius_of_circle;
      return area_of_circle;
    END;
    $$; */
	
ALTER SHARE sales_s SET COMMENT='This share contains sales data for 2017';

ALTER SHARE sales_s REMOVE ACCOUNT=<orgname.accountname>;

ALTER SHARE sales_s ADD ACCOUNTS=<orgname.accountname1>,<orgname.accountname2>;


ALTER TAG cost_center RENAME TO cost_center_na;

ALTER APPLICATION SALES_APP
SET TAG department = 'Sales';

ALTER APPLICATION PACKAGE hello_snowflake_package SET
  COMMENT = 'Altered the Hello Snowflake application.';
  
ALTER AUTHENTICATION POLICY restrict_client_types_policy SET CLIENT_TYPES = ('SNOWFLAKE_UI', 'SNOWSQL');

ALTER COMPUTE POOL tutorial_compute_pool SET
  MAX_NODES = 5
  AUTO_RESUME = FALSE 

ALTER DATABASE ROLE d1.dbr2 SET COMMENT = 'New comment for database role';

ALTER DATABASE ROLE d1.dr1 RENAME TO d1.dbr2;

ALTER EXTERNAL ACCESS INTEGRATION IF EXISTS dev_integration
  SET ALLOWED_AUTHENTICATION_SECRETS = (my_new_secret);
  
ALTER EXTERNAL ACCESS INTEGRATION IF EXISTS dev_integration_disabled
  SET ENABLED = FALSE;

ALTER EXTERNAL ACCESS INTEGRATION IF EXISTS dev_integration_disabled
  SET COMMENT = 'Disabled until the end of the Q1.';
  
ALTER EXTERNAL VOLUME exvol1
  ADD STORAGE_LOCATION =
    (
      NAME = 'my-s3-us-central-2'
      STORAGE_PROVIDER = 'S3'
      STORAGE_BASE_URL = 's3://my_bucket_us_central-1/'
      STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::123456789012:role/myrole'
    );
ALTER EXTERNAL VOLUME exvol3
  ADD STORAGE_LOCATION =
    (
      NAME = 'my-azure-japaneast'
      STORAGE_PROVIDER = 'AZURE'
      STORAGE_BASE_URL = 'azure://sfcdev1.blob.core.windows.net/my_container_japaneast/'
      AZURE_TENANT_ID = 'a9876545-4321-987b-b23c-2kz436789d0'
    );
	
ALTER FAILOVER GROUP myfg ADD myorg.myaccount3 TO ALLOWED_ACCOUNTS;	

ALTER FAILOVER GROUP myfg SET
  OBJECT_TYPES = USERS, ROLES, WAREHOUSES, RESOURCE MONITORS, DATABASES
  ALLOWED_DATABASES = db1;
  
ALTER FAILOVER GROUP myfg
  ADD db2, db3 TO ALLOWED_DATABASES;
  
ALTER FAILOVER GROUP myfg
  MOVE DATABASES db3 TO FAILOVER GROUP myfg2;
  
ALTER FAILOVER GROUP myfg3 SET
  OBJECT_TYPES = DATABASES, SHARES;
  
ALTER FAILOVER GROUP myfg
  REMOVE databases FROM OBJECT_TYPES;
  
ALTER FAILOVER GROUP myfg
  SET REPLICATION_SCHEDULE = '15 MINUTE';
  
ALTER NETWORK POLICY mypolicy1 SET ALLOWED_IP_LIST=('192.168.1.0/24','192.168.255.100')
                                   BLOCKED_IP_LIST=('192.168.1.99');
								   
ALTER REPLICATION GROUP myrg ADD myorg.myaccount3 TO ALLOWED_ACCOUNTS;

ALTER REPLICATION GROUP myrg SET
  OBJECT_TYPES = DATABASES, SHARES;
ALTER RESOURCE MONITOR limiter
  SET CREDIT_QUOTA=2000
  TRIGGERS ON 80 PERCENT DO NOTIFY
           ON 100 PERCENT DO SUSPEND_IMMEDIATE;
		   
ALTER RESOURCE MONITOR limiter
  SET CREDIT_QUOTA = 2000
      NOTIFY_USERS = (JDOE, "Jane Smith", "John Doe")
  TRIGGERS ON 80 PERCENT DO NOTIFY
           ON 100 PERCENT DO SUSPEND_IMMEDIATE	

ALTER STORAGE INTEGRATION myint SET ENABLED = TRUE;

ALTER ROLE role1 RENAME TO role2;

ALTER ROLE myrole SET COMMENT = 'New comment for role';

ALTER WAREHOUSE my_wh RESUME;

ALTER WAREHOUSE my_wh SET warehouse_size=MEDIUM;


ALTER AGGREGATION POLICY my_policy RENAME TO agg_policy_table1;

ALTER AGGREGATION POLICY my_policy SET BODY -> AGGREGATION_CONSTRAINT(MIN_GROUP_SIZE=>2);		

ALTER ALERT my_alert SUSPEND;

ALTER CORTEX SEARCH SERVICE mysvc SET WAREHOUSE = my_new_wh;  

ALTER CORTEX SEARCH SERVICE mysvc SET COMMENT = 'new_comment'; 

ALTER CORTEX SEARCH SERVICE mysvc SET TARGET_LAG = '1 hour';

ALTER GIT REPOSITORY snowflake_extensions FETCH;

ALTER LISTING MYLISTING
AS
  $$
  title: "MyListing"
  subtitle: "Subtitle for MyListing"
  description: "Description or MyListing"
  listing_terms:
    type: "STANDARD"
  targets:
    accounts: ["Org1.Account1"]
  usage_examples:
     - title: "this is a test sql"
       description: "Simple example"
       query: "select *"
  $$
  
ALTER LISTING MYLISTING PUBLISH;

ALTER LISTING MYLISTING UNPUBLISH;

ALTER LISTING MYLISTING SET COMMENT = 'My listing is ready!';

ALTER MASKING POLICY email_mask SET BODY ->
  CASE
    WHEN current_role() IN ('ANALYST') THEN VAL
    ELSE sha2(val, 512)
  END;
  
ALTER NETWORK RULE cloud_network SET VALUE_LIST = ('47.88.25.32/27');

ALTER NETWORK RULE external_access_rule SET VALUE_LIST = ('example.com', 'company.com:443');

ALTER NOTEBOOK my_notebook RENAME notebook_v2;

ALTER NOTEBOOK my_notebook UNSET QUERY_WAREHOUSE;

ALTER notebook my_notebook ADD LIVE VERSION FROM LAST;

ALTER NOTEBOOK my_notebook COMMIT;

ALTER PACKAGES POLICY packages_policy_prod_1 SET ALLOWLIST = ('pandas==1.2.3');

ALTER PASSWORD POLICY password_policy_prod_1 SET PASSWORD_MAX_RETRIES = 3;	

alter pipe mypipe SET PIPE_EXECUTION_PAUSED = true;

ALTER PIPE mypipe REFRESH PREFIX='d1/' MODIFIED_AFTER='2018-07-30T13:56:46-07:00';

ALTER PROJECTION POLICY mypolicy RENAME TO proj_policy_acctnumber;

ALTER ROW ACCESS POLICY rap_table_employee_info SET BODY -> BOOLAND;

ALTER SECRET service_now_creds_pw SET COMMENT = 'production secret for servicenow';

ALTER SERVICE example_service
  RESTORE VOLUME "myvolume"
  INSTANCES 0,2
  FROM SNAPSHOT my_snapshot;
  
ALTER SERVICE echo_service SET MIN_INSTANCES=3 MAX_INSTANCES=5;

ALTER SESSION POLICY session_policy_prod_1 SET SESSION_UI_IDLE_TIMEOUT_MINS = 15;

ALTER SNAPSHOT example_snapshot SET COMMENT = 'sample comment.';

ALTER STAGE my_ext_stage
SET URL='s3://loading/files/new/ '
COPY_OPTIONS = (ON_ERROR='skip_file');

ALTER STAGE my_ext_stage SET STORAGE_INTEGRATION = myint;

ALTER STAGE my_ext_stage SET CREDENTIALS=(AWS_KEY_ID='d4c3b2a1' AWS_SECRET_KEY='z9y8x7w6');

ALTER STAGE my_ext_stage3 SET ENCRYPTION=(TYPE='AWS_SSE_S3');

ALTER STAGE mystage SET DIRECTORY = ( ENABLE = TRUE );

ALTER STAGE mystage REFRESH SUBPATH = 'data';

ALTER STREAM mystream SET COMMENT = 'New comment for stream';

DROP APPLICATION hello_snowflake_app;

DROP APPLICATION PACKAGE hello_snowflake_app;

DROP AUTHENTICATION POLICY my_auth_policy;

DROP EXTERNAL VOLUME my_external_volume;

DROP CATALOG INTEGRATION myInt;

DROP CATALOG INTEGRATION IF EXISTS myInt;
	
DROP COMPUTE POOL tutorial_compute_pool;

DROP DATABASE ROLE d1.dr1;	
	
DROP FAILOVER GROUP IF EXISTS myfg;

DROP EXTERNAL VOLUME my_external_volume;

DROP INTEGRATION t2;

DROP NETWORK POLICY mypolicy;

DROP RESOURCE MONITOR IF EXISTS my_rm;

DROP REPLICATION GROUP myrg;

DROP ROLE myrole;	

DROP AGGREGATION POLICY my_aggpolicy;

DROP ALERT IF EXISTS my_alert;

DROP CORTEX SEARCH SERVICE mysvc;

DROP IMAGE REPOSITORY tutorial_repository;
	
DROP GIT REPOSITORY my_repository;

DROP LISTING IF EXISTS MY_LISTING

DROP MASKING POLICY ssn_mask;

DROP NETWORK RULE myrule;

DROP NOTEBOOK mynotebook;

DROP PASSWORD POLICY password_policy_production_1;
	
DROP PROJECTION POLICY do_not_project;

DROP PIPE mypipe;

DROP ROW ACCESS POLICY rap_table_employee_info;

DROP SECRET service_now_creds;

DROP SERVICE my_tutorial;

DROP SESSION POLICY session_policy_production_1;

DROP SNAPSHOT example_snapshot;

DROP STREAM IF EXISTS t2;

DROP STAGE my_stage;

DROP TASK IF EXISTS t2;

DESC APPLICATION hello_snowflake_app;
DESC ICEBERG TABLE my_iceberg_table ;
DESC AUTHENTICATION POLICY my_auth_policy;
DESC CATALOG INTEGRATION my_catalog_integration;
DESCRIBE COMPUTE POOL tutorial_compute_pool;
DESCRIBE DATABASE desc_demo;
DESC EXTERNAL VOLUME my_external_volume;
//DESC INTEGRATION myint;
DESC NETWORK POLICY mypolicy;
DESC SHARE sales_s;
DESCRIBE WAREHOUSE temporary_warehouse;
DESC AGGREGATION POLICY my_aggpolicy;
DESC ALERT my_alert;
DESCRIBE CORTEX SEARCH SERVICE mysvc;
DESC DYNAMIC TABLE product;
DESC EVENT TABLE my_logged_events;
DESC EXTERNAL TABLE emp;
DESC FILE FORMAT my_csv_format;
DESC FUNCTION multiply(number, number);
DESCRIBE GIT REPOSITORY snowflake_extensions;
DESC ICEBERG TABLE my_iceberg_table ;
DESC LISTING MYLISTING;
DESC MASKING POLICY ssn_mask;
DESC MATERIALIZED VIEW emp_view;
DESC NETWORK RULE myrule;
DESCRIBE NOTEBOOK mybook;
DESC PACKAGES POLICY packages_policy_prod_1;
DESC PASSWORD POLICY password_policy_prod_1;
desc pipe mypipe;
DESC PROCEDURE area_of_circle(FLOAT);
DESC PROJECTION POLICY do_not_project;
DESC ROW ACCESS POLICY rap_table_employee_info;
DESCRIBE SCHEMA sample_schema_2;
DESC SECRET service_now_creds_pw;
DESC SEQUENCE my_sequence;
DESCRIBE SERVICE my_service_with_ebs_volume;
DESC SESSION POLICY session_policy_prod_1;
DESC SNAPSHOT my_snapshot;
DESC STAGE my_s3_stage;
DESC STREAM mystream;
DESC TABLE emp TYPE = STAGE;
DESC TASK mytask;
DESC VIEW emp_view;

SHOW ACCOUNTS LIKE 'myaccount%';
SHOW GLOBAL ACCOUNTS LIKE 'myaccount%';
SHOW ORGANIZATION ACCOUNTS LIKE 'myaccount%';
SHOW MANAGED ACCOUNTS;
SHOW FUNCTIONS LIKE 'SQUARE';
SHOW ROLES;
SHOW GRANTS ON DATABASE sales;
SHOW GRANTS TO ROLE analyst;
SHOW GRANTS TO USER demo;
SHOW GRANTS OF ROLE analyst;
SHOW FUTURE GRANTS IN SCHEMA sales.public;
SHOW GRANTS TO SNOWFLAKE.CORE.BUDGET ROLE cost.budgets.my_budget!ADMIN;
SHOW GIT BRANCHES IN snowflake_extensions;
SHOW GIT REPOSITORIES;
SHOW GIT TAGS IN snowflake_extensions;
SHOW EXTERNAL FUNCTIONS LIKE 'SQUARE%';
SHOW DATA METRIC FUNCTIONS;
show user functions like 'ALLOWED_REGIONS%' in schema;
SHOW PROCEDURES LIKE 'area_of_%';
SHOW STREAMS LIKE 'line%' IN tpch.public;
SHOW TASKS LIKE 'line%' IN tpch.public;
SHOW CLASSES IN DATABASE SNOWFLAKE;
SHOW CORTEX SEARCH SERVICES;
SHOW LISTINGS LIMIT 10 FROM 'MYLISTING%'
SHOW LISTINGS LIKE 'MYLISTING%'
SHOW AUTHENTICATION POLICIES;
SHOW NETWORK RULES;
SHOW PACKAGES POLICIES;
SHOW PASSWORD POLICIES;
SHOW SESSION POLICIES;
SHOW MASKING POLICIES IN SCHEMA governance.policies;
SHOW ROW ACCESS POLICIES;
SHOW TAGS IN SCHEMA my_db.my_schema;
SHOW EXTERNAL VOLUMES LIKE 'aws%';
show pipes;
show channels;
SHOW ALERTS;
SHOW APPLICATIONS;
SHOW APPLICATION PACKAGES;
SHOW RELEASE DIRECTIVES test IN APPLICATION PACKAGE hello_snowflake_package;
SHOW TELEMETRY EVENT DEFINITIONS IN APPLICATION hello_snowflake;
SHOW VERSIONS IN APPLICATION PACKAGE hello_snowflake_app;
SHOW IMAGES IN IMAGE REPOSITORY tutorial_db.data_schema.tutorial_repository;
SHOW COMPUTE POOLS LIKE '%my_pool%' LIMIT 2;
SHOW SERVICES;
SHOW SERVICES LIKE '%echo%' LIMIT 1;
SHOW ENDPOINTS IN SERVICE echo_service;
SHOW SERVICE INSTANCES IN SERVICE echo_service;
SHOW ROLES IN SERVICE echo_service;
SHOW SNAPSHOTS;
SHOW CONNECTIONS LIKE 'test%';
SHOW CATALOG INTEGRATIONS LIKE 'demo%';
SHOW DELEGATED AUTHORIZATIONS BY USER jsmith;
SHOW DELEGATED AUTHORIZATIONS TO SECURITY INTEGRATION my_oauth_int2;
SHOW REPLICATION DATABASES WITH PRIMARY myorg.account1.mydb1;
SHOW REPLICATION GROUPS IN ACCOUNT myaccount1;
SHOW SHARES IN REPLICATION GROUP myrg;
SHOW DATABASES IN FAILOVER GROUP myfg;
SHOW PARAMETERS;
SHOW PARAMETERS IN WAREHOUSE testwh;
SHOW PARAMETERS IN DATABASE;
SHOW SHARES STARTS WITH 'SNOW' LIMIT 5 FROM 'A';
SHOW EXTERNAL TABLES LIKE 'line%' IN tpch.public;
SHOW MATERIALIZED VIEWS LIKE 'mv1%';
SHOW ICEBERG TABLES LIKE 'glue%' IN tpch.public;

CREATE TABLE test_weight_nulla (
    weight_grams INTEGER,
    CONSTRAINT chk_weight CHECK (weight_grams IS NULL OR weight_grams >= 0)
);

CREATE TABLE test_weight_not_null (
    weight_grams INTEGER NOT NULL,
    CONSTRAINT chk_weight CHECK (weight_grams >= 0)
    );

CREATE TABLE test_weight_nulls (
    weight_grams INTEGER
        CHECK (weight_grams IS NULL OR weight_grams >= 0)
);

CREATE TABLE test_weight_nulld (
    weight_grams INTEGER
        CONSTRAINT chk_weight
        CHECK (weight_grams IS NULL OR weight_grams >= 0)
);

CREATE TABLE test_weight_not_nullc (
    weight_grams INTEGER NOT NULL
        CONSTRAINT chk_weight
        CHECK (weight_grams >= 0)
);

CREATE TABLE test_weight_not_nullb (
    weight_grams INTEGER NOT NULL,
    CONSTRAINT chk_weight
        CHECK (weight_grams >= 0)
);

ALTER TABLE test_weight_nulla
ADD CHECK (weight_grams IS NULL OR weight_grams >= 0);

ALTER TABLE test_weight_not_null
ADD CONSTRAINT chk_weight
CHECK (weight_grams >= 0);

ALTER TABLE IF EXISTS test_weight_nulla
ADD CONSTRAINT chk_weight_null
CHECK (weight_grams IS NULL OR weight_grams >= 0);

ALTER TABLE test_weight_not_null
MODIFY CONSTRAINT chk_weight (weight_grams)
NOT ENFORCED;

ALTER TABLE test_weight_not_null
RENAME CONSTRAINT chk_weight TO chk_weight_new;

ALTER TABLE test_weight_not_null
DROP CONSTRAINT chk_weight (weight_grams) CASCADE;

ALTER TABLE test_weight_nulla
ADD CONSTRAINT chk_weight_null
CHECK (weight_grams IS NULL OR weight_grams >= 0);

ALTER TABLE test_weight_not_null
ADD CONSTRAINT chk_weight_not_null
CHECK (weight_grams >= 0);