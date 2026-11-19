db.createCollection("log", { capped : true, size : 5242880, max : 5000 } )

db.createCollection(
    "weather_Report",
    {
       timeseries: {
          timeField: "timestamp",
          metaField: "data",
          granularity: "hours"
       },
       expireAfterSeconds: 86400
    }
)

db.createCollection(
    "weather24h",
    {
       timeseries: {
          timeField: "timestamp",
          metaField: "data",
          bucketMaxSpanSeconds: 3600,
          bucketRoundingSeconds: 3600
       },
       expireAfterSeconds: 86400
    }
)


db.createCollection(
   "stocks",
   { clusteredIndex: { "key": { _id: 1 }, "unique": true, "name": "stocks clustered key" } }
)



db.createCollection(
   "temperatureSensor",
   { changeStreamPreAndPostImages: { enabled: true } }
);

db.createCollection( "myColl", { collation: { locale: "fr" } } );


db.createCollection(
   "users",
   { storageEngine: { wiredTiger: { configString: "block_compressor=zlib" } } }
)

db.Employee.insertOne({
  "name": "John Doe",
  age: 30,
  email: "johndoe@example.com",
  address: {
    street: "123 Main St",
    city: "Anytown",
    state: "CA",
    zip: {
	city: "Anytown",
    state: "CA"
	},
	pin:457
  }
});

db.Employee.createIndex( { name: -1 })

db.orders.createIndex(
   { orderId: 1,custid: -1 },
   { unique: true, partialFilterExpression: { age: { $gte: 21 } },  collation: { locale: "fr" }  }
   ,"majority")
   
db.orders.insertMany( [
   { orderId: 201, custid: 301, prodId: 100, numPurchased: 20 },
   { orderId: 202, custid: 302, prodId: 101, numPurchased: 10 },
   { orderId: 203, custid: 303, prodId: 102, numPurchased: 5 },
   { orderId: 204, custid: 303, prodId: 103, numPurchased: 15 },
   { orderId: 205, custid: 303, prodId: 103, numPurchased: 20 },
   { orderId: 206, custid: 302, prodId: 102, numPurchased: 1 },
   { orderId: 207, custid: 302, prodId: 101, numPurchased: 5 },
   { orderId: 208, custid: 301, prodId: 100, numPurchased: 10 },
   { orderId: 209, custid: 303, prodId: 103, numPurchased: 30 }
] )



db.createView(
   "vieworders",
   "orders",
   [ { $match: { numPurchased: 20 } } ]
)

db.createView(
   "placesView",
   "places",
   [ { $project: { category: 1 } } ],
   { collation: { locale: "fr", strength: 1 } }
)

db.createView( "sales", "orders", [
   {
      $lookup:
         {
            from: "inventory",
            localField: "prodId",
            foreignField: "prodId",
            as: "inventoryDocs"
         }
   },
   {
      $project:
         {
           _id: 0,
           prodId: 1,
           orderId: 1,
           numPurchased: 1,
           price: "$inventoryDocs.price"
         }
   },
      { $unwind: "$price" }
] ,{ collation: { locale: "fr", strength: 1 }})


db.createView(
    "orders_with_customers_and_products",  // The name of the view
    "orders",                              // The source collection
    [
        {
            $lookup: {
                from: "customers",           // First join with customers
                localField: "customer_id",
                foreignField: "customer_id",
                as: "customer_info"
            }
        },
        {
            $unwind: "$customer_info"       // Deconstruct the array of customer_info
        },
        {
            $lookup: {
                from: "products",            // Second join with products
                localField: "product_id",
                foreignField: "product_id",
                as: "product_info"
            }
        },
        {
            $unwind: "$product_info"        // Deconstruct the array of product_info
        },
        {
            $project: {                      // Specify fields to include or exclude
                "order_id": 1,
                "quantity": 1,
                "customer_info.name": 1,
                "customer_info.email": 1,
                "product_info.product_name": 1,
                "product_info.price": 1
            }
        }
    ],
    {
        collation: { locale: "en", strength: 2 } // Specify the collation options
    }
)



db.system.js.insertOne({
    _id: "isUserOlderThan",
    value: function(user, age) {
        return user.age > age;
    }
});


