CREATE TABLE mydataset.newtable1
(
  x INT64 OPTIONS(description="An optional INTEGER field"),
  y STRUCT<
    a ARRAY<STRING> OPTIONS(description="A repeated STRING field"),
    b BOOL
  >
)
PARTITION BY _PARTITIONDATE
OPTIONS(
  expiration_timestamp=TIMESTAMP "2025-01-01 00:00:00 UTC",
  partition_expiration_days=1,
  description="a table that expires in 2025, with each partition living for 24 hours",
  labels=[("org_unit", "development")]
);

Create table pk_table1
(
  col1 INT64 ,
  col2 STRING,
  Primary key (col1) NOT ENFORCED
);

Create table fk_table1
(
  col1 INT64 ,
  col2 STRING,
  CONSTRAINT fk_fk_table1_col1 foreign key (col1) REFERENCES pk_table1 (col1) NOT ENFORCED
);

CREATE TABLE mydataset.top_words
OPTIONS(
  description="Top ten words per Shakespeare corpus"
) AS
SELECT
  corpus,
  ARRAY_AGG(STRUCT(word, word_count) ORDER BY word_count DESC LIMIT 10) AS top_words
FROM bigquery-public-data.samples.shakespeare
GROUP BY corpus;

CREATE TABLE IF NOT EXISTS mydataset.newtable2 (x INT64, y STRUCT<a ARRAY<STRING>, b BOOL>)
OPTIONS(
  expiration_timestamp=TIMESTAMP "2025-01-01 00:00:00 UTC",
  description="a table that expires in 2025",
  labels=[("org_unit", "development")]
)

CREATE OR REPLACE TABLE mydataset.newtable3 (x INT64, y STRUCT<a ARRAY<STRING>, b BOOL>)
OPTIONS(
  expiration_timestamp=TIMESTAMP "2025-01-01 00:00:00 UTC",
  description="a table that expires in 2025",
  labels=[("org_unit", "development")]
)

CREATE TABLE mydataset.newtable4 (
  x INT64 NOT NULL,
  y STRUCT<
    a ARRAY<STRING>,
    b BOOL NOT NULL,
    c FLOAT64
  > NOT NULL,
  z STRING
)

CREATE TABLE mydataset.newtable5 (
  a STRING,
  b STRING,
  c STRUCT<
    x FLOAT64,
    y ARRAY<STRING>
  >
)
DEFAULT COLLATE 'und:ci';

CREATE TABLE mydataset.newtable6 (
  a STRING,
  b STRING COLLATE 'und:ci',
  c STRUCT<
    x FLOAT64,
    y ARRAY<STRING COLLATE 'und:ci'>
  >
);

CREATE TABLE mydataset.newtable7 (
  x STRING(10),
  y STRUCT<
    a ARRAY<BYTES(5)>,
    b NUMERIC(15, 2) OPTIONS(rounding_mode = 'ROUND_HALF_EVEN'),
    c FLOAT64
  >,
  z BIGNUMERIC(35)
)

CREATE TABLE mydataset.newtable8 (transaction_id INT64, transaction_date DATE)
PARTITION BY transaction_date
OPTIONS(
  partition_expiration_days=3,
  description="a table partitioned by transaction_date"
)

CREATE TABLE mydataset.myclusteredtable
(
  timestamp TIMESTAMP,
  customer_id STRING,
  transaction_amount NUMERIC
)
PARTITION BY DATE(timestamp)
CLUSTER BY customer_id
OPTIONS (
  partition_expiration_days=3,
  description="a table clustered by customer_id"
) 

CREATE TABLE mydataset.myclusteredtable
(
  customer_id STRING,
  transaction_amount NUMERIC
)
PARTITION BY DATE(_PARTITIONTIME)
CLUSTER BY
  customer_id
OPTIONS (
  partition_expiration_days=3,
  description="a table clustered by customer_id"
)

CREATE TABLE mydataset.myclusteredtable
(
  customer_id STRING,
  transaction_amount NUMERIC
)
CLUSTER BY
  customer_id
OPTIONS (
  description="a table clustered by customer_id"
)


CREATE TABLE mydataset.myclusteredtable
(
  timestamp TIMESTAMP,
  customer_id STRING,
  transaction_amount NUMERIC
)
PARTITION BY DATE(timestamp)
CLUSTER BY
  customer_id
OPTIONS (
  partition_expiration_days=3,
  description="a table clustered by customer_id"
)
AS SELECT * FROM mydataset.myothertable ;

CREATE TABLE mydataset.myclusteredtable
(
  customer_id STRING,
  transaction_amount NUMERIC
)
CLUSTER BY
  customer_id
OPTIONS (
  description="a table clustered by customer_id"
)
AS SELECT * FROM mydataset.myothertable  ;

CREATE TEMP TABLE Example
(
  x INT64,
  y STRING
);

   
CREATE TABLE
 mydataset.orders(id String, numeric_id INT)
PARTITION BY _PARTITIONDATE;

CREATE TABLE mydataset.newtable9
LIKE mydataset.sourcetable;

CREATE TABLE mydataset.newtable10
LIKE mydataset.sourcetable
AS SELECT * FROM mydataset.myothertable; 

Create table sourcetable;

CREATE TABLE mydataset.copy_sourcetable;

Create Table copy_table
copy copy_sourcetable;


CREATE SNAPSHOT TABLE `myproject.mydataset.mytablesnapshot`
CLONE `myproject.mydataset.mytable`
OPTIONS(
  expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 48 HOUR),
  friendly_name="my_table_snapshot",
  description="A table snapshot that expires in 2 days",
  labels=[("org_unit", "development")]
);

CREATE SNAPSHOT TABLE IF NOT EXISTS `myproject.mydataset.mytablesnapshot`
CLONE `myproject.mydataset.mytable`
OPTIONS(
  expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 48 HOUR),
  friendly_name="my_table_snapshot",
  description="A table snapshot that expires in 2 days",
  labels=[("org_unit", "development")]
);

