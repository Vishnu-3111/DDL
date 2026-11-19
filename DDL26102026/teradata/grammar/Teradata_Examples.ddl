 CREATE TABLE accounts11 (
       cust_id     INTEGER, 
       last_name   VARCHAR(30) CHARACTER SET UNICODE NOT CASESPECIFIC, 
       first_name  VARCHAR(30), 
       city        VARCHAR(50))
     PRIMARY INDEX (cust_id)
     PARTITION BY CASE_N (last_name LIKE 'A%', 
                          last_name LIKE 'B%',
                          last_name LIKE 'C%',
                          last_name LIKE 'D%',
                          last_name LIKE 'E%',
                          last_name LIKE 'F%',
                          last_name LIKE 'G%',
                          last_name LIKE 'H%',
                          last_name LIKE 'I%',
                          last_name LIKE 'J%',
                          last_name LIKE 'K%',
                          last_name LIKE 'L%',
                          last_name LIKE 'M%',
                          last_name LIKE 'N%',
                          last_name LIKE 'O%',
                          last_name LIKE 'P%',
                          last_name LIKE 'Q%',
                          last_name LIKE 'R%',
                          last_name LIKE 'S%',
                          last_name LIKE 'T%',
                          last_name LIKE 'U%',
                          last_name LIKE 'V%',
                          last_name LIKE 'W%',
                          last_name LIKE 'X%',
                          last_name LIKE 'Y%',
                          last_name LIKE 'Z%',
                          NO CASE,
                          UNKNOWN);
						  
CREATE TABLE accounts1 (
       cust_id     INTEGER, 
       last_name   VARCHAR(30) CHARACTER SET UNICODE NOT CASESPECIFIC, 
       first_name  VARCHAR(30), 
       city        VARCHAR(50))
     PRIMARY INDEX (cust_id)
     PARTITION BY  CASE_N (last_name < 'A', last_name < 'B',
                           last_name < 'C', last_name < 'D',
                           last_name < 'E', last_name < 'F',
                           last_name < 'G', last_name < 'H',
                           last_name < 'I', last_name < 'J',
                           last_name < 'K', last_name < 'L',
                           last_name < 'M', last_name < 'N',
                           last_name < 'O', last_name < 'P',
                           last_name < 'Q', last_name < 'R',
                           last_name < 'S', last_name < 'T',
                           last_name < 'U', last_name < 'V',
                           last_name < 'W', last_name < 'X',
                           last_name < 'Y', last_name >= 'Z',
                           UNKNOWN);
						   
