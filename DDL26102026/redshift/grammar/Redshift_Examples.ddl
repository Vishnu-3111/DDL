ALTER PROCEDURE first_quarter_revenue(volume INOUT bigint, at_price IN numeric,
 result OUT int) RENAME TO quarterly_revenue;
 
ALTER PROCEDURE first_quarter_revenue(bigint, numeric) RENAME TO quarterly_revenue;

ALTER PROCEDURE quarterly_revenue(bigint, numeric) OWNER TO etl_user;
 

ALTER MATERIALIZED VIEW tickets_mv AUTO REFRESH YES;

alter database tickit_sandbox rename to tickit_test;

ALTER DATABASE sampledb ISOLATION LEVEL SNAPSHOT;

ALTER DATABASE sampledb ISOLATION LEVEL SNAPSHOT;

ALTER DATABASE sampledb ISOLATION LEVEL SNAPSHOT;

create external schema spectrum_schema
from data catalog
database 'sampledb'
region 'us-west-2'
iam_role 'arn:aws:iam::123456789012:role/MySpectrumRole';

create external schema spectrum_schema
from data catalog
database 'spectrum_db'
iam_role 'arn:aws:iam::123456789012:role/MySpectrumRole'
create external database if not exists;

create external schema hive_schema
from hive metastore
database 'hive_db'
uri '172.10.10.10' port 99
iam_role 'arn:aws:iam::123456789012:role/MySpectrumRole';

create external schema spectrum_schema
from data catalog
database 'spectrum_db'
iam_role 'arn:aws:iam::123456789012:role/myRedshiftRole,arn:aws:iam::123456789012:role/myS3Role'
catalog_role 'arn:aws:iam::123456789012:role/myAthenaRole'
create external database if not exists;

CREATE EXTERNAL SCHEMA [IF NOT EXISTS] myRedshiftSchema
FROM POSTGRES
DATABASE 'my_aurora_db' SCHEMA 'my_aurora_schema'
URI 'endpoint to aurora hostname' PORT 5432  
IAM_ROLE 'arn:aws:iam::123456789012:role/MyAuroraRole'
SECRET_ARN 'arn:aws:secretsmanager:us-east-2:123456789012:secret:development/MyTestDatabase-AbCdEf' ;

CREATE EXTERNAL SCHEMA sales_schema FROM REDSHIFT DATABASE 'sales_db' SCHEMA 'public';

CREATE EXTERNAL SCHEMA [IF NOT EXISTS] myRedshiftSchema
FROM MYSQL
DATABASE 'my_aurora_db'
URI 'endpoint to aurora hostname'
IAM_ROLE 'arn:aws:iam::123456789012:role/MyAuroraRole'
SECRET_ARN 'arn:aws:secretsmanager:us-east-2:123456789012:secret:development/MyTestDatabase-AbCdEf';



create schema us_sales authorization dwuser;

create schema us_sales authorization dwuser QUOTA 50 GB;

create schema if not exists us_sales;

alter schema sales
rename to us_sales;

alter schema us_sales
owner to dwuser;

alter schema us_sales QUOTA 300 GB;
alter schema us_sales QUOTA UNLIMITED;

CREATE EXTERNAL FUNCTION exfunc_multiplication(int, int, int)
RETURNS INT
VOLATILE
LAMBDA 'lambda_multiplication'
IAM_ROLE 'arn:aws:iam::123456789012:role/Redshift-Exfunc-Test'
MAX_BATCH_ROWS 10
MAX_BATCH_SIZE 1024 MB 
; 

CREATE OR REPLACE EXTERNAL FUNCTION exfunc_upper(varchar)
RETURNS varchar
VOLATILE
LAMBDA 'exfunc_sleep_3'
IAM_ROLE 'arn:aws:iam::123456789012:role/Redshift-Exfunc-Test'
RETRY_TIMEOUT 3000;

CREATE OR REPLACE EXTERNAL FUNCTION exfunc_upper(varchar)
RETURNS varchar
VOLATILE
LAMBDA 'exfunc_sleep_3'
IAM_ROLE 'arn:aws:iam::123456789012:role/Redshift-Exfunc-Test'
RETRY_TIMEOUT 0;

CREATE EXTERNAL FUNCTION exfunc_sum(INT,INT)
RETURNS INT
VOLATILE
LAMBDA 'lambda_sum'
IAM_ROLE 'arn:aws:iam::123456789012:role/Redshift-Exfunc-Test';

CREATE OR REPLACE PROCEDURE test_sp1(f1 int, f2 varchar(20))
AS $$
DECLARE
  min_val int;
BEGIN
  DROP TABLE IF EXISTS tmp_tbl;
  CREATE TEMP TABLE tmp_tbl(id int);
  INSERT INTO tmp_tbl values (f1),(10001),(10002);
  SELECT INTO min_val MIN(id) FROM tmp_tbl;
  RAISE INFO 'min_val = %, f2 = %', min_val, f2; 
END;
$$ LANGUAGE plpgsql
SECURITY INVOKER
SET configuration_parameter TO value 
;

CREATE OR REPLACE PROCEDURE test_sp2(f1 IN int, f2 INOUT varchar(256), out_var OUT varchar(256))
AS $$
DECLARE
  loop_var int;
BEGIN
  IF f1 is null OR f2 is null THEN
    RAISE EXCEPTION 'input cannot be null';
  END IF;
  DROP TABLE if exists my_etl;
  CREATE TEMP TABLE my_etl(a int, b varchar);
    FOR loop_var IN 1..f1 LOOP
        insert into my_etl values (loop_var, f2);
        f2 := f2 || '+' || f2;
    END LOOP;
  SELECT INTO out_var count(*) from my_etl;
END;
$$ LANGUAGE plpgsql;

create function f_py_greater (a float, b float)
  returns float
stable
as $$
  if a > b:
    return a
  return b
$$ language plpythonu;

create function f_sql_greater (float, float)
  returns float
stable
as $$
  select case when $1 > $2 then $1
    else $2
  end
$$ language sql;


create function f_sql_commission (float, float )
  returns float
stable
as $$
  select f_sql_greater ($1, $2)
$$ language sql;

create function f_sql_commission (float, float )
  returns float
stable
as $$
  select f_sql_greater ($1, $2)
$$ language sql;

with venuecopy as (select * from venue)
select * from venuecopy order by 1 limit 10;

select * from venue limit 0;

select salesid, qtysold, pricepaid, commission, saletime from sales
order by qtysold, pricepaid, commission, salesid, saletime desc
limit 10;

select * from category order by 2, length(catdesc), 1, 3;

select * from category_stage
except
select * from category;

select distinct eventname from event, sales, venue
where event.eventid=sales.eventid and event.venueid=venue.venueid
and date_part(month,starttime)=3 and venuecity='Los Angeles'
intersect
select distinct eventname from event, sales, venue
where event.eventid=sales.eventid and event.venueid=venue.venueid
and date_part(month,starttime)=3 and venuecity='New York City'
order by eventname asc;

select eventid, listid, 'Yes' as salesrow
from sales
where listid in(500,501,502)
union
select eventid, listid, 'No'
from listing
where listid in(500,501,502)
order by listid asc;

select eventid, listid, 'Yes' as salesrow
from sales
where listid in(500,501,502)
union all
select eventid, listid, 'No'
from listing
where listid in(500,501,502)
order by listid asc;

select eventid, listid, 'Yes' as salesrow
from sales
where listid in(500,501,502)
union
select eventid, listid, 'No'
from listing
where listid in(500,501,502)
order by listid asc;

select eventid, listid, 'Yes' as salesrow
from sales
where listid in(500,501,502)
union all
select eventid, listid, 'No'
from listing
where listid in(500,501,502)
order by listid asc;

select listid, lastname, firstname, username,
pricepaid as price, 'S' as buyorsell
from sales, users
where sales.sellerid=users.userid
and pricepaid >=10000
union
select listid, lastname, firstname, username, pricepaid,
'B' as buyorsell
from sales, users
where sales.buyerid=users.userid
and pricepaid >=10000
order by 1, 2, 3, 4, 5;

select listid, sellerid, eventid from listing
union select listid, sellerid, eventid from sales
order by listid, sellerid, eventid desc limit 5;

(select * from t1
union
select * from t2)
intersect
(select * from t3)
order by c1;

select * from t1
union
select * from t2
intersect
select * from t3
order by c1;

select * from t1
union
select * from t2
except
select * from t3
order by c1;

select * from t1
union
select * from t2
except
select * from t3
order by c1;

select listid, eventid, sum(pricepaid) as revenue,
count(qtysold) as numtix
from sales
group by 1,2
order by 3, 4, 2, 1
limit 5;

