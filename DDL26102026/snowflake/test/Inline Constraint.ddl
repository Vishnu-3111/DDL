CREATE TABLE Customer_Satellite (
	CustomerHashKey INTEGER PRIMARY KEY
	,CustomerName VARCHAR(250)
	,CustomerAddress VARCHAR(250)
	,CustomerContactNumber INTEGER
	,LoadDateTime DATETIME
	);

CREATE TABLE Customer_Hub (
	CustomerHashKey INTEGER PRIMARY KEY
	,LoadDateTime DATETIME
	,ProductHashKey INTEGER
	,FOREIGN KEY (CustomerHashKey) REFERENCES Customer_Satellite(CustomerHashKey)
	);


CREATE TABLE t_object (
    ObjectID INTEGER PRIMARY KEY
	,ea_guid VARCHAR(50) UNIQUE
	,Name VARCHAR(250)
);

CREATE TABLE t_objectproperties (
    PropertyID INTEGER PRIMARY KEY
	,ea_guid VARCHAR(50) UNIQUE
    ,ObjectID INTEGER FOREIGN KEY REFERENCES t_object(ObjectID)
	,Name VARCHAR(250)
	,PropertyValue VARCHAR(250)
);

CREATE TABLE t_xref (
    PropertyID VARCHAR(50) PRIMARY KEY
    ,Client VARCHAR(50) FOREIGN KEY REFERENCES t_object(ea_guid)
	,Name VARCHAR(250)
);