db.system.js.insertOne({
    _id: "getUsersOlderThan",
    value: function(age) {
        return db.users.find({ age: { $gt: age } }).map(function(user) {
            return user.name;
        });
    }
});
   db.blog.insertOne({
"content": "content body",keywords:"keys",about:"test"})

db.blog.createIndex(
   {
      "about": "text",
      "keywords": "text"
   }
)


db.Employee.createIndex( { "$**": "text" } )

db.quotes.insertOne({
"quote": "some text"})
   
db.quotes.createIndex(
   { quote: "text" },
   { default_language: "spanish" }
)

db.quotes.createIndex(
   { quote : "text" },
   { language_override: "idioma" }
)

db.blog.createIndex(
   {
     content: "text",
     keywords: "text",
     about: "text"
   },
   {
     weights: {
       content: 10,
       keywords: 5
     },
     name: "BlogTextIndex"
   }
 )
 
 db.SAMPLE.insertOne({
"name": "John"})
 
 db.SAMPLE.createIndex(
   { "name": "text" },
   { "textIndexVersion": 2 }
 )
 
 db.test.insertOne({
"Name": "Iphone",
manufacturer:"product",
category:"sample"
})
 
 db.test.createIndex(
   {
      "$**" : 1
   },
   {
      "wildcardProjection" : {
         "attributes.size" : 1,
         "attributes.color" : 1
      }
   }
)


db.places.insertOne({
"loc": "Italy"})

db.places.createIndex( { loc : "2dsphere" } )


db.test.insertOne({
"address": "Italy"})

db.test.createIndex(
   { "address": "2dsphere" },
   { "2dsphereIndexVersion": 2 }
 )
 
db.User.insertOne({
	"Name":"stephan",
"address": "Italy"})
db.User.createIndex( { address : "2d" } )

db.User.createIndex(
   { address: "2d" },
   { bits: 32 }
)

db.User.createIndex(
   {
      address: "2d"
   },
   {
      min: -75,
      max: 60
   }
)


db.User.createIndex({ address: "text", "translation.quote": "text"},{ "default_language" : "fr" })

db.createCollection("products", { capped : true, size : 5242880, max : 5000 } )

db.products.createIndexes( [ { "manufacturer": 1}, { "category": 1 } ],
   { collation: { locale: "fr", strength: 2 } })
   
db.post.analyzeShardKey(
   {
     key: { lastName: 1 },
     keyCharacteristics: true,
     readWriteDistribution: false,
   }
)

db.orders.aggregate( [
   { $match: { status: "A" } },
   { $group: { _id: "$cust_id", total: { $sum: "$amount" } } },
   { $sort: { total: -1 } }
] )

db.pizzas.bulkWrite( [
      { insertOne: { document: { _id: 3, type: "beef", size: "medium", price: 6 } } },
      { insertOne: { document: { _id: 4, type: "sausage", size: "large", price: 10 } } },
      { updateOne: {
         filter: { type: "cheese" },
         update: { $set: { price: 8 } }
      } },
      { deleteOne: { filter: { type: "pepperoni"} } },
      { replaceOne: {
         filter: { type: "vegan" },
         replacement: { type: "tofu", size: "small", price: 4 }
      } }
   ] ) ;
   
db.customers.configureQueryAnalyzer(
   {
     mode: "off",
     samplesPerSecond: 0
   }
)

db.customers.count() ;

db.customers.countDocuments();

db.sample.datasize();

db.orders.deleteOne( { _id: ObjectId("563237a41a4d68582c2509da") } );

db.orders.deleteMany( { "client" : "Crude Traders Inc." } );  

db.inventory.distinct( "dept" )

db.students.drop()

db.pets.dropIndex( "catIdx" )
 
db.pets.dropIndex( { "cat" : -1 } )

db.orders.dropIndexes( { a: 1, b: 1 } )

db.orders.estimatedDocumentCount({ maxTimeMS: 5000 })

db.products.explain().count( { quantity: { $gt: 50 } } )

db.products.explain("executionStats").find(
   { quantity: { $gt: 50 }, category: "apparel" }
)

db.bios.find()

db.people.findAndModify({
    query: { name: "Tom", state: "active", rating: { $gt: 10 } },
    sort: { rating: 1 },
    update: { $inc: { score: 1 } }
})

