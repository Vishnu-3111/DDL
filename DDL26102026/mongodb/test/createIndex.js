// Examples of calls to createIndex
// https://www.mongodb.com/docs/manual/reference/method/db.collection.createIndex/

db.collection.createIndex(
  {
      "a": 1
  },
  {
      unique: true,
      sparse: true,
      expireAfterSeconds: 3600
  }
)


db.myColl.createIndex( { category: 1 }, { collation: { locale: "fr" } } )


db.myColl.createIndex(
   { score: 1, price: 1, category: 1 },
   { collation: { locale: "fr" } } )


db.collection.createIndex( { orderDate: 1 } )


db.collection.createIndex( { orderDate: 1, zipcode: -1 } )


db.collection.createIndex( { "state" : 1, "zipcode" : "hashed" } )


db.collection.createIndex(
   { category: 1 },
   { name: "category_fr", collation: { locale: "fr", strength: 2 } }
)


db.collection.createIndex(
   { orderDate: 1, category: 1 },
   { name: "date_category_fr", collation: { locale: "fr", strength: 2 } }
)


use inventory
db.products_catalog.createIndex( { "$**" : 1 } )


use inventory
db.products_catalog.createIndex(
  { "$**" : 1 },
  {
    "wildcardProjection" : {
      "product_attributes.elements" : 1,
      "product_attributes.resistance" : 1
    }
  }
)


use inventory
db.products_catalog.createIndex(
  { "$**" : 1 },
  {
    "wildcardProjection" : {
      "product_attributes.elements" : 0,
      "product_attributes.resistance" : 0
    }
  }
)


db.getSiblingDB("examples").invoices.createIndex(
  { "invoices" : 1 },
  { },
  "majority"
)
