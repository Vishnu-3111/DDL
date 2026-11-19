CREATE TEMPORARY TABLE new_tbl SELECT * FROM orig_tbl LIMIT 0;

Create Table orig_tbl
(
	Col1 INT,
	COL2 INT

);

CREATE TABLE new_tbl1 LIKE orig_tbl;

CREATE TABLE test (a INT NOT NULL AUTO_INCREMENT,
PRIMARY KEY (a), KEY(b))
ENGINE=InnoDB SELECT b,c FROM test2;

CREATE TABLE bar1 (m INT) SELECT n FROM foo;

CREATE TABLE tv1
SELECT * FROM (VALUES ROW(1,3,5), ROW(2,4,6)) AS v;

CREATE TABLE tv2
SELECT * FROM (VALUES ROW(1,3,5), ROW(2,4,6)) AS v(x,y,z);
	 
CREATE TABLE tv3 (a INT, b INT, c INT)
SELECT * FROM (VALUES ROW(1,3,5), ROW(2,4,6)) AS v(x,y,z);

CREATE TABLE tv4 (a INT, b INT, c INT)
SELECT * FROM (VALUES ROW(1,3,5), ROW(2,4,6)) AS v(x,y,z);

CREATE TABLE tv5 (a INT, b INT, c INT)
SELECT * FROM (VALUES ROW(1,3,5), ROW(2,4,6)) AS v(a,b,c);

CREATE TABLE tvx1
    SELECT (x,z) FROM (VALUES ROW(1,3,5), ROW(2,4,6)) AS v(x,y,z);
	
CREATE TABLE tvx2 (a INT, c INT)
    SELECT (x,z) FROM (VALUES ROW(1,3,5), ROW(2,4,6)) AS v(x,y,z);
	
CREATE TABLE bar2 (UNIQUE (n)) SELECT n FROM foo;

CREATE TABLE artists_and_works
  SELECT artist.name, COUNT(work.artist_id) AS number_of_works
  FROM artist LEFT JOIN work ON artist.id = work.artist_id
  GROUP BY artist.id;
  
CREATE TABLE foo (a TINYINT NOT NULL) SELECT b+1 AS a FROM bar;

CREATE TABLE parent (
    id INT NOT NULL,
    PRIMARY KEY (id)
) ENGINE=INNODB;

CREATE TABLE child (
    id INT,
    parent_id INT,
    INDEX par_ind (parent_id),
    FOREIGN KEY (parent_id)
        REFERENCES parent(id)
        ON DELETE CASCADE
) ENGINE=INNODB;


CREATE TABLE product (
    category INT NOT NULL, id INT NOT NULL,
    price DECIMAL,
    PRIMARY KEY(category, id)
)   ENGINE=INNODB;

CREATE TABLE customer (
    id INT NOT NULL,
    PRIMARY KEY (id)
)   ENGINE=INNODB;

CREATE TABLE product_order (
    no INT NOT NULL AUTO_INCREMENT,
    product_category INT NOT NULL,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,

    PRIMARY KEY(no),
    INDEX (product_category, product_id),
    INDEX (customer_id),

    FOREIGN KEY (product_category, product_id)
      REFERENCES product(category, id)
      ON UPDATE CASCADE ON DELETE RESTRICT,

    FOREIGN KEY (customer_id)
      REFERENCES customer(id)
)   ENGINE=INNODB;

CREATE TABLE t111
(
  CHECK (c1 <> c2),
  c1 INT CHECK (c1 > 10),
  c2 INT CONSTRAINT c2_positive CHECK (c2 > 0),
  c3 INT CHECK (c3 < 100),
  CONSTRAINT c1_nonzero CHECK (c1 <> 0),
  CHECK (c1 > c3)
);


CREATE TABLE tl1
(
  c1 VARCHAR(10) CHARACTER SET binary,
  c2 TEXT CHARACTER SET binary,
  c3 ENUM('a','b','c') CHARACTER SET binary
);

CREATE TABLE tl2
(
  c1 VARBINARY(10),
  c2 BLOB,
  c3 ENUM('a','b','c') CHARACTER SET binary
);

CREATE TABLE triangle (
  sidea DOUBLE,
  sideb DOUBLE,
  sidec DOUBLE AS (SQRT(sidea * sidea + sideb * sideb))
);

CREATE TABLE tl3 (
  first_name VARCHAR(10),
  last_name VARCHAR(10),
  full_name VARCHAR(255) AS (CONCAT(first_name,' ',last_name))
);

CREATE TABLE jemp (
	c JSON,
	 g INT GENERATED ALWAYS AS (c->"$.id"),
	INDEX i (g)
);

CREATE TABLE jempn (
  a BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  c JSON DEFAULT NULL,
  g INT GENERATED ALWAYS AS (c->"$.id") STORED,
  INDEX i (g)
) ENGINE=NDB;

CREATE TABLE tli1 (
  i INT,
  j DATE INVISIBLE
) ENGINE = InnoDB;

CREATE TABLE tli2 (col1 INT, col2 INT INVISIBLE);
CREATE TABLE tli3 AS SELECT col1, col2 FROM t1;

CREATE TABLE tlc1 (
 a INT NOT NULL PRIMARY KEY,
b1 BLOB,
 b2 BLOB COMMENT 'NDB_COLUMN=BLOB_INLINE_SIZE=8000'
 ) ENGINE NDB;
 
 CREATE TABLE tlc2 (
   c1 INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  c2 VARCHAR(100),
  c3 VARCHAR(100) )
   ENGINE=NDB
COMMENT="NDB_TABLE=READ_BACKUP=0,PARTITION_BALANCE=FOR_RP_BY_NODE";

CREATE TABLE customer_ix (name INT);

CREATE INDEX part_of_name ON customer_ix (name(10));

CREATE TABLE ti1 (
  col1 VARCHAR(10),
  col2 VARCHAR(20),
  INDEX (col1, col2(10))
);

CREATE TABLE t1ix (col1 INT, col2 INT, INDEX func_index (col1));
CREATE INDEX idx1 ON t1ix ((col1 + col2));

CREATE TABLE tbixl (
  col1 LONGTEXT,
  INDEX idx1 ((SUBSTRING(col1, 1, 10)))
);

