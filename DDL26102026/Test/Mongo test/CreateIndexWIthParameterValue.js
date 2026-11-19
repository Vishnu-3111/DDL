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

db.Employee.createIndex( { name: -1 , age:1}) // SSIN_DEV_23072024 the term "name" & "age" denote as Field name. Then "-1 & 1" denote as Field value