CREATE TABLE `myproject.mydataset.mytable`
CLONE `myproject.mydataset.mytablesnapshot`
OPTIONS(
  expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 365 DAY),
  friendly_name="my_table",
  description="A table that expires in 1 year",
  labels=[("org_unit", "development")]
);

CREATE TABLE IF NOT EXISTS `myproject.mydataset.mytableclone`
CLONE `myproject.mydataset.mytable`
OPTIONS(
  expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 365 DAY),
  friendly_name="my_table",
  description="A table that expires in 1 year",
  labels=[("org_unit", "development")]
);

CREATE VIEW mydataset.age_groups(age, count) AS SELECT age, COUNT(*)
FROM mydataset.people
group by age;

CREATE VIEW myProject.myDataset.myView AS SELECT * FROM anotherDataset.myTable;

CREATE VIEW `myproject.mydataset.newview`
OPTIONS(
  expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 48 HOUR),
  friendly_name="newview",
  description="a view that expires in 2 days",
  labels=[("org_unit", "development")]
)
AS SELECT column_1, column_2, column_3 FROM `myproject.mydataset.mytable`;

CREATE VIEW IF NOT EXISTS `myproject.mydataset.newview`
OPTIONS(
  expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 48 HOUR),
  friendly_name="newview",
  description="a view that expires in 2 days",
  labels=[("org_unit", "development")]
)
AS SELECT column_1, column_2, column_3 FROM `myproject.mydataset.mytable`; 

CREATE OR REPLACE VIEW `myproject.mydataset.newview`
OPTIONS(
  expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 48 HOUR),
  friendly_name="newview",
  description="a view that expires in 2 days",
  labels=[("org_unit", "development")]
)
AS SELECT column_1, column_2, column_3 FROM `myproject.mydataset.mytable`; 

CREATE VIEW `myproject.mydataset.newview` (
  column_1_new_name OPTIONS (DESCRIPTION='Description of the column 1 contents'),
  column_2_new_name OPTIONS (DESCRIPTION='Description of the column 2 contents'),
  column_3_new_name OPTIONS (DESCRIPTION='Description of the column 3 contents')
)
AS SELECT column_1, column_2, column_3 FROM `myproject.mydataset.mytable`;

CREATE MATERIALIZED VIEW myProject.myDataset.myView AS SELECT * FROM anotherDataset.myTable;

CREATE MATERIALIZED VIEW `myproject.mydataset.new_mv`
OPTIONS(
  expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 48 HOUR),
  friendly_name="new_mv",
  description="a materialized view that expires in 2 days",
  labels=[("org_unit", "development")],
  enable_refresh=true,
  refresh_interval_minutes=20
)
AS SELECT column_1, SUM(column_2) AS sum_2, AVG(column_3) AS avg_3
FROM `myproject.mydataset.mytable`
GROUP BY column_1;

CREATE MATERIALIZED VIEW IF NOT EXISTS `myproject.mydataset.new_mv`
OPTIONS(
  expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 48 HOUR),
  friendly_name="new_mv",
  description="a view that expires in 2 days",
  labels=[("org_unit", "development")],
  enable_refresh=false
)
AS SELECT column_1, column_2, column_3 FROM `myproject.mydataset.mytable` ;

CREATE MATERIALIZED VIEW `myproject.mydataset.new_mv`
PARTITION BY DATE(col_datetime)
CLUSTER BY col_int
AS SELECT col_int, col_datetime, COUNT(1) as cnt
   FROM `myproject.mydataset.mv_base_table`
   GROUP BY col_int, col_datetime ;
   
   
CREATE OR REPLACE EXTERNAL TABLE mydataset.newtable11 (x INT64, y STRING, z BOOL)
  OPTIONS(
    format ="PARQUET",
    max_staleness = INTERVAL '8 20 17' MONTH TO HOUR,
    metadata_cache_mode = 'AUTOMATIC')
WITH CONNECTION myconnection;

CREATE OR REPLACE EXTERNAL TABLE mydataset.newtable12 (x INT64, y STRING, z BOOL)
  OPTIONS(
    format ="PARQUET",
    max_staleness = STALENESS_INTERVAL,
    metadata_cache_mode = 'AUTOMATIC')
WITH CONNECTION myconnection;

CREATE EXTERNAL TABLE dataset.CsvTable OPTIONS (
  format = 'CSV',
  uris = ['gs://bucket/path1.csv', 'gs://bucket/path2.csv']
);

CREATE OR REPLACE EXTERNAL TABLE dataset.CsvTable
(
  x INT64,
  y STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://bucket/path1.csv'],
  field_delimiter = '|',
  max_bad_records = 5
);

CREATE EXTERNAL TABLE dataset.AutoHivePartitionedTable
WITH PARTITION COLUMNS
OPTIONS (
  uris = ['gs://bucket/path/*'],
  format = 'PARQUET',
  hive_partition_uri_prefix = 'gs://bucket/path',
  require_hive_partition_filter = false);
  
CREATE EXTERNAL TABLE dataset.CustomHivePartitionedTable
WITH PARTITION COLUMNS (
  field_1 STRING,
  field_2 INT64)
OPTIONS (
  uris = ['gs://bucket/path/*'],
  format = 'PARQUET',
  hive_partition_uri_prefix = 'gs://bucket/path',
  require_hive_partition_filter = false);
  
  
CREATE FUNCTION mydataset.multiplyInputs(x FLOAT64, y FLOAT64)
RETURNS FLOAT64
AS (x * y);

CREATE TEMP FUNCTION multiplyInputs(x FLOAT64, y FLOAT64)
RETURNS FLOAT64
LANGUAGE js
AS r"""
  return x*y;
""";

CREATE FUNCTION mydataset.remoteMultiplyInputs(x FLOAT64, y FLOAT64)
RETURNS FLOAT64
REMOTE WITH CONNECTION us.myconnection
OPTIONS(endpoint="https://us-central1-myproject.cloudfunctions.net/multiply");