select eventname, starttime, pricepaid/qtysold as costperticket, qtysold
from sales, event
where sales.eventid = event.eventid
and eventname='Hannah Montana'
and date_part(quarter, starttime) in(1,2)
and date_part(year, starttime) = 2008
order by 3 desc, 4, 2, 1 limit 10;

select * from sales s, listing l,
sales join listing
using (listid,eventid)
where s.listid=l.listid ;

select * from sales s, listing l
where s.listid=l.listid;

select distinct week, month, year
from date
where month='DEC' and year=2008
order by 1, 2, 3;

select distinct catgroup from category
order by 1;



select eventname, sum(pricepaid)
from sales join event on sales.eventid = event.eventid
group by 1
having sum(pricepaid) > 800000
order by 2 desc, 1;

select top 2 qtysold, sellerid
from sales
order by qtysold desc, sellerid;

select top 10 qtysold, sellerid
from sales
order by qtysold desc, sellerid;

select *
from sales
limit 10;

select * from sales s, listing l,
sales join listing
on sales.listid=listing.listid and sales.eventid=listing.eventid
where s.listid=l.listid ;

CREATE MATERIALIZED VIEW mv_baseball DISTSTYLE ALL AUTO REFRESH YES AS SELECT ball AS baseball FROM baseball_table;

CREATE MATERIALIZED VIEW mv_fq 
Backup no
AUTO REFRESH yes
as select firstname, lastname from apg.mv_fq_example;

CREATE MATERIALIZED VIEW mv_sales_vw as
select salesid, qtysold, pricepaid, commission, saletime from public.sales
union all
select salesid, qtysold, pricepaid, commission, saletime from spectrum.sales ;


CREATE MATERIALIZED VIEW tickets_mv_max AS
    select   catgroup,
    max(qtysold) as sold
    from     category c, event e, sales s
    where    c.catid = e.catid
    and      e.eventid = s.eventid
    group by catgroup;

SELECT name, state FROM STV_MV_INFO;

CREATE MATERIALIZED VIEW tickets_mv AS
    select catgroup,
    sum(qtysold) as sold
    from category c, event e, sales s
    where c.catid = e.catid
    and e.eventid = s.eventid
    group by catgroup;

create database sampledb collate case_insensitive;

CREATE DATABASE sales_db FROM DATASHARE salesshare OF NAMESPACE '13b8833d-17c6-4f16-8fe4-1a018f5ed00d';

CREATE DATABASE sampledb ISOLATION LEVEL SNAPSHOT;

create database tickit
with owner dwuser;

CREATE EXTERNAL TABLE schema_spectrum_uddh.soccer_league
(
  league_rank smallint,
  prev_rank   smallint,
  club_name   varchar(15),
  league_name varchar(20),
  league_off  decimal(6,2),
  league_def  decimal(6,2),
  league_spi  decimal(6,2),
  league_nspi integer
)
ROW FORMAT DELIMITED
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\n\l'
stored as textfile
LOCATION 's3://spectrum-uddh/league/'
table properties ('skip.header.line.count'='1');

CREATE EXTERNAL TABLE tbl_name (columns)
ROW FORMAT SERDE 'com.amazon.ionhiveserde.IonHiveSerDe'
STORED AS
INPUTFORMAT 'com.amazon.ionhiveserde.formats.IonInputFormat'
OUTPUTFORMAT 'com.amazon.ionhiveserde.formats.IonOutputFormat'
LOCATION 's3://s3-bucket/prefix'



CREATE EXTERNAL TABLE spectrum.mybucket_s3_logs(
bucketowner varchar(255),
bucket varchar(255),
requestdatetime varchar(2000),
remoteip varchar(255),
requester varchar(255),
requested varchar(255),
operation varchar(255),
key varchar(255),
requesturi_operation varchar(255),
requesturi_key varchar(255),
requesturi_httpprotoversion varchar(255),
httpstatus varchar(255),
errorcode varchar(255),
bytessent bigint,
objectsize bigint,
totaltime varchar(255),
turnaroundtime varchar(255),
referrer varchar(255),
useragent varchar(255),
versionid varchar(255))
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
'input.regex' = '([^ ]*) ([^ ]*) \\[(.*?)\\] ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) \"([^ ]*)\\s*([^ ]*)\\s*([^ ]*)\" (- |[^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) (\"[^\"]*\") ([^ ]*).*$')
LOCATION 's3://mybucket/s3logs';


create external table spectrum.grok_log(
timestamp varchar(255),
pid varchar(255),
loglevel varchar(255),
progname varchar(255),
message varchar(255))
row format serde 'com.amazonaws.glue.serde.GrokSerDe'
with serdeproperties ('input.format'='[DFEWI], \\[%{TIMESTAMP_ISO8601:timestamp} #%{POSINT:pid:int}\\] *(?<loglevel>:DEBUG|FATAL|ERROR|WARN|INFO) -- +%{DATA:progname}: %{GREEDYDATA:message}')
stored as textfile
location 's3://mybucket/grok/logs';

create external table spectrum.types(
cbigint bigint,
cbigint_null bigint,
cint int,
cint_null int)
row format serde 'org.apache.hadoop.hive.serde2.RegexSerDe'
with serdeproperties ('input.regex'='([^\\x01]+)\\x01([^\\x01]+)\\x01([^\\x01]+)\\x01([^\\x01]+)')
stored as textfile
location 's3://mybucket/regex/types';

create external table spectrum_db.spectrum_schema.test (c1 int)
stored as parquet
location 's3://mybucket/myfolder/';


create external table spectrum.sales_part(
salesid integer,
listid integer,
sellerid integer,
buyerid integer,
eventid integer,
dateid smallint,
qtysold smallint,
pricepaid decimal(8,2),
commission decimal(8,2),
saletime timestamp)
partitioned by (saledate date)
row format delimited
fields terminated by '|'
stored as textfile
location 's3://awssampledbuswest2/tickit/spectrum/sales_partition/'
table properties ('numRows'='170000');

CREATE EXTERNAL TABLE spectrum.partitioned_lineitem
PARTITIONED BY (l_shipdate)
STORED AS parquet
LOCATION 'S3://mybucket/cetas/partitioned_lineitem/'
AS SELECT l_orderkey, l_shipmode, l_shipdate, l_partkey FROM local_table;

create local table localtable 
(
col1 int,
col2 int

);

CREATE EXTERNAL TABLE spectrum.lineitem
STORED AS parquet
LOCATION 'S3://mybucket/cetas/lineitem/'
AS SELECT * FROM local_lineitem;

create external table spectrum.cloudtrail_json (
event_version int ,
event_id bigint,
event_time timestamp,
event_type varchar(10),
awsregion varchar(20),
event_name varchar(max),
event_source varchar(max),
requesttime timestamp,
useragent varchar(max),
recipientaccountid bigint)
row format serde 'org.openx.data.jsonserde.JsonSerDe'
with serdeproperties (
'dots.in.keys' = 'true',
'mapping.requesttime' = 'requesttimestamp'
) location 's3://mybucket/json/cloudtrail';

create external table spectrum.sales(
salesid integer,
listid integer,
sellerid integer,
buyerid integer,
eventid integer,
saledate date,
qtysold smallint,
pricepaid decimal(8,2),
commission decimal(8,2),
saletime timestamp)
row format delimited
fields terminated by '\t'
stored as textfile
location 's3://awssampledbuswest2/tickit/spectrum/sales/'
table properties ('numRows'='170000');


alter table users
add column feedback_score int
default NULL;

alter table users
drop column feedback_score cascade;

alter table users drop column feedback_score;

alter table spectrum.sales_part add if not exists
partition(saledate='2008-01-01')
location 's3://awssampledbuswest2/tickit/spectrum/sales_partition/saledate=2008-01/'
partition(saledate='2008-02-01')
location 's3://awssampledbuswest2/tickit/spectrum/sales_partition/saledate=2008-02/'
partition(saledate='2008-03-01')
location 's3://awssampledbuswest2/tickit/spectrum/sales_partition/saledate=2008-03/';

alter table spectrum.sales_part
add if not exists partition(saledate='2008-01-01')
location 's3://awssampledbuswest2/tickit/spectrum/sales_partition/saledate=2008-01/';


alter table spectrum.orc_example
set table properties('orc.schema.resolution'='name');

alter table spectrum.orc_example
set table properties('orc.schema.resolution'='position');

alter table spectrum.sales rename column sales_date to transaction_date;

alter table spectrum.sales_part
partition(saledate='2008-01-01')
set location 's3://awssampledbuswest2/tickit/spectrum/sales_partition/saledate=2008-01-01/';

alter table spectrum.sales_part
drop partition(saledate='2008-01-01');

