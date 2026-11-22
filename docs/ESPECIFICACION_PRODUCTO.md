# Payper · Especificación de producto

| Campo | Valor |
|---|---|
| Versión del documento | 0.1 |
| Estado | Propuesta de alcance |
| Producto | Aplicación web de presupuesto personal |
| Responsable de producto | [Nombre] |
| Repositorio | https://github.com/Nicolas-2001/Payper |

## 1. Solicitud del cliente

> Quiero registrar lo que gano y lo que gasto desde el celular. Al abrir la aplicación, quiero saber cuánto me queda del presupuesto del mes y cuáles son las categorías donde más gasto. Si me equivoco al registrar una compra, quiero poder corregirla y ver el cambio reflejado en mis totales. Más adelante quiero planear pagos que se repiten y apartar dinero para mis metas.

**Usuario principal.** Persona que administra su propio dinero y quiere revisar sus gastos y sus límites mensuales desde el celular o el computador.

**Supuestos de alcance.** Cuenta individual, montos en pesos colombianos (COP), meses calendario en hora de Colombia y registro manual de movimientos. La aplicación lleva un registro de las finanzas personales. La conexión bancaria y los pagos desde la app quedan fuera del alcance propuesto.

## 2. MVP · Versión 0.1

El primer lanzamiento debe permitir que una persona cree su cuenta, registre y corrija sus movimientos, defina un presupuesto mensual y revise cómo van sus gastos.

| Área | Entrega del MVP | Ampliación en el producto final |
|---|---|---|
| Cuenta | Registro, inicio y cierre de sesión | Recuperación de contraseña |
| Movimientos | Crear, consultar detalle, editar y eliminar | Movimientos recurrentes e importación CSV |
| Historial | Filtros por mes, tipo y categoría | Búsqueda y exportación CSV |
| Categorías | Catálogo inicial por tipo de movimiento | Creación, edición y archivado |
| Presupuesto | Un límite global por mes, con progreso y excedente | Límites mensuales por categoría |
| Tablero | Ingresos, gastos, balance del mes y gráfica de gastos por categoría | Tendencias, comparación mensual y próximos pagos |
| Metas | Se incorpora en la versión 1.0 | Metas de ahorro con aportes y progreso |

**Flujo de entrega.** Registro → inicio de sesión → historial → nuevo movimiento → detalle → edición o eliminación → tablero y presupuesto del mes.

## 3. Backlog del MVP

Cada historia puede convertirse en un issue de GitHub. Los criterios son condiciones comprobables para darla por aceptada.

### HU-01 · Crear y usar mi cuenta

Como usuario, quiero registrarme, entrar y cerrar sesión para consultar mis datos de forma privada.

- [ ] Puedo crear una cuenta con correo y contraseña. Un correo registrado permanece asociado a una sola cuenta.
- [ ] Con credenciales válidas entro al tablero. Si son incorrectas, recibo un mensaje y puedo volver a intentarlo.
- [ ] Al cerrar sesión, el historial y el tablero requieren volver a iniciar sesión.
- [ ] Los movimientos y presupuestos de otra cuenta quedan inaccesibles, incluso al abrir un enlace directo a su detalle.

### HU-02 · Registrar un ingreso o gasto

Como usuario, quiero anotar un movimiento para que aparezca en mi historial y se incluya en el mes correcto.

- [ ] Selecciono tipo, monto, fecha y categoría. La nota es opcional.
- [ ] El formulario acepta montos enteros mayores que cero y categorías compatibles con el tipo. Los campos inválidos se indican antes de guardar.
- [ ] Al guardar, el movimiento aparece en el historial del mes de su fecha y actualiza los totales correspondientes. El registro persiste al recargar.

### HU-03 · Consultar historial y detalle

Como usuario, quiero filtrar mis movimientos y abrir su detalle para encontrar una compra o un ingreso.

