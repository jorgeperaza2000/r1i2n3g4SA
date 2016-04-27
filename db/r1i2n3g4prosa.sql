-- phpMyAdmin SQL Dump
-- version 4.1.14
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Apr 27, 2016 at 01:56 PM
-- Server version: 5.6.17
-- PHP Version: 5.5.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `r1i2n3g4prosa`
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

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`localhost` EVENT `e_operaciones_expiradas` ON SCHEDULE EVERY 5 MINUTE STARTS '2015-07-30 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO call st_operaciones_expiradas()$$

DELIMITER ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