alter table spectrum.sales
set file format parquet;

alter table spectrum.sales
set location 's3://awssampledbuswest2/tickit/spectrum/sales/';

alter table spectrum.sales
set table properties ('numRows'='170000');

ALTER TABLE tickit_category_redshift ROW LEVEL SECURITY ON FOR DATASHARES;

ALTER TABLE tickit_category_redshift ROW LEVEL SECURITY OFF;

alter table t2 alter column c0 encode lzo;

alter table t1 alter encode auto;

alter table t1 alter sortkey(c0, c1);

alter table inventory alter diststyle all;

alter table inventory alter distkey inv_item_sk;

alter table t1 alter sortkey none;

alter table t1 alter sortkey(c0, c1);

alter table inventory alter diststyle key distkey inv_warehouse_sk;

alter table inventory alter diststyle key distkey inv_warehouse_sk;

alter table inventory alter diststyle key distkey inv_warehouse_sk;

alter table t1 alter column c3 encode runlength;

alter table t1 alter column c2 encode bytedict;

alter table t1 alter column c0 encode az64;

alter table event alter column eventname type varchar(300);

alter table category
drop constraint category_pkey;

alter table venue
rename column venueseats to venuesize;

create view vdate as select * from date;
alter table vdate owner to vuser;

alter table venue
owner to dwuser;

alter table users
rename to users_bkup;

create view myevent as select eventname from event
with no schema binding;

create view myevent as select eventname from event
with no schema binding;

create view event_vw as select * from public.event
with no schema binding;

create view sales_vw as
select * from public.sales
union all
select * from spectrum.sales
with no schema binding;

create view myevent as select eventname from event
where eventname = 'LeAnn Rimes';

create view myevent as select eventname from public.event
with no schema binding;

create or replace view myuser as select lastname from users;

create view myuser as select lastname from users;

create table event_backup 
backup yes
 as select * from event;

create table eventdistsort
distkey (1)
sortkey (1,3)
as
select eventid, venueid, dateid, eventname
from event;

create table eventdistsort1
distkey (eventid)
sortkey (eventid, dateid)
as
select eventid, venueid, dateid, eventname
from event;

create table eventdisteven
diststyle even
as
select eventid, venueid, dateid, eventname
from event;

create table venuedistevent distkey(venueid)
as select * from event;

ATTACH MASKING POLICY credit_card_masking_policy
   ON customer_data
   ( credit_card_number )
   TO alice;

ATTACH MASKING POLICY salary_masking_policy
   ON employee_data
   ( salary )
   TO ROLE hr_role;
   
ATTACH MASKING POLICY email_masking_policy
   ON user_profiles
   ( email )
   TO PUBLIC
   PRIORITY 1;



ATTACH RLS POLICY policy_concerts ON tickit_category_redshift TO ROLE analyst, ROLE dbadmin;

commit;
commit transaction;
commit work;

CREATE ROLE sample_role1;
CREATE ROLE sample_role1 EXTERNALID "ABC123";

DEALLOCATE PREPARE my_prepared_statement;
DEALLOCATE my_prepared_statement;

DESC DATASHARE salesshare;
DESC DATASHARE salesshare of ACCOUNT '123456789012' NAMESPACE '13b8833d-17c6-4f16-8fe4-1a018f5ed00d';

DESC IDENTITY PROVIDER azure_idp;

DETACH MASKING POLICY credit_card_masking_policy
   ON customer_data
   ( credit_card_number )
   FROM  alice;
   
DETACH MASKING POLICY salary_masking_policy
   ON employee_data
   ( salary )
   FROM ROLE hr_role;
   
   
DETACH MASKING POLICY email_masking_policy
   ON user_profiles
   ( email )
   FROM PUBLIC;
  


DETACH RLS POLICY my_policy ON TABLE my_table1, mytable2
FROM user_name;

DETACH RLS POLICY my_policy ON TABLE table1, table2, table3
FROM ROLE role_name;

DETACH RLS POLICY my_policy ON TABLE my_table
FROM PUBLIC;


DETACH RLS POLICY policy_concerts ON tickit_category_redshift FROM ROLE analyst, ROLE dbadmin;

drop function f_sqrt(int);
drop function f_sqrt(int)cascade;

drop group guests;

DROP IDENTITY PROVIDER oauth_provider;

DROP MODEL demo_ml.customer_churn ;

DROP MATERIALIZED VIEW tickets_mv;

DROP PROCEDURE quarterly_revenue(volume INOUT bigint, at_price IN numeric,result OUT int);

DROP RLS POLICY my_policy;
DROP RLS POLICY my_policy CASCADE;
DROP RLS POLICY IF EXISTS my_policy;
DROP RLS POLICY IF EXISTS my_policy RESTRICT;


DROP ROLE my_role;
DROP ROLE my_role FORCE;
DROP ROLE my_role RESTRICT;
DROP LIBRARY my_library;

DROP MASKING POLICY my_policy;

drop schema s_sales restrict;
drop schema s_sales cascade;
drop schema if exists s_sales;
drop schema s_spectrum drop external database restrict;
drop schema s_sales, s_profit, s_revenue drop external database cascade;

EXECUTE 'my_query_plan';
EXECUTE 'my_query_plan' (param1_value, param2_value);

lock event, sales;

REFRESH MATERIALIZED VIEW tickets_mv;

reset query_group;
reset all;
RESET app_context.user_id;

rollback;

set datestyle to 'SQL,DMY';
SET app_context.user_id TO 123;
SET app_context.user_id TO 'sample_variable_value';

SET SESSION AUTHORIZATION 'dwuser';
SET LOCAL SESSION AUTHORIZATION 'dwuser';
SET SESSION AUTHORIZATION DEFAULT;

show query_group;
show all;
SHOW app_context.user_id;

SHOW EXTERNAL TABLE my_schema.alldatatypes_parquet_test_partitioned;
SHOW EXTERNAL TABLE my_schema.alldatatypes_parquet_test_partitioned PARTITION;

SHOW DATABASES FROM DATA CATALOG ACCOUNT '123456789012' ;

SHOW MODEL ALL;
SHOW MODEL customer_churn;

show procedure test_sp2(int,varchar);
SHOW PROCEDURE my_stored_procedure(IN arg1 INT, OUT arg2 VARCHAR, INOUT arg3 DECIMAL);



SHOW DATASHARES;
SHOW DATASHARES LIKE 'sales%';

show table sales;
show table public.category;
show table foo;

show view LA_Venues_v;
show view public.Sports_v;

DROP DATASHARE salesshare;

DROP DATABASE test_db;
drop database tickit_test;

create group admin_group with user admin1, admin2;

COMMENT ON TABLE sales IS 'This table stores tickets sales data';
COMMENT ON TABLE sales IS NULL;
comment on table event is 'Contains listings of individual events.';
COMMENT ON COLUMN my_table.column_name IS 'This is a comment for the column column_name.';

close movie_cursor;


cancel 802;
cancel 802 'Long-running query';


call test_sp1(3,'book',3.14);

BEGIN;
begin read write;

START TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION READ ONLY;

ABORT WORK;
ABORT TRANSACTION;

analyze verbose;
analyze listing;
analyze venue(venueid, venuename);
analyze venue predicate columns;

analyze compression listing;
analyze compression sales(qtysold, commission, saletime);

truncate category;
TRUNCATE TABLE Customers;


insert into category_stage values
(12, 'Concerts', 'Comedy', 'All stand-up comedy performances');

insert into category_stage values
(13, 'Concerts', 'Other', default);

insert into category_stage values
(14, default, default, default),
(15, default, default, default);

insert into category_stage values
(default, default, default, default),
(20, default, 'Country', default),
(21, 'Concerts', 'Rock', default);

insert into category_ident(catgroup,catname,catdesc);

INSERT INTO mytable VALUES(1);


drop user if exists paulo;
drop user paulo, martha;

drop view eventview cascade;
drop view if exists eventview;

end;
end work;

end transaction;

drop table feedback, buyers;
DROP TABLE IF EXISTS t2;

fetch forward 5 from memory;
fetch next from memory;


create table venue(
venueid smallint not null,
venuename varchar(100),
venuecity varchar(30),
venuestate char(2),
venueseats integer,
primary key(venueid))
diststyle all;


create temp table tempevent(like venue); 

create table T1 (
  col1 Varchar(20) collate case_insensitive
 );

create table myevent(
eventid int,
eventname varchar(200),
eventcity varchar(30))
diststyle even;

create table if not exists cities(
cityid integer not null,
city varchar(100) not null,
state char(2) not null); 

