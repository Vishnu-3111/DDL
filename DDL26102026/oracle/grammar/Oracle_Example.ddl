CREATE TABLE employees_demo1
    ( employee_id    NUMBER(6)
    , first_name     VARCHAR2(20)
    , last_name      VARCHAR2(25) 
         CONSTRAINT emp_last_name_nn_demo NOT NULL
    , email          VARCHAR2(25) 
         CONSTRAINT emp_email_nn_demo     NOT NULL
    , phone_number   VARCHAR2(20)
    , hire_date      DATE  DEFAULT SYSDATE 
         CONSTRAINT emp_hire_date_nn_demo  NOT NULL
    , job_id         VARCHAR2(10)
       CONSTRAINT     emp_job_nn_demo  NOT NULL
    , salary         NUMBER(8,2)
       CONSTRAINT     emp_salary_nn_demo  NOT NULL
    , commission_pct NUMBER(2,2)
    , manager_id     NUMBER(6)
    , department_id  NUMBER(4)
    , dn             VARCHAR2(300)
    , CONSTRAINT     emp_salary_min_demo
                     CHECK (salary > 0) 
    , CONSTRAINT     emp_email_uk_demo
                     UNIQUE (email)
    ) ;


CREATE TABLE employees_demo2
    ( employee_id    NUMBER(6)
		, first_name     VARCHAR2(20)
		, last_name      VARCHAR2(25) 
			 CONSTRAINT emp_last_name_nn_demo NOT NULL
		, email          VARCHAR2(25) 
			 CONSTRAINT emp_email_nn_demo     NOT NULL
		, phone_number   VARCHAR2(20)
		, hire_date      DATE  DEFAULT SYSDATE 
			 CONSTRAINT emp_hire_date_nn_demo  NOT NULL
		, job_id         VARCHAR2(10)
		   CONSTRAINT     emp_job_nn_demo  NOT NULL
		, salary         NUMBER(8,2)
		   CONSTRAINT     emp_salary_nn_demo  NOT NULL
		, commission_pct NUMBER(2,2)
		, manager_id     NUMBER(6)
		, department_id  NUMBER(4)
		, dn             VARCHAR2(300)
		, CONSTRAINT     emp_salary_min_demo
						 CHECK (salary > 0) 
		, CONSTRAINT     emp_email_uk_demo
						 UNIQUE (email)
    ) 
   TABLESPACE example 
   STORAGE (INITIAL 8M)
  
   ;
   
CREATE TABLE myemp (employee_id number, last_name varchar2(25),
                    department_id NUMBER DEFAULT ON NULL 50 NOT NULL);
					
CREATE TABLE t1 (id NUMBER GENERATED AS IDENTITY);

CREATE GLOBAL TEMPORARY TABLE today_sales
   ON COMMIT PRESERVE ROWS 
   AS SELECT * FROM orders WHERE order_date = SYSDATE;
   
 CREATE TABLE later (col1 NUMBER, col2 VARCHAR2(20))    SEGMENT CREATION DEFERRED;
 
 CREATE TABLE persons1 OF person_t;
 
CREATE TABLE books (title VARCHAR2(100), author person_t);
 
CREATE TABLE dept_801
   PARALLEL
   AS SELECT * FROM employees
   WHERE department_id = 80;
   
   CREATE TABLE dept_802
   AS SELECT * FROM employees
   WHERE department_id = 80;
   
   CREATE TABLE departments_demo1
    ( department_id    NUMBER(4)
    , department_name  VARCHAR2(30)
           CONSTRAINT  dept_name_nn  NOT NULL
    , manager_id       NUMBER(6)
    , location_id      NUMBER(4)
    , dn               VARCHAR2(300)
    ) ;
	
	CREATE TABLE departments_demo2
    ( department_id    NUMBER(4)   PRIMARY KEY DISABLE
    , department_name  VARCHAR2(30)
           CONSTRAINT  dept_name_nn  NOT NULL
    , manager_id       NUMBER(6)
    , location_id      NUMBER(4)
    , dn               VARCHAR2(300)
    ) ;
	
	CREATE TABLE print_media
    ( product_id        NUMBER(6) REFERENCES hash_products(product_id) ON DELETE CASCADE
    , ad_id             NUMBER(6)
    , ad_composite      BLOB
    , ad_sourcetext     CLOB
    , ad_finaltext      CLOB
    , ad_fltextn        NCLOB
    , ad_textdocs_ntab  textdoc_tab
    , ad_photo          BLOB
    , ad_graphic        BFILE
    , ad_header         adheader_typ
    ) NESTED TABLE ad_textdocs_ntab STORE AS textdocs_nestedtab;
	
	CREATE TABLE business_contacts (
   company_name VARCHAR2(25),
   company_reps customer_list)
   NESTED TABLE company_reps STORE AS outer_ntab
   (NESTED TABLE phones STORE AS inner_ntab);
   
   CREATE TABLE my_customers (
   name VARCHAR2(25),
   phone_numbers phone_list)
   NESTED TABLE phone_numbers STORE AS outer_ntab
   (NESTED TABLE COLUMN_VALUE STORE AS inner_ntab);
   
   CREATE TABLE print_media_new
    ( product_id        NUMBER(6)
    , ad_id             NUMBER(6)
    , ad_composite      BLOB
    , ad_sourcetext     CLOB
    , ad_finaltext      CLOB
    , ad_fltextn        NCLOB
    , ad_textdocs_ntab  textdoc_tab
    , ad_photo          BLOB
    , ad_graphic        BFILE
    , ad_header         adheader_typ
    ) NESTED TABLE ad_textdocs_ntab STORE AS textdocs_nestedtab_new
    LOB (ad_sourcetext, ad_finaltext) STORE AS
      (TABLESPACE example
       STORAGE (INITIAL 6144)
       CHUNK 4000
       NOCACHE LOGGING); 
	   
	   
CREATE TABLE countries_demo
    ( country_id      CHAR(2)
      CONSTRAINT country_id_nn_demo NOT NULL
    , country_name    VARCHAR2(40)
    , currency_name   VARCHAR2(25)
    , currency_symbol VARCHAR2(3)
    , region          VARCHAR2(15)
    , CONSTRAINT    country_c_id_pk_demo
                    PRIMARY KEY (country_id ) )
    ORGANIZATION INDEX 
    INCLUDING   country_name 
    PCTTHRESHOLD 2 
    STORAGE 
     ( INITIAL  4K ) 
   OVERFLOW 
    STORAGE 
      ( INITIAL  4K ); 
	  
CREATE TABLE dept_external (
   deptno     NUMBER(6),
   dname      VARCHAR2(20),
   loc        VARCHAR2(25) 
)
ORGANIZATION EXTERNAL
(TYPE oracle_loader
 DEFAULT DIRECTORY admin
 ACCESS PARAMETERS
 (
  RECORDS DELIMITED BY newline
  BADFILE 'ulcase1.bad'
  DISCARDFILE 'ulcase1.dis'
  LOGFILE 'ulcase1.log'
  SKIP 20
  FIELDS TERMINATED BY ","  OPTIONALLY ENCLOSED BY '"'
  (
   deptno     INTEGER EXTERNAL(6),
   dname      CHAR(20),
   loc        CHAR(25)
  )
 )
 LOCATION ('ulcase1.ctl')
)
REJECT LIMIT UNLIMITED;

CREATE TABLE xwarehouses1 OF XMLTYPE;

CREATE TABLE xwarehouses2 OF XMLTYPE
   XMLSCHEMA "http://www.example.com/xwarehouses.xsd"
   ELEMENT "Warehouse";

CREATE TABLE xwarehouses3 (
   warehouse_id        NUMBER,
   warehouse_spec      XMLTYPE)
   XMLTYPE warehouse_spec STORE AS CLOB
   (TABLESPACE example
    STORAGE (INITIAL 6144)
    CHUNK 4000
    NOCACHE LOGGING);
	
CREATE TABLE xwarehouses4 (
   warehouse_id    NUMBER,
   warehouse_spec  XMLTYPE)
   XMLTYPE warehouse_spec STORE AS OBJECT RELATIONAL
      XMLSCHEMA "http://www.example.com/xwarehouses.xsd"
      ELEMENT "Warehouse";
	  
CREATE TABLE xwarehouses5 (
  warehouse_id   NUMBER,
  warehouse_spec XMLTYPE)
  XMLTYPE        warehouse_spec STORE AS SECUREFILE CLOB
  (TABLESPACE auto_seg_ts
  STORAGE (INITIAL 6144)
  CACHE);
  
CREATE TABLE range_sales
    ( prod_id        NUMBER(6)
    , cust_id        NUMBER
    , time_id        DATE
    , channel_id     CHAR(1)
    , promo_id       NUMBER(6)
    , quantity_sold  NUMBER(3)
    , amount_sold         NUMBER(10,2)
    ) 
PARTITION BY RANGE (time_id)
  (PARTITION SALES_Q1_1998 VALUES LESS THAN (TO_DATE('01-APR-1998','DD-MON-YYYY')),
   PARTITION SALES_Q2_1998 VALUES LESS THAN (TO_DATE('01-JUL-1998','DD-MON-YYYY')),
   PARTITION SALES_Q3_1998 VALUES LESS THAN (TO_DATE('01-OCT-1998','DD-MON-YYYY')),
   PARTITION SALES_Q4_1998 VALUES LESS THAN (TO_DATE('01-JAN-1999','DD-MON-YYYY')),
   PARTITION SALES_Q1_1999 VALUES LESS THAN (TO_DATE('01-APR-1999','DD-MON-YYYY')),
   PARTITION SALES_Q2_1999 VALUES LESS THAN (TO_DATE('01-JUL-1999','DD-MON-YYYY')),
   PARTITION SALES_Q3_1999 VALUES LESS THAN (TO_DATE('01-OCT-1999','DD-MON-YYYY')),
   PARTITION SALES_Q4_1999 VALUES LESS THAN (TO_DATE('01-JAN-2000','DD-MON-YYYY')),
   PARTITION SALES_Q1_2000 VALUES LESS THAN (TO_DATE('01-APR-2000','DD-MON-YYYY')),
   PARTITION SALES_Q2_2000 VALUES LESS THAN (TO_DATE('01-JUL-2000','DD-MON-YYYY')),
   PARTITION SALES_Q3_2000 VALUES LESS THAN (TO_DATE('01-OCT-2000','DD-MON-YYYY')),
   PARTITION SALES_Q4_2000 VALUES LESS THAN (MAXVALUE))
;

