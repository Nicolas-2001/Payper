# Payper · Modelo de datos

> Documento de trabajo. Lo completas tú y lo revisamos juntos antes de crear las tablas en MySQL.
> Alcance: historias HU-01 a HU-07 del MVP (ver [ESPECIFICACION_PRODUCTO.md](./ESPECIFICACION_PRODUCTO.md)).

## 1. Entidades

Lista las "cosas" que la app necesita guardar. Pista: busca los sustantivos que se repiten en las historias.

| Entidad         | ¿Qué representa?                         | Historia(s) donde aparece                       |
| --------------- | ---------------------------------------- | ----------------------------------------------- |
| users           | Los usuarios que estana en la aplicacion | HU-01, HU-02, HU-03, HU-04, HU-05, HU-06, HU-07 |
| categories      | Las categoria de cada transaccion        | HU-02, HU-03, HU-04, HU-07                      |
| budgets         | El presupuesto mensual de cada usuario   | HU-06, HU-07                                    |
| transactions    | Movimiento que hace el usuario           | HU-02, HU-03, HU-04, HU-05, HU-07               |

## 2. Tablas y columnas

Copia este bloque una vez por cada tabla.

### Tabla: `users`

| Columna         | Tipo MySQL        | ¿Obligatoria?             | Restricciones (PK, FK, UNIQUE, CHECK…)                                 | ¿Por qué?                                                          |
| --------------- | ----------------- | ------------------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------------ |
| `id`            | `BIGINT UNSIGNED` | Sí                        | `PRIMARY KEY`, `AUTO_INCREMENT`                                        | Identifica de forma única a cada usuario.                          |
| `name`          | `VARCHAR(100)`    | Sí                        | `NOT NULL`                                                             | Guarda el nombre que se muestra en la aplicación.                  |
| `email`         | `VARCHAR(254)`    | Sí                        | `NOT NULL`, `UNIQUE`                                                   | Identifica la cuenta al iniciar sesión y evita correos duplicados. |
| `password_hash` | `VARCHAR(255)`    | Sí                        | `NOT NULL`                                                             | Guarda el hash que el backend usa para verificar la contraseña.    |
| `is_active`     | `BOOLEAN`         | Sí, con valor por defecto | `NOT NULL`, `DEFAULT TRUE`, `CHECK (is_active IN (0, 1))`              | Las cuentas no se borran: se desactivan y conservan sus datos.     |
| `created_at`    | `DATETIME`        | Sí, automático            | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP`                                | Registra cuándo se creó la cuenta.                                 |
| `updated_at`    | `DATETIME`        | Sí, automático            | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP`, `ON UPDATE CURRENT_TIMESTAMP` | Registra cuándo se modificó la cuenta por última vez.              |

### Tabla: `categories`

| Columna       | Tipo MySQL                  | ¿Obligatoria?             | Restricciones (PK, FK, UNIQUE, CHECK…)                                  | ¿Por qué?                                                                            |
| ------------- | --------------------------- | ------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `id`          | `BIGINT UNSIGNED`           | Sí                        | `PRIMARY KEY`, `AUTO_INCREMENT`                                         | Identifica de forma única a cada categoría.                                          |
| `user_id`     | `BIGINT UNSIGNED`           | No                        | `NULL`, `FOREIGN KEY` → `users.id` `ON DELETE RESTRICT`                 | Si contiene un ID, la categoría es personal. Si es `NULL`, es global.                |
| `name`        | `VARCHAR(80)`               | Sí                        | `NOT NULL`                                                              | Es el nombre que ve el usuario al clasificar una transacción.                        |
| `type`        | `ENUM('income', 'expense')` | Sí                        | `NOT NULL`                                                              | Determina si las transacciones de esta categoría son ingresos o gastos.              |
| `is_active`   | `BOOLEAN`                   | Sí, con valor por defecto | `NOT NULL`, `DEFAULT TRUE`, `CHECK (is_active IN (0, 1))`               | Permite ocultar la categoría al registrar movimientos y conservarla en el historial. |
| `created_at`  | `DATETIME`                  | Sí, automático            | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP`                                 | Registra cuándo se creó la categoría.                                                |
| `updated_at`  | `DATETIME`                  | Sí, automático            | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP`, `ON UPDATE CURRENT_TIMESTAMP`  | Registra cuándo se modificó la categoría por última vez.                             |
| `global_name` | `VARCHAR(80)`               | No, calculada             | `GENERATED ALWAYS AS (CASE WHEN user_id IS NULL THEN name END) VIRTUAL` | Toma el nombre de las categorías globales para aplicarles una regla de unicidad.     |

