-- phpMyAdmin SQL Dump
-- version 4.1.14
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Apr 27, 2016 at 02:01 PM
-- Server version: 5.6.17
-- PHP Version: 5.5.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `r1i2n3g4pro`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `st_busca_clientes_facturar`()
BEGIN
	DECLARE v_idCliente INT(11);
    DECLARE v_intervalo INT(11);
    DECLARE fin INTEGER DEFAULT 0;
    
    DECLARE clientesPorFacturar_cursor CURSOR FOR
        SELECT id, intervalo FROM clientes WHERE fecActivacion = DATE_SUB(CURDATE(), INTERVAL intervalo MONTH);
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin=1;
    
    OPEN clientesPorFacturar_cursor;

		get_clientes: LOOP

			FETCH clientesPorFacturar_cursor INTO v_idCliente, v_intervalo;

			IF fin = 1 THEN
				LEAVE get_clientes;
			END IF;
			
            call st_generar_factura_cliente(v_idCliente, v_intervalo);
            
		END LOOP get_clientes;

	CLOSE clientesPorFacturar_cursor;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `st_generar_factura_cliente`(IN `p_id` INT(11), IN `p_intervalo` INT(11))
BEGIN
	
    DECLARE v_afiliacion INT(11);
    DECLARE fin INTEGER DEFAULT 0;
    DECLARE idFactura INT;
    
    DECLARE facturas_cursor CURSOR FOR
		SELECT COUNT(*) cantFacturas FROM facturas WHERE idCliente = p_id;
	
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin=1;
    
    OPEN facturas_cursor;

		get_facturas: LOOP

			FETCH facturas_cursor INTO v_afiliacion;

			IF fin = 1 THEN
                LEAVE get_facturas;
			END IF;
            
            SELECT fn_generar_encabezado_factura(p_id) INTO idFactura;
            
            IF v_afiliacion = 0 THEN /* SE AGREGA LA AFILIACION */
				SELECT fn_generar_afiliacion(p_id, idFactura, p_intervalo);
			END IF;
            
            SELECT fn_generar_item_factura(p_id, idFactura, p_intervalo);

		END LOOP get_facturas;

	CLOSE facturas_cursor;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `st_operaciones_duplica`(IN `p_id` INT(11))
BEGIN
    INSERT INTO operaciones SELECT '', nombre, email, numControl, monto, codOperacion, '', '', '', '', '', '', '', '', idVirtualPoint, duracionOperaciones, 1, idCliente, idUsuario, NOW() FROM operaciones WHERE id = p_id;
    UPDATE operaciones SET estatus = 3 WHERE id = p_id AND estatus = 1;
    DELETE FROM operaciones WHERE id = p_id;
    select fn_formatea_datos_criticos(p_id);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `st_operaciones_expiradas`(
)
BEGIN

  DECLARE v_idOperacion INT(11);


  DECLARE fin INTEGER DEFAULT 0;


  DECLARE operaciones_cursor CURSOR FOR
    SELECT id FROM operaciones o WHERE fecCreacion <=  DATE_SUB(NOW(),INTERVAL (SELECT duracionOperaciones FROM operaciones WHERE id = o.id) HOUR);


  DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin=1;

  OPEN operaciones_cursor;
  get_operaciones: LOOP
    FETCH operaciones_cursor INTO v_idOperacion;
    IF fin = 1 THEN
       LEAVE get_operaciones;
    END IF;
  UPDATE operaciones SET estatus = 3 WHERE id = v_idOperacion AND estatus IN (1, 2);
  DELETE FROM operaciones WHERE id = v_idOperacion;


  END LOOP get_operaciones;

  CLOSE operaciones_cursor;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `st_operaciones_historial`(IN p_id INT(11))
BEGIN

DELETE FROM operaciones WHERE id = p_id;
    UPDATE operaciones_h SET estatus = 3 WHERE id = p_id AND estatus <= 3;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_formatea_datos_criticos`(p_idOperacion INT(11)) RETURNS int(11)
BEGIN
	UPDATE operaciones_h
	SET 
		numTarjeta = CONCAT(SUBSTRING(numTarjeta, 1, 4),
				'-****-****-',
				SUBSTRING(numTarjeta,
					LENGTH(numTarjeta) - 3,
					LENGTH(numTarjeta))),
		docIdentidad = CONCAT('*****',
				SUBSTRING(docIdentidad,
					LENGTH(docIdentidad) - 2,
					LENGTH(docIdentidad))),
		codSeguridad = '***',
		fecVencimiento = '****'
	WHERE 
		id = p_idOperacion;
RETURN 1;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_generar_afiliacion`(`p_idCliente` INT(11), `idFactura` INT(11), `intervalo` INT(11)) RETURNS int(11)
BEGIN

	INSERT INTO detalle_factura 
		SELECT 
			'',
			idFactura, 
			'Afiliacion al Servicio RING', 
			'', 
			'',
			idTipoCobranza,
			'',
			1,
			(SELECT montoAfiliacion FROM clientes WHERE id = p_idCliente),
			(SELECT montoAfiliacion FROM clientes WHERE id = p_idCliente)
		FROM clientes 
        WHERE id = p_idCliente;
return 0;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_generar_encabezado_factura`(`p_id` INT(11)) RETURNS int(11)
BEGIN

	SET @idFactura = 0;
    
    SELECT COUNT(id) INTO @idFactura FROM facturas;

	IF @idFactura = 0 THEN
		INSERT INTO facturas SELECT '', COUNT(id)+1, NOW(), p_id, 1, 12 FROM facturas;
	ELSE
		INSERT INTO facturas SELECT MAX(id) + 1, MAX(id) + 1, NOW(), p_id, 1, 12 FROM facturas;
    END IF;
    
	SELECT MAX(id) INTO @idFactura FROM facturas;

    RETURN @idFactura;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_generar_item_factura`(`p_idCliente` INT(11), `idFactura` INT(11), `intervalo` INT(11)) RETURNS int(11)
BEGIN

	INSERT INTO detalle_factura 
		SELECT 
			'',
			idFactura, 
			CONCAT(
				'Facturacion Periodo ',  
				CASE 
					WHEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL intervalo MONTH), '%c') = 1 THEN "Enero"
					WHEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL intervalo MONTH), '%c') = 2 THEN "Febrero"
					WHEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL intervalo MONTH), '%c') = 3 THEN "Marzo"
					WHEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL intervalo MONTH), '%c') = 4 THEN "Abril"
					WHEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL intervalo MONTH), '%c') = 5 THEN "Mayo"
					WHEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL intervalo MONTH), '%c') = 6 THEN "Junio"
					WHEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL intervalo MONTH), '%c') = 7 THEN "Julio"
					WHEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL intervalo MONTH), '%c') = 8 THEN "Agosto"
					WHEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL intervalo MONTH), '%c') = 9 THEN "Septiembre"
					WHEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL intervalo MONTH), '%c') = 10 THEN "Octubre"
					WHEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL intervalo MONTH), '%c') = 11 THEN "Noviembre"
					WHEN DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL intervalo MONTH), '%c') = 12 THEN "Diciembre" END,
				' ',
				DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL intervalo MONTH), '%Y'),
				' - ',
				CASE 
					WHEN DATE_FORMAT(CURDATE(), '%c') = 1 THEN "Enero"
					WHEN DATE_FORMAT(CURDATE(), '%c') = 2 THEN "Febrero"
					WHEN DATE_FORMAT(CURDATE(), '%c') = 3 THEN "Marzo"
					WHEN DATE_FORMAT(CURDATE(), '%c') = 4 THEN "Abril"
					WHEN DATE_FORMAT(CURDATE(), '%c') = 5 THEN "Mayo"
					WHEN DATE_FORMAT(CURDATE(), '%c') = 6 THEN "Junio"
					WHEN DATE_FORMAT(CURDATE(), '%c') = 7 THEN "Julio"
					WHEN DATE_FORMAT(CURDATE(), '%c') = 8 THEN "Agosto"
					WHEN DATE_FORMAT(CURDATE(), '%c') = 9 THEN "Septiembre"
					WHEN DATE_FORMAT(CURDATE(), '%c') = 10 THEN "Octubre"
					WHEN DATE_FORMAT(CURDATE(), '%c') = 11 THEN "Noviembre"
					WHEN DATE_FORMAT(CURDATE(), '%c') = 12 THEN "Diciembre" END,
				' ',
				DATE_FORMAT(CURDATE(), '%Y')
			), 
			(SELECT COUNT(*) FROM operaciones_h WHERE fecOperacion >= DATE_SUB(CURDATE(), INTERVAL intervalo MONTH) AND idCliente = p_idCliente), 
			(SELECT COUNT(*) FROM operaciones_h WHERE fecOperacion >= DATE_SUB(CURDATE(), INTERVAL intervalo MONTH) AND idCliente = p_idCliente AND estatus = 5),
			idTipoCobranza,
			tasa,
			1,
			CASE 
				WHEN idTipoCobranza = 1 THEN (SELECT COUNT(*) FROM operaciones_h WHERE fecOperacion >= DATE_SUB(CURDATE(), INTERVAL intervalo MONTH) AND idCliente = p_idCliente AND estatus = 5) * tasa
                WHEN idTipoCobranza = 2 THEN (SELECT SUM(monto) FROM operaciones_h WHERE fecOperacion >= DATE_SUB(CURDATE(), INTERVAL intervalo MONTH) AND idCliente = p_idCliente AND estatus = 5) * (tasa/100)
                WHEN idTipoCobranza = 3 THEN tasa END,
			CASE 
				WHEN idTipoCobranza = 1 THEN (SELECT COUNT(*) FROM operaciones_h WHERE fecOperacion >= DATE_SUB(CURDATE(), INTERVAL intervalo MONTH) AND idCliente = p_idCliente AND estatus = 5) * tasa
                WHEN idTipoCobranza = 2 THEN (SELECT SUM(monto) FROM operaciones_h WHERE fecOperacion >= DATE_SUB(CURDATE(), INTERVAL intervalo MONTH) AND idCliente = p_idCliente AND estatus = 5) * (tasa/100)
                WHEN idTipoCobranza = 3 THEN tasa END
        FROM clientes
        WHERE id = p_idCliente;
        
RETURN 1;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `bancos`
--

CREATE TABLE IF NOT EXISTS `bancos` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Codigo Unico del Banco',
  `nombre` varchar(150) NOT NULL COMMENT 'Nombre del Banco',
  `estatus` int(11) NOT NULL COMMENT 'Estatus del cliente en el sistema\n1.- Activo, 0.- Inactivo.',
  `idUsuario` int(11) NOT NULL,
  `fecCreacion` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Contiene los bancos que estaran disponibles en la aplicacion.' AUTO_INCREMENT=4 ;

--
-- Dumping data for table `bancos`
--

INSERT INTO `bancos` (`id`, `nombre`, `estatus`, `idUsuario`, `fecCreacion`) VALUES
(1, 'Banesco Banco Universal', 1, 1, '2015-04-03 20:22:33'),
(2, 'Banco Exterior', 1, 1, '2015-04-03 20:22:43'),
(3, 'Banco del Caribe', 1, 1, '2015-04-03 20:21:50');

-- --------------------------------------------------------

--
-- Table structure for table `clientes`
--

CREATE TABLE IF NOT EXISTS `clientes` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Codigo Unico del Cliente',
  `nombre` varchar(200) NOT NULL COMMENT 'Nombre o Razon Social del Cliente',
  `rif` varchar(45) NOT NULL COMMENT 'Documento Legal que identifica al Cliente',
  `idEstado` int(11) NOT NULL COMMENT 'Codigo Unico del Estado donde presta servicios el Cliente',
  `idMunicipio` int(11) NOT NULL COMMENT 'Codigo Unico del Municipio donde presta servicios el Cliente',
  `direccion` text COMMENT 'Direccion Fiscal del Cliente',
  `telefono` varchar(45) NOT NULL COMMENT 'Telefono de contacto del Cliente',
  `personaContacto` varchar(200) NOT NULL COMMENT 'Persona Contacto entre el Cliente y la Empresa',
  `imagen` varchar(150) DEFAULT NULL COMMENT 'Ruta de la Imagen o Logo del cliente que se mostrara en la Aplicacion',
  `idTipoCobranza` int(11) NOT NULL COMMENT 'Modalidad de cobranza para el cliente.\n- Tasa Fija por transaccion.\n- Porcentual.\n- Licenciamiento Anual.\n- Licenciamiento Semestral.\n- Licenciamiento Mensual.',
  `tasa` varchar(10) DEFAULT NULL,
  `intervalo` int(11) NOT NULL,
  `montoAfiliacion` decimal(9,2) DEFAULT NULL,
  `duracionOperaciones` decimal(11,0) NOT NULL,
  `numeroUsuarios` int(11) NOT NULL,
  `idVendedor` int(11) NOT NULL,
  `estatus` int(11) NOT NULL COMMENT 'Estatus del cliente en el sistema\n1.- Activo, 0.- Inactivo.',
  `idUsuario` int(11) NOT NULL COMMENT 'Codigo de Usuario que realizo la creacion del Cliente',
  `fecCreacion` datetime NOT NULL COMMENT 'Fecha y Hora en la que se realizo la creacion del Cliente',
  `fecActivacion` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Contiene los clientes que haran uso de la aplicacion.' AUTO_INCREMENT=4 ;

--
-- Dumping data for table `clientes`
--

INSERT INTO `clientes` (`id`, `nombre`, `rif`, `idEstado`, `idMunicipio`, `direccion`, `telefono`, `personaContacto`, `imagen`, `idTipoCobranza`, `tasa`, `intervalo`, `montoAfiliacion`, `duracionOperaciones`, `numeroUsuarios`, `idVendedor`, `estatus`, `idUsuario`, `fecCreacion`, `fecActivacion`) VALUES
(1, 'Oriantech C.A. - Vendedor', 'J-12563563', 14, 191, 'Boleita', '02122809393', 'Raul Puig, Juan Nunes, Jorge Peraza', NULL, 1, '25', 1, '10000.00', '12', 20, 0, 1, 7, '2016-04-12 17:40:20', '2012-10-20'),
(2, 'Hospital Internacional Barquisimeto', 'J-321321321', 12, 166, 'Avenida Intercomunal Barquisimeto – Cabudare con Avenida La Montañita, Urb. Las Mercedes, Cabudare - Estado Lara, Venezuela', '0251-2200000', 'Oscar Gutierrez', NULL, 2, '1', 1, '15000.00', '12', 4, 0, 1, 7, '2016-03-13 11:51:57', '2016-02-13'),
(3, 'Oriantech C.A.', 'J-12563563', 14, 191, 'Boleita', '02122809393', 'Raul Puig, Juan Nunes, Jorge Peraza', NULL, 1, '25', 1, '10000.00', '12', 20, 0, 1, 7, '2016-04-12 15:46:33', '2010-01-20');

--
-- Triggers `clientes`
--
DROP TRIGGER IF EXISTS `clientes_hash_generator`;
DELIMITER //
CREATE TRIGGER `clientes_hash_generator` AFTER INSERT ON `clientes`
 FOR EACH ROW INSERT INTO hash_clientes VALUES 
(
	'',
	NEW.id,
	PASSWORD(NEW.id)
)
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `detalle_factura`
--

