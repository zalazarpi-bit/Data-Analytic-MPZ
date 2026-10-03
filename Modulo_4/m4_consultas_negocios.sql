

--Antes de avanzar con las consignas del checkpoint se actualiza la base de datos-- 

USE Ventas_Tech_DB;
GO

DELETE FROM ventas WHERE id_venta > 10;

INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
    (11, 2, 2,  3,   28.00, '2024-01-12'),
    (12, 3, 6,  1,   95.00, '2024-01-18'),
    (13, 1, 4,  2,  120.00, '2024-01-25'),
    (14, 5, 2,  4,   28.00, '2024-01-30'),
    (15, 4, 3,  1,  450.00, '2024-02-05'),
    (16, 2, 5,  2,  130.00, '2024-02-09'),
    (17, 1, 6,  3,   95.00, '2024-02-14'),
    (18, 3, 4,  1,  120.00, '2024-02-20'),
    (19, 5, 2,  5,   28.00, '2024-02-27'),
    (20, 1, 1,  1, 1200.00, '2024-04-03'),
    (21, 3, 3,  2,  450.00, '2024-04-08'),
    (22, 2, 4,  3,  120.00, '2024-04-15'),
    (23, 5, 5,  2,  130.00, '2024-04-19'),
    (24, 4, 6,  2,   95.00, '2024-04-24'),
    (25, 1, 2,  6,   28.00, '2024-04-29'),
    (26, 2, 1,  2, 1200.00, '2024-05-06'),
    (27, 4, 3,  1,  450.00, '2024-05-11'),
    (28, 3, 5,  3,  130.00, '2024-05-17'),
    (29, 5, 4,  1,  120.00, '2024-05-23'),
    (30, 1, 6,  2,   95.00, '2024-05-28'),
    (31, 3, 1,  1, 1200.00, '2024-06-04'),
    (32, 2, 2, 10,   28.00, '2024-06-11'),
    (33, 4, 4,  2,  120.00, '2024-06-18'),
    (34, 5, 3,  1,  450.00, '2024-06-25');

SELECT COUNT(*) AS ventas, COUNT(DISTINCT MONTH(fecha_venta)) AS meses
FROM ventas;
GO

--Consultas SQL de negocio--
--El equipo comercial de RetailPro necesita respuestas rápidas antes de la reunión del lunes. --
--No quieren ver todas las filas de la base de datos: quieren métricas concretas, rankings y comparativas.--

-- Consulta 1 — Resumen ejecutivo mensual --
--Total facturado, cantidad de pedidos y ticket promedio, agrupados por mes--

SELECT YEAR(fecha_venta) AS anio,
       MONTH(fecha_venta) AS mes,
       COUNT(*)           AS pedidos,
       SUM(cantidad * precio_unitario) AS facturacion,
       AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;
--Atencion: EXTRACT es sintaxis de PostgreSQL. El equivalente es MONTH(feha) o DEPART(MONTH, fecha)--
GO

--Consulta 2 — Ranking de productos--
--Top 5 de producto por total facturado, mostrando las unidades vendidas y el total generado.-- 

SELECT TOP 5 id_producto,
      SUM(cantidad)                   AS unidades,
      SUM(cantidad * precio_unitario) AS facturacion
FROM ventas
GROUP BY id_producto
ORDER BY facturacion DESC;
GO

--Consulta 3 — Clientes recurrentes--
--Cliente que hayan realizado más de un pedido, mostrando la cantidad de pedidos y el total gastado--

SELECT id_cliente,
        COUNT(*) AS pedidos,
        SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*)>1
ORDER BY pedidos DESC;
GO

--Consulta 4 — Meses por encima/por debajo del promedio --
--Total facturado por mes, con una columna adicional que etiquete si ese mes quedó 'Por encima' o 'Por debajo' del promedio mensual general.-- 

SELECT YEAR(fecha_venta) AS anio,
       MONTH(fecha_venta) AS mes,
       SUM(cantidad * precio_unitario) AS facturacion,
       CASE WHEN SUM(cantidad * precio_unitario) >
                (SELECT AVG(total_mes)
                 FROM (SELECT SUM(cantidad * precio_unitario) AS total_mes
                       FROM ventas
                       GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)) t)
            THEN 'Por encima'
            ELSE 'Por debajo'
      END AS comparativa
FROM ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;
GO

-- HALLAZGOS--
-- Los 3 clientes principales (id 1, 2 y 3) concentran el 70% de la facturación total siendo solo el 60% de la base de clientes.--
-- El producto 2 vendió más unidades (41) pero generó mucha menos facturación ($1.148,00) lo que indica que es un producto de bajo precio/alta rotación. --
-- Marzo fue el mes de mayor facturación del período ($6.444,00, el 38% del total del semestre) con el ticket promedio más alto ($644,40) y Enero y junio fueron los meses más bajos.--
