CREATE TABLE dim_country (
    country_id   SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);

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
    city       VARCHAR(255),
    state      VARCHAR(100),
    country_id INTEGER REFERENCES dim_country(country_id),
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
    city          VARCHAR(255),
    country_id    INTEGER REFERENCES dim_country(country_id)
);


CREATE TABLE fact_sales (
    sale_id          SERIAL PRIMARY KEY,
    date_id          INTEGER REFERENCES dim_date(date_id),
    customer_id      INTEGER REFERENCES dim_customer(customer_id),
    seller_id        INTEGER REFERENCES dim_seller(seller_id),
    product_id       INTEGER REFERENCES dim_product(product_id),
    store_id         INTEGER REFERENCES dim_store(store_id),
    supplier_id      INTEGER REFERENCES dim_supplier(supplier_id),
    sale_quantity     INTEGER, 
    sale_total_price  DECIMAL(10,2),  
    product_quantity  INTEGER           
);

CREATE INDEX idx_fact_date     ON fact_sales(date_id);
CREATE INDEX idx_fact_customer ON fact_sales(customer_id);
CREATE INDEX idx_fact_seller   ON fact_sales(seller_id);
CREATE INDEX idx_fact_product  ON fact_sales(product_id);
CREATE INDEX idx_fact_store    ON fact_sales(store_id);
CREATE INDEX idx_fact_supplier ON fact_sales(supplier_id);