create table customer_interleaved 
(
  c_custkey     	integer        not null,
  c_name        	varchar(25)    not null,
  c_address     	varchar(25)    not null,
  c_city        	varchar(10)    not null,
  c_nation      	varchar(15)    not null,
  c_region      	varchar(12)    not null,
  c_phone       	varchar(15)    not null,
  c_mktsegment      varchar(10)    not null)
diststyle all
interleaved sortkey (c_custkey, c_city, c_mktsegment);

create table sales1(
salesid integer not null,
listid integer not null,
sellerid integer not null,
buyerid integer not null,
eventid integer not null encode mostly16,
dateid smallint not null,
qtysold smallint not null encode mostly8,
pricepaid decimal(8,2) encode delta32k,
commission decimal(8,2) encode delta32k,
saletime timestamp,
primary key(salesid),
foreign key(listid) references listing(listid),
foreign key(sellerid) references users(userid),
foreign key(buyerid) references users(userid),
foreign key(dateid) references date(dateid))
distkey(listid)
compound sortkey(listid,sellerid);

create table listing (
listid integer,
primary key(listid)
); 

create table users (
userid integer,
 primary key(userid)
);

create table date (
dateid smallint,
primary key(dateid)
);

create table venue_ident(venueid bigint identity(0, 1),
venuename varchar(100),
venuecity varchar(30),
venuestate char(2),
venueseats integer,
 primary key(venueid),
 UNIQUE (venuename));

CREATE TABLE t1(
  hist_id BIGINT  NOT NULL, /* Cannot be overridden */
  base_id BIGINT  NOT NULL, /* Can be overridden */
  business_key varchar(10) ,
  some_field varchar(10)
)
BACKUP YES
;

create table t1(col1 int , col2 int) diststyle key;

create table t2(col1 int , col2 int);

create table t3(col1 int, col2 int ) diststyle all;

create table t1(c0 int, c1 varchar);

create table categorydef(
catid smallint not null ,
catgroup varchar(10) ,
catname varchar(10) ,
catdesc varchar(50) ,
primary key(catid));

create table t2(c0 int, c1 varchar) encode auto;

create table t3(c0 int , c1 varchar) encode auto;


vacuum;

vacuum sales;

vacuum sales to 100 percent;

vacuum sort only sales to 75 percent;

vacuum delete only sales to 75 percent;

vacuum reindex listing;

vacuum reindex listing to 75 percent;

vacuum recluster listing;

vacuum recluster listing boost;

update category
set catgroup='Theatre'
where catid between 6 and 8;

update category
set catdesc=default, catname='Shows'
where catgroup='Theatre';

update category
set catdesc='Broadway Musical'
where category.catid in
(select category.catid from category
join event on category.catid = event.catid
join venue on venue.venueid = event.venueid
join sales on sales.eventid = event.eventid
where venuecity='New York City' and catname='Musicals');


update category set catid=100
from event
where event.catid=category.catid;

update category set catid=100
from event
where event.catid=category.catid
and catgroup='Concerts';

update category set catid=100
from event join category cat on event.catid=cat.catid
where cat.catgroup='Concerts';

update category set catid=100
from
(select event.catid from event left join category cat on event.catid=cat.catid) eventcat
where category.catid=eventcat.catid
and catgroup='Concerts';

unload ('select * from venue')
to 's3://mybucket/unload/'
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole';

unload ('select * from venue')
to 's3://mybucket/unload/venue_pipe_'
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole';

unload ('select * from lineitem')
to 's3://mybucket/lineitem/'
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole'
PARQUET
PARTITION BY (l_shipdate);

revoke usage on language sql from PUBLIC;

revoke insert on table sales from group guests;

revoke select on all tables in schema qa_tickit from fred;

revoke select on table eventview from bobr;

revoke temporary on database tickit from public;

revoke select(cust_name, cust_phone) on cust_profile from user1;

revoke select(cust_name, cust_phone), update(cust_contact_preference) on cust_profile from group sales_group;

revoke ALL(cust_name, cust_phone,cust_contact_preference) on cust_profile from group sales_admin;

revoke select(cust_name) on cust_profile_vw from user2;

REVOKE USAGE ON DATASHARE salesshare FROM NAMESPACE '13b8833d-17c6-4f16-8fe4-1a018f5ed00d';

REVOKE USAGE ON DATABASE sales_db FROM Bob;


REVOKE USAGE ON SCHEMA sales_schema FROM GROUP Analyst_group;

revoke assumerole on all from public for all;

revoke assumerole on all from reg_user1 for all;

REVOKE ROLE sample_role1 FROM ROLE sample_role2;

REVOKE ROLE sys:DBA FROM user1;

REVOKE ROLE sample_role1, ROLE sample_role2 FROM user1;

REVOKE ROLE sample_role2 FROM user1;

REVOKE ROLE sample_role1, ROLE sample_role2 FROM ROLE sample_role5;

REVOKE CREATE SCHEMA, DROP SCHEMA FROM ROLE sample_role1;

PREPARE prep_insert_plan (int, char)
AS insert into prep1 values ($1, $2);

PREPARE prep_select_plan (int)
AS select * from prep1 where c1 = $1;

MERGE INTO target USING source ON target.id = source.id
WHEN MATCHED THEN UPDATE SET id = source.id, name = source.name
WHEN NOT MATCHED THEN INSERT VALUES (source.id, source.name);

MERGE INTO target USING source ON target.id = source.id
WHEN MATCHED THEN DELETE
WHEN NOT MATCHED THEN INSERT VALUES (source.id, source.name);

INSERT INTO spectrum.lineitem
SELECT * FROM local_lineitem;

INSERT INTO spectrum.customer
SELECT name, age, gender, 'May', 28 FROM local_customer;

INSERT INTO spectrum.customer
SELECT name, age, gender, 'May', 28 FROM local_customer;

grant select on table sales to fred;

grant select on all tables in schema qa_tickit to fred;

create group qa_users;
grant all on schema qa_tickit to group qa_users;

grant all on table qa_tickit.sales to group qa_users;

grant all on table qa_tickit.sales to group qa_users, group ro_users;

grant drop on table qa_tickit.sales to group qa_users;

grant all on schema qa_tickit to schema_user;

grant all on view_date to view_user;

grant select(cust_name, cust_phone) on cust_profile to user1;

grant select(cust_name, cust_phone), update(cust_contact_preference) on cust_profile to group sales_group;

grant ALL(cust_name, cust_phone,cust_contact_preference) on cust_profile to group sales_admin;

grant select(cust_name) on cust_profile_vw to user2;

GRANT USAGE ON DATASHARE salesshare TO NAMESPACE '13b8833d-17c6-4f16-8fe4-1a018f5ed00d';

GRANT USAGE ON DATABASE sales_db TO Bob;

GRANT USAGE ON SCHEMA sales_schema TO GROUP Analyst_group;

revoke assumerole on all from public for all;

grant assumerole on 'arn:aws:iam::123456789012:role/Redshift-S3-Read'
to reg_user1 for copy;

grant assumerole
on 'arn:aws:iam::123456789012:role/RoleA,arn:aws:iam::210987654321:role/RoleB'
to reg_user1
for unload; 

grant assumerole on 'arn:aws:iam::123456789012:role/Redshift-Exfunc'
to reg_user1 for external function;

grant assumerole on 'arn:aws:iam::123456789012:role/Redshift-ML'
to reg_user1 for create model;

GRANT ROLE sample_role1 TO user1;

GRANT ROLE sample_role1 TO user1 WITH ADMIN OPTION;
SET SESSION AUTHORIZATION user1;
GRANT ROLE sample_role1 TO user2;

GRANT ROLE sample_role1 TO ROLE sample_role2;

GRANT ROLE sample_role2 TO ROLE sample_role3;
GRANT ROLE sample_role3 TO ROLE sample_role2;

GRANT CREATE USER TO ROLE sample_role1;

GRANT ROLE sys:dba TO user1;

GRANT ROLE sample_role2 TO ROLE sample_role3;
GRANT ROLE sample_role3 TO ROLE sample_role2; 

EXPLAIN
SELECT *
FROM lf_db.public.t_share
WHERE a > 1;

explain
select eventid, eventname, event.venueid, venuename
from event, venue
where event.venueid = venue.venueid;

explain verbose
select eventid, eventname, event.venueid, venuename
from event, venue
where event.venueid = venue.venueid;

explain create table venue_nonulls as
select * from venue
where venueseats is not null;

delete from category;

delete from category
where catid between 0 and 9;

delete from listing
where listing.sellerid not in(select sales.sellerid from sales);

delete from category
using event
where event.catid=category.catid and category.catid=9;

delete from listing
where listing.sellerid not in(select sales.sellerid from sales);


delete from category
using event
where event.catid=category.catid and category.catid=9;