db.bios.findOne()

db.scores.findOneAndDelete(
   { "name" : "M. Tagnum" }
)

db.scores.findOneAndReplace(
   { "score" : { $lt : 20000 } },
   { "team" : "Observant Badgers", "score" : 20000 }
)

db.grades.findOneAndUpdate(
   { "name" : "R. Stiles" },
   { $inc: { "points" : 5 } }
)

db.grades.getIndexes()

db.people.getShardDistribution()

db.people.getShardVersion()

db.people.isCapped()

db.restaurants.hideIndex( "borough_1_ratings_1" );

db.data.latencyStats( { histograms: true } ).pretty()

db.orders.mapReduce(
   mapFunction2,
   reduceFunction2,
   {
     out: { merge: "map_reduce_example2" },
     query: { ord_date: { $gte: new Date("2020-03-01") } },
     finalize: finalizeFunction2
   }
 );
 
db.scores.reIndex() 

db.products.remove(
    { qty: { $gt: 20 } },
    { writeConcern: { w: "majority", wtimeout: 5000 } }
)

db.rrecord.renameCollection("record")

 db.restaurant.replaceOne(
      { "name" : "Central Perk Cafe" },
      { "name" : "Central Pork Cafe", "Borough" : "Manhattan" }
   );


 db.restaurant.replaceOne(
      { "name" : "Central Perk Cafe" },
      { "name" : "Central Pork Cafe", "Borough" : "Manhattan" }
   );

db.restaurants.stats()

db.restaurants.storageSize();

db.restaurants.totalIndexSize()

db.restaurants.unhideIndex( "borough_1_ratings_1" );

db.restaurant.updateOne(
      { "name" : "Central Perk Cafe" },
      { $set: { "violations" : 3 } }
   );
   
db.restaurant.updateMany(
      { violations: { $gt: 4 } },
      { $set: { "Review" : true } }
   );

db.myCollection.validate( { full: false } )   

db.adminCommand(
  {
     renameCollection: "test.orders",
     to: "test.orders-2016"
  }
)

db.aggregate( [ {
   $currentOp : { allUsers: true, idleConnections: true } }, {
   $match : { shard: "shard01" }
   }
] )

db.currentOp(
   {
     "waitingForLock" : true,
     $or: [
        { "op" : { "$in" : [ "insert", "update", "remove" ] } },
        { "command.findandmodify": { $exists: true } }
    ]
   }
)

db.dropDatabase()

db.fsyncLock()

db.fsyncUnlock()

db.getCollectionInfos( { "info.readOnly" : true } )

db.getCollectionNames()

db.getLogComponents()

 db.getMongo().setSecondaryOk()
db.getName()

db.getProfilingStatus()

db.getReplicationInfo();

db = db.getSiblingDB('users')

db.hello()

db.help()

db.hostInfo()

db.killOp(<opid of the query to kill>)

db.logout()

db.listCommands()

db.collection.stats()

db.printReplicationInfo()

db.printSecondaryReplicationInfo()

db.printShardingStatus()

db.resetError()

db.rotateCertificates("message": "Rotating certificates")

db.runCommand( { hello: 1 } )

db.serverBuildInfo()

db.serverCmdLineOpts()
db.serverStatus()

db.setLogLevel(2, "storage.journal" )

db.setProfilingLevel(1, { slowms: 20, sampleRate: 0.42 })

db.shutdownServer({
  force: <boolean>,
  timeoutSecs: <int>
})

db.stats(1024)

db.version()

watchCursor = db.getSiblingDB("hr").watch()

db.inventory.find().batchSize(10)

db.sensors.find({"sensor-location" : "Unit 12"}).
  sort({"reading.timestamp" : 1}).
  allowDiskUse()
  
db.orders.getPlanCache().clear();  

db.orders.getPlanCache().clearPlansByQuery(query);

var planCacheList = db.orders.getPlanCache().list();

db.products.getPlanCache().help();


var bulk = db.items.initializeOrderedBulkOp();
bulk.insert( { item: "abc123", status: "A", defaultQty: 500, points: 5 } );
bulk.insert( { item: "ijk123", status: "A", defaultQty: 100, points: 10 } );
bulk.find( { status: "D" } ).deleteOne();
bulk.toString();
bulk.toJSON();
bulk.execute();