- [ ] El historial abre en el mes actual, ordenado por fecha, del más reciente al más antiguo.
- [ ] Puedo combinar filtros por mes, tipo y categoría. Cuando la selección queda vacía, veo un mensaje que lo indica.
- [ ] El detalle muestra tipo, monto, fecha, categoría y nota, si la registré.

### HU-04 · Editar un movimiento

Como usuario, quiero corregir un movimiento para mantener mis cifras al día.

- [ ] El formulario abre con los datos registrados y aplica las mismas validaciones de creación.
- [ ] Si cambio la fecha a otro mes, el movimiento desaparece del mes de origen y aparece en el destino. Los totales de ambos meses se actualizan.

### HU-05 · Eliminar un movimiento

Como usuario, quiero eliminar un registro duplicado o equivocado.

- [ ] La app solicita confirmación. Cancelar conserva el movimiento.
- [ ] Al confirmar, el movimiento desaparece del historial y se recalculan los totales y el progreso del presupuesto del mes correspondiente.

### HU-06 · Definir mi presupuesto mensual

Como usuario, quiero fijar un límite mensual y saber cuánto me queda antes de gastarlo.

- [ ] Puedo crear o ajustar un límite positivo para el mes seleccionado. Cada mes tiene su propio límite.
- [ ] Con un límite de $800.000 y gastos de $900.000, veo $100.000 de excedente.
- [ ] En un mes sin límite, puedo ver mis gastos y tengo acceso a la opción de configurar el presupuesto.

### HU-07 · Entender mi mes

Como usuario, quiero ver mis ingresos, gastos y balance junto con una gráfica para entender en qué se fue la plata.

- [ ] Al elegir un mes, veo la suma de ingresos, la suma de gastos y su diferencia.
- [ ] La gráfica muestra el gasto por categoría con una leyenda o lista de montos. La suma de las categorías coincide con el total de gastos.
- [ ] Si el mes está vacío, los totales aparecen en cero y la gráfica muestra un mensaje indicando que aún faltan movimientos.
- [ ] Puedo registrar un movimiento, abrir su detalle y consultar el tablero desde el celular y el computador.

## 4. Producto final · Versión 1.0

Al cierre de la versión 1.0, puedo preparar el mes antes de gastar, comprobar cuánto llevo por categoría, ver qué pagos se aproximan y seguir mis metas. El historial que registré durante el MVP sigue disponible.

| Historia | Como usuario… | Criterios de aceptación |
|---|---|---|
| HU-08 · Categorías propias | Quiero adaptar las categorías a mis gastos reales. | Puedo crear, renombrar y archivar categorías. Las archivadas conservan su historial y dejan de aparecer al crear movimientos. |
| HU-09 · Límites por categoría | Quiero saber qué categoría se acerca a su límite. | Puedo establecer un límite por categoría y mes. La app muestra el porcentaje consumido y distingue los estados de aviso (desde el 80 %) y excedente (más del 100 %). El límite global se calcula por separado. |
| HU-10 · Pagos recurrentes | Quiero ver los cobros que se repiten para preparar el mes. | Puedo programar, editar o pausar un pago mensual. Cada ocurrencia sigue pendiente hasta que la confirmo y solo puede generar un movimiento. Para una fecha como el día 31, un mes más corto usa su último día. |
| HU-11 · Metas de ahorro | Quiero apartar plata para una compra o un viaje. | Puedo fijar un monto objetivo y registrar o retirar aportes. Veo el monto acumulado y el porcentaje. Un aporte representa una asignación a la meta y deja intactos los totales de ingresos y gastos. |
| HU-12 · Comparar meses | Quiero saber cómo cambiaron mis gastos de un mes a otro. | Puedo seleccionar dos meses y comparar totales y categorías. Veo la diferencia en COP. La variación porcentual aparece cuando el mes base tiene un valor de referencia mayor que cero. |
| HU-13 · Buscar y exportar | Quiero encontrar movimientos y llevar mis datos a una hoja de cálculo. | Puedo buscar por nota y combinar la búsqueda con los filtros. El CSV exporta los resultados actuales e incluye encabezados de fecha, tipo, categoría, monto y nota. |
| HU-14 · Importar movimientos | Quiero cargar movimientos desde un archivo para ahorrar tiempo. | Puedo revisar las filas antes de confirmar. La app indica los errores por fila y los posibles duplicados. Solo se guardan las filas válidas que selecciono. Reintentar la misma importación confirmada conserva un solo registro por fila importada. |
| HU-15 · Recuperar acceso | Quiero restablecer mi contraseña si la olvido. | Puedo solicitar un enlace temporal de un solo uso. Después del cambio puedo entrar con la contraseña nueva. Un enlace usado o vencido requiere una nueva solicitud. |

