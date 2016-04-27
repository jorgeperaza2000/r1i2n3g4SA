<?php

$session = isset($_GET["s"])?$_GET["s"]:"";

switch ( $session ) {
	case cPrincipal:
		$_SESSION["seccion"] = 0;
	break;	
	case cCambioClave:
		$_SESSION["seccion"] = 0;
	break;
	case cNuevaVenta:
		$_SESSION["seccion"] = 1;
	break;
	case cClientes:
		$_SESSION["seccion"] = 2;
	break;
	case cAddClientes:
		$_SESSION["seccion"] = 2;
	break;
	case cEditClientes:
		$_SESSION["seccion"] = 2;
	break;
	case cUsuarios:
		$_SESSION["seccion"] = 3;
	break;
	case cAddUsuarios:
		$_SESSION["seccion"] = 3;
	break;
	case cEditUsuarios:
		$_SESSION["seccion"] = 3;
	break;
	case cBancos:
		$_SESSION["seccion"] = 4;
	break;
	case cAddBancos:
		$_SESSION["seccion"] = 4;
	break;
	case cEditBancos:
		$_SESSION["seccion"] = 4;
	break;
	case cVirtualPoints:
		$_SESSION["seccion"] = 5;
	break;
	case cAddVirtualPoints:
		$_SESSION["seccion"] = 5;
	break;
	case cEditVirtualPoints:
		$_SESSION["seccion"] = 5;
	break;
	
	case cOperaciones:
		$_SESSION["seccion"] = 6;
	break;
	case cReporteGeneral:
		$_SESSION["seccion"] = 7;
	break;
	case cEstadoCuenta:
		$_SESSION["seccion"] = 10;
	break;
	case cVerFactura:
		$_SESSION["seccion"] = 10;
	break;
	case cReportarPago:
		$_SESSION["seccion"] = 10;
	break;
	
	default:
		$_SESSION["seccion"] = 0;
	break;
}
?>