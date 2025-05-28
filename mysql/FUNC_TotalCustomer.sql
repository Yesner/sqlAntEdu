DELIMITER $$

CREATE FUNCTION totalVentasCliente(p_DNI VARCHAR(11))
returns float
deterministic
BEGIN

Declare total float;
SELECT SUM(i.precio*i.cantidad) INTO total 
FROM facturas AS f
INNER JOIN items_facturas AS i ON f.numero = i.numero
WHERE f.DNI = p_DNI;
RETURN total;
END $$

DELIMITER ;

SELECT totalVentasCliente('1471156710')  AS TotalFacturado;

-- 1471156710 R: '9,878,890'


SELECT * FROM clientes;