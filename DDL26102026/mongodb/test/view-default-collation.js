// Create a View with Default Collation
// https://www.mongodb.com/docs/manual/core/views/specify-collation/

db.places.insertMany([
   { _id: 1, category: "café" }
   { _id: 2, category: "cafe" }
   { _id: 3, category: "cafE" }
])

db.createView(
   "placesView",
   "places",
   [ { $project: { category: 1 } } ],
   { collation: { locale: "fr", strength: 1 } }
)