CREATE TABLE employees1 (
  data JSON,
  INDEX ((data->>'$.name'))
);

CREATE TABLE employees2 (
  data JSON,
  INDEX ((CAST(data->>'$.name' AS CHAR(30))))
);

/* CREATE TABLE employees3 (
  data JSON,
  INDEX idx ((CAST(data->>"$.name" AS CHAR(30)) COLLATE utf8mb4_bin))
); */

CREATE TABLE employees4 (
  data JSON,
  INDEX idx ((CAST(data->>"$.name" AS CHAR(30))))
);

CREATE TABLE employees5 (
         data JSON,
         generated_col VARCHAR(30) AS (CAST(data->>'$.name' AS CHAR(30)))
       );
	   
CREATE TABLE customers1 (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    custinfo JSON,
    INDEX zips( (CAST(custinfo->'$.zipcode' AS UNSIGNED ARRAY)) )
    );
	
CREATE TABLE customers2 (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    custinfo JSON
    );
	
CREATE TABLE customers3 (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    custinfo JSON
    );
	
CREATE INDEX zips ON customers3 ( (CAST(custinfo->'$.zipcode' AS UNSIGNED ARRAY)) );

CREATE TABLE customers4 (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    custinfo JSON
    );


CREATE TABLE lookup (id INT) ENGINE = MEMORY;
CREATE INDEX id_index ON lookup (id) USING BTREE;

CREATE TABLE tix1 (id INT , c1 INT);
CREATE INDEX id_index ON tix1 (id) COMMENT 'MERGE_THRESHOLD=40';

CREATE INDEX i1 ON tix1 (c1) ENGINE_ATTRIBUTE='{"key":"value"}';

CREATE TABLE account (acct_num INT, amount DECIMAL(10,2));

CREATE TRIGGER upd_check BEFORE UPDATE ON account
       FOR EACH ROW
       BEGIN
           IF NEW.amount < 0 THEN
               SET NEW.amount = 0;
           ELSEIF NEW.amount > 100 THEN
               SET NEW.amount = 100;
           END IF;
       END;
	   
CREATE TABLE test1(a1 INT);

CREATE TABLE test2(a2 INT);

CREATE TABLE test3(a3 INT NOT NULL AUTO_INCREMENT PRIMARY KEY);

CREATE TABLE test4(
  a4 INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  b4 INT DEFAULT 0
);

CREATE TRIGGER testref BEFORE INSERT ON test1
  FOR EACH ROW
  BEGIN
    INSERT INTO test2 SET a2 = NEW.a1;
    DELETE FROM test3 WHERE a3 = NEW.a1;
    UPDATE test4 SET b4 = b4 + 1 WHERE a4 = NEW.a1;
  END;
  
CREATE VIEW test.v1 AS SELECT * FROM t;

CREATE VIEW v2 AS SELECT qty, price, qty*price AS value FROM t;

CREATE VIEW v3 AS SELECT * FROM t WHERE t.id = f(t.name);

CREATE TABLE t1 (a INT);

CREATE VIEW v3 AS SELECT * FROM t1 WHERE a < 2
WITH CHECK OPTION;

CREATE VIEW v4 AS SELECT * FROM v1 WHERE a > 0
WITH LOCAL CHECK OPTION;

CREATE VIEW v5 AS SELECT * FROM v1 WHERE a > 0
WITH CASCADED CHECK OPTION;

CREATE VIEW v6 AS SELECT col1, 1 AS col2 FROM t;

CREATE ALGORITHM = MERGE VIEW v_merge (vc1, vc2) AS
SELECT c1, c2 FROM t WHERE c3 > 100;

/*CREATE FUNCTION hello (s CHAR(20))
RETURNS CHAR(50) DETERMINISTIC
RETURN CONCAT('Hello, ',s,'!');*/

CREATE FUNCTION f1(i INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
  RETURN i;
END;

CREATE FUNCTION f2()
RETURNS CHAR(36) CHARACTER SET utf8mb4
BEGIN
  RETURN UUID();
END;

CREATE FUNCTION f3(p_id INT)
RETURNS INT
BEGIN
  UPDATE t SET modtime = NOW() WHERE id = p_id;
  RETURN ROW_COUNT();
END;

CREATE FUNCTION f4(a INT) RETURNS INT
BEGIN
  IF (a < 3) THEN
    INSERT INTO t2 VALUES (a);
  END IF;
  RETURN 0;
END;

CREATE FUNCTION unsafe_func () RETURNS INT
BEGIN
	IF @@server_id=2 THEN dangerous_statement; END IF;
	RETURN 1;
END;

CREATE PROCEDURE citycount (IN country CHAR(3), OUT cities INT)
       BEGIN
         SELECT COUNT(*) INTO cities FROM world.city
         WHERE CountryCode = country;
       END;
	   
CREATE DEFINER = 'admin'@'localhost' PROCEDURE account_count1()
BEGIN
  SELECT 'Number of accounts:', COUNT(*) FROM mysql.user;
END;

CREATE DEFINER = 'admin'@'localhost' PROCEDURE account_count2()
SQL SECURITY INVOKER
BEGIN
  SELECT 'Number of accounts:', COUNT(*) FROM mysql.user;
END;

CREATE DEFINER = 'admin'@'localhost' PROCEDURE p1()
SQL SECURITY DEFINER
BEGIN
  UPDATE t1 SET counter = counter + 1;
END;

CREATE DEFINER = 'admin'@'localhost' PROCEDURE p2()
SQL SECURITY INVOKER
BEGIN
  UPDATE t1 SET counter = counter + 1;
END;


CREATE TABLE departments (
    department_id INT NOT NULL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100)
);


CREATE TABLE employee_details (
    employee_id INT NOT NULL PRIMARY KEY,
    email VARCHAR(100) UNIQUE,
    age INT CHECK (age >= 18),
    department_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department_id INT,
    department_id INT REFERENCES departments(department_id)
);

ALTER DATABASE mydb READ ONLY = 0 DEFAULT COLLATE utf8mb4_bin;

ALTER FUNCTION calculate_tax 
    READS SQL DATA
    SQL SECURITY INVOKER
    COMMENT 'Calculates tax based on a fixed rate';

ALTER INSTANCE RELOAD TLS FOR CHANNEL mysql_main NO ROLLBACK ON ERROR;