CREATE TABLE empl_h  
  (  
     employee_id  NUMBER(6) PRIMARY KEY,  
     first_name   VARCHAR2(20),  
     last_name    VARCHAR2(25),  
     email        VARCHAR2(25),  
     phone_number VARCHAR2(20),  
     hire_date    DATE DEFAULT SYSDATE,  
     job_id       VARCHAR2(10),  
     salary       NUMBER(8, 2),  
     part_name    VARCHAR2(25)  
  ) PARTITION BY RANGE (hire_date) (  
PARTITION hire_q1 VALUES less than(to_date('01-APR-2014', 'DD-MON-YYYY')),   
PARTITION hire_q2 VALUES less than(to_date('01-JUL-2014', 'DD-MON-YYYY')),   
PARTITION hire_q3 VALUES less than(to_date('01-OCT-2014', 'DD-MON-YYYY')),   
PARTITION hire_q4 VALUES less than(to_date('01-JAN-2015', 'DD-MON-YYYY'))  
);

CREATE TABLE parts (p_name) AS SELECT PARTITION_NAME FROM USER_TAB_PARTITIONS WHERE TABLE_NAME = 'EMPL_H';

CREATE TABLE customers_demo (
  customer_id number(6),
  cust_first_name varchar2(20),
  cust_last_name varchar2(20),
  credit_limit number(9,2))
PARTITION BY RANGE (credit_limit)
INTERVAL (1000)
(PARTITION p1 VALUES LESS THAN (5001));

CREATE TABLE list_customers 
   ( customer_id             NUMBER(6)
   , cust_first_name         VARCHAR2(20) 
   , cust_last_name          VARCHAR2(20)
   , cust_address            CUST_ADDRESS_TYP
   , nls_territory           VARCHAR2(30)
   , cust_email              VARCHAR2(40))
   PARTITION BY LIST (nls_territory) (
   PARTITION asia VALUES ('CHINA', 'THAILAND'),
   PARTITION europe VALUES ('GERMANY', 'ITALY', 'SWITZERLAND'),
   PARTITION west VALUES ('AMERICA'),
   PARTITION east VALUES ('INDIA'),
   PARTITION rest VALUES (DEFAULT)); 
   
   
CREATE TABLE hash_products 
    ( product_id          NUMBER(6)   PRIMARY KEY
    , product_name        VARCHAR2(50) 
    , product_description VARCHAR2(2000) 
    , category_id         NUMBER(2) 
    , weight_class        NUMBER(1) 
    , warranty_period     INTERVAL YEAR TO MONTH 
    , supplier_id         NUMBER(6) 
    , product_status      VARCHAR2(20) 
    , list_price          NUMBER(8,2) 
    , min_price           NUMBER(8,2) 
    , catalog_url         VARCHAR2(50) 
    , CONSTRAINT          product_status_lov_demo 
                          CHECK (product_status in ('orderable' 
                                                  ,'planned' 
                                                  ,'under development' 
                                                  ,'obsolete') 
 ) ) 
 PARTITION BY HASH (product_id) 
 PARTITIONS 4 
 STORE IN (tbs_01, tbs_02, tbs_03, tbs_04); 
 
CREATE TABLE part_order_items (
    order_id        NUMBER(12) PRIMARY KEY,
    line_item_id    NUMBER(3),
    product_id      NUMBER(6) NOT NULL,
    unit_price      NUMBER(8,2),
    quantity        NUMBER(8),
    CONSTRAINT product_id_fk
    FOREIGN KEY (product_id) REFERENCES hash_products(product_id) ON DELETE CASCADE)
 PARTITION BY REFERENCE (product_id_fk);
 


CREATE TABLE customers_part (
   customer_id        NUMBER(6),
   cust_first_name    VARCHAR2(20),
   cust_last_name     VARCHAR2(20),
   nls_territory      VARCHAR2(30),
   credit_limit       NUMBER(9,2)) 
   PARTITION BY RANGE (credit_limit)
   SUBPARTITION BY LIST (nls_territory)
      SUBPARTITION TEMPLATE 
         (SUBPARTITION east  VALUES 
            ('CHINA', 'JAPAN', 'INDIA', 'THAILAND'),
          SUBPARTITION west VALUES 
             ('AMERICA', 'GERMANY', 'ITALY', 'SWITZERLAND'),
          SUBPARTITION other VALUES (DEFAULT))
      (PARTITION p1 VALUES LESS THAN (1000),
       PARTITION p2 VALUES LESS THAN (2500),
       PARTITION p3 VALUES LESS THAN (MAXVALUE));
	   
	   
CREATE TABLE departments_obj_t OF department_typ; 


CREATE TABLE salesreps OF salesrep_typ;

CREATE TABLE employees_obj_t OF employees_typ (e_no PRIMARY KEY)
   OBJECT IDENTIFIER IS PRIMARY KEY;
     
CREATE VIEW emp_view AS 
   SELECT last_name, salary*12 annual_salary
   FROM employees 
   WHERE department_id = 20;


CREATE EDITIONING VIEW ed_orders_view (o_id, o_date, o_status)
  AS SELECT order_id, order_date, order_status FROM orders
  WITH READ ONLY;


CREATE VIEW emp_sal (emp_id, last_name, 
      email UNIQUE RELY DISABLE NOVALIDATE,
   CONSTRAINT id_pk PRIMARY KEY (emp_id) RELY DISABLE NOVALIDATE)
   AS SELECT employee_id, last_name, email FROM employees;

CREATE VIEW clerk1 AS
   SELECT employee_id, last_name, department_id, job_id 
   FROM employees
   WHERE job_id = 'PU_CLERK' 
      or job_id = 'SH_CLERK' 
      or job_id = 'ST_CLERK';
	  
CREATE VIEW clerk2 AS
   SELECT employee_id, last_name, department_id, job_id 
   FROM employees
   WHERE job_id = 'PU_CLERK' 
      or job_id = 'SH_CLERK' 
      or job_id = 'ST_CLERK'
   WITH CHECK OPTION;
   
CREATE VIEW locations_view AS
   SELECT d.department_id, d.department_name, l.location_id, l.city
   FROM departments d, locations l
   WHERE d.location_id = l.location_id;
   
CREATE VIEW customer_ro (name, language, credit)
      AS SELECT cust_last_name, nls_language, credit_limit
      FROM customers
      WITH READ ONLY;
	  
CREATE OR REPLACE VIEW oc_inventories OF inventory_typ
 WITH OBJECT OID (product_id)
 AS SELECT i.product_id,
           warehouse_typ(w.warehouse_id, w.warehouse_name, w.location_id),
           i.quantity_on_hand
    FROM inventories i, warehouses w
    WHERE i.warehouse_id=w.warehouse_id;
	
CREATE VIEW warehouse_view1 AS
   SELECT VALUE(p) AS warehouse_xml
   FROM xwarehouses p;


CREATE VIEW warehouse_view2 OF XMLTYPE
 XMLSCHEMA "http://www.example.com/xwarehouses.xsd" 
    ELEMENT "Warehouse"
    WITH OBJECT ID 
    (extract(OBJECT_VALUE, '/Warehouse/Area/text()').getnumberval())
 AS SELECT XMLELEMENT("Warehouse",
            XMLFOREST(WarehouseID as "Building",
                      area as "Area",
                      docks as "Docks",
                      docktype as "DockType",
                      wateraccess as "WaterAccess",
                      railaccess as "RailAccess",
                      parking as "Parking",
                      VClearance as "VClearance"))
  FROM warehouse_table;
  
  CREATE OR REPLACE ANALYTIC VIEW sales_av
USING sales_fact
DIMENSION BY
  (time_attr_dim                         -- An attribute dimension of time data
    KEY month_id REFERENCES month_id
    HIERARCHIES (
      time_hier DEFAULT),
   product_attr_dim                      -- An attribute dimension of product data
    KEY category_id REFERENCES category_id
    HIERARCHIES (
      product_hier DEFAULT),
   geography_attr_dim                    -- An attribute dimension of store data
    KEY state_province_id 
    REFERENCES state_province_id HIERARCHIES (
      geography_hier DEFAULT)
   )
MEASURES
 (sales FACT sales,                      -- A base measure
  units FACT units,                      -- A base measure
  sales_prior_period AS                  -- Calculated measures
    (LAG(sales) OVER (HIERARCHY time_hier OFFSET 1)),
  sales_year_ago AS
    (LAG(sales) OVER (HIERARCHY time_hier OFFSET 1
     ACROSS ANCESTOR AT LEVEL year)),
  chg_sales_year_ago AS
    (LAG_DIFF(sales) OVER (HIERARCHY time_hier OFFSET 1
     ACROSS ANCESTOR AT LEVEL year)),
  pct_chg_sales_year_ago AS
    (LAG_DIFF_PERCENT(sales) OVER (HIERARCHY time_hier OFFSET 1
     ACROSS ANCESTOR AT LEVEL year)),
  sales_qtr_ago AS
    (LAG(sales) OVER (HIERARCHY time_hier OFFSET 1
     ACROSS ANCESTOR AT LEVEL quarter)),
  chg_sales_qtr_ago AS
    (LAG_DIFF(sales) OVER (HIERARCHY time_hier OFFSET 1
     ACROSS ANCESTOR AT LEVEL quarter)),
  pct_chg_sales_qtr_ago AS
    (LAG_DIFF_PERCENT(sales) OVER (HIERARCHY time_hier OFFSET 1
     ACROSS ANCESTOR AT LEVEL quarter))
  )
DEFAULT MEASURE SALES;

CREATE MATERIALIZED VIEW mv1 AS SELECT * FROM hr.employees;

CREATE MATERIALIZED VIEW foreign_customers
   AS SELECT * FROM sh.customers@remote cu
   WHERE EXISTS
     (SELECT * FROM sh.countries@remote co
      WHERE co.country_id = cu.country_id);
	  
CREATE MATERIALIZED VIEW LOG ON times
   WITH ROWID, SEQUENCE (time_id, calendar_year)
   INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW LOG ON products
   WITH ROWID, SEQUENCE (prod_id)
   INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW sales_mv
   BUILD IMMEDIATE
   REFRESH FAST ON COMMIT
   AS SELECT t.calendar_year, p.prod_id, 
      SUM(s.amount_sold) AS sum_sales
      FROM times t, products p, sales s
      WHERE t.time_id = s.time_id AND p.prod_id = s.prod_id
      GROUP BY t.calendar_year, p.prod_id;
	  
CREATE MATERIALIZED VIEW sales_by_month_by_state
     TABLESPACE example
     PARALLEL 4
     BUILD IMMEDIATE
     REFRESH COMPLETE
     ENABLE QUERY REWRITE
     AS SELECT t.calendar_month_desc, c.cust_state_province,
        SUM(s.amount_sold) AS sum_sales
        FROM times t, sales s, customers c
        WHERE s.time_id = t.time_id AND s.cust_id = c.cust_id
        GROUP BY t.calendar_month_desc, c.cust_state_province;
		