delete from category
where catid in
(select category.catid from category, event
where category.catid=event.catid and category.catid=9);

declare lollapalooza cursor for
select eventname, starttime, pricepaid/qtysold as costperticket, qtysold
from sales, event
where sales.eventid = event.eventid
and eventname='Lollapalooza';

create user user1 password 'md5153c434b4b77c89e6b94f12c5393af5b';

CREATE USER admin PASSWORD 'sha256|Mypassword1';

CREATE USER admin PASSWORD 'sha256|821708135fcc42eb3afda85286dee0ed15c2c461d000291609f77eb113073ec2|c721bff5d9042cf541ff7b9d48fa8a6e545c19a763e3710151f9513038b0f6c6';

create user iam_superuser password 'md5A1234567890123456780123456789012' createuser;

create user dbuser with password 'abcD1234' createdb connection limit 30;

create user dbuser with password 'abcD1234' valid until '2017-06-10';

create user newman with password '@AbC4321!';

create user slashpass password 'md50c983d1a624280812631c5389e60d48c';

CREATE USER dbuser password 'abcD1234' SESSION TIMEOUT 120;

CREATE MODEL example_model
    FROM (SELECT * FROM sales_data)
    TARGET sale_amount
    FUNCTION XGBOOST (float, integer, float, varchar)
    IAM_ROLE 'arn:aws:iam::123456789012:role/redshift-ml-role'
    AUTO ON
    MODEL_TYPE XGBOOST
    PROBLEM_TYPE REGRESSION
    OBJECTIVE 'MSE'
    PREPROCESSORS 'none'
    HYPERPARAMETERS DEFAULT
    SETTINGS (
        S3_BUCKET 'example-bucket',
        KMS_KEY_ID 'arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012',
        S3_GARBAGE_COLLECT on,
        MAX_CELLS 2000000,
        MAX_RUNTIME 7200,
        HORIZON 7,
        FREQUENCY 1,
        PERCENTILES '50, 75, 90'
    );
	
DROP MODEL abalone_xgboost_multi_predict_age;

CREATE MODEL abalone_xgboost_multi_predict_age
FROM ( SELECT length_val,
			  diameter,
			  height,
			  whole_weight,
			  shucked_weight,
			  viscera_weight,
			  shell_weight,
			  rings
FROM abalone_xgb WHERE record_number < 2500 )
TARGET rings FUNCTION ml_fn_abalone_xgboost_multi_predict_age
IAM_ROLE default
AUTO OFF
MODEL_TYPE XGBOOST
OBJECTIVE 'multi:softmax'
PREPROCESSORS 'none'
HYPERPARAMETERS DEFAULT EXCEPT (NUM_ROUND '100', NUM_CLASS '30')
    SETTINGS (S3_BUCKET 'your-bucket');
	
CREATE MODEL customer_churn
    FROM 'training-job-customer-churn-v4'
    FUNCTION customer_churn_predict (varchar, int, float, float)
    RETURNS int
    IAM_ROLE default
    SETTINGS (S3_BUCKET 'your-bucket');


create library f_urlparse
language plpythonu
from 's3://mybucket/urlparse3-1.0.3.zip'
credentials 'aws_iam_role=arn:aws:iam::<aws-account-id>:role/<role-name>'
region as 'us-east-1';  

create library f_urlparse
language plpythonu
from 'https://example.com/packages/urlparse3-1.0.3.zip';

CREATE IDENTITY PROVIDER identity_provider_name TYPE type_name
NAMESPACE namespace_name
 PARAMETERS parameter_string;
 
 CREATE DATASHARE demoshare SET PUBLICACCESSIBLE TRUE, MANAGEDBY ADX;
 
 CREATE DATASHARE salesshare;
 
 ALTER USER odie SET TIMEZONE TO 'Europe/Zurich';
 
 ALTER USER myco_aad:bob EXTERNALID "ABC123" PASSWORD DISABLE;
 
 ALTER USER dbuser RESET SESSION TIMEOUT;
 
 ALTER USER dbuser SESSION TIMEOUT 300;
 
 alter user admin rename to sysadmin;
 
 alter user admin password 'adminPass9'
valid until '2017-12-31 23:59';

alter user admin createdb;

alter user iam_superuser password 'md51234567890123456780123456789012';

alter table sales append from sales_listing ignoreextra;

ALTER TABLE target_tbl APPEND FROM my_streaming_materialized_view;

alter table sales_report append from sales_month filltarget;

ALTER ROLE sample_role1 WITH RENAME TO sample_role2;

ALTER ROLE sample_role1 WITH OWNER TO user1;

ALTER ROLE sample_role1 EXTERNALID TO "XYZ456";

ALTER PROCEDURE quarterly_revenue(bigint, numeric) OWNER TO etl_user;

ALTER RLS POLICY policy_concerts
USING (catgroup = 'piano concerts');

ALTER IDENTITY PROVIDER oauth_standard
PARAMETERS '{"issuer":"https://sts.windows.net/2sdfdsf-d475-420d-b5ac-667adad7c702/",
"client_id":"87f4aa26-78b7-410e-bf29-57b39929ef9a",
"client_secret":"BUAH~ewrqewrqwerUUY^%tHe1oNZShoiU7",
"audience":["https://analysis.windows.net/powerbi/connector/AmazonRedshift"]
}';

alter group admin_group
rename to administrators;

alter group admin_group
add user dwuser;

alter default privileges for user report_admin grant select on tables to group report_readers; 

alter default privileges grant select on tables to public; 

alter default privileges in schema sales grant insert on tables to group sales_admin; 

alter default privileges in schema sales revoke insert on tables from group sales_admin;

alter default privileges revoke execute on functions from public;
alter default privileges grant execute on functions to group dev_test; 

ALTER DATASHARE salesshare REMOVE TABLE public.tickit_sales_redshift;

ALTER DATASHARE salesshare ADD ALL TABLES IN SCHEMA PUBLIC;

ALTER DATASHARE salesshare ADD TABLE public.tickit_sales_redshift;


ALTER DATASHARE salesshare SET PUBLICACCESSIBLE FALSE;

copy catdemo
from 's3://awssampledbuswest2/tickit/category_pipe.txt'
iam_role 'arn:aws:iam::<aws-account-id>:role/<role-name>'
region 'us-west-2';

COPY public.target_table
FROM 's3://mybucket-bucket/staging-folder'
IAM_ROLE 'arn:aws:iam::123456789012:role/MyLoadRoleName' 
JOB CREATE my_copy_job_name
AUTO ON;   

copy customer
from 's3://mybucket/customer' 
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole';

copy customer
from 's3://mybucket/cust.manifest' 
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole'
manifest;      

copy sales
from 's3://mybucket/ssh_manifest' 
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole'
ssh;       

copy favoritemovies from 'dynamodb://ProductCatalog'
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole'
readratio 50;  

copy customer from 's3://mybucket/mydata' 
credentials 
'aws_iam_role=arn:aws:iam::<account-id>:role/<role-name>;master_symmetric_key=<root-key>';

copy sales
from 'emr://j-SAMPLE2B500FC/myoutput/part-*' 
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole'
delimiter '\t' lzop;

copy sales
from 'emr://j-SAMPLE2B500FC/myoutput/json/' 
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole'
JSON 's3://mybucket/jsonpaths.txt';

copy customer
from 's3://mybucket/cust.manifest' 
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole'
format as orc
manifest;

copy listing 
from 's3://mybucket/data/listings/parquet/' 
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole'
format as parquet;

copy event
from 's3://mybucket/data/allevents_pipe.txt' 
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole' 
removequotes
emptyasnull
blanksasnull
maxerror 5
delimiter '|'
timeformat 'YYYY-MM-DD HH:MI:SS';

copy venue
from 's3://mybucket/data/venue_fw.txt' 
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole'
fixedwidth 'venueid:3,venuename:25,venuecity:12,venuestate:2,venueseats:6';

copy category
from 's3://mybucket/data/category_csv.txt' 
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole' 
csv quote as '%';

copy venue
from 's3://mybucket/data/venue.txt' 
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole'
explicit_ids;

copy time
from 's3://mybucket/data/timerows.gz' 
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole'
gzip
delimiter '|';

copy redshiftinfo from 's3://mybucket/data/redshiftinfo.txt' 
iam_role 'arn:aws:iam::0123456789012:role/MyRedshiftRole' 
delimiter '|' escape;

COPY norway_water FROM 's3://bucket_name/shapefiles/norway/gis_osm_water_a_free_1.shp'
FORMAT SHAPEFILE
SIMPLIFY AUTO
CREDENTIALS 'aws_iam_role=arn:aws:iam::123456789012:role/MyRoleName';

