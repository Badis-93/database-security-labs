# Практическая работа: RLS и маскирование данных в PostgreSQL

## 🎯 Цель работы
Закрепить навыки использования инструмента ограничения видимости данных на уровне строк (Row-Level Security) и маскирования данных (PostgreSQL Anonymizer).

## 📋 Задание
1. Создать таблицу skillbox_test с данными сотрудников, настроить RLS так, чтобы сотрудники отдела сбыта видели только свои строки, а бухгалтерия — все.
2. Настроить маскирование телефона для сотрудников отдела сбыта: первые 4 символа видны, остальные заменены на *.

## 🛠️ Использованные инструменты
- PostgreSQL
- Row-Level Security (RLS)
- PostgreSQL Anonymizer
- SQL: CREATE TABLE, CREATE USER, GRANT, CREATE POLICY, SECURITY LABEL
- Мета-команды: SET ROLE, RESET ROLE

## 📦 Файлы

- [task1.sql](task1.sql) — создание таблицы, пользователей и настройка RLS
- [task2.sql](task2.sql) — подключение Anonymizer и настройка маскирования

## 📸 Задание 1. Создание таблицы и настройка RLS

### Создание таблицы и заполнение

-- Выполняется от имени суперпользователя postgres
CREATE TABLE skillbox_test (
    id integer,
    login text,
    salary integer,
    phone text
);

INSERT INTO skillbox_test (id, login, salary, phone) VALUES (1, 'SEMIONOV', 50000, '791101234567');
INSERT INTO skillbox_test (id, login, salary, phone) VALUES (2, 'DANILOV', 90000, '795301234567');
INSERT INTO skillbox_test (id, login, salary, phone) VALUES (3, 'ROMANOVA', 70000, '790401234567');

Создана таблица skillbox_test с четырьмя полями: id, login, salary, phone. Добавлены три строки с данными сотрудников.

### Создание пользователей

-- Отдел сбыта
CREATE USER "SEMIONOV" WITH PASSWORD 'semionov';
CREATE USER "DANILOV" WITH PASSWORD 'danilov';
-- Бухгалтерия
CREATE USER "ROMANOVA" WITH PASSWORD 'romanova';

Созданы три учётные записи: SEMIONOV, DANILOV (отдел сбыта) и ROMANOVA (бухгалтерия).

### Настройка RLS

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

### Пояснения

| Команда | Назначение |
|---------|-----------|
| ENABLE ROW LEVEL SECURITY | Включает RLS на таблице |
| FORCE ROW LEVEL SECURITY | Применяет RLS даже к владельцу таблицы |
| GRANT SELECT ON | Даёт пользователям право читать таблицу |
| CREATE POLICY sales_policy | Политика: строка видна, если login = current_user |
| CREATE POLICY accountant_policy | Политика: ROMANOVA видит все строки |

### Проверка RLS

-- От имени SEMIONOV — 1 строка (только своя)
SET ROLE "SEMIONOV";
SELECT * FROM skillbox_test;
RESET ROLE;

-- От имени ROMANOVA — 3 строки (все)
SET ROLE "ROMANOVA";
SELECT * FROM skillbox_test;
RESET ROLE;

**Результат:** сотрудники отдела сбыта видят только свою строку, бухгалтерия — все три строки. RLS работает корректно.

## 📸 Задание 2. Настройка маскирования

### Подключение Anonymizer и настройка

-- 1. Подключение расширения
CREATE EXTENSION IF NOT EXISTS anon CASCADE;

-- 2. Включение прозрачного динамического маскирования
ALTER DATABASE postgres SET anon.transparent_dynamic_masking TO true;

-- 3. Пометка ролей отдела сбыта как MASKED
SECURITY LABEL FOR anon ON ROLE "SEMIONOV" IS 'MASKED';
SECURITY LABEL FOR anon ON ROLE "DANILOV" IS 'MASKED';

-- 4. Настройка маскирования столбца phone
SECURITY LABEL FOR anon ON COLUMN skillbox_test.phone
    IS $$MASKED WITH FUNCTION anon.partial(phone, 4, '********', 0)$$;

