-- Создание таблиц

-- Создание схемы базы данных гитарного магазина
CREATE SCHEMA guitar_shop_database;

-- Информация о производителях
CREATE TABLE guitar_shop_database.maker(
  maker_id SERIAL PRIMARY KEY,
  m_name VARCHAR(255) NOT NULL UNIQUE,
  country VARCHAR(255) NOT NULL
);


-- Информация о поставках
CREATE TABLE guitar_shop_database.supply(
  supply_id SERIAL PRIMARY KEY,
  s_date DATE NOT NULL
);

-- Информация о товаре
CREATE TABLE guitar_shop_database.product(
  product_id SERIAL PRIMARY KEY,
  maker_id SERIAL NOT NULL,
  p_name VARCHAR(255) NOT NULL UNIQUE ,
  cost INTEGER NOT NULL CHECK (cost > 0),
  amount INTEGER NOT NULL CHECK (amount >= 0),
  FOREIGN KEY (maker_id)
    REFERENCES guitar_shop_database.maker(maker_id)
);

-- Таблица-связка "Продукт-поставка"
CREATE TABLE guitar_shop_database.product_x_supply(
  product_id SERIAL NOT NULL,
  supply_id SERIAL NOT NULL,
  s_amount INTEGER NOT NULL CHECK (s_amount > 0),
  PRIMARY KEY (product_id, supply_id),
  FOREIGN KEY (product_id)
    REFERENCES guitar_shop_database.product(product_id),
  FOREIGN KEY (supply_id)
    REFERENCES guitar_shop_database.supply(supply_id)
);

-- Характеристики товаров
CREATE TABLE guitar_shop_database.characteristic(
  product_id SERIAL PRIMARY KEY,
	category VARCHAR(255) NOT NULL,
  body_type VARCHAR(255),
  material VARCHAR(255),
  scale_length FLOAT,
  string_num INTEGER,
  colour VARCHAR(255),
  battery_type VARCHAR(255),
  caliber VARCHAR(255),
  compatibility VARCHAR(255),
  thickness VARCHAR(255),
  insulation BOOLEAN,
  FOREIGN KEY (product_id)
    REFERENCES guitar_shop_database.product(product_id)
    DEFERRABLE INITIALLY DEFERRED
);

-- Добавление внешнего ключа
ALTER TABLE guitar_shop_database.product
ADD FOREIGN KEY (product_id)
  REFERENCES guitar_shop_database.characteristic(product_id)
  DEFERRABLE INITIALLY DEFERRED;

------------------------------------------------------------------------------------------------------------------------

-- Заполнение таблицы "maker"
INSERT INTO guitar_shop_database.maker(m_name, country)
  VALUES ('Yamaha', 'Japan'), ('Fender', 'USA'), ('Veston', 'China'),
         ('Ibanez', 'Japan'), ('Gibson', 'USA'), ('Planet Waves', 'USA'),
         ('Magic Music', 'Russia'), ('AMC Music', 'Russia'), ('Korg', 'Japan'),
         ('Elixir Strings', 'USA'), ('D`Addario', 'USA');

-- Заполнение таблицы "supply"
INSERT INTO guitar_shop_database.supply(s_date)
  VALUES ('2019-05-31'), ('2019-06-28'), ('2019-07-12'),
         ('2019-08-02'), ('2019-08-30');

-- Заполнение таблиц "product" и "characteristic" (параллельное, так как присутствует круговая связь по product_id)
BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'Yamaha'),
            'Yamaha C40', 122, 12);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, body_type, material, scale_length, string_num, colour)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Yamaha C40'),
            'classical guitar', 'classical', 'meranti', 25.6, 6, 'natural');
COMMIT;

BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'Fender'),
            'Fender FA-125 Dreadnought', 210, 7);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, body_type, material, scale_length, string_num, colour)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Fender FA-125 Dreadnought'),
            'acoustic guitar', 'dreadnought', 'walnut', 25.3, 6, 'natural');
COMMIT;

BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'Fender'),
            'Fender Malibu Special MBK W/Bag', 555, 1);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, body_type, material, scale_length, string_num, colour)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Fender Malibu Special MBK W/Bag'),
            'electroacoustic guitar', 'malibu', 'mahogany', 24, 6, 'black');
COMMIT;

BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'Veston'),
            'Veston KUS 15BK', 30, 4);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, body_type, material, scale_length, string_num, colour)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Veston KUS 15BK'),
            'ukulele', 'soprano', 'linden', 13, 6, 'black');
COMMIT;

BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'Veston'),
            'Veston KUS 15GR', 30, 2);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, body_type, material, scale_length, string_num, colour)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Veston KUS 15GR'),
            'ukulele', 'soprano', 'linden', 13, 6, 'green');
COMMIT;

BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'Ibanez'),
            'Ibanez CE16M-BK', 1, 32);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, material, colour, thickness)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Ibanez CE16M-BK'),
            'guitar accessories', 'carbon fiber', 'black', 'medium');
