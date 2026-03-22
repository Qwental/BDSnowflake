INSERT INTO dim_country (country_name)
SELECT DISTINCT country_name
FROM (
    SELECT customer_country AS country_name FROM mock_data
        WHERE customer_country IS NOT NULL AND TRIM(customer_country) <> ''
    UNION
    SELECT seller_country FROM mock_data
        WHERE seller_country IS NOT NULL AND TRIM(seller_country) <> ''
    UNION
    SELECT store_country FROM mock_data
        WHERE store_country IS NOT NULL AND TRIM(store_country) <> ''
    UNION
    SELECT supplier_country FROM mock_data
        WHERE supplier_country IS NOT NULL AND TRIM(supplier_country) <> ''
) sub
ORDER BY country_name;

INSERT INTO dim_city (city_name, state, country_id)
SELECT DISTINCT 
    city_name,
    state,
    c.country_id
FROM (
    SELECT 
        store_city AS city_name,
        store_state AS state,
        store_country AS country_name
    FROM mock_data
    WHERE store_city IS NOT NULL AND TRIM(store_city) <> ''
    UNION
    SELECT 
        supplier_city,
        NULL AS state,
        supplier_country
    FROM mock_data
    WHERE supplier_city IS NOT NULL AND TRIM(supplier_city) <> ''
) cities
LEFT JOIN dim_country c ON c.country_name = cities.country_name
ORDER BY city_name, state;

-- dim_breed
INSERT INTO dim_breed (breed_name)
SELECT DISTINCT customer_pet_breed
FROM mock_data
WHERE customer_pet_breed IS NOT NULL AND TRIM(customer_pet_breed) <> ''
ORDER BY customer_pet_breed;

-- dim_product_category
INSERT INTO dim_product_category (category_name)
SELECT DISTINCT product_category
FROM mock_data
WHERE product_category IS NOT NULL AND TRIM(product_category) <> ''
ORDER BY product_category;

-- dim_pet_category
INSERT INTO dim_pet_category (category_name)
SELECT DISTINCT pet_category
FROM mock_data
WHERE pet_category IS NOT NULL AND TRIM(pet_category) <> ''
ORDER BY pet_category;

-- dim_brand
INSERT INTO dim_brand (brand_name)
SELECT DISTINCT product_brand
FROM mock_data
WHERE product_brand IS NOT NULL AND TRIM(product_brand) <> ''
ORDER BY product_brand;

-- dim_material
INSERT INTO dim_material (material_name)
SELECT DISTINCT product_material
FROM mock_data
WHERE product_material IS NOT NULL AND TRIM(product_material) <> ''
ORDER BY product_material;


-- dim_date
INSERT INTO dim_date (full_date, day_of_month, month, year, quarter, day_of_week, day_name, month_name)
SELECT DISTINCT
    d,
    EXTRACT(DAY    FROM d)::INT,
    EXTRACT(MONTH  FROM d)::INT,
    EXTRACT(YEAR   FROM d)::INT,
    EXTRACT(QUARTER FROM d)::INT,
    EXTRACT(ISODOW FROM d)::INT,
    TRIM(TO_CHAR(d, 'Day')),
    TRIM(TO_CHAR(d, 'Month'))
FROM (
    SELECT TO_DATE(sale_date, 'MM/DD/YYYY') AS d
    FROM mock_data
    WHERE sale_date IS NOT NULL AND TRIM(sale_date) <> ''
) sub
ORDER BY d;

-- dim_customer
INSERT INTO dim_customer
       (first_name, last_name, age, email, country_id, postal_code,
        pet_type, pet_name, breed_id)
SELECT DISTINCT ON (m.customer_email)
    m.customer_first_name,
    m.customer_last_name,
    m.customer_age,
    m.customer_email,
    c.country_id,
    m.customer_postal_code,
    m.customer_pet_type,
    m.customer_pet_name,
    b.breed_id
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = m.customer_country
LEFT JOIN dim_breed   b ON b.breed_name   = m.customer_pet_breed
WHERE m.customer_email IS NOT NULL AND TRIM(m.customer_email) <> ''
ORDER BY m.customer_email;

-- dim_seller
INSERT INTO dim_seller (first_name, last_name, email, country_id, postal_code)
SELECT DISTINCT ON (m.seller_email)
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    c.country_id,
    m.seller_postal_code
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = m.seller_country
WHERE m.seller_email IS NOT NULL AND TRIM(m.seller_email) <> ''
ORDER BY m.seller_email;

