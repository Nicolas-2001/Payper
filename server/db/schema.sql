-- =====================================================================
-- Payper · Esquema de base de datos del MVP (HU-01 a HU-07)
-- Diseño y decisiones: docs/modelo-datos.md
--
-- Requiere MySQL 8.0.16 o superior: en versiones anteriores los CHECK
-- se aceptan pero se ignoran sin avisar.
--
-- ATENCIÓN: este script BORRA las tablas y las vuelve a crear.
-- Úsalo solo en desarrollo. Después corre seed.sql para las categorías.
-- =====================================================================

-- Fija la codificación de esta conexión. Sin esto, un cliente configurado
-- en latin1 guarda mal las tildes (la "ó" queda como "Ã³").
SET NAMES utf8mb4;

-- utf8mb4 guarda cualquier carácter (tildes, eñes, emojis).
-- utf8mb4_0900_ai_ci compara sin distinguir mayúsculas ni tildes:
-- "Alimentación" y "alimentacion" cuentan como el mismo nombre.
CREATE DATABASE IF NOT EXISTS payper
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE payper;

-- Se borran en orden inverso a las dependencias: primero las tablas
-- que apuntan a otras, al final las que solo reciben referencias.
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS budgets;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;


-- ---------------------------------------------------------------------
-- users · HU-01
-- Las cuentas no se borran: se desactivan con is_active = FALSE.
-- ---------------------------------------------------------------------
CREATE TABLE users (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name          VARCHAR(100)    NOT NULL,
  email         VARCHAR(254)    NOT NULL,
  password_hash VARCHAR(255)    NOT NULL,  -- hash de bcrypt, nunca la contraseña
  is_active     BOOLEAN         NOT NULL DEFAULT TRUE,
  created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  CONSTRAINT uq_users_email      UNIQUE (email),
  -- BOOLEAN en MySQL es TINYINT(1): sin este CHECK aceptaría un 5.
  CONSTRAINT chk_users_is_active CHECK (is_active IN (0, 1))
) ENGINE = InnoDB;


-- ---------------------------------------------------------------------
-- categories · HU-02, HU-03, HU-07 (y HU-08 en la versión 1.0)
-- user_id NULL  = categoría global (catálogo inicial, la ven todos).
-- user_id con ID = categoría personal (llega con la HU-08).
-- El type no se cambia después de crear la categoría (regla del backend).
-- ---------------------------------------------------------------------
CREATE TABLE categories (
  id          BIGINT UNSIGNED           NOT NULL AUTO_INCREMENT,
  user_id     BIGINT UNSIGNED           NULL,
  name        VARCHAR(80)               NOT NULL,
  type        ENUM('income', 'expense') NOT NULL,
  is_active   BOOLEAN                   NOT NULL DEFAULT TRUE,
  created_at  DATETIME                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME                  NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,

  -- Columna calculada: vale name si la categoría es global y NULL si es
  -- personal. Existe solo para el UNIQUE de abajo.
  global_name VARCHAR(80)
              GENERATED ALWAYS AS (CASE WHEN user_id IS NULL THEN name END) VIRTUAL,

  PRIMARY KEY (id),
  -- Evita duplicados entre las categorías personales de un usuario.
  -- No sirve para las globales: en un UNIQUE, dos NULL no son iguales.
  CONSTRAINT uq_categories_user_name_type   UNIQUE (user_id, name, type),
  -- Por eso este segundo UNIQUE evita duplicados entre las globales.
  CONSTRAINT uq_categories_global_name_type UNIQUE (global_name, type),
  CONSTRAINT chk_categories_is_active       CHECK (is_active IN (0, 1)),
  CONSTRAINT fk_categories_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
) ENGINE = InnoDB;


-- ---------------------------------------------------------------------
-- budgets · HU-06
-- Un límite global por usuario y mes. period siempre es el día 01:
-- 2026-11-01 representa noviembre de 2026.
-- Un mes sin presupuesto simplemente no tiene fila.
-- ---------------------------------------------------------------------
CREATE TABLE budgets (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id    BIGINT UNSIGNED NOT NULL,
  period     DATE            NOT NULL,
  amount     BIGINT          NOT NULL,  -- pesos enteros (COP)
  created_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                             ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  -- Un presupuesto por mes. Este índice también sirve a la llave foránea
  -- de user_id, así que MySQL no crea otro.
  CONSTRAINT uq_budgets_user_period       UNIQUE (user_id, period),
  CONSTRAINT chk_budgets_period_first_day CHECK (DAYOFMONTH(period) = 1),
  CONSTRAINT chk_budgets_amount           CHECK (amount > 0),
  CONSTRAINT fk_budgets_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
) ENGINE = InnoDB;


-- ---------------------------------------------------------------------
-- transactions · HU-02 a HU-05, HU-07
-- El tipo (ingreso o gasto) sale de la categoría, no se guarda aquí.
-- transaction_date decide el mes al que pertenece el movimiento.
-- ---------------------------------------------------------------------
CREATE TABLE transactions (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id          BIGINT UNSIGNED NOT NULL,
  category_id      BIGINT UNSIGNED NOT NULL,
  transaction_date DATE            NOT NULL,
  amount           BIGINT          NOT NULL,  -- pesos enteros (COP), siempre positivo
  note             VARCHAR(255)    NULL,
  created_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  -- Consulta principal de la app: movimientos de un usuario en un mes.
  -- Filtra con un rango para que el índice se use:
  --   WHERE user_id = ? AND transaction_date >= '2026-11-01'
  --                     AND transaction_date <  '2026-12-01'
  INDEX idx_transactions_user_date (user_id, transaction_date),
  INDEX idx_transactions_category  (category_id),
  CONSTRAINT chk_transactions_amount CHECK (amount > 0),
  CONSTRAINT fk_transactions_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  -- Una categoría con movimientos no se puede borrar: se desactiva.
  CONSTRAINT fk_transactions_category
    FOREIGN KEY (category_id) REFERENCES categories (id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
) ENGINE = InnoDB;