- `UNIQUE (user_id, name, type)` evita categorías personales duplicadas para el mismo usuario y tipo.
- `UNIQUE (global_name, type)` evita categorías globales duplicadas del mismo tipo.
- El backend asigna `user_id` al crear la categoría y lo mantiene fijo al editarla.
- El `type` de una categoría no se puede cambiar después de crearla. Si cambiara, todos sus movimientos pasados pasarían de ingreso a gasto (o al revés) sin que el usuario lo note.
- Las categorías no se borran: se archivan con `is_active = FALSE`. Así conservan su historial (HU-08).
- En el MVP todas las categorías son globales (`user_id = NULL`). Las personales llegan con la HU-08 (versión 1.0).

### Tabla: `budgets`

| Columna      | Tipo MySQL        | ¿Obligatoria?  | Restricciones (PK, FK, UNIQUE, CHECK…)                                          | ¿Por qué?                                                                                          |
| ------------ | ----------------- | -------------- | ------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `id`         | `BIGINT UNSIGNED` | Sí             | `PRIMARY KEY`, `AUTO_INCREMENT`                                                 | Identifica de forma única a cada presupuesto.                                                      |
| `user_id`    | `BIGINT UNSIGNED` | Sí             | `NOT NULL`, `FOREIGN KEY` → `users.id` `ON DELETE RESTRICT`                     | Identifica al dueño del presupuesto.                                                               |
| `period`     | `DATE`            | Sí             | `NOT NULL`, `CHECK (DAYOFMONTH(period) = 1)` | Guarda el mes y el año usando el día `01`. Por ejemplo, `2026-11-01` representa noviembre de 2026. |
| `amount`     | `BIGINT`          | Sí             | `NOT NULL`, `CHECK (amount > 0)`                                                | Guarda en pesos enteros el límite que el usuario planea gastar durante el mes.                                       |
| `created_at` | `DATETIME`        | Sí, automático | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP`                                         | Registra cuándo se creó el presupuesto.                                                            |
| `updated_at` | `DATETIME`        | Sí, automático | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP`, `ON UPDATE CURRENT_TIMESTAMP`          | Registra cuándo se modificó el presupuesto por última vez.                                         |

- `UNIQUE (user_id, period)` permite como máximo un presupuesto por usuario y mes.
- El presupuesto es opcional. Si el usuario deja un mes sin configurar, ese mes queda sin fila.

### Tabla: `transactions`

| Columna            | Tipo MySQL        | ¿Obligatoria?  | Restricciones (PK, FK, UNIQUE, CHECK…)                                 | ¿Por qué?                                                                                    |
| ------------------ | ----------------- | -------------- | ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `id`               | `BIGINT UNSIGNED` | Sí             | `PRIMARY KEY`, `AUTO_INCREMENT`                                        | Identifica de forma única a cada transacción.                                                |
| `user_id`          | `BIGINT UNSIGNED` | Sí             | `NOT NULL`, `FOREIGN KEY` → `users.id` `ON DELETE RESTRICT`            | Identifica al dueño del movimiento, incluso si usa una categoría global.                     |
| `category_id`      | `BIGINT UNSIGNED` | Sí             | `NOT NULL`, `FOREIGN KEY` → `categories.id` `ON DELETE RESTRICT`       | Clasifica el movimiento y permite identificar si es un ingreso o un gasto.                   |
| `transaction_date` | `DATE`            | Sí             | `NOT NULL`                                                             | Indica cuándo ocurrió el movimiento y a qué mes corresponde.                                 |
| `amount`           | `BIGINT`          | Sí             | `NOT NULL`, `CHECK (amount > 0)`                                       | Guarda en pesos enteros el valor positivo del movimiento. La categoría determina si es un ingreso o un gasto. |
| `note`             | `VARCHAR(255)`    | No             | Admite `NULL`                                                          | Nota opcional sobre el movimiento. Se llama igual que en la especificación y la interfaz.                                      |
| `created_at`       | `DATETIME`        | Sí, automático | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP`                                | Registra cuándo se ingresó el movimiento en Payper.                                          |
| `updated_at`       | `DATETIME`        | Sí, automático | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP`, `ON UPDATE CURRENT_TIMESTAMP` | Registra cuándo se modificó el movimiento por última vez.                                    |