-- dim_product
INSERT INTO dim_product
       (product_name, category_id, pet_category_id, price, weight,
        color, size, brand_id, material_id,
        description, rating, reviews, release_date, expiry_date)
SELECT DISTINCT ON (
    m.product_name,  m.product_category, m.product_brand,
    m.product_price, m.product_color,    m.product_size,
    m.product_material, m.product_weight
)
    m.product_name,
    pc.category_id,
    ptc.pet_category_id,
    m.product_price,
    m.product_weight,
    m.product_color,
    m.product_size,
    br.brand_id,
    mt.material_id,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    CASE WHEN m.product_release_date IS NOT NULL
              AND TRIM(m.product_release_date) <> ''
         THEN TO_DATE(m.product_release_date, 'MM/DD/YYYY')
    END,
    CASE WHEN m.product_expiry_date IS NOT NULL
              AND TRIM(m.product_expiry_date) <> ''
         THEN TO_DATE(m.product_expiry_date, 'MM/DD/YYYY')
    END
FROM mock_data m
LEFT JOIN dim_product_category pc  ON pc.category_name  = m.product_category
LEFT JOIN dim_pet_category     ptc ON ptc.category_name = m.pet_category
LEFT JOIN dim_brand            br  ON br.brand_name     = m.product_brand
LEFT JOIN dim_material         mt  ON mt.material_name  = m.product_material
ORDER BY m.product_name,  m.product_category, m.product_brand,
         m.product_price, m.product_color,    m.product_size,
         m.product_material, m.product_weight;

-- ✅ dim_store (с city_id)
INSERT INTO dim_store
       (store_name, location, city_id, phone, email)
SELECT DISTINCT ON (m.store_name, m.store_location, m.store_city)
    m.store_name,
    m.store_location,
    ct.city_id,
    m.store_phone,
    m.store_email
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = m.store_country
LEFT JOIN dim_city ct ON ct.city_name = m.store_city 
                     AND ct.state = m.store_state 
                     AND ct.country_id = c.country_id
WHERE m.store_name IS NOT NULL AND TRIM(m.store_name) <> ''
ORDER BY m.store_name, m.store_location, m.store_city;

INSERT INTO dim_supplier
       (supplier_name, contact, email, phone, address, city_id)
SELECT DISTINCT ON (m.supplier_email)
    m.supplier_name,
    m.supplier_contact,
    m.supplier_email,
    m.supplier_phone,
    m.supplier_address,
    ct.city_id
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = m.supplier_country
LEFT JOIN dim_city ct ON ct.city_name = m.supplier_city 
                     AND ct.country_id = c.country_id
WHERE m.supplier_email IS NOT NULL AND TRIM(m.supplier_email) <> ''
ORDER BY m.supplier_email;


INSERT INTO fact_sales
       (date_id, customer_id, seller_id, product_id,
        store_id, supplier_id,
        sale_quantity, sale_total_price)
SELECT
    d.date_id,
    cust.customer_id,
    sel.seller_id,
    prod.product_id,
    st.store_id,
    sup.supplier_id,
    m.sale_quantity,
    m.sale_total_price
FROM mock_data m
LEFT JOIN dim_date d
       ON d.full_date = TO_DATE(m.sale_date, 'MM/DD/YYYY')
LEFT JOIN dim_customer cust
       ON cust.email = m.customer_email
LEFT JOIN dim_seller sel
       ON sel.email = m.seller_email

LEFT JOIN dim_brand            _br  ON _br.brand_name     = m.product_brand
LEFT JOIN dim_material         _mt  ON _mt.material_name  = m.product_material
LEFT JOIN dim_product_category _pc  ON _pc.category_name  = m.product_category
LEFT JOIN dim_product prod
       ON prod.product_name IS NOT DISTINCT FROM m.product_name
      AND prod.price        IS NOT DISTINCT FROM m.product_price
      AND prod.color        IS NOT DISTINCT FROM m.product_color
      AND prod.size         IS NOT DISTINCT FROM m.product_size
      AND prod.weight       IS NOT DISTINCT FROM m.product_weight
      AND prod.brand_id     IS NOT DISTINCT FROM _br.brand_id
      AND prod.material_id  IS NOT DISTINCT FROM _mt.material_id
      AND prod.category_id  IS NOT DISTINCT FROM _pc.category_id

LEFT JOIN dim_country _sc ON _sc.country_name = m.store_country
LEFT JOIN dim_city _sct ON _sct.city_name = m.store_city 
                       AND _sct.state = m.store_state
                       AND _sct.country_id = _sc.country_id
