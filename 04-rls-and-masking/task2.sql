-- Задание 2. Настройка маскирования через PostgreSQL Anonymizer
-- Выполняется от имени суперпользователя postgres

-- 1. Подключение расширения
CREATE EXTENSION IF NOT EXISTS anon CASCADE;

-- 2. Включение прозрачного динамического маскирования
ALTER DATABASE postgres SET anon.transparent_dynamic_masking TO true;

-- 3. Пометка ролей отдела сбыта как MASKED
SECURITY LABEL FOR anon ON ROLE "SEMIONOV" IS 'MASKED';
SECURITY LABEL FOR anon ON ROLE "DANILOV" IS 'MASKED';

-- 4. Настройка маскирования столбца phone
-- Показываем первые 4 символа, остальные заменяем на *
SECURITY LABEL FOR anon ON COLUMN skillbox_test.phone
    IS $$MASKED WITH FUNCTION anon.partial(phone, 4, '********', 0)$$;

-- Проверка маскирования
-- От имени SEMIONOV: телефон замаскирован (7911********)
SET ROLE "SEMIONOV";
SELECT * FROM skillbox_test;
RESET ROLE;

-- От имени ROMANOVA: телефон без маскирования
SET ROLE "ROMANOVA";
SELECT * FROM skillbox_test;
RESET ROLE;