CREATE OR REPLACE TABLE FUNCTION mydataset.names_by_year(y INT64)
AS
  SELECT year, name, SUM(number) AS total
  FROM `bigquery-public-data.usa_names.usa_1910_current`
  WHERE year = y
  GROUP BY year, name ;
  
CREATE PROCEDURE myProject.myDataset.QueryTable()
BEGIN
  SELECT * FROM anotherDataset.myTable;
END;

CREATE PROCEDURE mydataset.AddDelta(INOUT x INT64, delta INT64)
BEGIN
  SET x = x + delta;
END;

CREATE PROCEDURE mydataset.SelectFromTablesAndAppend(
  target_date DATE, OUT rows_added INT64)
BEGIN
  CREATE TEMP TABLE DataForTargetDate AS
  SELECT t1.id, t1.x, t2.y
  FROM dataset.partitioned_table1 AS t1
  JOIN dataset.partitioned_table2 AS t2
  ON t1.id = t2.id
  WHERE t1.date = target_date
    AND t2.date = target_date;

  SET rows_added = (SELECT COUNT(*) FROM DataForTargetDate);

  SELECT id, x, y, target_date  
  FROM DataForTargetDate;

  DROP TABLE DataForTargetDate;
END;

CREATE OR REPLACE PROCEDURE IF NOT EXISTS project_name.dataset_name.CalculateSum (
    IN num1 INT,
    IN num2 INT,
    OUT sum_result INT
)
WITH CONNECTION my_connection
LANGUAGE pyspark AS
'''
sum_result = num1 + num2
''';

CREATE OR REPLACE PROCEDURE my_dataset.fetch_mysql_data_invoker()
EXTERNAL SECURITY INVOKER
WITH CONNECTION `my_project.us.connection_mysql`
LANGUAGE SQL
AS """
  SELECT * FROM EXTERNAL_QUERY('my_project.us.connection_mysql', 'SELECT * FROM mysql_database.table_name');
""";

CREATE OR REPLACE PROCEDURE my_dataset.fetch_mysql_data_definer()
EXTERNAL SECURITY DEFINER
WITH CONNECTION `my_project.us.connection_mysql`
LANGUAGE SQL
AS """
  SELECT * FROM EXTERNAL_QUERY('my_project.us.connection_mysql', 'SELECT * FROM mysql_database.table_name');
""";


CREATE TABLE dataset.my_table(a STRING, b INT64);

CREATE SEARCH INDEX my_index
ON dataset.my_table(ALL COLUMNS);

CREATE TABLE dataset.complex_table(
  a STRING,
  my_struct STRUCT<string_field STRING, int_field INT64>,
  b ARRAY<STRING>
);

CREATE SEARCH INDEX my_index
ON dataset.complex_table(a, my_struct, b)
OPTIONS (analyzer = 'NO_OP_ANALYZER');

CREATE SCHEMA mydataset
OPTIONS(
  location="us",
  default_table_expiration_days=3.75,
  labels=[("label1","value1"),("label2","value2")]
  )
  
  CREATE SCHEMA mydataset
OPTIONS(
  is_case_insensitive=TRUE
)

CREATE SCHEMA mydataset
DEFAULT COLLATE 'und:ci'


CREATE OR REPLACE ROW ACCESS POLICY salary_policy ON employees
GRANT TO ('user@example.com')
FILTER USING (salary > 75000);

CREATE ROW ACCESS POLICY salary_policy ON employees
GRANT TO ('user@example.com')
FILTER USING (salary > 50000);


CREATE ROW ACCESS POLICY IF NOT EXISTS salary_policy ON employees
GRANT TO ('user@example.com')
FILTER USING (salary > 50000);

CREATE CAPACITY `admin_project.region-us.my-commitment`
OPTIONS (
  slot_count = 100,
  plan = 'ANNUAL');  

CREATE RESERVATION `admin_project.region-us.prod`
OPTIONS (
  slot_capacity = 100);
  
CREATE ASSIGNMENT `admin_project.region-us.prod.my_assignment`
OPTIONS (
  assignee = 'organizations/1234',
  job_type = 'PIPELINE');

CREATE ASSIGNMENT `admin_project.region-us.prod.my_assignment`
OPTIONS (
  assignee = 'projects/my_project',
  job_type = 'QUERY');  
  
 ALTER SCHEMA mydataset
SET DEFAULT COLLATE 'und:ci';

ALTER SCHEMA mydataset
SET OPTIONS(
  is_case_insensitive=TRUE
);

ALTER SCHEMA mydataset
SET OPTIONS(
  default_table_expiration_days=3.75
  );
  
ALTER TABLE mydataset.mytable
SET OPTIONS (
  expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 7 DAY),
  description="Table that expires seven days from now"
)

ALTER TABLE mydataset.mypartitionedtable
SET OPTIONS (require_partition_filter=true)

ALTER TABLE mydataset.mytable
SET OPTIONS (expiration_timestamp=NULL)

ALTER TABLE mydataset.mytable
  ADD COLUMN A STRING,
  ADD COLUMN IF NOT EXISTS B GEOGRAPHY,
  ADD COLUMN C ARRAY<NUMERIC>,
  ADD COLUMN D DATE OPTIONS(description="my description")

ALTER TABLE mydataset.mytable
   ADD COLUMN A STRUCT<
       B GEOGRAPHY,
       C ARRAY<INT64>,
       D INT64 NOT NULL,
       E TIMESTAMP OPTIONS(description="creation time")
       >
	   
ALTER TABLE mydataset.mytable
ADD COLUMN word STRING COLLATE 'und:ci'

CREATE TABLE fk_table(x int64, y int64, i int64, j int64, u int64, v int64);

ALTER TABLE fk_table
ADD CONSTRAINT my_fk_test FOREIGN KEY (u, v)
REFERENCES pk_table(x, y) NOT ENFORCED