bulk.getOperations();

db.changeUserPassword("accountUser", passwordPrompt())

db.auth( {
   user: <username>,
   pwd: passwordPrompt(),   // Or "<cleartext password>"
   mechanism: <authentication mechanism>,
   digestPassword: <boolean>
} )

db.createUser( { user: "accountAdmin01",
                 pwd: passwordPrompt(),  // Or  "<cleartext password>"
                 customData: { employeeId: 12345 },
                 roles: [ { role: "clusterAdmin", db: "admin" },
                          { role: "readAnyDatabase", db: "admin" },
                          "readWrite"] },
               { w: "majority" , wtimeout: 5000 } )

db.dropUser("reportUser1", {w: "majority", wtimeout: 5000})

db.getSiblingDB("products").getUser(
   "accountAdmin01",
   { showCustomData: false }
)

db.getUser("appClient")

db.dropAllUsers( {w: "majority", wtimeout: 5000} )

db.getUsers({ filter: { mechanisms: "SCRAM-SHA-256" } })

db.grantRolesToUser(
   "accountUser01",
   [ "readWrite" , { role: "read", db: "stock" } ],
   { w: "majority" , wtimeout: 4000 }
)

db.revokeRolesFromUser( "accountUser01",
                        [ { role: "read", db: "stock" }, "readWrite" ],
                        { w: "majority" }
                      )
					  
db.updateUser( "appClient01",
{
   customData : { employeeId : "0x3039" },
   roles : [
      { role : "read", db : "assets"  }
   ]
} )				
db.updateRole(
    "inventoryControl",
    {
      privileges:
          [
            {
              resource: { db:"products", collection:"clothing" },
              actions: [ "update", "createCollection", "createIndex"]
            }
          ],
      roles:
          [
            {
              role: "read",
              db: "products"
            }
          ]
    },
    { w:"majority" }
)	  

db.revokeRolesFromRole( "<rolename>", [ <roles> ], { <writeConcern> } )

db.grantRolesToRole(
    "productsReaderWriter",
    [ "productsReader" ],
    { w: "majority" , wtimeout: 5000 }
)

db.revokePrivilegesFromRole(
    "<rolename>",
    [
        { resource: { <resource> }, actions: [ "<action>", ... ] },
        ...
    ],
    { <writeConcern> }
)

db.grantPrivilegesToRole(
    "< rolename >",
    [
        { resource: { <resource> }, actions: [ "<action>", ... ] },
        ...
    ],
    { < writeConcern > }
)

db.getRoles(
    {
      rolesInfo: 1,
      showPrivileges: true,
      showBuiltinRoles: true
    }
)

db.getRole( "associate" )

db.dropAllRoles( { w: "majority" } )

db.dropRole( "readPrices", { w: "majority" } )

db.createRole(
   {
     role: "myClusterwideAdmin",
     privileges: [
       { resource: { cluster: true }, actions: [ "addShard" ] },
       { resource: { db: "config", collection: "" }, actions: [ "find", "update", "insert", "remove" ] },
       { resource: { db: "users", collection: "usersCollection" }, actions: [ "update", "insert", "remove" ] },
       { resource: { db: "", collection: "" }, actions: [ "find" ] }
     ],
     roles: [
       { role: "read", db: "admin" }
     ]
   },
   { w: "majority" , wtimeout: 5000 }
)

rs.add( { host: "mongodbd4.example.net:27017" } )

rs.add( "mongodbd4.example.net:27017" )

rs.addArb("localhost:27020");

var config = rs.conf();

rs.freeze(seconds)

rs.printSlaveReplicationInfo()

rs.reconfig(cfg);

rs.reconfigForPSASet(1, cfg);

rs.syncFrom("myHost:27017");

rs.stepDown(120);

var status = rs.status();

rs.remove("localhost:27020");

rs.initiate(
   {
      _id: "myReplSet",
      version: 1,
      members: [
         { _id: 0, host : "mongodb0.example.net:27017" },
         { _id: 1, host : "mongodb1.example.net:27017" },
         { _id: 2, host : "mongodb2.example.net:27017" }
      ]
   }
)

