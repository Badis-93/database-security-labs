-- Задание 1. Создание схем
CREATE SCHEMA shema1;
CREATE SCHEMA shema2;

-- Задание 2. Создание пользователей
CREATE USER User1 WITH PASSWORD 'password1';
CREATE USER User2 WITH PASSWORD 'password2';

-- Задание 3. Права User1 на схемы
GRANT ALL PRIVILEGES ON SCHEMA shema1 TO User1;
GRANT ALL PRIVILEGES ON SCHEMA shema2 TO User1;

-- Задание 4. Таблица от имени User1
CREATE TABLE shema1.Table1 (col1 text);

-- Задание 5. Права User2 на INSERT
GRANT INSERT ON shema1.Table1 TO User2;

-- Задание 6. Добавление строки от User2
INSERT INTO shema1.Table1 (col1) VALUES ('test');
COMMIT;

-- Задание 7. Попытка SELECT от User2 → ошибка permission denied
SELECT * FROM shema1.Table1;

-- Задание 8. Проверка от User1 → строка видна
SELECT * FROM shema1.Table1;
