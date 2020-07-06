-- (1) GROUP BY + HAVING
SELECT maker.m_name, avg(cost) AS "average_price"
FROM guitar_shop_database.product INNER JOIN guitar_shop_database.maker
ON product.maker_id = maker.maker_id
INNER JOIN guitar_shop_database.characteristic
ON product.product_id = characteristic.product_id
WHERE guitar_shop_database.characteristic.category LIKE 'guitar accessories'
GROUP BY maker.m_name
HAVING count(product.p_name) >= 2;

-- В результате данного запроса для каждого производителя, выпускающего гитарные аксессуары, будет найдена
  -- средняя стоимость выпускаемого ими товара (и представленного в магазине).
  -- Будут выведены: имя производителя, средняя стоимость.
  -- (производители будут учтены и выведены, если в магазине представлены хотя бы 2 вида их товаров)

-- (2) ORDER BY
SELECT product.p_name, characteristic.category, product.cost
FROM guitar_shop_database.product INNER JOIN guitar_shop_database.characteristic
ON product.product_id = characteristic.product_id
WHERE guitar_shop_database.characteristic.category LIKE 'ukulele' OR
      guitar_shop_database.characteristic.category LIKE 'classical guitar' OR
      guitar_shop_database.characteristic.category LIKE 'acoustic guitar' OR
      guitar_shop_database.characteristic.category LIKE 'electroacoustic guitar'
ORDER BY cost ASC;

-- В результате данного запроса будет выведен список гитар, представленных в магазине,
  -- расположенных в порядке возрастания цены.
  -- Будут выведены: название товара, категория, стоимость товара.

-- (3) func() OVER(): PARTITION BY
SELECT maker.country, product.p_name, product.cost,
       avg(product.cost) OVER (PARTITION BY maker.country) AS "avg_price"
FROM guitar_shop_database.product INNER JOIN guitar_shop_database.maker
ON product.maker_id = maker.maker_id
INNER JOIN guitar_shop_database.characteristic
ON product.product_id = characteristic.product_id;

-- В результате данного запроса будет найдена средняя цена товара для каждой страны-производителя.
  -- Будут выведены: страна-производитель, название товара, цена товара, средняя цена товаров страны-производителя.

-- (4) func() OVER(): ORDER BY
SELECT supply.s_date, product_x_supply.s_amount,
        sum(product_x_supply.s_amount) OVER (ORDER BY supply.s_date ASC) AS "product_amount"
FROM guitar_shop_database.supply INNER JOIN guitar_shop_database.product_x_supply
ON supply.supply_id = product_x_supply.supply_id;

-- В результате данного запроса будут выведены:
  -- дата поставки, количество поставленного товара в конкретный день, количество поставленного товара,
  -- начиная с ближайшей даты поставки и заканчивая текущей (нарастающий итог).

-- (5) func() OVER(): ORDER BY
SELECT maker.country, product.p_name, product.cost,
       dense_rank() OVER (ORDER BY maker.country) AS "country_num"
FROM guitar_shop_database.product INNER JOIN guitar_shop_database.maker
ON product.maker_id = maker.maker_id
INNER JOIN guitar_shop_database.characteristic
ON product.product_id = characteristic.product_id;

-- Ранжируем каждую строку окна без разрывов в нумерации при равенстве значений (нумеруем страны-производителей)
  -- Будут выведены: страна-производитель, название товара, цена товара, номер страны-производителя.

-- (6) GROUP BY + HAVING, ORDER BY
SELECT supply.s_date, sum(product_x_supply.s_amount) AS "product_amount"
FROM guitar_shop_database.supply INNER JOIN guitar_shop_database.product_x_supply
ON supply.supply_id = product_x_supply.supply_id
INNER JOIN guitar_shop_database.product
ON product.product_id = product_x_supply.product_id
INNER JOIN guitar_shop_database.characteristic
ON product.product_id = characteristic.product_id
GROUP BY supply.s_date
HAVING sum(product_x_supply.s_amount) >= 30
ORDER BY product_amount ASC;

-- В результате данного запроса будут выведены даты поставок в порядке возрастания количества поставляемого товара
  -- (от наименее "насыщенных" дней в плане поставок к наиболее "насыщенным"). Будут учтены дни, когда поставляют
  -- не менее 30 единиц товара.
  -- Будут выведены: дата поставки, количество поставляемых единиц товара.