### Пояснения

| Команда | Назначение |
|---------|-----------|
| CREATE EXTENSION anon | Подключает расширение PostgreSQL Anonymizer |
| ALTER DATABASE ... transparent_dynamic_masking | Включает прозрачное маскирование для БД |
| SECURITY LABEL ON ROLE ... 'MASKED' | Помечает роль как требующую маскирования |
| SECURITY LABEL ON COLUMN ... | Задаёт функцию маскирования для столбца |

### Разбор функции anon.partial

anon.partial(phone, 4, '********', 0)

| Параметр | Значение | Назначение |
|----------|----------|------------|
| phone | столбец | Какой столбец маскировать |
| 4 | 4 символа слева | Сколько символов оставить видимыми |
| '********' | 8 звёздочек | Чем заменить остальные символы |
| 0 | 0 символов справа | Сколько символов оставить справа |

**Итог:** `791101234567` → `7911********`

### Проверка маскирования

-- От имени SEMIONOV: телефон замаскирован
SET ROLE "SEMIONOV";
SELECT * FROM skillbox_test;
RESET ROLE;

**Результат:** строка SEMIONOV, телефон отображается как `7911********`.

-- От имени ROMANOVA: телефон без маскирования
SET ROLE "ROMANOVA";
SELECT * FROM skillbox_test;
RESET ROLE;

**Результат:** все три строки, телефоны видны полностью (`791101234567`, `795301234567`, `790401234567`).

## 📊 Выводы
- Освоена настройка Row-Level Security в PostgreSQL: пользователи видят только разрешённые строки.
- Изучено применение RLS FORCE — политика действует даже на владельца таблицы.
- Отработано создание политик с условием по current_user.
- Освоено подключение расширения PostgreSQL Anonymizer.
- Настроено прозрачное динамическое маскирование на уровне БД.
- Отработана функция anon.partial для частичного маскирования (первые 4 символа видны, остальные скрыты).
- Проверено поведение: отдел сбыта видит замаскированные данные, бухгалтерия — без маскирования.

## 🧠 Чему научился
- Настройка RLS в PostgreSQL: ENABLE, FORCE, CREATE POLICY.
- Использование SET ROLE / RESET ROLE для проверки прав.
- Создание политик на основе current_user.
- Установка расширения anon через CREATE EXTENSION.
- Пометка ролей через SECURITY LABEL.
- Настройка маскирования столбца через SECURITY LABEL ON COLUMN.
- Работа с функцией anon.partial для частичного маскирования.
- Понимание разницы между RLS (ограничение видимости строк) и маскированием (изменение содержимого столбца).

## 🔐 Практическая значимость
RLS и маскирование — ключевые инструменты защиты данных в БД:
- RLS ограничивает доступ к строкам на основе роли пользователя;
- маскирование скрывает часть чувствительных данных от неавторизованных сотрудников;
- совместное применение даёт многоуровневую защиту;
- RLS часто используется для мультитенантных приложений и разграничения доступа между отделами;
- маскирование — для защиты персональных данных (номера телефонов, паспорта, карты).

В реальной работе эти инструменты применяются при выполнении требований 152-ФЗ (защита персональных данных), PCI DSS (защита платёжных данных) и внутренних политик безопасности.

## ⚠️ Особенности выполнения
- **FORCE ROW LEVEL SECURITY** нужен, чтобы RLS действовал даже для владельца таблицы. Без этого владелец видел бы все строки в обход политик.
- **SECURITY LABEL** — специальный синтаксис PostgreSQL для меток безопасности. Не путать с обычными COMMENT.
- **$$ ... $$** — dollar-quoting в PostgreSQL. Используется, чтобы избежать конфликтов с кавычками внутри строки.
- **SET ROLE / RESET ROLE** — переключение на другого пользователя в текущей сессии без переподключения. Удобно для проверки прав.
- **anon.partial** принимает 4 аргумента: имя столбца, количество символов слева, маска, количество символов справа.
- **Прозрачное динамическое маскирование** работает через `anon.transparent_dynamic_masking = true`. Без этой настройки метки не сработают.