ALTER PROCEDURE update_inventory
    SQL SECURITY INVOKER
    READS SQL DATA
    COMMENT 'Updates or reads the inventory levels for a given product';

ALTER SERVER s OPTIONS (USER 'sally');

ALTER TABLE t1 RENAME t2;

ALTER TABLE t1 RENAME t2;

create table t2;

ALTER TABLE t2 MODIFY a TINYINT NOT NULL, CHANGE b c CHAR(20);

ALTER TABLE t2 ADD d TIMESTAMP;

ALTER TABLE t2 ADD INDEX (d), ADD UNIQUE (a);

ALTER TABLE t2 ADD c INT UNSIGNED NOT NULL AUTO_INCREMENT,
  ADD PRIMARY KEY (c);
  
ALTER TABLE t1 TABLESPACE ts_1 STORAGE DISK;

ALTER TABLE t2 STORAGE DISK;

ALTER TABLE t3 MODIFY c2 INT STORAGE MEMORY;

ALTER TABLE t2 ADD id INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE t2 RENAME t1;

ALTER TABLESPACE ts1 ENGINE_ATTRIBUTE='{"key":"value"}';

ALTER ALGORITHM = MERGE
VIEW product_sales AS
SELECT p.product_name, SUM(o.quantity) AS total_sales
FROM products p
JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_name;

ALTER DEFINER = 'admin_user'@'localhost'
VIEW product_sales AS
SELECT p.product_name, SUM(o.quantity) AS total_sales
FROM products p
JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_name;


ALTER SQL SECURITY INVOKER
VIEW product_sales AS
SELECT p.product_name, SUM(o.quantity) AS total_sales
FROM products p
JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_name;

CREATE DATABASE IF NOT EXISTS ecommerce_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
	
CREATE LOGFILE GROUP lg1  ADD UNDOFILE 'undo.dat' INITIAL_SIZE = 10M;

CREATE LOGFILE GROUP lg1 ADD UNDOFILE 'undo.dat' INITIAL_SIZE = 10M  ENGINE = NDB; 

CREATE SERVER s
FOREIGN DATA WRAPPER mysql
OPTIONS (USER 'Remote', HOST '198.51.100.106', DATABASE 'test');

CREATE SPATIAL REFERENCE SYSTEM 4120
NAME 'Greek'
ORGANIZATION 'EPSG' IDENTIFIED BY 4120
DEFINITION
  'GEOGCS["Greek",DATUM["Greek",SPHEROID["Bessel 1841",
  6377397.155,299.1528128,AUTHORITY["EPSG","7004"]],
  AUTHORITY["EPSG","6120"]],PRIMEM["Greenwich",0,
  AUTHORITY["EPSG","8901"]],UNIT["degree",0.017453292519943278,
  AUTHORITY["EPSG","9122"]],AXIS["Lat",NORTH],AXIS["Lon",EAST],
  AUTHORITY["EPSG","4120"]]';

CREATE UNDO TABLESPACE undo_003 ADD DATAFILE 'undo_003.ibu';

CREATE TABLESPACE `ts2` ADD DATAFILE 'ts2.ibd' FILE_BLOCK_SIZE = 8192 ENGINE=InnoDB;

CREATE TABLESPACE `ts1` ADD DATAFILE 'ts1.ibd' ENGINE=INNODB;

CREATE TABLESPACE myts ADD DATAFILE 'mydata-1.dat' USE LOGFILE GROUP mylg ENGINE=NDB;

DROP DATABASE IF EXISTS old_ecommerce_db;

DROP DATABASE IF EXISTS test_db;

DROP EVENT IF EXISTS daily_cleanup;

DROP PROCEDURE update_inventory;

DROP FUNCTION calculate_tax;

DROP SERVER remote_db_server;

DROP SPATIAL REFERENCE SYSTEM 4326;

DROP TABLE IF EXISTS old_sales_data, temp_orders CASCADE;

DROP UNDO TABLESPACE undo_003;

DROP TRIGGER IF EXISTS sales.before_insert_order;

DROP VIEW IF EXISTS active_customers, monthly_sales;

RENAME TABLE t1 TO t3;

RENAME TABLE customers TO clients, orders TO sales_orders;

TRUNCATE TABLE logs;

CALL p(@version, @increment);

DELETE FROM somelog WHERE user = 'jcole'
ORDER BY timestamp_column LIMIT 1;

DELETE a1, a2 FROM t1 AS a1 INNER JOIN t2 AS a2
WHERE a1.id=a2.id;

DELETE FROM a1, a2 USING t1 AS a1 INNER JOIN t2 AS a2
WHERE a1.id=a2.id;

DELETE t1 FROM t1 LEFT JOIN t2 ON t1.id=t2.id WHERE t2.id IS NULL;

HANDLER employees OPEN AS emp_handler;

HANDLER employees READ idx_emp_id = (12345);

HANDLER employees READ idx_salary >= (50000)
    WHERE department = 'Sales'
    LIMIT 10;
	
HANDLER employees READ idx_hire_date FIRST
    WHERE status = 'Active';
HANDLER employees CLOSE;
	
IMPORT TABLE FROM '/tmp/mysql-files/employees.sdi','/tmp/mysql-files/managers.sdi';
	   
	   
INSERT INTO employees (first_name, last_name, position)
VALUES ('John', 'Doe', 'Software Engineer'),
       ('Jane', 'Smith', 'Data Scientist')
ON DUPLICATE KEY UPDATE position = VALUES(position);

INSERT INTO employees
SET first_name = 'Emily', last_name = 'Brown', position = 'Marketing Manager'
ON DUPLICATE KEY UPDATE position = VALUES(position);

INSERT INTO employees_backup (first_name, last_name, position)
SELECT first_name, last_name, position
FROM employees
WHERE position = 'Software Engineer';

LOAD DATA INFILE '/tmp/test.txt' INTO TABLE test
  FIELDS TERMINATED BY ','  LINES STARTING BY 'xxx';


LOAD DATA INFILE '/tmp/test.txt' INTO TABLE test IGNORE 1 LINES;

LOAD DATA INFILE 'data.txt' INTO TABLE table2
  FIELDS TERMINATED BY ',';
  
