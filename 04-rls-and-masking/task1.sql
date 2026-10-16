-- Задание 1. Создание таблицы skillbox_test, пользователей и настройка RLS
-- Выполняется от имени суперпользователя postgres

-- DDL-команда: создание таблицы
CREATE TABLE skillbox_test (
    id integer,
    login text,
    salary integer,
    phone text
);

-- DML-команды: вставка трёх строк
INSERT INTO skillbox_test (id, login, salary, phone) VALUES (1, 'SEMIONOV', 50000, '791101234567');
INSERT INTO skillbox_test (id, login, salary, phone) VALUES (2, 'DANILOV', 90000, '795301234567');
INSERT INTO skillbox_test (id, login, salary, phone) VALUES (3, 'ROMANOVA', 70000, '790401234567');

-- Проверка
SELECT * FROM skillbox_test;
COMMIT;

-- Создание тестовых учётных записей
-- Отдел сбыта
CREATE USER "SEMIONOV" WITH PASSWORD 'semionov';
CREATE USER "DANILOV" WITH PASSWORD 'danilov';
-- Бухгалтерия
CREATE USER "ROMANOVA" WITH PASSWORD 'romanova';

-- Настройка Row-Level Security (RLS)
-- 1. Включаем RLS на таблице
ALTER TABLE skillbox_test ENABLE ROW LEVEL SECURITY;

-- 2. Применяем RLS к владельцу таблицы
ALTER TABLE skillbox_test FORCE ROW LEVEL SECURITY;

-- 3. Выдаём пользователям право на чтение таблицы
GRANT SELECT ON skillbox_test TO "SEMIONOV", "DANILOV", "ROMANOVA";

-- 4. Политика для отдела сбыта: каждый видит только свою строку
CREATE POLICY sales_policy ON skillbox_test
    FOR SELECT
    USING (login = current_user);

-- 5. Политика для бухгалтерии: ROMANOVA видит все строки
CREATE POLICY accountant_policy ON skillbox_test
    FOR SELECT
    USING (current_user = 'ROMANOVA');

-- Проверка RLS
-- Проверка от имени SEMIONOV (должна быть 1 строка)
SET ROLE "SEMIONOV";
SELECT * FROM skillbox_test;
RESET ROLE;

-- Проверка от имени ROMANOVA (должны быть все 3 строки)
SET ROLE "ROMANOVA";
SELECT * FROM skillbox_test;
RESET ROLE;
