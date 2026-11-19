/* Create PostgreSQL Tables with Constraints and Comments - Testing EA 1701 - "Import DDL Script" */

CREATE TABLE products
(
	product_no integer NOT NULL PRIMARY KEY, 
	name text NOT NULL,
	price numeric NULL
)
;
/*
COMMENT ON TABLE products IS 'Products';
COMMENT ON COLUMN products.product_no IS 'Product number';
COMMENT ON COLUMN products.name IS 'Product name';
COMMENT ON COLUMN products.price IS 'Product price';
*/
--
CREATE TABLE orders
(
	order_id integer NOT NULL PRIMARY KEY,
	product_no integer REFERENCES products (product_no),
	quantity integer NULL
)
;

COMMENT ON TABLE orders IS 'Orders';
COMMENT ON COLUMN orders.order_id IS 'Order ID';
COMMENT ON COLUMN orders.product_no IS 'Product number';
COMMENT ON COLUMN orders.quantity IS 'Quantity';