LOAD DATA INFILE 'data.txt' INTO TABLE tbl_name
  FIELDS TERMINATED BY ',' ENCLOSED BY '"'
  LINES TERMINATED BY '\r\n'
  IGNORE 1 LINES;
LOAD DATA INFILE '/tmp/jokes.txt' INTO TABLE jokes
  FIELDS TERMINATED BY ''
  LINES TERMINATED BY '\n%%\n' (joke);
  
LOAD XML LOCAL INFILE 'person.xml' INTO TABLE person ROWS IDENTIFIED BY '<person>';

LOAD XML LOCAL INFILE 'person-dump.xml' INTO TABLE person2;

LOAD XML LOCAL INFILE 'person-dump.xml' INTO TABLE person2;
 
LOAD XML INFILE '../bin/person-dump.xml' INTO TABLE test.individual;

LOAD XML INFILE '../bin/person-dump.xml' INTO TABLE test.individual (@person_id, @fname, @lname, @created)
 SET individual_id=@person_id, name1=@fname, name2=@lname, made=@created;
 
LOAD XML LOCAL INFILE 'address.xml' INTO TABLE person  ROWS IDENTIFIED BY '<person>';

LOAD XML LOCAL INFILE 'address.xml' INTO TABLE address   ROWS IDENTIFIED BY '<address>';

REPLACE INTO test VALUES (1, 'Old', '2014-08-20 18:47:00');

REPLACE INTO test2 VALUES (1, 'New', '2014-08-20 18:47:42');

REPLACE INTO employees
SET id = 3, first_name = 'Emily', last_name = 'Brown', position = 'Marketing Manager';

REPLACE INTO employees_archive (id, first_name, last_name, position)
SELECT id, first_name, last_name, position
FROM employees
WHERE position = 'Senior Developer';

REPLACE INTO employees_backup
TABLE employees
WHERE hire_date < '2022-01-01';

TABLE t ORDER BY b LIMIT 3 OFFSET 2;

UPDATE items,
       (SELECT id FROM items
        WHERE retail / wholesale >= 1.3 AND quantity < 100)
        AS discounted
    SET items.retail = items.retail * 0.9
    WHERE items.id = discounted.id;
	
UPDATE items,
       (SELECT id FROM items
        WHERE id IN
            (SELECT id FROM items
             WHERE retail / wholesale >= 1.3 AND quantity < 100))
        AS discounted
SET items.retail = items.retail * 0.9
WHERE items.id = discounted.id;

UPDATE items,
       (SELECT id, retail / wholesale AS markup, quantity FROM items)
       AS discounted
    SET items.retail = items.retail * 0.9
    WHERE discounted.markup >= 1.3
    AND discounted.quantity < 100
    AND items.id = discounted.id;

UPDATE items,month SET items.price=month.price
WHERE items.id=month.id;

VALUES ROW(1,-2,3), ROW(5,7,9), ROW(4,6,8);

VALUES ROW("q", 42, '2019-12-18'), ROW(23, "abc", 98.6),ROW(27.0002, "Mary Smith", '{"a": 10, "b": 25}');

WITH
  cte1 AS (SELECT a, b FROM table1),
  cte2 AS (SELECT c, d FROM table2)
SELECT b, d FROM cte1 JOIN cte2
WHERE cte1.a = cte2.c;

WITH cte (col1, col2) AS
(
  SELECT 1, 2
  UNION ALL
  SELECT 3, 4
)
SELECT col1, col2 FROM cte;


SET autocommit=0;	

START TRANSACTION;

COMMIT;

LOCK INSTANCE FOR BACKUP;

UNLOCK INSTANCE;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

LOCK TABLE t WRITE, t AS t1 READ;

XA START 'xid-12345';
-- or
XA BEGIN 'xid-12345';

XA END 'xid-12345';

XA PREPARE 'xid-12345';

XA COMMIT 'xid-12345';

XA ROLLBACK 'xid-12345';

PURGE BINARY LOGS TO 'mysql-bin.010';

PURGE BINARY LOGS BEFORE '2019-04-02 22:46:26';

RESET BINARY LOGS AND GTIDS TO 1234;

SET sql_log_bin = ON;

CHANGE REPLICATION FILTER
    REPLICATE_DO_DB = (d1), REPLICATE_IGNORE_DB = (d2);
	
CHANGE REPLICATION FILTER REPLICATE_DO_DB = (d1) FOR CHANNEL channel_1;

CHANGE REPLICATION FILTER
    REPLICATE_DO_DB = (db1, db2), REPLICATE_DO_DB = (db3, db4);

CHANGE REPLICATION FILTER
    REPLICATE_DO_DB = (db3, db4);
	
CHANGE REPLICATION FILTER
    REPLICATE_WILD_DO_TABLE = ('db1.old%');

CHANGE REPLICATION FILTER
    REPLICATE_WILD_IGNORE_TABLE = ('db1.new%', 'db2.new%');
	
CHANGE REPLICATION FILTER REPLICATE_REWRITE_DB = ((db1, db2));

CHANGE REPLICATION FILTER
    REPLICATE_DO_DB = (), REPLICATE_IGNORE_DB = ();
	
CHANGE REPLICATION SOURCE TO IGNORE_SERVER_IDS = ();

CHANGE REPLICATION SOURCE TO
    PRIVILEGE_CHECKS_USER = 'user'@'host',
    REQUIRE_ROW_FORMAT = 1,
    FOR CHANNEL 'channel_1';


CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='source3.example.com',
  SOURCE_USER='replication',
  SOURCE_PASSWORD='password',
  SOURCE_PORT=3306,
  SOURCE_AUTO_POSITION = 1,
  FOR CHANNEL "source_3";

CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='source2.example.com',
  SOURCE_USER='replication',
  SOURCE_PASSWORD='password',
  SOURCE_PORT=3306,
  SOURCE_LOG_FILE='source2-bin.001',
  SOURCE_LOG_POS=4,
  SOURCE_CONNECT_RETRY=10;

CHANGE REPLICATION SOURCE TO
  RELAY_LOG_FILE='replica-relay-bin.006',
  RELAY_LOG_POS=4025;


RESET REPLICA FOR CHANNEL 'channel_name';

START REPLICA UNTIL SQL_AFTER_MTS_GAPS;

