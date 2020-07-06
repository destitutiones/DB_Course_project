-- Представления (Views)

-- (1) Представление гитар, продающихся в магазине, со всеми их характеристиками в порядке убывания цены
CREATE VIEW guitar_shop_database.guitar_view AS
SELECT product.p_name, maker.m_name AS "maker", product.cost, characteristic.category, characteristic.body_type,
       characteristic.material, characteristic.scale_length, characteristic.string_num, characteristic.colour
FROM guitar_shop_database.product INNER JOIN guitar_shop_database.characteristic
ON product.product_id = characteristic.product_id
INNER JOIN guitar_shop_database.maker
ON product.maker_id = maker.maker_id
WHERE guitar_shop_database.characteristic.category LIKE 'ukulele' OR
      guitar_shop_database.characteristic.category LIKE 'classical guitar' OR
      guitar_shop_database.characteristic.category LIKE 'acoustic guitar' OR
      guitar_shop_database.characteristic.category LIKE 'electroacoustic guitar'
ORDER BY cost DESC;


-- (2) Представление перечня товаров, которые придут в ожидаемых поставках, также указывается их количество,
  -- общая стоимость данного количества единиц каждого товара, суммарная стоимость каждой поставки
CREATE VIEW guitar_shop_database.supply_view AS
SELECT *, sum(tmp_table.prod_sum_cost) OVER (PARTITION BY tmp_table.supply_date) as "sum_cost"
FROM
  (SELECT supply.s_date AS "supply_date", product.p_name, product.cost, product_x_supply.s_amount,
       (product.cost * product_x_supply.s_amount) AS "prod_sum_cost"
  FROM guitar_shop_database.product_x_supply INNER JOIN guitar_shop_database.product
  ON product_x_supply.product_id = product.product_id
  INNER JOIN guitar_shop_database.supply
  ON product_x_supply.supply_id = supply.supply_id
  GROUP BY p_name, s_date, s_amount, cost
  ORDER BY supply.s_date) AS "tmp_table";


-- (3) Представление производителей и их товаров, которые продаются в магазине, также выводится
  -- стоимость каждого товара и средняя стоимость товаров этого производителя, представленных в магазине
  -- (производители расположены в алфавитном порядке, товары - в порядке возрастания цены
  -- в пределах каждого окна)
CREATE VIEW guitar_shop_database.makers_view AS
SELECT maker.m_name, product.p_name, product.cost,
       avg(cost) OVER (PARTITION BY maker.m_name) AS "average_price"
FROM guitar_shop_database.product INNER JOIN guitar_shop_database.maker
ON product.maker_id = maker.maker_id;

-------------------------------------------------------------------------------------------------------------

-- Хранимые процедуры

-- (1) Функция, обновляющая цены товаров определенного производителя; на ввод подается название производителя
  -- и значение в десятых, насколько уменьшается цена (подобие объявление скидки в магазине)
  -- Новая цена продукта округляется. Если цена продукта такова, что цена станет меньше 1$, она не изменяется.
CREATE OR REPLACE FUNCTION guitar_shop_database.func_salary(f_maker VARCHAR, percent FLOAT) RETURNS void AS
  $$
  UPDATE guitar_shop_database.product
  SET cost = cost * (1 - percent)
  WHERE (SELECT m_name FROM guitar_shop_database.maker WHERE maker.maker_id = product.maker_id) LIKE f_maker;
  $$ LANGUAGE SQL;

SELECT guitar_shop_database.func_salary('Fender', 0.1);
-- Стоимость всех товаров Fender (кроме некоторых исключений) понизится на 10%.


-- (2) Функция, возвращающая стоимость конкретного продукта, переведенную в рубли по курсу на 24.04.19
CREATE OR REPLACE FUNCTION guitar_shop_database.func_usd_to_rub(prod VARCHAR) RETURNS NUMERIC AS
  $$
  SELECT (cost * 64.31)
  FROM guitar_shop_database.product
  WHERE p_name LIKE prod
  $$ LANGUAGE SQL;

