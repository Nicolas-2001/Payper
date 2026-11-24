-- =====================================================================
-- Payper · Pruebas de las restricciones de la base de datos
--
-- Cada prueba marcada "DEBE FALLAR" tiene que dar error. Si alguna
-- pasa sin error, hay una regla que no se está aplicando.
--
-- Todo corre dentro de una transacción que termina en ROLLBACK, así que
-- no deja datos en la base. Requiere haber corrido schema.sql y seed.sql.
--
-- Cómo correrlo sin que se detenga en el primer error:
--   Terminal:  mysql -u root -p --force < server/db/pruebas.sql
--   Workbench: activa "Continue on SQL Script Error" (el ícono del rayo
--              con el signo de admiración) y ejecuta todo con Ctrl+Shift+Enter.
-- =====================================================================

-- Fija la codificación de esta conexión. Sin esto, un cliente configurado
-- en latin1 guarda mal las tildes (la "ó" queda como "Ã³").
SET NAMES utf8mb4;

USE payper;

START TRANSACTION;

-- ---------------------------------------------------------------------
-- Datos de prueba (estas sentencias SÍ deben funcionar)
-- ---------------------------------------------------------------------
INSERT INTO users (name, email, password_hash)
VALUES ('Prueba', 'prueba@payper.test', 'hash-de-prueba');
SET @user_id = LAST_INSERT_ID();

SET @vivienda = (SELECT id FROM categories WHERE global_name = 'Vivienda' AND type = 'expense');

INSERT INTO transactions (user_id, category_id, transaction_date, amount)
VALUES (@user_id, @vivienda, '2026-11-05', 1200000);

INSERT INTO budgets (user_id, period, amount)
VALUES (@user_id, '2026-11-01', 1600000);

SELECT 'Datos de prueba creados. Desde aquí, cada prueba debe dar ERROR.' AS paso;


-- ---------------------------------------------------------------------
-- users
-- ---------------------------------------------------------------------
-- 1. DEBE FALLAR · correo repetido → uq_users_email
INSERT INTO users (name, email, password_hash)
VALUES ('Otra', 'prueba@payper.test', 'hash');

-- 2. DEBE FALLAR · is_active fuera de 0/1 → chk_users_is_active
INSERT INTO users (name, email, password_hash, is_active)
VALUES ('Otra', 'otra@payper.test', 'hash', 5);

-- 3. DEBE FALLAR · borrar un usuario con datos → fk_transactions_user
DELETE FROM users WHERE id = @user_id;


-- ---------------------------------------------------------------------
-- categories
-- ---------------------------------------------------------------------
-- 4. DEBE FALLAR · categoría global repetida → uq_categories_global_name_type
INSERT INTO categories (name, type) VALUES ('Vivienda', 'expense');

-- 5. DEBE FALLAR · igual que la 4, sin tilde ni mayúscula (collation ai_ci)
INSERT INTO categories (name, type) VALUES ('alimentacion', 'expense');

-- 6. DEBE FALLAR · tipo inválido → ENUM en modo estricto
INSERT INTO categories (name, type) VALUES ('Mascotas', 'gasto');

-- 7. DEBE FALLAR · borrar una categoría con movimientos → fk_transactions_category
DELETE FROM categories WHERE id = @vivienda;


-- ---------------------------------------------------------------------
-- budgets
-- ---------------------------------------------------------------------
-- 8. DEBE FALLAR · period que no es día 01 → chk_budgets_period_first_day
INSERT INTO budgets (user_id, period, amount)
VALUES (@user_id, '2026-12-15', 800000);

-- 9. DEBE FALLAR · segundo presupuesto para noviembre → uq_budgets_user_period
INSERT INTO budgets (user_id, period, amount)
VALUES (@user_id, '2026-11-01', 900000);

-- 10. DEBE FALLAR · límite en cero → chk_budgets_amount
INSERT INTO budgets (user_id, period, amount)
VALUES (@user_id, '2027-01-01', 0);


-- ---------------------------------------------------------------------
-- transactions
-- ---------------------------------------------------------------------
-- 11. DEBE FALLAR · monto en cero → chk_transactions_amount
INSERT INTO transactions (user_id, category_id, transaction_date, amount)
VALUES (@user_id, @vivienda, '2026-11-06', 0);

-- 12. DEBE FALLAR · monto negativo → chk_transactions_amount
INSERT INTO transactions (user_id, category_id, transaction_date, amount)
VALUES (@user_id, @vivienda, '2026-11-06', -5000);

-- 13. DEBE FALLAR · categoría que no existe → fk_transactions_category
INSERT INTO transactions (user_id, category_id, transaction_date, amount)
VALUES (@user_id, 999999, '2026-11-06', 5000);

-- 14. DEBE FALLAR · usuario que no existe → fk_transactions_user
INSERT INTO transactions (user_id, category_id, transaction_date, amount)
VALUES (999999, @vivienda, '2026-11-06', 5000);


-- ---------------------------------------------------------------------
-- Casos válidos (estas sentencias SÍ deben funcionar)
-- ---------------------------------------------------------------------
SELECT 'Fin de los errores esperados. Lo que sigue debe funcionar.' AS paso;

-- Presupuesto de otro mes para el mismo usuario
INSERT INTO budgets (user_id, period, amount)
VALUES (@user_id, '2026-12-01', 800000);

-- Categoría personal con el mismo nombre que una global
INSERT INTO categories (user_id, name, type) VALUES (@user_id, 'Vivienda', 'expense');

-- Desactivar una categoría con movimientos (en lugar de borrarla)
UPDATE categories SET is_active = FALSE WHERE id = @vivienda;

-- Consulta del mes con rango de fechas: EXPLAIN debe mostrar
-- key = idx_transactions_user_date
EXPLAIN
SELECT * FROM transactions
WHERE user_id = @user_id
  AND transaction_date >= '2026-11-01'
  AND transaction_date <  '2026-12-01';

ROLLBACK;

SELECT 'Pruebas terminadas. ROLLBACK aplicado: la base quedó como estaba.' AS paso;