START REPLICA SQL_THREAD;

START GROUP_REPLICATION USER='repl_user', PASSWORD='secure_pass', DEFAULT_AUTH='mysql_native_password';

PREPARE stmt1 FROM 'SELECT * FROM employees WHERE department_id = ?';

PREPARE stmt2 FROM 'INSERT INTO orders (customer_id, order_date) VALUES (?, ?)';

PREPARE stmt3 FROM 'UPDATE products SET stock = stock - ? WHERE product_id = ?';


EXECUTE stmt3 USING @quantity, @product_id;

ALTER USER USER() IDENTIFIED BY 'auth_string';

ALTER USER 'jeffrey'@'localhost'
  IDENTIFIED BY 'new_password' PASSWORD EXPIRE;
  
  
ALTER USER 'jeffrey'@'localhost'
  IDENTIFIED WITH caching_sha2_password BY 'new_password'
  PASSWORD EXPIRE INTERVAL 180 DAY
  FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 2;

ALTER USER 'jeffrey'@'localhost' ACCOUNT LOCK;
ALTER USER 'jeffrey'@'localhost' ACCOUNT UNLOCK;


ALTER USER 'jeffrey'@'localhost'
  REQUIRE SSL WITH MAX_CONNECTIONS_PER_HOUR 20;

ALTER USER
  'jeffrey'@'localhost'
    IDENTIFIED BY 'jeffrey_new_password',
  'jeanne'@'localhost',
  'josh'@'localhost'
    IDENTIFIED BY 'josh_new_password'
    REPLACE 'josh_current_password'
    RETAIN CURRENT PASSWORD
  REQUIRE SSL WITH MAX_USER_CONNECTIONS 2
  PASSWORD HISTORY 5;

ALTER USER 'josh'@'localhost' DISCARD OLD PASSWORD;

ALTER USER 'jeffrey'@'localhost'
  IDENTIFIED BY 'password';
  
ALTER USER 'jeffrey'@'localhost'
  IDENTIFIED WITH mysql_native_password
             BY 'password';
			
ALTER USER 'jeffrey'@'localhost'
  IDENTIFIED WITH mysql_native_password
             BY 'password'
             REPLACE 'current_password';
			 
ALTER USER 'jeffrey'@'localhost'
  IDENTIFIED WITH mysql_native_password
             AS '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4';
			 
ALTER USER 'jeffrey'@'localhost' REQUIRE NONE;

ALTER USER 'jeffrey'@'localhost' REQUIRE SSL;

ALTER USER 'jeffrey'@'localhost'
  REQUIRE ISSUER '/C=SE/ST=Stockholm/L=Stockholm/O=MySQL/CN=CA/emailAddress=ca@example.com';
  
ALTER USER 'jeffrey'@'localhost'
  REQUIRE SUBJECT '/C=SE/ST=Stockholm/L=Stockholm/
    O=MySQL demo client certificate/
    CN=client/emailAddress=client@example.com'
  AND ISSUER '/C=SE/ST=Stockholm/L=Stockholm/
    O=MySQL/CN=CA/emailAddress=ca@example.com'
  AND CIPHER 'EDH-RSA-DES-CBC3-SHA';
  
ALTER USER 'jeffrey'@'localhost'
  WITH MAX_QUERIES_PER_HOUR 500 MAX_UPDATES_PER_HOUR 100;
  
ALTER USER 'jeffrey'@'localhost' PASSWORD HISTORY DEFAULT;

ALTER USER 'jeffrey'@'localhost' PASSWORD REUSE INTERVAL 360 DAY;

ALTER USER 'bill'@'localhost' COMMENT 'Something about Bill';

ALTER USER 'bill'@'localhost' ATTRIBUTE '{"comment": null}';

CREATE ROLE 'admin', 'developer';
CREATE ROLE 'webapp'@'localhost';

CREATE USER 'jeffrey'@'localhost' IDENTIFIED BY 'password';

CREATE USER 'jeffrey'@'localhost'
  IDENTIFIED BY 'new_password' PASSWORD EXPIRE;
  
CREATE USER 'jeffrey'@'localhost'
  IDENTIFIED WITH caching_sha2_password BY 'new_password'
  PASSWORD EXPIRE INTERVAL 180 DAY
  FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 2;
  
CREATE USER
  'jeffrey'@'localhost' IDENTIFIED WITH mysql_native_password
                                   BY 'new_password1',
  'jeanne'@'localhost' IDENTIFIED WITH caching_sha2_password
                                  BY 'new_password2'
  REQUIRE X509 WITH MAX_QUERIES_PER_HOUR 60
  PASSWORD HISTORY 5
  ACCOUNT LOCK;
  
CREATE USER 'jeffrey'@'localhost'
  IDENTIFIED BY 'password';

CREATE USER 'jeffrey'@'localhost'
  IDENTIFIED WITH mysql_native_password BY 'password';
  
CREATE USER 'u1'@'localhost'
  IDENTIFIED WITH caching_sha2_password
    BY 'sha2_password'
  AND IDENTIFIED WITH authentication_ldap_sasl
    AS 'uid=u1_ldap,ou=People,dc=example,dc=com';
	
CREATE USER 'u1'@'localhost'
  IDENTIFIED WITH caching_sha2_password
    BY 'sha2_password'
  AND IDENTIFIED WITH authentication_ldap_sasl
    AS 'uid=u1_ldap,ou=People,dc=example,dc=com'
  AND IDENTIFIED WITH authentication_webauthn;
  

  
CREATE USER 'joe'@'10.0.0.1' DEFAULT ROLE administrator, developer;


CREATE USER 'jeffrey'@'localhost'
  REQUIRE SUBJECT '/C=SE/ST=Stockholm/L=Stockholm/
    O=MySQL demo client certificate/
    CN=client/emailAddress=client@example.com'
  AND ISSUER '/C=SE/ST=Stockholm/L=Stockholm/
    O=MySQL/CN=CA/emailAddress=ca@example.com'
  AND CIPHER 'EDH-RSA-DES-CBC3-SHA';
  
CREATE USER 'jeffrey'@'localhost'
  WITH MAX_QUERIES_PER_HOUR 500 MAX_UPDATES_PER_HOUR 100;
  
