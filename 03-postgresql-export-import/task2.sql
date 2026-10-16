-- Задание 2. Создание БД imp и импорт данных
-- Выполняется от имени суперпользователя postgres

-- 1. Создание новой базы данных imp
CREATE DATABASE imp;

-- 2. Импорт данных из файла экспорта
-- Выполняется из терминала (не внутри psql):
-- psql -U postgres -h localhost -d imp -f skillbox_export.sql

-- 3. Проверка наличия данных в таблице Skillbox
\c imp
SELECT * FROM Skillbox;
