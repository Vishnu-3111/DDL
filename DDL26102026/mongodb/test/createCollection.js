// Examples of calls to createCollection
// https://www.mongodb.com/docs/manual/reference/method/db.createCollection/#mongodb-method-db.createCollection

// Create a Capped Collection
db.createCollection("log", { capped : true, size : 5242880, max : 5000 } )

// Create a Time Series Collection
db.createCollection(
    "weather24h",
    {
       timeseries: {
          timeField: "timestamp",
          metaField: "data",
          granularity: "hours"
       },
       expireAfterSeconds: 86400
    }
)

// Create a Clustered Collection
db.createCollection(
   "stocks",
   { clusteredIndex: { "key": { _id: 1 }, "unique": true, "name": "stocks clustered key" } }
)

// Create a Collection with Change Stream Pre- and Post-Images for Documents
db.createCollection(
   "temperatureSensor",
   { changeStreamPreAndPostImages: { enabled: true } }
);

// Specify Collation
db.createCollection( "myColl", { collation: { locale: "fr" } } );

// Specify Storage Engine Options
db.createCollection(
   "users",
   { storageEngine: { wiredTiger: { configString: "<option>=<setting>" } } }
)