CREATE USER 'jeffrey'@'localhost'
  FAILED_LOGIN_ATTEMPTS 4 PASSWORD_LOCK_TIME 2;
  
   CREATE USER 'bill'@'localhost'
ATTRIBUTE '{"fname":"William", "lname":"Schmidt",
 "comment":"Website developer"}';
 
DROP ROLE 'admin', 'developer';
DROP ROLE 'webapp'@'localhost';

DROP USER 'jeffrey'@'localhost';


GRANT ALL ON db1.* TO 'jeffrey'@'localhost';
GRANT 'role1', 'role2' TO 'user1'@'localhost', 'user2'@'localhost';
GRANT SELECT ON world.* TO 'role3';

CREATE USER 'jeffrey'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON db1.* TO 'jeffrey'@'localhost';
GRANT SELECT ON db2.invoice TO 'jeffrey'@'localhost';

GRANT SELECT ON `d_`.* TO u;

GRANT ALL ON test.* TO 'fef'@'localhost' 

GRANT SELECT, INSERT ON *.* TO u1;

GRANT SELECT, INSERT, UPDATE ON *.* TO u1;


GRANT ALL ON *.* TO 'someuser'@'somehost';
GRANT SELECT, INSERT ON *.* TO 'someuser'@'somehost';

GRANT ALL ON mydb.* TO 'someuser'@'somehost';
GRANT SELECT, INSERT ON mydb.* TO 'someuser'@'somehost';

GRANT ALL ON mydb.mytbl TO 'someuser'@'somehost';
GRANT SELECT, INSERT ON mydb.mytbl TO 'someuser'@'somehost';

GRANT SELECT (col1), INSERT (col1, col2) ON mydb.mytbl TO 'someuser'@'somehost';

GRANT CREATE ROUTINE ON mydb.* TO 'someuser'@'somehost';
GRANT EXECUTE ON PROCEDURE mydb.myproc TO 'someuser'@'somehost';

GRANT PROXY ON 'localuser'@'localhost' TO 'externaluser'@'somehost';

GRANT 'role1', 'role2' TO 'user1'@'localhost', 'user2'@'localhost';

GRANT 'u1' TO 'u1';   
GRANT 'r1' TO 'r1';  

GRANT 'r2' TO 'u2';
GRANT 'u2' TO 'r2';

GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO u1;

GRANT INSERT ON schema1.* TO r1;
GRANT SELECT ON schema2.* TO r1;

GRANT SELECT, INSERT, UPDATE ON *.* TO u2;

GRANT SELECT, INSERT, UPDATE ON *.* TO u3 AS u1;

RENAME USER 'jeffrey'@'localhost' TO 'jeff'@'127.0.0.1';

  
  REVOKE INSERT ON *.* FROM 'jeffrey'@'localhost';
REVOKE 'role1', 'role2' FROM 'user1'@'localhost', 'user2'@'localhost';
REVOKE SELECT ON world.* FROM 'role3';

REVOKE SELECT ON test.t1 FROM jerry@localhost;

REVOKE IF EXISTS SELECT ON test.t1 FROM jerry@localhost;

REVOKE SELECT ON test.t1 FROM jerry@localhost IGNORE UNKNOWN USER;
 
SET DEFAULT ROLE 'admin', 'developer' TO 'joe'@'10.0.0.1';

SET PASSWORD FOR 'bob'@'%.example.org' = 'auth_string';

ALTER RESOURCE GROUP rg1 VCPU = 0-63;

ALTER RESOURCE GROUP rg2 THREAD_PRIORITY = 5;

ALTER RESOURCE GROUP rg3 DISABLE FORCE;

CREATE RESOURCE GROUP rg1
  TYPE = USER
  VCPU = 0
  THREAD_PRIORITY = 19;
  
CREATE RESOURCE GROUP rg2
  TYPE = SYSTEM
  THREAD_PRIORITY = -20
  DISABLE;
  
DROP RESOURCE GROUP rg1;

DROP RESOURCE GROUP rg2 FORCE;

SET RESOURCE GROUP rg2 FOR 14, 78, 4;


ANALYZE TABLE t UPDATE HISTOGRAM ON c1, c2, c3 WITH 10 BUCKETS;
ANALYZE TABLE t UPDATE HISTOGRAM ON c1, c3 WITH 10 BUCKETS;
ANALYZE TABLE t DROP HISTOGRAM ON c2;

ANALYZE TABLE t UPDATE HISTOGRAM ON c1;

ANALYZE TABLE t DROP HISTOGRAM ON c1;

ANALYZE TABLE t UPDATE HISTOGRAM ON c1 
   USING DATA '{"buckets": [], "data-type": "int", "auto-update": false,
 "null-values": 0.0, "collation-id": 8, "last-updated": "2024-03-26
 16:54:43.674995", "sampling-rate": 1.0, "histogram-type": "singleton",
 "number-of-buckets-specified": 100}';   
 
CHECK TABLE test_table FAST QUICK;

CHECKSUM TABLE employees EXTENDED;

OPTIMIZE TABLE foo;

REPAIR LOCAL TABLE customers, transactions;

REPAIR TABLE payments EXTENDED USE_FRM;

REPAIR TABLE users, orders, products EXTENDED;

INSTALL COMPONENT 'file://component1', 'file://component2';

INSTALL COMPONENT 'file://component1', 'file://component2' 
    SET GLOBAL component1.var1 = 12 + 3, PERSIST component2.var2 = 'strings';
	
INSTALL PLUGIN plugin_name SONAME 'shared_library_name';

UNINSTALL COMPONENT 'file://component1', 'file://component2';

UNINSTALL PLUGIN plugin_name;

CLONE INSTANCE FROM 'clone_user'@'192.168.1.100':3306
IDENTIFIED BY 'clone_password'
DATA DIRECTORY = '/path/to/clone_dir'
REQUIRE SSL;

CLONE LOCAL DATA DIRECTORY = '/path/to/clone_dir';

SET @@GLOBAL.sort_buffer_size = 50000, sort_buffer_size = 1000000;

SET GLOBAL sort_buffer_size = 1000000, SESSION sort_buffer_size = 1000000;
SET @@GLOBAL.sort_buffer_size = 1000000, @@LOCAL.sort_buffer_size = 1000000;
SET GLOBAL max_connections = 1000, sort_buffer_size = 1000000;

