CREATE TABLE dim_country (
    country_id   SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dim_city (
    city_id    SERIAL PRIMARY KEY,
    city_name  VARCHAR(255) NOT NULL,
    state      VARCHAR(100),
    country_id INTEGER REFERENCES dim_country(country_id)
);

CREATE UNIQUE INDEX idx_dim_city_unique 
    ON dim_city (city_name, COALESCE(state, ''), country_id);

CREATE TABLE dim_breed (
    breed_id   SERIAL PRIMARY KEY,
    breed_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dim_product_category (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dim_pet_category (
    pet_category_id SERIAL PRIMARY KEY,
    category_name   VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dim_brand (
    brand_id   SERIAL PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dim_material (
    material_id   SERIAL PRIMARY KEY,
    material_name VARCHAR(100) NOT NULL UNIQUE
);


CREATE TABLE dim_date (
    date_id      SERIAL PRIMARY KEY,
    full_date    DATE NOT NULL UNIQUE,
    day_of_month INTEGER NOT NULL,
    month        INTEGER NOT NULL,
    year         INTEGER NOT NULL,
    quarter      INTEGER NOT NULL,
    day_of_week  INTEGER NOT NULL,
    day_name     VARCHAR(20),
    month_name   VARCHAR(20)
);

CREATE TABLE dim_customer (
    customer_id SERIAL PRIMARY KEY,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    age         INTEGER,
    email       VARCHAR(255),
    country_id  INTEGER REFERENCES dim_country(country_id),
    postal_code VARCHAR(50),
    pet_type    VARCHAR(50),
    pet_name    VARCHAR(100),
    breed_id    INTEGER REFERENCES dim_breed(breed_id)
);

CREATE TABLE dim_seller (
    seller_id   SERIAL PRIMARY KEY,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    email       VARCHAR(255),
    country_id  INTEGER REFERENCES dim_country(country_id),
    postal_code VARCHAR(50)
);

CREATE TABLE dim_product (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(255),
    category_id     INTEGER REFERENCES dim_product_category(category_id),
    pet_category_id INTEGER REFERENCES dim_pet_category(pet_category_id),
    price           DECIMAL(10,2),
    weight          DECIMAL(10,2),
    color           VARCHAR(50),
    size            VARCHAR(50),
    brand_id        INTEGER REFERENCES dim_brand(brand_id),
    material_id     INTEGER REFERENCES dim_material(material_id),
    description     TEXT,
    rating          DECIMAL(3,1),
    reviews         INTEGER,
    release_date    DATE,
    expiry_date     DATE
);

CREATE TABLE dim_store (
    store_id   SERIAL PRIMARY KEY,
    store_name VARCHAR(255),
    location   VARCHAR(255),
    city_id    INTEGER REFERENCES dim_city(city_id),
    phone      VARCHAR(50),
    email      VARCHAR(255)
);

CREATE TABLE dim_supplier (
    supplier_id   SERIAL PRIMARY KEY,
    supplier_name VARCHAR(255),
    contact       VARCHAR(255),
    email         VARCHAR(255),
    phone         VARCHAR(50),
    address       VARCHAR(255),
    city_id       INTEGER REFERENCES dim_city(city_id)
);


CREATE TABLE fact_sales (
    sale_id          SERIAL PRIMARY KEY,
    date_id          INTEGER REFERENCES dim_date(date_id),
    customer_id      INTEGER REFERENCES dim_customer(customer_id),
    seller_id        INTEGER REFERENCES dim_seller(seller_id),
    product_id       INTEGER REFERENCES dim_product(product_id),
    store_id         INTEGER REFERENCES dim_store(store_id),
    supplier_id      INTEGER REFERENCES dim_supplier(supplier_id),
    sale_quantity    INTEGER NOT NULL, 
    sale_total_price DECIMAL(10,2) NOT NULL  
);

CREATE TABLE fact_inventory (
    inventory_id     SERIAL PRIMARY KEY,
    date_id          INTEGER REFERENCES dim_date(date_id),
    product_id       INTEGER REFERENCES dim_product(product_id),
    store_id         INTEGER REFERENCES dim_store(store_id),
    quantity_on_hand INTEGER NOT NULL,
    quantity_reserved INTEGER DEFAULT 0
);


CREATE INDEX idx_fact_sales_date     ON fact_sales(date_id);
CREATE INDEX idx_fact_sales_customer ON fact_sales(customer_id);
CREATE INDEX idx_fact_sales_seller   ON fact_sales(seller_id);
CREATE INDEX idx_fact_sales_product  ON fact_sales(product_id);
CREATE INDEX idx_fact_sales_store    ON fact_sales(store_id);
CREATE INDEX idx_fact_sales_supplier ON fact_sales(supplier_id);


CREATE INDEX idx_fact_inventory_date    ON fact_inventory(date_id);
CREATE INDEX idx_fact_inventory_product ON fact_inventory(product_id);
CREATE INDEX idx_fact_inventory_store   ON fact_inventory(store_id);

CREATE UNIQUE INDEX idx_fact_inventory_unique 
    ON fact_inventory(date_id, product_id, store_id);