CREATE TABLE sales_sum_table
   (month VARCHAR2(8), state VARCHAR2(40), sales NUMBER(10,2));

CREATE MATERIALIZED VIEW sales_sum_table
   ON PREBUILT TABLE WITH REDUCED PRECISION
   ENABLE QUERY REWRITE
   AS SELECT t.calendar_month_desc AS month, 
             c.cust_state_province AS state,
             SUM(s.amount_sold) AS sales
      FROM times t, customers c, sales s
      WHERE s.time_id = t.time_id AND s.cust_id = c.cust_id
      GROUP BY t.calendar_month_desc, c.cust_state_province;

CREATE MATERIALIZED VIEW catalog   
   REFRESH FAST START WITH SYSDATE NEXT SYSDATE + 1/4096 
   WITH PRIMARY KEY 
   AS SELECT * FROM product_information;  

CREATE MATERIALIZED VIEW order_data REFRESH WITH ROWID 
   AS SELECT * FROM orders; 

CREATE MATERIALIZED VIEW LOG ON employees
   WITH PRIMARY KEY
   INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW emp_data 
   PCTFREE 5 PCTUSED 60 
   TABLESPACE example 
   STORAGE (INITIAL 50K)
   REFRESH FAST NEXT sysdate + 7 
   AS SELECT * FROM employees; 


CREATE MATERIALIZED VIEW all_customers
   PCTFREE 5 PCTUSED 60 
   TABLESPACE example 
   STORAGE (INITIAL 50K) 
   USING INDEX STORAGE (INITIAL 25K)
   REFRESH START WITH ROUND(SYSDATE + 1) + 11/24 
   NEXT NEXT_DAY(TRUNC(SYSDATE), 'MONDAY') + 15/24 
   AS SELECT * FROM sh.customers@remote 
         UNION
      SELECT * FROM sh.customers@local; 

CREATE MATERIALIZED VIEW LOG ON inventories
   WITH (quantity_on_hand);

CREATE MATERIALIZED VIEW my_warranty_orders
   AS SELECT w.order_id, w.line_item_id, o.order_date
   FROM warranty_orders w, orders o
   WHERE o.order_id = o.order_id
   AND o.sales_rep_id = 165;    
   
CREATE MATERIALIZED VIEW LOG ON customers1
   PCTFREE 5 
   TABLESPACE example 
   STORAGE (INITIAL 10K);

CREATE MATERIALIZED VIEW LOG ON customers2 WITH PRIMARY KEY, ROWID;
  
CREATE MATERIALIZED VIEW LOG ON sales1
   WITH ROWID, SEQUENCE(amount_sold, time_id, prod_id)
   INCLUDING NEW VALUES; 

CREATE MATERIALIZED VIEW LOG ON order_items WITH (product_id);

CREATE MATERIALIZED VIEW products_mv 
   REFRESH FAST ON COMMIT
   AS SELECT SUM(list_price - min_price), category_id
         FROM product_information 
         GROUP BY category_id;

CREATE MATERIALIZED VIEW LOG ON sales2
   PCTFREE 5 
   TABLESPACE example 
   STORAGE (INITIAL 10K)
   FOR SYNCHRONOUS REFRESH USING mystage_log;
   
  
  CREATE SEQUENCE customers_seq
 START WITH     1000
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;
 
 CREATE FUNCTION get_bal(acc_no IN NUMBER) 
   RETURN NUMBER 
   IS acc_bal NUMBER(11,2);
   BEGIN 
      SELECT order_total 
      INTO acc_bal 
      FROM orders 
      WHERE customer_id = acc_no; 
      RETURN(acc_bal); 
    END;

CREATE FUNCTION SecondMax (input NUMBER) RETURN NUMBER
    PARALLEL_ENABLE AGGREGATE USING SecondMaxImpl;
	
CREATE OR REPLACE FUNCTION text_length(a CLOB) 
   RETURN NUMBER DETERMINISTIC IS
BEGIN 
  RETURN DBMS_LOB.GETLENGTH(a);
END;

CREATE PROCEDURE remove_emp (employee_id NUMBER) AS
   tot_emps NUMBER;
   BEGIN
      DELETE FROM employees
      WHERE employees.employee_id = remove_emp.employee_id;
   tot_emps := tot_emps - 1;
   END;


CREATE PROCEDURE find_root
   ( x IN REAL ) 
   IS LANGUAGE C
      NAME c_find_root
      LIBRARY c_utils
      PARAMETERS ( x BY REFERENCE );
	  
create table t_employees
( salary NUMBER,
	department_id NUMBER 

);
	  
CREATE OR REPLACE TRIGGER t
  BEFORE
    INSERT OR
    UPDATE OF salary, department_id OR
    DELETE
  ON t_employees
BEGIN
  CASE
    WHEN INSERTING THEN
      DBMS_OUTPUT.PUT_LINE('Inserting');
    WHEN UPDATING('salary') THEN
      DBMS_OUTPUT.PUT_LINE('Updating salary');
    WHEN UPDATING('department_id') THEN
      DBMS_OUTPUT.PUT_LINE('Updating department ID');
    WHEN DELETING THEN
      DBMS_OUTPUT.PUT_LINE('Deleting');
  END CASE;
END;

CREATE OR REPLACE VIEW order_info AS
   SELECT c.customer_id, c.cust_last_name, c.cust_first_name,
          o.order_id, o.order_date, o.order_status
   FROM customers c, orders o
   WHERE c.customer_id = o.customer_id;

CREATE OR REPLACE TRIGGER order_info_insert
   INSTEAD OF INSERT ON order_info
   DECLARE
     duplicate_info EXCEPTION;
     PRAGMA EXCEPTION_INIT (duplicate_info, -00001);
   BEGIN
     INSERT INTO customers
       (customer_id, cust_last_name, cust_first_name)
     VALUES (
     :new.customer_id,
     :new.cust_last_name,
     :new.cust_first_name);
   INSERT INTO orders (order_id, order_date, customer_id)
   VALUES (
     :new.order_id,
     :new.order_date,
     :new.customer_id);
   EXCEPTION
     WHEN duplicate_info THEN
       RAISE_APPLICATION_ERROR (
         num=> -20107,
         msg=> 'Duplicate customer or order ID');
   END order_info_insert;
   
-- Create view:

CREATE OR REPLACE VIEW dept_view AS
  SELECT d.department_id, 
         d.department_name        
  FROM departments d;
 
-- Create trigger:
 
CREATE OR REPLACE TRIGGER dept_emplist_tr
  INSTEAD OF INSERT ON NESTED TABLE emplist OF dept_view
  REFERENCING NEW AS Employee
              PARENT AS Department
  FOR EACH ROW
BEGIN
  -- Insert on nested table translates to insert on base table:
  INSERT INTO employees (
    employee_id,
    last_name,
    email,
    hire_date,
    job_id,
    salary,
    department_id
  )
  VALUES (
    :Employee.emp_id,                      -- employee_id
    :Employee.lastname,                    -- last_name
    :Employee.lastname || '@example.com',  -- email
    SYSDATE,                               -- hire_date
    :Employee.job,                         -- job_id
    :Employee.sal,                         -- salary
    :Department.department_id              -- department_id
  );
END;

create table orders
(
	customer_id NUMBER,
	sales_rep_id NUMBER,
	order_mode STRING
);

CREATE INDEX ord_customer_ix
   ON orders (customer_id);

   
CREATE INDEX ord_customer_ix_demo 
   ON orders (customer_id, sales_rep_id)
   COMPRESS 1;
   
CREATE INDEX ord_customer_ix_demo
   ON orders (order_mode)
   NOSORT
   NOLOGGING;
   
CREATE UNIQUE INDEX promo_ix ON orders
   (CASE WHEN promotion_id = 2 THEN customer_id ELSE NULL END,
    CASE WHEN promotion_id = 2 THEN promotion_id ELSE NULL END);
   
CREATE TABLE personnel;
   
CREATE INDEX idx_personnel ON CLUSTER personnel; 


CREATE TABLE example_table (
  column1 VARCHAR2(50) COLLATE BINARY_CI VISIBLE CONSTRAINT col1_unique UNIQUE, -- Basic column with collation, visibility, and constraint
  column2 NUMBER INVISIBLE, -- Invisible column
  column3 NUMBER GENERATED ALWAYS AS (column1 + column2) VIRTUAL, -- Virtual generated column
  column4 DATE DEFAULT SYSDATE, -- Default value
  column5 VARCHAR2(100) CONSTRAINT chk_length CHECK (LENGTH(column5) > 5) -- Check constraint
);


CREATE TABLE persons_with_defaults OF person_typ
  (id DEFAULT 0, name DEFAULT 'Unknown', date_of_birth DEFAULT SYSDATE, status DEFAULT 'Active');

ADMINISTER KEY MANAGEMENT
  CREATE KEYSTORE '/etc/ORACLE/WALLETS/orcl'
  IDENTIFIED BY password;
  
ADMINISTER KEY MANAGEMENT
  SET KEYSTORE OPEN
  IDENTIFIED BY password
  CONTAINER = CURRENT;
  
ADMINISTER KEY MANAGEMENT
  BACKUP KEYSTORE USING 'hr.emp_keystore'
  IDENTIFIED BY password
  TO '/etc/ORACLE/KEYSTORE/DB1/';
  
 ADMINISTER KEY MANAGEMENT
  ALTER KEYSTORE PASSWORD IDENTIFIED BY old_password
  SET new_password WITH BACKUP USING 'pwd_change';
  
ADMINISTER KEY MANAGEMENT
  MERGE KEYSTORE '/etc/ORACLE/KEYSTORE/DB1'
  AND KEYSTORE '/etc/ORACLE/KEYSTORE/DB2'
    IDENTIFIED BY existing_keystore_password
  INTO NEW KEYSTORE '/etc/ORACLE/KEYSTORE/DB3'
    IDENTIFIED BY new_keystore_password;
	
ADMINISTER KEY MANAGEMENT
  MERGE KEYSTORE '/etc/ORACLE/KEYSTORE/DB1'
  INTO EXISTING KEYSTORE '/etc/ORACLE/KEYSTORE/DB2'
    IDENTIFIED BY existing_keystore_password
  WITH BACKUP;

ADMINISTER KEY MANAGEMENT ISOLATE KEYSTORE IDENTIFIED BY isolated_keystore_password
FROM ROOT KEYSTORE FORCE KEYSTORE IDENTIFIED BY EXTERNAL STORE
WITH BACKUP USING 'backup_03';