COPY norway_water FROM 's3://bucket_name/shapefiles/norway/gis_osm_water_a_free_1.shp'
FORMAT SHAPEFILE
SIMPLIFY AUTO 1.1E-05
MAXERROR 2
CREDENTIALS 'aws_iam_role=arn:aws:iam::123456789012:role/MyRoleName';

COPY norway_natural FROM 's3://bucket_name/shapefiles/norway/compressed/gis_osm_natural_free_1.shp.gz'
FORMAT SHAPEFILE
GZIP
CREDENTIALS 'aws_iam_role=arn:aws:iam::123456789012:role/MyRoleName';

COPY public.zipcode1
FROM 's3://mybucket/mydata/zipcode.csv' 
DELIMITER ';' 
IGNOREHEADER 1 REGION 'us-east-1'
NOLOAD
CREDENTIALS 'aws_iam_role=arn:aws:iam::123456789012:role/myRedshiftRole';

create table Employee(empID integer primary key,emp_name varchar (25));

create table organization(ID integer primary key,empID integer references Employee (empID));


create table person(name varchar(25),ID int primary key ,age int default 18);


CREATE EXTERNAL PROTECTED VIEW sample_schema.glue_data_catalog_view IF NOT EXISTS
AS SELECT * FROM sample_database.remote_table;

ALTER EXTERNAL VIEW sample_schema.glue_data_catalog_view
FORCE
REMOVE DEFINITION

ALTER FUNCTION first_quarter_revenue(bigint, numeric, int) 
         RENAME TO quarterly_revenue;

ALTER FUNCTION quarterly_revenue(bigint, numeric) OWNER TO etl_user;

ALTER SYSTEM SET default_identity_namespace = 'MYCO';

ALTER SYSTEM SET data_catalog_auto_mount = true;

create  table order_items 
(
order_id int,
col2 int

);

create local temp  table orders 
(
order_id int,
col2 int

);

ALTER TABLE orders
ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


ALTER TABLE order_items
ADD CONSTRAINT fk_order_id FOREIGN KEY (order_id)
REFERENCES orders (order_id);


DROP EXTERNAL VIEW gsds.glue_data_catalog_view IF EXISTS


SHOW COLUMNS FROM TABLE awsdatacatalog.batman.nation LIMIT 2;

// Vis_25112026_[251101000]_ALTER EXTERNAL SCHEMA (URI, IAM_ROLE, AUTHENTICATION MTLS, AUTHENTICATION_ARN)
ALTER EXTERNAL SCHEMA schema_name
URI 'lkc-ghidef-67890.centralus.azure.glb.confluent.cloud:9092';

ALTER EXTERNAL SCHEMA kafka_schema IAM_ROLE default AUTHENTICATION mtls AUTHENTICATION_ARN 'arn:aws:acm:us-east-1:123456789012:certificate/abcd1234';

// Vis_25112026_[251101001]_CREATE DATABASE: FROM INTEGRATION SET options, COLLATE CI, IAM_ROLE, quoted OF ACCOUNT id
CREATE DATABASE sales_zetl FROM INTEGRATION 'a1b2c3d4-5678-90ab-cdef-EXAMPLE11111' DATABASE 'sourcedb' SET ACCEPTINVCHARS = TRUE HISTORY_MODE = TRUE REFRESH_INTERVAL 600;

CREATE DATABASE sampledb2 WITH OWNER dwuser CONNECTION LIMIT UNLIMITED COLLATE CI ISOLATION LEVEL SNAPSHOT;

CREATE DATABASE lf_db FROM ARN 'arn:aws:glue:us-east-1:123456789012:database/lf_db' WITH DATA CATALOG SCHEMA 'lf_schema' IAM_ROLE default;

CREATE DATABASE sales_db WITH PERMISSIONS FROM DATASHARE salesshare OF ACCOUNT '123456789012' NAMESPACE '13b8833d-17c6-4f16-8fe4-1a018f5ed00d';

// Vis_25112026_[251101002]_ALTER DATABASE: combined options, COLLATE CS, INTEGRATION REFRESH REMEDIABLE, INTEGRATION SET
ALTER DATABASE sampledb CONNECTION LIMIT 50 COLLATE CS ISOLATION LEVEL SERIALIZABLE;

ALTER DATABASE sample_integration_db INTEGRATION REFRESH REMEDIABLE TABLES IN SCHEMA sample_schema;

ALTER DATABASE sample_integration_db INTEGRATION SET QUERY_ALL_STATES = TRUE HISTORY_MODE = TRUE FOR TABLE sample_schema.orders;

// Vis_25112026_[251101003]_DROP DATABASE FORCE
DROP DATABASE tickit_test FORCE;

// Vis_25112026_[251101004]_CREATE SCHEMA AUTHORIZATION username
CREATE SCHEMA AUTHORIZATION dwuser QUOTA 50 GB;

// Vis_25112026_[251101005]_CREATE EXTERNAL SCHEMA: FROM KAFKA, AUTHENTICATION MTLS, optional source, clauses in any order
CREATE EXTERNAL SCHEMA kafka_schema
FROM KAFKA
IAM_ROLE default
URI 'b-1.mycluster.kafka.us-east-1.amazonaws.com:9094'
AUTHENTICATION mtls
AUTHENTICATION_ARN 'arn:aws:acm:us-east-1:123456789012:certificate/abcd1234';

CREATE EXTERNAL SCHEMA spectrum_schema2 FROM DATABASE 'spectrum_db' IAM_ROLE 'SESSION' CATALOG_ROLE 'SESSION';

// Vis_25112026_[251101006]_ALTER DATASHARE: SET INCLUDENEW TRUE FOR SCHEMA, function with empty argument list
ALTER DATASHARE salesshare SET INCLUDENEW = TRUE FOR SCHEMA public;

ALTER DATASHARE salesshare ADD FUNCTION public.get_version();

// Vis_25112026_[251101007]_DESC DATASHARE with numeric account id
DESC DATASHARE salesshare OF ACCOUNT 123456789012 NAMESPACE '13b8833d-17c6-4f16-8fe4-1a018f5ed00d';

// Vis_25112026_[251101008]_Column COLLATE CI / CS abbreviations
CREATE TABLE t_collate_abbrev (id INTEGER, name VARCHAR(50) COLLATE CI, code CHAR(5) COLLATE CS);

// Vis_25112026_[251101009]_New data types: SUPER, BOOL, NCHAR, BINARY VARYING, INTERVAL, TIME/TIMESTAMP WITH TIME ZONE
CREATE TABLE t_new_types (c1 SUPER, c2 BOOL, c3 NCHAR(10), c4 BINARY VARYING(20), c5 INTERVAL YEAR TO MONTH, c6 INTERVAL DAY TO SECOND, c7 TIMESTAMP WITH TIME ZONE, c8 TIME WITH TIME ZONE);

// Vis_25112026_[251101010]_CREATE EXTERNAL TABLE STORED AS RCFILE
CREATE EXTERNAL TABLE spectrum.sales_rc (salesid INTEGER, pricepaid DECIMAL(8,2))
STORED AS RCFILE
LOCATION 's3://amzn-s3-demo-bucket/tickit/spectrum/sales_rc/';

// Vis_25112026_[251101011]_ALTER TABLE: RLS CONJUNCTION TYPE, MASKING FOR DATASHARES, comma-separated clauses, multi-column PARTITION, multiple TABLE PROPERTIES
ALTER TABLE tickit_category_redshift ROW LEVEL SECURITY ON CONJUNCTION TYPE OR FOR DATASHARES;

ALTER TABLE tickit_category_redshift MASKING ON FOR DATASHARES;

ALTER TABLE sales ALTER SORTKEY (salesid, listid), ALTER DISTKEY sellerid;

ALTER TABLE spectrum.sales_part ADD IF NOT EXISTS PARTITION (saledate='2008-01-01', region='us') LOCATION 's3://amzn-s3-demo-bucket/tickit/spectrum/sales_partition/saledate=2008-01/';

ALTER TABLE spectrum.sales SET TABLE PROPERTIES ('numRows'='170000', 'skip.header.line.count'='1');

// Vis_25112026_[251101012]_ALTER TABLE APPEND with schema-qualified target
ALTER TABLE public.sales APPEND FROM public.sales_monthly IGNOREEXTRA;

// Vis_25112026_[251101013]_TRUNCATE schema-qualified table
TRUNCATE TABLE public.category;

// Vis_25112026_[251101014]_ALTER MATERIALIZED VIEW: AUTO REFRESH YES INTERVAL, ALTER DISTSTYLE/SORTKEY
ALTER MATERIALIZED VIEW tickets_mv AUTO REFRESH YES INTERVAL 3600;