CREATE TABLE pk_table(x int64, y int64) ;

ALTER TABLE pk_table
ADD PRIMARY KEY (x,y) NOT ENFORCED;

ALTER TABLE mydataset.mytable RENAME TO mynewtable


ALTER TABLE mydataset.mytable
  RENAME COLUMN columnA TO temp,
  RENAME COLUMN columnB TO columnA,
  RENAME COLUMN temp TO columnB
  
  ALTER TABLE mydataset.mytable
  RENAME COLUMN A TO columnA,
  RENAME COLUMN IF EXISTS B TO columnB
  
 ALTER TABLE mydataset.mytable
  DROP COLUMN A,
  DROP COLUMN IF EXISTS B
  
ALTER TABLE mytable DROP CONSTRAINT myConstraint;

ALTER TABLE myTable
DROP PRIMARY KEY;
ALTER TABLE mydataset.mytable
SET DEFAULT COLLATE ''

ALTER TABLE mydataset.mytable
ADD COLUMN name STRING  

ALTER TABLE mydataset.mytable
ALTER COLUMN price
SET OPTIONS (description = 'Price per unit');

ALTER VIEW mydataset.myview
ALTER COLUMN total
SET OPTIONS (description = 'Total sales of the product');

ALTER TABLE mydataset.mytable
ALTER COLUMN mycolumn
DROP NOT NULL

CREATE TABLE dataset.table(c1 INT64);

ALTER TABLE dataset.table ALTER COLUMN c1 SET DATA TYPE NUMERIC;

CREATE TABLE dataset.table(s1 STRUCT<a INT64, b STRING>);

ALTER TABLE dataset.table ALTER COLUMN s1
SET DATA TYPE STRUCT<a NUMERIC, b STRING>;

CREATE TABLE dataset.table (pt NUMERIC(7,2));

ALTER TABLE dataset.table
ALTER COLUMN pt
SET DATA TYPE NUMERIC(8,2);

CREATE TABLE dataset.table (pt NUMERIC(7,2));

ALTER TABLE dataset.table
ALTER COLUMN pt
SET DATA TYPE NUMERIC(8,2);

ALTER TABLE mydataset.mytable
ALTER COLUMN mycolumn
SET DEFAULT CURRENT_TIME();

ALTER TABLE mydataset.mytable
ALTER COLUMN mycolumn
DROP DEFAULT;

ALTER VIEW mydataset.myview
SET OPTIONS (
  expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 7 DAY),
  description="View that expires seven days from now"
)

ALTER MATERIALIZED VIEW mydataset.my_mv
SET OPTIONS (
  enable_refresh=true,
  refresh_interval_minutes=20
)

ALTER ORGANIZATION
SET OPTIONS (
  `region-us.default_time_zone` = "America/Chicago",
  `region-us.default_job_query_timeout_ms` = 3600000
);

ALTER ORGANIZATION
SET OPTIONS (
  `region-us.default_time_zone` = NULL,
  `region-us.default_kms_key_name` = NULL,
  `region-us.default_query_job_timeout_ms` = NULL,
  `region-us.default_interactive_query_queue_timeout_ms` = NULL,
  `region-us.default_batch_query_queue_timeout_ms` = NULL);
  
ALTER ORGANIZATION
SET OPTIONS (
  `region-us.default_time_zone` = "America/Chicago",
  `region-us.default_job_query_timeout_ms` = 3600000
);

ALTER ORGANIZATION
SET OPTIONS (
  `region-us.default_time_zone` = NULL,
  `region-us.default_kms_key_name` = NULL,
  `region-us.default_query_job_timeout_ms` = NULL,
  `region-us.default_interactive_query_queue_timeout_ms` = NULL,
  `region-us.default_batch_query_queue_timeout_ms` = NULL);
  
 ALTER PROJECT project_id
SET OPTIONS (
  `region-us.default_time_zone` = "America/New_York",
  `region-us.default_job_query_timeout_ms` = 1800000
);

ALTER PROJECT project_id
SET OPTIONS (
  `region-us.default_time_zone` = NULL,
  `region-us.default_kms_key_name` = NULL,
  `region-us.default_query_job_timeout_ms` = NULL,
  `region-us.default_interactive_query_queue_timeout_ms` = NULL,
  `region-us.default_batch_query_queue_timeout_ms` = NULL);
  
ALTER BI_CAPACITY `my-project.region-us.default`
SET OPTIONS(
  size_gb = 250
);

ALTER BI_CAPACITY `my-project.region-us.default`
SET OPTIONS(
  size_gb = 0
);

ALTER BI_CAPACITY `my-project.region-us.default`
SET OPTIONS(
  preferred_tables = NULL
)

ALTER BI_CAPACITY `my-project.region-us.default`
SET OPTIONS(
  size_gb = 250,
  preferred_tables = ["data_project1.dataset1.table1",
                      "data_project2.dataset2.table2"]
)

ALTER BI_CAPACITY `region-us.default`
SET OPTIONS(
  preferred_tables = ["dataset1.table1",
                      "data_project2.dataset2.table2"]
)

ALTER CAPACITY `admin_project.region-us.my-commitment`
SET OPTIONS (
  plan = 'THREE_YEAR');
  
ALTER RESERVATION `admin_project.region-us.my-reservation`
SET OPTIONS (
  slot_capacity = 300,
  autoscale_max_slots = 400);
  
DROP SCHEMA mydataset

DROP SCHEMA IF EXISTS mydataset CASCADE  

DROP TABLE IF EXISTS mydataset.mytable

DROP TABLE mydataset.mytable

DROP SNAPSHOT TABLE mydataset.mytablesnapshot

DROP SNAPSHOT TABLE IF EXISTS mydataset.mytablesnapshot

DROP EXTERNAL TABLE mydataset.external_table

DROP EXTERNAL TABLE IF EXISTS mydataset.external_table

DROP VIEW IF EXISTS mydataset.myview

DROP VIEW mydataset.myview