ADMINISTER KEY MANAGEMENT
  CREATE KEY USING TAG 'mykey1'
  IDENTIFIED BY password
  WITH BACKUP;
  
ADMINISTER KEY MANAGEMENT
  USE KEY 'ARgEtzPxpE/Nv8WdPu8LJJUAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  IDENTIFIED BY password
  WITH BACKUP;

ADMINISTER KEY MANAGEMENT UNITE KEYSTORE IDENTIFIED BY isolated_keystore_password
WITH ROOT KEYSTORE IDENTIFIED BY united_keystore_password
WITH BACKUP USING 'backup_01';

ADMINISTER KEY MANAGEMENT SET ENCRYPTION KEY mkid:1234abcd
USING TAG 'MonthlyRotation'
USING ALGORITHM 'AES256'
FORCE KEYSTORE
IDENTIFIED BY EXTERNAL STORE
WITH BACKUP USING 'backup_03'
CONTAINER = ALL;

ADMINISTER KEY MANAGEMENT
  SET TAG 'mykey2' FOR 'ARgEtzPxpE/Nv8WdPu8LJJUAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  FORCE KEYSTORE
  IDENTIFIED BY password
  WITH BACKUP;

ADMINISTER KEY MANAGEMENT
  EXPORT KEYS WITH SECRET "my_secret"
  TO '/etc/TDE/export.exp'
  IDENTIFIED BY password
  WITH IDENTIFIER IN 'AdoxnJ0uH08cv7xkz83ovwsAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
                     'AW5z3CoyKE/yv3cNT5CWCXUAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
					 
ADMINISTER KEY MANAGEMENT
  IMPORT KEYS WITH SECRET "my_secret"
  FROM '/etc/TDE/export.exp'
  IDENTIFIED BY password
  WITH BACKUP;
  
ADMINISTER KEY MANAGEMENT
  SET ENCRYPTION KEY IDENTIFIED BY "user_id:password"
  MIGRATE USING software_keystore_password
  WITH BACKUP;
  
ADMINISTER KEY MANAGEMENT
  SET ENCRYPTION KEY IDENTIFIED BY software_keystore_password
  REVERSE MIGRATE USING "user_id:password";
  
  
ADMINISTER KEY MANAGEMENT MOVE ENCRYPTION KEYS 
    TO NEW KEYSTORE '/path/to/new/keystore_location1'
    IDENTIFIED BY 'keystore1_password'
    FROM FORCE KEYSTORE
    IDENTIFIED BY 'keystore_password'
    WITH IDENTIFIER IN ('key_id_1', 'key_id_2')
    WITH BACKUP USING 'backup_identifier';
	
ADMINISTER KEY MANAGEMENT
  ADD SECRET 'secret1' FOR CLIENT 'client1'
  USING TAG 'My first secret'
  IDENTIFIED BY password
  WITH BACKUP;
  
ADMINISTER KEY MANAGEMENT
  DELETE SECRET FOR CLIENT 'client1'
  IDENTIFIED BY password
  WITH BACKUP;

-- Update an existing secret for a client in an auto-login keystore
ADMINISTER KEY MANAGEMENT UPDATE SECRET 'newSecret456' FOR CLIENT 'myClient'
    USING TAG 'clientTag'
    TO LOCAL AUTO_LOGIN KEYSTORE '/path/to/keystore_directory';
	
-- Delete a secret for a client from an auto-login keystore
ADMINISTER KEY MANAGEMENT DELETE SECRET FOR CLIENT 'myClient'
    FROM LOCAL AUTO_LOGIN KEYSTORE '/path/to/keystore_directory';


ADMINISTER KEY MANAGEMENT SWITCHOVER TO LIBRARY 'updated_fully_qualified_file_name_of_library' FOR ALL CONTAINERS


ALTER ANALYTIC VIEW TKHCSGL308_UNITS_AVIEW_CACHE ADD CACHE
    MEASURE GROUP (sales, units, cost)
    LEVELS (TIME.FISCAL.FISCAL_QUARTER, WAREHOUSE);
	
ALTER ATTRIBUTE DIMENSION product_attr_dim RENAME TO my_product_attr_dim;

ALTER AUDIT POLICY dp_actions_pol
  ADD ACTIONS COMPONENT = datapump EXPORT
  DROP ACTIONS COMPONENT = datapump IMPORT;
  
ALTER AUDIT POLICY hr_admin_pol
  DROP PRIVILEGES CREATE ANY TABLE
       ACTIONS LOCK TABLE
       ROLES audit_viewer;
	   
	   
ALTER AUDIT POLICY emp_updates_pol
  CONDITION 'UID = 102'
  EVALUATE PER STATEMENT;
  
ALTER CLUSTER EMP_DEPT DEALLOCATE UNUSED KEEP 30 K;

ALTER CLUSTER EMP_DEPT SIZE 1024;

ALTER CLUSTER EMP_DEPT SIZE 1024;

ALTER DATABASE  
    CLEAR LOGFILE 'diskc:log3.log';
	
ALTER DATABASE 
    RECOVER LOGFILE 'diskc:log3.log'; 
	
ALTER DATABASE 
    RECOVER AUTOMATIC UNTIL TIME '2001-10-27:14:00:00'; 

ALTER DATABASE
   RECOVER TABLESPACE tbs_03
   PARALLEL;

ALTER DATABASE
  ADD LOGFILE GROUP 3 
    ('diska:log3.log' ,  
     'diskb:log3.log') SIZE 50K;
	 
ALTER DATABASE   
    RENAME FILE 'diskc:log3.log' TO 'diskb:log3.log'; 
	
ALTER DATABASE 
   DEFAULT TEMPORARY TABLESPACE tbs_05;

ALTER DATABASE 
    CREATE DATAFILE 'tbs_f03.dbf' 
                 AS 'tbs_f04.dbf'; 
				 
ALTER DATABASE
  ENABLE BLOCK CHANGE TRACKING
    USING FILE 'tracking_file' REUSE;

ALTER DATABASE DICTIONARY 
ENCRYPT CREDENTIALS;

ALTER DATABASE DICTIONARY 
DELETE CREDENTIALS KEY;

ALTER DIMENSION customers_dim
   DROP ATTRIBUTE country;

ALTER DIMENSION customers_dim
   ADD LEVEL zone IS customers.cust_postal_code
   ADD ATTRIBUTE zone DETERMINES (cust_city);
   
   
ALTER DISKGROUP dgroup_01
  CHECK ALL
  REPAIR;
  
ALTER DISKGROUP dgroup_01
  REBALANCE POWER 11 WAIT;

ALTER DISKGROUP dgroup_01
  ADD TEMPLATE template_01
    ATTRIBUTES (UNPROTECTED COARSE);

ALTER DISKGROUP dgroup_01
  MODIFY TEMPLATE template_01
    ATTRIBUTES (FINE);

ALTER DISKGROUP dgroup_01
  ADD ALIAS '+dgroup_01/alias_dir/datafile.dbf'
    FOR '+dgroup_01.261.1';

ALTER DISKGROUP dgroup_01
  DISMOUNT FORCE;
  
ALTER FLASHBACK ARCHIVE my_flashback_archive
MODIFY TABLESPACE my_tablespace QUOTA 20G;

ALTER FLASHBACK ARCHIVE my_flashback_archive
ADD TABLESPACE my_tablespace QUOTA 10G;

ALTER FLASHBACK ARCHIVE my_flashback_archive
SET DEFAULT;


ALTER FUNCTION oe.get_bal COMPILE;


ALTER HIERARCHY product_hier RENAME TO myproduct_hier;

ALTER INDEX cost_ix 
   REBUILD PARTITION p2;
   
ALTER INDEX cost_ix
   REBUILD PARTITION p3 NOLOGGING;


ALTER INDEX cost_ix UNUSABLE;


ALTER INDEX cost_ix MODIFY PARTITION p3
   STORAGE(MAXEXTENTS 30) LOGGING;


ALTER INDEX cost_ix
   SPLIT PARTITION p2 AT (1500) 
   INTO ( PARTITION p2a TABLESPACE tbs_01 LOGGING,
          PARTITION p2b TABLESPACE tbs_02);

ALTER INDEX prod_idx
      MODIFY DEFAULT ATTRIBUTES INITRANS 5;
	  
	  ALTER INDEX cost_ix
   DROP PARTITION p1;
   
ALTER INDEXTYPE position_indextype COMPILE;

ALTER INMEMORY JOIN GROUP prod_id1
  ADD(product_descriptions(product_id));
  
  ALTER INMEMORY JOIN GROUP prod_id1
  REMOVE(product_descriptions(product_id));


ALTER JAVA CLASS "Agent"
   RESOLVER (("/usr/bin/bfile_dir/*" pm)(* public))
   RESOLVE;
   
ALTER LIBRARY hr.my_ext_lib COMPILE;

ALTER LOCKDOWN PROFILE hr_prof
  ENABLE FEATURE = ('UTL_HTTP', 'UTL_SMTP', 'OS_ACCESS');
  
  ALTER LOCKDOWN PROFILE hr_prof
  ENABLE FEATURE ALL EXCEPT = ('AQ_PROTOCOLS', 'CTX_PROTOCOLS');
  
  
ALTER MATERIALIZED VIEW emp_data
   REFRESH COMPLETE   
   START WITH TRUNC(SYSDATE+1) + 9/24  
   NEXT SYSDATE+7;
   
ALTER MATERIALIZED VIEW order_data 
   REFRESH WITH PRIMARY KEY; 
   
ALTER MATERIALIZED VIEW order_data COMPILE;

ALTER MATERIALIZED VIEW sales_by_month_by_state
   REFRESH FAST; 


ALTER MATERIALIZED VIEW LOG ON order_items ADD ROWID;

ALTER MATERIALIZED VIEW LOG ON employees
   ADD (commission_pct)
   EXCLUDING NEW VALUES;
   
ALTER MATERIALIZED ZONEMAP sales_zmap
  REFRESH FAST ON COMMIT;
  
ALTER MATERIALIZED ZONEMAP sales_zmap
  PCTFREE 20 PCTUSED 50 NOCACHE;
  
ALTER MATERIALIZED ZONEMAP sales_zmap
  COMPILE;
  
ALTER OPERATOR eq_op COMPILE;

ALTER OUTLINE salaries REBUILD;

ALTER PLUGGABLE DATABASE APPLICATION hrapp payrollapp employeesapp SYNC

ALTER PLUGGABLE DATABASE APPLICATION ALL EXCEPT hrapp payrollapp SYNC 

ALTER PLUGGABLE DATABASE PREPARE MIRROR COPY mirror_name WITH HIGH REDUNDANCY 

 ALTER PLUGGABLE DATABASE 
   DISABLE LOST WRITE PROTECTION

