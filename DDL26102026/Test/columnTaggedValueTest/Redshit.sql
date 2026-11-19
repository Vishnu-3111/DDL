DROP TABLE IF EXISTS tickit.users;	
CREATE TABLE IF NOT EXISTS tickit.users	
(	
	userid INTEGER NOT NULL  ENCODE RAW	
	,username CHAR(8)   ENCODE lzo	
	,firstname VARCHAR(30)   ENCODE lzo	
	,lastname VARCHAR(30)   ENCODE lzo	
	,city VARCHAR(30)   ENCODE lzo	
	,state CHAR(2)   ENCODE lzo	
	,email VARCHAR(100)   ENCODE lzo	
	,phone CHAR(14)   ENCODE lzo	
	,likesports BOOLEAN   ENCODE RAW	
	,liketheatre BOOLEAN   ENCODE RAW	
	,likeconcerts BOOLEAN   ENCODE RAW	
	,likejazz BOOLEAN   ENCODE RAW	
	,likeclassical BOOLEAN   ENCODE RAW	
	,likeopera BOOLEAN   ENCODE RAW	
	,likerock BOOLEAN   ENCODE RAW	
	,likevegas BOOLEAN   ENCODE RAW	
	,likebroadway BOOLEAN   ENCODE RAW	
	,likemusicals BOOLEAN   ENCODE RAW	
)	
DISTSTYLE KEY	
 DISTKEY (userid)	
 SORTKEY (	
	userid	
	)	
;	
ALTER TABLE tickit.users owner to "IAMR:AWSReservedSSO_AmazonQ-FullAccess_cac2d4c3c5226f49";	
DROP TABLE IF EXISTS tickit.venue;	
CREATE TABLE IF NOT EXISTS tickit.venue	
(	
	venueid SMALLINT NOT NULL  ENCODE RAW	
	,venuename VARCHAR(100)   ENCODE lzo	
	,venuecity VARCHAR(30)   ENCODE lzo	
	,venuestate CHAR(2)   ENCODE lzo	
	,venueseats INTEGER   ENCODE az64	
)	
DISTSTYLE KEY	
 DISTKEY (venueid)	
 SORTKEY (	
	venueid	
	)	
;	
ALTER TABLE tickit.venue owner to "IAMR:AWSReservedSSO_AmazonQ-FullAccess_cac2d4c3c5226f49";	
DROP TABLE IF EXISTS tickit.category;	
CREATE TABLE IF NOT EXISTS tickit.category	
(	
	catid SMALLINT NOT NULL  ENCODE RAW	
	,catgroup VARCHAR(10)   ENCODE lzo	
	,catname VARCHAR(10)   ENCODE lzo	
	,catdesc VARCHAR(50)   ENCODE lzo	
)	
DISTSTYLE KEY	
 DISTKEY (catid)	
 SORTKEY (	
	catid	
	)	
;	
ALTER TABLE tickit.category owner to "IAMR:AWSReservedSSO_AmazonQ-FullAccess_cac2d4c3c5226f49";	
DROP TABLE IF EXISTS tickit.date;	
CREATE TABLE IF NOT EXISTS tickit.date	
(	
	dateid SMALLINT NOT NULL  ENCODE RAW	
	,caldate DATE NOT NULL  ENCODE az64	
	,"day" CHAR(3) NOT NULL  ENCODE lzo	
	,week SMALLINT NOT NULL  ENCODE az64	
	,"month" CHAR(5) NOT NULL  ENCODE lzo	
	,qtr CHAR(5) NOT NULL  ENCODE lzo	
	,"year" SMALLINT NOT NULL  ENCODE az64	
	,holiday BOOLEAN  DEFAULT false ENCODE RAW	
)	
DISTSTYLE KEY	
 DISTKEY (dateid)	
 SORTKEY (	
	dateid	
	)	
;	
ALTER TABLE tickit.date owner to "IAMR:AWSReservedSSO_AmazonQ-FullAccess_cac2d4c3c5226f49";	
DROP TABLE IF EXISTS tickit.event;	
CREATE TABLE IF NOT EXISTS tickit.event	
(	
	eventid INTEGER NOT NULL  ENCODE az64	
	,venueid SMALLINT NOT NULL  ENCODE az64	
	,catid SMALLINT NOT NULL  ENCODE az64	
	,dateid SMALLINT NOT NULL  ENCODE RAW	
	,eventname VARCHAR(200)   ENCODE lzo	
	,starttime TIMESTAMP WITHOUT TIME ZONE   ENCODE az64	
)	
DISTSTYLE KEY	
 DISTKEY (eventid)	
 SORTKEY (	
	dateid	
	)	
;	
ALTER TABLE tickit.event owner to '水';	
DROP TABLE IF EXISTS tickit.listing;	
CREATE TABLE IF NOT EXISTS tickit.listing	
(	
	listid INTEGER NOT NULL  ENCODE az64	
	,sellerid INTEGER NOT NULL  ENCODE az64	
	,eventid INTEGER NOT NULL  ENCODE az64	
	,dateid SMALLINT NOT NULL  ENCODE RAW	
	,numtickets SMALLINT NOT NULL  ENCODE az64	
	,priceperticket NUMERIC(8,2)   ENCODE az64	
	,totalprice NUMERIC(8,2)   ENCODE az64	
	,listtime TIMESTAMP WITHOUT TIME ZONE   ENCODE az64	
)	
DISTSTYLE KEY	
 DISTKEY (listid)	
 SORTKEY (	
	dateid	
	)	
;	
ALTER TABLE tickit.listing owner to "IAMR:AWSReservedSSO_AmazonQ-FullAccess_cac2d4c3c5226f49";	
DROP TABLE IF EXISTS tickit.sales;	
CREATE TABLE IF NOT EXISTS tickit.sales	
(	
	salesid INTEGER NOT NULL  ENCODE az64	
	,listid INTEGER NOT NULL  ENCODE az64	
	,sellerid INTEGER NOT NULL  ENCODE az64	
	,buyerid INTEGER NOT NULL  ENCODE az64	
	,eventid INTEGER NOT NULL  ENCODE az64	
	,dateid SMALLINT NOT NULL  ENCODE RAW	
	,qtysold SMALLINT NOT NULL  ENCODE az64	
	,pricepaid NUMERIC(8,2)   ENCODE az64	
	,commission NUMERIC(8,2)   ENCODE az64	
	,saletime TIMESTAMP WITHOUT TIME ZONE   ENCODE az64	
)	
DISTSTYLE KEY	
 DISTKEY (listid)	
 SORTKEY (	
	dateid	
	)	
;	
ALTER TABLE tickit.sales owner to "IAMR:AWSReservedSSO_AmazonQ-FullAccess_cac2d4c3c5226f49";	
