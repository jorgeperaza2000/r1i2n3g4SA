<?php

$session = isset($_GET["s"])?$_GET["s"]:"";

switch ( $session ) {
	
	case cPrincipal:
		include 'principal.php';
	break;	
	case cCambioClave:
		include 'cambioclave.php';
	break;
	case cNuevaVenta:
		include 'nueva_venta.php';
	break;
	case cOperaciones:
		include 'historico_operaciones.php';
	break;
	case cClientes:
		include 'clientes.php';
	break;
	case cAddClientes:
		include 'addcliente.php';
	break;
	case cEditClientes:
		include 'editcliente.php';
	break;
	case cUsuarios:
		include 'usuarios.php';
	break;
	case cAddUsuarios:
		include 'addusuario.php';
	break;
	case cEditUsuarios:
		include 'editusuario.php';
	break;
	case cBancos:
		include 'bancos.php';
	break;
	case cAddBancos:
		include 'addbanco.php';
	break;
	case cEditBancos:
		include 'editbanco.php';
	break;
	case cVirtualPoints:
		include 'virtualpoints.php';
	break;
	case cAddVirtualPoints:
		include 'addvirtualpoint.php';
	break;
	case cEditVirtualPoints:
		include 'editvirtualpoint.php';
	break;
	case cMailBox:
		include 'mailbox.php';
	break; 
	
	case cReporteGeneral:
		include 'reportegeneral.php';
	break;

	case cEstadoCuenta:
		include 'estado_cuenta.php';
	break;
	case cVerFactura:
		include "ver_factura.php";
	break;
	case cReportarPago:
		include "reportar_pago.php";
	break;
	
	default:
		include 'principal.php';
	break;

}