db.authors.checkMetadataConsistency()

db.checkMetadataConsistency()

convertShardKeyToHashed( ObjectId("5b2be413c06d924ab26ff9ca") )

sh.abortReshardCollection("sales.orders")

sh.addShard("repl0/mongodb3.example.net:27327")

sh.addShardToZone("shard0000", "LGA")

sh.addTagRange( "exampledb.collection",
                { state: "NY", zip: MinKey },
                { state: "NY", zip: MaxKey },
                "NY"
              )

sh.balancerCollectionStatus("test.contacts")

sh.checkMetadataConsistency()

sh.commitReshardCollection("sales.orders")

sh.disableAutoSplit();

sh.disableBalancing("students.grades")

sh.enableAutoMerger( "testDatabase.myCollection" )

sh.enableBalancing("students.grades")

sh.enableAutoSplit()

sh.enableSharding("shardTest")

sh.getBalancerState()

sh.getShardedDataDistribution()

sh.isBalancerRunning()

sh.removeRangeFromZone( "exampledb.collection",
                { a : 1 },
                { a : 10 }
              )
sh.moveChunk("records.people", { zipcode: "53187" }, "shard0019")

sh.removeShardTag("shard001", "zoneA")			  

sh.waitForPingChange(
  ["mongos1.example.net:27017", "mongos2.example.net:27017"], // active pings
  60000, // timeout in milliseconds
  1000   // interval in milliseconds
)

sh.waitForBalancerOff(60000, 1000)

sh.waitForBalancer(true, 60000, 1000)

sh.updateZoneKeyRange(
   "exampledb.collection",
   { a : 1 },
   { a : 10 },
   "alpha"
)

sh.stopBalancer(60000, 1000)

sh.stopAutoMerger()

sh.startBalancer(60000, 1000)

sh.startAutoMerger()

sh.splitFind( "test.foo", { x: 70 } )

sh.splitAt( "test.foo", { x: 70 } )

sh.shardCollection("records.people", { zipcode: 1 } )

sh.removeShardFromZone("shard0000", "NYC")

sh.removeTagRange( "exampledb.collection",
                { state: "NY", zip: MinKey },
                { state: "NY", zip: MaxKey }
              )
			  
sh.reshardCollection( "sales.orders", { order_id: 1 } )
			  
sh.setBalancerState(false)			  

db = connect("localhost:27017/myDatabase")

cluster = Mongo("mongodb://mymongo.example.net:27017/?replicaSet=myMongoCluster")

db = new Mongo().getDB("myDatabase");

db.getMongo().getDBNames().map(
   name => db.getSiblingDB( name ).getCollectionNames()
)

db.getMongo().getDBs()

db.getMongo().getReadPrefMode()

db.getMongo().getReadPrefTagSet()

db.getMongo().getWriteConcern()

db.getMongo().startSession({retryWrites: true, causalConsistency: true}).getDatabase(db.getName());

db.getMongo().setWriteConcern( { w: 2, wtimeout: 1000 } )


function runTransactionWithRetry(txnFunc, session) {
    while (true) {
        try {
            txnFunc(session);  // performs transaction
            break;
        } catch (error) {
            // If transient error, retry the whole transaction
            if (error?.errorLabels?.includes("TransientTransactionError")) {
                print("TransientTransactionError, retrying transaction ...");
                continue;
            } else {
                throw error;
            }
        }
    }
}

db.weather24h.createSearchIndex(
   "searchIndex01",
   { mappings: { dynamic: true } }
)

function insertDocuments(dbName, collectionName, documents) {
    const db = connect("mongodb://localhost:27017/" + dbName);
    const collection = db.getCollection(collectionName);
    collection.insertMany(documents);
    print("Documents inserted into collection: " + collectionName);
}


db.movies.dropSearchIndex("searchIndex01")

sp.solarDemo.stop()

sp.solarDemo.stats()

sp.solarDemo.start()

sp.solarDemo.sample()

sp.solarDemo.drop()

watchCursorFullDocumentBeforeChange = db.temperatureSensor.watch(
   [],
   { fullDocumentBeforeChange: "whenAvailable" }
)

var authColl = db.getCollection("auth")

db.users.createIndex({ "email": 1 }, { unique: true })
