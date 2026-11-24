-- =====================================================================
-- Payper · Catálogo inicial de categorías (MVP)
-- Corre este script justo después de schema.sql.
--
-- Todas son globales (user_id = NULL): las ve cualquier usuario.
-- Vivienda, Alimentación y Salario son las del caso de aceptación del MVP.
--
-- Si lo corres dos veces seguidas falla a propósito, por el UNIQUE
-- (global_name, type). Para empezar de cero, corre schema.sql otra vez.
-- =====================================================================

-- Fija la codificación de esta conexión. Sin esto, un cliente configurado
-- en latin1 guarda mal las tildes (la "ó" queda como "Ã³").
SET NAMES utf8mb4;

USE payper;

INSERT INTO categories (name, type) VALUES
  -- Ingresos
  ('Salario',          'income'),
  ('Trabajo extra',    'income'),
  ('Ventas',           'income'),
  ('Otros',            'income'),

  -- Gastos
  ('Vivienda',         'expense'),
  ('Alimentación',     'expense'),
  ('Transporte',       'expense'),
  ('Servicios',        'expense'),
  ('Salud',            'expense'),
  ('Educación',        'expense'),
  ('Entretenimiento',  'expense'),
  ('Ropa',             'expense'),
  ('Deudas',           'expense'),
  ('Otros',            'expense');  -- mismo nombre que arriba, distinto tipo: permitido