DROP MATERIALIZED VIEW mydataset.my_mv

DROP MATERIALIZED VIEW IF EXISTS mydataset.my_mv

DROP FUNCTION mydataset.parseJsonAsStruct;

DROP FUNCTION `other_project`.sample_dataset.parseJsonAsStruct;

DROP TABLE FUNCTION mydataset.my_table_function;

DROP PROCEDURE mydataset.myProcedure;

DROP PROCEDURE `other-project`.sample_dataset.myprocedure;

DROP ROW ACCESS POLICY my_row_filter ON project.dataset.my_table;

DROP ALL ROW ACCESS POLICIES ON project.dataset.my_table;

DROP CAPACITY `admin_project.region-us.1234`

DROP RESERVATION `admin_project.region-us.prod`

DROP ASSIGNMENT `admin_project.region-us.prod.1234`

DROP SEARCH INDEX my_index ON dataset.my_table;

INSERT dataset.Inventory (product, quantity)
VALUES('top load washer', 10),
      ('front load washer', 20),
      ('dryer', 30),
      ('refrigerator', 10),
      ('microwave', 20),
      ('dishwasher', 30),
      ('oven', 5)
	  
ALTER TABLE dataset.NewArrivals ALTER COLUMN quantity SET DEFAULT 100;

INSERT dataset.NewArrivals (product, quantity, warehouse)
VALUES('top load washer', DEFAULT, 'warehouse #1'),
      ('dryer', 200, 'warehouse #2'),
      ('oven', 300, 'warehouse #3');
	  
INSERT dataset.DetailedInventory (product, quantity, supply_constrained)
SELECT product, quantity, false
FROM dataset.Inventory;

INSERT dataset.DetailedInventory (product, quantity)
VALUES('countertop microwave',
  (SELECT quantity FROM dataset.DetailedInventory
   WHERE product = 'microwave'));
   
 INSERT dataset.Warehouse VALUES('warehouse #4', 'WA'), ('warehouse #5', 'NY')
 
INSERT dataset.DetailedInventory
VALUES('top load washer', 10, FALSE, [(CURRENT_DATE, "comment1")], ("white","1 year",(30,40,28))),
      ('front load washer', 20, FALSE, [(CURRENT_DATE, "comment1")], ("beige","1 year",(35,45,30)))
	  
CREATE TABLE IF NOT EXISTS dataset.table1 (names ARRAY<STRING>);

INSERT INTO dataset.table1 (names)
VALUES (["name1","name2"]);

DELETE dataset.Inventory
WHERE quantity = 0;

DELETE dataset.Inventory
WHERE NOT EXISTS
  (SELECT * from dataset.NewArrivals
   WHERE Inventory.product = NewArrivals.product)

TRUNCATE TABLE dataset.Inventory

UPDATE dataset.Inventory
SET quantity = quantity - 10,
    supply_constrained = DEFAULT
WHERE product like '%washer%'

UPDATE dataset.Inventory
SET quantity = quantity +
  (SELECT quantity FROM dataset.NewArrivals
   WHERE Inventory.product = NewArrivals.product),
    supply_constrained = false
WHERE product IN (SELECT product FROM dataset.NewArrivals)

UPDATE dataset.DetailedInventory
SET specifications.color = 'white',
    specifications.warranty = '1 year'
WHERE product like '%washer%' 

UPDATE dataset.DetailedInventory
SET specifications
   = STRUCT<color STRING, warranty STRING,
   dimensions STRUCT<depth FLOAT64, height FLOAT64, width FLOAT64>>('white', '1 year', NULL)
WHERE product like '%washer%'

UPDATE dataset.DetailedInventory
SET comments = ARRAY(
  SELECT comment FROM UNNEST(comments) AS comment
  UNION ALL
  SELECT (CAST('2016-01-01' AS DATE), 'comment1')
)
WHERE product like '%washer%'

UPDATE dataset.DetailedInventory
SET comments = ARRAY_CONCAT(comments,
  ARRAY<STRUCT<created DATE, comment STRING>>[(CAST('2016-01-01' AS DATE), 'comment1')])
WHERE product like '%washer%'

UPDATE dataset.DetailedInventory
SET comments = ARRAY(
  SELECT comment FROM UNNEST(comments) AS comment
  UNION ALL
  SELECT (CAST('2016-01-01' AS DATE), 'comment2')
)
WHERE true



UPDATE dataset.DetailedInventory
SET comments = ARRAY(
  SELECT c FROM UNNEST(comments) AS c
  WHERE c.comment NOT LIKE '%comment2%'
)
WHERE true

UPDATE dataset.DetailedInventory
SET supply_constrained = true
FROM dataset.NewArrivals, dataset.Warehouse
WHERE DetailedInventory.product = NewArrivals.product AND
      NewArrivals.warehouse = Warehouse.warehouse AND
      Warehouse.state = 'WA'
	  
UPDATE dataset.DetailedInventory
SET supply_constrained = true
FROM dataset.NewArrivals
INNER JOIN dataset.Warehouse
ON NewArrivals.warehouse = Warehouse.warehouse
WHERE DetailedInventory.product = NewArrivals.product AND
      Warehouse.state = 'WA'
	  
MERGE dataset.DetailedInventory T
USING dataset.Inventory S
ON T.product = S.product
WHEN NOT MATCHED AND quantity < 20 THEN
  INSERT(product, quantity, supply_constrained, comments)
  VALUES(product, quantity, true, ARRAY<STRUCT<created DATE, comment STRING>>[(DATE('2016-01-01'), 'comment1')])
WHEN NOT MATCHED THEN
  INSERT(product, quantity, supply_constrained)
  VALUES(product, quantity, false)
  
MERGE dataset.Inventory T
USING dataset.NewArrivals S
ON T.product = S.product
WHEN MATCHED THEN
  UPDATE SET quantity = T.quantity + S.quantity
WHEN NOT MATCHED THEN
  INSERT (product, quantity) VALUES(product, quantity)
  