SET @x = 1, SESSION sql_mode = '';

SET PERSIST port = 3307;

SET PERSIST_ONLY port = 3307;

SET max_connections = 1000;

SET SESSION max_connections = 1000;

SET GLOBAL sql_log_bin = ON;

SET GLOBAL version = 'abc';

SET @@SESSION.max_join_size = DEFAULT;
SET @@SESSION.max_join_size = @@GLOBAL.max_join_size;

SET PERSIST_ONLY back_log = 100;
SET @@PERSIST_ONLY.back_log = 100;

SET PERSIST max_connections = 1000;
SET @@PERSIST.max_connections = 1000;

SET SESSION sql_mode = 'TRADITIONAL';
SET LOCAL sql_mode = 'TRADITIONAL';
SET @@SESSION.sql_mode = 'TRADITIONAL';
SET @@LOCAL.sql_mode = 'TRADITIONAL';
SET @@sql_mode = 'TRADITIONAL';
SET sql_mode = 'TRADITIONAL';

SET @name = 43;
SET @total_tax = (SELECT SUM(tax) FROM taxable_transactions);

SET CHARACTER SET 'latin1';

SHOW BINLOG EVENTS IN 'mysql-bin.000001' LIMIT 10, 5;

SHOW CHARACTER SET WHERE Maxlen > 1;

SHOW CHARACTER SET WHERE Default_collation LIKE '%japanese%';

SHOW CHARACTER SET LIKE 'latin%';

SHOW COLLATION WHERE Charset = 'latin1';

SHOW COLLATION WHERE `Default` = 'Yes';

SHOW COLUMNS FROM City;

SHOW COLUMNS FROM mytable FROM mydb;
SHOW COLUMNS FROM mydb.mytable;

SHOW CREATE DATABASE test

SHOW CREATE DATABASE test
 
SHOW CREATE EVENT myschema.e_daily\G;

SHOW CREATE PROCEDURE test.citycount\G;

SHOW CREATE FUNCTION test.hello\G;

SHOW CREATE TABLE t\G;

SHOW CREATE TRIGGER ins_sum\G ;

SHOW CREATE USER 'u1'@'localhost';

SHOW CREATE VIEW v\G;

SHOW DATABASES WHERE `Database` LIKE 'test%' AND `Database` NOT LIKE '%_backup';

SHOW ENGINE INNODB STATUS
SHOW ENGINE INNODB MUTEX
SHOW ENGINE PERFORMANCE_SCHEMA STATUS

SHOW COUNT(*) ERRORS;

SHOW PROCEDURE CODE p1

SHOW FUNCTION CODE test.hello;

SHOW EVENTS FROM test;

SHOW PROCEDURE STATUS LIKE 'sp1'

SHOW FUNCTION STATUS LIKE 'hello'

SHOW FULL PROCESSLIST

SHOW PROFILE FOR QUERY 1;

SHOW PROFILE CPU FOR QUERY 2;

SHOW PROFILE FOR QUERY 2;

SHOW PROFILES

SHOW RELAYLOG EVENTS IN 'relay-log.000002' FROM 200 LIMIT 5;

SHOW RELAYLOG EVENTS FOR CHANNEL 'channel_name';


SHOW GRANTS FOR 'jeffrey'@'localhost';

SHOW GRANTS FOR u1;

SHOW GRANTS FOR 'u1'@'localhost' USING 'r1', 'r2';

SHOW GRANTS FOR 'u1'@'localhost' USING 'r2';

SHOW INDEX FROM City\G
 
SHOW INDEX FROM mytable FROM mydb;
SHOW INDEX FROM mydb.mytable;

SHOW OPEN TABLES IN test_db;

SHOW OPEN TABLES IN test_db;

SHOW OPEN TABLES IN test_db WHERE `Table` LIKE 'user%' AND `Table` NOT LIKE '%backup%';

SHOW PARSE_TREE SELECT * FROM t3 WHERE o_id > 2 ;

SHOW PRIVILEGES 

SHOW REPLICA STATUS

SHOW REPLICAS;

SHOW STATUS LIKE 'Key%';

SHOW TABLE STATUS IN test_db LIKE 'user%';

SHOW EXTENDED TABLES IN test_db;

SHOW TABLE STATUS IN test_db WHERE `Name` LIKE 'user%' AND `Rows` > 500;

SHOW TABLES IN test_db WHERE `Tables_in_test_db` LIKE '%a%';

SHOW TRIGGERS LIKE 'acc%' ;

SHOW COUNT(*) WARNINGS;

SHOW VARIABLES LIKE 'max_error_count';

Show warnings disabled

CACHE INDEX pt PARTITION (p0) IN kc_fast;
CACHE INDEX pt PARTITION (p1, p3) IN kc_slow;

CACHE INDEX t1, t2, t3 IN hot_cache;

FLUSH BINARY LOGS
FLUSH ENGINE LOGS
FLUSH ERROR LOGS
FLUSH GENERAL LOGS
FLUSH RELAY LOGS
FLUSH SLOW LOGS

FLUSH TABLES WITH READ LOCK ;

KILL CONNECTION 1234;

KILL CONNECTION 3456;

LOAD INDEX INTO CACHE t1, t2 IGNORE LEAVES;

LOAD INDEX INTO CACHE pt PARTITION (p0);
LOAD INDEX INTO CACHE pt PARTITION (p1, p3);

LOAD INDEX INTO CACHE pt PARTITION (ALL);

LOAD INDEX INTO CACHE pt;

RESET REPLICA;

RESET BINARY LOGS AND GTIDS 254

RESET PERSIST max_connections;

RESTART

SHUTDOWN;

EXPLAIN FORMAT=JSON INTO @myselect  SELECT name FROM a WHERE id = 2;

EXPLAIN FORMAT=JSON INTO @myupdate UPDATE a SET name2 = "garcia" WHERE id = 3; 

EXPLAIN FORMAT=JSON INTO @mydelete DELETE FROM a WHERE name1 LIKE '%e%';

EXPLAIN FORMAT=TREE FOR SCHEMA s1 SELECT * FROM t WHERE c2 > 50 ;

EXPLAIN SELECT Name FROM country WHERE Code Like 'A%';