ALTER PLUGGABLE DATABASE pdb1
  UNPLUG INTO '/oracle/data/pdb1.xml';  
  
ALTER PLUGGABLE DATABASE pdb5
  OPEN READ WRITE INSTANCES = ('ORCLDB_1', 'ORCLDB_2');


ALTER PLUGGABLE DATABASE ALL
  OPEN READ ONLY;


ALTER PMEM FILESTORE cloud_db_1 RESIZE 5T

ALTER  PMEM FILESTORE cloud_db_1 MOUNT  MOUNTPOINT '/corp/db/cloud_db_1'
    BACKINGFILE '/var/pmem/foo_1'

ALTER PMEM FILESTORE cloud_db_1 DISMOUNT

ALTER PROCEDURE hr.remove_emp COMPILE;

ALTER PROFILE new_profile 
   LIMIT PASSWORD_REUSE_TIME 90 
   PASSWORD_REUSE_MAX UNLIMITED;
   
ALTER PROFILE app_user 
   LIMIT PASSWORD_REUSE_TIME DEFAULT
   PASSWORD_REUSE_MAX UNLIMITED;

ALTER PROFILE app_user2 LIMIT
   PASSWORD_LIFE_TIME 90
   PASSWORD_GRACE_TIME 5;
   
   
ALTER PROFILE app_user LIMIT IDLE_TIME DEFAULT;


ALTER RESOURCE COST 
   CPU_PER_SESSION 100
   CONNECT_TIME      1; 


ALTER RESOURCE COST 
   LOGICAL_READS_PER_SESSION 2
   CONNECT_TIME 0; 

ALTER ROLE warehouse_user NOT IDENTIFIED;

ALTER ROLE dw_manager 
   IDENTIFIED BY data;
   
ALTER ROLE dw_manager IDENTIFIED USING hr.admin;

ALTER ROLLBACK SEGMENT rbs_one ONLINE; 


ALTER ROLLBACK SEGMENT rbs_one 
   SHRINK TO 100M;
   
ALTER SEQUENCE customers_seq 
   MAXVALUE 1500;
   

ALTER SEQUENCE customers_seq 
   CYCLE
   CACHE 5; 
   
ALTER SESSION
   SET NLS_CURRENCY = 'DM';    
   
ALTER SESSION
   SET NLS_LANGUAGE = FRENCH;    
   
ALTER SESSION
  SET QUERY_REWRITE_ENABLED = TRUE;  
   
   
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ',.' ;   
   
ALTER PUBLIC SYNONYM emp_table COMPILE;
ALTER SYNONYM offices NONEDITIONABLE;   
ALTER SYNONYM offices COMPILE;


ALTER SYSTEM ARCHIVE LOG CHANGE 9356083; 

ALTER SYSTEM ARCHIVE LOG 
    LOGFILE 'diskl:log6.log' 
    TO 'diska:[arch$]';   
   
 ALTER SYSTEM 
   SET DISPATCHERS = 
      '(INDEX=0)(PROTOCOL=TCP)(DISPATCHERS=5)',
      '(INDEX=1)(PROTOCOL=ipc)(DISPATCHERS=10)'; 
  
ALTER SYSTEM DISABLE DISTRIBUTED RECOVERY; 
  
   
ALTER TABLE t1 MODIFY OPAQUE TYPE x STORE (XMLType, clob_typ) UNPACKED;

ALTER TABLE staff 
   ADD (REF(dept) WITH ROWID);
   
ALTER TABLE staff 
    ADD (SCOPE FOR (dept) IS offices); 
	
ALTER TABLE employees ADD (skills skill_table_type)
    NESTED TABLE skills STORE AS nested_skill_table;
	
ALTER TABLE xwarehouses 
   ADD (PRIMARY KEY(XMLDATA."WarehouseID"));

ALTER TABLESPACE tbs_03 
    ADD DATAFILE 'tbs_f04.dbf'
    SIZE 100K
    AUTOEXTEND ON
    NEXT 10K
    MAXSIZE 100K;

   
 ALTER TABLESPACE tbsu1 REMOVE LOST WRITE PROTECTION
   
   
ALTER TABLESPACE tbs_02
  RENAME DATAFILE 'diskb:tbs_f5.dbf'
  TO              'diska:tbs_f5.dbf'; 
  
   
ALTER TABLESPACE SET ts1
  FORCE LOGGING;

ALTER TRIGGER update_job_history DISABLE;
   
   
ALTER TRIGGER update_job_history ENABLE; 

ALTER TYPE data_typ1 
   ADD MEMBER FUNCTION qtr(der_qtr DATE) 
   RETURN CHAR CASCADE;   
   
ALTER TYPE phone_list_typ_demo
  MODIFY LIMIT 10 CASCADE;   
   
ALTER TYPE phone_list_typ
  MODIFY ELEMENT TYPE VARCHAR(64) CASCADE;   
  
ALTER USER sidney 
    IDENTIFIED BY second_2nd_pwd
    DEFAULT TABLESPACE example; 
	
ALTER USER sh 
    DEFAULT ROLE ALL EXCEPT dw_manager; 
	
ALTER USER app_user1 IDENTIFIED GLOBALLY AS 'CN=tom,O=oracle,C=US';

ALTER VIEW customer_ro
    COMPILE; 

ANALYZE TABLE orders DELETE STATISTICS; 

ANALYZE TABLE customers VALIDATE REF UPDATE;

ANALYZE CLUSTER personnel
    VALIDATE STRUCTURE CASCADE; 

ANALYZE TABLE orders
   LIST CHAINED ROWS INTO chained_rows; 

ASSOCIATE STATISTICS WITH PACKAGES emp_mgmt DEFAULT SELECTIVITY 10;

ASSOCIATE STATISTICS WITH INDEXES salary_index DEFAULT COST (100,5,0);

CALL warehouse_typ(456, 'Warehouse 456', 2236).ret_name()
   INTO :x;
   
CALL ret_warehouse_typ(warehouse_typ(234, 'Warehouse 234',
   2235)).ret_name()
   INTO :x
   
COMMENT ON COLUMN employees.job_id 
   IS 'abbreviated job title';

COMMENT ON COLUMN employees.job_id IS ''; 


COMMIT 
    COMMENT 'In-doubt transaction Code 36, Call (415) 555-2637'; 

COMMIT FORCE '22.57.53'; 

COMMIT WORK;

CREATE OR REPLACE ANALYTIC VIEW sales_av
USING sales_fact
DIMENSION BY
  (time_attr_dim                         -- An attribute dimension of time data
    KEY month_id REFERENCES month_id
    HIERARCHIES (
      time_hier DEFAULT),
   product_attr_dim                      -- An attribute dimension of product data
    KEY category_id REFERENCES category_id
    HIERARCHIES (
      product_hier DEFAULT),
   geography_attr_dim                    -- An attribute dimension of store data
    KEY state_province_id 
    REFERENCES state_province_id HIERARCHIES (
      geography_hier DEFAULT)
   )
MEASURES
 (sales FACT sales,                      -- A base measure
  units FACT units,                      -- A base measure
  sales_prior_period AS                  -- Calculated measures
    (LAG(sales) OVER (HIERARCHY time_hier OFFSET 1)),
  sales_year_ago AS
    (LAG(sales) OVER (HIERARCHY time_hier OFFSET 1
     ACROSS ANCESTOR AT LEVEL year)),
  chg_sales_year_ago AS
    (LAG_DIFF(sales) OVER (HIERARCHY time_hier OFFSET 1
     ACROSS ANCESTOR AT LEVEL year)),
  pct_chg_sales_year_ago AS
    (LAG_DIFF_PERCENT(sales) OVER (HIERARCHY time_hier OFFSET 1
     ACROSS ANCESTOR AT LEVEL year)),
  sales_qtr_ago AS
    (LAG(sales) OVER (HIERARCHY time_hier OFFSET 1
     ACROSS ANCESTOR AT LEVEL quarter)),
  chg_sales_qtr_ago AS
    (LAG_DIFF(sales) OVER (HIERARCHY time_hier OFFSET 1
     ACROSS ANCESTOR AT LEVEL quarter)),
  pct_chg_sales_qtr_ago AS
    (LAG_DIFF_PERCENT(sales) OVER (HIERARCHY time_hier OFFSET 1
     ACROSS ANCESTOR AT LEVEL quarter))
  )
DEFAULT MEASURE SALES;


CREATE OR REPLACE ATTRIBUTE DIMENSION time_attr_dim
DIMENSION TYPE TIME
USING time_dim
ATTRIBUTES
 (year_id
   CLASSIFICATION caption VALUE 'YEAR_ID'
   CLASSIFICATION description VALUE 'YEAR ID',
  year_name
    CLASSIFICATION caption VALUE 'YEAR_NAME'
    CLASSIFICATION description VALUE 'Year',
  year_end_date
    CLASSIFICATION caption VALUE 'YEAR_END_DATE'
    CLASSIFICATION description VALUE 'Year End Date',
  quarter_id
    CLASSIFICATION caption VALUE 'QUARTER_ID'
    CLASSIFICATION description VALUE 'QUARTER ID',
  quarter_name
    CLASSIFICATION caption VALUE 'QUARTER_NAME'
    CLASSIFICATION description VALUE 'Quarter',
  quarter_end_date
    CLASSIFICATION caption VALUE 'QUARTER_END_DATE'
    CLASSIFICATION description VALUE 'Quarter End Date',
  quarter_of_year
    CLASSIFICATION caption VALUE 'QUARTER_OF_YEAR'
    CLASSIFICATION description VALUE 'Quarter of Year',    
  month_id
    CLASSIFICATION caption VALUE 'MONTH_ID'
    CLASSIFICATION description VALUE 'MONTH ID',
  month_name
    CLASSIFICATION caption VALUE 'MONTH_NAME'
    CLASSIFICATION description VALUE 'Month',
  month_long_name
    CLASSIFICATION caption VALUE 'MONTH_LONG_NAME'
    CLASSIFICATION description VALUE 'Month Long Name',
  month_end_date
    CLASSIFICATION caption VALUE 'MONTH_END_DATE'
    CLASSIFICATION description VALUE 'Month End Date',
  month_of_quarter
    CLASSIFICATION caption VALUE 'MONTH_OF_QUARTER'
    CLASSIFICATION description VALUE 'Month of Quarter',
  month_of_year
    CLASSIFICATION caption VALUE 'MONTH_OF_YEAR'
    CLASSIFICATION description VALUE 'Month of Year',
  season
    CLASSIFICATION caption VALUE 'SEASON'
    CLASSIFICATION description VALUE 'Season',
  season_order
    CLASSIFICATION caption VALUE 'SEASON_ORDER'
    CLASSIFICATION description VALUE 'Season Order')