CREATE TABLE accounts3 (
       cust_id     INTEGER,
       last_name   VARCHAR(30) NOT CASESPECIFIC, 
       first_name  VARCHAR(30), 
       city        VARCHAR(50))
     PRIMARY INDEX (cust_id)
     PARTITION BY RANGE_N(last_name BETWEEN 'A','B','C','D','E','F','G',
                        'H','I','J','K','L','M','N',
                        'O','P','Q','R','S','T','U',
                         'V','W','X','Y','Z' 
                                   AND
                  'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ',
             NO RANGE,UNKNOWN);
			 
   CREATE TABLE accounts4 (
       cust_id     INTEGER,
       last_name   VARCHAR(30) NOT CASESPECIFIC, 
       first_name  VARCHAR(30), 
       city        VARCHAR(50))
     PRIMARY INDEX (cust_id)
     PARTITION BY RANGE_N(last_name BETWEEN
                 ('A'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('B'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('C'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('D'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('E'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('F'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('G'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('H'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('I'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('J'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('K'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('L'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('M'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('N'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('O'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('P'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('Q'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('R'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('S'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('T'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('U'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('V'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('W'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('X'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('Y'||'0000000000000000000000000000000000000000000000000000000000'XC),
                 ('Z'||'0000000000000000000000000000000000000000000000000000000000'XC),
                  AND
                 ('{'||'0000000000000000000000000000000000000000000000000000000000'XC),
                                   UNKNOWN);
						  
						  
  CREATE TABLE t1(
       i INTEGER,
       j CHARACTER(4),
       k INTEGER)
     PRIMARY INDEX(i)
     PARTITION BY (RANGE_N(j BETWEEN 'aaaa','cccc','eeee', 
                  'gggg','iiii','kkkk',
                  'mmmm','oooo','qqqq',
                  'ssss' 
                             AND     'tttt',
          NO RANGE),
                   RANGE_N(k BETWEEN 1 
                             AND    10 
                             EACH    1));
							 
CREATE TABLE t2(
       i INTEGER,
       j CHARACTER(4) NOT CASESPECIFIC,
       k INTEGER)
     PRIMARY INDEX(i)
     PARTITION BY (RANGE_N(j || 'a' BETWEEN 'aaaa' AND 'bbbb',
                                            'cccc' AND 'dddd', 
                  'eeee' AND 'ffff', 
                  'gggg' AND 'hhhh', 
                  'iiii' AND 'jjjj', 
                  'kkkk' AND 'llll',
                  'mmmm' AND 'nnnn',
                  'oooo' AND 'pppp',
                  'qqqq' AND 'rrrr',
                  'ssss' AND 'tttt',
          NO RANGE),
                   RANGE_N(k BETWEEN 1 
                             AND    10 
                             EACH    1));
							 
							 
CREATE TABLE orders (
       o_orderkey      INTEGER NOT NULL,
       o_custkey       INTEGER,
       o_orderstatus   CHARACTER(1) NOT CASESPECIFIC,
       o_totalprice    DECIMAL(13,2) NOT NULL,
       o_orderdate     DATE FORMAT 'yyyy-mm-dd' NOT NULL,
       o_orderpriority CHARACTER(21),
       o_comment       VARCHAR(79))
     PRIMARY INDEX (o_orderkey)
     PARTITION BY (RANGE_N(o_custkey BETWEEN 0
                                     AND 49999 
                                     EACH 1000),
                   RANGE_N(o_orderdate BETWEEN DATE '2000-01-01' 
                                       AND     DATE '2006-12-31'
                                       EACH INTERVAL '1' MONTH),
                   CASE_N(o_orderstatus = 'S', o_orderstatus = 'C',
                          o_orderstatus = 'F'))
     UNIQUE INDEX (o_orderkey);
	 
     CREATE TABLE lineitem (
       l_orderkey      INTEGER NOT NULL,
       l_partkey       INTEGER NOT NULL,
       l_suppkey       INTEGER,
       l_linenumber    INTEGER,
       l_quantity      INTEGER NOT NULL,
       l_extendedprice DECIMAL(13,2) NOT NULL,
       l_discount      DECIMAL(13,2),
       l_tax           DECIMAL(13,2),
       l_returnflag    CHARACTER(1),
       l_linestatus    CHARACTER(1),
       l_shipdate      DATE FORMAT 'yyyy-mm-dd',
       l_commitdate    DATE FORMAT 'yyyy-mm-dd',
       l_receiptdate   DATE FORMAT 'yyyy-mm-dd',
       l_shipinstruct  VARCHAR(25),
       l_shipmode      VARCHAR(25),
       l_comment       VARCHAR(44))
     PRIMARY INDEX (l_orderkey)
     PARTITION BY (RANGE_N(l_suppkey BETWEEN 0 
                                     AND  4999 
                                     EACH  100),
                   RANGE_N(l_shipdate BETWEEN DATE '2000-01-01' 
                                     AND DATE '2006-12-31' 
                                     EACH INTERVAL '1' MONTH),
                   CASE_N(l_shipmode = 'USPS FirstClass', 
                          l_shipmode = 'UPS', 
                          l_shipmode = 'FedEx', 
                   NO CASE OR UNKNOWN));
				   
 CREATE TABLE sales_history (
       product_code       CHARACTER(8),
       quantity_sold      INTEGER,
       transaction_period PERIOD(DATE))
     PRIMARY INDEX (product_code)
     PARTITION BY RANGE_N(END(transaction_period) 
                              BETWEEN DATE '2008-03-31'
                              AND     DATE '2015-12-31'
                              EACH INTERVAL '1' YEAR);
							  
     CREATE TABLE orders2 (
       o_orderkey      INTEGER NOT NULL,
       o_custkey       INTEGER,
       o_orderperiod   PERIOD(DATE) NOT NULL,
       o_orderpriority CHARACTER(21),
       o_comment       VARCHAR(79))
     PRIMARY INDEX (o_orderkey)
     PARTITION BY CASE_N (END(o_orderperiod) <= DATE '2010-03-31',/*Q1*/
                          END(o_orderperiod) <= DATE '2010-06-30',/*Q2*/
                          END(o_orderperiod) <= DATE '2010-09-30',/*Q3*/
                          END(o_orderperiod) <= DATE '2010-12-31' /*Q4*/
                         );
						 
						 
CREATE TABLE product (
       product_id    INTEGER NOT NULL,
       p_color       INTEGER NOT NULL,
       p_size        INTEGER NOT NULL,
       p_width       SMALLINT NOT NULL,
       p_depth       SMALLINT NOT NULL,
       p_height      SMALLINT NOT NULL,
       p_weight      SMALLINT NOT NULL,
       p_catalog     INTEGER NOT NULL,
       p_code        BYTEINT NOT NULL,
       p_subcode     SMALLINT NOT NULL,
       rating        BYTEINT NOT NULL,
       discontinued  BYTEINT NOT NULL,
       in_stock      INTEGER NOT NULL,
       back_order    INTEGER NOT NULL,
       total_sold    INTEGER NOT NULL,
       product_date  DATE FORMAT 'yyyy-mm-dd' NOT NULL,
       note          CHARACTER(255))
     PRIMARY INDEX (product_id)
     PARTITION BY (RANGE_N(p_color       BETWEEN 1 
                                         AND  1000 
                                         EACH  500),
                   RANGE_N(p_size        BETWEEN 1 
                                         AND 1000, 1001 
                                         AND 48000000),
                   RANGE_N(p_width       BETWEEN 1 
                                         AND   400 
                                         EACH  200),
                   RANGE_N(p_depth       BETWEEN 1 
                                         AND   400 
                                         EACH  200),
                   RANGE_N(p_height      BETWEEN 1 
                                         AND   400 
                                         EACH  200),
                   RANGE_N(p_weight      BETWEEN 1 
                                         AND  2000 
                                         EACH 1000),
                   CASE_N(p_catalog <= 1,NO CASE),
                   RANGE_N(p_code        BETWEEN 1 
                                         AND   100 
                                         EACH   50),
                   RANGE_N(p_subcode     BETWEEN 1 
                                         AND 10000 
                                         EACH 5000),
                   RANGE_N(rating        BETWEEN 1 
                                         AND    10 
                                         EACH    5),
                   CASE_N(discontinued = 0, 
                          discontinued = 1),
                   CASE_N(in_stock < 50,    NO CASE),
                   CASE_N(back_order = 0,   NO CASE),
                   CASE_N(total_sold < 1000,NO CASE),
                   RANGE_N(product_date BETWEEN DATE '2004-01-01' 
                                        AND     DATE '2006-12-31' 
                                        EACH INTERVAL '1' YEAR));
										
										
CREATE VOLATILE TABLE V_lineitem (
       l_orderkey INTEGER NOT NULL,
       l_partkey INTEGER NOT NULL,
       l_suppkey INTEGER,
       l_linenumber INTEGER,
       l_quantity INTEGER NOT NULL,
       l_extendedprice DECIMAL(13,2) NOT NULL,
       l_discount DECIMAL(13,2),
       l_tax DECIMAL(13,2),
       l_returnflag CHARACTER(1),
       l_linestatus CHARACTER(1),
       l_shipdate DATE FORMAT 'yyyy-mm-dd',
       l_commitdate DATE FORMAT 'yyyy-mm-dd',
       l_receiptdate DATE FORMAT 'yyyy-mm-dd',
       l_shipinstruct VARCHAR(25),
       l_shipmode VARCHAR(10),
       l_comment VARCHAR(44))
     PRIMARY INDEX (l_orderkey)
     PARTITION BY RANGE_N(l_shipdate BETWEEN DATE '1992-01-01' 
                                     AND     DATE '1998-12-31' 
                                     EACH INTERVAL '1' MONTH);
									 
									 
     CREATE GLOBAL TEMPORARY TABLE g_orders (
       o_orderkey      INTEGER NOT NULL,
       o_custkey       INTEGER,
       o_orderstatus   CHARACTER(1) CASESPECIFIC,
       o_totalprice    DECIMAL(13,2) NOT NULL,
       o_orderdate     DATE FORMAT 'yyyy-mm-dd' NOT NULL,
       o_orderpriority CHARACTER(21),
       o_clerk         CHARACTER(16),
       o_shippriority  INTEGER,
       o_comment       VARCHAR(79))
     PRIMARY INDEX (o_orderkey)
     PARTITION BY RANGE_N(o_orderdate BETWEEN DATE '1992-01-01' 
                                      AND     DATE '1998-12-31' 
                                      EACH INTERVAL '1' MONTH)
     UNIQUE INDEX (o_orderkey);

 CREATE TABLE good_6 (
       column_1 INTEGER,
       column_2 INTEGER NOT NULL PRIMARY KEY);	

  CREATE TABLE good_7 (
       column_1 INTEGER, 
       column_2 INTEGER NOT NULL UNIQUE,
       column_3 INTEGER NOT NULL UNIQUE);	

CREATE TABLE good_8 (
       column_1 INTEGER, 
       column_2 INTEGER NOT NULL UNIQUE,
       column_3 INTEGER NOT NULL UNIQUE)
     UNIQUE PRIMARY INDEX (column_2);	

  CREATE TABLE cyk.test_1, NO FALLBACK, AFTER JOURNAL (
       x INTEGER, 
       y INTEGER) 
     PRIMARY INDEX(x);
    
     CREATE TABLE cyk.test_2, NO FALLBACK, NOT LOCAL AFTER JOURNAL (
       x INTEGER, 
       y INTEGER) 
     PRIMARY INDEX(x);
    
     CREATE TABLE cyk.test_3, NO FALLBACK, LOCAL AFTER JOURNAL (
       x INTEGER, 
       y INTEGER) 
     PRIMARY INDEX(x);

	  CREATE TABLE cyk.test_4, NO FALLBACK, NO BEFORE JOURNAL,
       NOT LOCAL AFTER JOURNAL (
       x INTEGER, 
       y INTEGER) 
     PRIMARY INDEX(x);
    
     CREATE TABLE cyk.test_5, NO FALLBACK, NO BEFORE JOURNAL,
       NOT LOCAL AFTER JOURNAL (
       x INTEGER, 
       y INTEGER) 
     PRIMARY INDEX(x);
    
     CREATE TABLE cyk.test_6, NO FALLBACK, NO BEFORE JOURNAL,
       LOCAL AFTER JOURNAL (
       x INTEGER, 
       y INTEGER) 
     PRIMARY INDEX(x);
	 
	  CREATE TABLE target_table AS (SELECT column_x + 1 AS column_x,
                                          column_y + 1 AS column_y
                                   FROM subquery_table )
     WITH NO DATA;
	 
	CREATE TABLE target_table2 AS (SELECT column_x, column_y
                                  FROM subquery_table)
								  WITH NO DATA
    INDEX (column_y);	
	
	CREATE TABLE target_table3 (
       column_1 ,
       column_2)
     AS (SELECT *
         FROM subquery_table )
     WITH DATA
     INDEX (column_2);
	 
	   CREATE SET TABLE t21, NO FALLBACK,
       NO BEFORE JOURNAL,
       NO AFTER JOURNAL,
       CHECKSUM = DEFAULT (
         x INTEGER,
         y CHAR(10) CHARACTER SET LATIN CASESPECIFIC,
         z INTEGER)
     UNIQUE PRIMARY INDEX (x);
	 
	  CREATE SET TABLE t9(x, y) AS (SELECT y, z
                                   FROM t1) 
     WITH DATA AND STATISTICS 
     PRIMARY INDEX(x, y);
	 
	  CREATE TABLE t10(a, b NOT CASESPECIFIC, c) AS (SELECT x, y, z
                                                   FROM t1) 
     WITH DATA AND STATISTICS;
	 
	   CREATE TABLE t10(x UPPERCASE, y) AS (SELECT y, z
                                         FROM t1) 
     WITH DATA AND STATISTICS;
	 
	   CREATE TABLE t3 AS (SELECT *
                        FROM test 
                        WHERE x > 10) 
    WITH DATA AND STATISTICS;
	
	   CREATE TABLE t22 AS (SELECT *
                        FROM test LEFT OUTER JOIN  test1 ON test.x=test1.x1) 
    WITH DATA AND STATISTICS;
	
	 CREATE TABLE t24 (a, b) AS (SELECT x1, y1
                                FROM test RIGHT JOIN 
                                test1 ON test.a=test1.a1) 
     WITH DATA AND STATISTICS;
	 
	     CREATE TABLE t31 (c1, c2) AS (SELECT MAX(x), y
                                 FROM test   
                                 GROUP BY 2) 
    WITH DATA AND STATISTICS;
	
	 CREATE TABLE t32 (c1, c2) AS (SELECT COUNT(x), y 
                                 FROM test 
                                 GROUP BY 2) 
    WITH DATA AND STATISTICS;
	
	CREATE TABLE t35(a, b, c) AS (SELECT x1, MIN(y1), AVG(a1)
                                 FROM test1 
                                 GROUP BY x1 
                                 HAVING AVG(y1) > 40) 
    WITH DATA AND STATISTICS;
	
	 CREATE TABLE t36 (c1, c2, c3) AS (SELECT x, RANK(y), z
                                     FROM test 
                                     QUALIFY RANK(X)> 1) 
    WITH DATA AND STATISTICS;
	
	 CREATE TABLE t37 (c1, c2, c3) AS (SELECT x, y, z
                                     FROM test SAMPLE 4) 
    WITH DATA AND STATISTICS;
	
	 CREATE TABLE t41 AS (SELECT *
                        FROM test, test1) 
    WITH DATA AND STATISTICS 
    PRIMARY INDEX (z, z1) 
    INDEX (b, b1);
	
	CREATE TABLE t61 (c1, c2, c3, c4) AS (SELECT x1, y1, x-1, y*2
                                         FROM test1, test) 
    WITH DATA AND STATISTICS;
	
	CREATE TABLE t5 AS (SELECT *
                        FROM v2, v3) 
    WITH DATA AND STATISTICS;
	
	 CREATE TABLE t51 AS (SELECT *
                        FROM v3, test) 
    WITH DATA AND STATISTICS;
	
	 CREATE TABLE t17 AS (SELECT *
                        FROM v1)
     WITH NO DATA AND STATISTICS;
	 
	   CREATE TABLE t51 AS (SELECT *
                        FROM v1) 
    WITH DATA AND STATISTICS;
	
	 CREATE TABLE t52 (a, b) AS (SELECT x+1 AS x, y+1 AS y
                               FROM test) 
    WITH DATA AND STATISTICS;
	
	CREATE TABLE source (
       column_1 INTEGER,
       column_2 INTEGER)
     UNIQUE PRIMARY INDEX (column_1);
	 
	   CREATE TABLE target
     AS source
     WITH NO DATA;

     CREATE TABLE target2 AS (SELECT column_1, column_2
                             FROM source)
     WITH DATA 
     PRIMARY INDEX (column_1);
	 
		CREATE TABLE t37a AS t37 
     WITH NO DATA;
	 
	   CREATE TABLE accounts2 (
       cust_id     INTEGER, 
       last_name   VARCHAR(30) CHARACTER SET UNICODE NOT CASESPECIFIC, 
       first_name  VARCHAR(30), 
       city        VARCHAR(50))
     PRIMARY INDEX (cust_id)
     PARTITION BY CASE_N (last_name LIKE 'A%',
                          last_name LIKE 'B%',
                          last_name LIKE 'C%',
                          last_name LIKE 'D%',
                          last_name LIKE 'E%',
                          last_name LIKE 'F%',
                          last_name LIKE 'G%',
                          last_name LIKE 'H%',
                          last_name LIKE 'I%',
                          last_name LIKE 'J%',
                          last_name LIKE 'K%',
                          last_name LIKE 'L%',
                          last_name LIKE 'M%',
                          last_name LIKE 'N%',
                          last_name LIKE 'O%',
                          last_name LIKE 'P%',
                          last_name LIKE 'Q%',
                          last_name LIKE 'R%',
                          last_name LIKE 'S%',
                          last_name LIKE 'T%',
                          last_name LIKE 'U%',
                          last_name LIKE 'V%',
                          last_name LIKE 'W%',
                          last_name LIKE 'X%',
                          last_name LIKE 'Y%',
                          last_name LIKE 'Z%',
                          NO CASE,
                          UNKNOWN);	
						  
	   CREATE TABLE nopi_constraints1 (
       column_1 INTEGER NOT NULL,
       column_2 INTEGER NOT NULL)
     UNIQUE INDEX (column_1)
     UNIQUE INDEX (column_2)
     NO PRIMARY INDEX;
	 
	  CREATE MULTISET TABLE sales_temp1, FALLBACK, NO BEFORE JOURNAL,
     NO AFTER JOURNAL, CHECKSUM = DEFAULT (
       item_nbr INTEGER NOT NULL,
       sale_date DATE FORMAT 'MM/DD/YYYY' NOT NULL,
       item_count INTEGER)
     NO PRIMARY INDEX;
	 
	 
CREATE TABLE jsonTable4(id INTEGER,
               jsn1 JSON(30000) INLINE LENGTH 30000,
               jsn2 JSON INLINE LENGTH 100);
			   
CREATE TABLE xmlTable4(id INTEGER,
                       xml1 XML(30000) INLINE LENGTH 30000,
                       xml2 XML INLINE LENGTH 100);
					   
CREATE TABLE geoTable3(id INTEGER,
                       geo1 ST_GEOMETRY(100) INLINE LENGTH 100,
                       geo2 ST_GEOMETRY,
                       geo3 ST_GEOMETRY INLINE LENGTH 30000);
					   
	     CREATE TABLE test_12 (
       column_1 INTEGER NOT NULL,
       column_2 INTEGER NOT NULL,
     CONSTRAINT UNIQUE (column_2));
	 
	 
	  CREATE TABLE test_21 AS (
       column_1 INTEGER NOT NULL,
       column_2 INTEGER NOT NULL, 
     CONSTRAINT PRIMARY KEY (column_2));
	 
	  CREATE SET TABLE test_22 ,NO FALLBACK ,
       NO BEFORE JOURNAL,
       NO AFTER JOURNAL,
       CHECKSUM = DEFAULT
       (
       column_1 INTEGER NOT NULL,
       column_2 INTEGER NOT NULL, CONSTRAINT PRIMARY KEY (column_2);
	   
	    CREATE SET TABLE test_32 ,NO FALLBACK ,
       NO BEFORE JOURNAL,
       NO AFTER JOURNAL,
       CHECKSUM = DEFAULT
       (column_1 INTEGER NOT NULL,
       column_2 INTEGER NOT NULL, 
							CONSTRAINT UNIQUE (column_1)
       CONSTRAINT PRIMARY KEY (column_2));
	   
	 CREATE MULTISET TABLE t37 (
        a INTEGER, 
        b INTEGER, 
      c INTEGER, 
        d INTEGER) 
     PARTITION BY (RANGE_N(a BETWEEN 1 
                             AND    10 
                             EACH 1), 
                   COLUMN);
				   
				      CREATE TABLE nopi_constraints (
       column_1 INTEGER NOT NULL,
       column_2 INTEGER NOT NULL ,
     CONSTRAINT UNIQUE (column_1),
     CONSTRAINT PRIMARY KEY (column_2))
     NO PRIMARY INDEX;
	 
	  CREATE MULTISET TABLE sales_temp1, FALLBACK, NO BEFORE JOURNAL,
 NO AFTER JOURNAL, CHECKSUM = DEFAULT (
 item_nbr INTEGER NOT NULL,
 sale_date DATE FORMAT 'MM/DD/YYYY' NOT NULL,
 item_count INTEGER) ;
 
 CREATE TABLE target_nopi AS
 source_pi
 WITH DATA 
 NO PRIMARY INDEX;
 
  CREATE TABLE source_pi (
 column_1 INTEGER,
 column_2 INTEGER)
 UNIQUE PRIMARY INDEX (column_1);
 
 CREATE TABLE source_nopi (
 column_1 INTEGER,
 column_2 INTEGER)
 NO PRIMARY INDEX;

 
 CREATE TABLE xmlTable1(id INTEGER,
 xml1 XML(64000));

CREATE TABLE xmlTable2(id INTEGER,
 xml1 XML(100),
 xml2 XML,
 xml3 XML INLINE LENGTH 30000);

CREATE TABLE xmlTable3(id INTEGER,
 xml1 XML(100) INLINE LENGTH 100,
 xml2 XML,
 xml3 XML INLINE LENGTH 30000);	 
 
 CREATE TABLE table_2 (
       id       tbl_integer, 
       emp_name tbl_char50) 
     PRIMARY INDEX(id);
	 
CREATE SET TABLE MOVEDATE.customer, NO FALLBACK, NO BEFORE JOURNAL,
 NO AFTER JOURNAL, CHECKSUM=DEFAULT (
 cust_name CHARACTER(8) CHARACTER SET LATIN NOT CASESPECIFIC,
 policy_number INTEGER,
 policy_expiration_date DATE FORMAT 'YYYY/MM/DD')
 PRIMARY INDEX ( cust_name ,policy_number )
 PARTITION BY CASE_N(
 policy_expiration_date >= DATE, NO CASE);
 
 CREATE TABLE movedate.stock (
 stock_name CHARACTER(8),
 stock_code INTEGER,
 stock_price DECIMAL(10,6),
 stock_pricing_time TIMESTAMP(6) WITH TIME ZONE)
 PRIMARY INDEX (stock_code, stock_pricing_time)
 PARTITION BY CASE_N(stock_pricing_time >= CURRENT_TIMESTAMP, 
 NO CASE);
 
 CREATE TABLE num_tab (
 n1 NUMBER(3,3),
 n2 NUMBER,
 n3 NUMBER(5),
 n4 NUMBER(5,1),
 n5 NUMBER(9));
 
 CREATE TABLE tab_1 (
 c1 INTEGER, 
 cir_1 circle, 
 cir_2 circle NOT NULL);
 
  CREATE TABLE tab_2 (
 x CHARACTER(10), 
 y SYSUDTLIB.ellipse, 
 z SYSUDTLIB.circle FORMAT 'X(15)' );
 

 
 CREATE TABLE emp_record (
 emp_name VARCHAR(30),
 emp_number INTEGER, 
 salary INTEGER, 
 group_membership CONSTRAINT)
 UNIQUE PRIMARY INDEX(emp_name);
 
 
 CREATE TABLE Customers (
       CustomerID INTEGER ,
       FirstName INTEGER,
	   LastName VARCHAR(50),
	   Email VARCHAR(100),
     CONSTRAINT pk_customer  PRIMARY KEY (CustomerID)
	 );
	 
CREATE TABLE Orders (
    OrderID INTEGER ,
    CustomerID INTEGER,
    OrderDate DATE,
    OrderTotal DECIMAL(10, 2),
	CONSTRAINT pk_orders  PRIMARY KEY (OrderID),
   CONSTRAINT fk_orders FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE table_1_rls_constraints (
 column_1 INTEGER,
 column_2 CHARACTER(30), 
 classification_level CONSTRAINT, 
 classification_category CONSTRAINT)
 UNIQUE PRIMARY INDEX(col1);
 
 
CREATE SET TABLE qtbl_1, QUEUE, FALLBACK, 
 NO BEFORE JOURNAL,
 NO AFTER JOURNAL (
 col_1 TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 col_2 INTEGER,
 col_3 INTEGER)
 PRIMARY INDEX (col_2, col_3);
 
 
 CREATE MULTISET TABLE qtbl_3, QUEUE,
 NO BEFORE JOURNAL,
 NO AFTER JOURNAL (
 qits TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 col_2 INTEGER,
 col_3 INTEGER CHECK (col_3 > 10))
 PRIMARY INDEX (qits);
 
 CREATE GLOBAL TEMPORARY TRACE TABLE udf_test1 (
 proc_ID BYTE(2), 
 sequence INTEGER, 
 udf_name CHARACTER(15),
 in_quantity INTEGER, 
 trace_val1 FLOAT, 
 trace_text CHARACTER(30))
 ON COMMIT DELETE ROWS;
 
 
  CREATE GLOBAL TEMPORARY TRACE TABLE udf_test2, NO LOG (
 proc_ID BYTE(2),
 sequence INTEGER,
 trace_string VARCHAR(256))
 ON COMMIT DELETE ROWS;
 
 CREATE FOREIGN TABLE riverflow_json1
USING ( LOCATION ('/s3/td-usgs-public.s3.amazonaws.com/JSONDATA/') );

CREATE MULTISET FOREIGN TABLE NOS_USR.riverflow_json2 ,FALLBACK ,
 MAP = TD_MAP1
 (
 Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC,
 Payload JSON(16776192) INLINE LENGTH 64000 CHARACTER SET LATIN)
USING
(
 LOCATION ('/s3/td-usgs-public.s3.amazonaws.com/JSONDATA/')
 MANIFEST ('FALSE')
 PATHPATTERN ('$var1/$var2/$var3/$var4/$var5')
 ROWFORMAT ('{"record_delimiter":"\n","character_set":"LATIN"}')
 STOREDAS ('TEXTFILE')
)
NO PRIMARY INDEX ;


CREATE MULTISET FOREIGN TABLE NOS_USR.riverflow_csv2 ,FALLBACK ,
 MAP = TD_MAP1
 (
 Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC,
 GageHeight2 DECIMAL(3,2),
 Flow DECIMAL(3,2),
 site_no INTEGER,
 datetime TIMESTAMP(0) FORMAT 'Y4-MM-DDBHH:MI',
 Precipitation DECIMAL(3,2),
 GageHeight DECIMAL(3,2))
USING
(
 LOCATION ('/s3/td-usgs-public.s3.amazonaws.com/CSVDATA/')
 MANIFEST ('FALSE')
 PATHPATTERN ('$var1/$site_no/$var3/$var4/$var5')
 ROWFORMAT ('{"field_delimiter":",","record_delimiter":"\n","charact
er_set":"LATIN"}')
 STOREDAS ('TEXTFILE')
 HEADER ('TRUE')
 STRIP_EXTERIOR_SPACES ('FALSE')
 STRIP_ENCLOSING_CHAR ('NONE')
)
NO PRIMARY INDEX ;


CREATE MULTISET FOREIGN TABLE NOS_USR.riverflow_parquet ,FALLBACK ,
 MAP = TD_MAP1
 (
 Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC,
 GageHeight2 FLOAT,
 Flow FLOAT,
 site_no BIGINT,
 datetime VARCHAR(16) CHARACTER SET UNICODE NOT CASESPECIFIC,
 Precipitation FLOAT,
 GageHeight FLOAT)
USING
(
 LOCATION ('/s3/td-usgs-public.s3.amazonaws.com/PARQUETDATA/')
 MANIFEST ('FALSE')
 PATHPATTERN ('$var1/$var2/$var3/$var4/$var5')
 STOREDAS ('PARQUET')
)
NO PRIMARY INDEX 
PARTITION BY COLUMN ADD 65525;

CREATE FOREIGN TABLE delta_lake_table1,
 EXTERNAL SECURITY INVOKER TRUSTED test0
 USING (
 LOCATION ('/S3/YOUR-BUCKET.s3.amazonaws.com/testdeltalake/
deltalakewp/_symlink_format_manifest')
 MANIFEST ('TRUE')
 TABLE_FORMAT ('DELTALAKE')
 );
 
 CREATE MULTISET FOREIGN TABLE NOS_USR.delta_lake_table2 ,FALLBACK ,
 EXTERNAL SECURITY INVOKER TRUSTED
 MAP = TD_MAP1
 (
 Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC,
 street VARCHAR(22) CHARACTER SET UNICODE NOT CASESPECIFIC,
 state VARCHAR(2) CHARACTER SET UNICODE NOT CASESPECIFIC,
 bedrooms INTEGER,
 bathrooms INTEGER,
 sqft INTEGER,
 types VARCHAR(11) CHARACTER SET UNICODE NOT CASESPECIFIC,
 price INTEGER)
USING
(
 LOCATION ('/S3/YOUR-BUCKET.s3.amazonaws.com/testdeltalake/deltalakewp/
_symlink_format_manifest')
 MANIFEST ('TRUE')
 TABLE_FORMAT ('DELTALAKE')
 PATHPATTERN ('$var1/$zip/$var3')
 STOREDAS ('PARQUET')
)
NO PRIMARY INDEX
PARTITION BY COLUMN ADD 65524 ;

 
 CREATE FOREIGN TABLE sensordata3,
EXTERNAL SECURITY MyAuthObj
USING (
 LOCATION ('/s3/YOUR-BUCKET.s3.amazonaws.com/')
);

 CREATE MULTISET FOREIGN TABLE myDB.rivercopy_0627_t ,FALLBACK ,
 EXTERNAL SECURITY MyAuthObj ,
 MAP = TD_MAP1
 (
 Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC,
 Payload JSON(8388096) INLINE LENGTH 32000 CHARACTER SET UNICODE)
USING
(
 LOCATION ('/S3/YOUR-BUCKET.s3.amazonaws.com/JSONDATA/
09380000/2018/06/27.json')
 PATHPATTERN 
('$Var1/$Var2/$Var3/$Var4/$Var5/$Var6/$Var7/$Var8/$Var9/$Var10/$Var11/$Var12/$Va
r13/$Var14/$Var15/$Var16/$Var17/$Var18/$Var19/$Var20')
 ROWFORMAT ('{"record_delimiter":"\n","character_set":"UTF8"}')
 STOREDAS ('TEXTFILE')
)
NO PRIMARY INDEX ;

CREATE MULTISET FOREIGN TABLE myDB.rivercopy_0627_t1 ,FALLBACK ,
 EXTERNAL SECURITY MyAuthObj ,
 MAP = TD_MAP1
 (
 Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC,
 Payload JSON(8388096) INLINE LENGTH 32000 CHARACTER SET UNICODE)
USING
(
 LOCATION ('/S3/YOUR-BUCKET.s3.amazonaws.com/JSONDATA/
09380000/2018/06/27.json')
 PATHPATTERN 
('$Var1/$Var2/$Var3/$Var4/$Var5/$Var6/$Var7/$Var8/$Var9/$Var10/$Var11/$Var12/$Va
r13/$Var14/$Var15/$Var16/$Var17/$Var18/$Var19/$Var20')
 ROWFORMAT ('{"record_delimiter":"\n","character_set":"UTF8"}')
 STOREDAS ('TEXTFILE')
)
NO PRIMARY INDEX ;

CREATE FOREIGN TABLE riverflow_csv4,
 EXTERNAL SECURITY MyAuthObj
 USING (
 LOCATION ('/s3/YOUR-BUCKET.s3.amazonaws.com/CSVDATA/09513780/')
 );

CREATE MULTISET FOREIGN TABLE NU.riverflow_csv6 ,FALLBACK ,
 EXTERNAL SECURITY MyAuthObj ,
 MAP = TD_MAP1
 (
 Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC,
 GageHeight2 DECIMAL(3,2),
 Flow DECIMAL(3,2),
 site_no INTEGER,
 datetime TIMESTAMP(0) FORMAT 'Y4-MM-DDBHH:MI',
 Precipitation DECIMAL(3,2),
 GageHeight DECIMAL(3,2))
 
USING
(
 LOCATION ('/s3/YOUR-BUCKET.s3.amazonaws.com/CSVDATA/')
 MANIFEST ('FALSE')
 PATHPATTERN ('$var1/$site_no/$var3/$var4/$var5')
 ROWFORMAT 
('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
 STOREDAS ('TEXTFILE')
 HEADER ('TRUE')
 STRIP_EXTERIOR_SPACES ('FALSE')
 STRIP_ENCLOSING_CHAR ('NONE')
)
NO PRIMARY INDEX ;

CREATE MULTISET FOREIGN TABLE NU.riverflow_csv_9 ,FALLBACK ,
 EXTERNAL SECURITY MyAuthObj ,
 MAP = TD_MAP1
 (
 Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC,
 GageHeight2 DECIMAL(3,2),
 Flow DECIMAL(3,2),
 site_no INTEGER,
 datetime TIMESTAMP(0) FORMAT 'Y4-MM-DDBHH:MI',
 Precipitation DECIMAL(3,2),
 GageHeight DECIMAL(3,2))
USING
(
 LOCATION ('/S3/YOUR-BUCKET.s3.amazonaws.com/CSVDATA/')
 MANIFEST ('FALSE')
 PATHPATTERN ('$CSVDATA/$site_no/$2018/$byteint4/$filename')
 ROWFORMAT 
('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
 STOREDAS ('TEXTFILE')
 HEADER ('TRUE')
 STRIP_EXTERIOR_SPACES ('FALSE')
 STRIP_ENCLOSING_CHAR ('NONE')
)
NO PRIMARY INDEX ;

CREATE MULTISET FOREIGN TABLE CRIMEDATA,
 EXTERNAL SECURITY DEFINER TRUSTED S3
 USING (
 LOCATION ('/s3/s3.amazonaws.com/sv186025-crimedata-no-vcol-pq/')
 )
 PARTITION BY (COLUMN, CITY VARCHAR(2), Year_x BIGINT, Month_x VARCHAR(3));
 
 
CREATE MULTISET FOREIGN TABLE CRIMEDATA2, FALLBACK,
 EXTERNAL SECURITY DEFINER TRUSTED S3_AUTH,
 MAP = TD_MAP1
 (
 Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC,
 index BIGINT,
 ID_Number BIGINT,
 Case_Number VARCHAR(8) CHARACTER SET UNICODE NOT CASESPECIFIC,
 Year_x BIGINT,
 Month_x VARCHAR(3) CHARACTER SET UNICODE NOT CASESPECIFIC,
 Day_x BIGINT,
 Arrest BYTEINT,
 District FLOAT)
USING
(
 LOCATION ('/s3/s3.amazonaws.com/sv186025-crimedata-no-vcol-pq/')
 MANIFEST ('FALSE')
 PATHPATTERN ('$CITY/$Year_x/$Month_x/$var4')
 STOREDAS ('PARQUET')
)
NO PRIMARY INDEX
PARTITION BY (COLUMN, CITY VARCHAR(2), Year_x BIGINT, Month_x VARCHAR(3));


CREATE ERROR TABLE err_table_1 FOR table_1_RLS_constraints1 
 NO RLS;
 
create table table_1_RLS_constraints1;
 
CREATE ERROR TABLE FOR t; 

create table t;

CREATE VIEW dept AS
SELECT deptno(TITLE 'Department Number'),
 deptname(TITLE 'Department Name'), 
 loc (TITLE 'Department Location'), 
 mgrno(TITLE 'Manager Number') 
 FROM department;
 
 CREATE VIEW staff_info (number, name, position, department, 
sex, dob) AS
 SELECT employee.empno, name, jobtitle, deptno, sex, dob 
 FROM employee
 WHERE jobtitle NOT IN ('Vice Pres', 'Manager')
WITH CHECK OPTION;


CREATE VIEW multitype_v AS
SELECT udf_aggregate_mp_struc(NEW VARIANT_TYPE(MultiType.w AS w, 
MultiType.x AS x, 
 MultiType.y AS y, 
 NEW MP_STRUCTURED_INT(MultiType.w, MultiType.x, 
 MultiType.y) AS z)) AS m FROM MultiType;

REPLACE VIEW employee_info (number, name, position, department)
 AS SELECT employee.empno, name, jobtitle, deptno 
 FROM emp_info
 WHERE jobtitle NOT IN ('vice pres', 'manager');
 
 CREATE VIEW emp_record_view AS
 SELECT emp_number, salary, group_membership 
 FROM emp_record
 WHERE emp_name=user;

CREATE VIEW sales_v1 AS
 WITH multiple_orders AS (
 SELECT customer_id, COUNT(*) AS order_count
 FROM orders
 GROUP BY customer_id
 HAVING COUNT(*) > 1
),
multiple_order_totals AS (
 SELECT customer_id, SUM(total_cost) AS total_spend
 FROM orders
 WHERE customer_id IN (SELECT customer_id FROM multiple_orders) 
 GROUP BY customer_id
)
SELECT * FROM multiple_order_totals;

CREATE VIEW sales_v2 AS
WITH multiple_order_totals AS (
 SELECT customer_id, SUM(total_cost) AS total_spend
 FROM orders
 WHERE customer_id IN (SELECT customer_id FROM multiple_orders)
 GROUP BY customer_id
),
multiple_orders AS (
 SELECT customer_id, COUNT(*) AS order_count
 FROM orders
 GROUP BY customer_id
 HAVING COUNT(*) > 1
)
SELECT * FROM multiple_order_totals;

CREATE VIEW t1_view AS WITH RECURSIVE s5 (MinVersion_view) AS (SELECT a1 FROM 
t1 WHERE a1 > 1
UNION ALL
SEL MinVersion_view FROM s5 WHERE MinVersion_view > 3),
RECURSIVE s6 (MinVersion_view2) AS (SELECT a1 FROM t1 WHERE a1 = 2
UNION ALL
SEL MinVersion_view2 FROM S6 WHERE MinVersion_view2 > 2)
SEL * FROM s5,s6;

CREATE VIEW emp_info1 (workername,workeryrsexp,department, 
 managername,manageryrsexp) AS
 SELECT workers.name, workers.yrsexp, workers.deptno, 
 managers.name, managers.yrsexp
 FROM employee AS workers, employee AS managers 
 WHERE workers.deptno = managers.deptno 
 AND managers.jobtitle IN ('Manager', 'Vice Pres') 
 AND workers.yrsexp > managers.yrsexp;
 
 CREATE VIEW emp_info2 (workername,workeryrsexp,department, 
 managername,manageryrsexp) AS
 SELECT workers.name, workers.yrsexp, workers.deptno, 
 managers.name, managers.yrsexp
 FROM employee AS workers, employee AS managers 
 WHERE workers.deptno = managers.deptno 
 AND managers.jobtitle IN ('Manager', 'Vice Pres') 
 AND workers.yrsexp > managers.yrsexp;
 
 CREATE VIEW v2 (a, b, c) 
 AS SELECT a1, b1, c1 
 FROM t1
 WHERE test.value_expression(b1, c1) > 10;
 
 CREATE VIEW dept_sal (deptno, minsal, maxsal, avgsal) AS 
SELECT deptno, MIN(salary), MAX(salary), AVG(salary) 
FROM employee 
GROUP BY deptno 
HAVING AVG(salary) >= 35000;

CREATE VIEW dept300 (name, jobtitle) AS 
 SELECT name, jobtitle 
 FROM employee 
 WHERE DeptNo = 300 
WITH CHECK OPTION;


CREATE RECURSIVE VIEW rpl (part, subpart, quantity, depth) AS (
 SELECT root.part, root.subpart, root.quantity, 0 AS depth
 FROM partlist AS root
 WHERE root.part = '01'
 UNION ALL
 SELECT child.part, child.subpart, child.quantity, parent.depth + 1
 FROM rpl AS parent, partlist AS child
 WHERE parent.subpart = child.part
 AND parent.depth <= 100);
 
 REPLACE RECURSIVE VIEW rec(p, mycount) AS (
 SELECT n, 0 AS mycount
 FROM t
 WHERE n = 1
 UNION ALL
 SELECT rec.p, rec.mycount + 1
 FROM t, rec
 WHERE rec.p = t.n
 AND rec.mycount <= 20
 
 CREATE RECURSIVE VIEW reachable_from (destination, cost, depth) AS (
 SELECT root.destination, root.cost, 0 AS depth
 FROM flights AS root
 WHERE root.source = 'Paris'
 UNION ALL
 SELECT out.destination, in.cost + out.cost, in.depth + 1 AS depth
 FROM reachable_from AS in, flights AS out
 WHERE in.destination = out.source
 AND in.depth <= 20);

CREATE RECURSIVE VIEW reachable_from (source, destination, cost,
 depth) AS (
 SELECT source, destination, MSUM(flights.cost, 25, 
flights.destination), 0 AS depth
 FROM flights
 UNION ALL
 SELECT in1.source, out1.destination, in1.cost + out1.cost,
 in1.depth + 1
 FROM reachable_from in1, flights AS out1
 WHERE in1.destination = out1.source
 AND in1.depth <= 100);

CREATE RECURSIVE VIEW oaf_problem (source, destination, mcost,
 depth) AS (
 SELECT source, destination, MSUM(cost, 25, destination), 
 0 AS depth
 FROM flights
 UNION ALL
 SELECT in1.source, out1.destination, 
 MSUM(in1.mcost + out1.cost, 25, out1.destination),
 in1.depth + 1
 FROM oaf_problem AS in1, flights AS out1
 WHERE in1.destination = out1.source
 AND in1.depth <= 100;

CREATE RECURSIVE VIEW rec1 (f1, mycount) AS (
 SELECT a1, 0 AS mycount
 FROM nonrec
 UNION ALL
 SELECT a2, mycount + 1
 FROM rec LEFT OUTER JOIN nonrec ON nonrec.a1 = rec.f1
 WHERE rec.mycount <= 100);



CREATE RECURSIVE VIEW rec2 (f1, mycount) AS (
 SELECT a1, 0 AS mycount
 FROM nonrec
 UNION ALL
 SELECT a2, mycount + 1
 FROM nonrec LEFT OUTER JOIN rec ON nonrec.a1 = rec.f1
 WHERE rec.mycount <= 100);

CREATE RECURSIVE VIEW rec3 (f1, mycount) AS (
 SELECT a1, 0 AS mycount
 FROM nonrec
 UNION ALL
 SELECT a2, mycount + 1
 FROM nonrec RIGHT OUTER JOIN rec ON nonrec.a1 = rec.f1
 WHERE rec.mycount <= 100);
 
 CREATE RECURSIVE VIEW rec4 (f1, mycount) AS (
 SELECT a1, 0 AS mycount
 FROM nonrec
 UNION ALL
 SELECT a2, mycount + 1
 FROM rec RIGHT OUTER JOIN nonrec ON nonrec.a1 = rec.f1
 WHERE rec.mycount <= 100);
 
 CREATE RECURSIVE VIEW rec5 (f1, mycount) AS (
 SELECT a1, 0 AS mycount
 FROM nonrec1 FULL OUTER JOIN nonrec2 ON nonrec1.a1 = nonrec2.a2
 UNION ALL
 SELECT a2, mycount + 1
 FROM nonrec, rec
 WHERE rec.mycount <= 100);
 
 CREATE RECURSIVE VIEW rec6 (f1, mycount) AS (
 SELECT a1, 0 AS mycount
 FROM nonrec
 UNION ALL
 SELECT a2, mycount + 1
 FROM nonrec FULL OUTER JOIN rec ON nonrec.a1 = rec.f1
 WHERE rec.mycount <= 100);
 
 CREATE RECURSIVE VIEW even (n) AS (
 SELECT * 
 FROM (SELECT 0) AS a(i)
 UNION ALL
 SELECT m + 1
 FROM odd);
 
 CREATE RECURSIVE VIEW odd (m) AS (
 SELECT *
 FROM (SELECT 1) AS a(i)
 UNION ALL
 SELECT n + 1
 FROM even);
 
 REPLACE RECURSIVE VIEW rec8 (p) AS (
 SELECT n
 FROM t
 WHERE n = 1
 UNION ALL
 SELECT t.n
 FROM t
 WHERE t.n = 0;
 
 CREATE RECURSIVE VIEW aggregation1 (source,destination,mycount) AS (
 SELECT source, destination, 0 AS mycount
 FROM flights
 GROUP BY source, destination
 UNION ALL
 SELECT in1.source, out1.destination, in1.mycount + 1
 FROM aggregation AS in1, flights AS out1
 WHERE in1.destination = out1.source
 AND in1.mycount <=100);
 
 CREATE RECURSIVE VIEW aggregation2 (source,destination,mycount) AS (
 SELECT source, destination, 0 AS mycount
 FROM flights
 UNION ALL
 SELECT in1.source, out1.destination, in1.mycount + 1
 FROM aggregation AS in1, flights AS out1
 WHERE in1.destination = out1.source
 AND in1.mycount <=100
 GROUP BY in1.source, out1.destination);
 
 CREATE PROCEDURE GetRegionXSP1
 (INOUT region VARCHAR(64))
 LANGUAGE C
 NO SQL
 EXTERNAL NAME 'CS!getregion!xspsrc/getregion.c!F!xsp_getregion'
 PARAMETER STYLE TD_GENERAL;
 
 CREATE PROCEDURE GetRegionXSP2
 (INOUT region VARCHAR(64))
 LANGUAGE C
 NO SQL
 EXTERNAL NAME 'CS!getregion!xspsrc/getregion.c!F!xsp_getregion'
 PARAMETER STYLE SQL
 
 CREATE PROCEDURE xsp_abc(IN param1 INTEGER, 
 OUT result1 INTEGER)
 LANGUAGE C
 MODIFIES SQL DATA
 PARAMETER STYLE SQL
 EXTERNAL NAME 'SP!CLI!CS!xsp_abc!xsp_abc.c';
 
 CREATE PROCEDURE MyMoney(IN A1 MONEY, OUT A2 MONEY)
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA 
 EXTERNAL NAME 
 'UDF_JAR:UserDefinedFunctions.mymoney';
 
 CREATE PROCEDURE MyCircle(IN A1 CIRCLE, OUT A2 INTEGER)
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA 
 EXTERNAL NAME 
 'UDF_JAR:UserDefinedFunctions.mycircle';
 
 REPLACE PROCEDURE PDT_UDF(IN P1 PERIOD(DATE), IN P2 PERIOD(DATE), OUT P3 
PERIOD(DATE))
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA 
 EXTERNAL NAME 
 'UDF_JAR:UserDefinedFunctions.pdt_udf';
 
 CREATE PROCEDURE get_Geom(IN G1 ST_Geometry, OUT A1 INTEGER)
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA 
 EXTERNAL NAME 
 'UDF_JAR:UserDefinedFunctions.get_Geom';

REPLACE PROCEDURE getPhoneNum(IN A1 phonenumbers_ary, 
 IN EMPID INTEGER, OUT myphonenum INTEGER)
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA 
 EXTERNAL NAME 
 'UDF_JAR:UserDefinedFunctions.getPhoneNums';
 
 CREATE PROCEDURE dst_xsp(IN dataset_in DATASET(8000) Storage Format Avro,
 OUT dataset_out DATASET(8000) Storage Format Avro)
LANGUAGE JAVA 
NO SQL 
PARAMETER STYLE JAVA
EXTERNAL NAME 'JarXSP1:dst_xsp1.dst_xsp(java.sql.Blob, byte[][])';

CREATE PROCEDURE GetRegionXSP3
 (INOUT region VARCHAR(64))
 LANGUAGE C
 NO SQL
 EXTERNAL NAME 'CS!getregion!xspsrc/getregion.c!F!xsp_getregion'
 PARAMETER STYLE SQL;
 
  CREATE PROCEDURE GetRegionXSP4
 (INOUT region VARCHAR(64))
 LANGUAGE C
 NO SQL
 EXTERNAL NAME 'CS!getregion!xspsrc/getregion.c!F!xsp_getregion'
 PARAMETER STYLE TD_GENERAL;
 
 CREATE PROCEDURE mybyteint
 (IN b BYTEINT,
 OUT c BYTEINT)
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA
 EXTERNAL NAME 'User_jar:UnitTest.mybyteint';
 
 CREATE PROCEDURE mysmallint
 (IN b smallint, 
 INOUT c smallint )
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA
 EXTERNAL NAME 'newint_jar:newint.mysmallint';

 
 CREATE PROCEDURE myint
 (IN b INTEGER, 
 OUT c INTEGER )
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA 
 EXTERNAL NAME 'user_jar:UnitTest.myint';
 
 CREATE PROCEDURE mydecs
 (IN c DECIMAL(8,2), 
 OUT d DECIMAL(8,2))
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA
 EXTERNAL NAME 'user_jar:UnitTest.mydec';
 
 CREATE PROCEDURE myfloat
 (IN i FLOAT, 
 OUT j FLOAT )
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA
 EXTERNAL NAME 'user_jar:UnitTest.myfloat';
 
 CREATE PROCEDURE mydatediagret
 (IN d DATE,
 OUT o DATE )
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA
 EXTERNAL NAME 'user_jar:UnitTest.mydatediagret';
 
 CREATE PROCEDURE mytimezdiagret
 (IN t int,
 OUT d int )
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA
 EXTERNAL NAME 'user_jar:UnitTest.mytimezdiagret';
 
 CREATE PROCEDURE mytszdiagret
 (IN t date,
 OUT d date )
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA
 EXTERNAL NAME 'user_jar:UnitTest.mytszdiagret';
 
 CREATE PROCEDURE intcpy
 (IN parameter_1 INTERVAL YEAR,
 OUT t INTERVAL YEAR )
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA
 EXTERNAL NAME 'user_jar:UnitTest.intcpy';
 
 CREATE PROCEDURE strcpy
 (IN parameter_1 VARCHAR(15),
 OUT t VARCHAR(15) )
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA
 EXTERNAL NAME 'user_jar:UnitTest.strcpy';
 
 CREATE PROCEDURE myclobdiagret2
 (IN b CLOB)
 LANGUAGE JAVA
 MODIFIES SQL DATA
 PARAMETER STYLE JAVA
 EXTERNAL NAME 'user_jar:UnitTest.myclobdiagret2';
 
 CREATE PROCEDURE mybvdiagret
 (IN c varbyte(30),
 OUT d varbyte(30))
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA
 EXTERNAL NAME 'user_jar:UnitTest.mybvdiagret';
 
 CREATE PROCEDURE myblobdiagret
 (IN b blob,
 OUT c blob)
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA
 EXTERNAL NAME 'user_jar:UnitTest.myblobdiagret';
 
 
 CREATE PROCEDURE sp_params (INOUT iop1 SMALLINT,
 OUT op1 DECIMAL(10,3), 
 IN ip2 NUMERIC, 
 INOUT iop2 FLOAT, 
 OUT op2 REAL, 
 IN ip3 DOUBLE PRECISION)
 BEGIN
 SET iop1=3;
 SET op1=5.2;
 SET iop2=10.2;
 SET op2=iop2;
 END;
 
 CREATE PROCEDURE SYSLIB.static_dml()
 SQL SECURITY CREATOR
 BEGIN
 INSERT INTO t1
 SELECT 1,1;
 END;

 
 REPLACE PROCEDURE testdb1.sp1() 
 SQL SECURITY INVOKER 
 BEGIN 
 delete from db1.tab1; 
 insert into db1.tab1 select * from db2.tab1;
 END;
 
//1
 
 //2

CREATE PROCEDURE sp_sample4a (IN in_param INTEGER,
 OUT out_param INTEGER) 
 SET out_param = in_param + 1;
 
CREATE PROCEDURE sp_sample4b (IN in_param INTEGER,
 OUT out_param INTEGER)
 WHILE (in_param < 20)
 SET out_param = in_param + 1;
 END WHILE;

//3

CREATE PROCEDURE clobsplitter(IN a1 INTEGER, 
 IN a2 INTEGER, 
 INOUT b CLOB )
 BEGIN
 DECLARE localclob CLOB;
 DECLARE len INTEGER;
 SET len = CHARACTERS(b);
 SET localclob = SUBSTR(b, 1, len/2);
 INSERT tabc1 (:a1, localclob);
 INSERT tabc2 (:a2, SUBSTR(b, len/2 + 1));
 SET b = localclob || SUBSTR(b, len/2 + 1);
 END;
//4
 
 CREATE PROCEDURE stores_sales_procedure (storecode INTEGER, 
 salesdate DATE, 
 salesclob CLOB)
 BEGIN
 INSERT INTO saleslog (:storecode, :salesdate, :salesclob,
 CURRENT_DATE, CURRENT_TIME);
 INSERT INTO sales 
 SELECT * FROM TABLE (xmlparser(:salesclob));
 END;
 
 //5
 
 CREATE PROCEDURE abc (IN data1v VARCHAR(10), 
 IN data2v VARCHAR(10))
 DYNAMIC RESULT SETS 1
 BEGIN
 DECLARE sql_stmt1 VARCHAR(100);
 DECLARE sales DECIMAL(8,2);
 DECLARE item INTEGER;
 DECLARE cstmt CURSOR WITH RETURN FOR stmt1;
 SET sql_stmt1 = 'SELECT T1.item, T1.sales FROM T1 WHERE'
 data1v | '= store_name AND ' | data2v | '= region;';
 PREPARE stmt1 FROM sql_stmt1;
 OPEN cstmt;
 FETCH NEXT FROM cstmt INTO item, sales;
 END;
 
//6

CREATE PROCEDURE cas01 (OUT p1 insv_structured_date)
 BEGIN
 DECLARE vudt insv_structured_date AS NEW insv_structured_date();
 SET p1= NEW insv_structured_date(CAST('02/02/02' AS DATE));
 END;
 //7

//8
 
 CREATE PROCEDURE sp_sample1( ip INTEGER, 
 OUT op INTEGER) 
 BEGIN DECLARE var1 INTEGER;
 SELECT col1 INTO var1 
 FROM tab1 
 WHERE col2 = ip;
 SET op = var1 * 10;
 END;
 
 CREATE PROCEDURE spSampleQ(IN ip INTEGER, 
 OUT op INTEGER)
 BEGIN DECLARE qits TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
 qsn INTEGER GENERATED ALWAYS AS IDENTITY,
 qcol_1 INTEGER,
 qcol_2 INTEGER;
 SELECT AND CONSUME TOP 1 qits, qsn, qcol_1, qcol_2 
 INTO c_qits, c_qsn, c_qcol_1, c_qcol_2
 FROM qtab1e; 
 END;
 
 CREATE PROCEDURE consumecart(OUT sp_ordernum CHARACTER(15), 
 OUT sp_product CHARACTER(30), 
 OUT sp_quantity INTEGER) 
 BEGIN 
 SELECT AND CONSUME TOP 1 ordernum, product, quantity INTO 
 :sp_ordernum, :sp_product, :sp_quantity FROM shoppingcart;
 END;
 
 CREATE FUNCTION test.myudf1 (a CLOB, b INTEGER, c INTEGER, 
 d CHARACTER (100))
 RETURNS CHAR(50)
 LANGUAGE SQL
 DETERMINISTIC
 CONTAINS SQL
 SPECIFIC test.myudf
 CALLED ON NULL INPUT
 SQL SECURITY DEFINER
 COLLATION INVOKER
 INLINE TYPE 1
 RETURN d || (SUBSTRING(a FROM b FOR c));
 
 CREATE FUNCTION test.myudf2 (a CHARACTER(100))
 RETURNS CHARACTER(400)
 LANGUAGE SQL
 DETERMINISTIC
 CONTAINS SQL
 SPECIFIC test.myudf
 CALLED ON NULL INPUT
 SQL SECURITY DEFINER
 COLLATION INVOKER
 INLINE TYPE 1
 RETURN CHAR2HEXINT(a);
 
  CREATE FUNCTION test.myudf3 (a PERIOD(TIME))
 RETURNS TIME
 LANGUAGE SQL
 DETERMINISTIC
 CONTAINS SQL
 SPECIFIC test.myudf
 CALLED ON NULL INPUT
 SQL SECURITY DEFINER
 COLLATION INVOKER
 INLINE TYPE 1
 RETURN PRIOR(END(a));
 
 CREATE FUNCTION test.zipcode (a address)
 RETURNS CHARACTER(5)
 LANGUAGE SQL
 DETERMINISTIC
 CONTAINS SQL
 SPECIFIC test.zipcode
 CALLED ON NULL INPUT
 SQL SECURITY DEFINER
 COLLATION INVOKER
 INLINE TYPE 1
 RETURN a.zip();

CREATE FUNCTION test.udf (a INTEGER)
 RETURNS INTEGER
 LANGUAGE SQL
 DETERMINISTIC
 CONTAINS SQL
 SPECIFIC test.udf
 CALLED ON NULL INPUT
 SQL SECURITY DEFINER
 COLLATION INVOKER
 INLINE TYPE 1
 RETURN a + SYSLIB.my_external_udf();
 
 CREATE FUNCTION test.geospatial_type_UDF1()
 RETURNS ST_GEOMETRY
 LANGUAGE SQL
 DETERMINISTIC
 CONTAINS SQL
 SPECIFIC test.geospatial_type_UDF
 CALLED ON NULL INPUT
 SQL SECURITY DEFINER
 COLLATION INVOKER
 INLINE TYPE 1
 RETURN NEW ST_GEOMETRY('POINT (1,2)');
 
 CREATE FUNCTION test.geospatial_type_udf2
 (a ST_GEOMETRY, b ST_GEOMETRY)
 RETURNS INTEGER
 LANGUAGE SQL
 DETERMINISTIC
 CONTAINS SQL
 SPECIFIC test.geospatial_type_UDF
 CALLED ON NULL INPUT
 SQL SECURITY DEFINER
 COLLATION INVOKER
 INLINE TYPE 1
 RETURN a.st_within(b);
 
  CREATE FUNCTION xml_extract( xml_text VARCHAR(64000))
 RETURNS TABLE (cust_id INTEGER,
 store INTEGER,
 item INTEGER)
 LANGUAGE C
 NO SQL
 EXTERNAL;

CREATE FUNCTION xml_extract( xml_text LOCATOR CLOB)
 RETURNS TABLE (cust_id INTEGER,
 store INTEGER,
 item INTEGER)
 LANGUAGE C
 NO SQL
 EXTERNAL;
 
 CREATE FUNCTION fnc_tbf001udt(
 p1 INTEGER, 
 p2 TABLEINT)
 RETURNS TABLE (c1 INTEGER, 
 c2 INTEGER, 
 c3 VARCHAR(3), 
 udtc4 TABLEINT)
 LANGUAGE C 
 NO SQL 
 PARAMETER STYLE SQL 
 EXTERNAL NAME 'CS!fnc_tbf001udt!fnc_tbf001udt.c';
 
 CREATE FUNCTION lobtf_concat3 (
 NumRows INTEGER,
 A BLOB AS LOCATOR,
 B VARBYTE(64000),
 C BLOB AS LOCATOR)
 RETURNS TABLE (ampnum INTEGER,
 a_out BLOB(10),
 b_out VARBYTE(10),
 c_out BLOB(10),
 myresult BLOB(30))
 LANGUAGE C
 NO SQL
 PARAMETER STYLE SQL
 EXTERNAL NAME 'SS!lobtf_concat3!/home/i18n/hsf/tf/c/
 lobtf_concat3.c';
 
 CREATE FUNCTION extract_store_data (
 text VARCHAR(32000),
 from_store INTEGER)
 RETURNS TABLE VARYING COLUMNS (10)
 SPECIFIC extract_store_data
 LANGUAGE C
 NO SQL
 PARAMETER STYLE SQL
 NOT DETERMINISTIC
 EXTERNAL NAME 'SS!extract_store_data!extract_store_data.c';

 
 CREATE FUNCTION mytableudf (
 p1 INTEGER )
 RETURNS TABLE (c1 INTEGER, 
 c2 INTEGER)
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA 
 EXTERNAL NAME 'UDF_JAR:UserDefinedFunctions.mytableudf';
 
 CREATE FUNCTION mytableudf (
 p1 INTEGER )
 RETURNS TABLE (c1 INTEGER, 
 c2 INTEGER)
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA 
 EXTERNAL NAME 
'UDF_JAR:UserDefinedFunctions.mytableudf(int, int[],int[])';

 REPLACE FUNCTION add2int (
 a INTEGER, 
 b INTEGER)
 RETURNS TABLE (
 addend1 INTEGER, 
 addend2 INTEGER, 
 mysum INTEGER)
 SPECIFIC add2int 
 LANGUAGE C 
 NO SQL 
 PARAMETER STYLE SQL
 NOT DETERMINISTIC
 CALLED ON NULL INPUT
 EXTERNAL NAME 'CS!add3int!add2int.c';

CREATE FUNCTION rdg.tdat 
 (rowc INTEGER, 
 InLineNum INTEGER, 
 logonstr VARCHAR(50) CHARACTER SET LATIN, 
 sqlRqst VARCHAR(512) CHARACTER SET LATIN) 
 RETURNS TABLE (
 ampId INTEGER, 
 cnt INTEGER, 
 OutLineNum INTEGER, 
 str1 VARCHAR(256) CHARACTER SET LATIN,
 str20 VARCHAR(256) CHARACTER SET LATIN) 
 SPECIFIC tdat 
 LANGUAGE C 
 NO SQL 
 PARAMETER STYLE SQL 
 NOT DETERMINISTIC 
 CALLED ON NULL INPUT 
 EXTERNAL NAME 'SS:tdat:/home/rdg/tdat/Tdat.c:SL:cliv2';
 
 CREATE FUNCTION find_text (
 searched_string VARCHAR(500), 
 pattern VARCHAR(500))
 RETURNS CHARACTER
 LANGUAGE C
 NO SQL
 EXTERNAL
 PARAMETER STYLE SQL;
 
  CREATE FUNCTION write_mq(
 qmgr VARCHAR(256), 
 qnm VARCHAR(256), 
 channel VARCHAR(256), 
 vcmsg VARCHAR(32000)) 
 RETURNS INTEGER
 LANGUAGE C 
 NO SQL 
 PARAMETER STYLE SQL 
 EXTERNAL NAME 'F:emruwmq:SI:cmqc:/usr/include/cmqc.h:SL:mqic
 :SL:mqmcs:SS:emruwmq:/home/rmh/projects/emruwmq/emruwmq.c';
 
 CREATE FUNCTION sales_collect (
 store_number INTEGER, 
 item_no INTEGER)
 RETURNS INTEGER
 LANGUAGE C
 NO SQL
 EXTERNAL NAME 'cs!salecol!salecollector.c'
 PARAMETER STYLE SQL
 EXTERNAL SECURITY DEFINER sales;
 
 CREATE FUNCTION udf_agch002002udt (
 parameter_1 varchar_udt) 
 RETURNS varchar_udt 
 CLASS AGGREGATE (20000)
 LANGUAGE C 
 NO SQL 
 EXTERNAL NAME 'CS!udf_agch002002udt!udf_agch002002udt.c' 
 PARAMETER STYLE SQL;
 
 CREATE FUNCTION clob_compress (a CLOB AS LOCATOR) 
 RETURNS BLOB AS LOCATOR 
 SPECIFIC clob_compress 
 LANGUAGE C 
 NO SQL 
 FOR COMPRESS 
 PARAMETER STYLE TD_GENERAL
 RETURNS NULL ON NULL INPUT 
 DETERMINISTIC 
 EXTERNAL NAME 'cs!clobcompress!clobcompress.c';
 
 CREATE FUNCTION d_clob_compress (a DCLOB) 
 RETURNS BLOB AS LOCATOR 
 SPECIFIC d_clob_compress 
 LANGUAGE C 
 NO SQL 
 FOR COMPRESS 
 PARAMETER STYLE TD_GENERAL RETURNS NULL ON NULL INPUT 
 DETERMINISTIC 
 EXTERNAL NAME 'cs!dclobcompress!dclobcompress.c';
 
 CREATE FUNCTION clob_decompress (a BLOB AS LOCATOR) 
 RETURNS CLOB AS LOCATOR 
 SPECIFIC clob_decompress 
 LANGUAGE C 
 NO SQL 
 FOR DECOMPRESS 
 PARAMETER STYLE TD_GENERAL 
 RETURNS NULL ON NULL INPUT 
 DETERMINISTIC 
 EXTERNAL NAME 'cs!clobdecompress!clobdecompress.c';
 
 CREATE FUNCTION d_clob_decompress (a BLOB AS LOCATOR) 
 RETURNS DCLOB
 SPECIFIC d_clob_decompress 
 LANGUAGE C 
 NO SQL 
 FOR DECOMPRESS 
 PARAMETER STYLE TD_GENERAL RETURNS NULL ON NULL INPUT 
 DETERMINISTIC 
 EXTERNAL NAME 'cs!dclobdecompress!dclobdecompress.c';
 
 CREATE FUNCTION s_clob_decompress (a BLOB AS LOCATOR) 
 RETURNS SCLOB 
 SPECIFIC s_clob_decompress 
 LANGUAGE C 
 NO SQL 
 FOR DECOMPRESS 
 PARAMETER STYLE TD_GENERAL RETURNS NULL ON NULL INPUT 
 DETERMINISTIC 
 EXTERNAL NAME 'cs!sclobdecompress!sclobdecompress.c';
 
 CREATE FUNCTION udf_agch002002dynudt (
 parameter_1 VARIANT_TYPE) 
RETURNS integer_udt CLASS AGGREGATE(4) 
LANGUAGE C 
NO SQL 
EXTERNAL NAME 'CS!udf_agch002002dynudt!udf_agch002002dynudt.c' 
PARAMETER STYLE SQL;

CREATE FUNCTION ascii (
 string_expr TD_ANYTYPE)
 RETURNS TD_ANYTYPE
 LANGUAGE C
 NO SQL
 SPECIFIC ascii
 EXTERNAL NAME 'CS!ascii!ascii.c'
 PARAMETER STYLE SQL;
 CREATE FUNCTION judf_cref012003 (
 par1 BIGINT)
 RETURNS BIGINT
 CAST FROM INTEGER
 SPECIFIC judf_cref012003
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA
 NOT DETERMINISTIC
 CALLED ON NULL INPUT
 EXTERNAL NAME 'UDF_JAR:UserDefinedFunctions.mybigint(long) 
 returns int';
 
 CREATE FUNCTION std_dev(
 x FLOAT)
 RETURNS FLOAT
 CLASS AGGREGATE(79)
 LANGUAGE JAVA
 NO SQL
 PARAMETER STYLE JAVA
 EXTERNAL NAME 'UDF_JAR:UserDefinedFunctions.std_dev(
 com.teradata.fnc.Phase,
 com.teradata.fnc.Context[],
 double) 
 returns java.lang.Double';
 
 CREATE FUNCTION my_array_udf1( 
 a1 phonenumbers_ary) 
 RETURNS VARCHAR(100)
 NO SQL
 PARAMETER STYLE SQL
 DETERMINISTIC
 LANGUAGE C
 EXTERNAL NAME 'CS!my_array_udf!my_array_udf.c';
 
 CREATE FUNCTION my_array_udf2 ( 
 a1 phonenumbers_ary) 
 RETURNS VARCHAR(100)
 NO SQL
 PARAMETER STYLE TD_GENERAL
 DETERMINISTIC
 LANGUAGE C
 EXTERNAL NAME 'CS!my_array_udf!my_array_udf.c';
 
 CREATE FUNCTION array_udf1( 
 a1 3d_array) 
 RETURNS VARCHAR(100)
 NO SQL
 PARAMETER STYLE SQL
 DETERMINISTIC
 LANGUAGE C
 EXTERNAL NAME 'CS!array_udf!array_udf.c!F!my_array_udf';
 
 CREATE FUNCTION array_udf2 ( 
 a1 3d_array) 
 RETURNS VARCHAR(100)
 NO SQL
 PARAMETER STYLE TD_GENERAL
 DETERMINISTIC
 LANGUAGE C
 EXTERNAL NAME 'CS!array_udf!array_udf.c!F!my_array_udf';
 
 CREATE FUNCTION SYSLIB.insert_level (
 CURRENT_SESSION SMALLINT)
 RETURNS SMALLINT
 LANGUAGE C
 NO SQL
 PARAMETER STYLE TD_GENERAL
 EXTERNAL NAME 'CS!insertlevel!c:\cctests\insertlevel.c';
 
 CREATE FUNCTION SYSLIB.update_level (
 CURRENT_SESSION SMALLINT, 
 INPUT_ROW SMALLINT)
 RETURNS SMALLINT
 LANGUAGE C
 NO SQL
 PARAMETER STYLE TD_GENERAL
 EXTERNAL NAME 'CS!updatelevel!c:\cctests\updatelevel.c';
 
 CREATE FUNCTION SYSLIB.delete_level (
 INPUT_ROW SMALLINT)
 RETURNS CHARACTER
 LANGUAGE C
 NO SQL
 PARAMETER STYLE TD_GENERAL
 EXTERNAL NAME 'CS!deletelevel!c:\cctests\deletelevel.c';
 
 CREATE FUNCTION SYSLIB.read_level (
 CURRENT_SESSION SMALLINT, 
 INPUT_ROW SMALLINT)
 RETURNS CHARACTER
 LANGUAGE C
 NO SQL
 PARAMETER STYLE TD_GENERAL
 EXTERNAL NAME 'CS!readlevel!c:\cctests\readlevel.c';
 
 CREATE FUNCTION SYSLIB.insert_category (
 CURRENT_SESSION BYTE(8))
 RETURNS BYTE(8)
 LANGUAGE C
 NO SQL
 PARAMETER STYLE SQL
 EXTERNAL NAME 'CS!insert_category!c:\cctests\insert_category.c';
 
 CREATE FUNCTION SYSLIB.UpdateCategory (
 CURRENT_SESSION BYTE(8), 
 INPUT_ROW BYTE(8))
 RETURNS BYTE(8)
 LANGUAGE C
 NO SQL
 PARAMETER STYLE SQL
 EXTERNAL NAME 'CS!updatecategory!c:\cctests\updatecategory.c';
 
 CREATE FUNCTION SYSLIB.DeleteCategory (
 INPUT_ROW BYTE(8))
 RETURNS CHARACTER
 LANGUAGE C
 NO SQL
 PARAMETER STYLE SQL
 EXTERNAL NAME 'CS!deletecategory!c:\cctests\deletecategory.c';
 
 CREATE FUNCTION SYSLIB.ReadCategory (
 CURRENT_SESSION BYTE(8), 
 INPUT_ROW BYTE(8))
 RETURNS CHARACTER
 LANGUAGE C
 NO SQL
 PARAMETER STYLE SQL
 EXTERNAL NAME 'CS!readcategory!c:\cctests\readcategory.c';
 
 CREATE FUNCTION SYSLIB.ReadClassification (
 UserClearance SMALLINT,
 RowClassification SMALLINT)
 RETURNS CHARACTER(1)
 SPECIFIC SYSLIB.ReadClassification
 LANGUAGE C
 DETERMINISTIC
 NO SQL
 EXTERNAL NAME 'cs!ReadClassification!c:\udf_ReadClassification.c'
 PARAMETER STYLE TD_GENERAL;
 
 REPLACE FUNCTION MAPPING appl_view_db.Attribution
 FOR attribution SERVER coprocessor 
 MAP JSON ( '{ "function_version": "1.0" }') 
 USING
 ANY IN TABLE,
 conversion IN TABLE,
 excluding IN TABLE,
 optional IN TABLE,
 model1 IN TABLE,
 model2 IN TABLE,
 EventColumn, TimestampColumn, WindowSize (10);
 
 CREATE FUNCTION MAPPING user_Attribution
 FOR attribution 
 USING
 ANY IN TABLE,
 ANY IN TABLE,
 conversion IN TABLE,
 excluding IN TABLE,
 optional IN TABLE,
 model1 IN TABLE,
 model2 IN TABLE,
 EventColumn, TimestampColumn, WindowSize;
 
 CREATE FUNCTION MAPPING appl_view_db.glm 
 FOR glm SERVER coprocessor 
 MAP JSON ( '{ "function_version": "1.0" }') 
 USING 
 InputTable IN TABLE, 
 OutputTable OUT TABLE, 
 ColumnNames, CategoricalColumns, Family, 
 Link, Weight, Threshold, MaxIterNum, Intercept, Step;
 
 CREATE FUNCTION MAPPING appl_view_db.Attribution
 FOR attribution SERVER coprocessor 
 MAP JSON ( '{ "function_version": "1.0" }') 
 USING
 ANY IN TABLE,
 conversion IN TABLE,
 excluding IN TABLE,
 optional IN TABLE,
 model1 IN TABLE,
 model2 IN TABLE,
 EventColumn, TimestampColumn, WindowSize;
 
 CREATE FUNCTION MAPPING usr_SVMSparse
FOR SparseSVMTrainer SERVER TD_SERVER_DB.coprocessor
USING
InputTable(inp_table) IN TABLE ,
ModelTable(model_table) OUT TABLE ,
IDColumn ,
SampleIdColumn ,
AttributeColumn(AttributeNameColumn) ,
LabelColumn(ResponseColumn),
ValueColumn(AttributeValueColumn),
HashProjection , "Hash" , HashBuckets ,
Cost , Bias , ClassWeights ,
MaxStep(Maxnum) ,
Maxnum(10),
Epsilon , Seed , SequenceInputBy
;

CREATE FUNCTION MAPPING usr_SVMSparse
FOR SparseSVMTrainer SERVER TD_SERVER_DB.coprocessor
USING
InputTable IN TABLE ,
ModelTable OUT TABLE ,
IDColumn ,
SampleIdColumn ,
AttributeColumn(AttributeNameColumn) ,
LabelColumn(ResponseColumn),
ValueColumn(AttributeValueColumn),
HashProjection , "Hash" , HashBuckets ,
Cost , Bias , ClassWeights ,
MaxStep ,
Epsilon , Seed , SequenceInputBy
;

CREATE FUNCTION MAPPING appl_view_db.CCMPrepare
 FOR ccmprepare SERVER coprocessor 
 MAP JSON ( '{ "function_version": "1.0" }') 
 USING 
 ANY IN TABLE;
 
 CREATE FUNCTION MAPPING user_Attribution
 FOR attribution MAP JSON ( '{ "function_version": "1.0" }') 
 USING
 ANY IN TABLE,
 ANY IN TABLE,
 conversion IN TABLE,
 excluding IN TABLE,
 optional IN TABLE,
 model1 IN TABLE,
 model2 IN TABLE,
 EventColumn, TimestampColumn, WindowSize;
 
 CREATE FUNCTION MAPPING user_attribution
FOR Attribution SERVER coprocessor
USING
inputtable IN TABLE,
inputtable1 IN TABLE,
ConversionEvents(ANY) IN TABLE,
excluding IN TABLE,
optional IN TABLE,
model1 IN TABLE,
model2 IN TABLE,
EVENT_COLUMN_NAME ('event'),
TIMESTAMP_COLUMN_NAME ('time_stamp' ),
WINDOW(WindowSize);

CREATE FUNCTION MAPPING appl_view_db.GLMPredict
 FOR glmpredict SERVER coprocessor 
 MAP JSON ( '{ "function_version": "1.0" }') 
 USING 
 ANY IN TABLE, 
 MODEL IN TABLE;
 
 CREATE FUNCTION MAPPING user_attribution
FOR Attribution SERVER coprocessor
USING
inputtable IN TABLE,
ANY IN TABLE,
ConversionEvents(conversion) IN TABLE,
excluding IN TABLE,
optional IN TABLE,
model1 IN TABLE,
model2 IN TABLE,
EVENT_COLUMN_NAME ('event'),
TIMESTAMP_COLUMN_NAME ('time_stamp' ),
WINDOW(WindowSize);

CREATE FUNCTION MAPPING usr_SVMSparse
FOR SparseSVMTrainer SERVER TD_SERVER_DB.coprocessor
USING
InputTable IN TABLE ,
ModelTable(model_table) OUT TABLE ,
IDColumn ,
SampleIdColumn ,
AttributeColumn(AttributeNameColumn) ,
LabelColumn(ResponseColumn),
ValueColumn(AttributeValueColumn),
HashProjection , "Hash" , HashBuckets ,
Cost , Bias , ClassWeights ,
MaxStep ,
Epsilon , Seed , SequenceInputBy
;

CREATE FUNCTION MAPPING sessionize_fm FOR sessionize SERVER coprocessor
USING
InputTable IN TABLE,
ModelTable IN TABLE,
ClusterTable OUT TABLE,
TIMECOLUMN,
TIMEOUT(SELECT timeout FROM ssqtbl WHERE username='John'),
CLICKLAG,
EMITNULL;

CREATE FUNCTION MAPPING sessionize_fm FOR sessionize SERVER coprocessor
USING
InputTable IN TABLE,
ModelTable IN TABLE,
ClusterTable OUT TABLE,
TIMECOLUMN,
TIMEOUT(SELECT timeout FROM ssqtbl WHERE username=USER),
CLICKLAG,
EMITNULL;

CREATE FUNCTION MAPPING usr_SVMSparse
FOR SparseSVMTrainer SERVER TD_SERVER_DB.coprocessor
USING
InputTable IN TABLE ,
ModelTable OUT TABLE ,
IDColumn ,
SampleIdColumn ,
AttributeColumn(AttributeNameColumn) ,
LabelColumn(ResponseColumn),
ValueColumn(AttributeValueColumn||'_'||Maxnum),
HashProjection , "Hash" , HashBuckets ,
Cost , Bias , ClassWeights ,
MaxStep(Maxnum) ,
Epsilon , Seed , SequenceInputBy
;

CREATE FUNCTION MAPPING NOS_Writer
FOR WRITE_NOS
EXTERNAL SECURITY DEFINER TRUSTED MyObjAuth
USING
LOCATION,
STOREDAS,
NAMING,
MANIFESTFILE,
MANIFESTONLY,
OVERWRITE,
INCLUDE_ORDERING,
INCLUDE_HASHBY,
MAXOBJECTSIZE,
COMPRESSION,
ANY IN TABLE;


create table employee1
(
	name INTEGER,
	ssn INTEGER
);

CREATE UNIQUE INDEX ident (name, ssn) ON employee1;


create table ind_table
(
	column_1 INTEGER
);

CREATE INDEX index_2 (column_1) ON ind_table;

create table employee2
(
	dept_no INTEGER
);

CREATE INDEX (dept_no) ON employee2;

create table employee3
(
	dept_no INTEGER
);

CREATE INDEX(dept_no) WITH LOAD IDENTITY ON employee3;

create table lineitem2
(
	l_orderkey INTEGER
);

CREATE JOIN INDEX order_join_line AS 
 SELECT (l_orderkey, o_orderdate, o_custkey, o_totalprice),
 (l_partkey, l_quantity, l_extendedprice, l_shipdate)
 FROM lineitem2 
 LEFT JOIN orders ON l_orderkey = o_orderkey
 ORDER BY o_orderdate
 PRIMARY INDEX (l_orderkey);
 
 create table indx_lineitem
 (
 lshipdate INTEGER
 );

CREATE HASH INDEX line_hidx_6, CHECKSUM=ON 
 (lshipdate) ON indx_lineitem
 BY (l_shipdate)
 ORDER BY VALUES;
 
 create table indx_orders
 (
	o_custkey INTEGER
 );
 
 CREATE HASH INDEX ord_hidx_2 (o_custkey) ON indx_orders
 BY (o_custkey)
 ORDER BY HASH (o_custkey);
 
 Create table indx_orders2
 (
	o_orderdate INTEGER
 );
 
  CREATE HASH INDEX ord_hidx_5 (o_orderdate) ON indx_orders2
 ORDER BY (o_orderdate);
 
 create table indx_lineitem1
 (
	l_shipdate INTEGER
 );
 
 CREATE HASH INDEX line_hidx_4 (l_shipdate) ON indx_lineitem1;

CREATE TABLE t1_hash_index (
 id TBL_INTEGER, 
 emp_name TBL_CHAR50) 
 PRIMARY INDEX(id);
 
 CREATE HASH INDEX tb_index_1 (emp_name) 
 ON t1_hash_index 
 BY (emp_name) 
 ORDER BY HASH (emp_name);

CREATE TABLE parent_tab (
 prime_key INTEGER, 
 column_2 INTEGER, 
 column_3 INTEGER)
 UNIQUE PRIMARY INDEX (prime_key);
 
 
 CREATE TABLE child_tab (
 prime_key INTEGER, 
 for_key INTEGER, 
 column_3 INTEGER,
 FOREIGN KEY (for_key) REFERENCES WITH NO CHECK OPTION
 parent_tab(prime_key));
 
 CREATE TRIGGER UpdateForKey
 AFTER UPDATE OF prime_key ON parent_tab
 REFERENCING OLD TABLE AS OldTable NEW TABLE AS NewTable
 FOR EACH STATEMENT (
 UPDATE child_tab
 SET for_key=NewTable.prime_key
 WHERE child_tab.for_key=OldTable.prime_key;);
 
 CREATE TRIGGER DelForKey
 AFTER DELETE ON parent_tab
 REFERENCING OLD TABLE AS OldTable
 FOR EACH STATEMENT (
 UPDATE child_tab
 SET for_key=NULL
 WHERE for_key=OldTable.prime_key;);
 
 CREATE TABLE employee (
 name CHARACTER(30), 
 dept_Id INTEGER, 
 salary DECIMAL(10,2), 
 comments CHARACTER(30));
 
 CREATE TABLE salary_log (
 user_name CHARACTER(30), 
 emp_name CHARACTER(30), 
 old_salary DECIMAL(10,2), 
 new_salary DECIMAL(10,2));
 
 CREATE TRIGGER RaiseTrig
 AFTER UPDATE OF salary ON employee
 REFERENCING OLD AS OldRow NEW AS NewRow
 FOR EACH ROW
 WHEN ((NewRow.salary-OldRow.salary)/OldRow.salary > 10)
 INSERT INTO salary_log
 VALUES ('USER', NewRow.name, OldRow.salary, NewRow.salary);
 
 CREATE TABLE subject_table (
 entry_date DATE, 
 amount INTEGER);
 
 CREATE TRIGGER set_trig
 BEFORE INSERT ON subject_table 
 REFERENCING NEW AS curr_value 
 FOR EACH ROW 
 SET curr_value.entry_date = DATE;
 
 CREATE TABLE tab1 (
 a INTEGER, 
 b INTEGER, 
 c INTEGER);
 CREATE TABLE tab2 (
 d INTEGER, 
 e INTEGER, 
 f INTEGER);
 
 CREATE TABLE tab3 (
 g INTEGER, 
 h INTEGER, 
 i INTEGER);
 
 CREATE TRIGGER trig1
 AFTER INSERT ON tab1
 REFERENCING NEW AS NewRow
 FOR EACH ROW (
 INSERT INTO tab2
 VALUES (NewRow.a + 10, NewRow.b + 10, NewRow.c););
 
 CREATE TRIGGER trig2
 AFTER INSERT ON tab2
 REFERENCING NEW AS NewRow
 FOR EACH ROW (
 INSERT INTO tab3
 VALUES (NewRow.d + 100, NewRow.e + 100, NewRow.f););
 
 create table t11
 (
	a INTEGER
 );
 
 CREATE TRIGGER TrigWhen
 AFTER INSERT ON t11
 REFERENCING NEW AS NewRow
 FOR EACH ROW
 WHEN (10 > (
 SELECT SUM(b) 
 FROM t2 
 WHERE t2.c < 5))
 ABORT;
 
 CREATE TRIGGER trigwhen2
 AFTER INSERT ON t11
 REFERENCING NEW_TABLE AS NewTab
 FOR EACH STATEMENT
 WHEN (10 < MAX(NewTab.a))
 ABORT;
 
  CREATE TRIGGER trigwhen4
 AFTER INSERT ON t11
 REFERENCING NEW AS NewRow
 FOR EACH ROW
 WHEN (t2.a > (
 SELECT b 
 FROM t2 
 WHERE t2.c < 5))
 ABORT;
 
 create table inventory
 (
	col1 INTEGER
 );
 
 CREATE TRIGGER inventory_trigger 
 AFTER UPDATE ON inventory
 REFERENCING OLD_NEW_TABLE AS OldNewTab (OldValue, NewValue) 
 (INSERT INTO InventoryLogTbl 
 SELECT OldValue.ProductKey, 
OldValue.AvailQty, NewValue.AvailQty 
 FROM OldNewTab;);
 
 CREATE TRIGGER inventory_trigger AFTER UPDATE ON inventory
 REFERENCING OLD_TABLE AS OldTab 
 NEW_TABLE AS NewTab
 (INSERT INTO InventoryLogTbl 
 SELECT OldTab.ProductKey, 
OldTab.AvailQty, NewTab.AvailQty 
 FROM OldTab, NewTab 
 WHERE OldTab.ProductKey = NewTab.ProductKey;);
 
 CREATE TABLE document_table (
 docnum INTEGER, 
 document BLOB)
 UNIQUE PRIMARY INDEX(docnum);
 CREATE TABLE document_journal_table (
 docnum INTEGER, 
 action CHARARACTER(1))
 UNIQUE PRIMARY INDEX(docnum);
 
 CREATE TRIGGER log_inserts_to_doc AFTER INSERT ON document_table
 REFERENCING new AS new_row
 FOR EACH ROW
 BEGIN ATOMIC
 CALL insert_doc_journal( new_row.docnum );
 END;
 

CREATE TABLE trg_udf007_04 (
 a INTEGER, 
 b FLOAT);
 CREATE TABLE trg_udf007_03 (
 a INTEGER, 
 b FLOAT);
 CREATE TABLE trg_udf007_01 (
 a INTEGER, 
 b FLOAT);
 
 CREATE TRIGGER trg_udf007_01_trigger
 AFTER INSERT ON trg_udf007_03 
 REFERENCING NEW AS cur
 FOR EACH ROW
 WHEN ( 11 > first1err(cur.a, cur.b))
 (INSERT INTO trg_udf007_04 (cur.a, cur.b); 
 );


create table customer11
(
	col1 INTEGER
);

CREATE TRIGGER CA_Mailing_list 
 AFTER INSERT ON customer11
 REFERENCING NEW AS NewRow
 FOR EACH ROW
 WHEN (NewRow.address.state() = 'CA')
 INSERT INTO MailingAddresses 
 VALUES (NewRow.Name.Last(), 
NewRow.Name.First(), NewRow.address);


create table Employee11
(
	col1 a
);

 CREATE TRIGGER DefaultEmployeeAddress 
 BEFORE INSERT ON Employee11
 REFERENCING NEW AS NewRow
 FOR EACH ROW
 WHEN (NewRow.address IS NULL)
 SET NewRow.address =
 address().street('17095 Via Del Campo').zip('92127');
 
 create table Source_DynTriggerTest2
 (
	colq INTEGER
 );
 
 CREATE TRIGGER Dyn_TestTrigger02
 AFTER INSERT ON Source_DynTriggerTest2
 REFERENCING NEW AS NewRow
 FOR EACH ROW
 WHEN (scalar001dynRtnint_1p(NEW VARIANT_TYPE(NewRow.a AS a,
 NewRow.b AS b))<8)
 INSERT INTO Target_DynTriggerTest2
 VALUES(1,NewRow.a,NewRow.b);
 
 create table nopi008_t1
 (
	colg INTEGER
 );
 
 CREATE TRIGGER nopi008_trig4 
 AFTER UPDATE ON nopi008_t1
 REFERENCING OLD_TABLE AS myold 
 FOR EACH STATEMENT (
 INSERT INTO nopi008_t999(a,b) 
 SELECT a,b 
 FROM myold;);
 
 CREATE table t111
 (
	colh INTEGER
 );
 
 CREATE TRIGGER trig_insert_after_update
 AFTER UPDATE OF b1 ON t111
 REFERENCING OLD AS OldRow NEW AS NewRow
 FOR EACH ROW
 WHEN (test.common_value_expression(OldRow.a1, NewRow.b1) >10)
 INSERT INTO t2
 VALUES (NewRow.a1, NewRow.b1, NewRow.c1);
 
 CREATE TABLE t1111
 (
	colt INTEGER
 );
 
 CREATE TRIGGER trig_insert 
 AFTER INSERT ON t1111
 REFERENCING NEW AS n
 FOR EACH ROW (
 INSERT INTO t2 
 VALUES (n.a1, test.common_value_expression(n.b2, 1), n.c1); );
 
CREATE AUTHORIZATION sales_processing 
AS DEFINER TRUSTED
USER 'salesmng'
PASSWORD 'mysecret';

CREATE AUTHORIZATION Auth_S3_USR_IVO
USER 'service-account-name@project-id.iam.gserviceaccount.com'
PASSWORD '-----BEGIN PRIVATE KEY-----\n
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCyfg3398iOxjt...almSAvk9SqPoyZ
R7JJFs=\n
-----END PRIVATE KEY-----\n'; 
CREATE AUTHORIZATION MyAuthObj
USER ''
PASSWORD '';

DROP TABLE order_ids;

DROP FOREIGN TABLE MyDB.table1;

DROP ERROR TABLE
  database_name.error_table_name;

DROP ERROR TABLE
  FOR database_name.data_table_name;
  
 DROP VIEW dept300; 
 
 DROP JOIN INDEX ji_emp;
 
 DROP HASH INDEX OrdHIdx_1;
 
 DROP AUTHORIZATION sales;
 
 DROP PROCEDURE get_region_xsp;
 
 Drop Macro db.macname ;
 
 DROP FUNCTION MAPPING appl_view_db.glm;
 
 DROP TYPE SYSUDTLIB.employee;
 
 DROP DATABASE accounting;
 
 DROP USER user_1;
 
 DROP CONSTRAINT levels;

DROP TRIGGER parent_tab;

DROP INDEX index_1 ON table_5;

DROP INDEX (name) ON Employee;

DROP INDEX (column_1, column_2) ON table_6;

DROP FUNCTION udf2 (INTEGER, INTEGER);
 DROP SPECIFIC FUNCTION specific_udf2;

DROP SPECIFIC FUNCTION fpm1;
 DROP FUNCTION Finger_print_Match(VARBYTE, VARBYTE);

DROP SPECIFIC FUNCTION testi_opt1;
 DROP FUNCTION test_image(VARCHAR, INTEGER);
 
 DROP FUNCTION test_image();

DROP Avro SCHEMA chemDatasetSchema;

DROP ROLE temp_admin;

DROP EXTERNAL ROLE rhh;

HELP COLUMN table_1.column_2;

HELP COLUMN column_name 
 FROM table_name;
 HELP COLUMN table_name.column_name;
 
 HELP COLUMN * FROM table_name;
 HELP COLUMN table_name.*;


HELP COLUMN employee.name, employee.dept_no, department.dept_no 
 FROM employee, department;

HELP COLUMN table_1.*;

HELP COLUMN 1+10, 10.1+1, 'asdf'||'asd1';

HELP COLUMN d.*, transaction_detail.*;

HELP COLUMN 1+1, d.*;

HELP COLUMN t1.distinct_column;

HELP COLUMN employee.jobduration;

HELP COLUMN department.depttran;
 HELP COLUMN department.dept_tran;
 
 HELP COLUMN department.dept_no;
 HELP COLUMN department.dept_no;
 
 HELP COLUMN MyTable.c;
 
 HELP CONSTRAINT table_1.check_1; 
 
 HELP CONSTRAINT temporal.tab1.vtuniq1;
 
HELP TABLE personnel.department;

HELP TABLE t1;

DELETE FROM employee
 WHERE deptno=500;
 
 DELETE FROM employee ALL;

DELETE FROM employee
 WHERE empno=10011;
 
 DELETE FROM employee
 WHERE employee.deptno = department.deptno
 AND department.location = 'NYC';


 DELETE FROM employee AS managers
 WHERE managers.deptno = employee.deptno
 AND managers.jobtitle IN ('Manager', 'Vice Pres')
 AND employee.yrsexp > managers.yrsexp;

DELETE employee
 FROM department AS d, employee
 WHERE employee.dept_no = d.dept_no
 AND salary_pool < 50000;
 
 DELETE FROM employee
 WHERE dept_no IN (SELECT dept_no
 FROM department
 WHERE salary_pool < 50000);
 
 DELETE FROM test_table
 WHERE circle_udt < NEW circle('1,1,9');
 
 DELETE FROM test_table1, test_table2
 WHERE test_table1.mycirc = test_table2.mycirc;

DELETE FROM new_sales
 WHERE item_nbr = 100;
 
 DELETE FROM new_sales;
 
 DELETE WITH ISOLATED LOADING FROM ldi_table1 WHERE a > 10;
 
 INSERT INTO employee (name, empno, deptno, dob, gender, edlev)
 VALUES ('SMITH T', 10021, 700, 460729, 'F', 16);

INSERT INTO promotion (deptnum, empname, yearsexp)
 SELECT deptno, name, yrsexp
 FROM employee
 WHERE yrsexp > 10 ;
 
 INSERT INTO promotion
 SELECT name, deptno, yrsexp
 FROM employee
 WHERE yrsexp > 10 ;
 
 INSERT INTO employee (name, empno, deptno, dob, gender, edlev)
 VALUES ('Orebo B', 10005, 300, 'Nov 17 1957', 'M', 18) ;
 
 INSERT INTO table_1 (column_1, column_2, column_3)
 VALUES (111,111,111);
 INSERT INTO table_1 (column_1, column_2, column_2)
 VALUES (,222,222);

INSERT INTO Orders VALUES (PARTITION, 10, 'A', 599.99,
 DATE '2001-02-07','HIGH', 'Jack', 3,'Invalid insert');
 
 INSERT INTO table7 (col1, col3, col4)
 VALUES (1, DEFAULT(col2), 'bbb');
 
 INSERT INTO table7
 VALUES (1, 2, DEFAULT (col2)+5, 'aaa');
 
 INSERT INTO t
 SELECT *
 FROM s
 LOGGING ERRORS WITH NO LIMIT;
 
 INSERT INTO tab1 VALUES (0, 'LINESTRING(1 1, 2 2, 3 3, 4 4)');
 
 INSERT INTO t1 VALUES (1,2,3 (SELECT d2
 FROM t2
 WHERE a2=t1.a1));
 
 INSERT INTO orders
 SELECT o_orderkey, o_custkey, o_orderstatus, o_totalprice + 10,
 o_ordertsz, o_comment
 FROM orders_staging
 HASH BY o_totalprice;
 
 INSERT INTO orders
 SELECT o_orderkey, o_custkey, o_orderstatus, o_totalprice + 10,
 o_ordertsz, o_comment
 FROM orders_staging
 HASH BY orders_staging.o_totalprice;
 
 UPDATE employee
 SET yrs_exp = 16
 WHERE empno = 10017;

UPDATE employee
 SET salary = salary * 1.1 ALL ;
 
 UPDATE employee
 SET salary = NULL
 WHERE emp_no = 10001 ;
 
 UPDATE e
 FROM employee AS e, department AS d
 SET salary = salary * 1.05
 WHERE e.emp_no = d.emp_no;
 
 UPDATE table_1
 SET column_1 = 1
 WHERE column_1 IN (SELECT column_2
 FROM table_2);
 UPDATE table_1
 SET column_1 = 1
 WHERE table_1.column_1=table_2.column_1;
 
 UPDATE disc
 SET price = price * .85
 WHERE label_no IN (SELECT label_no
 FROM label
 WHERE label_name LIKE '%erstwhile%')
 AND line = 'NEA';
 
 UPDATE disc
 SET price = price * .85
 WHERE disc.label_no = label.label_no
 AND label_name LIKE '%erstwhile%'
 AND line = 'NEA';
 
 UPDATE sales_sum_table AS sst
 SET total_sales = (SELECT SUM(amount)
 FROM sales_table AS s
 WHERE s.day_of_sale BETWEEN sst.period_start 
 AND sst.period_end);
 
 UPDATE sales_sum_table AS sst
 SET total_sales = (SELECT SUM(amount) 
 FROM sales_table AS s
 WHERE s.day_of_sale BETWEEN sst.period_start 
 AND sst.period_end);
 
 UPDATE publisher
 SET pubnum = NULL
 WHERE 0 = (SELECT COUNT(*)
 FROM book, publisher
 WHERE book.pubnum = publisher.pubnum);
 
 UPDATE disc
 SET price = price * .85
 WHERE label_no IN (SELECT label_no
 FROM label
 WHERE label_name LIKE '%erstwhile%')
 AND line = 'NEA';
 
 UPDATE disc
 SET price = price * .85
 WHERE disc.label_no = label.label_no
 AND label_name LIKE '%erstwhile%'
 AND line = 'NEA';
 
 UPDATE employee
 FROM department AS d
 SET salary = salary * 1.05
 WHERE employee.dept_no = d.dept_no
 AND salary_pool > 25000;
 
 UPDATE t1
 SET b1 = test.value_expression(t1.a1, t1.b1)
 WHERE test.value_expression(t1.c1, t1.d1) > 5;
 

 UPDATE sales
 SET itemcount = item_count + 1
 WHERE (item_nbr = 10
 AND sale_date = '05/30/2000')
 ELSE INSERT
 INTO sales (10, '05/30/2000', 1);
 
 CREATE MACRO new_emp1oyee (
 number INTEGER, 
 name VARCHAR(12), 
 dept INTEGER DEFAULT 900, 
 position VARCHAR(12) ,
 sex CHARACTER, 
 dob DATE FORMAT 'MMMbDDbYYYY', 
 edlev BYTEINT ) AS
 (INSERT INTO employee (empno,name,deptno,jobtitle,sex,dob,edlev)
 VALUES (:number, :name, :dept, :position, :sex, :dob, :edlev);
 -- The following select verifies the insert 
 SELECT * 
 FROM employee 
 WHERE empno = :number; );
 
 REPLACE MACRO new_employee(name VARCHAR(12) NOT NULL, 
 street CHARACTER(30), 
 city CHARACTER(20), 
 number INTEGER NOT NULL, 
 dept SMALLINT DEFAULT 999) AS
 (INSERT INTO employee (name, street, city, empno, deptno) 
 VALUES (:name, :street, :city, :number, :dept); 
 UPDATE department 
 SET empcount = empcount + 1 
 WHERE deptno = :dept ;);
 
 CREATE MACRO m (p INTEGER)
AS (SELECT TOP :p x1 
 FROM t1;);
 
 CREATE MACRO personnel.new_employee
 (number (SMALLINT FORMAT '9(5)'), 
 name (VARCHAR(12)), 
 dept (SMALLINT FORMAT '999'), 
 position (VARCHAR(12)), 
 birthdate (DATE FORMAT 'MMMbDDbYYYY'), 
 sex (CHARACTER(1)), 
 education (BYTEINT)) AS
 (ABORT 'Department 300 not valid' 
 WHERE :dept = 300;
 INSERT INTO employee (empno,name,deptno,jobtitle,dob,sex,edlev)
 VALUES (:number,:name,:dept,:position,:birthdate,:sex,:education); );
 
  CREATE TYPE address AS (
 street VARCHAR(20), 
 zip CHARACTER(5) ) 
 NOT FINAL
 CONSTRUCTOR METHOD address( VARCHAR(20), CHARACTER(5) ) 
 RETURNS address
 SPECIFIC address_constructor_1
 SELF AS RESULT
 LANGUAGE C
 PARAMETER STYLE SQL
 DETERMINISTIC
 NO SQL,
 INSTANCE METHOD city() 
 RETURNS VARCHAR(20)
 LANGUAGE C
 PARAMETER STYLE SQL
 DETERMINISTIC
 NO SQL,
 METHOD state() 
 RETURNS CHARACTER(2) 
 SPECIFIC address_state
 RETURNS NULL ON NULL INPUT
 LANGUAGE C
 PARAMETER STYLE SQL
 DETERMINISTIC
 NO SQL,
 METHOD in_state(CHARACTER(2)) 
 RETURNS CHARACTER(1)
 LANGUAGE C
 PARAMETER STYLE SQL
 DETERMINISTIC
 NO SQL;
 
 CREATE TYPE SYSUDTLIB.person AS (
 ssn CHARACTER(11), 
 first_name VARCHAR(20),
 middle_name VARCHAR(20),
 last_name VARCHAR(20),
 domicile address ) 
 NOT FINAL;
 
 CREATE TYPE euro 
 AS DECIMAL(8, 2) 
 FINAL
 METHOD toUS()
 RETURNS us_dollar CAST FROM DECIMAL(8,2)
 LANGUAGE C
 DETERMINISTIC
 NO SQL
 RETURNS NULL ON NULL INPUT;
 
 CREATE TYPE SYSUDTLIB.us_dollar 
 AS DECIMAL(8, 2) 
 FINAL
 METHOD toEuro()
 RETURNS euro CAST FROM DECIMAL(8,2)
 LANGUAGE C
 DETERMINISTIC
 NO SQL
 RETURNS NULL ON NULL INPUT;

 CREATE TYPE phonenumbers_ary AS 
 CHARACTER(10) ARRAY[5] 
 DEFAULT NULL;
 
  CREATE TYPE phonenumbers_ary AS
 VARRAY(5) OF CHARACTER(10) 
 DEFAULT NULL;
 
 CREATE TYPE phonenumbers_ary AS 
 VARRAY(5) OF CHARACTER(10);
 
 CREATE TYPE structudt_ary AS 
 employee ARRAY[20];
 
 CREATE TYPE measures_udt AS (
 amplitude INTEGER,
 phase INTEGER, 
 frequency INTEGER);
 
 CREATE TYPE seismic_cube AS 
 measures_udt ARRAY [1:5][1:7][1:20] 
 DEFAULT NULL;
 
 CREATE TYPE seismic_cube AS 
 measures_udt ARRAY [1:5][1:7][1:20];
 
 CREATE TYPE seismic_cube_2 AS 
 measures_udt ARRAY [5][7][20];
 
 CREATE TYPE seismic_cube_3 AS 
 measures_udt ARRAY [1:5][7][1:20];
 
 CREATE TYPE seismic_cube AS
 VARRAY (1:5)(1:7)(1:20) OF measures_udt 
 DEFAULT NULL;

CREATE TYPE seismic_cube AS
 VARRAY (1:5)(1:7)(1:20) OF measures_udt;
 
 CREATE TYPE seismic_cube_2 AS
 VARRAY (5)(7)(20) measures_udt;
 
 CREATE TYPE seismic_cube_3 AS
 VARRAY (1:5)(7)(1:20) measures_udt;
 
 CREATE TYPE seismic_cube_4 AS
 measures_udt ARRAY [5][7][-10:10];
 
 CREATE TYPE seismic_cube_5 AS
 VARRAY (5)(7)(-10:10) OF measures_udt;
 
 CREATE Avro SCHEMA chemDatasetSchema AS
'{
"namespace": "example.avro",
 "type": "record",
 "name": "User",
 "fields": [
 {"name": "name", "type": "string"},
 {"name": "favorite_number", "type": ["int", "null"]},
 {"name": "favorite_color", "type": ["string", "null"]}
 ]
}';

CREATE Avro SCHEMA chemDatasetSchema AS
'7B226E616D657370616365223A226578616D706C652E6176726F222C2274797065223A227265636
F7264222C226E616D65223A2255736572222C226669656C6473223A5B7B226E616D65223A226E616
D65222C2274797065223A22737472696E67227D2C7B226E616D65223A226661766F726974655F6E7
56D626572222C2274797065223A5B22696E74222C226E756C6C225D7D2C7B226E616D65223A22666
1766F726974655F636F6C6F72222C2274797065223A5B22737472696E67222C226E756C6C225D7D5
D7D';

CREATE CSV SCHEMA Rivers_Schema AS
'{"field_delimiter":"\t",
"field_names":["site_no","location"]}';

CREATE DATABASE finance FROM sysadmin 
 AS PERMANENT = 60000000, 
 SPOOL = 120000000, 
 FALLBACK PROTECTION, 
 AFTER JOURNAL, 
 BEFORE JOURNAL, 
 DEFAULT JOURNAL TABLE = finance.journals, 
 ACCOUNT = 'ACCTG';

CREATE DATABASE personnel FROM administration
 AS PERMANENT = 5000000 BYTES, FALLBACK, BEFORE JOURNAL, 
 DUAL AFTER JOURNAL, DEFAULT JOURNAL TABLE = personnel.fin_copy;
 
 CREATE EXTERNAL ROLE rhh;
 
 
 CREATE USER marks
 FROM finance AS
 PERMANENT = 1000000,
 PASSWORD = finan1,
 SPOOL = 1200000,
 FALLBACK PROTECTION,
 DUAL AFTER JOURNAL,
 DEFAULT JOURNAL TABLE = finance.journals,
 DEFAULT DATABASE = finance,
 STARTUP = 'EXEC setpf;'
 ACCOUNT = '$mfinance','$hfinance';
 
 CREATE USER sls120639 AS
 DEFAULT DATABASE = it_dev,
 PASSWORD = (EXPIRE = 0),
 PERM = 2000000*(HASHAMP()+1),
 SPOOL = 2000000*(HASHAMP()+1),
 TEMPORARY = 2000000*(HASHAMP()+1);
 
 CREATE USER user1 AS
 PASSWORD = (EXPIRE = 0), 
 PERM = 1e9 SKEW = 10 PERCENT;
 
 CREATE USER user1 AS
PASSWORD = (EXPIRE = 0),
PERM = 1e9,
TEMPORARY = 1e9 SKEW = 20 PERCENT;

CREATE USER user1 AS
 PASSWORD = (EXPIRE = 0), 
 PERM = 1e9
 SPOOL = 1e9 SKEW = 20 PERCENT;
 
 CREATE USER user_name
 FROM r_n_d AS
 PERMANENT = 1000000,
 PASSWORD = abbub279,
 SPOOL = 1200000,
 FALLBACK PROTECTION,
 DUAL AFTER JOURNAL,
 DEFAULT JOURNAL TABLE = r_n_d.journals,
 DEFAULT DATABASE = r_n_d,
 STARTUP = 'EXEC setpf;'
 ACCOUNT = '$mr_n_d','$hr_n_d',
 TIME ZONE = 'America Pacific';
 
 CREATE USER TEST_XFORM AS PERM=4E7 PASSWORD=TEST_XFORM TRANSFORM (XMLD_STRUCT2 
= XMLD_STRUCT2INT, JSON CHARACTER SET LATIN = TD_JSON_VARCHAR, JSON CHARACTER 
SET UNICODE = TD_JSON_VARCHAR);

CREATE USER user_name
 AS
 PERMANENT = 1e6, 
 PASSWORD=my_pwd
,
 CONSTRAINT = classfication_level (TopSecret),
 CONSTRAINT = classification_category (UnitedStates);
 CREATE USER pls
 AS
 PERMANENT = 1e6, 
 PASSWORD=secret
,
 CONSTRAINT = classification_level (Secret, Unclassified DEFAULT),
 CONSTRAINT = classification_category (UnitedStates);
 CREATE USER ArnAnderson
 AS
 PERMANENT = 1e6, 
 PASSWORD=hidden
,
 CONSTRAINT = classification_category (Norway);
 
 CREATE USER sally_jones
 AS 
 PERMANENT = 1E6, 
 PASSWORD=Sal3446Jones
,
 CONSTRAINT = group_membership (clerk),
 DEFAULT ROLE=personnel_clerk;
 
 CREATE USER big_guy
 AS 
 PERMANENT = 1E6, 
 PASSWORD=Big9999Guy
,
 CONSTRAINT = group_membership (executive),
 DEFAULT ROLE=exec_role;
 
 CREATE USER al_manager
 AS 
 PERMANENT = 1E6, 
 PASSWORD=Al9999Manager
,
 CONSTRAINT = group_membership (manager),
 DEFAULT ROLE=mgr_role;
 
 CREATE USER tom_smith
 AS 
 PERMANENT = 1E6, 
 PASSWORD=Tom1111Smith
 ,
 CONSTRAINT = group_membership (executive),
 DEFAULT ROLE=peon;
 
 CREATE USER sally_jones
 AS 
 PERMANENT = 1E6, 
 PASSWORD=Sal3446Jones
,
 CONSTRAINT = group_membership (clerk),
 DEFAULT ROLE=personnel_clerk;
 
 CREATE USER big_guy
 AS 
 PERMANENT = 1E6, 
 PASSWORD=Big9999Guy
,
 CONSTRAINT = group_membership (executive),
 DEFAULT ROLE=exec_role;
 
 CREATE USER al_manager
 AS 
 PERMANENT = 1E6, 
 PASSWORD=Al9999Manager
,
 CONSTRAINT = group_membership (manager),
 DEFAULT ROLE=mgr_role;
 
 CREATE USER tom_smith
 AS 
 PERMANENT = 1E6, 
 PASSWORD=Tom1111Smith
 ,
 CONSTRAINT = group_membership (executive),
 DEFAULT ROLE=staff;
 
 CREATE USER fc1
 FROM r_n_d AS
 PERMANENT = 1000000,
 PASSWORD = bub279,
 SPOOL = 2200000,
 FALLBACK PROTECTION,
 DUAL AFTER JOURNAL,
 DEFAULT JOURNAL TABLE = r_n_d.journals,
 DEFAULT DATABASE = r_n_d,
 STARTUP = 'EXEC setpf;'
 ACCOUNT = '$mr_n_d','$hr_n_d',
 TIME ZONE = 'Africa Egypt'
 EXPORTWIDTH = EXPECTED;

 
 CREATE FUNCTION MAPPING myDatabase.myFunctionMapping
  FOR otherDatabase.myFunction
  SERVER myServer
  EXTERNAL SECURITY DEFINER TRUSTED myAuthorization
  MAP JSON ('{"key": "value"}')
  STOREDAS ('TEXTFILE')
  USING table1, table2;
  
  
  //Alter table commands 
//ALTER FOREIGN TABLE ParquetTab1 ADD GageHeight FLOAT;

//ALTER FOREIGN TABLE JSONTab1
//ADD Payload JSON(8388096) INLINE LENGTH 32000 CHARACTER SET UNICODE;

//ALTER FOREIGN TABLE ParquetTab1 DROP GageHeight;

ALTER TABLE sales TO CURRENT;

ALTER TABLE customer TO CURRENT WITH DELETE;

// Alter procedure commands

ALTER PROCEDURE spAP2 
     COMPILE WITH NO SPL, NO WARNING;


 ALTER PROCEDURE my_xsp LANGUAGE C COMPILE;
 
ALTER PROCEDURE spa_tz  LANGUAGE SQL COMPILE AT TIME ZONE 'gmt';

ALTER PROCEDURE spAP3 COMPILE WITH NO WARNING;

//Alter Function  commands 

ALTER FUNCTION TransXML EXECUTE NOT PROTECTED;


ALTER FUNCTION XPathValue COMPILE;

ALTER FUNCTION XPathValue EXECUTE NOT PROTECTED;


//alter type commands

ALTER TYPE address      /* Drop attribute of structured type */
DROP ATTRIBUTE country;

ALTER TYPE euro   /* Add original method */
 ADD INSTANCE METHOD toYen() 
 RETURNS yen
 LANGUAGE C
 PARAMETER STYLE SQL
 DETERMINISTIC
 NO SQL;

 ALTER TYPE phonenumbers_ary COMPILE;
 
 ALTER TYPE address      /* Add 3 attributes to structured type */
 ADD ATTRIBUTE country   VARCHAR(15), 
               continent VARCHAR(20), 
               zone      INTEGER;
			   
create table table_1(id tbl_integer);

 ALTER TABLE table_1
      ADD CONSTRAINT dup_constr_name
      FOREIGN KEY (id) REFERENCES table_2 (id);
	  
CREATE CONSTRAINT classification_level SMALLINT, NOT NULL,
		VALUES (top_secret:4, secret:3, confidential:2, unclassified:1), 
		INSERT SYSLIB.insert_level,
		UPDATE SYSLIB.update_level,
		DELETE SYSLIB.delete_level,
		SELECT SYSLIB.read_level;

ALTER CONSTRAINT classification_level
AS FUNCTION ADD DELETE SYSLIB.deletelevel;

RENAME TABLE emp TO employee;

RENAME VIEW staff_info TO staff_information;

RENAME PROCEDURE get_region_xsp TO emp;


RENAME SPECIFIC FUNCTION match_text TO scan_text;
RENAME FUNCTION imagine_numbers(FLOAT, FLOAT) TO imaginary;

RENAME TRIGGER parent_tab TO parent_table;

HELP VOLATILE TABLE sales_temp;

HELP VIEW udt_view;

HELP INDEX tname (cname_1, cname_2, cname_3);

HELP JOIN INDEX ord_cust_idx;

HELP PROCEDURE pa.sp1new ATTRIBUTES;

HELP MACRO SYSUDTLB.Example;

HELP FUNCTION  SYSUDTLIB.AdhocIntToSQL;

HELP TYPE mydistinct;

HELP USER  user_name ;

HELP TRIGGER UpdateForKey;

SHOW TABLE personnel.emp_bonus;

SHOW FUNCTION MAPPING appl_view_db.Interpolator;

SET SESSION CONSTRAINT = classification_level (top_secret), 
CONSTRAINT = classification_category  (nato, united_states);

SET SESSION DATABASE accounting;

SET SESSION FOR NO ISOLATED LOADING;

MODIFY USER sls120639 AS
DEFAULT DATABASE = it_dev,
PASSWORD = (EXPIRE = 0),
PERM = 3000000*(HASHAMP()+1),
SPOOL = 3000000*(HASHAMP()+1),
TEMPORARY = 3000000*(HASHAMP()+1); 


DELETE DATABASE used_cars;

DELETE USER user_name;

DATABASE personnel;

COMMENT ON COLUMN employee.name 
IS 'Employee name, last name followed by first initial';


CREATE CONSTRUCTOR METHOD address( VARCHAR(20), CHARACTER(5) )
      RETURNS address
      FOR address
      EXTERNAL NAME 
       'SO!C:\structured_lib\addr_cons.obj!F!addr_constructor';
	   
CREATE CAST (euro AS VARCHAR(20))
WITH METHOD SYSUDTLIB.euroString( ) FOR euro
AS ASSIGNMENT
	   
CREATE ORDERING FOR rectangle
    ORDER FULL BY MAP WITH FUNCTION compare_rect();

CREATE PROFILE research_and_development AS
DEFAULT DATABASE = it_dev,
PASSWORD = (EXPIRE = 0),
SPOOL = 2000000*(HASHAMP()+1);


CREATE MAP Small_Table_Map FROM TD_Map1 SPARSE AMPCOUNT=4;

CREATE ZONE zn_01 ROOT z_root01;

ALTER METHOD polygon_mbr() FOR SYSUDTLIB.polygon
EXECUTE NOT PROTECTED;

ALTER SPECIFIC METHOD SYSUDTLIB.polygon_mbr COMPILE;

ALTER ZONE zn_01 DROP ROOT;

ALTER ZONE zn_01 ADD ROOT zn_rt01;

DROP GLOP SET  user_name.UDF_glop_1;

DROP CAST (circle AS ellipse);

DROP ORDERING FOR circle;

DROP TRANSFORM c_routine FOR SYSUDTLIB.address;

DROP PROFILE finance;

DROP ZONE zn_01;

DROP MAP SmallTableMap;

DROP STATISTICS INDEX (column_1,column_2) ON table_1;

DROP STATISTICS INDEX unique_1 ON table_1;

HELP SPECIFIC METHOD SYSUDTLIB.polygon_mbr;

HELP METHOD int_ordering FOR udt_int;

HELP Avro SCHEMA chemDatasetSchema;

HELP TRANSFORM address;

HELP DATABASE personnel;

HELP SESSION CONSTRAINT;

HELP CAST SYSUDTLIB.euro TARGET;

HELP STATISTICS personnel.employee;

HELP STATISTICS personnel.employee FROM my_qcd;

SHOW QUERY LOGGING ON ALL;

SHOW STATISTICS VALUES SEQUENCED COLUMN x1, COLUMN y1 ON table_1;

SHOW SELECT * FROM View_1, Table_2 WHERE View1.column_1=Table2.column_3;

REPLACE SPECIFIC METHOD SYSUDTLIB.polygon_mbr
  EXTERNAL 'fd' ;
  
SET TRANSFORM GROUP FOR TYPE JSON CHARACTER SET LATIN TD_JSON_VARCHAR;

SET TIME ZONE USER;
SET TIME ZONE INTERVAL '08:00' HOUR TO MINUTE;
SET TIME ZONE +1;

SET SESSION UDFSEARCHPATH = functions, SYSLIB, TD_SYSFNLIB FOR FUNCTION = bitor;

SET SESSION ACCOUNT='$M0+FIN1&S&D&H' FOR SESSION ;

SET SESSION CALENDAR=ISO;

SET SESSION CHARACTER SET UNICODE PASS THROUGH ON;

SET QUERY_BAND = 'org=Finance;report=Fin123;' FOR SESSION;

SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ
UNCOMMITTED;

SET SESSION SEARCHUIFDBPATH = DB1, DB2;

SET SESSION JSON IGNORE ERRORS ON;

SET SESSION FOR ISOLATED LOADING;

SET SESSION DOT NOTATION DEFAULT ON ERROR;

SET SESSION DEBUG FUNCTION  function_name  OFF;

SET SESSION DATEFORM = ANSIDATE;

SET SESSION DATABASE accounting;

SET SESSION COLLATION ASCII;

MODIFY PROFILE finance AS SPOOL = 1000000;

MODIFY USER brewster AS PROFILE = finance;

LOGGING INCREMENTAL ARCHIVE OFF FOR MyDB;

LOGGING INCREMENTAL ARCHIVE ON FOR MyDB DELETE LOG ROWS;

INCREMENTAL RESTORE ALLOW WRITE FOR tab1;

BEGIN ISOLATED LOADING ON ldi_table1, ldi_table2 USING QUERY_BAND 'LDILoadGroup=Grp1;' IN MULTIPLE SESSION;

SET QUERY_BAND= 'LDILoadGroup=NONE;' FOR SESSION;

CHECKPOINT ISOLATED LOADING FOR QUERY_BAND 'LDILoadGroup=Grp1;';

END ISOLATED LOADING FOR QUERY_BAND 'LDILoadGroup=Grp1;';

BEGIN LOGGING DENIALS ON EACH OVERRIDE DUMP CONSTRAINT FOR CONSTRAINT levels;

BEGIN LOGGING WITH TEXT ON EACH USER, DATABASE, GRANT;

BEGIN QUERY CAPTURE AS workload wl_2;

BEGIN QUERY LOGGING WITH USECOUNT ON ALL;

FLUSH QUERY LOGGING WITH ALL;

END LOGGING DENIALS WITH TEXT ON UDTTYPE;

END QUERY LOGGING ON ALL RULES;

END QUERY LOGGING ON user_1 ACCOUNT = ('order_entry');

CREATE TABLE test_weight_null (
    weight_grams INTEGER,
    CONSTRAINT chk_weight CHECK (weight_grams IS NOT NULL OR weight_grams >= 0)
);

CREATE TABLE test_weight_not_null (
    weight_grams INTEGER NOT NULL,
    CONSTRAINT chk_weight CHECK (weight_grams >= 0)
);

ALTER TABLE test_weight_null
ADD CONSTRAINT chk_weight_null
CHECK (weight_grams IS NULL OR weight_grams >= 0);

ALTER TABLE test_weight_not_null
ADD CONSTRAINT chk_weight_not_null
CHECK (weight_grams >= 0);