EXPLAIN SELECT Name FROM country WHERE Code LIKE 'A%';

EXPLAIN FORMAT=JSON SELECT Name FROM country WHERE Code LIKE 'A%';

EXPLAIN ANALYZE SELECT * FROM t1 JOIN t2 ON (t1.c1 = t2.c2)
 
EXPLAIN ANALYZE SELECT * FROM t3 WHERE i > 8 ;

DESCRIBE City;

USE s2;

HELP 'ascii'
HELP 'create table'

ALTER EVENT no_such_event   ON SCHEDULE  EVERY '2:3' DAY_HOUR;

ALTER EVENT myevent
    ON SCHEDULE
      EVERY 12 HOUR
    STARTS CURRENT_TIMESTAMP + INTERVAL 4 HOUR;
	
ALTER EVENT myevent
    ON SCHEDULE
      AT CURRENT_TIMESTAMP + INTERVAL 1 DAY
    DO
      TRUNCATE TABLE myschema.mytable;
	  
ALTER EVENT myevent
    DISABLE;
	
ALTER EVENT myevent
    RENAME TO yourevent;
	
CREATE EVENT myevent
    ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 HOUR
    DO
      UPDATE myschema.mytable SET mycol = mycol + 1;
	  
CREATE EVENT e_totals
ON SCHEDULE AT '2006-02-10 23:59:00'
DO INSERT INTO test.totals VALUES (NOW());

CREATE EVENT e_hourly
    ON SCHEDULE
      EVERY 1 HOUR
    COMMENT 'Clears out sessions table each hour.'
    DO
      DELETE FROM site_activity.sessions;
	  
CREATE EVENT e_daily
    ON SCHEDULE
      EVERY 1 DAY
    COMMENT 'Saves total number of sessions then clears the table each day'
    DO
      BEGIN
        INSERT INTO site_activity.totals (time, total)
          SELECT CURRENT_TIMESTAMP, COUNT(*)
            FROM site_activity.sessions;
        DELETE FROM site_activity.sessions;
      END 
	  
CREATE EVENT e
    ON SCHEDULE
      EVERY 5 SECOND
    DO
      BEGIN
        DECLARE v INTEGER;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;

        SET v = 0;

        WHILE v < 5 DO
          INSERT INTO t1 VALUES (0);
          UPDATE t2 SET s1 = s1 + 1;
          SET v = v + 1;
        END WHILE;
    END
	
CREATE EVENT e_call_myproc
    ON SCHEDULE
      AT CURRENT_TIMESTAMP + INTERVAL 1 DAY
    DO CALL myproc(5, 27);

 DO SLEEP(5);
 
 
SELECT 1, 2 UNION SELECT 'a', 'b';

SELECT REPEAT('a',1) UNION SELECT REPEAT('b',20);

SELECT * FROM t1 UNION SELECT * FROM t2;
TABLE t1 UNION SELECT * FROM t2;
VALUES ROW(4,-2), ROW(5,9) UNION SELECT * FROM t2;
SELECT * FROM t1 UNION TABLE t2;
TABLE t1 UNION TABLE t2;
VALUES ROW(4,-2), ROW(5,9) UNION TABLE t2;
SELECT * FROM t1 UNION VALUES ROW(4,-2),ROW(5,9);
TABLE t1 UNION VALUES ROW(4,-2),ROW(5,9);
VALUES ROW(4,-2), ROW(5,9) UNION VALUES ROW(4,-2),ROW(5,9);

SELECT * FROM ( t2) AS t(x,y) UNION TABLE t1;

(SELECT a FROM t1 WHERE a=10 AND b=1 ORDER BY a LIMIT 10)
UNION
(SELECT a FROM t2 WHERE a=11 AND b=2 ORDER BY a LIMIT 10);

(TABLE t1 ORDER BY x LIMIT 10) 
INTERSECT 
(TABLE t2 ORDER BY a LIMIT 10);

TABLE t1
UNION 
TABLE t2
ORDER BY a LIMIT 10;

(SELECT a FROM t1 WHERE a=10 AND b=1)
EXCEPT
(SELECT a FROM t2 WHERE a=11 AND b=2)
ORDER BY a LIMIT 10;

Create Table orders
(
	Col1 INT,
	customer_id INT

);

Create Table employees
(
	employee_id INT,
	COL2 INT

);

Create Table customers
(
	customer_id INT,
	COL2 INT

);


ALTER TABLE orders
ADD CONSTRAINT fk_customer_id FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE employees
ADD CONSTRAINT pk_employee_id PRIMARY KEY (employee_id);

CREATE TABLE test_weight_null (
    weight_gramms INTEGER not null,
    CONSTRAINT chks_weight CHECK (weight_gramms IS NOT NULL OR weight_gramms >= 0)
);

CREATE TABLE test_weight_not_null (
    weight_grams INTEGER NOT NULL,
    CONSTRAINT chk_weight CHECK (weight_grams >= 0)
);


-- ADD CHECK with constraint name
ALTER TABLE test_weight_null
ADD CONSTRAINT chk_weight_null
CHECK (weight_grams IS NOT NULL OR weight_grams >= 0);

-- ADD CHECK without constraint name
ALTER TABLE test_weight_null
ADD CHECK (weight_grams IS NOT NULL OR weight_grams >= 0);

-- ADD CHECK NOT ENFORCED
ALTER TABLE test_weight_null
ADD CONSTRAINT chk_weight_null
CHECK (weight_grams IS NOT NULL OR weight_grams >= 0) NOT ENFORCED;

-- ADD CHECK ENFORCED
ALTER TABLE test_weight_null
ADD CONSTRAINT chk_weight_null
CHECK (weight_grams IS NOT NULL OR weight_grams >= 0) ENFORCED;

-- DROP CHECK
ALTER TABLE test_weight_null
DROP CHECK chk_weight_null;

-- DROP CONSTRAINT
ALTER TABLE test_weight_null
DROP CONSTRAINT chk_weight_null;

-- ALTER CHECK NOT ENFORCED
ALTER TABLE test_weight_null
ALTER CHECK chk_weight_null NOT ENFORCED;

-- ALTER CHECK ENFORCED
ALTER TABLE test_weight_null
ALTER CHECK chk_weight_null ENFORCED;