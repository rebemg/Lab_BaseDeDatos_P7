DROP TABLE IF EXISTS detalle_pedido CASCADE;
DROP TABLE IF EXISTS pedido CASCADE;
DROP TABLE IF EXISTS inventario CASCADE;
DROP TABLE IF EXISTS producto CASCADE;
DROP TABLE IF EXISTS cliente CASCADE;
DROP TABLE IF EXISTS empleado CASCADE;
DROP TABLE IF EXISTS auditoria_pedido CASCADE;
DROP TABLE IF EXISTS resumen_clientes CASCADE;


CREATE TABLE empleado (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50),
    puesto VARCHAR(50),
    salario NUMERIC(10,2),
    fecha_contratacion DATE
);

INSERT INTO empleado (nombre, puesto, salario, fecha_contratacion) VALUES
('Ana Torres', 'Analista', 15000, '2026-10-02'),
('Luis Gómez', 'Gerente', 30000, '2026-09-15'),
('Marta Ruiz', 'Desarrolladora', 22000, '2026-08-10'),
('Carlos Pérez', 'Soporte', 14000, '2026-07-01'),
('Diana López', 'Analista', 16000, '2026-10-01');

CREATE TABLE cliente (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    direccion VARCHAR(100)
);

INSERT INTO cliente (nombre, direccion) VALUES
('Luis Gómez', 'Av. Universidad 123'),
('Marta Ruiz', 'Calle Reforma 456'),
('Carlos Pérez', 'Av. Central 789'),
('Diana López', 'Calle Norte 22'),
('Ana Torres', 'Av. Sur 77');

CREATE TABLE producto (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10,2)
);

INSERT INTO producto (nombre, precio) VALUES
('Libro A', 250.00),
('Libro B', 300.00),
('Libro C', 150.00),
('Laptop', 25000.00),
('Mouse', 500.00);

CREATE TABLE pedido (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL REFERENCES cliente(id),
    fecha DATE NOT NULL
);

INSERT INTO pedido (cliente_id, fecha) VALUES
(1, '2026-10-05'),
(2, '2026-10-06'),
(3, '2026-10-07'),
(4, '2026-10-08'),
(5, '2026-10-09');

CREATE TABLE detalle_pedido (
    pedido_id INT REFERENCES pedido(id),
    producto_id INT REFERENCES producto(id),
    cantidad INT NOT NULL,
    PRIMARY KEY (pedido_id, producto_id)
);

INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad) VALUES
(1,1,2),
(1,2,1),
(2,3,3),
(3,4,1),
(4,5,2),
(5,2,1);

-- INVENTARIO

CREATE TABLE inventario (
    producto_id INT PRIMARY KEY REFERENCES producto(id),
    stock INT NOT NULL
);

INSERT INTO inventario (producto_id, stock)
VALUES
(1,100),
(2,100),
(3,100),
(4,100),
(5,100);

-- Incrementar Salario
CREATE OR REPLACE PROCEDURE aumentar_salario(emp_id INT, incremento NUMERIC)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE empleado SET salario = salario + incremento
    WHERE id = emp_id;
END;
$$;

CALL aumentar_salario(1, 1000);

-- Aumentar pedidos
CREATE OR REPLACE FUNCTION contar_pedidos(cli_id INT)
RETURNS INT AS $$
DECLARE
    total INT;
BEGIN
    SELECT COUNT(*) INTO total FROM pedido
    WHERE cliente_id = cli_id;
    RETURN total;
END;
$$ LANGUAGE plpgsql;

SELECT nombre, contar_pedidos(id) FROM cliente;


CREATE TABLE auditoria_pedido (
    id SERIAL PRIMARY KEY,
    pedido_id INT,
    fecha TIMESTAMP,
    accion VARCHAR(20)
);

-- Trigger
CREATE OR REPLACE FUNCTION registrar_auditoria()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria_pedido(pedido_id, fecha, accion)
    VALUES(NEW.id, NOW(), 'INSERT');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pedido_insert
AFTER INSERT ON pedido
FOR EACH ROW
EXECUTE FUNCTION registrar_auditoria();

-- Tabla de resumen de clientes
CREATE TABLE resumen_clientes (
    cliente_id INT PRIMARY KEY REFERENCES cliente(id),
    total_ventas NUMERIC(12,2) DEFAULT 0
);

-- Procedimiento total de ventas
CREATE OR REPLACE PROCEDURE calcular_resumen_clientes()
LANGUAGE plpgsql
AS $$
BEGIN

    TRUNCATE TABLE resumen_clientes;

    INSERT INTO resumen_clientes (cliente_id, total_ventas)
    SELECT
        c.id,
        COALESCE(SUM(dp.cantidad * p.precio),0)
    FROM cliente c
    LEFT JOIN pedido pe
        ON c.id = pe.cliente_id
    LEFT JOIN detalle_pedido dp
        ON pe.id = dp.pedido_id
    LEFT JOIN producto p
        ON dp.producto_id = p.id
    GROUP BY c.id;

END;
$$;

CALL calcular_resumen_clientes();

-- Trigger
CREATE OR REPLACE FUNCTION actualizar_resumen_cliente()
RETURNS TRIGGER
AS $$
BEGIN

    INSERT INTO resumen_clientes (cliente_id, total_ventas)
    SELECT
        NEW.cliente_id,
        COALESCE(SUM(dp.cantidad * p.precio),0)
    FROM pedido pe
    LEFT JOIN detalle_pedido dp
        ON pe.id = dp.pedido_id
    LEFT JOIN producto p
        ON dp.producto_id = p.id
    WHERE pe.cliente_id = NEW.cliente_id

    ON CONFLICT (cliente_id)
    DO UPDATE SET
        total_ventas = EXCLUDED.total_ventas;

    RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_resumen
AFTER INSERT ON pedido
FOR EACH ROW
EXECUTE FUNCTION actualizar_resumen_cliente();

-- Probar trigger de auditoría
INSERT INTO pedido (cliente_id, fecha)
VALUES (1, CURRENT_DATE);

SELECT * FROM auditoria_pedido;

-- Probar función contar pedidos
SELECT nombre, contar_pedidos(id)
FROM cliente;

SELECT * FROM resumen_clientes;