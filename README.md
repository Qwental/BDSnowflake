# BigDataSnowflake
#### Выполнил Бугренков Владимир М8О-311Б-23

### Схема снежинки
![Схема снежинки](схема_снежинки.jpg)

### что сделано
нужные sql-скрипты сделаны(инициализация мок данными, заполнение мок-таблицы из csv, ddl скрипт для создание снежинки и dml для ее заполнения), модель снежинки построена, бд запускается в контейнере




### инструкция по запуску
1. git clone
```bash
   git clone https://github.com/Qwental/BDSnowflake.git
   cd BDSnowflake
```

можно настроить .env, если хочется;
значения по дефолту без .env такие:
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=postgres
POSTGRES_PORT=5432

2. compose up
```bash
docker compose up -d
```
3. Проверка логов инициализации спустя пару секунд
```bash
docker compose logs postgres
```
4. готовые запросы для проверки через CLI
подрубаемся:
```bash
PGPASSWORD=postgres psql -h localhost -p 5432 -U postgres -d petshop
```
4.1. 
```psql
SELECT 'mock_data' AS table_name, COUNT(*) AS rows FROM mock_data UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dim_customer UNION ALL
SELECT 'dim_seller', COUNT(*) FROM dim_seller UNION ALL
SELECT 'dim_product', COUNT(*) FROM dim_product UNION ALL
SELECT 'dim_store', COUNT(*) FROM dim_store UNION ALL
SELECT 'dim_supplier', COUNT(*) FROM dim_supplier UNION ALL
SELECT 'dim_city', COUNT(*) FROM dim_city UNION ALL
SELECT 'dim_country', COUNT(*) FROM dim_country UNION ALL
SELECT 'fact_sales', COUNT(*) FROM fact_sales;
```

4.2. 
```psql
SELECT c.first_name, p.product_name, d.full_date,
       f.sale_quantity, f.sale_total_price
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_product  p ON f.product_id  = p.product_id
JOIN dim_date     d ON f.date_id     = d.date_id
LIMIT 5;
```