ALTER MATERIALIZED VIEW tickets_mv ALTER DISTSTYLE KEY DISTKEY catgroup;

ALTER MATERIALIZED VIEW tickets_mv ALTER COMPOUND SORTKEY (catgroup, sold);

// Vis_25112026_[251101015]_DROP MATERIALIZED VIEW list with CASCADE
DROP MATERIALIZED VIEW IF EXISTS tickets_mv, public.sales_mv CASCADE;

// Vis_25112026_[251101016]_REFRESH MATERIALIZED VIEW schema-qualified with CASCADE
REFRESH MATERIALIZED VIEW public.tickets_mv CASCADE;

// Vis_25112026_[251101017]_DROP FUNCTION with any argument list and schema-qualified name
DROP FUNCTION f_sql_greater(float, float);

DROP FUNCTION public.f_py_greater(a float, b float) CASCADE;

// Vis_25112026_[251101018]_ALTER / DROP / SHOW PROCEDURE with argmode argument lists, optional list, schema-qualified names
ALTER PROCEDURE public.quarterly_revenue(volume INOUT bigint, at_price IN numeric) RENAME TO quarterly_revenue2;

DROP PROCEDURE quarterly_revenue(volume INOUT bigint, at_price IN numeric,result OUT int);

SHOW PROCEDURE test_sp2(int, varchar);

SHOW PROCEDURE public.test_sp1;

// Vis_25112026_[251101020]_CALL with argument expressions, empty list and schema-qualified name
CALL public.test_sp1(3, 'book');

CALL test_sp2();

// Vis_25112026_[251101019]_CREATE PROCEDURE SET configuration with a string value
CREATE OR REPLACE PROCEDURE sp_set_path()
AS $$
BEGIN
  RAISE INFO 'ok';
END;
$$ LANGUAGE plpgsql
SET search_path TO 'public';

// Vis_25112026_[251101021]_CREATE MODEL with schema-qualified model name
CREATE MODEL demo_ml.customer_churn_auto
FROM customer_activity
TARGET churn
FUNCTION ml_fn_customer_churn_auto
IAM_ROLE default
SETTINGS (S3_BUCKET 'amzn-s3-demo-bucket');

// Vis_25112026_[251101022]_CREATE EXTERNAL MODEL (Bedrock) with quoted and unquoted SETTINGS values
CREATE EXTERNAL MODEL llm_claude
FUNCTION llm_claude_func
IAM_ROLE 'arn:aws:iam::123456789012:role/RedshiftBedrockRole'
MODEL_TYPE BEDROCK
SETTINGS (
    MODEL_ID 'anthropic.claude-v2:1',
    PROMPT 'Summarize the following text:',
    REQUEST_TYPE RAW,
    RESPONSE_TYPE SUPER);

CREATE EXTERNAL MODEL llm_titan FUNCTION llm_titan_func IAM_ROLE default MODEL_TYPE BEDROCK SETTINGS (MODEL_ID amazon.titan-text-express-v1, REQUEST_TYPE UNIFIED);

// Vis_25112026_[251101023]_ALTER USER: comma-separated options, NOLOGIN, LOGIN PASSWORD
ALTER USER dbuser CONNECTION LIMIT 10, SESSION TIMEOUT 300;

ALTER USER dbuser NOLOGIN;

ALTER USER dbuser LOGIN PASSWORD 'Abcd1234';

// Vis_25112026_[251101024]_ALTER DEFAULT PRIVILEGES ... ON PROCEDURES / ON TABLES
ALTER DEFAULT PRIVILEGES IN SCHEMA sales GRANT EXECUTE ON PROCEDURES TO ROLE sales_role;

ALTER DEFAULT PRIVILEGES FOR USER report_admin GRANT SELECT ON TABLES TO GROUP report_readers;

// Vis_25112026_[251101025]_GRANT/REVOKE: mixed privileges, new ON objects, scoped FOR ... IN, ADMIN/GRANT OPTION FOR, new grantees
GRANT EXECUTE ON PROCEDURE public.sp_get_current_user_definer() TO ROLE analyst;

GRANT EXECUTE ON FUNCTION f_sql_greater(float, float) TO GROUP report_readers;

GRANT SELECT, TRUNCATE ON ALL TABLES IN SCHEMA sales TO ROLE etl_role;

GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA sales TO bob;

GRANT EXECUTE FOR FUNCTIONS IN SCHEMA Sales_schema TO bob;

REVOKE EXECUTE FOR FUNCTIONS IN SCHEMA Sales_schema FROM bob;

GRANT SELECT FOR TABLES IN SCHEMA sales DATABASE dev TO ROLE analyst;

GRANT ALTER, DROP ON COPY JOB my_copy_job TO ROLE etl_role;

GRANT USAGE ON TEMPLATE test_schema.demo_template TO ROLE etl_role;

GRANT EXECUTE ON MODEL customer_churn TO ROLE analyst;

GRANT CREATE, ALTER, DROP ON EXTERNAL SCHEMA spectrum_schema TO IAM_ROLE 'arn:aws:iam::123456789012:role/myrole';

GRANT ACCESS SYSTEM TABLE, IGNORE RLS, EXPLAIN MASKING TO ROLE auditor;

GRANT SELECT ON TABLE lookup_table TO MASKING POLICY mask_credit_card;

GRANT CONNECT ON WORKGROUP TO idc:alice;

REVOKE ADMIN OPTION FOR ROLE sample_role FROM bob;

REVOKE GRANT OPTION SELECT FOR TABLES IN SCHEMA sales FROM bob;

GRANT DEBUG ON DATABASE fed_db TO ADMINS OF ACCOUNT '123456789012';

GRANT EXECUTE ON PROCEDURE sales_sp(int) TO DATASHARE salesshare;

// Vis_25112026_[251101028]_RLS policies: database-qualified names, multi-column WITH, unquoted alias, ATTACH/DETACH on db.schema.table
CREATE RLS POLICY policy_concerts
WITH (catgroup VARCHAR(10))
USING (catgroup = 'Concerts');

CREATE RLS POLICY dev.policy_sales WITH (region VARCHAR(20), amount INTEGER) AS s USING (region = 'us-east');

ALTER RLS POLICY dev.policy_sales USING (region = 'us-west');

DROP RLS POLICY IF EXISTS dev.policy_sales CASCADE;

ATTACH RLS POLICY dev.policy_sales ON TABLE dev.public.sales TO ROLE analyst, ROLE dbadmin;

DETACH RLS POLICY dev.policy_sales ON TABLE dev.public.sales FROM ROLE analyst;

// Vis_25112026_[251101028]_Masking policies with database-qualified policy names
CREATE MASKING POLICY dev.mask_credit_card WITH (credit_card VARCHAR(256)) USING ('XXXXXXXXXXXX'::TEXT);

ALTER MASKING POLICY dev.mask_credit_card USING ('000000000000'::TEXT);

// Vis_25112026_[251101029]_ATTACH / DETACH MASKING POLICY on qualified relation with USING (input columns)
ATTACH MASKING POLICY dev.mask_credit_card ON dev.public.credit_cards (credit_card) USING (credit_card) TO ROLE analyst PRIORITY 10;

DETACH MASKING POLICY dev.mask_credit_card ON dev.public.credit_cards (credit_card) FROM ROLE analyst;

// Vis_25112026_[251101028]_DROP MASKING POLICY with database-qualified name
DROP MASKING POLICY dev.mask_credit_card;

// Vis_25112026_[251101026]_CREATE IDENTITY PROVIDER with APPLICATION_ARN and IAM_ROLE, no PARAMETERS
CREATE IDENTITY PROVIDER "redshift-idc-app" TYPE AWSIDC
NAMESPACE 'awsidc'
APPLICATION_ARN 'arn:aws:sso::123456789012:application/ssoins-12345f67fe123d4/apl-a0b0a12dc123b1a4'
IAM_ROLE 'arn:aws:iam::123456789012:role/MyRedshiftRole';

// Vis_25112026_[251101027]_ALTER IDENTITY PROVIDER with multiple clauses and AUTO_CREATE_ROLES
ALTER IDENTITY PROVIDER "my-redshift-idc-application" IAM_ROLE 'arn:aws:iam::123456789012:role/myadministratorrole' AUTO_CREATE_ROLES TRUE INCLUDE GROUPS LIKE 'sales%';

// Vis_25112026_[251101030]_SELECT: QUALIFY after FROM table, GROUP BY ALL, SELECT INTO regression
SELECT venuestate, venuename FROM venue QUALIFY ROW_NUMBER() OVER (PARTITION BY venuestate ORDER BY venuename) = 1;