LEVEL month
  LEVEL TYPE MONTHS
  CLASSIFICATION caption VALUE 'MONTH'
  CLASSIFICATION description VALUE 'Month'
  KEY month_id
  MEMBER NAME month_name
  MEMBER CAPTION month_name
  MEMBER DESCRIPTION month_long_name
  ORDER BY month_end_date
  DETERMINES (month_end_date,
    quarter_id,
    season,
    season_order,
    month_of_year,
    month_of_quarter)
LEVEL quarter
  LEVEL TYPE QUARTERS
  CLASSIFICATION caption VALUE 'QUARTER'
  CLASSIFICATION description VALUE 'Quarter'
  KEY quarter_id
  MEMBER NAME quarter_name
  MEMBER CAPTION quarter_name
  MEMBER DESCRIPTION quarter_name
  ORDER BY quarter_end_date
  DETERMINES (quarter_end_date,
    quarter_of_year,
    year_id)
LEVEL year
  LEVEL TYPE YEARS
  CLASSIFICATION caption VALUE 'YEAR'
  CLASSIFICATION description VALUE 'Year'
  KEY year_id
  MEMBER NAME year_name
  MEMBER CAPTION year_name
  MEMBER DESCRIPTION year_name
  ORDER BY year_end_date
  DETERMINES (year_end_date)
LEVEL season
  LEVEL TYPE QUARTERS
  CLASSIFICATION caption VALUE 'SEASON'
  CLASSIFICATION description VALUE 'Season'
  KEY season
  MEMBER NAME season
  MEMBER CAPTION season
  MEMBER DESCRIPTION season
LEVEL month_of_quarter
  LEVEL TYPE MONTHS
  CLASSIFICATION caption VALUE 'MONTH_OF_QUARTER'
  CLASSIFICATION description VALUE 'Month of Quarter'
  KEY month_of_quarter;
  
  
  CREATE AUDIT POLICY table_pol
  PRIVILEGES CREATE ANY TABLE, DROP ANY TABLE;
  
CREATE AUDIT POLICY dml_pol
  ACTIONS DELETE on hr.employees,
          INSERT on hr.employees,
          UPDATE on hr.employees,
          ALL on hr.departments;
		  
CREATE AUDIT POLICY security_pol
  ACTIONS ADMINISTER KEY MANAGEMENT;
  
CREATE AUDIT POLICY dp_actions_pol
  ACTIONS COMPONENT = datapump IMPORT;
  
CREATE AUDIT POLICY order_updates_pol
  ACTIONS UPDATE ON oe.orders
  WHEN 'SYS_CONTEXT(USERENV, IDENTIFICATION_TYPE) = EXTERNAL'
  EVALUATE PER SESSION;
  
CREATE CLUSTER emp_dept (deptno NUMBER(3))  
   SIZE 600  
   TABLESPACE USERS 
   STORAGE (INITIAL 200K  
      NEXT 300K  
      MINEXTENTS 2  
      PCTINCREASE 33);
	  
CREATE CLUSTER sales (amount_sold NUMBER, prod_id NUMBER)
  HASHKEYS 100000
  HASH IS (amount_sold * 10 + prod_id)
  SIZE 300
  TABLESPACE example
  PARTITION BY RANGE (amount_sold)
    (PARTITION p1 VALUES LESS THAN (2001),
     PARTITION p2 VALUES LESS THAN (4001),
     PARTITION p3 VALUES LESS THAN (6001),
     PARTITION p4 VALUES LESS THAN (8001),
     PARTITION p5 VALUES LESS THAN (MAXVALUE));
	 
CREATE CONTEXT hr_context USING emp_mgmt;


CREATE CONTROLFILE REUSE DATABASE "demo" NORESETLOGS NOARCHIVELOG
    MAXLOGFILES 32
    MAXLOGMEMBERS 2
    MAXDATAFILES 32
    MAXINSTANCES 1
    MAXLOGHISTORY 449
LOGFILE
  GROUP 1 '/path/oracle/dbs/t_log1.f'  SIZE 500K,
  GROUP 2 '/path/oracle/dbs/t_log2.f'  SIZE 500K

DATAFILE
  '/path/oracle/dbs/t_db1.f',
  '/path/oracle/dbs/dbu19i.dbf',
  '/path/oracle/dbs/tbs_11.f',
  '/path/oracle/dbs/smundo.dbf',
  '/path/oracle/dbs/demo.dbf'
CHARACTER SET WE8DEC
;


CREATE DATABASE newcdb
  USER SYS IDENTIFIED BY sys_password
  USER SYSTEM IDENTIFIED BY system_password
  LOGFILE GROUP 1 ('/u01/logs/my/redo01a.log','/u02/logs/my/redo01b.log')
             SIZE 100M BLOCKSIZE 512,
          GROUP 2 ('/u01/logs/my/redo02a.log','/u02/logs/my/redo02b.log')
             SIZE 100M BLOCKSIZE 512,
          GROUP 3 ('/u01/logs/my/redo03a.log','/u02/logs/my/redo03b.log')
             SIZE 100M BLOCKSIZE 512
  MAXLOGHISTORY 1
  MAXLOGFILES 16
  MAXLOGMEMBERS 3
  MAXDATAFILES 1024
  CHARACTER SET AL32UTF8
  NATIONAL CHARACTER SET AL16UTF16
  EXTENT MANAGEMENT LOCAL
  DATAFILE '/u01/app/oracle/oradata/newcdb/system01.dbf'
    SIZE 700M REUSE AUTOEXTEND ON NEXT 10240K MAXSIZE UNLIMITED
  SYSAUX DATAFILE '/u01/app/oracle/oradata/newcdb/sysaux01.dbf'
    SIZE 550M REUSE AUTOEXTEND ON NEXT 10240K MAXSIZE UNLIMITED
  DEFAULT TABLESPACE deftbs
    DATAFILE '/u01/app/oracle/oradata/newcdb/deftbs01.dbf'
    SIZE 500M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
  DEFAULT TEMPORARY TABLESPACE tempts1
    TEMPFILE '/u01/app/oracle/oradata/newcdb/temp01.dbf'
    SIZE 20M REUSE AUTOEXTEND ON NEXT 640K MAXSIZE UNLIMITED
  UNDO TABLESPACE undotbs1
    DATAFILE '/u01/app/oracle/oradata/newcdb/undotbs01.dbf'
    SIZE 200M REUSE AUTOEXTEND ON NEXT 5120K MAXSIZE UNLIMITED
  ENABLE PLUGGABLE DATABASE
    SEED
    FILE_NAME_CONVERT = ('/u01/app/oracle/oradata/newcdb/',
                         '/u01/app/oracle/oradata/pdbseed/')
    SYSTEM DATAFILES SIZE 125M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
    SYSAUX DATAFILES SIZE 100M
  USER_DATA TABLESPACE usertbs
    DATAFILE '/u01/app/oracle/oradata/pdbseed/usertbs01.dbf'
    SIZE 200M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
	
CREATE DATABASE LINK remote.us.example.com
   CONNECT TO CURRENT_USER
   USING 'remote';


CREATE DATABASE LINK local 
   CONNECT TO hr IDENTIFIED BY password
   USING 'local';

CREATE DIMENSION customers_dim 
   LEVEL customer   IS (customers.cust_id)
   LEVEL city       IS (customers.cust_city) 
   LEVEL state      IS (customers.cust_state_province) 
   LEVEL country    IS (countries.country_id) 
   LEVEL subregion  IS (countries.country_subregion) 
   LEVEL region     IS (countries.country_region) 
   HIERARCHY geog_rollup (
      customer      CHILD OF
      city          CHILD OF 
      state         CHILD OF 
      country       CHILD OF 
      subregion     CHILD OF 
      region 
   JOIN KEY (customers.country_id) REFERENCES country
   )
   ATTRIBUTE customer DETERMINES
   (cust_first_name, cust_last_name, cust_gender, 
    cust_marital_status, cust_year_of_birth, 
    cust_income_level, cust_credit_limit) 
   ATTRIBUTE country DETERMINES (countries.country_name)
;

CREATE DIMENSION customers_dim
   LEVEL customer IS (customers.cust_id)
   LEVEL status IS (customers.cust_marital_status) SKIP WHEN NULL
   LEVEL city IS (customers.cust_city)
   LEVEL state IS (customers.cust_state_province)
   LEVEL country IS (countries.country_id)
   LEVEL subregion IS (countries.country_subregion) SKIP WHEN NULL
   LEVEL region IS (countries.country_region)
   HIERARCHY geog_rollup (
      customer CHILD OF
      city CHILD OF
      state CHILD OF
      country CHILD OF
      subregion CHILD OF
      region
   JOIN KEY (customers.country_id) REFERENCES country
   )
   ATTRIBUTE customer DETERMINES
   (cust_first_name, cust_last_name, cust_gender,
    cust_marital_status, cust_year_of_birth,
    cust_income_level, cust_credit_limit)
   ATTRIBUTE country DETERMINES (countries.country_name)
;


CREATE DIRECTORY mydir AS '/scratch/data/file_data';


CREATE OR REPLACE DIRECTORY bfile_dir AS '/usr/bin/bfile_dir';

CREATE DISKGROUP dgroup_01
  EXTERNAL REDUNDANCY
  DISK '/devices/disks/c*';
  
CREATE EDITION test_ed;

CREATE FLASHBACK ARCHIVE DEFAULT test_archive1
   TABLESPACE example
   QUOTA 1 M
   RETENTION 1 DAY;

CREATE FLASHBACK ARCHIVE test_archive2
   TABLESPACE example
   QUOTA 1 M
   RETENTION 1 DAY;

CREATE OR REPLACE HIERARCHY geography_hier
USING geography_attr_dim
 (state_province
  CHILD OF country
  CHILD OF region);
  
CREATE OR REPLACE HIERARCHY product_hier
USING product_attr_dim
 (category
  CHILD OF department);

CREATE INDEXTYPE position_indextype
   FOR position_between(NUMBER, NUMBER, NUMBER)
   USING position_im;  
   
CREATE INMEMORY JOIN GROUP prod_id1
  (inventories(product_id), order_items(product_id));   


CREATE JAVA RESOURCE NAMED "appText" 
   USING BFILE (java_dir, 'textBundle.dat')   
   
   
CREATE LIBRARY app_lib as '${ORACLE_HOME}/lib/app_lib.so'
   AGENT 'sales.hq.example.com';

CREATE OR REPLACE LIBRARY ext_lib AS 'ddl_1' IN ddl_dir CREDENTIAL ddl_cred;