SELECT guitar_shop_database.func_usd_to_rub('Yamaha C40');
-- Будет выведена стоимость Yamaha C40 в рублях по курсу на 24.04.19.


-- (3) Функция, возвращающая суммарную стоимость всех товаров в магазине. (для триггера 1)
CREATE OR REPLACE FUNCTION guitar_shop_database.prod_sum() RETURNS BIGINT AS
  $$
  SELECT sum(cost * amount)
  FROM guitar_shop_database.product
  $$ LANGUAGE SQL;

SELECT guitar_shop_database.prod_sum();
-- Будет выведена суммарная стоимость всех товаров в магазине.


-- (4) Добавляет значения в таблицы product и characteristic (для триггера 2)
CREATE OR REPLACE FUNCTION guitar_shop_database.prod_sold() RETURNS TRIGGER AS
  $$
  BEGIN
    IF (OLD.amount > NEW.amount) THEN
      INSERT INTO guitar_shop_database.sales(prod_id, prod_name, prod_cost, prod_amount, sales_sum, date, time)
        VALUES (NEW.product_id, NEW.p_name, NEW.cost, (OLD.amount - NEW.amount),
                (NEW.cost * (OLD.amount - NEW.amount)), current_date, current_time);
    END IF;
    RETURN NEW;
  END
  $$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------------------------------------
-- Триггеры

-- (1) При вызове INSERT/DELETE/UPDATE для таблицы product в таблицу sum_cost добавляется суммарная стоимость
  -- всей продукции в магазине на текущий момент времени (после выполнения транзакции, часовой пояс - GMT).

CREATE TABLE guitar_shop_database.sum_cost(
  sum_cost BIGINT NOT NULL CHECK (sum_cost > 0),
  date DATE NOT NULL,
  time TIME NOT NULL,
  PRIMARY KEY(date, time)
);

CREATE OR REPLACE FUNCTION guitar_shop_database.trigger_sum() RETURNS TRIGGER AS $$
  BEGIN
    IF (TG_OP = 'INSERT') OR (TG_OP = 'DELETE') OR (TG_OP = 'UPDATE') THEN
      INSERT INTO guitar_shop_database.sum_cost VALUES
        ((SELECT guitar_shop_database.prod_sum()), current_date, current_time);
      RETURN NEW;
    END IF;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_prod_sum
AFTER INSERT OR UPDATE OR DELETE ON guitar_shop_database.product
FOR EACH ROW
EXECUTE PROCEDURE guitar_shop_database.trigger_sum();

-- Проверка: добавлена информация о гитаре Fender CD-60
BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'Fender'),
            'Fender CD-60', 224, 5);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, body_type, material, scale_length, string_num, colour)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Fender CD-60'),
            'acoustic guitar', 'dreadnought', 'linden', 25.3, 6, 'natural');
COMMIT;


-- (2) При вызове UPDATE для таблицы product фиксирует id продажи, id проданного товара, его название,
  -- стоимость единицы товара, количество проданного товара, сумму, вырученную за эту продажу, а также
  -- дату и время обновления информации (продажи) в таблице sales

CREATE TABLE guitar_shop_database.sales(
  sales_id SERIAL PRIMARY KEY,
  prod_id SERIAL,
  prod_name VARCHAR NOT NULL,
  prod_cost INTEGER,
  prod_amount INTEGER,
  sales_sum BIGINT,
  date DATE NOT NULL,
  time TIME NOT NULL
);

CREATE TRIGGER trigger_prod_sold
AFTER UPDATE ON guitar_shop_database.product
FOR EACH ROW
EXECUTE PROCEDURE guitar_shop_database.prod_sold();

-- Проверка: кол-во гитар уменьшилось на 2, зафиксированы данные о продаже на сумму 60$;
UPDATE guitar_shop_database.product
SET amount = amount - 2
WHERE p_name LIKE 'Veston KUS 15BK';

-- Проверка: кол-во медиаторов увеличилось на 10, ничего не фиксируется.
UPDATE guitar_shop_database.product
SET amount = amount + 10
WHERE p_name LIKE 'Fender 351 Pick';