LEFT JOIN dim_store st
       ON st.store_name IS NOT DISTINCT FROM m.store_name
      AND st.location   IS NOT DISTINCT FROM m.store_location
      AND st.city_id    IS NOT DISTINCT FROM _sct.city_id

LEFT JOIN dim_supplier sup
       ON sup.email = m.supplier_email;


INSERT INTO fact_inventory (date_id, product_id, store_id, quantity_on_hand)
SELECT DISTINCT
    d.date_id,
    prod.product_id,
    st.store_id,
    m.product_quantity
FROM mock_data m
LEFT JOIN dim_date d
       ON d.full_date = TO_DATE(m.sale_date, 'MM/DD/YYYY')

LEFT JOIN dim_brand            _br  ON _br.brand_name     = m.product_brand
LEFT JOIN dim_material         _mt  ON _mt.material_name  = m.product_material
LEFT JOIN dim_product_category _pc  ON _pc.category_name  = m.product_category
LEFT JOIN dim_product prod
       ON prod.product_name IS NOT DISTINCT FROM m.product_name
      AND prod.price        IS NOT DISTINCT FROM m.product_price
      AND prod.color        IS NOT DISTINCT FROM m.product_color
      AND prod.size         IS NOT DISTINCT FROM m.product_size
      AND prod.weight       IS NOT DISTINCT FROM m.product_weight
      AND prod.brand_id     IS NOT DISTINCT FROM _br.brand_id
      AND prod.material_id  IS NOT DISTINCT FROM _mt.material_id
      AND prod.category_id  IS NOT DISTINCT FROM _pc.category_id

LEFT JOIN dim_country _sc ON _sc.country_name = m.store_country
LEFT JOIN dim_city _sct ON _sct.city_name = m.store_city 
                       AND _sct.state = m.store_state
                       AND _sct.country_id = _sc.country_id
LEFT JOIN dim_store st
       ON st.store_name IS NOT DISTINCT FROM m.store_name
      AND st.location   IS NOT DISTINCT FROM m.store_location
      AND st.city_id    IS NOT DISTINCT FROM _sct.city_id

WHERE m.product_quantity IS NOT NULL
  AND d.date_id IS NOT NULL
  AND prod.product_id IS NOT NULL
  AND st.store_id IS NOT NULL
ON CONFLICT (date_id, product_id, store_id) 
DO UPDATE SET quantity_on_hand = EXCLUDED.quantity_on_hand;



SELECT 'количество строк по таблицам' AS info;

SELECT 'mock_data (staging)'   AS table_name, COUNT(*) AS rows FROM mock_data
UNION ALL
SELECT 'dim_country',          COUNT(*) FROM dim_country
UNION ALL
SELECT 'dim_city',             COUNT(*) FROM dim_city
UNION ALL
SELECT 'dim_breed',            COUNT(*) FROM dim_breed
UNION ALL
SELECT 'dim_product_category', COUNT(*) FROM dim_product_category
UNION ALL
SELECT 'dim_pet_category',     COUNT(*) FROM dim_pet_category
UNION ALL
SELECT 'dim_brand',            COUNT(*) FROM dim_brand
UNION ALL
SELECT 'dim_material',         COUNT(*) FROM dim_material
UNION ALL
SELECT 'dim_date',             COUNT(*) FROM dim_date
UNION ALL
SELECT 'dim_customer',         COUNT(*) FROM dim_customer
UNION ALL
SELECT 'dim_seller',           COUNT(*) FROM dim_seller
UNION ALL
SELECT 'dim_product',          COUNT(*) FROM dim_product
UNION ALL
SELECT 'dim_store',            COUNT(*) FROM dim_store
UNION ALL
SELECT 'dim_supplier',         COUNT(*) FROM dim_supplier
UNION ALL
SELECT 'fact_sales',           COUNT(*) FROM fact_sales
UNION ALL
SELECT 'fact_inventory',       COUNT(*) FROM fact_inventory;

SELECT 'легит чек. продажи с заполненными FK' AS info;

SELECT 
    COUNT(*) as total_sales,
    COUNT(date_id) as with_date,
    COUNT(customer_id) as with_customer,
    COUNT(seller_id) as with_seller,
    COUNT(product_id) as with_product,
    COUNT(store_id) as with_store,
    COUNT(supplier_id) as with_supplier
FROM fact_sales;

SELECT 'легит чек. складские остатки' AS info;

SELECT 
    COUNT(*) as total_inventory_records,
    COUNT(DISTINCT product_id) as unique_products,
    COUNT(DISTINCT store_id) as unique_stores,
    SUM(quantity_on_hand) as total_stock
FROM fact_inventory;