## 5. Reglas compartidas

- **Balance del mes** = ingresos registrados − gastos registrados. Puede ser negativo y corresponde a los movimientos del mes, independientemente de lo que haya en una cuenta bancaria.
- **Margen del presupuesto** = límite del mes − gastos registrados. Un margen negativo se presenta como excedente en COP. Guardar un gasto por encima del límite está permitido.
- **Fecha del movimiento** determina el mes. Por ejemplo, un gasto del 31 de enero registrado el 1 de febrero pertenece a enero.
- **Cambios en movimientos** se reflejan en historial, totales, gráfica y presupuesto. En la versión final, los pagos pendientes se muestran en la agenda y se incorporan a los gastos cuando se confirman.
- **Accesibilidad y diseño adaptable.** Los formularios tienen etiquetas visibles y mensajes de error junto al campo. Los estados del presupuesto se distinguen con texto además del color.

## 6. Orden de entrega

| Hito | Historias | Resultado que revisa el cliente |
|---|---|---|
| MVP · 0.1 | HU-01 a HU-07 | Puedo registrar mis gastos desde el celular y comprobar cuánto llevo del presupuesto. |
| Planificación · 0.2 | HU-08 a HU-10 | Puedo organizar categorías, definir límites y anticipar cobros recurrentes. |
| Análisis y ahorro · 1.0 | HU-11 a HU-15 | Puedo seguir mis metas, comparar meses, gestionar mis datos y recuperar el acceso. |

### Caso de aceptación del MVP

Para noviembre, registro un ingreso de **$2.000.000**, un gasto de **$1.200.000** en vivienda y otro de **$300.000** en alimentación. Fijo el presupuesto en **$1.600.000**.

| Momento | Gastos de noviembre | Balance de noviembre | Margen del presupuesto |
|---|---:|---:|---:|
| Después de registrar ambos gastos | $1.500.000 | $500.000 | $100.000 |
| Después de corregir alimentación a $350.000 | $1.550.000 | $450.000 | $50.000 |
| Después de eliminar el gasto de alimentación | $1.200.000 | $800.000 | $400.000 |

En cada paso, el historial y la gráfica coinciden con los totales. Al recargar la aplicación, se mantienen los cambios.

## 7. Plantilla para nuevas historias en GitHub

```markdown
# HU-XX · [Acción que quiere realizar el usuario]

**Hito** · [MVP 0.1 / Planificación 0.2 / Producto final 1.0]
**Prioridad** · [Alta / Media / Baja]
**Dependencias** · [HU-XX, si aplica]

Como [tipo de usuario], quiero [acción] para [beneficio].

## Criterios de aceptación

- [ ] Dado [contexto], cuando [acción], entonces [resultado visible].
- [ ] Dado [caso de error o límite], cuando [acción], entonces [respuesta esperada].

## Reglas de negocio

- [Regla que afecta esta historia]

## Evidencia de aceptación

- [Prueba realizada, captura o enlace al PR]
```

Una historia se considera terminada cuando sus criterios pasan, los cambios se conservan al recargar si corresponde y el issue queda vinculado al PR o a la evidencia de aceptación.
