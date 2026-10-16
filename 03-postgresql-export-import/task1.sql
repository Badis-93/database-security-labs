-- Задание 1. Создание и заполнение таблицы Skillbox
-- Выполняется от имени суперпользователя postgres

-- DDL-команда: создание таблицы
CREATE TABLE Skillbox (
  col1 text
);

-- DML-команды: вставка трёх строк
INSERT INTO Skillbox (col1) VALUES ('Первый текст');
INSERT INTO Skillbox (col1) VALUES ('Второй текст');
INSERT INTO Skillbox (col1) VALUES ('Третий текст');

-- Проверка (необязательно)
SELECT * FROM Skillbox;

-- Сохраняем изменения
COMMIT;

-- Экспорт данных таблицы Skillbox с помощью pg_dump
-- Выполняется из терминала (не внутри psql):
-- pg_dump -U postgres -h localhost -d postgres -t Skillbox -f skillbox_export.sql
