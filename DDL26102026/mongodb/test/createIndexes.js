// Examples of calls to createIndexes
// https://www.mongodb.com/docs/manual/reference/method/db.collection.createIndexes/

db.collection.createIndexes(
   [
     {
       "a": 1
     },
     {
       "b": 1
     }
   ],
   {
     unique: true,
     sparse: true,
     expireAfterSeconds: 3600
   }
 )

db.myColl.createIndex(
   { score: 1, price: 1, category: 1 },
   { collation: { locale: "fr" } } )


db.restaurants.createIndexes([{"borough": 1}, {"location": "2dsphere"}])


db.products.createIndexes( [ { "manufacturer": 1}, { "category": 1 } ],
   { collation: { locale: "fr", strength: 2 } })


use inventory
db.products_catalog.createIndexes(
  [ { "product_attributes.$**" : 1 } ]
)


use inventory
db.products_catalog.createIndexes( [ { "$**" : 1 } ] )


use inventory
db.products_catalog.createIndexes(
  [ { "$**" : 1 } ],
  {
    "wildcardProjection" : {
      "product_attributes.elements" : 1,
      "product_attributes.resistance" : 1
    }
  }
)


use inventory
db.products_catalog.createIndexes(
  [ { "$**" : 1 } ],
  {
    "wildcardProjection" : {
      "product_attributes.elements" : 0,
      "product_attributes.resistance" : 0
    }
  }
)


db.getSiblingDB("examples").invoices.createIndexes(
  { "invoices" : 1 },
  { },
  "majority"
)


db.cakeSales.insertMany( [
   { _id: 0, type: "chocolate", orderDate: new Date("2020-05-18T14:10:30Z"),
     state: "CA", price: 13, quantity: 120 },
   { _id: 1, type: "chocolate", orderDate: new Date("2021-03-20T11:30:05Z"),
     state: "WA", price: 14, quantity: 140 },
   { _id: 2, type: "vanilla", orderDate: new Date("2021-01-11T06:31:15Z"),
     state: "CA", price: 12, quantity: 145 },
   { _id: 3, type: "vanilla", orderDate: new Date("2020-02-08T13:13:23Z"),
     state: "WA", price: 13, quantity: 104 },
   { _id: 4, type: "strawberry", orderDate: new Date("2019-05-18T16:09:01Z"),
     state: "CA", price: 41, quantity: 162 },
   { _id: 5, type: "strawberry", orderDate: new Date("2019-01-08T06:12:03Z"),
     state: "WA", price: 43, quantity: 134 }
] )
db.cakeSales.createIndexes( [
   { "type": 1 },
   { "orderDate": 1 },
   { "state": 1 },
   { "orderDate": 1, "state": -1 }
] )