- Al crear o editar una transacción, el backend verifica que la categoría sea global o pertenezca al usuario autenticado.
- El gasto mensual se calcula sumando las transacciones de tipo `expense` de ese usuario en el mes correspondiente.
- `INDEX idx_transactions_user_date (user_id, transaction_date)` acelera la consulta principal de la app: movimientos de un usuario en un mes. MySQL también usa este índice para la llave foránea de `user_id`, así que no crea uno aparte.
- Para filtrar por mes se usa un rango de fechas, no funciones sobre la columna:

  ```sql
  WHERE user_id = ? AND transaction_date >= '2026-11-01' AND transaction_date < '2026-12-01'
  ```

  Si se escribe `MONTH(transaction_date) = 11`, MySQL tiene que calcular la función en cada fila y no puede usar el índice.

## 3. Relaciones

- **Usuarios y transacciones (1:N).** Un usuario puede tener muchas transacciones. Cada transacción pertenece a un solo usuario mediante `transactions.user_id`.
- **Usuarios y presupuestos mensuales (1:N).** Un usuario puede tener presupuestos en varios meses, con un máximo de uno por mes. Cada presupuesto pertenece a un solo usuario mediante `budgets.user_id`.
- **Usuarios y categorías personales (1:N).** Un usuario puede tener muchas categorías personales. Cada categoría personal pertenece a un solo usuario mediante `categories.user_id`. Si ese campo es `NULL`, la categoría es global y todos pueden usarla.
- **Categorías y transacciones (1:N).** Una categoría puede usarse en muchas transacciones. Cada transacción tiene una sola categoría mediante `transactions.category_id`.

Para saber cuánto se ha usado del presupuesto mensual, sumo las transacciones de gasto del mismo usuario dentro de ese mes.

## 4. Preguntas de diseño

1. **Dinero.** Los montos son enteros en COP. ¿Qué tipo de dato usarías? ¿Por qué `FLOAT` suele ser mala idea para dinero?
   - **Respuesta.** Uso `BIGINT` en `transactions.amount` y `budgets.amount` para guardar los montos en pesos enteros. Por ejemplo, $25.000 COP se guarda como `25000`. Añadiría `NOT NULL` y `CHECK (amount > 0)`. `FLOAT` trabaja con valores aproximados, así que puede perder precisión al guardar o sumar montos.

2. **Correo único.** ¿Cómo garantiza la base de datos que un correo pertenezca a una sola cuenta?
   - **Respuesta.** Pondría `NOT NULL` y `UNIQUE (email)` en la tabla `users`. Así, la base de datos exige un correo para cada cuenta y rechaza un registro si ese correo ya existe.

3. **Presupuesto por mes.** ¿Cómo guardas el mes de un presupuesto? ¿Cómo evitas que un usuario tenga dos presupuestos para el mismo mes?
   - **Respuesta.** Usaría `period` de tipo `DATE` y guardaría siempre el primer día del mes. Por ejemplo, `2026-11-01` representa noviembre de 2026. Validaría el día con `CHECK (DAYOFMONTH(period) = 1)` y usaría `UNIQUE (user_id, period)` para evitar duplicados. Si el usuario deja un mes sin presupuesto, ese mes queda sin fila.

4. **Tipo de movimiento.** Solo puede ser ingreso o gasto. ¿Qué opciones te da MySQL para restringirlo?
   - **Respuesta.** Puedo usar `ENUM('income', 'expense')` con MySQL en modo estricto, o un `VARCHAR` con `CHECK (type IN ('income', 'expense'))`. En ambos casos pondría `NOT NULL`. Para Payper usaría `ENUM` en `categories.type`.

