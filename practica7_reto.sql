DROP TABLE IF EXISTS inventario CASCADE;
DROP TABLE IF EXISTS producto CASCADE;
DROP TABLE IF EXISTS detalle_pedido CASCADE;

CREATE TABLE producto (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50)
);

CREATE TABLE inventario (
    producto_id INT PRIMARY KEY REFERENCES producto(id),
    stock INT NOT NULL
);

CREATE TABLE detalle_pedido (
    pedido_id INT,
    producto_id INT REFERENCES producto(id),
    cantidad INT NOT NULL
);


CREATE OR REPLACE FUNCTION controlar_stock()
RETURNS TRIGGER
AS $$
DECLARE
    stock_actual INT;
BEGIN

    SELECT stock
    INTO stock_actual
    FROM inventario
    WHERE producto_id = NEW.producto_id;

    IF stock_actual < NEW.cantidad THEN
        RAISE EXCEPTION
        'Stock insuficiente para el producto %. Disponible: %, solicitado: %',
        NEW.producto_id,
        stock_actual,
        NEW.cantidad;
    END IF;

    UPDATE inventario
    SET stock = stock - NEW.cantidad
    WHERE producto_id = NEW.producto_id;

    RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_control_stock
BEFORE INSERT ON detalle_pedido
FOR EACH ROW
EXECUTE FUNCTION controlar_stock();

INSERT INTO producto (nombre) VALUES
('Laptop'),
('Mouse'),
('Teclado'),
('Monitor'),
('Impresora');

INSERT INTO inventario (producto_id, stock)
VALUES
(1, 100),
(2, 50),
(3, 80),
(4, 30),
(5, 20);

-- Ejemplo de venta correcta
INSERT INTO detalle_pedido
VALUES (1, 1, 10);

SELECT * FROM inventario;

-- Stock insuficiente
INSERT INTO detalle_pedido
VALUES (2, 5, 25);