CREATE LOCKDOWN PROFILE hr_prof INCLUDING PRIVATE_DBAAS;



CREATE MATERIALIZED ZONEMAP sales_zmap
  ON sales(cust_id, prod_id);
  
CREATE MATERIALIZED ZONEMAP sales_zmap
  AS SELECT SYS_OP_ZONE_ID(s.rowid),
            MIN(prod_category), MAX(prod_category),
            MIN(prod_subcategory), MAX(prod_subcategory),
            MIN(country_id), MAX(country_id),
            MIN(cust_state_province), MAX(cust_state_province),
            MIN(cust_city), MAX(cust_city)
    FROM sales s
       LEFT OUTER JOIN products p ON s.prod_id = p.prod_id
       LEFT OUTER JOIN customers c ON s.cust_id = c.cust_id
    GROUP BY sys_op_zone_id(s.rowid);


CREATE MATERIALIZED ZONEMAP sales_zmap
  AS SELECT SYS_OP_ZONE_ID(s.rowid),
            MIN(prod_category), MAX(prod_category),
            MIN(prod_subcategory), MAX(prod_subcategory),
            MIN(country_id), MAX(country_id),
            MIN(cust_state_province), MAX(cust_state_province),
            MIN(cust_city), MAX(cust_city)
     FROM sales s, products p, customers c
     WHERE s.prod_id = p.prod_id(+) AND
           s.cust_id = c.cust_id(+)
     GROUP BY sys_op_zone_id(s.rowid);
	 
CREATE OPERATOR eq_op
   BINDING (VARCHAR2, VARCHAR2) 
   RETURN NUMBER 
   USING eq_f; 
   
CREATE OR REPLACE OUTLINE public_salaries 
   FROM PRIVATE my_salaries;
   
CREATE OUTLINE salaries FOR CATEGORY special
   ON SELECT last_name, salary FROM employees;

CREATE PFILE = 'my_init.ora' FROM SPFILE = 's_params.ora';



CREATE PLUGGABLE DATABASE salespdb
  ADMIN USER salesadm IDENTIFIED BY password
  ROLES = (dba)
  DEFAULT TABLESPACE sales
    DATAFILE '/disk1/oracle/dbs/salespdb/sales01.dbf' SIZE 250M AUTOEXTEND ON
  FILE_NAME_CONVERT = ('/disk1/oracle/dbs/pdbseed/ ',
                       '/disk1/oracle/dbs/salespdb/ ')
  STORAGE (MAXSIZE 2G)
  PATH_PREFIX = '/disk1/oracle/dbs/salespdb/ ';
  
  
CREATE PLUGGABLE DATABASE salespdb
  USING '/disk1/usr/salespdb.xml'
  SOURCE_FILE_NAME_CONVERT =
    ('/disk1/oracle/dbs/salespdb/ ', '/disk2/oracle/dbs/salespdb/ ')
  NOCOPY
  STORAGE (MAXSIZE 2G)
  TEMPFILE REUSE;
  
CREATE PMEM FILESTORE cloud_db_1 MOUNTPOINT '/corp/db/cloud_db_1' 
    BACKINGFILE '/var/pmem/foo_1.' SIZE 2T BLOCKSIZE 8K 
    AUTOEXTEND ON NEXT 10G MAXSIZE 3T 
	
CREATE PROFILE app_user2 LIMIT
   FAILED_LOGIN_ATTEMPTS 5
   PASSWORD_LIFE_TIME 60
   PASSWORD_REUSE_TIME 60
   PASSWORD_REUSE_MAX 5
   PASSWORD_VERIFY_FUNCTION ora12c_verify_function
   PASSWORD_LOCK_TIME 1/24
   PASSWORD_GRACE_TIME 10
   INACTIVE_ACCOUNT_TIME 30;


CREATE PROFILE app_user LIMIT 
   SESSIONS_PER_USER          UNLIMITED 
   CPU_PER_SESSION            UNLIMITED 
   CPU_PER_CALL               3000 
   CONNECT_TIME               45 
   LOGICAL_READS_PER_SESSION  DEFAULT 
   LOGICAL_READS_PER_CALL     1000 
   PRIVATE_SGA                15K
   COMPOSITE_LIMIT            5000000; 


CREATE RESTORE POINT good_data;


CREATE ROLE dw_manager
   IDENTIFIED BY warehouse; 


CREATE ROLE warehouse_user IDENTIFIED EXTERNALLY;


CREATE ROLE crole1 CONTAINER = ALL;


CREATE SCHEMA AUTHORIZATION oe
   CREATE TABLE new_product 
      (color VARCHAR2(10)  PRIMARY KEY, quantity NUMBER) 
   CREATE VIEW new_product_view 
      AS SELECT color, quantity FROM new_product WHERE color = 'RED'
	  
CREATE ROLLBACK SEGMENT rbs_one
   TABLESPACE rbs_ts
   STORAGE
   ( INITIAL 10K );
   
 CREATE SPFILE = 's_params.ora' 
   FROM PFILE = '$ORACLE_HOME/work/t_init1.ora';
   
CREATE PUBLIC SYNONYM emp_table 
   FOR hr.employees@remote.us.example.com;

CREATE TABLESPACE lmt1 DATAFILE 'lmt_file2.dbf' SIZE 100m REUSE
  EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;
  
CREATE TABLESPACE lmt2 DATAFILE 'lmt_file3.dbf' SIZE 100m REUSE 
  EXTENT MANAGEMENT LOCAL;
  
  
CREATE TABLESPACE auto_seg_ts DATAFILE 'file_2.dbf' SIZE 1M
   EXTENT MANAGEMENT LOCAL
   SEGMENT SPACE MANAGEMENT AUTO;
   
CREATE TABLESPACE SET ts1
  IN SHARDSPACE sgr1 
  USING TEMPLATE
  ( DATAFILE SIZE 100m
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO
  );
  
CREATE TYPE customer_typ_demo AS OBJECT
    ( customer_id        NUMBER(6)
    , cust_first_name    VARCHAR2(20)
    , cust_last_name     VARCHAR2(20)
    , cust_address       CUST_ADDRESS_TYP
    , phone_numbers      PHONE_LIST_TYP
    , nls_language       VARCHAR2(3)
    , nls_territory      VARCHAR2(30)
    , credit_limit       NUMBER(9,2)
    , cust_email         VARCHAR2(30)
    , cust_orders        ORDER_LIST_TYP
    ) ;


CREATE TYPE data_typ1 AS OBJECT 
   ( year NUMBER, 
     MEMBER FUNCTION prod(invent NUMBER) RETURN NUMBER 
   ); 

CREATE USER sidney 
    IDENTIFIED BY out_standing1 
    DEFAULT TABLESPACE example 
    QUOTA 10M ON example 
    TEMPORARY TABLESPACE temp
    QUOTA 5M ON system 
    PROFILE app_user 
    PASSWORD EXPIRE;


CREATE USER global_user
   IDENTIFIED GLOBALLY AS 'CN=analyst, OU=division1, O=oracle, C=US'
   DEFAULT TABLESPACE example
   QUOTA 5M ON example;
   
DISASSOCIATE STATISTICS FROM PACKAGES hr.emp_mgmt;

DROP ANALYTIC VIEW sales_av;

DROP ATTRIBUTE DIMENSION product_attr_dim;

DROP AUDIT POLICY table_pol;

DROP CLUSTER personnel
   INCLUDING TABLES
   CASCADE CONSTRAINTS;
   
DROP CONTEXT hr_context;

DROP DATABASE ;

DROP PUBLIC DATABASE LINK remote;

DROP DIRECTORY bfile_dir;

DROP DIMENSION customers_dim;

DROP DISKGROUP dgroup_01 INCLUDING CONTENTS;

DROP EDITION TEST_ED;

DROP FLASHBACK ARCHIVE test_archive2;

DROP FUNCTION oe.SecondMax; 

DROP HIERARCHY product_hier;

DROP INDEX ord_customer_ix_demo;

DROP INDEXTYPE position_indextype FORCE;

DROP INMEMORY JOIN GROUP prod_id1;

DROP JAVA CLASS "Agent";

DROP LIBRARY ext_lib;

DROP LOCKDOWN PROFILE hr_prof;

DROP MATERIALIZED VIEW sales_by_month_by_state;

DROP MATERIALIZED VIEW LOG ON customers; 

DROP OUTLINE salaries;

DROP OPERATOR eq_op;

DROP PACKAGE emp_mgmt; 

DROP PLUGGABLE DATABASE pdb1
  INCLUDING DATAFILES;
  
DROP PROFILE app_user CASCADE; 
  
DROP PROCEDURE hr.remove_emp; 

DROP PMEM FILESTORE cloud_db_1 EXCLUDING CONTENTS

DROP RESTORE POINT good_data;

DROP ROLE dw_manager; 

DROP ROLLBACK SEGMENT rbs_one; 

DROP PUBLIC SYNONYM customers; 

DROP TABLE list_customers PURGE; 

DROP TABLESPACE tbs_01   INCLUDING CONTENTS  CASCADE CONSTRAINTS; 

DROP TABLESPACE tbs_02   INCLUDING CONTENTS AND DATAFILES;

DROP TABLESPACE SET ts1;

DROP TYPE person_t FORCE;

DROP VIEW emp_view; 

EXPLAIN PLAN FOR
  SELECT * FROM sales 
     WHERE time_id BETWEEN h AND '01-OCT-2000';
	 
FLASHBACK TABLE print_media TO BEFORE DROP RENAME TO print_media_old;

FLASHBACK TABLE print_media TO BEFORE DROP;

GRANT REFERENCES (employee_id), 
      UPDATE (employee_id, salary, commission_pct) 
   ON hr.employees
   TO oe; 
   
GRANT SELECT, UPDATE 
   ON emp_view TO PUBLIC; 

GRANT SELECT 
   ON oe.customers_seq TO hr; 


INSERT INTO employees (employee_id, last_name, email, 
      hire_date, job_id, salary, commission_pct) 
   VALUES (207, 'Gregory', 'pgregory@example.com', 
      sysdate, 'PU_CLERK', 1.2E3, NULL);


INSERT INTO bonuses
   SELECT employee_id, salary*1.1 
   FROM employees
   WHERE commission_pct > 0.25; 
   
   
   INSERT INTO raises
   SELECT employee_id, salary*1.1 FROM employees
   WHERE commission_pct > 2
   LOG ERRORS INTO errlog ('my_bad') REJECT LIMIT 10;
   
LOCK TABLE employees@remote 
   IN SHARE MODE;   
   
LOCK TABLE employees
   IN EXCLUSIVE MODE 
   NOWAIT; 