CREATE TABLE IF NOT EXISTS `detalle_factura` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idFactura` int(11) NOT NULL,
  `descripcion` varchar(250) NOT NULL,
  `operacionesTotal` int(11) DEFAULT NULL,
  `operacionesAprobadas` int(11) DEFAULT NULL,
  `idTipoCobranza` int(11) NOT NULL,
  `tasa` varchar(10) DEFAULT NULL,
  `cantidad` decimal(9,2) NOT NULL,
  `montoUnitario` decimal(9,2) NOT NULL,
  `montoTotal` decimal(9,2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `detalle_factura`
--

INSERT INTO `detalle_factura` (`id`, `idFactura`, `descripcion`, `operacionesTotal`, `operacionesAprobadas`, `idTipoCobranza`, `tasa`, `cantidad`, `montoUnitario`, `montoTotal`) VALUES
(0, 0, 'Afiliacion al Servicio RING', 0, 0, 2, '', '1.00', '15000.00', '15000.00');

-- --------------------------------------------------------

--
-- Table structure for table `facturas`
--

CREATE TABLE IF NOT EXISTS `facturas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `numFactura` varchar(45) NOT NULL,
  `fecFactura` date NOT NULL,
  `idCliente` int(11) NOT NULL,
  `estatus` enum('Pendiente','En Revision','Pagada','Vencida') NOT NULL DEFAULT 'Pendiente',
  `iva` decimal(9,2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `facturas`
--

INSERT INTO `facturas` (`id`, `numFactura`, `fecFactura`, `idCliente`, `estatus`, `iva`) VALUES
(0, '1', '2016-03-13', 2, 'Pendiente', '12.00');

-- --------------------------------------------------------

--
-- Table structure for table `hash_clientes`
--

CREATE TABLE IF NOT EXISTS `hash_clientes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idCliente` int(11) NOT NULL,
  `hashCliente` varchar(250) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `hash_clientes`
--

INSERT INTO `hash_clientes` (`id`, `idCliente`, `hashCliente`) VALUES
(1, 1, '*E6CC90B878B948C35E92B003C792C46C58C4AF40'),
(2, 2, '*12033B78389744F3F39AC4CE4CCFCAD6960D8EA0'),
(3, 3, '*C4E74DDDC9CC9E2FDCDB7F63B127FB638831262E');

-- --------------------------------------------------------

--
-- Table structure for table `localidades`
--

CREATE TABLE IF NOT EXISTS `localidades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tabla` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `localidad_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1495 ;

--
-- Dumping data for table `localidades`
--

INSERT INTO `localidades` (`id`, `tabla`, `nombre`, `localidad_id`) VALUES
(1, 'pais', 'VENEZUELA', NULL),
(2, 'estado', 'DTTO. CAPITAL', 1),
(3, 'estado', 'ANZOATEGUI', 1),
(4, 'estado', 'APURE', 1),
(5, 'estado', 'ARAGUA', 1),
(6, 'estado', 'BARINAS', 1),
(7, 'estado', 'BOLIVAR', 1),
(8, 'estado', 'CARABOBO', 1),
(9, 'estado', 'COJEDES', 1),
(10, 'estado', 'FALCON', 1),
(11, 'estado', 'GUARICO', 1),
(12, 'estado', 'LARA', 1),
(13, 'estado', 'MERIDA', 1),
(14, 'estado', 'MIRANDA', 1),
(15, 'estado', 'MONAGAS', 1),
(16, 'estado', 'NUEVA ESPARTA', 1),
(17, 'estado', 'PORTUGUESA', 1),
(18, 'estado', 'SUCRE', 1),
(19, 'estado', 'TACHIRA', 1),
(20, 'estado', 'TRUJILLO', 1),
(21, 'estado', 'YARACUY', 1),
(22, 'estado', 'ZULIA', 1),
(23, 'estado', 'AMAZONAS', 1),
(24, 'estado', 'DELTA AMACURO', 1),
(25, 'estado', 'VARGAS', 1),
(26, 'municipio', 'LIBERTADOR', 2),
(27, 'municipio', 'ANACO', 3),
(28, 'municipio', 'ARAGUA', 3),
(29, 'municipio', 'BOLIVAR', 3),
(30, 'municipio', 'BRUZUAL', 3),
(31, 'municipio', 'CAJIGAL', 3),
(32, 'municipio', 'FREITES', 3),
(33, 'municipio', 'INDEPENDENCIA', 3),
(34, 'municipio', 'LIBERTAD', 3),
(35, 'municipio', 'MIRANDA', 3),
(36, 'municipio', 'MONAGAS', 3),
(37, 'municipio', 'PEÑALVER', 3),
(38, 'municipio', 'SIMON RODRIGUEZ', 3),
(39, 'municipio', 'SOTILLO', 3),
(40, 'municipio', 'GUANIPA', 3),
(41, 'municipio', 'GUANTA', 3),
(42, 'municipio', 'PIRITU', 3),
(43, 'municipio', 'M.L/DIEGO BAUTISTA U', 3),
(44, 'municipio', 'CARVAJAL', 3),
(45, 'municipio', 'SANTA ANA', 3),
(46, 'municipio', 'MC GREGOR', 3),
(47, 'municipio', 'S JUAN CAPISTRANO', 3),
(48, 'municipio', 'ACHAGUAS', 4),
(49, 'municipio', 'MUÑOZ', 4),
(50, 'municipio', 'PAEZ', 4),
(51, 'municipio', 'PEDRO CAMEJO', 4),
(52, 'municipio', 'ROMULO GALLEGOS', 4),
(53, 'municipio', 'SAN FERNANDO', 4),
(54, 'municipio', 'BIRUACA', 4),
(55, 'municipio', 'GIRARDOT', 5),
(56, 'municipio', 'SANTIAGO MARIÑO', 5),
(57, 'municipio', 'JOSE FELIX RIVAS', 5),
(58, 'municipio', 'SAN CASIMIRO', 5),
(59, 'municipio', 'SAN SEBASTIAN', 5),
(60, 'municipio', 'SUCRE', 5),
(61, 'municipio', 'URDANETA', 5),
(62, 'municipio', 'ZAMORA', 5),
(63, 'municipio', 'LIBERTADOR', 5),
(64, 'municipio', 'JOSE ANGEL LAMAS', 5),
(65, 'municipio', 'BOLIVAR', 5),
(66, 'municipio', 'SANTOS MICHELENA', 5),
(67, 'municipio', 'MARIO B IRAGORRY', 5),
(68, 'municipio', 'TOVAR', 5),
(69, 'municipio', 'CAMATAGUA', 5),
(70, 'municipio', 'JOSE R REVENGA', 5),
(71, 'municipio', 'FRANCISCO LINARES A.', 5),
(72, 'municipio', 'M.OCUMARE D LA COSTA', 5),
(73, 'municipio', 'ARISMENDI', 6),
(74, 'municipio', 'BARINAS', 6),
(75, 'municipio', 'BOLIVAR', 6),
(76, 'municipio', 'EZEQUIEL ZAMORA', 6),
(77, 'municipio', 'OBISPOS', 6),
(78, 'municipio', 'PEDRAZA', 6),
(79, 'municipio', 'ROJAS', 6),
(80, 'municipio', 'SOSA', 6),
(81, 'municipio', 'ALBERTO ARVELO T', 6),
(82, 'municipio', 'A JOSE DE SUCRE', 6),
(83, 'municipio', 'CRUZ PAREDES', 6),
(84, 'municipio', 'ANDRES E. BLANCO', 6),
(85, 'municipio', 'CARONI', 7),
(86, 'municipio', 'CEDEÑO', 7),
(87, 'municipio', 'HERES', 7),
(88, 'municipio', 'PIAR', 7),
(89, 'municipio', 'ROSCIO', 7),
(90, 'municipio', 'SUCRE', 7),
(91, 'municipio', 'SIFONTES', 7),
(92, 'municipio', 'RAUL LEONI', 7),
(93, 'municipio', 'GRAN SABANA', 7),
(94, 'municipio', 'EL CALLAO', 7),
(95, 'municipio', 'PADRE PEDRO CHIEN', 7),
(96, 'municipio', 'BEJUMA', 8),
(97, 'municipio', 'CARLOS ARVELO', 8),
(98, 'municipio', 'DIEGO IBARRA', 8),
(99, 'municipio', 'GUACARA', 8),
(100, 'municipio', 'MONTALBAN', 8),
(101, 'municipio', 'JUAN JOSE MORA', 8),
(102, 'municipio', 'PUERTO CABELLO', 8),
(103, 'municipio', 'SAN JOAQUIN', 8),
(104, 'municipio', 'VALENCIA', 8),
(105, 'municipio', 'MIRANDA', 8),
(106, 'municipio', 'LOS GUAYOS', 8),
(107, 'municipio', 'NAGUANAGUA', 8),
(108, 'municipio', 'SAN DIEGO', 8),
(109, 'municipio', 'LIBERTADOR', 8),
(110, 'municipio', 'ANZOATEGUI', 9),
(111, 'municipio', 'FALCON', 9),
(112, 'municipio', 'GIRARDOT', 9),
(113, 'municipio', 'MP PAO SN J BAUTISTA', 9),
(114, 'municipio', 'RICAURTE', 9),
(115, 'municipio', 'SAN CARLOS', 9),
(116, 'municipio', 'TINACO', 9),
(117, 'municipio', 'LIMA BLANCO', 9),
(118, 'municipio', 'ROMULO GALLEGOS', 9),
(119, 'municipio', 'ACOSTA', 10),
(120, 'municipio', 'BOLIVAR', 10),
(121, 'municipio', 'BUCHIVACOA', 10),
(122, 'municipio', 'CARIRUBANA', 10),
(123, 'municipio', 'COLINA', 10),
(124, 'municipio', 'DEMOCRACIA', 10),
(125, 'municipio', 'FALCON', 10),
(126, 'municipio', 'FEDERACION', 10),
(127, 'municipio', 'MAUROA', 10),
(128, 'municipio', 'MIRANDA', 10),
(129, 'municipio', 'PETIT', 10),
(130, 'municipio', 'SILVA', 10),
(131, 'municipio', 'ZAMORA', 10),
(132, 'municipio', 'DABAJURO', 10),
(133, 'municipio', 'MONS. ITURRIZA', 10),
(134, 'municipio', 'LOS TAQUES', 10),
(135, 'municipio', 'PIRITU', 10),
(136, 'municipio', 'UNION', 10),
(137, 'municipio', 'SAN FRANCISCO', 10),
(138, 'municipio', 'JACURA', 10),
(139, 'municipio', 'CACIQUE MANAURE', 10),
(140, 'municipio', 'PALMA SOLA', 10),
(141, 'municipio', 'SUCRE', 10),
(142, 'municipio', 'URUMACO', 10),
(143, 'municipio', 'TOCOPERO', 10),
(144, 'municipio', 'INFANTE', 11),
(145, 'municipio', 'MELLADO', 11),
(146, 'municipio', 'MIRANDA', 11),
(147, 'municipio', 'MONAGAS', 11),
(148, 'municipio', 'RIBAS', 11),
(149, 'municipio', 'ROSCIO', 11),
(150, 'municipio', 'ZARAZA', 11),
(151, 'municipio', 'CAMAGUAN', 11),
(152, 'municipio', 'S JOSE DE GUARIBE', 11),
(153, 'municipio', 'LAS MERCEDES', 11),
(154, 'municipio', 'EL SOCORRO', 11),
(155, 'municipio', 'ORTIZ', 11),
(156, 'municipio', 'S MARIA DE IPIRE', 11),
(157, 'municipio', 'CHAGUARAMAS', 11),
(158, 'municipio', 'SAN GERONIMO DE G', 11),
(159, 'municipio', 'CRESPO', 12),
(160, 'municipio', 'IRIBARREN', 12),
(161, 'municipio', 'JIMENEZ', 12),
(162, 'municipio', 'MORAN', 12),
(163, 'municipio', 'PALAVECINO', 12),
(164, 'municipio', 'TORRES', 12),
(165, 'municipio', 'URDANETA', 12),
(166, 'municipio', 'ANDRES E BLANCO', 12),
(167, 'municipio', 'SIMON PLANAS', 12),
(168, 'municipio', 'ALBERTO ADRIANI', 13),
(169, 'municipio', 'ANDRES BELLO', 13),
(170, 'municipio', 'ARZOBISPO CHACON', 13),
(171, 'municipio', 'CAMPO ELIAS', 13),
(172, 'municipio', 'GUARAQUE', 13),
(173, 'municipio', 'JULIO CESAR SALAS', 13),
(174, 'municipio', 'JUSTO BRICEÑO', 13),
(175, 'municipio', 'LIBERTADOR', 13),
(176, 'municipio', 'SANTOS MARQUINA', 13),
(177, 'municipio', 'MIRANDA', 13),
(178, 'municipio', 'ANTONIO PINTO S.', 13),
(179, 'municipio', 'OB. RAMOS DE LORA', 13),
(180, 'municipio', 'CARACCIOLO PARRA', 13),
(181, 'municipio', 'CARDENAL QUINTERO', 13),
(182, 'municipio', 'PUEBLO LLANO', 13),
(183, 'municipio', 'RANGEL', 13),
(184, 'municipio', 'RIVAS DAVILA', 13),
(185, 'municipio', 'SUCRE', 13),
(186, 'municipio', 'TOVAR', 13),
(187, 'municipio', 'TULIO F CORDERO', 13),
(188, 'municipio', 'PADRE NOGUERA', 13),
(189, 'municipio', 'ARICAGUA', 13),
(190, 'municipio', 'ZEA', 13),
(191, 'municipio', 'ACEVEDO', 14),
(192, 'municipio', 'BRION', 14),
(193, 'municipio', 'GUAICAIPURO', 14),
(194, 'municipio', 'INDEPENDENCIA', 14),
(195, 'municipio', 'LANDER', 14),
(196, 'municipio', 'PAEZ', 14),
(197, 'municipio', 'PAZ CASTILLO', 14),
(198, 'municipio', 'PLAZA', 14),
(199, 'municipio', 'SUCRE', 14),
(200, 'municipio', 'URDANETA', 14),
(201, 'municipio', 'ZAMORA', 14),
(202, 'municipio', 'CRISTOBAL ROJAS', 14),
(203, 'municipio', 'LOS SALIAS', 14),
(204, 'municipio', 'ANDRES BELLO', 14),
(205, 'municipio', 'SIMON BOLIVAR', 14),
(206, 'municipio', 'BARUTA', 14),
(207, 'municipio', 'CARRIZAL', 14),
(208, 'municipio', 'CHACAO', 14),
(209, 'municipio', 'EL HATILLO', 14),
(210, 'municipio', 'BUROZ', 14),
(211, 'municipio', 'PEDRO GUAL', 14),
(212, 'municipio', 'ACOSTA', 15),
(213, 'municipio', 'BOLIVAR', 15),
(214, 'municipio', 'CARIPE', 15),
(215, 'municipio', 'CEDEÑO', 15),
(216, 'municipio', 'EZEQUIEL ZAMORA', 15),
(217, 'municipio', 'LIBERTADOR', 15),
(218, 'municipio', 'MATURIN', 15),
(219, 'municipio', 'PIAR', 15),
(220, 'municipio', 'PUNCERES', 15),
(221, 'municipio', 'SOTILLO', 15),
(222, 'municipio', 'AGUASAY', 15),
(223, 'municipio', 'SANTA BARBARA', 15),
(224, 'municipio', 'URACOA', 15),
(225, 'municipio', 'ARISMENDI', 16),
(226, 'municipio', 'DIAZ', 16),
(227, 'municipio', 'GOMEZ', 16),
(228, 'municipio', 'MANEIRO', 16),
(229, 'municipio', 'MARCANO', 16),
(230, 'municipio', 'MARIÑO', 16),
(231, 'municipio', 'PENIN. DE MACANAO', 16),
(232, 'municipio', 'VILLALBA(I.COCHE)', 16),
(233, 'municipio', 'TUBORES', 16),
(234, 'municipio', 'ANTOLIN DEL CAMPO', 16),
(235, 'municipio', 'GARCIA', 16),
(236, 'municipio', 'ARAURE', 17),
(237, 'municipio', 'ESTELLER', 17),
(238, 'municipio', 'GUANARE', 17),
(239, 'municipio', 'GUANARITO', 17),
(240, 'municipio', 'OSPINO', 17),
(241, 'municipio', 'PAEZ', 17),
(242, 'municipio', 'SUCRE', 17),
(243, 'municipio', 'TUREN', 17),
(244, 'municipio', 'M.JOSE V DE UNDA', 17),
(245, 'municipio', 'AGUA BLANCA', 17),
(246, 'municipio', 'PAPELON', 17),
(247, 'municipio', 'GENARO BOCONOITO', 17),
(248, 'municipio', 'S RAFAEL DE ONOTO', 17),
(249, 'municipio', 'SANTA ROSALIA', 17),
(250, 'municipio', 'ARISMENDI', 18),
(251, 'municipio', 'BENITEZ', 18),
(252, 'municipio', 'BERMUDEZ', 18),
(253, 'municipio', 'CAJIGAL', 18),
(254, 'municipio', 'MARIÑO', 18),
(255, 'municipio', 'MEJIA', 18),
(256, 'municipio', 'MONTES', 18),
(257, 'municipio', 'RIBERO', 18),
(258, 'municipio', 'SUCRE', 18),
(259, 'municipio', 'VALDEZ', 18),
(260, 'municipio', 'ANDRES E BLANCO', 18),
(261, 'municipio', 'LIBERTADOR', 18),
(262, 'municipio', 'ANDRES MATA', 18),
(263, 'municipio', 'BOLIVAR', 18),
(264, 'municipio', 'CRUZ S ACOSTA', 18),
(265, 'municipio', 'AYACUCHO', 19),
(266, 'municipio', 'BOLIVAR', 19),
(267, 'municipio', 'INDEPENDENCIA', 19),
(268, 'municipio', 'CARDENAS', 19),
(269, 'municipio', 'JAUREGUI', 19),
(270, 'municipio', 'JUNIN', 19),
(271, 'municipio', 'LOBATERA', 19),
(272, 'municipio', 'SAN CRISTOBAL', 19),
(273, 'municipio', 'URIBANTE', 19),
(274, 'municipio', 'CORDOBA', 19),
(275, 'municipio', 'GARCIA DE HEVIA', 19),
(276, 'municipio', 'GUASIMOS', 19),
(277, 'municipio', 'MICHELENA', 19),
(278, 'municipio', 'LIBERTADOR', 19),
(279, 'municipio', 'PANAMERICANO', 19),
(280, 'municipio', 'PEDRO MARIA UREÑA', 19),
(281, 'municipio', 'SUCRE', 19),
(282, 'municipio', 'ANDRES BELLO', 19),
(283, 'municipio', 'FERNANDEZ FEO', 19),
(284, 'municipio', 'LIBERTAD', 19),
(285, 'municipio', 'SAMUEL MALDONADO', 19),
(286, 'municipio', 'SEBORUCO', 19),
(287, 'municipio', 'ANTONIO ROMULO C', 19),
(288, 'municipio', 'FCO DE MIRANDA', 19),
(289, 'municipio', 'JOSE MARIA VARGA', 19),
(290, 'municipio', 'RAFAEL URDANETA', 19),
(291, 'municipio', 'SIMON RODRIGUEZ', 19),
(292, 'municipio', 'TORBES', 19),
(293, 'municipio', 'SAN JUDAS TADEO', 19),
(294, 'municipio', 'RAFAEL RANGEL', 20),
(295, 'municipio', 'BOCONO', 20),
(296, 'municipio', 'CARACHE', 20),
(297, 'municipio', 'ESCUQUE', 20),
(298, 'municipio', 'TRUJILLO', 20),
(299, 'municipio', 'URDANETA', 20),
(300, 'municipio', 'VALERA', 20),
(301, 'municipio', 'CANDELARIA', 20),
(302, 'municipio', 'MIRANDA', 20),
(303, 'municipio', 'MONTE CARMELO', 20),
(304, 'municipio', 'MOTATAN', 20),
(305, 'municipio', 'PAMPAN', 20),
(306, 'municipio', 'S RAFAEL CARVAJAL', 20),
(307, 'municipio', 'SUCRE', 20),
(308, 'municipio', 'ANDRES BELLO', 20),
(309, 'municipio', 'BOLIVAR', 20),
(310, 'municipio', 'JOSE F M CAÑIZAL', 20),
(311, 'municipio', 'JUAN V CAMPO ELI', 20),
(312, 'municipio', 'LA CEIBA', 20),
(313, 'municipio', 'PAMPANITO', 20),
(314, 'municipio', 'BOLIVAR', 21),
(315, 'municipio', 'BRUZUAL', 21),
(316, 'municipio', 'NIRGUA', 21),
(317, 'municipio', 'SAN FELIPE', 21),
(318, 'municipio', 'SUCRE', 21),
(319, 'municipio', 'URACHICHE', 21),
(320, 'municipio', 'PEÑA', 21),
(321, 'municipio', 'JOSE ANTONIO PAEZ', 21),
(322, 'municipio', 'LA TRINIDAD', 21),
(323, 'municipio', 'COCOROTE', 21),
(324, 'municipio', 'INDEPENDENCIA', 21),
(325, 'municipio', 'ARISTIDES BASTID', 21),
(326, 'municipio', 'MANUEL MONGE', 21),
(327, 'municipio', 'VEROES', 21),
(328, 'municipio', 'BARALT', 22),
(329, 'municipio', 'SANTA RITA', 22),
(330, 'municipio', 'COLON', 22),
(331, 'municipio', 'MARA', 22),
(332, 'municipio', 'MARACAIBO', 22),
(333, 'municipio', 'MIRANDA', 22),
(334, 'municipio', 'PAEZ', 22),
(335, 'municipio', 'MACHIQUES DE P', 22),
(336, 'municipio', 'SUCRE', 22),
(337, 'municipio', 'LA CAÑADA DE U.', 22),
(338, 'municipio', 'LAGUNILLAS', 22),
(339, 'municipio', 'CATATUMBO', 22),
(340, 'municipio', 'M/ROSARIO DE PERIJA', 22),
(341, 'municipio', 'CABIMAS', 22),
(342, 'municipio', 'VALMORE RODRIGUEZ', 22),
(343, 'municipio', 'JESUS E LOSSADA', 22),
(344, 'municipio', 'ALMIRANTE P', 22),
(345, 'municipio', 'SAN FRANCISCO', 22),
(346, 'municipio', 'JESUS M SEMPRUN', 22),
(347, 'municipio', 'FRANCISCO J PULG', 22),
(348, 'municipio', 'SIMON BOLIVAR', 22),
(349, 'municipio', 'ATURES', 23),
(350, 'municipio', 'ATABAPO', 23),
(351, 'municipio', 'MAROA', 23),
(352, 'municipio', 'RIO NEGRO', 23),
(353, 'municipio', 'AUTANA', 23),
(354, 'municipio', 'MANAPIARE', 23),
(355, 'municipio', 'ALTO ORINOCO', 23),
(356, 'municipio', 'TUCUPITA', 24),
(357, 'municipio', 'PEDERNALES', 24),
(358, 'municipio', 'ANTONIO DIAZ', 24),
(359, 'municipio', 'CASACOIMA', 24),
(360, 'municipio', 'VARGAS', 25),
(361, 'parroquia', 'ALTAGRACIA', 26),
(362, 'parroquia', 'CANDELARIA', 26),
(363, 'parroquia', 'CATEDRAL', 26),
(364, 'parroquia', 'LA PASTORA', 26),
(365, 'parroquia', 'SAN AGUSTIN', 26),
(366, 'parroquia', 'SAN JOSE', 26),
(367, 'parroquia', 'SAN JUAN', 26),
(368, 'parroquia', 'SANTA ROSALIA', 26),
(369, 'parroquia', 'SANTA TERESA', 26),
(370, 'parroquia', 'SUCRE', 26),
(371, 'parroquia', '23 DE ENERO', 26),
(372, 'parroquia', 'ANTIMANO', 26),
(373, 'parroquia', 'EL RECREO', 26),
(374, 'parroquia', 'EL VALLE', 26),
(375, 'parroquia', 'LA VEGA', 26),
(376, 'parroquia', 'MACARAO', 26),
(377, 'parroquia', 'CARICUAO', 26),
(378, 'parroquia', 'EL JUNQUITO', 26),
(379, 'parroquia', 'COCHE', 26),
(380, 'parroquia', 'SAN PEDRO', 26),
(381, 'parroquia', 'SAN BERNARDINO', 26),
(382, 'parroquia', 'EL PARAISO', 26),
(383, 'parroquia', 'ANACO', 27),
(384, 'parroquia', 'SAN JOAQUIN', 27),
(385, 'parroquia', 'CM. ARAGUA DE BARCELONA', 28),
(386, 'parroquia', 'CACHIPO', 28),
(387, 'parroquia', 'EL CARMEN', 29),
(388, 'parroquia', 'SAN CRISTOBAL', 29),
(389, 'parroquia', 'BERGANTIN', 29),
(390, 'parroquia', 'CAIGUA', 29),
(391, 'parroquia', 'EL PILAR', 29),
(392, 'parroquia', 'NARICUAL', 29),
(393, 'parroquia', 'CM. CLARINES', 30),
(394, 'parroquia', 'GUANAPE', 30),
(395, 'parroquia', 'SABANA DE UCHIRE', 30),
(396, 'parroquia', 'CM. ONOTO', 31),
(397, 'parroquia', 'SAN PABLO', 31),
(398, 'parroquia', 'CM. CANTAURA', 32),
(399, 'parroquia', 'LIBERTADOR', 32),
(400, 'parroquia', 'SANTA ROSA', 32),
(401, 'parroquia', 'URICA', 32),
(402, 'parroquia', 'CM. SOLEDAD', 33),
(403, 'parroquia', 'MAMO', 33),
(404, 'parroquia', 'CM. SAN MATEO', 34),
(405, 'parroquia', 'EL CARITO', 34),
(406, 'parroquia', 'SANTA INES', 34),
(407, 'parroquia', 'CM. PARIAGUAN', 35),
(408, 'parroquia', 'ATAPIRIRE', 35),
(409, 'parroquia', 'BOCA DEL PAO', 35),
(410, 'parroquia', 'EL PAO', 35),
(411, 'parroquia', 'CM. MAPIRE', 36),
(412, 'parroquia', 'PIAR', 36),
(413, 'parroquia', 'SN DIEGO DE CABRUTICA', 36),
(414, 'parroquia', 'SANTA CLARA', 36),
(415, 'parroquia', 'UVERITO', 36),
(416, 'parroquia', 'ZUATA', 36),
(417, 'parroquia', 'CM. PUERTO PIRITU', 37),
(418, 'parroquia', 'SAN MIGUEL', 37),
(419, 'parroquia', 'SUCRE', 37),
(420, 'parroquia', 'CM. EL TIGRE', 38),
(421, 'parroquia', 'POZUELOS', 39),
(422, 'parroquia', 'CM PTO. LA CRUZ', 39),
(423, 'parroquia', 'CM. SAN JOSE DE GUANIPA', 40),
(424, 'parroquia', 'GUANTA', 41),
(425, 'parroquia', 'CHORRERON', 41),
(426, 'parroquia', 'PIRITU', 42),
(427, 'parroquia', 'SAN FRANCISCO', 42),
(428, 'parroquia', 'LECHERIAS', 43),
(429, 'parroquia', 'EL MORRO', 43),
(430, 'parroquia', 'VALLE GUANAPE', 44),
(431, 'parroquia', 'SANTA BARBARA', 44),
(432, 'parroquia', 'SANTA ANA', 45),
(433, 'parroquia', 'PUEBLO NUEVO', 45),
(434, 'parroquia', 'EL CHAPARRO', 46),
(435, 'parroquia', 'TOMAS ALFARO CALATRAVA', 46),
(436, 'parroquia', 'BOCA UCHIRE', 47),
(437, 'parroquia', 'BOCA DE CHAVEZ', 47),
(438, 'parroquia', 'ACHAGUAS', 48),
(439, 'parroquia', 'APURITO', 48),
(440, 'parroquia', 'EL YAGUAL', 48),
(441, 'parroquia', 'GUACHARA', 48),
(442, 'parroquia', 'MUCURITAS', 48),
(443, 'parroquia', 'QUESERAS DEL MEDIO', 48),
(444, 'parroquia', 'BRUZUAL', 49),
(445, 'parroquia', 'MANTECAL', 49),
(446, 'parroquia', 'QUINTERO', 49),
(447, 'parroquia', 'SAN VICENTE', 49),
(448, 'parroquia', 'RINCON HONDO', 49),
(449, 'parroquia', 'GUASDUALITO', 50),
(450, 'parroquia', 'ARAMENDI', 50),
(451, 'parroquia', 'EL AMPARO', 50),
(452, 'parroquia', 'SAN CAMILO', 50),
(453, 'parroquia', 'URDANETA', 50),
(454, 'parroquia', 'SAN JUAN DE PAYARA', 51),
(455, 'parroquia', 'CODAZZI', 51),
(456, 'parroquia', 'CUNAVICHE', 51),
(457, 'parroquia', 'ELORZA', 52),
(458, 'parroquia', 'LA TRINIDAD', 52),
(459, 'parroquia', 'SAN FERNANDO', 53),
(460, 'parroquia', 'PEÑALVER', 53),
(461, 'parroquia', 'EL RECREO', 53),
(462, 'parroquia', 'SN RAFAEL DE ATAMAICA', 53),
(463, 'parroquia', 'BIRUACA', 54),
(464, 'parroquia', 'CM. LAS DELICIAS', 55),
(465, 'parroquia', 'CHORONI', 55),
(466, 'parroquia', 'MADRE MA DE SAN JOSE', 55),
(467, 'parroquia', 'JOAQUIN CRESPO', 55),
(468, 'parroquia', 'PEDRO JOSE OVALLES', 55),
(469, 'parroquia', 'JOSE CASANOVA GODOY', 55),
(470, 'parroquia', 'ANDRES ELOY BLANCO', 55),
(471, 'parroquia', 'LOS TACARIGUAS', 55),
(472, 'parroquia', 'CM. TURMERO', 56),
(473, 'parroquia', 'SAMAN DE GUERE', 56),
(474, 'parroquia', 'ALFREDO PACHECO M', 56),
(475, 'parroquia', 'CHUAO', 56),
(476, 'parroquia', 'AREVALO APONTE', 56),
(477, 'parroquia', 'CM. LA VICTORIA', 57),
(478, 'parroquia', 'ZUATA', 57),
(479, 'parroquia', 'PAO DE ZARATE', 57),
(480, 'parroquia', 'CASTOR NIEVES RIOS', 57),
(481, 'parroquia', 'LAS GUACAMAYAS', 57),
(482, 'parroquia', 'CM. SAN CASIMIRO', 58),
(483, 'parroquia', 'VALLE MORIN', 58),
(484, 'parroquia', 'GUIRIPA', 58),
(485, 'parroquia', 'OLLAS DE CARAMACATE', 58),
(486, 'parroquia', 'CM. SAN SEBASTIAN', 59),
(487, 'parroquia', 'CM. CAGUA', 60),
(488, 'parroquia', 'BELLA VISTA', 60),
(489, 'parroquia', 'CM. BARBACOAS', 61),
(490, 'parroquia', 'SAN FRANCISCO DE CARA', 61),
(491, 'parroquia', 'TAGUAY', 61),
(492, 'parroquia', 'LAS PEÑITAS', 61),
(493, 'parroquia', 'CM. VILLA DE CURA', 62),
(494, 'parroquia', 'MAGDALENO', 62),
(495, 'parroquia', 'SAN FRANCISCO DE ASIS', 62),
(496, 'parroquia', 'VALLES DE TUCUTUNEMO', 62),
(497, 'parroquia', 'PQ AUGUSTO MIJARES', 62),
(498, 'parroquia', 'CM. PALO NEGRO', 63),
(499, 'parroquia', 'SAN MARTIN DE PORRES', 63),
(500, 'parroquia', 'CM. SANTA CRUZ', 64),
(501, 'parroquia', 'CM. SAN MATEO', 65),
(502, 'parroquia', 'CM. LAS TEJERIAS', 66),
(503, 'parroquia', 'TIARA', 66),
(504, 'parroquia', 'CM. EL LIMON', 67),
(505, 'parroquia', 'CA A DE AZUCAR', 67),
(506, 'parroquia', 'CM. COLONIA TOVAR', 68),
(507, 'parroquia', 'CM. CAMATAGUA', 69),
(508, 'parroquia', 'CARMEN DE CURA', 69),
(509, 'parroquia', 'CM. EL CONSEJO', 70),
(510, 'parroquia', 'CM. SANTA RITA', 71),
(511, 'parroquia', 'FRANCISCO DE MIRANDA', 71),
(512, 'parroquia', 'MONS FELICIANO G', 71),
(513, 'parroquia', 'OCUMARE DE LA COSTA', 72),
(514, 'parroquia', 'ARISMENDI', 73),
(515, 'parroquia', 'GUADARRAMA', 73),
(516, 'parroquia', 'LA UNION', 73),
(517, 'parroquia', 'SAN ANTONIO', 73),
(518, 'parroquia', 'ALFREDO A LARRIVA', 74),
(519, 'parroquia', 'BARINAS', 74),
(520, 'parroquia', 'SAN SILVESTRE', 74),
(521, 'parroquia', 'SANTA INES', 74),
(522, 'parroquia', 'SANTA LUCIA', 74),
(523, 'parroquia', 'TORUNOS', 74),
(524, 'parroquia', 'EL CARMEN', 74),
(525, 'parroquia', 'ROMULO BETANCOURT', 74),
(526, 'parroquia', 'CORAZON DE JESUS', 74),
(527, 'parroquia', 'RAMON I MENDEZ', 74),
(528, 'parroquia', 'ALTO BARINAS', 74),
(529, 'parroquia', 'MANUEL P FAJARDO', 74),
(530, 'parroquia', 'JUAN A RODRIGUEZ D', 74),
(531, 'parroquia', 'DOMINGA ORTIZ P', 74),
(532, 'parroquia', 'ALTAMIRA', 75),
(533, 'parroquia', 'BARINITAS', 75),
(534, 'parroquia', 'CALDERAS', 75),
(535, 'parroquia', 'SANTA BARBARA', 76),
(536, 'parroquia', 'JOSE IGNACIO DEL PUMAR', 76),
(537, 'parroquia', 'RAMON IGNACIO MENDEZ', 76),
(538, 'parroquia', 'PEDRO BRICEÑO MENDEZ', 76),
(539, 'parroquia', 'EL REAL', 77),
(540, 'parroquia', 'LA LUZ', 77),
(541, 'parroquia', 'OBISPOS', 77),
(542, 'parroquia', 'LOS GUASIMITOS', 77),
(543, 'parroquia', 'CIUDAD BOLIVIA', 78),
(544, 'parroquia', 'IGNACIO BRICEÑO', 78),
(545, 'parroquia', 'PAEZ', 78),
(546, 'parroquia', 'JOSE FELIX RIBAS', 78),
(547, 'parroquia', 'DOLORES', 79),
(548, 'parroquia', 'LIBERTAD', 79),
(549, 'parroquia', 'PALACIO FAJARDO', 79),
(550, 'parroquia', 'SANTA ROSA', 79),
(551, 'parroquia', 'CIUDAD DE NUTRIAS', 80),
(552, 'parroquia', 'EL REGALO', 80),
(553, 'parroquia', 'PUERTO DE NUTRIAS', 80),
(554, 'parroquia', 'SANTA CATALINA', 80),
(555, 'parroquia', 'RODRIGUEZ DOMINGUEZ', 81),
(556, 'parroquia', 'SABANETA', 81),
(557, 'parroquia', 'TICOPORO', 82),
(558, 'parroquia', 'NICOLAS PULIDO', 82),
(559, 'parroquia', 'ANDRES BELLO', 82),
(560, 'parroquia', 'BARRANCAS', 83),
(561, 'parroquia', 'EL SOCORRO', 83),
(562, 'parroquia', 'MASPARRITO', 83),
(563, 'parroquia', 'EL CANTON', 84),
(564, 'parroquia', 'SANTA CRUZ DE GUACAS', 84),
(565, 'parroquia', 'PUERTO VIVAS', 84),
(566, 'parroquia', 'SIMON BOLIVAR', 85),
(567, 'parroquia', 'ONCE DE ABRIL', 85),
(568, 'parroquia', 'VISTA AL SOL', 85),
(569, 'parroquia', 'CHIRICA', 85),
(570, 'parroquia', 'DALLA COSTA', 85),
(571, 'parroquia', 'CACHAMAY', 85),
(572, 'parroquia', 'UNIVERSIDAD', 85),
(573, 'parroquia', 'UNARE', 85),
(574, 'parroquia', 'YOCOIMA', 85),
(575, 'parroquia', 'POZO VERDE', 85),
(576, 'parroquia', 'CM. CAICARA DEL ORINOCO', 86),
(577, 'parroquia', 'ASCENSION FARRERAS', 86),
(578, 'parroquia', 'ALTAGRACIA', 86),
(579, 'parroquia', 'LA URBANA', 86),
(580, 'parroquia', 'GUANIAMO', 86),
(581, 'parroquia', 'PIJIGUAOS', 86),
(582, 'parroquia', 'CATEDRAL', 87),
(583, 'parroquia', 'AGUA SALADA', 87),
(584, 'parroquia', 'LA SABANITA', 87),
(585, 'parroquia', 'VISTA HERMOSA', 87),
(586, 'parroquia', 'MARHUANTA', 87),
(587, 'parroquia', 'JOSE ANTONIO PAEZ', 87),
(588, 'parroquia', 'ORINOCO', 87),
(589, 'parroquia', 'PANAPANA', 87),
(590, 'parroquia', 'ZEA', 87),
(591, 'parroquia', 'CM. UPATA', 88),
(592, 'parroquia', 'ANDRES ELOY BLANCO', 88),
(593, 'parroquia', 'PEDRO COVA', 88),
(594, 'parroquia', 'CM. GUASIPATI', 89),
(595, 'parroquia', 'SALOM', 89),
(596, 'parroquia', 'CM. MARIPA', 90),
(597, 'parroquia', 'ARIPAO', 90),
(598, 'parroquia', 'LAS MAJADAS', 90),
(599, 'parroquia', 'MOITACO', 90),
(600, 'parroquia', 'GUARATARO', 90),
(601, 'parroquia', 'CM. TUMEREMO', 91),
(602, 'parroquia', 'DALLA COSTA', 91),
(603, 'parroquia', 'SAN ISIDRO', 91),
(604, 'parroquia', 'CM. CIUDAD PIAR', 92),
(605, 'parroquia', 'SAN FRANCISCO', 92),
(606, 'parroquia', 'BARCELONETA', 92),
(607, 'parroquia', 'SANTA BARBARA', 92),
(608, 'parroquia', 'CM. SANTA ELENA DE UAIREN', 93),
(609, 'parroquia', 'IKABARU', 93),
(610, 'parroquia', 'CM. EL CALLAO', 94),
(611, 'parroquia', 'CM. EL PALMAR', 95),
(612, 'parroquia', 'BEJUMA', 96),
(613, 'parroquia', 'CANOABO', 96),
(614, 'parroquia', 'SIMON BOLIVAR', 96),
(615, 'parroquia', 'GUIGUE', 97),
(616, 'parroquia', 'BELEN', 97),
(617, 'parroquia', 'TACARIGUA', 97),
(618, 'parroquia', 'MARIARA', 98),
(619, 'parroquia', 'AGUAS CALIENTES', 98),
(620, 'parroquia', 'GUACARA', 99),
(621, 'parroquia', 'CIUDAD ALIANZA', 99),
(622, 'parroquia', 'YAGUA', 99),
(623, 'parroquia', 'MONTALBAN', 100),
(624, 'parroquia', 'MORON', 101),
(625, 'parroquia', 'URAMA', 101),
(626, 'parroquia', 'DEMOCRACIA', 102),
(627, 'parroquia', 'FRATERNIDAD', 102),
(628, 'parroquia', 'GOAIGOAZA', 102),
(629, 'parroquia', 'JUAN JOSE FLORES', 102),
(630, 'parroquia', 'BARTOLOME SALOM', 102),
(631, 'parroquia', 'UNION', 102),
(632, 'parroquia', 'BORBURATA', 102),
(633, 'parroquia', 'PATANEMO', 102),
(634, 'parroquia', 'SAN JOAQUIN', 103),
(635, 'parroquia', 'CANDELARIA', 104),
(636, 'parroquia', 'CATEDRAL', 104),
(637, 'parroquia', 'EL SOCORRO', 104),
(638, 'parroquia', 'MIGUEL PEÑA', 104),
(639, 'parroquia', 'SAN BLAS', 104),
(640, 'parroquia', 'SAN JOSE', 104),
(641, 'parroquia', 'SANTA ROSA', 104),
(642, 'parroquia', 'RAFAEL URDANETA', 104),
(643, 'parroquia', 'NEGRO PRIMERO', 104),
(644, 'parroquia', 'MIRANDA', 105),
(645, 'parroquia', 'U LOS GUAYOS', 106),
(646, 'parroquia', 'NAGUANAGUA', 107),
(647, 'parroquia', 'URB SAN DIEGO', 108),
(648, 'parroquia', 'U TOCUYITO', 109),
(649, 'parroquia', 'U INDEPENDENCIA', 109),
(650, 'parroquia', 'COJEDES', 110),
(651, 'parroquia', 'JUAN DE MATA SUAREZ', 110),
(652, 'parroquia', 'TINAQUILLO', 111),
(653, 'parroquia', 'EL BAUL', 112),
(654, 'parroquia', 'SUCRE', 112),
(655, 'parroquia', 'EL PAO', 113),
(656, 'parroquia', 'LIBERTAD DE COJEDES', 114),
(657, 'parroquia', 'EL AMPARO', 114),
(658, 'parroquia', 'SAN CARLOS DE AUSTRIA', 115),
(659, 'parroquia', 'JUAN ANGEL BRAVO', 115),
(660, 'parroquia', 'MANUEL MANRIQUE', 115),
(661, 'parroquia', 'GRL/JEFE JOSE L SILVA', 116),
(662, 'parroquia', 'MACAPO', 117),
(663, 'parroquia', 'LA AGUADITA', 117),
(664, 'parroquia', 'ROMULO GALLEGOS', 118),
(665, 'parroquia', 'SAN JUAN DE LOS CAYOS', 119),
(666, 'parroquia', 'CAPADARE', 119),
(667, 'parroquia', 'LA PASTORA', 119),
(668, 'parroquia', 'LIBERTADOR', 119),
(669, 'parroquia', 'SAN LUIS', 120),
(670, 'parroquia', 'ARACUA', 120),
(671, 'parroquia', 'LA PEÑA', 120),
(672, 'parroquia', 'CAPATARIDA', 121),
(673, 'parroquia', 'BOROJO', 121),
(674, 'parroquia', 'SEQUE', 121),
(675, 'parroquia', 'ZAZARIDA', 121),
(676, 'parroquia', 'BARIRO', 121),
(677, 'parroquia', 'GUAJIRO', 121),
(678, 'parroquia', 'NORTE', 122),
(679, 'parroquia', 'CARIRUBANA', 122),
(680, 'parroquia', 'PUNTA CARDON', 122),
(681, 'parroquia', 'SANTA ANA', 122),
(682, 'parroquia', 'LA VELA DE CORO', 123),
(683, 'parroquia', 'ACURIGUA', 123),
(684, 'parroquia', 'GUAIBACOA', 123),
(685, 'parroquia', 'MACORUCA', 123),
(686, 'parroquia', 'LAS CALDERAS', 123),
(687, 'parroquia', 'PEDREGAL', 124),
(688, 'parroquia', 'AGUA CLARA', 124),
(689, 'parroquia', 'AVARIA', 124),
(690, 'parroquia', 'PIEDRA GRANDE', 124),
(691, 'parroquia', 'PURURECHE', 124),
(692, 'parroquia', 'PUEBLO NUEVO', 125),
(693, 'parroquia', 'ADICORA', 125),
(694, 'parroquia', 'BARAIVED', 125),
(695, 'parroquia', 'BUENA VISTA', 125),
(696, 'parroquia', 'JADACAQUIVA', 125),
(697, 'parroquia', 'MORUY', 125),
(698, 'parroquia', 'EL VINCULO', 125),
(699, 'parroquia', 'EL HATO', 125),
(700, 'parroquia', 'ADAURE', 125),
(701, 'parroquia', 'CHURUGUARA', 126),
(702, 'parroquia', 'AGUA LARGA', 126),
(703, 'parroquia', 'INDEPENDENCIA', 126),
(704, 'parroquia', 'MAPARARI', 126),
(705, 'parroquia', 'EL PAUJI', 126),
(706, 'parroquia', 'MENE DE MAUROA', 127),
(707, 'parroquia', 'CASIGUA', 127),
(708, 'parroquia', 'SAN FELIX', 127),
(709, 'parroquia', 'SAN ANTONIO', 128),
(710, 'parroquia', 'SAN GABRIEL', 128),
(711, 'parroquia', 'SANTA ANA', 128),
(712, 'parroquia', 'GUZMAN GUILLERMO', 128),
(713, 'parroquia', 'MITARE', 128),
(714, 'parroquia', 'SABANETA', 128),
(715, 'parroquia', 'RIO SECO', 128),
(716, 'parroquia', 'CABURE', 129),
(717, 'parroquia', 'CURIMAGUA', 129),
(718, 'parroquia', 'COLINA', 129),
(719, 'parroquia', 'TUCACAS', 130),
(720, 'parroquia', 'BOCA DE AROA', 130),
(721, 'parroquia', 'PUERTO CUMAREBO', 131),
(722, 'parroquia', 'LA CIENAGA', 131),
(723, 'parroquia', 'LA SOLEDAD', 131),
(724, 'parroquia', 'PUEBLO CUMAREBO', 131),
(725, 'parroquia', 'ZAZARIDA', 131),
(726, 'parroquia', 'CM. DABAJURO', 132),
(727, 'parroquia', 'CHICHIRIVICHE', 133),
(728, 'parroquia', 'BOCA DE TOCUYO', 133),
(729, 'parroquia', 'TOCUYO DE LA COSTA', 133),
(730, 'parroquia', 'LOS TAQUES', 134),
(731, 'parroquia', 'JUDIBANA', 134),
(732, 'parroquia', 'PIRITU', 135),
(733, 'parroquia', 'SAN JOSE DE LA COSTA', 135),
(734, 'parroquia', 'STA.CRUZ DE BUCARAL', 136),
(735, 'parroquia', 'EL CHARAL', 136),
(736, 'parroquia', 'LAS VEGAS DEL TUY', 136),
(737, 'parroquia', 'CM. MIRIMIRE', 137),
(738, 'parroquia', 'JACURA', 138),
(739, 'parroquia', 'AGUA LINDA', 138),
(740, 'parroquia', 'ARAURIMA', 138),
(741, 'parroquia', 'CM. YARACAL', 139),
(742, 'parroquia', 'CM. PALMA SOLA', 140),
(743, 'parroquia', 'SUCRE', 141),
(744, 'parroquia', 'PECAYA', 141),
(745, 'parroquia', 'URUMACO', 142),
(746, 'parroquia', 'BRUZUAL', 142),
(747, 'parroquia', 'CM. TOCOPERO', 143),
(748, 'parroquia', 'VALLE DE LA PASCUA', 144),
(749, 'parroquia', 'ESPINO', 144),
(750, 'parroquia', 'EL SOMBRERO', 145),
(751, 'parroquia', 'SOSA', 145),
(752, 'parroquia', 'CALABOZO', 146),
(753, 'parroquia', 'EL CALVARIO', 146),
(754, 'parroquia', 'EL RASTRO', 146),
(755, 'parroquia', 'GUARDATINAJAS', 146),
(756, 'parroquia', 'ALTAGRACIA DE ORITUCO', 147),
(757, 'parroquia', 'LEZAMA', 147),
(758, 'parroquia', 'LIBERTAD DE ORITUCO', 147),
(759, 'parroquia', 'SAN FCO DE MACAIRA', 147),
(760, 'parroquia', 'SAN RAFAEL DE ORITUCO', 147),
(761, 'parroquia', 'SOUBLETTE', 147),
(762, 'parroquia', 'PASO REAL DE MACAIRA', 147),
(763, 'parroquia', 'TUCUPIDO', 148),
(764, 'parroquia', 'SAN RAFAEL DE LAYA', 148),
(765, 'parroquia', 'SAN JUAN DE LOS MORROS', 149),
(766, 'parroquia', 'PARAPARA', 149),
(767, 'parroquia', 'CANTAGALLO', 149),
(768, 'parroquia', 'ZARAZA', 150),
(769, 'parroquia', 'SAN JOSE DE UNARE', 150),
(770, 'parroquia', 'CAMAGUAN', 151),
(771, 'parroquia', 'PUERTO MIRANDA', 151),
(772, 'parroquia', 'UVERITO', 151),
(773, 'parroquia', 'SAN JOSE DE GUARIBE', 152),
(774, 'parroquia', 'LAS MERCEDES', 153),
(775, 'parroquia', 'STA RITA DE MANAPIRE', 153),
(776, 'parroquia', 'CABRUTA', 153),
(777, 'parroquia', 'EL SOCORRO', 154),
(778, 'parroquia', 'ORTIZ', 155),
(779, 'parroquia', 'SAN FCO. DE TIZNADOS', 155),
(780, 'parroquia', 'SAN JOSE DE TIZNADOS', 155),
(781, 'parroquia', 'S LORENZO DE TIZNADOS', 155),
(782, 'parroquia', 'SANTA MARIA DE IPIRE', 156),
(783, 'parroquia', 'ALTAMIRA', 156),
(784, 'parroquia', 'CHAGUARAMAS', 157),
(785, 'parroquia', 'GUAYABAL', 158),
(786, 'parroquia', 'CAZORLA', 158),
(787, 'parroquia', 'FREITEZ', 159),
(788, 'parroquia', 'JOSE MARIA BLANCO', 159),
(789, 'parroquia', 'CATEDRAL', 160),
(790, 'parroquia', 'LA CONCEPCION', 160),
(791, 'parroquia', 'SANTA ROSA', 160),
(792, 'parroquia', 'UNION', 160),
(793, 'parroquia', 'EL CUJI', 160),
(794, 'parroquia', 'TAMACA', 160),
(795, 'parroquia', 'JUAN DE VILLEGAS', 160),
(796, 'parroquia', 'AGUEDO F. ALVARADO', 160),
(797, 'parroquia', 'BUENA VISTA', 160),
(798, 'parroquia', 'JUAREZ', 160),
(799, 'parroquia', 'JUAN B RODRIGUEZ', 161),
(800, 'parroquia', 'DIEGO DE LOZADA', 161),
(801, 'parroquia', 'SAN MIGUEL', 161),
(802, 'parroquia', 'CUARA', 161),
(803, 'parroquia', 'PARAISO DE SAN JOSE', 161),
(804, 'parroquia', 'TINTORERO', 161),
(805, 'parroquia', 'JOSE BERNARDO DORANTE', 161),
(806, 'parroquia', 'CRNEL. MARIANO PERAZA', 161),
(807, 'parroquia', 'BOLIVAR', 162),
(808, 'parroquia', 'ANZOATEGUI', 162),
(809, 'parroquia', 'GUARICO', 162),
(810, 'parroquia', 'HUMOCARO ALTO', 162),
(811, 'parroquia', 'HUMOCARO BAJO', 162),
(812, 'parroquia', 'MORAN', 162),
(813, 'parroquia', 'HILARIO LUNA Y LUNA', 162),
(814, 'parroquia', 'LA CANDELARIA', 162),
(815, 'parroquia', 'CABUDARE', 163),
(816, 'parroquia', 'JOSE G. BASTIDAS', 163),
(817, 'parroquia', 'AGUA VIVA', 163),
(818, 'parroquia', 'TRINIDAD SAMUEL', 164),
(819, 'parroquia', 'ANTONIO DIAZ', 164),
(820, 'parroquia', 'CAMACARO', 164),
(821, 'parroquia', 'CASTAÑEDA', 164),
(822, 'parroquia', 'CHIQUINQUIRA', 164),
(823, 'parroquia', 'ESPINOZA LOS MONTEROS', 164),
(824, 'parroquia', 'LARA', 164),
(825, 'parroquia', 'MANUEL MORILLO', 164),
(826, 'parroquia', 'MONTES DE OCA', 164),
(827, 'parroquia', 'TORRES', 164),
(828, 'parroquia', 'EL BLANCO', 164),
(829, 'parroquia', 'MONTA A VERDE', 164),
(830, 'parroquia', 'HERIBERTO ARROYO', 164),
(831, 'parroquia', 'LAS MERCEDES', 164),
(832, 'parroquia', 'CECILIO ZUBILLAGA', 164),
(833, 'parroquia', 'REYES VARGAS', 164),
(834, 'parroquia', 'ALTAGRACIA', 164),
(835, 'parroquia', 'SIQUISIQUE', 165),
(836, 'parroquia', 'SAN MIGUEL', 165),
(837, 'parroquia', 'XAGUAS', 165),
(838, 'parroquia', 'MOROTURO', 165),
(839, 'parroquia', 'PIO TAMAYO', 166),
(840, 'parroquia', 'YACAMBU', 166),
(841, 'parroquia', 'QBDA. HONDA DE GUACHE', 166),
(842, 'parroquia', 'SARARE', 167),
(843, 'parroquia', 'GUSTAVO VEGAS LEON', 167),
(844, 'parroquia', 'BURIA', 167),
(845, 'parroquia', 'GABRIEL PICON G.', 168),
(846, 'parroquia', 'HECTOR AMABLE MORA', 168),
(847, 'parroquia', 'JOSE NUCETE SARDI', 168),
(848, 'parroquia', 'PULIDO MENDEZ', 168),
(849, 'parroquia', 'PTE. ROMULO GALLEGOS', 168),
(850, 'parroquia', 'PRESIDENTE BETANCOURT', 168),
(851, 'parroquia', 'PRESIDENTE PAEZ', 168),
(852, 'parroquia', 'CM. LA AZULITA', 169),
(853, 'parroquia', 'CM. CANAGUA', 170),
(854, 'parroquia', 'CAPURI', 170),
(855, 'parroquia', 'CHACANTA', 170),
(856, 'parroquia', 'EL MOLINO', 170),
(857, 'parroquia', 'GUAIMARAL', 170),
(858, 'parroquia', 'MUCUTUY', 170),
(859, 'parroquia', 'MUCUCHACHI', 170),
(860, 'parroquia', 'ACEQUIAS', 171),
(861, 'parroquia', 'JAJI', 171),
(862, 'parroquia', 'LA MESA', 171),
(863, 'parroquia', 'SAN JOSE', 171),
(864, 'parroquia', 'MONTALBAN', 171),
(865, 'parroquia', 'MATRIZ', 171),
(866, 'parroquia', 'FERNANDEZ PEÑA', 171),
(867, 'parroquia', 'CM. GUARAQUE', 172),
(868, 'parroquia', 'MESA DE QUINTERO', 172),
(869, 'parroquia', 'RIO NEGRO', 172),
(870, 'parroquia', 'CM. ARAPUEY', 173),
(871, 'parroquia', 'PALMIRA', 173),
(872, 'parroquia', 'CM. TORONDOY', 174),
(873, 'parroquia', 'SAN CRISTOBAL DE T', 174),
(874, 'parroquia', 'ARIAS', 175),
(875, 'parroquia', 'SAGRARIO', 175),
(876, 'parroquia', 'MILLA', 175),
(877, 'parroquia', 'EL LLANO', 175),
(878, 'parroquia', 'JUAN RODRIGUEZ SUAREZ', 175),
(879, 'parroquia', 'JACINTO PLAZA', 175),
(880, 'parroquia', 'DOMINGO PEÑA', 175),
(881, 'parroquia', 'GONZALO PICON FEBRES', 175),
(882, 'parroquia', 'OSUNA RODRIGUEZ', 175),
(883, 'parroquia', 'LASSO DE LA VEGA', 175),
(884, 'parroquia', 'CARACCIOLO PARRA P', 175),
(885, 'parroquia', 'MARIANO PICON SALAS', 175),
(886, 'parroquia', 'ANTONIO SPINETTI DINI', 175),
(887, 'parroquia', 'EL MORRO', 175),
(888, 'parroquia', 'LOS NEVADOS', 175),
(889, 'parroquia', 'CM. TABAY', 176),
(890, 'parroquia', 'CM. TIMOTES', 177),
(891, 'parroquia', 'ANDRES ELOY BLANCO', 177),
(892, 'parroquia', 'PIÑANGO', 177),
(893, 'parroquia', 'LA VENTA', 177),
(894, 'parroquia', 'CM. STA CRUZ DE MORA', 178),
(895, 'parroquia', 'MESA BOLIVAR', 178),
(896, 'parroquia', 'MESA DE LAS PALMAS', 178),
(897, 'parroquia', 'CM. STA ELENA DE ARENALES', 179),
(898, 'parroquia', 'ELOY PAREDES', 179),
(899, 'parroquia', 'PQ R DE ALCAZAR', 179),
(900, 'parroquia', 'CM. TUCANI', 180),
(901, 'parroquia', 'FLORENCIO RAMIREZ', 180),
(902, 'parroquia', 'CM. SANTO DOMINGO', 181),
(903, 'parroquia', 'LAS PIEDRAS', 181),
(904, 'parroquia', 'CM. PUEBLO LLANO', 182),
(905, 'parroquia', 'CM. MUCUCHIES', 183),
(906, 'parroquia', 'MUCURUBA', 183),
(907, 'parroquia', 'SAN RAFAEL', 183),
(908, 'parroquia', 'CACUTE', 183),
(909, 'parroquia', 'LA TOMA', 183),
(910, 'parroquia', 'CM. BAILADORES', 184),
(911, 'parroquia', 'GERONIMO MALDONADO', 184),
(912, 'parroquia', 'CM. LAGUNILLAS', 185),
(913, 'parroquia', 'CHIGUARA', 185),
(914, 'parroquia', 'ESTANQUES', 185),
(915, 'parroquia', 'SAN JUAN', 185),
(916, 'parroquia', 'PUEBLO NUEVO DEL SUR', 185),
(917, 'parroquia', 'LA TRAMPA', 185),
(918, 'parroquia', 'EL LLANO', 186),
(919, 'parroquia', 'TOVAR', 186),
(920, 'parroquia', 'EL AMPARO', 186),
(921, 'parroquia', 'SAN FRANCISCO', 186),
(922, 'parroquia', 'CM. NUEVA BOLIVIA', 187),
(923, 'parroquia', 'INDEPENDENCIA', 187),
(924, 'parroquia', 'MARIA C PALACIOS', 187),
(925, 'parroquia', 'SANTA APOLONIA', 187),
(926, 'parroquia', 'CM. STA MARIA DE CAPARO', 188),
(927, 'parroquia', 'CM. ARICAGUA', 189),
(928, 'parroquia', 'SAN ANTONIO', 189),
(929, 'parroquia', 'CM. ZEA', 190),
(930, 'parroquia', 'CAÑO EL TIGRE', 190),
(931, 'parroquia', 'CAUCAGUA', 191),
(932, 'parroquia', 'ARAGUITA', 191),
(933, 'parroquia', 'AREVALO GONZALEZ', 191),
(934, 'parroquia', 'CAPAYA', 191),
(935, 'parroquia', 'PANAQUIRE', 191),
(936, 'parroquia', 'RIBAS', 191),
(937, 'parroquia', 'EL CAFE', 191),
(938, 'parroquia', 'MARIZAPA', 191),
(939, 'parroquia', 'HIGUEROTE', 192),
(940, 'parroquia', 'CURIEPE', 192),
(941, 'parroquia', 'TACARIGUA', 192),
(942, 'parroquia', 'LOS TEQUES', 193),
(943, 'parroquia', 'CECILIO ACOSTA', 193),
(944, 'parroquia', 'PARACOTOS', 193),
(945, 'parroquia', 'SAN PEDRO', 193),
(946, 'parroquia', 'TACATA', 193),
(947, 'parroquia', 'EL JARILLO', 193),
(948, 'parroquia', 'ALTAGRACIA DE LA M', 193),
(949, 'parroquia', 'STA TERESA DEL TUY', 194),
(950, 'parroquia', 'EL CARTANAL', 194),
(951, 'parroquia', 'OCUMARE DEL TUY', 195),
(952, 'parroquia', 'LA DEMOCRACIA', 195),
(953, 'parroquia', 'SANTA BARBARA', 195),
(954, 'parroquia', 'RIO CHICO', 196),
(955, 'parroquia', 'EL GUAPO', 196),
(956, 'parroquia', 'TACARIGUA DE LA LAGUNA', 196),
(957, 'parroquia', 'PAPARO', 196),
(958, 'parroquia', 'SN FERNANDO DEL GUAPO', 196),
(959, 'parroquia', 'SANTA LUCIA', 197),
(960, 'parroquia', 'GUARENAS', 198),
(961, 'parroquia', 'PETARE', 199),
(962, 'parroquia', 'LEONCIO MARTINEZ', 199),
(963, 'parroquia', 'CAUCAGUITA', 199),
(964, 'parroquia', 'FILAS DE MARICHES', 199),
(965, 'parroquia', 'LA DOLORITA', 199),
(966, 'parroquia', 'CUA', 200),
(967, 'parroquia', 'NUEVA CUA', 200),
(968, 'parroquia', 'GUATIRE', 201),
(969, 'parroquia', 'BOLIVAR', 201),
(970, 'parroquia', 'CHARALLAVE', 202),
(971, 'parroquia', 'LAS BRISAS', 202),
(972, 'parroquia', 'SAN ANTONIO LOS ALTOS', 203),
(973, 'parroquia', 'SAN JOSE DE BARLOVENTO', 204),
(974, 'parroquia', 'CUMBO', 204),
(975, 'parroquia', 'SAN FCO DE YARE', 205),
(976, 'parroquia', 'S ANTONIO DE YARE', 205),
(977, 'parroquia', 'BARUTA', 206),
(978, 'parroquia', 'EL CAFETAL', 206),
(979, 'parroquia', 'LAS MINAS DE BARUTA', 206),
(980, 'parroquia', 'CARRIZAL', 207),
(981, 'parroquia', 'CHACAO', 208),
(982, 'parroquia', 'EL HATILLO', 209),
(983, 'parroquia', 'MAMPORAL', 210),
(984, 'parroquia', 'CUPIRA', 211),
(985, 'parroquia', 'MACHURUCUTO', 211),
(986, 'parroquia', 'CM. SAN ANTONIO', 212),
(987, 'parroquia', 'SAN FRANCISCO', 212),
(988, 'parroquia', 'CM. CARIPITO', 213),
(989, 'parroquia', 'CM. CARIPE', 214),
(990, 'parroquia', 'TERESEN', 214),
(991, 'parroquia', 'EL GUACHARO', 214),
(992, 'parroquia', 'SAN AGUSTIN', 214),
(993, 'parroquia', 'LA GUANOTA', 214),
(994, 'parroquia', 'SABANA DE PIEDRA', 214),
(995, 'parroquia', 'CM. CAICARA', 215),
(996, 'parroquia', 'AREO', 215),
(997, 'parroquia', 'SAN FELIX', 215),
(998, 'parroquia', 'VIENTO FRESCO', 215),
(999, 'parroquia', 'CM. PUNTA DE MATA', 216),
(1000, 'parroquia', 'EL TEJERO', 216),
(1001, 'parroquia', 'CM. TEMBLADOR', 217),
(1002, 'parroquia', 'TABASCA', 217),
(1003, 'parroquia', 'LAS ALHUACAS', 217),
(1004, 'parroquia', 'CHAGUARAMAS', 217),
(1005, 'parroquia', 'EL FURRIAL', 218),
(1006, 'parroquia', 'JUSEPIN', 218),
(1007, 'parroquia', 'EL COROZO', 218),
(1008, 'parroquia', 'SAN VICENTE', 218),
(1009, 'parroquia', 'LA PICA', 218),
(1010, 'parroquia', 'ALTO DE LOS GODOS', 218),
(1011, 'parroquia', 'BOQUERON', 218),
(1012, 'parroquia', 'LAS COCUIZAS', 218),
(1013, 'parroquia', 'SANTA CRUZ', 218),
(1014, 'parroquia', 'SAN SIMON', 218),
(1015, 'parroquia', 'CM. ARAGUA', 219),
(1016, 'parroquia', 'CHAGUARAMAL', 219),
(1017, 'parroquia', 'GUANAGUANA', 219),
(1018, 'parroquia', 'APARICIO', 219),
(1019, 'parroquia', 'TAGUAYA', 219),
(1020, 'parroquia', 'EL PINTO', 219),
(1021, 'parroquia', 'LA TOSCANA', 219),
(1022, 'parroquia', 'CM. QUIRIQUIRE', 220),
(1023, 'parroquia', 'CACHIPO', 220),
(1024, 'parroquia', 'CM. BARRANCAS', 221),
(1025, 'parroquia', 'LOS BARRANCOS DE FAJARDO', 221),
(1026, 'parroquia', 'CM. AGUASAY', 222),
(1027, 'parroquia', 'CM. SANTA BARBARA', 223),
(1028, 'parroquia', 'CM. URACOA', 224),
(1029, 'parroquia', 'CM. LA ASUNCION', 225),
(1030, 'parroquia', 'CM. SAN JUAN BAUTISTA', 226),
(1031, 'parroquia', 'ZABALA', 226),
(1032, 'parroquia', 'CM. SANTA ANA', 227),
(1033, 'parroquia', 'GUEVARA', 227),
(1034, 'parroquia', 'MATASIETE', 227),
(1035, 'parroquia', 'BOLIVAR', 227),
(1036, 'parroquia', 'SUCRE', 227),
(1037, 'parroquia', 'CM. PAMPATAR', 228),
(1038, 'parroquia', 'AGUIRRE', 228),
(1039, 'parroquia', 'CM. JUAN GRIEGO', 229),
(1040, 'parroquia', 'ADRIAN', 229),
(1041, 'parroquia', 'CM. PORLAMAR', 230),
(1042, 'parroquia', 'CM. BOCA DEL RIO', 231),
(1043, 'parroquia', 'SAN FRANCISCO', 231),
(1044, 'parroquia', 'CM. SAN PEDRO DE COCHE', 232),
(1045, 'parroquia', 'VICENTE FUENTES', 232),
(1046, 'parroquia', 'CM. PUNTA DE PIEDRAS', 233),
(1047, 'parroquia', 'LOS BARALES', 233),
(1048, 'parroquia', 'CM.LA PLAZA DE PARAGUACHI', 234),
(1049, 'parroquia', 'CM. VALLE ESP SANTO', 235),
(1050, 'parroquia', 'FRANCISCO FAJARDO', 235),
(1051, 'parroquia', 'CM. ARAURE', 236),
(1052, 'parroquia', 'RIO ACARIGUA', 236),
(1053, 'parroquia', 'CM. PIRITU', 237),
(1054, 'parroquia', 'UVERAL', 237),
(1055, 'parroquia', 'CM. GUANARE', 238),
(1056, 'parroquia', 'CORDOBA', 238),
(1057, 'parroquia', 'SAN JUAN GUANAGUANARE', 238),
(1058, 'parroquia', 'VIRGEN DE LA COROMOTO', 238),
(1059, 'parroquia', 'SAN JOSE DE LA MONTAÑA', 238),
(1060, 'parroquia', 'CM. GUANARITO', 239),
(1061, 'parroquia', 'TRINIDAD DE LA CAPILLA', 239),
(1062, 'parroquia', 'DIVINA PASTORA', 239),
(1063, 'parroquia', 'CM. OSPINO', 240),
(1064, 'parroquia', 'APARICION', 240),
(1065, 'parroquia', 'LA ESTACION', 240),
(1066, 'parroquia', 'CM. ACARIGUA', 241),
(1067, 'parroquia', 'PAYARA', 241),
(1068, 'parroquia', 'PIMPINELA', 241),
(1069, 'parroquia', 'RAMON PERAZA', 241),
(1070, 'parroquia', 'CM. BISCUCUY', 242),
(1071, 'parroquia', 'CONCEPCION', 242),
(1072, 'parroquia', 'SAN RAFAEL PALO ALZADO', 242),
(1073, 'parroquia', 'UVENCIO A VELASQUEZ', 242),
(1074, 'parroquia', 'SAN JOSE DE SAGUAZ', 242),
(1075, 'parroquia', 'VILLA ROSA', 242),
(1076, 'parroquia', 'CM. VILLA BRUZUAL', 243),
(1077, 'parroquia', 'CANELONES', 243),
(1078, 'parroquia', 'SANTA CRUZ', 243),
(1079, 'parroquia', 'SAN ISIDRO LABRADOR', 243),
(1080, 'parroquia', 'CM. CHABASQUEN', 244),
(1081, 'parroquia', 'PEÑA BLANCA', 244),
(1082, 'parroquia', 'CM. AGUA BLANCA', 245),
(1083, 'parroquia', 'CM. PAPELON', 246),
(1084, 'parroquia', 'CAÑO DELGADITO', 246),
(1085, 'parroquia', 'CM. BOCONOITO', 247),
(1086, 'parroquia', 'ANTOLIN TOVAR AQUINO', 247),
(1087, 'parroquia', 'CM. SAN RAFAEL DE ONOTO', 248),
(1088, 'parroquia', 'SANTA FE', 248),
(1089, 'parroquia', 'THERMO MORLES', 248),
(1090, 'parroquia', 'CM. EL PLAYON', 249),
(1091, 'parroquia', 'FLORIDA', 249),
(1092, 'parroquia', 'RIO CARIBE', 250),
(1093, 'parroquia', 'SAN JUAN GALDONAS', 250),
(1094, 'parroquia', 'PUERTO SANTO', 250),
(1095, 'parroquia', 'EL MORRO DE PTO SANTO', 250),
(1096, 'parroquia', 'ANTONIO JOSE DE SUCRE', 250),
(1097, 'parroquia', 'EL PILAR', 251),
(1098, 'parroquia', 'EL RINCON', 251),
(1099, 'parroquia', 'GUARAUNOS', 251),
(1100, 'parroquia', 'TUNAPUICITO', 251),
(1101, 'parroquia', 'UNION', 251),
(1102, 'parroquia', 'GRAL FCO. A VASQUEZ', 251),
(1103, 'parroquia', 'SANTA CATALINA', 252),
(1104, 'parroquia', 'SANTA ROSA', 252),
(1105, 'parroquia', 'SANTA TERESA', 252),
(1106, 'parroquia', 'BOLIVAR', 252),
(1107, 'parroquia', 'MACARAPANA', 252),
(1108, 'parroquia', 'YAGUARAPARO', 253),
(1109, 'parroquia', 'LIBERTAD', 253),
(1110, 'parroquia', 'PAUJIL', 253),
(1111, 'parroquia', 'IRAPA', 254),
(1112, 'parroquia', 'CAMPO CLARO', 254),
(1113, 'parroquia', 'SORO', 254),
(1114, 'parroquia', 'SAN ANTONIO DE IRAPA', 254),
(1115, 'parroquia', 'MARABAL', 254),
(1116, 'parroquia', 'CM. SAN ANT DEL GOLFO', 255),
(1117, 'parroquia', 'CUMANACOA', 256),
(1118, 'parroquia', 'ARENAS', 256),
(1119, 'parroquia', 'ARICAGUA', 256),
(1120, 'parroquia', 'COCOLLAR', 256),
(1121, 'parroquia', 'SAN FERNANDO', 256),
(1122, 'parroquia', 'SAN LORENZO', 256),
(1123, 'parroquia', 'CARIACO', 257),
(1124, 'parroquia', 'CATUARO', 257),
(1125, 'parroquia', 'RENDON', 257),
(1126, 'parroquia', 'SANTA CRUZ', 257),
(1127, 'parroquia', 'SANTA MARIA', 257),
(1128, 'parroquia', 'ALTAGRACIA', 258),
(1129, 'parroquia', 'AYACUCHO', 258),
(1130, 'parroquia', 'SANTA INES', 258),
(1131, 'parroquia', 'VALENTIN VALIENTE', 258),
(1132, 'parroquia', 'SAN JUAN', 258),
(1133, 'parroquia', 'GRAN MARISCAL', 258),
(1134, 'parroquia', 'RAUL LEONI', 258),
(1135, 'parroquia', 'GUIRIA', 259),
(1136, 'parroquia', 'CRISTOBAL COLON', 259),
(1137, 'parroquia', 'PUNTA DE PIEDRA', 259),
(1138, 'parroquia', 'BIDEAU', 259),
(1139, 'parroquia', 'MARIÑO', 260),
(1140, 'parroquia', 'ROMULO GALLEGOS', 260),
(1141, 'parroquia', 'TUNAPUY', 261),
(1142, 'parroquia', 'CAMPO ELIAS', 261),
(1143, 'parroquia', 'SAN JOSE DE AREOCUAR', 262),
(1144, 'parroquia', 'TAVERA ACOSTA', 262),
(1145, 'parroquia', 'CM. MARIGUITAR', 263),
(1146, 'parroquia', 'ARAYA', 264),
(1147, 'parroquia', 'MANICUARE', 264),
(1148, 'parroquia', 'CHACOPATA', 264),
(1149, 'parroquia', 'CM. COLON', 265),
(1150, 'parroquia', 'RIVAS BERTI', 265),
(1151, 'parroquia', 'SAN PEDRO DEL RIO', 265),
(1152, 'parroquia', 'CM. SAN ANT DEL TACHIRA', 266),
(1153, 'parroquia', 'PALOTAL', 266),
(1154, 'parroquia', 'JUAN VICENTE GOMEZ', 266),
(1155, 'parroquia', 'ISAIAS MEDINA ANGARIT', 266),
(1156, 'parroquia', 'CM. CAPACHO NUEVO', 267),
(1157, 'parroquia', 'JUAN GERMAN ROSCIO', 267),
(1158, 'parroquia', 'ROMAN CARDENAS', 267),
(1159, 'parroquia', 'CM. TARIBA', 268),
(1160, 'parroquia', 'LA FLORIDA', 268),
(1161, 'parroquia', 'AMENODORO RANGEL LAMU', 268),
(1162, 'parroquia', 'CM. LA GRITA', 269),
(1163, 'parroquia', 'EMILIO C. GUERRERO', 269),
(1164, 'parroquia', 'MONS. MIGUEL A SALAS', 269),
(1165, 'parroquia', 'CM. RUBIO', 270),
(1166, 'parroquia', 'BRAMON', 270),
(1167, 'parroquia', 'LA PETROLEA', 270),
(1168, 'parroquia', 'QUINIMARI', 270),
(1169, 'parroquia', 'CM. LOBATERA', 271),
(1170, 'parroquia', 'CONSTITUCION', 271),
(1171, 'parroquia', 'LA CONCORDIA', 272),
(1172, 'parroquia', 'PEDRO MARIA MORANTES', 272),
(1173, 'parroquia', 'SN JUAN BAUTISTA', 272),
(1174, 'parroquia', 'SAN SEBASTIAN', 272),
(1175, 'parroquia', 'DR. FCO. ROMERO LOBO', 272),
(1176, 'parroquia', 'CM. PREGONERO', 273),
(1177, 'parroquia', 'CARDENAS', 273),
(1178, 'parroquia', 'POTOSI', 273),
(1179, 'parroquia', 'JUAN PABLO PEÑALOZA', 273),
(1180, 'parroquia', 'CM. STA. ANA  DEL TACHIRA', 274),
(1181, 'parroquia', 'CM. LA FRIA', 275),
(1182, 'parroquia', 'BOCA DE GRITA', 275),
(1183, 'parroquia', 'JOSE ANTONIO PAEZ', 275),
(1184, 'parroquia', 'CM. PALMIRA', 276),
(1185, 'parroquia', 'CM. MICHELENA', 277),
(1186, 'parroquia', 'CM. ABEJALES', 278),
(1187, 'parroquia', 'SAN JOAQUIN DE NAVAY', 278),
(1188, 'parroquia', 'DORADAS', 278),
(1189, 'parroquia', 'EMETERIO OCHOA', 278),
(1190, 'parroquia', 'CM. COLONCITO', 279),
(1191, 'parroquia', 'LA PALMITA', 279),
(1192, 'parroquia', 'CM. UREÑA', 280),
(1193, 'parroquia', 'NUEVA ARCADIA', 280),
(1194, 'parroquia', 'CM. QUENIQUEA', 281),
(1195, 'parroquia', 'SAN PABLO', 281),
(1196, 'parroquia', 'ELEAZAR LOPEZ CONTRERA', 281),
(1197, 'parroquia', 'CM. CORDERO', 282),
(1198, 'parroquia', 'CM.SAN RAFAEL DEL PINAL', 283),
(1199, 'parroquia', 'SANTO DOMINGO', 283),
(1200, 'parroquia', 'ALBERTO ADRIANI', 283),
(1201, 'parroquia', 'CM. CAPACHO VIEJO', 284),
(1202, 'parroquia', 'CIPRIANO CASTRO', 284),
(1203, 'parroquia', 'MANUEL FELIPE RUGELES', 284),
(1204, 'parroquia', 'CM. LA TENDIDA', 285),
(1205, 'parroquia', 'BOCONO', 285),
(1206, 'parroquia', 'HERNANDEZ', 285),
(1207, 'parroquia', 'CM. SEBORUCO', 286),
(1208, 'parroquia', 'CM. LAS MESAS', 287),
(1209, 'parroquia', 'CM. SAN JOSE DE BOLIVAR', 288),
(1210, 'parroquia', 'CM. EL COBRE', 289),
(1211, 'parroquia', 'CM. DELICIAS', 290),
(1212, 'parroquia', 'CM. SAN SIMON', 291),
(1213, 'parroquia', 'CM. SAN JOSECITO', 292),
(1214, 'parroquia', 'CM. UMUQUENA', 293),
(1215, 'parroquia', 'BETIJOQUE', 294),
(1216, 'parroquia', 'JOSE G HERNANDEZ', 294),
(1217, 'parroquia', 'LA PUEBLITA', 294),
(1218, 'parroquia', 'EL CEDRO', 294),
(1219, 'parroquia', 'BOCONO', 295),
(1220, 'parroquia', 'EL CARMEN', 295),
(1221, 'parroquia', 'MOSQUEY', 295),
(1222, 'parroquia', 'AYACUCHO', 295),
(1223, 'parroquia', 'BURBUSAY', 295),
(1224, 'parroquia', 'GENERAL RIVAS', 295),
(1225, 'parroquia', 'MONSEÑOR JAUREGUI', 295),
(1226, 'parroquia', 'RAFAEL RANGEL', 295),
(1227, 'parroquia', 'SAN JOSE', 295),
(1228, 'parroquia', 'SAN MIGUEL', 295),
(1229, 'parroquia', 'GUARAMACAL', 295),
(1230, 'parroquia', 'LA VEGA DE GUARAMACAL', 295),
(1231, 'parroquia', 'CARACHE', 296),
(1232, 'parroquia', 'LA CONCEPCION', 296),
(1233, 'parroquia', 'CUICAS', 296),
(1234, 'parroquia', 'PANAMERICANA', 296),
(1235, 'parroquia', 'SANTA CRUZ', 296),
(1236, 'parroquia', 'ESCUQUE', 297),
(1237, 'parroquia', 'SABANA LIBRE', 297),
(1238, 'parroquia', 'LA UNION', 297),
(1239, 'parroquia', 'SANTA RITA', 297),
(1240, 'parroquia', 'CRISTOBAL MENDOZA', 298),
(1241, 'parroquia', 'CHIQUINQUIRA', 298),
(1242, 'parroquia', 'MATRIZ', 298),
(1243, 'parroquia', 'MONSEÑOR CARRILLO', 298),
(1244, 'parroquia', 'CRUZ CARRILLO', 298),
(1245, 'parroquia', 'ANDRES LINARES', 298),
(1246, 'parroquia', 'TRES ESQUINAS', 298),
(1247, 'parroquia', 'LA QUEBRADA', 299),
(1248, 'parroquia', 'JAJO', 299),
(1249, 'parroquia', 'LA MESA', 299),
(1250, 'parroquia', 'SANTIAGO', 299),
(1251, 'parroquia', 'CABIMBU', 299),
(1252, 'parroquia', 'TUÑAME', 299),
(1253, 'parroquia', 'MERCEDES DIAZ', 300),
(1254, 'parroquia', 'JUAN IGNACIO MONTILLA', 300),
(1255, 'parroquia', 'LA BEATRIZ', 300),
(1256, 'parroquia', 'MENDOZA', 300),
(1257, 'parroquia', 'LA PUERTA', 300),
(1258, 'parroquia', 'SAN LUIS', 300),
(1259, 'parroquia', 'CHEJENDE', 301),
(1260, 'parroquia', 'CARRILLO', 301),
(1261, 'parroquia', 'CEGARRA', 301),
(1262, 'parroquia', 'BOLIVIA', 301),
(1263, 'parroquia', 'MANUEL SALVADOR ULLOA', 301),
(1264, 'parroquia', 'SAN JOSE', 301),
(1265, 'parroquia', 'ARNOLDO GABALDON', 301),
(1266, 'parroquia', 'EL DIVIDIVE', 302),
(1267, 'parroquia', 'AGUA CALIENTE', 302),
(1268, 'parroquia', 'EL CENIZO', 302),
(1269, 'parroquia', 'AGUA SANTA', 302),
(1270, 'parroquia', 'VALERITA', 302),
(1271, 'parroquia', 'MONTE CARMELO', 303),
(1272, 'parroquia', 'BUENA VISTA', 303),
(1273, 'parroquia', 'STA MARIA DEL HORCON', 303),
(1274, 'parroquia', 'MOTATAN', 304),
(1275, 'parroquia', 'EL BAÑO', 304),
(1276, 'parroquia', 'JALISCO', 304),
(1277, 'parroquia', 'PAMPAN', 305),
(1278, 'parroquia', 'SANTA ANA', 305),
(1279, 'parroquia', 'LA PAZ', 305),
(1280, 'parroquia', 'FLOR DE PATRIA', 305),
(1281, 'parroquia', 'CARVAJAL', 306),
(1282, 'parroquia', 'ANTONIO N BRICEÑO', 306),
(1283, 'parroquia', 'CAMPO ALEGRE', 306),
(1284, 'parroquia', 'JOSE LEONARDO SUAREZ', 306),
(1285, 'parroquia', 'SABANA DE MENDOZA', 307),
(1286, 'parroquia', 'JUNIN', 307),
(1287, 'parroquia', 'VALMORE RODRIGUEZ', 307),
(1288, 'parroquia', 'EL PARAISO', 307),
(1289, 'parroquia', 'SANTA ISABEL', 308),
(1290, 'parroquia', 'ARAGUANEY', 308),
(1291, 'parroquia', 'EL JAGUITO', 308),
(1292, 'parroquia', 'LA ESPERANZA', 308),
(1293, 'parroquia', 'SABANA GRANDE', 309),
(1294, 'parroquia', 'CHEREGUE', 309),
(1295, 'parroquia', 'GRANADOS', 309),
(1296, 'parroquia', 'EL SOCORRO', 310),
(1297, 'parroquia', 'LOS CAPRICHOS', 310),
(1298, 'parroquia', 'ANTONIO JOSE DE SUCRE', 310),
(1299, 'parroquia', 'CAMPO ELIAS', 311),
(1300, 'parroquia', 'ARNOLDO GABALDON', 311),
(1301, 'parroquia', 'SANTA APOLONIA', 312),
(1302, 'parroquia', 'LA CEIBA', 312),
(1303, 'parroquia', 'EL PROGRESO', 312),
(1304, 'parroquia', 'TRES DE FEBRERO', 312),
(1305, 'parroquia', 'PAMPANITO', 313),
(1306, 'parroquia', 'PAMPANITO II', 313),
(1307, 'parroquia', 'LA CONCEPCION', 313),
(1308, 'parroquia', 'CM. AROA', 314),
(1309, 'parroquia', 'CM. CHIVACOA', 315),
(1310, 'parroquia', 'CAMPO ELIAS', 315),
(1311, 'parroquia', 'CM. NIRGUA', 316),
(1312, 'parroquia', 'SALOM', 316),
(1313, 'parroquia', 'TEMERLA', 316),
(1314, 'parroquia', 'CM. SAN FELIPE', 317),
(1315, 'parroquia', 'ALBARICO', 317),
(1316, 'parroquia', 'SAN JAVIER', 317),
(1317, 'parroquia', 'CM. GUAMA', 318),
(1318, 'parroquia', 'CM. URACHICHE', 319),
(1319, 'parroquia', 'CM. YARITAGUA', 320),
(1320, 'parroquia', 'SAN ANDRES', 320),
(1321, 'parroquia', 'CM. SABANA DE PARRA', 321),
(1322, 'parroquia', 'CM. BORAURE', 322),
(1323, 'parroquia', 'CM. COCOROTE', 323),
(1324, 'parroquia', 'CM. INDEPENDENCIA', 324),
(1325, 'parroquia', 'CM. SAN PABLO', 325),
(1326, 'parroquia', 'CM. YUMARE', 326),
(1327, 'parroquia', 'CM. FARRIAR', 327),
(1328, 'parroquia', 'EL GUAYABO', 327),
(1329, 'parroquia', 'GENERAL URDANETA', 328);
INSERT INTO `localidades` (`id`, `tabla`, `nombre`, `localidad_id`) VALUES
(1330, 'parroquia', 'LIBERTADOR', 328),
(1331, 'parroquia', 'MANUEL GUANIPA MATOS', 328),
(1332, 'parroquia', 'MARCELINO BRICEÑO', 328),
(1333, 'parroquia', 'SAN TIMOTEO', 328),
(1334, 'parroquia', 'PUEBLO NUEVO', 328),
(1335, 'parroquia', 'PEDRO LUCAS URRIBARRI', 329),
(1336, 'parroquia', 'SANTA RITA', 329),
(1337, 'parroquia', 'JOSE CENOVIO URRIBARR', 329),
(1338, 'parroquia', 'EL MENE', 329),
(1339, 'parroquia', 'SANTA CRUZ DEL ZULIA', 330),
(1340, 'parroquia', 'URRIBARRI', 330),
(1341, 'parroquia', 'MORALITO', 330),
(1342, 'parroquia', 'SAN CARLOS DEL ZULIA', 330),
(1343, 'parroquia', 'SANTA BARBARA', 330),
(1344, 'parroquia', 'LUIS DE VICENTE', 331),
(1345, 'parroquia', 'RICAURTE', 331),
(1346, 'parroquia', 'MONS.MARCOS SERGIO G', 331),
(1347, 'parroquia', 'SAN RAFAEL', 331),
(1348, 'parroquia', 'LAS PARCELAS', 331),
(1349, 'parroquia', 'TAMARE', 331),
(1350, 'parroquia', 'LA SIERRITA', 331),
(1351, 'parroquia', 'BOLIVAR', 332),
(1352, 'parroquia', 'COQUIVACOA', 332),
(1353, 'parroquia', 'CRISTO DE ARANZA', 332),
(1354, 'parroquia', 'CHIQUINQUIRA', 332),
(1355, 'parroquia', 'SANTA LUCIA', 332),
(1356, 'parroquia', 'OLEGARIO VILLALOBOS', 332),
(1357, 'parroquia', 'JUANA DE AVILA', 332),
(1358, 'parroquia', 'CARACCIOLO PARRA PEREZ', 332),
(1359, 'parroquia', 'IDELFONZO VASQUEZ', 332),
(1360, 'parroquia', 'CACIQUE MARA', 332),
(1361, 'parroquia', 'CECILIO ACOSTA', 332),
(1362, 'parroquia', 'RAUL LEONI', 332),
(1363, 'parroquia', 'FRANCISCO EUGENIO B', 332),
(1364, 'parroquia', 'MANUEL DAGNINO', 332),
(1365, 'parroquia', 'LUIS HURTADO HIGUERA', 332),
(1366, 'parroquia', 'VENANCIO PULGAR', 332),
(1367, 'parroquia', 'ANTONIO BORJAS ROMERO', 332),
(1368, 'parroquia', 'SAN ISIDRO', 332),
(1369, 'parroquia', 'FARIA', 333),
(1370, 'parroquia', 'SAN ANTONIO', 333),
(1371, 'parroquia', 'ANA MARIA CAMPOS', 333),
(1372, 'parroquia', 'SAN JOSE', 333),
(1373, 'parroquia', 'ALTAGRACIA', 333),
(1374, 'parroquia', 'GOAJIRA', 334),
(1375, 'parroquia', 'ELIAS SANCHEZ RUBIO', 334),
(1376, 'parroquia', 'SINAMAICA', 334),
(1377, 'parroquia', 'ALTA GUAJIRA', 334),
(1378, 'parroquia', 'SAN JOSE DE PERIJA', 335),
(1379, 'parroquia', 'BARTOLOME DE LAS CASAS', 335),
(1380, 'parroquia', 'LIBERTAD', 335),
(1381, 'parroquia', 'RIO NEGRO', 335),
(1382, 'parroquia', 'GIBRALTAR', 336),
(1383, 'parroquia', 'HERAS', 336),
(1384, 'parroquia', 'M.ARTURO CELESTINO A', 336),
(1385, 'parroquia', 'ROMULO GALLEGOS', 336),
(1386, 'parroquia', 'BOBURES', 336),
(1387, 'parroquia', 'EL BATEY', 336),
(1388, 'parroquia', 'ANDRES BELLO (KM 48)', 337),
(1389, 'parroquia', 'POTRERITOS', 337),
(1390, 'parroquia', 'EL CARMELO', 337),
(1391, 'parroquia', 'CHIQUINQUIRA', 337),
(1392, 'parroquia', 'CONCEPCION', 337),
(1393, 'parroquia', 'ELEAZAR LOPEZ C', 338),
(1394, 'parroquia', 'ALONSO DE OJEDA', 338),
(1395, 'parroquia', 'VENEZUELA', 338),
(1396, 'parroquia', 'CAMPO LARA', 338),
(1397, 'parroquia', 'LIBERTAD', 338),
(1398, 'parroquia', 'UDON PEREZ', 339),
(1399, 'parroquia', 'ENCONTRADOS', 339),
(1400, 'parroquia', 'DONALDO GARCIA', 340),
(1401, 'parroquia', 'SIXTO ZAMBRANO', 340),
(1402, 'parroquia', 'EL ROSARIO', 340),
(1403, 'parroquia', 'AMBROSIO', 341),
(1404, 'parroquia', 'GERMAN RIOS LINARES', 341),
(1405, 'parroquia', 'JORGE HERNANDEZ', 341),
(1406, 'parroquia', 'LA ROSA', 341),
(1407, 'parroquia', 'PUNTA GORDA', 341),
(1408, 'parroquia', 'CARMEN HERRERA', 341),
(1409, 'parroquia', 'SAN BENITO', 341),
(1410, 'parroquia', 'ROMULO BETANCOURT', 341),
(1411, 'parroquia', 'ARISTIDES CALVANI', 341),
(1412, 'parroquia', 'RAUL CUENCA', 342),
(1413, 'parroquia', 'LA VICTORIA', 342),
(1414, 'parroquia', 'RAFAEL URDANETA', 342),
(1415, 'parroquia', 'JOSE RAMON YEPEZ', 343),
(1416, 'parroquia', 'LA CONCEPCION', 343),
(1417, 'parroquia', 'SAN JOSE', 343),
(1418, 'parroquia', 'MARIANO PARRA LEON', 343),
(1419, 'parroquia', 'MONAGAS', 344),
(1420, 'parroquia', 'ISLA DE TOAS', 344),
(1421, 'parroquia', 'MARCIAL HERNANDEZ', 345),
(1422, 'parroquia', 'FRANCISCO OCHOA', 345),
(1423, 'parroquia', 'SAN FRANCISCO', 345),
(1424, 'parroquia', 'EL BAJO', 345),
(1425, 'parroquia', 'DOMITILA FLORES', 345),
(1426, 'parroquia', 'LOS CORTIJOS', 345),
(1427, 'parroquia', 'BARI', 346),
(1428, 'parroquia', 'JESUS M SEMPRUN', 346),
(1429, 'parroquia', 'SIMON RODRIGUEZ', 347),
(1430, 'parroquia', 'CARLOS QUEVEDO', 347),
(1431, 'parroquia', 'FRANCISCO J PULGAR', 347),
(1432, 'parroquia', 'RAFAEL MARIA BARALT', 348),
(1433, 'parroquia', 'MANUEL MANRIQUE', 348),
(1434, 'parroquia', 'RAFAEL URDANETA', 348),
(1435, 'parroquia', 'FERNANDO GIRON TOVAR', 349),
(1436, 'parroquia', 'LUIS ALBERTO GOMEZ', 349),
(1437, 'parroquia', 'PARHUEÑA', 349),
(1438, 'parroquia', 'PLATANILLAL', 349),
(1439, 'parroquia', 'CM. SAN FERNANDO DE ATABA', 350),
(1440, 'parroquia', 'UCATA', 350),
(1441, 'parroquia', 'YAPACANA', 350),
(1442, 'parroquia', 'CANAME', 350),
(1443, 'parroquia', 'CM. MAROA', 351),
(1444, 'parroquia', 'VICTORINO', 351),
(1445, 'parroquia', 'COMUNIDAD', 351),
(1446, 'parroquia', 'CM. SAN CARLOS DE RIO NEG', 352),
(1447, 'parroquia', 'SOLANO', 352),
(1448, 'parroquia', 'COCUY', 352),
(1449, 'parroquia', 'CM. ISLA DE RATON', 353),
(1450, 'parroquia', 'SAMARIAPO', 353),
(1451, 'parroquia', 'SIPAPO', 353),
(1452, 'parroquia', 'MUNDUAPO', 353),
(1453, 'parroquia', 'GUAYAPO', 353),
(1454, 'parroquia', 'CM. SAN JUAN DE MANAPIARE', 354),
(1455, 'parroquia', 'ALTO VENTUARI', 354),
(1456, 'parroquia', 'MEDIO VENTUARI', 354),
(1457, 'parroquia', 'BAJO VENTUARI', 354),
(1458, 'parroquia', 'CM. LA ESMERALDA', 355),
(1459, 'parroquia', 'HUACHAMACARE', 355),
(1460, 'parroquia', 'MARAWAKA', 355),
(1461, 'parroquia', 'MAVACA', 355),
(1462, 'parroquia', 'SIERRA PARIMA', 355),
(1463, 'parroquia', 'SAN JOSE', 356),
(1464, 'parroquia', 'VIRGEN DEL VALLE', 356),
(1465, 'parroquia', 'SAN RAFAEL', 356),
(1466, 'parroquia', 'JOSE VIDAL MARCANO', 356),
(1467, 'parroquia', 'LEONARDO RUIZ PINEDA', 356),
(1468, 'parroquia', 'MONS. ARGIMIRO GARCIA', 356),
(1469, 'parroquia', 'MCL.ANTONIO J DE SUCRE', 356),
(1470, 'parroquia', 'JUAN MILLAN', 356),
(1471, 'parroquia', 'PEDERNALES', 357),
(1472, 'parroquia', 'LUIS B PRIETO FIGUERO', 357),
(1473, 'parroquia', 'CURIAPO', 358),
(1474, 'parroquia', 'SANTOS DE ABELGAS', 358),
(1475, 'parroquia', 'MANUEL RENAUD', 358),
(1476, 'parroquia', 'PADRE BARRAL', 358),
(1477, 'parroquia', 'ANICETO LUGO', 358),
(1478, 'parroquia', 'ALMIRANTE LUIS BRION', 358),
(1479, 'parroquia', 'IMATACA', 359),
(1480, 'parroquia', 'ROMULO GALLEGOS', 359),
(1481, 'parroquia', 'JUAN BAUTISTA ARISMEN', 359),
(1482, 'parroquia', 'MANUEL PIAR', 359),
(1483, 'parroquia', '5 DE JULIO', 359),
(1484, 'parroquia', 'CARABALLEDA', 360),
(1485, 'parroquia', 'CARAYACA', 360),
(1486, 'parroquia', 'CARUAO', 360),
(1487, 'parroquia', 'CATIA LA MAR', 360),
(1488, 'parroquia', 'LA GUAIRA', 360),
(1489, 'parroquia', 'MACUTO', 360),
(1490, 'parroquia', 'MAIQUETIA', 360),
(1491, 'parroquia', 'NAIGUATA', 360),
(1492, 'parroquia', 'EL JUNKO', 360),
(1493, 'parroquia', 'PQ RAUL LEONI', 360),
(1494, 'parroquia', 'PQ CARLOS SOUBLETTE', 360);

-- --------------------------------------------------------

--
-- Table structure for table `mensajes`
--

CREATE TABLE IF NOT EXISTS `mensajes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `para` int(11) NOT NULL COMMENT 'Id cliente que recibe el mensaje',
  `de` int(11) NOT NULL COMMENT 'id del cliente que envia el mensaje',
  `asunto` varchar(250) NOT NULL,
  `mensaje` text NOT NULL,
  `estatus` int(11) NOT NULL COMMENT '0- No Leido 1- Leido',
  `fecCreacion` datetime NOT NULL,
  `idUsuario` int(11) NOT NULL COMMENT 'id Usuario que envia el mensaje',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `mensajes`
--

INSERT INTO `mensajes` (`id`, `para`, `de`, `asunto`, `mensaje`, `estatus`, `fecCreacion`, `idUsuario`) VALUES
(1, 1, 1, 'Probando 1', 'Esto es una prueba', 0, '2015-07-28 08:09:33', 1),
(2, 1, 1, 'Probando otro', 'Esto es otra prueba', 1, '2015-07-28 00:00:00', 1);

-- --------------------------------------------------------

--
-- Table structure for table `operaciones`
--

CREATE TABLE IF NOT EXISTS `operaciones` (
  `id` int(11) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `email` varchar(255) NOT NULL,
  `numControl` varchar(50) NOT NULL,
  `monto` decimal(9,2) NOT NULL,
  `codOperacion` varchar(11) NOT NULL,
  `numTarjeta` varchar(20) DEFAULT NULL,
  `nacionalidad` varchar(1) DEFAULT NULL,
  `docIdentidad` varchar(10) DEFAULT NULL,
  `fecVencimiento` varchar(4) DEFAULT NULL,
  `codSeguridad` varchar(3) DEFAULT NULL,
  `respuesta` varchar(255) DEFAULT NULL,
  `numAutorizacion` varchar(45) DEFAULT NULL,
  `fecOperacion` datetime NOT NULL,
  `idVirtualPoint` int(11) NOT NULL,
  `duracionOperaciones` decimal(11,0) NOT NULL,
  `estatus` enum('En espera','En proceso','Incompleta','No Autorizada','Autorizada') NOT NULL COMMENT '0.- NULL\n1.- En espera\n2.- En Proceso\n3.- Incompleta\n4.- No Autorizada\n5.- Autorizada',
  `idCliente` int(11) NOT NULL,
  `idUsuario` int(11) NOT NULL,
  `fecCreacion` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Contiene las operaciones activas y en espera de ser pasadas a la tabla "operaciones_h". Esto con el fin de mantener el minimo de operaciones activas para minimizar tiempos en las busquedas.';

--
-- Triggers `operaciones`
--
DROP TRIGGER IF EXISTS `updateToOperacionesH`;
DELIMITER //
CREATE TRIGGER `updateToOperacionesH` AFTER UPDATE ON `operaciones`
 FOR EACH ROW UPDATE operaciones_h SET
numTarjeta = CONCAT('XXXX-XXXX-XXXX-', substring(NEW.numTarjeta, LENGTH(NEW.numTarjeta) - 3, LENGTH(NEW.numTarjeta))),
nacionalidad = NEW.nacionalidad,
docIdentidad = NEW.docIdentidad,
fecVencimiento = 'XXXX',
codSeguridad = 'XXX',
respuesta = NEW.respuesta,
numAutorizacion = NEW.numAutorizacion,
fecOperacion = NEW.fecOperacion,
estatus = NEW.estatus
WHERE id = OLD.id
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `operaciones_h`
--

CREATE TABLE IF NOT EXISTS `operaciones_h` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(150) NOT NULL,
  `email` varchar(255) NOT NULL,
  `numControl` varchar(50) NOT NULL,
  `monto` decimal(9,2) NOT NULL,
  `codOperacion` varchar(11) NOT NULL,
  `numTarjeta` varchar(20) DEFAULT NULL,
  `nacionalidad` varchar(1) DEFAULT NULL,
  `docIdentidad` varchar(10) DEFAULT NULL,
  `fecVencimiento` varchar(4) DEFAULT NULL,
  `codSeguridad` varchar(3) DEFAULT NULL,
  `respuesta` varchar(255) DEFAULT NULL,
  `numAutorizacion` varchar(45) DEFAULT NULL,
  `fecOperacion` datetime NOT NULL,
  `idVirtualPoint` int(11) NOT NULL,
  `duracionOperaciones` decimal(11,0) NOT NULL,
  `estatus` enum('En espera','En proceso','Incompleta','No Autorizada','Autorizada') NOT NULL COMMENT '0.- NULL\n1.- En espera\n2.- En Proceso\n3.- Incompleta\n4.- No Autorizada\n5.- Autorizada',
  `idCliente` int(11) NOT NULL,
  `idUsuario` int(11) NOT NULL,
  `fecCreacion` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Contiene el historial de  operaciones.' AUTO_INCREMENT=1 ;

--
-- Triggers `operaciones_h`
--
DROP TRIGGER IF EXISTS `copyToOperaciones`;
DELIMITER //
CREATE TRIGGER `copyToOperaciones` AFTER INSERT ON `operaciones_h`
 FOR EACH ROW INSERT INTO operaciones VALUES 
(
NEW.id,
NEW.nombre,
NEW.email,
NEW.numControl,
NEW.monto,
NEW.codOperacion,
CONCAT('XXXX-XXXX-XXXX-', substring(NEW.numTarjeta, LENGTH(NEW.numTarjeta) - 3, LENGTH(NEW.numTarjeta))),
NEW.nacionalidad,
NEW.docIdentidad,
'',
'',
NEW.respuesta,
NEW.numAutorizacion,
NEW.fecOperacion,
NEW.idVirtualPoint,
NEW.duracionOperaciones,
NEW.estatus,
NEW.idCliente,
NEW.idUsuario,
NEW.fecCreacion
)
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tipo_cobranza`
--

CREATE TABLE IF NOT EXISTS `tipo_cobranza` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(150) NOT NULL,
  `abr` varchar(100) NOT NULL,
  `estatus` int(1) NOT NULL DEFAULT '1',
  `idUsuario` int(11) NOT NULL,
  `fecCreacion` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `tipo_cobranza`
--

INSERT INTO `tipo_cobranza` (`id`, `nombre`, `abr`, `estatus`, `idUsuario`, `fecCreacion`) VALUES
(1, 'Tasa Fija por transaccion', 'TFPT', 1, 1, '0000-00-00 00:00:00'),
(2, 'Porcentual', 'PORC', 1, 1, '0000-00-00 00:00:00'),
(3, 'Licenciamiento Anual', 'LA', 1, 1, '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `tipo_usuario`
--

CREATE TABLE IF NOT EXISTS `tipo_usuario` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(250) DEFAULT NULL,
  `estatus` int(1) DEFAULT NULL,
  `mostrar` int(1) DEFAULT '1',
  `idUsuario` int(11) NOT NULL,
  `fecCreacion` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Contiene los tipos de usuarios' AUTO_INCREMENT=6 ;

--
-- Dumping data for table `tipo_usuario`
--

INSERT INTO `tipo_usuario` (`id`, `nombre`, `descripcion`, `estatus`, `mostrar`, `idUsuario`, `fecCreacion`) VALUES
(1, 'Administrador', 'Usuarios internos Oriantech C.A.', 1, 0, 1, '0000-00-00 00:00:00'),
(2, 'Master', 'Usuarios con privilegios de ver todas las transacciones, reportes, etc.', 1, 1, 1, '0000-00-00 00:00:00'),
(3, 'Operador', 'Usuarios con privilegios para cargar y visualizar solo sus propias transacciones.', 1, 1, 1, '0000-00-00 00:00:00'),
(4, 'Espectador', 'Usuario con privilegios de visualizar informacion en el sistema, No podra modificar data en el sistema.', 1, 1, 1, '0000-00-00 00:00:00'),
(5, 'Vendedor', 'Usuario con privilegios de visualizar informacion en el sistema, No podra modificar data en el sistema, Solo podra ver informacion de sus clientes.', 1, 1, 1, '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `usuarios`
--

CREATE TABLE IF NOT EXISTS `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Codigo Unico de la tabla',
  `nombre` varchar(100) NOT NULL COMMENT 'Nombre del usuario',
  `usuario` varchar(45) NOT NULL COMMENT 'Nombre de Usuario para realizar login en la aplicacion',
  `clave` varchar(200) NOT NULL COMMENT 'Clave de seguridad para Login en la aplicacion',
  `extension` varchar(11) DEFAULT NULL,
  `estatus` int(1) NOT NULL COMMENT '2.- Bloqueado, 1.- Activo, 0.- Inactivo',
  `cambioClave` tinyint(1) DEFAULT NULL COMMENT '1.-  No necesita cambio de clave, 0.- Necesita realizar un cambio de clave',
  `idTipoUsuario` int(11) NOT NULL COMMENT 'Se refiere a los tipos de privilegios que tiene un usuario en la aplicacion\n0.- Admin, 1.- Supervisor, 2.- Usuario,',
  `idCliente` int(11) NOT NULL COMMENT 'Codigo Unicio del cliente al que pertenece el usuario',
  `idUsuario` int(11) NOT NULL COMMENT 'Codigo Unico del Usuario que realizo la creacion del Usuario',
  `fecCreacion` datetime NOT NULL COMMENT 'Fecha y Hora en que se realizo la creacion del Usuario',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Contiene los usuarios que haran uso de la aplicacion. Externos e Internos de la empresa.' AUTO_INCREMENT=40 ;

--
-- Dumping data for table `usuarios`
--

INSERT INTO `usuarios` (`id`, `nombre`, `usuario`, `clave`, `extension`, `estatus`, `cambioClave`, `idTipoUsuario`, `idCliente`, `idUsuario`, `fecCreacion`) VALUES
(1, 'Jorge Peraza', 'jperaza', '*A4B6157319038724E3560894F7F932C8886EBFCF', '104', 1, 1, 2, 3, 7, '2015-12-11 13:13:25'),
(2, 'Raul Puig', 'rpuig', '*A1E9B2EDA475682D4CC2386ABF63333E94718191', NULL, 1, 1, 2, 3, 1, '2015-11-07 18:59:24'),
(3, 'Yamilev Riera', 'yriera', '*E308276C30135FF4F116E2858E3250E854680420', NULL, 1, 1, 2, 3, 1, '2015-11-07 18:59:16'),
(4, 'Usuario1', 'hib1', '*A4B6157319038724E3560894F7F932C8886EBFCF', '1601', 1, 1, 2, 2, 1, '2015-11-07 19:11:54'),
(5, 'Usuario2', 'hib2', '*A4B6157319038724E3560894F7F932C8886EBFCF', NULL, 1, 1, 3, 2, 1, '2015-11-07 19:12:26'),
(6, 'Usuario3', 'hib3', '*A4B6157319038724E3560894F7F932C8886EBFCF', '', 1, 1, 4, 2, 1, '2016-04-23 23:47:27'),
(7, 'Administrador', 'admin', '*2736D94B53DB1709B89CA1EED36BC2A8A35A3FCE', '', 1, 1, 1, 3, 1, '2016-04-23 23:46:30'),
(8, 'Juan Nunes', 'Jcnunes', '*9AFEEF2451970307D17A849F579B61DFD0848D91', '', 1, 1, 2, 3, 1, '2016-04-23 23:46:21'),
(39, 'j', 'j', '*9A04E9549880BB91C935B6A3E90DA60E3E5C783F', 'j', 1, 1, 2, 2, 1, '2016-04-23 23:45:44');

-- --------------------------------------------------------

--
-- Table structure for table `virtual_points`
--

CREATE TABLE IF NOT EXISTS `virtual_points` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Codigo Unico del Virtual Point',
  `idCliente` int(11) NOT NULL COMMENT 'Codigo Unico del Cliente que posee el Virtual Point',
  `descripcion` varchar(250) DEFAULT NULL,
  `codAfiliacion` varchar(50) NOT NULL,
  `transcode` varchar(10) NOT NULL,
  `url` varchar(200) NOT NULL COMMENT 'Url asociada al Virtual Point',
  `idBanco` int(11) NOT NULL COMMENT 'Codigo Unico del Banco Asociado al Virtual Point',
  `estatus` int(11) NOT NULL COMMENT 'Estatus del cliente en el sistema\n1.- Activo, 0.- Inactivo.',
  `idUsuario` int(11) NOT NULL COMMENT 'Codigo de Usuario que realizo la creacion del Virtual Point',
  `fecCreacion` datetime NOT NULL COMMENT 'Fecha y Hora en la que se realizo la creacion del Virtual Point',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Contiene los puntos virtuales disponibles para cada Cliente' AUTO_INCREMENT=4 ;

--
-- Dumping data for table `virtual_points`
--

INSERT INTO `virtual_points` (`id`, `idCliente`, `descripcion`, `codAfiliacion`, `transcode`, `url`, `idBanco`, `estatus`, `idUsuario`, `fecCreacion`) VALUES
(1, 1, 'VP Banesco ', '67201442', '0141', 'https://e-payment.megasoft.com.ve/payment/action/procesar-compra?cod_afiliacion=67201442&transcode=0141', 1, 1, 1, '2015-04-19 15:27:23'),
(2, 2, 'VP Exterior', '20152411', '0141', 'https://e-payment.megasoft.com.ve/payment/action/procesar-compra?cod_afiliacion=20152411&transcode=0141', 2, 1, 7, '2015-12-01 19:08:08'),
(3, 3, 'VP Banesco ', '67201442', '0141', 'https://e-payment.megasoft.com.ve/payment/action/procesar-compra?cod_afiliacion=67201442&transcode=0141', 1, 1, 1, '2015-04-19 15:27:23');

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`localhost` EVENT `e_operaciones_expiradas` ON SCHEDULE EVERY 5 MINUTE STARTS '2015-07-30 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO call st_operaciones_expiradas()$$

DELIMITER ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