SELECT catgroup, SUM(qtysold) FROM category GROUP BY ALL;

select * into newevent from event;

// Vis_25112026_[251101031]_INSERT VALUES with :: cast, negative decimal, function call; INSERT ... SELECT regression
INSERT INTO t1(col1) VALUES ('Incomplete'::char(3));

INSERT INTO sales_history VALUES (1, -2.5, getdate(), DEFAULT, NULL);

INSERT INTO spectrum.lineitem
SELECT * FROM local_lineitem;

// Vis_25112026_[251101032]_UPDATE schema-qualified table with alias
UPDATE public.category AS c SET catgroup = 'Theatre' WHERE catid = 9;

// Vis_25112026_[251101033]_MERGE with schema-qualified tables and source alias
MERGE INTO public.target USING public.source AS s ON target.id = s.id REMOVE DUPLICATES;

// Vis_25112026_[251101034]_COPY JOB forms, COPY ... JOB CREATE, FORMAT AS JSON 'auto' with comma-separated parameters
COPY JOB RUN my_copy_job_name;

COPY JOB DROP my_copy_job_name;

COPY public.target_table
FROM 's3://amzn-s3-demo-bucket/staging-folder'
IAM_ROLE 'arn:aws:iam::123456789012:role/MyLoadRoleName'
JOB CREATE my_copy_job_name
AUTO ON;

COPY category FROM 's3://amzn-s3-demo-bucket/category_object_auto.json' IAM_ROLE default FORMAT AS JSON 'auto', REGION 'us-east-1';

// Vis_25112026_[251101035]_UNLOAD: FORMAT AS PARQUET, NULL AS, ADDQUOTES without argument
UNLOAD ('select * from venue') TO 's3://amzn-s3-demo-bucket/unload/venue_' IAM_ROLE default FORMAT AS PARQUET PARTITION BY (venuestate) INCLUDE;

UNLOAD ('select * from venue') TO 's3://amzn-s3-demo-bucket/unload/venue_' IAM_ROLE 'arn:aws:iam::0123456789012:role/MyRedshiftRole' CSV NULL AS 'N/A' ADDQUOTES ALLOWOVERWRITE;

// Vis_25112026_[251101036]_CREATE [OR REPLACE] TEMPLATE FOR COPY
CREATE TEMPLATE test_schema.demo_template
FOR COPY
AS
FORMAT JSON 'auto'
NULL AS 'N/A'
MAXERROR 100;

CREATE OR REPLACE TEMPLATE dev.test_schema.csv_template FOR COPY CSV IGNOREHEADER 1, DELIMITER ',';

// Vis_25112026_[251101037]_ALTER TEMPLATE: RENAME TO, SET, ADD, DROP
ALTER TEMPLATE test_template
RENAME TO demo_template;

ALTER TEMPLATE test_schema.demo_template SET MAXERROR TO 50, IGNOREHEADER TO 2;

ALTER TEMPLATE test_schema.demo_template ADD TRUNCATECOLUMNS;

ALTER TEMPLATE test_schema.demo_template DROP MAXERROR;

// Vis_25112026_[251101038]_DROP TEMPLATE
DROP TEMPLATE test_schema.test_template;

// Vis_25112026_[251101039]_BEGIN / START TRANSACTION isolation levels READ UNCOMMITTED, REPEATABLE READ
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED READ WRITE;

START TRANSACTION ISOLATION LEVEL REPEATABLE READ;

// Vis_25112026_[251101040]_LOCK schema-qualified tables
LOCK TABLE public.event, public.sales;

// Vis_25112026_[251101041]_VACUUM schema-qualified table with FORCE
VACUUM FULL public.sales TO 75 PERCENT BOOST FORCE;

// Vis_25112026_[251101042]_EXECUTE with number and string parameters
EXECUTE prep_insert_plan (2, 'Two');

// Vis_25112026_[251101043]_COMMENT ON schema-qualified table and columns
COMMENT ON TABLE public.sales IS 'This table stores tickets sales data';

COMMENT ON COLUMN public.sales.qtysold IS 'Quantity sold';

COMMENT ON COLUMN sales.pricepaid IS 'Price paid';

// Vis_25112026_[251101044]_SET with value list and decimal value
SET search_path TO '$user', public;

SET seed TO 0.25;

// Vis_25112026_[251101045]_SHOW EXTERNAL TABLE database.schema.table
SHOW EXTERNAL TABLE spectrum_db.my_schema.alldatatypes_parquet_test_partitioned PARTITION;

// Vis_25112026_[251101046]_USE database
use pdb;

// Vis_25112026_[251101047]_SHOW DATABASES: optional FROM DATA CATALOG, LIKE, IAM_ROLE, LIMIT
SHOW DATABASES;

SHOW DATABASES LIKE 'sample%' LIMIT 5;

SHOW DATABASES FROM DATA CATALOG ACCOUNT '123456789012' IAM_ROLE default LIMIT 10;

// Vis_25112026_[251101048]_SHOW USER LOCKOUT
SHOW USER LOCKOUT;

// Vis_25112026_[251101049]_SHOW COLUMN GRANTS
SHOW COLUMN GRANTS ON TABLE demo_db.demo_schema.t100 FOR ROLE analyst LIMIT 10;

// Vis_25112026_[251101050]_SHOW CONSTRAINTS PRIMARY KEYS / FOREIGN KEYS [EXPORTED]
SHOW CONSTRAINTS PRIMARY KEYS FROM TABLE demo_db.demo_schema.pk1;

SHOW CONSTRAINTS FOREIGN KEYS EXPORTED FROM TABLE demo_schema.pk1 LIMIT 5;

// Vis_25112026_[251101051]_SHOW FUNCTIONS
SHOW FUNCTIONS FROM SCHEMA demo_schema like '%discount';

// Vis_25112026_[251101052]_SHOW PROCEDURES
SHOW PROCEDURES FROM SCHEMA demo_db.demo_schema;

// Vis_25112026_[251101053]_SHOW GRANTS ON database/function/table and FOR ROLE
SHOW GRANTS on database demo_db;

SHOW GRANTS ON FUNCTION demo_schema.f2(int, varchar) FOR PUBLIC;

SHOW GRANTS ON TABLE demo_db.demo_schema.t100 FOR alice LIMIT 20;

SHOW GRANTS FOR ROLE analyst FROM DATABASE demo_db;

// Vis_25112026_[251101054]_SHOW PARAMETERS OF FUNCTION / PROCEDURE
SHOW PARAMETERS OF FUNCTION demo_schema.f2(INT, VARCHAR, DECIMAL, DATE, TIMESTAMP, BOOLEAN);

SHOW PARAMETERS OF PROCEDURE demo_db.demo_schema.p1(INT) LIKE 'a%';

// Vis_25112026_[251101055]_SHOW RLS / MASKING POLICIES
SHOW RLS POLICIES;

SHOW MASKING POLICIES ON demo_schema.credit_cards FOR ROLE analyst LIMIT 10;

SHOW RLS POLICIES FROM DATABASE demo_db;

// Vis_25112026_[251101056]_SHOW TEMPLATE
SHOW TEMPLATE test_template;

// Vis_25112026_[251101057]_SHOW TEMPLATES
SHOW TEMPLATES FROM SCHEMA s1 LIKE 'demo%' LIMIT 10;

// Vis_26112026_[261101142]_CREATE EXTERNAL VIEW without PROTECTED; USING ICEBERG with LOCATION / PARTITIONED BY / TABLE PROPERTIES
CREATE EXTERNAL VIEW sample_schema.glue_data_catalog_view2 IF NOT EXISTS
AS SELECT * FROM sample_database.remote_table;

CREATE EXTERNAL VIEW iceberg_view_loc USING ICEBERG LOCATION 's3://amzn-s3-demo-bucket/iceberg/view1/';

CREATE EXTERNAL VIEW sample_schema.iceberg_view_part USING ICEBERG LOCATION 's3://amzn-s3-demo-bucket/iceberg/view2/' PARTITIONED BY (sale_date)
AS SELECT sale_id, sale_date, amount FROM sales;

CREATE EXTERNAL VIEW sample_schema.iceberg_view_props USING ICEBERG TABLE PROPERTIES ('format-version'='2', 'write.format.default'='parquet')
AS SELECT * FROM sample_database.remote_table;

CREATE EXTERNAL PROTECTED VIEW sample_schema.iceberg_view_full IF NOT EXISTS USING ICEBERG LOCATION 's3://amzn-s3-demo-bucket/iceberg/view3/' PARTITIONED BY (region, sale_date) TABLE PROPERTIES ('format-version'='2')
AS SELECT region, sale_date, SUM(amount) FROM sales GROUP BY region, sale_date;
