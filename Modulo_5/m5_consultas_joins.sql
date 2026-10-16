-- El equipo de análisis de RetailPro necesita una vista única que cruce toda la información del negocio. Además, el área de CRM quiere saber qué clientes nunca compraron y el área de producto quiere identificar qué artículos del catálogo no tienen movimiento.--
-- Consulta 1 — Vista base del proyecto –-
-- Combinación de tabla Ventas con las tablas descriptivas.--

SELECT 
        v.id_ventas,
    v.fecha_compra,
    c.id_cliente,
    c.Nombre_completo        AS cliente,
    c.Género                 AS genero_cliente,
    c.Ocupación,
    c.Educación,
    p.producto,
    p.Descripción_Abreviada,
    s.nombre_suc             AS sucursal,
    s.zona,
    ve.nombre_completo       AS vendedor,
    v.Cantidad               AS cantidad,
    v.valor_unidad           AS precio_unitario,
    v.Cantidad * v.valor_unidad AS total_venta

FROM dbo.Ventas AS v
INNER JOIN dbo.Cliente AS C ON v.ID_Cliente = c.id_Cliente
INNER JOIN dbo.Productos AS p ON v.ID_Producto = p.ID_Producto
INNER JOIN dbo.Vendedor AS ve ON v.ID_Vendedor = ve.ID_Vendedor
INNER JOIN dbo.Sucursal AS s ON ve.id_Sucursal = s.ID_Sucursal;


-- Consulta 2 — Clientes sin ventas -–
-- Se identifican clientes registrados que aún no han realizado ninguna compra.-–
-- (en el moldeado de tablas no contamos con ‘fecha de registro’ por lo que no se llama a consulta)--

SELECT
    c.id_cliente,
    c.Nombre_completo AS nombre,
    c.email
FROM Cliente c
LEFT JOIN Ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_cliente IS NULL;

-- Consulta 3 — Productos sin ventas --
-- Se identifican los productos del catálogo que no tienen ninguna venta registrada --
-- (el esquema no modela categoría ni precio de catálogo en Productos. Se utiliza Descripción_Abreviada como categoría, y el precio no se incluye porque no está disponible para productos sin ventas) --

SELECT
    p.id_producto,
    p.producto AS nombre_producto,
    p.Descripción_Abreviada AS categoria
FROM Productos p
LEFT JOIN Ventas v ON p.id_producto = v.id_producto
WHERE v.id_producto IS NULL;

-- Consulta 4 — Consolidado por canal –
-- Se consolida el total de ventas por canal de compra. La asignación del canal depende de ‘id_codigo_pago’ donde los ID 101, 103 y 105 son pagos virtuales y los ID 102, 104 y 106 son pagos presenciales.--


SELECT canal, SUM(total) AS total_canal
FROM (
    SELECT v.fecha_compra, v.Cantidad * v.valor_unidad AS total, 'Presencial' AS canal
    FROM Ventas v
    WHERE v.id_codigo_pago IN (102, 104, 106)

    UNION ALL

    SELECT v.fecha_compra, v.Cantidad * v.valor_unidad AS total, 'Virtual' AS canal
    FROM Ventas v
    WHERE v.id_codigo_pago IN (101, 103, 105)
) AS consolidado
GROUP BY canal;