MERGE dataset.NewArrivals T
USING (SELECT * FROM dataset.NewArrivals WHERE warehouse <> 'warehouse #2') S
ON T.product = S.product
WHEN MATCHED AND T.warehouse = 'warehouse #1' THEN
  UPDATE SET quantity = T.quantity + 20
WHEN MATCHED THEN
  DELETE
  
MERGE dataset.Inventory T
USING dataset.NewArrivals S
ON FALSE
WHEN NOT MATCHED AND product LIKE '%washer%' THEN
  INSERT (product, quantity) VALUES(product, quantity)
WHEN NOT MATCHED BY SOURCE AND product LIKE '%washer%' THEN
  DELETE
  
MERGE dataset.DetailedInventory T
USING dataset.Inventory S
ON T.product = S.product
WHEN MATCHED AND S.quantity < (SELECT AVG(quantity) FROM dataset.Inventory) THEN
  UPDATE SET comments = ARRAY_CONCAT(comments, ARRAY<STRUCT<created DATE, comment STRING>>[(CAST('2016-02-01' AS DATE), 'comment2')])
  
MERGE dataset.Inventory T
USING (SELECT product, quantity, state FROM dataset.NewArrivals t1 JOIN dataset.Warehouse t2 ON t1.warehouse = t2.warehouse) S
ON T.product = S.product
WHEN MATCHED AND state = 'CA' THEN
  UPDATE SET quantity = T.quantity + S.quantity
WHEN MATCHED THEN
  DELETE
  
 MERGE dataset.Inventory T
USING dataset.NewArrivals S
ON T.product = S.product
WHEN MATCHED THEN
  UPDATE SET quantity = T.quantity + S.quantity
  
MERGE dataset.NewArrivals
USING (SELECT * FROM UNNEST([('microwave', 10, 'warehouse #1'),
                             ('dryer', 30, 'warehouse #1'),
                             ('oven', 20, 'warehouse #2')]))
ON FALSE
WHEN NOT MATCHED THEN
  INSERT ROW
WHEN NOT MATCHED BY SOURCE THEN
  DELETE
 
GRANT `roles/bigquery.dataViewer` ON SCHEMA `myProject`.myDataset
TO "user:raha@example-pet-store.com", "user:sasha@example-pet-store.com"

REVOKE `roles/bigquery.admin` ON SCHEMA `myProject`.myDataset
FROM "group:example-team@example-pet-store.com", "serviceAccount:user@test-project.iam.gserviceaccount.com"

DECLARE x INT64;

DECLARE d DATE DEFAULT CURRENT_DATE();

DECLARE x, y, z INT64 DEFAULT 0;

DECLARE item DEFAULT (SELECT item FROM schema1.products LIMIT 1);

SET x = 5;

SET (a, b, c) = (1 + 3, 'foo', false);

DECLARE target_word STRING DEFAULT 'methinks';
DECLARE corpus_count, word_count INT64;

SET (corpus_count, word_count) = (
  SELECT AS STRUCT COUNT(DISTINCT corpus), SUM(word_count)
  FROM bigquery-public-data.samples.shakespeare
  WHERE LOWER(word) = target_word
);

EXECUTE IMMEDIATE "SELECT ? * (? + 2)" INTO y USING 1, 3;

EXECUTE IMMEDIATE "SELECT @a * (@b + 2)" INTO y USING 1 as a, 3 as b;

DECLARE book_name STRING DEFAULT 'Ulysses';
DECLARE book_year INT64 DEFAULT 1922;
DECLARE first_date INT64;

EXECUTE IMMEDIATE
  "CREATE TEMP TABLE Books (title STRING, publish_date INT64)";
  
EXECUTE IMMEDIATE
  "INSERT INTO Books (title, publish_date) VALUES('Hamlet', 1599)";
  
EXECUTE IMMEDIATE
  "INSERT INTO Books (title, publish_date) VALUES(?, ?)"
  USING book_name, book_year;
  
EXECUTE IMMEDIATE
  "INSERT INTO Books (title, publish_date) VALUES(@name, @year)"
  USING 1815 as year, "Emma" as name;
  
 EXECUTE IMMEDIATE
  CONCAT(
    "INSERT INTO Books (title, publish_date)", "VALUES('Middlemarch', 1871)"
  );
  
EXECUTE IMMEDIATE "SELECT publish_date FROM Books LIMIT 1" INTO first_date;

DECLARE x INT64 DEFAULT 10;
BEGIN
  DECLARE y INT64;
  SET y = x;
  SELECT y;
END;


BEGIN
  BEGIN
    ...
  EXCEPTION WHEN ERROR THEN
    SELECT 1/0;
  END;
EXCEPTION WHEN ERROR THEN
  
END;

CREATE OR REPLACE PROCEDURE schema1.proc1() BEGIN
  SELECT 1/0;
END;

CREATE OR REPLACE PROCEDURE schema1.proc2() BEGIN
  CALL schema1.proc1();
END;

BEGIN
  CALL schema1.proc2();
EXCEPTION WHEN ERROR THEN
  SELECT
    @@error.message,
    @@error.stack_trace,
    @@error.statement_text,
    @@error.formatted_stack_trace;
END;

DECLARE target_product_id INT64 DEFAULT 103;
CASE
  WHEN
    EXISTS(SELECT 1 FROM schema.products_a WHERE product_id = target_product_id)
    THEN SELECT 'found product in products_a table';
  WHEN
    EXISTS(SELECT 1 FROM schema.products_b WHERE product_id = target_product_id)
    THEN SELECT 'found product in products_b table';
  ELSE
    SELECT 'did not find product';
END CASE;

DECLARE product_id INT64 DEFAULT 1;
CASE product_id
  WHEN 1 THEN
    SELECT CONCAT('Product one');
  WHEN 2 THEN
    SELECT CONCAT('Product two');
  ELSE
    SELECT CONCAT('Invalid product');
END CASE;

