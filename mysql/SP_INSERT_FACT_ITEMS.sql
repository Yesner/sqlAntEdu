
DELIMITER $$

CREATE PROCEDURE InsertFacturaConItems (
    IN p_DNI VARCHAR(11),
    IN p_MATRICULA VARCHAR(5),
    IN p_FECHA_VENTA DATE,
    IN p_IMPUESTO FLOAT,
    IN p_CODIGOS TEXT,       -- Lista separada por coma
    IN p_CANTIDADES TEXT,    -- Lista separada por coma
    IN p_PRECIOS TEXT        -- Lista separada por coma
)
BEGIN
    DECLARE v_NUMERO INT;
    DECLARE v_idx INT DEFAULT 1;
    DECLARE v_total INT;
    DECLARE v_codigo VARCHAR(10);
    DECLARE v_cantidad INT;
    DECLARE v_precio FLOAT;
    DECLARE v_cod TEXT;
    DECLARE v_can TEXT;
    DECLARE v_pre TEXT;
    DECLARE v_msg TEXT;

    -- Para mensaje de error si el producto no existe
    DECLARE v_error_msg VARCHAR(255);

    START TRANSACTION;

    -- Crear número de factura
    SELECT IFNULL(MAX(NUMERO), 0) + 1 INTO v_NUMERO FROM FACTURAS;

    -- Insertar la factura
    INSERT INTO FACTURAS (DNI, MATRICULA, FECHA_VENTA, NUMERO, IMPUESTO)
    VALUES (p_DNI, p_MATRICULA, p_FECHA_VENTA, v_NUMERO, p_IMPUESTO);

    -- Contar cuántos ítems vienen
    SET v_total = 1 + LENGTH(p_CODIGOS) - LENGTH(REPLACE(p_CODIGOS, ',', ''));

    WHILE v_idx <= v_total DO
        -- Obtener el código, cantidad y precio individual
        SET v_cod = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_CODIGOS, ',', v_idx), ',', -1));
        SET v_can = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_CANTIDADES, ',', v_idx), ',', -1));
        SET v_pre = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_PRECIOS, ',', v_idx), ',', -1));

        SET v_codigo = v_cod;
        SET v_cantidad = CAST(v_can AS UNSIGNED);
        SET v_precio = CAST(v_pre AS DECIMAL(10,2));

        -- Validar existencia del producto
        IF NOT EXISTS (SELECT 1 FROM productos WHERE CODIGO = v_codigo) THEN
            ROLLBACK;
            SET v_error_msg = CONCAT('El producto con código ', v_codigo, ' no existe.');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
        END IF;

        -- Insertar el ítem
        INSERT INTO items_facturas (NUMERO, CODIGO_DEL_PRODUCTO, CANTIDAD, PRECIO)
        VALUES (v_NUMERO, v_codigo, v_cantidad, v_precio);

        SET v_idx = v_idx + 1;
    END WHILE;

    COMMIT;

    SELECT CONCAT('Factura ', v_NUMERO, ' y sus ítems insertados con éxito') AS mensaje;
END $$

DELIMITER ;



CALL InsertFacturaConItems(
    '1471156710', 
    '00236', 
    '2025-05-19', 
    0.15, 
    '1004327', 
    '4', 
    '19.51'
);

-- 4 x 19.51 = 78.04


DROP TRIGGER ActualizarVolumenCompra;

SELECT * FROM FACTURAS ORDER BY NUMERO DESC;
SELECT * FROM items_facturas order by NUMERO desc;

SELECT * FROM clientes WHERE DNI = '1471156710';


DELIMITER $$

CREATE TRIGGER ActualizarVolumenCompra
AFTER INSERT ON ITEMS_FACTURAS
FOR EACH ROW
BEGIN
    DECLARE total FLOAT;

    -- Calcula el total de la factura actual
    SELECT IFNULL(SUM(PRECIO * CANTIDAD), 0)
    INTO total
    FROM ITEMS_FACTURAS
    WHERE NUMERO = NEW.NUMERO;

    -- Actualiza el volumen de compra del cliente
    UPDATE clientes
    SET VOLUMEN_COMPRA = IFNULL(VOLUMEN_COMPRA, 0) + total
    WHERE DNI = (SELECT DNI FROM FACTURAS WHERE NUMERO = NEW.NUMERO);
END $$

DELIMITER ;