COMMIT;

BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'Gibson'),
            'Gibson APRGG50-74M', 1, 15);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, material, colour, thickness)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Gibson APRGG50-74M'),
            'guitar accessories', 'plastic', 'black', 'medium');
COMMIT;

BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'Fender'),
            'Fender 351 Pick', 1, 20);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, material, colour, thickness)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Fender 351 Pick'),
            'guitar accessories', 'plastic', 'black', 'thin');
COMMIT;

BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'Planet Waves'),
            'Planet Waves 1UCT2-100 Cortex Pick', 1, 43);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, material, colour, thickness)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Planet Waves 1UCT2-100 Cortex Pick'),
            'guitar accessories', 'plastic', 'yellow', 'light');
COMMIT;

BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'Magic Music'),
            'Magic Music Bag ЧГ-К', 24, 6);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, material, colour, compatibility, insulation)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Magic Music Bag ЧГ-К'),
            'guitar accessories', 'fabric', 'black', 'classical guitar', 'YES');
COMMIT;

BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'Magic Music'),
            'Magic Music Bag ЧГ-В', 26, 3);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, material, colour, compatibility, insulation)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Magic Music Bag ЧГ-В'),
            'guitar accessories', 'fabric', 'black', 'acoustic guitar', 'YES');
COMMIT;

BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'AMC Music'),
            'AMC Music УКЛ1 CONCERT', 10, 3);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, material, colour, compatibility, insulation)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'AMC Music УКЛ1 CONCERT'),
            'guitar accessories', 'fabric', 'black', 'ukulele', 'YES');
COMMIT;

BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'Korg'),
            'Korg Griptune', 17, 6);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, material, colour, battery_type)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Korg Griptune'),
            'guitar accessories', 'plastic', 'black', 'CR2032');
COMMIT;

BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'Korg'),
            'Korg Sledgehammer Pro', 27, 2);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, material, colour, battery_type)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Korg Sledgehammer Pro'),
            'guitar accessories', 'plastic', 'black', 'CR2032');
COMMIT;

BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'Elixir Strings'),
            'Elixir 11027', 25, 10);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, material, caliber, compatibility)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Elixir 11027'),
            'guitar accessories', 'bronze', '11-52', 'acoustic guitar');
COMMIT;

BEGIN;
  INSERT INTO guitar_shop_database.product(maker_id, p_name, cost, amount)
    VALUES ((SELECT maker_id FROM guitar_shop_database.maker WHERE m_name = 'D`Addario'),
            'D`Addario EJ26', 11, 0);
  INSERT INTO guitar_shop_database.characteristic(product_id, category, material, caliber, compatibility)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'D`Addario EJ26'),
            'guitar accessories', 'phosphor bronze', '11-52', 'acoustic guitar');
COMMIT;

-- Заполнение таблицы "product_x_supply"

INSERT INTO guitar_shop_database.product_x_supply(product_id, supply_id, s_amount)
    VALUES ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Veston KUS 15GR'),
            (SELECT supply_id FROM guitar_shop_database.supply WHERE s_date = '2019-05-31'), 5),
           ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Korg Sledgehammer Pro'),
            (SELECT supply_id FROM guitar_shop_database.supply WHERE s_date = '2019-05-31'), 8),
           ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'D`Addario EJ26'),
            (SELECT supply_id FROM guitar_shop_database.supply WHERE s_date = '2019-05-31'), 15),
           ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Veston KUS 15BK'),
            (SELECT supply_id FROM guitar_shop_database.supply WHERE s_date = '2019-06-28'), 10),
           ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Gibson APRGG50-74M'),
            (SELECT supply_id FROM guitar_shop_database.supply WHERE s_date = '2019-06-28'), 100),
           ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Fender Malibu Special MBK W/Bag'),
            (SELECT supply_id FROM guitar_shop_database.supply WHERE s_date = '2019-07-12'), 3),
           ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Magic Music Bag ЧГ-В'),
            (SELECT supply_id FROM guitar_shop_database.supply WHERE s_date = '2019-08-02'), 15),
           ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'AMC Music УКЛ1 CONCERT'),
            (SELECT supply_id FROM guitar_shop_database.supply WHERE s_date = '2019-08-02'), 15),
           ((SELECT product_id FROM guitar_shop_database.product WHERE p_name = 'Elixir 11027'),
            (SELECT supply_id FROM guitar_shop_database.supply WHERE s_date = '2019-08-30'), 30);

------------------------------------------------------------------------------------------------------------------------

-- Удаление значений из таблицы
TRUNCATE guitar_shop_database.characteristic, guitar_shop_database.maker,
  guitar_shop_database.product, guitar_shop_database.product_x_supply, guitar_shop_database.supply;

-- Удаление таблиц
DROP TABLE guitar_shop_database.characteristic, guitar_shop_database.maker,
  guitar_shop_database.product, guitar_shop_database.product_x_supply, guitar_shop_database.supply;

-- Удаление схемы
DROP SCHEMA guitar_shop_database