DECLARE target_product_id INT64 DEFAULT 103;
IF EXISTS(SELECT 1 FROM schema.products
           WHERE product_id = target_product_id) THEN
  SELECT CONCAT('found product ', CAST(target_product_id AS STRING));
  ELSEIF EXISTS(SELECT 1 FROM schema.more_products
           WHERE product_id = target_product_id) THEN
  SELECT CONCAT('found product from more_products table',
  CAST(target_product_id AS STRING));
ELSE
  SELECT CONCAT('did not find product ', CAST(target_product_id AS STRING));
END IF;

DECLARE x INT64 DEFAULT 0;
LOOP
  SET x = x + 1;
  IF x >= 10 THEN
    LEAVE;
  END IF;
END LOOP;

DECLARE x INT64 DEFAULT 0;

REPEAT
  SET x = x + 1;
  SELECT x;
  UNTIL x >= 3
END REPEAT;

DECLARE heads BOOL;
DECLARE heads_count INT64 DEFAULT 0;
LOOP
  SET heads = RAND() < 0.5;
  IF heads THEN
    SELECT 'Heads!';
    SET heads_count = heads_count + 1;
  ELSE
    SELECT 'Tails!';
    BREAK;
  END IF;
END LOOP;

DECLARE heads BOOL;
DECLARE heads_count INT64 DEFAULT 0;
LOOP
  SET heads = RAND() < 0.5;
  IF heads THEN
    SELECT 'Heads!';
    SET heads_count = heads_count + 1;
    CONTINUE;
  END IF;
  SELECT 'Tails!';
  BREAK;
END LOOP;

FOR record IN
  (SELECT word, word_count
   FROM bigquery-public-data.samples.shakespeare
   LIMIT 5)
DO
  SELECT record.word, record.word_count;
END FOR;

BEGIN TRANSACTION;


CREATE TEMP TABLE tmp AS
SELECT * FROM myschema.NewArrivals WHERE warehouse = 'warehouse #1';


DELETE myschema.NewArrivals WHERE warehouse = 'warehouse #1';


MERGE myschema.Inventory AS I
USING tmp AS T
ON I.product = T.product
WHEN NOT MATCHED THEN
 INSERT(product, quantity, supply_constrained)
 VALUES(product, quantity, false)
WHEN MATCHED THEN
 UPDATE SET quantity = I.quantity + T.quantity;
 
DROP TABLE tmp;

COMMIT TRANSACTION;

BEGIN

  BEGIN TRANSACTION;
  INSERT INTO myschema.NewArrivals
    VALUES ('top load washer', 100, 'warehouse #1');

  SELECT 1/0;
  COMMIT TRANSACTION;

EXCEPTION WHEN ERROR THEN

  SELECT @@error.message;
  ROLLBACK TRANSACTION;
END;

RAISE USING MESSAGE = message;

DECLARE retCode INT64;

CALL mySchema.UpdateSomeTables('someAccountId', retCode);

EXPORT DATA OPTIONS(
  uri='gs://bucket/folder/*.csv',
  format='CSV',
  overwrite=true,
  header=true,
  field_delimiter=';') AS
SELECT field1, field2 FROM mydataset.table1 ORDER BY field1 LIMIT 10

EXPORT DATA OPTIONS(
  uri='gs://bucket/folder/*',
  format='AVRO',
  compression='SNAPPY') AS
SELECT field1, field2 FROM mydataset.table1 ORDER BY field1 LIMIT 10

EXPORT DATA OPTIONS(
  uri='gs://bucket/folder/*',
  format='PARQUET',
  overwrite=true) AS
SELECT field1, field2 FROM mydataset.table1 ORDER BY field1 LIMIT 10

EXPORT DATA
  WITH CONNECTION myproject.us.myconnection
  OPTIONS(
  uri='s3://bucket/folder/*',
  format='JSON',
  overwrite=true) AS
SELECT field1, field2 FROM mydataset.table1 ORDER BY field1 LIMIT 10


LOAD DATA INTO mydataset.table1
  FROM FILES(
    format='AVRO',
    uris = ['gs://bucket/path/file.avro']
  )
    
LOAD DATA INTO mydataset.table1
  FROM FILES(
    format='CSV',
    uris = ['gs://bucket/path/file1.csv', 'gs://bucket/path/file2.csv']
  )
  
LOAD DATA INTO mydataset.table1
  OPTIONS(
    description="my table",
    expiration_timestamp="2025-01-01 00:00:00 UTC"
  )
  FROM FILES(
    format='AVRO',
    uris = ['gs://bucket/path/file.avro']
  )
  
LOAD DATA OVERWRITE mydataset.table1
  FROM FILES(
    format='AVRO',
    uris = ['gs://bucket/path/file.avro']
  )
  
LOAD DATA INTO mydataset.table1
  PARTITION BY transaction_date 
  CLUSTER BY customer_id
  OPTIONS(
    partition_expiration_days=3
  )
  FROM FILES(
    format='AVRO',
    uris = ['gs://bucket/path/file.avro']
  )
  

  
LOAD DATA INTO mydataset.table1
  FROM FILES(
    format='AVRO',
    uris = ['gs://bucket/path/*'],
    hive_partition_uri_prefix='gs://bucket/path'
  )
  WITH PARTITION COLUMNS(
    field_1 STRING,
    field_2 INT64
  )
    
LOAD DATA INTO mydataset.table1
  FROM FILES(
    format='AVRO',
    uris = ['gs://bucket/path/*'],
    hive_partition_uri_prefix='gs://bucket/path'
  )
  WITH PARTITION COLUMNS


LOAD DATA INTO mydataset.table1
  (
    x INT64, 
    y STRING
  )
  FROM FILES(
    format='AVRO',
    uris = ['gs://bucket/path/*'],
    hive_partition_uri_prefix='gs://bucket/path'
  )
  WITH PARTITION COLUMNS
  