MERGE INTO people_target pt 
USING people_source ps 
ON    (pt.person_id = ps.person_id) 
WHEN MATCHED THEN UPDATE 
  SET pt.first_name = ps.first_name, 
      pt.last_name = ps.last_name, 
      pt.title = ps.title;   
   
 MERGE INTO people_target pt 
USING people_source ps 
ON    (pt.person_id = ps.person_id) 
WHEN MATCHED THEN UPDATE 
  SET pt.first_name = ps.first_name, 
      pt.last_name = ps.last_name, 
      pt.title = ps.title 
WHEN NOT MATCHED THEN INSERT 
  (pt.person_id, pt.first_name, pt.last_name, pt.title) 
  VALUES (ps.person_id, ps.first_name, ps.last_name, ps.title);  
   
RENAME temporary TO job_history;   
   
PURGE RECYCLEBIN;

PURGE TABLE test;


REVOKE INHERIT PRIVILEGES ON USER sh FROM hr;

REVOKE UPDATE 
    ON emp_details_view FROM public;

REVOKE REFERENCES 
    ON hr.employees 
    FROM oe 
    CASCADE CONSTRAINTS; 
	
REVOKE READ ON DIRECTORY bfile_dir FROM hr;

ROLLBACK TO SAVEPOINT banda_sal; 

ROLLBACK WORK 
    FORCE '25.32.87'; 

SET ROLE dw_manager IDENTIFIED BY warehouse; 

SET ROLE ALL EXCEPT dw_manager;

SET TRANSACTION READ ONLY NAME 'Toronto'; 

TRUNCATE CLUSTER personnel REUSE STORAGE;

TRUNCATE TABLE sales_demo PRESERVE MATERIALIZED VIEW LOG; 

TRUNCATE TABLE orders_demo;


UPDATE employees a 
    SET department_id = 
        (SELECT department_id 
            FROM departments 
            WHERE location_id = '2100'), 
        (salary, commission_pct) = 
        (SELECT 1.1*AVG(salary), 1.5*AVG(commission_pct) 
          FROM employees b 
          WHERE a.department_id = b.department_id) 
    WHERE department_id IN 
        (SELECT department_id 
          FROM departments
          WHERE location_id = 2900 
              OR location_id = 2700); 


UPDATE sales PARTITION (sales_q1_1999) s
   SET s.promo_id = 494
   WHERE amount_sold > 1000;
   
   
FLASHBACK DATABASE   TO TIMESTAMP SYSDATE-1;


CREATE OR REPLACE PACKAGE BODY emp_mgmt AS 
   tot_emps NUMBER; 
   tot_depts NUMBER; 
FUNCTION hire 
   (last_name VARCHAR2, job_id VARCHAR2, 
    manager_id NUMBER, salary NUMBER, 
    commission_pct NUMBER, department_id NUMBER) 
   RETURN NUMBER IS new_empno NUMBER; 
BEGIN 
   SELECT employees_seq.NEXTVAL 
      INTO new_empno 
      FROM DUAL; 
   INSERT INTO employees 
      VALUES (new_empno, 'First', 'Last','first.example@example.com',
              '(415)555-0100',
              TO_DATE('18-JUN-2002','DD-MON-YYYY'),
              'IT_PROG',90000000,00, 100,110);
      tot_emps := tot_emps + 1; 
   RETURN(new_empno); 
END; 
FUNCTION create_dept(department_id NUMBER, location_id NUMBER) 
   RETURN NUMBER IS 
      new_deptno NUMBER; 
   BEGIN 
      SELECT departments_seq.NEXTVAL 
         INTO new_deptno 
         FROM dual; 
      INSERT INTO departments 
         VALUES (new_deptno, 'department name', 100, 1700); 
      tot_depts := tot_depts + 1; 
      RETURN(new_deptno); 
   END; 

PROCEDURE increase_sal(employee_id NUMBER, salary_incr NUMBER) IS 
   curr_sal NUMBER; 
   BEGIN 
      SELECT salary INTO curr_sal FROM employees 
      WHERE employees.employee_id = increase_sal.employee_id; 
      IF curr_sal IS NULL 
         THEN RAISE no_sal; 
      ELSE 
         UPDATE employees 
         SET salary = salary + salary_incr 
         WHERE employee_id = employee_id; 
      END IF; 
   END; 
PROCEDURE increase_comm(employee_id NUMBER, comm_incr NUMBER) IS 
   curr_comm NUMBER; 
   BEGIN 
      SELECT commission_pct 
      INTO curr_comm 
      FROM employees 
      WHERE employees.employee_id = increase_comm.employee_id; 
      IF curr_comm IS NULL 
         THEN RAISE no_comm; 
      ELSE 
         UPDATE employees 
         SET commission_pct = commission_pct + comm_incr; 
      END IF; 
   END; 
END emp_mgmt; 


CREATE OR REPLACE PACKAGE emp_mgmt AS 
   FUNCTION hire (last_name VARCHAR2, job_id VARCHAR2, 
      manager_id NUMBER, salary NUMBER, 
      commission_pct NUMBER, department_id NUMBER) 
      RETURN NUMBER; 
   FUNCTION create_dept(department_id NUMBER, location_id NUMBER) 
      RETURN NUMBER; 
   PROCEDURE remove_emp(employee_id NUMBER); 
   PROCEDURE remove_dept(department_id NUMBER); 
   PROCEDURE increase_sal(employee_id NUMBER, salary_incr NUMBER); 
   PROCEDURE increase_comm(employee_id NUMBER, comm_incr NUMBER); 
   no_comm EXCEPTION; 
   no_sal EXCEPTION; 
END emp_mgmt; 



CREATE TYPE BODY demo_typ2 IS
   MEMBER FUNCTION get_square
   RETURN NUMBER
   IS x NUMBER;
   BEGIN
      SELECT c.col.a1*c.col.a1 INTO x
      FROM demo_tab2 c;
      RETURN (x);
   END;
END;

DELETE product_price_history pp 
WHERE  (product_id, currency_code, effective_from_date) 
   IN (SELECT product_id, currency_code, Max(effective_from_date) 
       FROM   product_price_history 
       GROUP BY product_id, currency_code);
	   

  DELETE product_price_history 
  WHERE  product_id = 2 
  AND    effective_to_date IS NULL 
  returning  currency_code INTO currency; 
   
DELETE FROM (SELECT * FROM employees)
   WHERE job_id = 'SA_REP'
   AND commission_pct < 0.2;   
   
DELETE FROM product_descriptions
   WHERE language_id = 'AR';


CREATE TABLE employees (employee_id NUMBER );

CREATE TABLE orders (customer_id NUMBER );

CREATE TABLE customers (customer_id NUMBER primary key );



ALTER TABLE employees
ADD CONSTRAINT pk_employee_id PRIMARY KEY (employee_id);


ALTER TABLE orders
ADD CONSTRAINT fk_customer_id FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

CREATE TABLE  "COUNTRY_DIM"
(
	"Alpha_2_code" NUMBER(22,2) NULL,	-- Alphanumeric 2 chars code following specification in ISO-3166
	"Alpha_3_code" NUMBER(22,2) NULL,	-- Alphanumeric 3 chars code following specification in ISO-3166
	"Country_dim_id" VARCHAR(255) NOT NULL,	-- Deterministic surrogate key (hash of business key(s), e.g., COUNTRY_ID)
	"Country_dim_pk" NUMBER(22,2) NOT NULL,	-- COUNTRIES_DIM primary key
	"Federation_de" VARCHAR(255) NULL,	-- Assigned federation (currently only used for "European Union") in german
	"Federation_en" VARCHAR(255) NULL,	-- Assigned federation (currently only used for "European Union") in english
	"Hashdiff" VARCHAR(255) NOT NULL,	-- Hash of historized attributes to detect changes
	"Id" VARCHAR(255) NOT NULL,	-- ID of the country
	"Is_asean_flag" CHAR(1) NULL,	-- Flag indcating if the coutry is part of ASEAN
	"Is_au_flag" CHAR(1) NULL,	-- Flag indicating if the coutry is part of AU
	"Is_em_ev_flag" CHAR(1) NULL,	-- Emerging Market Flag EV
	"Is_em_hr_flag" CHAR(1) NULL,	-- Emerging Market Flag RV
	"Is_ewr_flag" CHAR(1) NULL,	-- Flag indicating if the coutry is part of the european economic area
	"Is_mercosur_flag" CHAR(1) NULL,	-- Flag indicating if the country is part of MERCOSUR
	"Is_nafta_flag" CHAR(1) NULL,	-- Flag indicating if the country is part of NAFTA
	"Is_oecd_flag" CHAR(1) NULL,	-- Flag indicating if the country is part of OECD
	"Log_change_reason" VARCHAR(255) NOT NULL,	-- Reason for the change
	"Log_insert_ts_ltz" TIMESTAMP(9) WITH LOCAL TIME ZONE NOT NULL,	-- Timestamp with local time zone when data was inserted into the table
	"Log_last_update_ts_ltz" TIMESTAMP(9) WITH LOCAL TIME ZONE NOT NULL,	-- Timestamp with local time zone when the table was last updated
	"Log_pipeline_id" VARCHAR(255) NOT NULL,	-- Identifier of the pipeline run that added the data
	"Log_pipeline_name" VARCHAR(255) NOT NULL,	-- Name of the pipeline or job
	"Main_currency" VARCHAR(255) NULL,	-- Main currency of the country
	"Name_de" VARCHAR(255) NULL,	-- Full german name of the coutry
	"Name_en" VARCHAR(255) NULL,	-- Full english name of the country
	"Numeric_code" NUMBER(22,2) NULL,	-- Numeric codes following specification in ISO-3166
	"Scd_ctyik" NUMBER(22,2) NULL,	-- Reference to SCD source table
	"Valid_from" TIMESTAMP(9) WITH TIME ZONE NOT NULL,	-- Record version start timestamp
	"Valid_to" TIMESTAMP(9) WITH TIME ZONE NOT NULL,	-- Record version end timestamp
	"Partner_rating_fact_HK" varchar(50) NULL
)
;

CREATE TABLE test_weight_null (
    weight_grams NUMBER NULL,
    CONSTRAINT chk_weight CHECK (weight_grams IS NULL OR weight_grams >= 0)
);

CREATE TABLE test_weight_not_null (
    weight_grams NUMBER NOT NULL,
    CONSTRAINT chk_weight CHECK (weight_grams >= 0)
);

ALTER TABLE test_weight_null
ADD CONSTRAINT chk_weight_null
CHECK (weight_grams IS NULL OR weight_grams >= 0);

ALTER TABLE test_weight_not_null
ADD CONSTRAINT chk_weight_not_null
CHECK (weight_grams >= 0);