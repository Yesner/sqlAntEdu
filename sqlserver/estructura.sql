-- Borrar la base de datos si existe y crearla nuevamente
DROP DATABASE IF EXISTS Taxes_Nicaragua;
GO

CREATE DATABASE Taxes_Nicaragua;
GO

USE Taxes_Nicaragua;
GO

--  Tabla de Retenciones
CREATE TABLE retenciones (
    codigo INT PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL,
    alicuota DECIMAL(5,2) NULL -- Puede ser NULL para casos como Renta del Trabajo
);
GO

-- Insertar registros de retenciones
INSERT INTO retenciones (codigo, descripcion, alicuota) VALUES
(11, 'Renta del Trabajo (según tarifa progresiva)', NULL),
(21, 'Venta de bienes y prestaciones de servicios con tarjetas de crédito/débito', 1.5),
(22, 'Compra de bienes y prestación de servicios en general', 2.0),
(23, 'Trabajos de construcción', 2.0),
(24, 'Arrendamientos y alquileres', 2.0),
(25, 'Compraventa de bienes agropecuarios', 3.0),
(26, 'Metro cúbico de madera en rollo', 5.0),
(27, 'Servicios profesionales o técnicos superiores prestados por persona natural', 10.0),
(28, 'Importador (próxima importación)', 10.0),
(29, 'Importador no inscrito en la administración tributaria, sobre monto mayor a US$2,000', 10.0),
(210, 'Exportador de comercio irregular no inscrito en la administración tributaria, sobre monto mayor a US$500', 10.0),
(211, 'Otras actividades', 10.0),
(31, 'Indemnización laboral adicional a 5 meses, sobre el excedente', 15.0),
(43, 'Reaseguros pagados a no residentes', 1.5),
(44, 'Primas de seguros y fianzas a no residentes', 3.0),
(45, 'Transporte marítimo y aéreo, carga y pasajeros, transporte terrestre internacional de pasajeros a no residentes', 3.0),
(46, 'Comunicación telefónica y de internet internacionales a no residentes', 3.0),
(47, 'Resto de actividades económicas a no residentes', 20.0);
GO

--  Tabla de Empleados
CREATE TABLE empleados (
    empleado_id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    salario_mensual DECIMAL(12,2) NOT NULL
);
GO


ALTER TABLE empleados
ADD correo_electronico VARCHAR(150) NULL;



--  Tabla de Categorías de Productos
CREATE TABLE categorias_producto (
    categoria_id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo_retencion INT NOT NULL,
    CONSTRAINT FK_Categoria_Retencion FOREIGN KEY (codigo_retencion) REFERENCES retenciones(codigo)
);
GO

-- Insertar Categorías de Productos (solo categorías válidas para productos)
INSERT INTO categorias_producto (nombre, codigo_retencion) VALUES
('Servicios Profesionales', 27),
('Venta de Bienes', 22),
('Arrendamientos', 24);
GO

--  Tabla de Productos
CREATE TABLE productos (
    producto_id INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(255) NULL,
    precio DECIMAL(12,2) NOT NULL,
    categoria_id INT NOT NULL,
    CONSTRAINT FK_Producto_Categoria FOREIGN KEY (categoria_id) REFERENCES categorias_producto(categoria_id)
);
GO

-- Insertar Productos de ejemplo
INSERT INTO productos (nombre, descripcion, precio, categoria_id) VALUES
('Consultoría Técnica', 'Servicio de consultoría', 1500.00, 1),
('Laptop Modelo X', 'Venta de laptop de alta gama', 750.00, 2),
('Alquiler Oficina', 'Alquiler mensual de oficina', 500.00, 3);
GO

--  Tabla de Ventas (relación entre empleados y productos vendidos)
CREATE TABLE ventas (
    venta_id INT IDENTITY PRIMARY KEY,
    empleado_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    fecha DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Venta_Empleado FOREIGN KEY (empleado_id) REFERENCES empleados(empleado_id),
    CONSTRAINT FK_Venta_Producto FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
);
GO

--  Tabla de Historial de Retenciones
CREATE TABLE historial_retenciones (
    retencion_id INT IDENTITY PRIMARY KEY,
    fecha DATETIME NOT NULL DEFAULT GETDATE(),
    
    producto_id INT NULL, -- puede ser NULL si la retención es solo para salario
    empleado_id INT NULL, -- puede ser NULL si la retención es sobre un producto

    cantidad INT NULL, -- NULL para retenciones salariales
    precio_unitario DECIMAL(12,2) NULL, -- NULL para retenciones salariales

    codigo_retencion INT NOT NULL, -- código de la retención aplicada
    base_imponible DECIMAL(12,2) NOT NULL,
    monto_retencion DECIMAL(12,2) NOT NULL,
    descripcion_retencion VARCHAR(255) NULL,

    usuario_id INT NULL, -- quién realizó la operación (usuario del sistema)

    CONSTRAINT FK_Historial_Producto FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
    CONSTRAINT FK_Historial_Empleado FOREIGN KEY (empleado_id) REFERENCES empleados(empleado_id),
    CONSTRAINT FK_Historial_Retencion FOREIGN KEY (codigo_retencion) REFERENCES retenciones(codigo)
);
GO
