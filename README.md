# Práctica 7
Rebeca Moreno González

## Objetivo

Comprender qué son los procedimientos almacenados, las funciones definidas por el usuario y los triggers. Saber crearlos, ejecutarlos y utilizarlos para automatizar tareas y garantizar la integridad.

## Decisiones

En esta actividad se crearon procedimientos, funciones y triggers para automatizar diferentes tareas de la base de datos. Se implementó un procedimiento para aumentar el salario de los empleados y una función para contar los pedidos de cada cliente. También se creó una tabla de auditoría que registra automáticamente los nuevos pedidos y guarda información sobre las operaciones realizadas. Además, se desarrolló un resumen de ventas por cliente que se actualiza al registrar nuevos pedidos, facilitando la consulta de los totales de venta.

Para el reto, se utilizó la tabla `inventario` para guardar las existencias de cada producto y se implementó un trigger que verifica si hay suficientes unidades antes de registrar una venta. Cuando se agrega un producto a un pedido, el trigger revisa el stock disponible y, si hay suficientes unidades, descuenta automáticamente la cantidad vendida. En caso contrario, genera un error para evitar que se registren ventas sin tener los productos necesarios. Con esto se logró llevar un mejor control del inventario y evitar problemas con las existencias.

## Pruebas realizadas

**Para la actividad guiada:**

- Ejecuté el procedimiento `aumentar_salario` para comprobar que el salario de un empleado se incrementara correctamente.
- Utilicé la función `contar_pedidos` para verificar el número de pedidos asociados a cada cliente.
- Inserté nuevos registros en la tabla `pedido` para comprobar el funcionamiento del trigger de auditoría y confirmar que los movimientos se registraran en la tabla `auditoria_pedido`.
- Ejecuté el procedimiento `calcular_resumen_clientes` y después consulté la tabla `resumen_clientes` para verificar los totales de ventas.

**Para el reto:**

- Inserté registros válidos en `detalle_pedido` y comprobé que las cantidades disponibles en `inventario` disminuyeran correctamente.
- También intenté registrar una cantidad mayor al stock disponible para comprobar que el trigger generara la excepción correspondiente e impidiera la operación.

## Errores

El error que tuve al realizar esta práctica fue el SQL state: `42P07`, el cual ocurre cuando PostgreSQL intenta crear una tabla que ya existe en la base de datos. Este problema se solucionó utilizando sentencias como `DROP TABLE IF EXISTS` o `CREATE TABLE IF NOT EXISTS` antes de ejecutar nuevamente los scripts.

## Conclusión

En esta práctica aprendí a utilizar procedimientos, funciones y triggers para automatizar diferentes tareas dentro de una base de datos. También comprendí cómo registrar los pedidos, consultar las ventas de cada cliente y llevar un mejor control del inventario. Al realizar las pruebas, pude comprobar cómo estas herramientas ayudan a evitar errores y facilitan el manejo de la información. Siento que esta actividad me ayudó a reforzar mis conocimientos de SQL y a entender mejor cómo hacer que una base de datos sea más eficiente y confiable.
