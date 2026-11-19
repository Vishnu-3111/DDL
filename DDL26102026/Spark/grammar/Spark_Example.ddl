---------CREATE USE DATASOURCE SYNTAX-------

--Use data source
CREATE TABLE student1 (id INT, name STRING, age INT) USING CSV;

--Use data from another table
CREATE TABLE student_copy USING CSV
    AS SELECT * FROM student;
  
--Omit the USING clause, which uses the default data source (parquet by default)
CREATE TABLE student2 (id INT, name STRING, age INT);

--Use parquet data source with parquet storage options
--The columns 'id' and 'name' enable the bloom filter during writing parquet file,
--column 'age' does not enable
CREATE TABLE student_parquet(id INT, name STRING, age INT) USING PARQUET
    OPTIONS (
      'parquet.bloom.filter.enabled'='true',
      'parquet.bloom.filter.enabled#age'='false'
    );

--Specify table comment and properties
CREATE TABLE student3 (id INT, name STRING, age INT) USING CSV
    COMMENT 'this is a comment'
    TBLPROPERTIES ('foo'='bar');

--Specify table comment and properties with different clauses order
CREATE TABLE student4 (id INT, name STRING, age INT) USING CSV
    TBLPROPERTIES ('foo'='bar')
    COMMENT 'this is a comment';

--Create partitioned and bucketed table
CREATE TABLE student5 (id INT, name STRING, age INT)
    USING CSV
    PARTITIONED BY (age)
    CLUSTERED BY (Id) INTO 4 buckets;

--Create partitioned and bucketed table through CTAS
CREATE TABLE student_partition_bucket
    USING parquet
    PARTITIONED BY (age)
    CLUSTERED BY (id) INTO 4 buckets
    AS SELECT * FROM student;

--Create bucketed table through CTAS and CTE

/* CREATE TABLE student_bucket
    USING parquet
    CLUSTERED BY (id) INTO 4 buckets (
    WITH tmpTable AS (
        SELECT * FROM student WHERE id > 100
    )
    SELECT * FROM tmpTable
);   need to implement   */ 




---------CREATE HIVE FORMAT SYNTAX-------


--Use hive format
CREATE TABLE Student (id INT, name STRING, age INT) STORED AS ORC;

--Use data from another table
CREATE TABLE student_copy STORED AS ORC
    AS SELECT * FROM Student;

--Specify table comment and properties
CREATE TABLE Student2 (id INT, name STRING, age INT)
    COMMENT 'this is a comment'
    STORED AS ORC
    TBLPROPERTIES ('foo'='bar');  

--Specify table comment and properties with different clauses order
CREATE TABLE student6 (id INT, name STRING, age INT)
    STORED AS ORC
    TBLPROPERTIES ('foo'='bar')
    COMMENT 'this is a comment';

--Create partitioned table
CREATE TABLE student7 (id INT, name STRING)
    PARTITIONED BY (age INT)
    STORED AS ORC;

--Create partitioned table with different clauses order
CREATE TABLE student8 (id INT, name STRING)
    STORED AS ORC
    PARTITIONED BY (age INT);