5. **Categoría compatible (HU-02).** ¿Dónde guardarías el tipo de cada categoría? ¿Esa regla la valida la base de datos, el backend o ambos?
   - **Respuesta.** Guardaría el tipo en `categories.type`. Si el usuario selecciona **Ingreso**, el backend comprueba que la categoría elegida sea `income` y que sea global o le pertenezca. MySQL garantiza que la categoría exista y tenga un tipo válido. El backend comprueba que coincida con el tipo seleccionado. La transacción guarda `category_id` y obtiene su tipo a través de esa categoría.

6. **Contraseña.** ¿Se guarda tal cual? ¿Qué es *hashing* y qué hace `bcrypt`?
   - **Respuesta.** En `users.password_hash` guardaría el hash de la contraseña. El *hashing* transforma la contraseña en un valor que permite verificarla al iniciar sesión sin tener que recuperar el texto original. `bcrypt` genera ese hash usando un valor aleatorio llamado *salt* y un costo configurable que hace más lento probar muchas contraseñas.

7. **Privacidad (HU-01).** ¿Qué columna te permite asegurar que un usuario solo vea sus propios movimientos y presupuestos?
   - **Respuesta.** Usaría `user_id` en `transactions` y `budgets`. El backend toma el ID del usuario autenticado y aplica `WHERE user_id = ?` al listar sus datos. Para consultar, editar o eliminar un registro específico, usa `WHERE id = ? AND user_id = ?`.

## 5. Diagrama (opcional)

Si quieres, dibuja las tablas y sus relaciones en [dbdiagram.io](https://dbdiagram.io) o en papel, y enlaza o adjunta la imagen aquí.

## 6. Notas de la revisión

### Revisión 1 · 23 de noviembre de 2026

| Tema | Decisión | Motivo |
|---|---|---|
| Tipo de dato del dinero | `BIGINT` con `CHECK (amount > 0)` en `transactions` y `budgets` | La especificación pide montos enteros en COP. Antes las tablas decían `DECIMAL(14,2)` y la respuesta 1 decía `BIGINT`. |
| Borrar un usuario | No se permite: se desactiva con `is_active = FALSE`. `ON DELETE RESTRICT` en `transactions`, `budgets` y `categories` | Se conserva el historial y ningún dato queda huérfano. La base de datos rechaza un `DELETE` por error. |
| Borrar una categoría usada | No se permite: se desactiva con `is_active = FALSE`. `ON DELETE RESTRICT` en `transactions.category_id` | Conserva su historial (HU-08). |
| Índice principal | `(user_id, transaction_date)` en `transactions` | Historial, tablero y presupuesto consultan "movimientos de un usuario en un mes". |
| Filtro por mes | Rango de fechas (`>=` primer día y `<` primer día del mes siguiente) | Permite usar el índice. |
| Tipo de categoría | No se puede cambiar después de crearla | Evita que cambie el significado de los movimientos pasados. |
| `period` | Solo `CHECK (DAYOFMONTH(period) = 1)` | `MONTH(...) BETWEEN 1 AND 12` sobraba: un `DATE` siempre tiene un mes válido. |
| Fechas de auditoría | `DATETIME` en lugar de `TIMESTAMP` | `TIMESTAMP` solo llega hasta enero de 2038. |
| Nota del movimiento | La columna se llama `note` | Mismo nombre en la especificación, la base de datos, la API y React. |

**Requisito técnico.** MySQL 8.0.16 o superior, porque en versiones anteriores los `CHECK` se aceptan pero se ignoran.

**Consecuencias de desactivar una cuenta.**

- El inicio de sesión rechaza a un usuario con `is_active = FALSE`.
- Su correo sigue ocupado por `UNIQUE (email)`. Si la persona vuelve, se reactiva su cuenta; no se crea una nueva.

**Pendiente de decidir.** `users.name` no lo pide la especificación. Se queda, pero el formulario de registro tendrá el campo nombre.