LOAD DATA INTO mydataset.testparquet
  FROM FILES (
    uris = ['s3://test-bucket/sample.parquet'],
    format = 'PARQUET'
  )
  WITH CONNECTION `aws-us-east-1.test-connection` 
  
LOAD DATA INTO mydataset.table1
PARTITIONS(_PARTITIONTIME = TIMESTAMP('2016-01-01'))
  PARTITION BY _PARTITIONTIME
  FROM FILES(
    format = 'AVRO',
    uris = ['gs://bucket/path/file.avro']
  )
  
LOAD DATA INTO mydataset.test_csv (Number INT64, Name STRING, Time DATE)
  PARTITION BY Time
  FROM FILES (
    format = 'CSV', uris = ['azure://test.blob.core.windows.net/container/sampled*'],
    skip_leading_rows=1
  )
  WITH CONNECTION `azure-eastus2.test-connection`
  
-- This query succeeds and no error is produced.
ASSERT (
  (SELECT COUNT(*) > 5 FROM UNNEST([1, 2, 3, 4, 5, 6]))
) AS 'Table must contain more than 5 rows.';

-- Error: Table must contain more than 10 rows.
ASSERT (
  (SELECT COUNT(*) > 10 FROM UNNEST([1, 2, 3, 4, 5, 6]))
) AS 'Table must contain more than 10 rows.';

-- This query succeeds and no error is produced.
ASSERT
  EXISTS(
    (SELECT X FROM UNNEST([7877, 7879, 7883, 7901, 7907]) AS X WHERE X = 7907))
AS 'Column X must contain the value 7907.';

-- Error: Column X must contain the value 7919.
ASSERT
  EXISTS(
    (SELECT X FROM UNNEST([7877, 7879, 7883, 7901, 7907]) AS X WHERE X = 7919))
AS 'Column X must contain the value 7919';

label_1: BEGIN
  SELECT 1;
  BREAK label_1;
  SELECT 2; -- Unreached
END;

label_1: LOOP
  BREAK label_1;
END LOOP label_1;

WHILE x < 1 DO
  CONTINUE label_1; -- Error
END WHILE;

label_1: BEGIN
  BREAK label_1;
END;

label_2: BEGIN
  BREAK label_2;
END;

label_1: BEGIN
  BREAK label_1;
END;

label_1: BEGIN
   label_1: BEGIN -- Error
     BREAK label_1;
   END;
END;

label_1: BEGIN
   DECLARE label_1 INT64;
   BREAK label_1;
END;

label_1: BEGIN
  BREAK label_1;
END label_1;

label_1: BEGIN
  BREAK label_1;
END;
  
  
BEGIN
  BREAK label_1;
END label_1;

label_1: LOOP
  WHILE x < 1 DO
    IF y < 1 THEN
      CONTINUE label_1;
    ELSE
      BREAK label_1;
  END WHILE;
END LOOP label_1

WHILE x < 1 DO
  BREAK label_1; -- Error
END WHILE;

label_1: BEGIN
  SELECT 1;
  EXCEPTION WHEN ERROR THEN
    BREAK label_1;
    SELECT 2; -- Unreached
END;

label_1: BEGIN
  SELECT 1;
  CONTINUE label_1; -- Error
  SELECT 2;
END;

CREATE TABLE my_table (
    id INT64 PRIMARY KEY NOT ENFORCED,
    name STRING
    
);

CREATE TABLE parent_table (
    id INT64 PRIMARY KEY NOT ENFORCED,
    name STRING
    
);

CREATE TABLE child_table (
    id INT64 PRIMARY KEY  NOT ENFORCED,
    parent_id INT64 FOREIGN KEY  REFERENCES parent_table(id) NOT ENFORCED,
    description STRING
    
);

CREATE EXTERNAL SCHEMA mydataset
WITH CONNECTION myproject.`aws-us-east-1`.myconnection
  OPTIONS (
    external_source = 'aws-glue://arn:aws:glue:us-east-1:123456789:database/test_database',
    location = 'aws-us-east-1');
	
ALTER TABLE pk_table
ADD PRIMARY KEY (x,y) NOT ENFORCED;

ALTER TABLE fk_table
ADD CONSTRAINT my_fk_name FOREIGN KEY (u, v)
REFERENCES pk_table(x, y) NOT ENFORCED
  
CREATE AGGREGATE FUNCTION myProject.myDataset.ScaledSum(
  dividend FLOAT64,
  divisor FLOAT64 NOT AGGREGATE)
RETURNS FLOAT64
AS (
  SUM(dividend) / divisor
);
  
DROP VECTOR INDEX my_index ON dataset.my_table;

CREATE TABLE mydatasets.my_table_with_range (
    id INT64,
    int_range RANGE<datetime>,  -- Range of integer values
    date_range RANGE<DATE>   -- Range of date values
);

CREATE TABLE mydatasets.my_table_with_range_and_interval (
    id INT64,
    int_range RANGE<Datetime>,  -- Range of integer values
    date_range RANGE<DATE>,  -- Range of date values
    duration INTERVAL      -- Interval for storing time spans
);

Create table  `oceanic-trail-436011-g7`.mydatasets.sa(col int);  

CREATE TABLE sales_transactions
(
    transaction_id STRING,
    customer_id STRING,
    product_id STRING,

    transaction_timestamp TIMESTAMP,
    transaction_date DATE,

    quantity INT64,
    price NUMERIC,
    discount NUMERIC,

    sales_channel STRING,
    region STRING,

    customer STRUCT<
        first_name STRING,
        last_name STRING,
        email STRING
    >,

    items ARRAY<STRUCT<
        item_id STRING,
        item_name STRING,
        category STRING,
        unit_price NUMERIC
    >>,

    created_at TIMESTAMP
)

PARTITION BY DATE(transaction_timestamp)

CLUSTER BY customer_id, product_id,region

OPTIONS (
    description = "Sales transactions table with partitioning and clustering",
    require_partition_filter = TRUE,
    partition_expiration_days = 365
)


  

 
 
 