--Use Row Format and file format
CREATE TABLE `test`.student9 (id INT, name STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
    STORED AS TEXTFILE;

--Use complex datatype
 CREATE EXTERNAL TABLE family1(
        name STRING,
        friends ARRAY<STRING>,
        children MAP<STRING, INT>,
        address STRUCT<street: STRING, city: STRING>
    )
    ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' ESCAPED BY '?'
    COLLECTION ITEMS TERMINATED BY '_'
    MAP KEYS TERMINATED BY ':'
    LINES TERMINATED BY '\n'
    NULL DEFINED AS 'foonull'
    STORED AS TEXTFILE
    LOCATION '/tmp/family/';

--Use predefined custom SerDe
CREATE TABLE avroExample
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.avro.AvroSerDe'
    STORED AS INPUTFORMAT 'org.apache.hadoop.hive.ql.io.avro.AvroContainerInputFormat'
        OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.avro.AvroContainerOutputFormat'
    
			; 

--Use personalized custom SerDe(we may need to `ADD JAR xxx.jar` first to ensure we can find the serde_class,
--or you may run into `CLASSNOTFOUND` exception)
--ADD JAR /tmp/hive_serde_example.jar;

CREATE EXTERNAL TABLE family (id INT, name STRING)
    ROW FORMAT SERDE 'com.ly.spark.serde.SerDeExample'
    STORED AS INPUTFORMAT 'com.ly.spark.example.serde.io.SerDeExampleInputFormat'
        OUTPUTFORMAT 'com.ly.spark.example.serde.io.SerDeExampleOutputFormat'
    LOCATION '/tmp/family/';

--Use `CLUSTERED BY` clause to create bucket table without `SORTED BY`
CREATE TABLE clustered_by_test1 (ID INT, AGE STRING)
    CLUSTERED BY (ID)
    INTO 4 BUCKETS
    STORED AS ORC

--Use `CLUSTERED BY` clause to create bucket table with `SORTED BY`
CREATE TABLE clustered_by_test2 (ID INT, NAME STRING)
    PARTITIONED BY (YEAR STRING)
    CLUSTERED BY (ID, NAME)
    SORTED BY (ID ASC)
    INTO 3 BUCKETS
    STORED AS PARQUET
	
	
---------CREATE TABLE USING LIKE SYNTAX-------
	
-- Create table using an existing table
CREATE TABLE Student_Dupli like test.`Student`;

-- Create table like using a data source
CREATE TABLE Student_Dupli like `sample`.`Student` USING CSV;

-- Table is created as external table at the location specified
CREATE TABLE Student_Dupli like check.Student location  '/root1/home';

-- Create table like using a rowformat
CREATE TABLE Student_Dupli like Student
    ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
    STORED AS TEXTFILE
    TBLPROPERTIES ('owner'='xxxx');	



---------CREATE VIEW SYNTAX-------
	
-- Create or replace view for `experienced_employee` with comments.
CREATE OR REPLACE VIEW experienced_employee
    (ID COMMENT 'Unique identification number', Name) 
    COMMENT 'View for experienced employees'
    AS SELECT id, name FROM all_employee
        WHERE working_years > 5;

-- Create a global temporary view `subscribed_movies` if it does not exist.
CREATE GLOBAL TEMPORARY VIEW IF NOT EXISTS subscribed_movies 
    AS SELECT mo.member_id, mb.full_name, mo.movie_title
        FROM movies AS mo INNER JOIN members AS mb 
        ON mo.member_id = mb.id;	
		
		
		

---------CREATE FUNTION SYNTAX-------

-- 1. Create a simple UDF `SimpleUdf` that increments the supplied integral value by 10.
--    import org.apache.hadoop.hive.ql.exec.UDF;
--    public class SimpleUdf extends UDF {
--      public int evaluate(int value) {
--        return value + 10;
--      }
--    }
-- 2. Compile and place it in a JAR file called `SimpleUdf.jar` in /tmp.

-- Create a table called `test` and insert two rows.
CREATE TABLE test(c1 INT);

-- Create a permanent function called `simple_udf`. 
CREATE FUNCTION simple_udf AS 'SimpleUdf'
    USING JAR '/tmp/SimpleUdf.jar';


-- Created a temporary function.
CREATE TEMPORARY FUNCTION simple_temp_udf AS 'SimpleUdf' 
    USING JAR '/tmp/SimpleUdf.jar';

-- Verify that the newly created temporary function is in the registry.
-- Please note that the temporary function does not have a qualified


-- 1. Modify `SimpleUdf`'s implementation to add supplied integral value by 20.
--    import org.apache.hadoop.hive.ql.exec.UDF;
  
--    public class SimpleUdfR extends UDF {
--      public int evaluate(int value) {
--        return value + 20;
--      }
--    }
-- 2. Compile and place it in a jar file called `SimpleUdfR.jar` in /tmp.

-- Replace the implementation of `simple_udf`
CREATE OR REPLACE FUNCTION simple_udf AS 'SimpleUdfR'
    USING JAR '/tmp/SimpleUdfR.jar';
	
ALTER DATABASE inventory SET DBPROPERTIES ('Edited-by' = 'John', 'Edit-date' = '01/01/2001');

ALTER DATABASE inventory SET LOCATION 'file:/temp/spark-warehouse/new_inventory.db';

ALTER TABLE Student RENAME TO StudentInfo;

ALTER TABLE default.StudentInfo PARTITION (age='10') RENAME TO PARTITION (age='15');

ALTER TABLE StudentInfo ADD columns (LastName string, DOB timestamp);

ALTER TABLE StudentInfo DROP columns (LastName, DOB);

ALTER TABLE StudentInfo RENAME COLUMN name TO FirstName;

ALTER TABLE StudentInfo ALTER COLUMN FirstName COMMENT "new comment";

ALTER TABLE StudentInfo REPLACE COLUMNS (name string, ID int COMMENT 'new comment');

ALTER TABLE StudentInfo ADD IF NOT EXISTS PARTITION (age=18);

ALTER TABLE StudentInfo DROP IF EXISTS PARTITION (age=18);

ALTER TABLE StudentInfo ADD IF NOT EXISTS PARTITION (age=18) PARTITION (age=20);


ALTER TABLE loc_orc SET fileformat orc;

ALTER TABLE p1 partition (month=2, day=2) SET fileformat parquet;
-- Change the file Location
ALTER TABLE dbx.tab1 PARTITION (a='1', b='2') SET LOCATION '/path/to/part/ways'

-- SET SERDE/ SERDE Properties
ALTER TABLE test_tab SET SERDE 'org.apache.hadoop.hive.serde2.columnar.LazyBinaryColumnarSerDe';

ALTER TABLE dbx.tab1 SET SERDE 'org.apache.hadoop' WITH SERDEPROPERTIES ('k' = 'v', 'kay' = 'vee')

-- SET TABLE PROPERTIES
ALTER TABLE dbx.tab1 SET TBLPROPERTIES ('winner' = 'loser');

-- SET TABLE COMMENT Using SET PROPERTIES
ALTER TABLE dbx.tab1 SET TBLPROPERTIES ('comment' = 'A table comment.');

-- Alter TABLE COMMENT Using SET PROPERTIES
ALTER TABLE dbx.tab1 SET TBLPROPERTIES ('comment' = 'This is a new comment.');

-- DROP TABLE PROPERTIES
ALTER TABLE dbx.tab1 UNSET TBLPROPERTIES ('winner');

-- RECOVER PARTITIONS
ALTER TABLE dbx.tab1 RECOVER PARTITIONS;

ALTER VIEW tempdb1.v1 RENAME TO tempdb1.v2;

ALTER VIEW tempdb1.v2 SET TBLPROPERTIES ('created.by.user' = "John", 'created.date' = '01-01-2001' );

ALTER VIEW tempdb1.v2 UNSET TBLPROPERTIES ('created.by.user', 'created.date');

ALTER VIEW tempdb1.v2 AS SELECT * FROM tempdb1.v1;

CREATE DATABASE customer_db;
CREATE DATABASE IF NOT EXISTS customer_db;
CREATE DATABASE IF NOT EXISTS customer_db COMMENT 'This is customer database' LOCATION '/user'
    WITH DBPROPERTIES (ID=001, Name='John');

-- Drop the database and it's tables
DROP DATABASE inventory_db CASCADE;

-- Drop the database using IF EXISTS
DROP DATABASE IF EXISTS inventory_db CASCADE;

DROP FUNCTION test_avg;

DROP TEMPORARY FUNCTION IF EXISTS test_avg;
DROP TABLE employeetable;

-- Assumes a table named `employeetable` exists in the `userdb` database
DROP TABLE userdb.employeetable;

-- Assumes a table named `employeetable` does not exist.
-- Throws exception
DROP TABLE employeetable;

-- Assumes a table named `employeetable` does not exist,Try with IF EXISTS
-- this time it will not throw exception
DROP TABLE IF EXISTS employeetable;

-- Completely purge the table skipping trash.
DROP TABLE employeetable PURGE;

-- Assumes a view named `employeeView` exists.
DROP VIEW employeeView;

-- Assumes a view named `employeeView` exists in the `userdb` database
DROP VIEW userdb.employeeView;

-- Assumes a view named `employeeView` does not exist.
-- Throws exception
DROP VIEW employeeView;

-- Assumes a view named `employeeView` does not exist,Try with IF EXISTS
-- this time it will not throw exception
DROP VIEW IF EXISTS employeeView;

REPAIR TABLE t1;

TRUNCATE TABLE Student partition(age=10);

TRUNCATE TABLE Student;

INSERT INTO students VALUES
    ('Amy Smith', '123 Park Ave, San Jose', 111111);
	
INSERT INTO students VALUES
    ('Bob Brown', '456 Taylor St, Cupertino', 222222),
    ('Cathy Johnson', '789 Race Ave, Palo Alto', 333333);
	
INSERT INTO students PARTITION (student_id = 444444)
    SELECT name, address FROM persons WHERE name = "Dora Williams";
	

INSERT INTO students
     FROM applicants SELECT name, address, student_id WHERE qualified = true;
	 
INSERT INTO students PARTITION (birthday = date'2019-01-02')
    VALUES ('Amy Smith', '123 Park Ave, San Jose');
	
INSERT INTO students (address, name, student_id) VALUES
    ('Hangzhou, China', 'Kent Yao', 11215016);
	
INSERT INTO students PARTITION (student_id = 11215017) (address, name) VALUES
    ('Hangzhou, China', 'Kent Yao Jr.');
	
INSERT OVERWRITE students VALUES
    ('Ashua Hill', '456 Erica Ct, Cupertino', 111111),
    ('Brian Reed', '723 Kern Ave, Palo Alto', 222222);
	
INSERT OVERWRITE students PARTITION (student_id = 222222)
    SELECT name, address FROM persons WHERE name = "Dora Williams";
	
INSERT INTO persons REPLACE WHERE ssn = 123456789 SELECT * FROM persons2

INSEsRT OVERWRITE students TABLE visiting_students;

INSERT OVERWRITE students
    FROM applicants SELECT name, address, student_id WHERE qualified = true;
	
INSERT INTO students PARTITION (birthday = date'2019-01-02')
    VALUES ('Amy Smith', '123 Park Ave, San Jose');
	
INSERT OVERWRITE students PARTITION (birthday = date'2019-01-02')
    VALUES('Jason Wang', '908 Bird St, Saratoga');
	
INSERT OVERWRITE students (address, name, student_id) VALUES
    ('Hangzhou, China', 'Kent Yao', 11215016);
	
INSERT OVERWRITE students PARTITION (student_id = 11215016) (address, name) VALUES
    ('Hangzhou, China', 'Kent Yao Jr.');
	
LOAD DATA LOCAL INPATH '/user/hive/warehouse/students' OVERWRITE INTO TABLE test_load;

LOAD DATA LOCAL INPATH '/user/hive/warehouse/test_partition/c2=2/c3=3'
    OVERWRITE INTO TABLE test_load_partition PARTITION (c2=2, c3=3);
	
SELECT * FROM person WHERE id > 200 ORDER BY id;

SELECT id, sum(quantity) FROM dealer GROUP BY id ORDER BY id;

SELECT city, sum(quantity) AS sum FROM dealer GROUP BY city HAVING city = 'Fremont';

SELECT name, age FROM person ORDER BY age;
SELECT name, age, zip_code FROM person SORT BY 1;
SELECT age, name FROM person CLUSTER BY age;
SELECT age, name FROM person DISTRIBUTE BY age;
SELECT name, age FROM person ORDER BY name LIMIT 2;
SELECT name, age FROM person ORDER BY name LIMIT length('SPARK');
SELECT name, age FROM person ORDER BY name OFFSET length(name);


EXPLAIN select k, sum(v) from values (1, 2), (1, 3) t(k, v) group by k;

ADD FILE "/path/to/file/abc.txt";
ADD FILE '/another/test.txt';
ADD FILE "/path with space/abc.txt";
ADD FILE "/path/to/some/directory";
ADD FILES "/path with space/cde.txt" '/path with space/fgh.txt';

ADD JAR "/path/to/some.jar";
ADD JAR '/some/other.jar';
ADD JAR "/path with space/abc.jar";
ADD JARS "/path with space/def.jar" '/path with space/ghi.jar';
ADD JAR "ivy://group:module:version";
ADD JAR "ivy://group:module:version?transitive=false"
ADD JAR "ivy://group:module:version?transitive=true"
ADD JAR "ivy://group:module:version?exclude=group:module&transitive=true"

ANALYZE TABLE students COMPUTE STATISTICS NOSCAN;
ANALYZE TABLE students COMPUTE STATISTICS;
ANALYZE TABLE students PARTITION (student_id = 111111) COMPUTE STATISTICS;

CACHE TABLE testCache OPTIONS ('storageLevel' 'DISK_ONLY') SELECT * FROM testData;

DESCRIBE DATABASE employees;
DESCRIBE DATABASE EXTENDED employees;

DESC FUNCTION EXTENDED abs;
DESC FUNCTION max;
DESC FUNCTION EXTENDED explode;

DESCRIBE QUERY SELECT age, sum(age) FROM person GROUP BY age;
DESCRIBE QUERY WITH all_names_cte
    AS (SELECT name from person) SELECT * FROM all_names_cte;
DESC QUERY VALUES(100, 'John', 10000.20D) AS employee(id, name, salary);
DESC QUERY TABLE person;
DESCRIBE FROM person SELECT age;

DESCRIBE TABLE customer;
DESCRIBE TABLE salesdb.customer;
DESCRIBE TABLE EXTENDED customer;
DESCRIBE TABLE EXTENDED customer PARTITION (state = 'AR');
DESCRIBE customer customer.name;

LIST JAR '/tmp/test.jar /some/random.jar /another/random.jar';

LIST JAR;

LIST FILE '/tmp/test /some/random/file /another/random/file' ;
REFRESH "hdfs://path/to/table";

REFRESH TABLE tempDB.view1;  

RESET spark.abc;
SET;
SET -v;
SET spark.sql.variable.substitute=false;

SHOW COLUMNS IN customer;
SHOW COLUMNS IN salesdb.customer;
SHOW COLUMNS IN customer IN salesdb;

SHOW CREATE TABLE test AS SERDE;
SHOW CREATE TABLE test;
SHOW DATABASES LIKE 'pay*';
SHOW SCHEMAS;

SHOW PARTITIONS customer;

SHOW PARTITIONS salesdb.customer;
SHOW PARTITIONS customer PARTITION (state = 'CA', city = 'Fremont');

SHOW TABLE EXTENDED LIKE 'employee';
SHOW TABLE EXTENDED  LIKE 'employe*';
SHOW TABLE EXTENDED  IN default LIKE 'employee' PARTITION (grade=1);
SHOW TABLE EXTENDED  IN default LIKE 'empl*' PARTITION (grade=1);

SHOW TABLES;
SHOW TABLES FROM userdb;

SHOW TABLES IN userdb;
SHOW TABLES FROM default LIKE 'sam*';
SHOW TABLES LIKE 'sam*|suj';

SHOW TBLPROPERTIES customer;
SHOW TBLPROPERTIES salesdb.customer;
SHOW TBLPROPERTIES customer (created.by.user);
SHOW TBLPROPERTIES customer ('created.date');

SHOW VIEWS;
SHOW VIEWS FROM userdb;
SHOW VIEWS IN global_temp;
SHOW VIEWS FROM default LIKE 'sam*';
SHOW VIEWS LIKE 'sam|suj|temp*';

UNCACHE TABLE t1;