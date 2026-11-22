# Payper · Modelo de datos

> Documento de trabajo. Lo completas tú y lo revisamos juntos antes de crear las tablas en MySQL.
> Alcance: historias HU-01 a HU-07 del MVP (ver [ESPECIFICACION_PRODUCTO.md](./ESPECIFICACION_PRODUCTO.md)).

## 1. Entidades

Lista las "cosas" que la app necesita guardar. Pista: busca los sustantivos que se repiten en las historias.

| Entidad | ¿Qué representa? | Historia(s) donde aparece |
|---|---|---|
|  |  |  |

## 2. Tablas y columnas

Copia este bloque una vez por cada tabla.

### Tabla: `nombre_tabla`

| Columna | Tipo MySQL | ¿Obligatoria? | Restricciones (PK, FK, UNIQUE, CHECK…) | ¿Por qué? |
|---|---|---|---|---|
| id |  |  |  |  |
|  |  |  |  |  |

## 3. Relaciones

Describe cómo se conectan las tablas. Ejemplo de formato: "Un X tiene muchos Y; cada Y pertenece a un solo X".

-

## 4. Preguntas de diseño

Responde con tus palabras. No pasa nada si alguna queda en duda: la discutimos en la revisión.

1. **Dinero.** Los montos son enteros en COP. ¿Qué tipo de dato usarías? ¿Por qué `FLOAT` suele ser mala idea para dinero?
   - Respuesta:
2. **Correo único.** ¿Cómo garantiza la base de datos (no solo el código) que un correo pertenezca a una sola cuenta?
   - Respuesta:
3. **Presupuesto por mes.** ¿Cómo guardas "el mes" de un presupuesto? ¿Cómo evitas que un usuario tenga dos presupuestos para el mismo mes?
   - Respuesta:
4. **Tipo de movimiento.** Solo puede ser ingreso o gasto. ¿Qué opciones te da MySQL para restringirlo?
   - Respuesta:
5. **Categoría compatible.** Una categoría de gasto no se puede usar en un ingreso (HU-02). ¿Dónde guardarías el tipo de cada categoría? ¿Esa regla la valida la base de datos, el backend o ambos?
   - Respuesta:
6. **Contraseña.** ¿Se guarda tal cual? Investiga qué es *hashing* y qué hace *bcrypt*.
   - Respuesta:
7. **Privacidad (HU-01).** ¿Qué columna te permite asegurar que un usuario solo vea sus propios movimientos y presupuestos?
   - Respuesta:

## 5. Diagrama (opcional)

Si quieres, dibuja las tablas y sus relaciones en [dbdiagram.io](https://dbdiagram.io) o en papel, y enlaza o adjunta la imagen aquí.

## 6. Notas de la revisión

_Espacio para los comentarios y decisiones que salgan de la revisión._
