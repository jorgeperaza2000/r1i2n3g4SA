<?php
session_start();
include "db.php";

switch ( $_GET["op"] ) {
		
	case "login":
		
		$data = $db->query("SELECT 
								u.*,
								c.nombre cliente,
								c.duracionOperaciones
							FROM 
								usuarios u, clientes c 
							WHERE 
								u.idCliente = c.id AND 
							    u.usuario = '" . $_POST["txtUserName"] . "' AND 
							    u.clave = '" . $_POST["txtPassword"] . "' 
							LIMIT 1")->fetchAll();
		if ( $data ) {
				
			if ( $data[0]["estatus"] == 0 ) { //El Usuario se encuentra inactivo
				header("location: ../index.php?e=2");
				die(); 
			}
			$_SESSION["usuario"]["id"] = $data[0]["id"];
			$_SESSION["usuario"]["nombre"] = $data[0]["nombre"];
			$_SESSION["usuario"]["usuario"] = $data[0]["usuario"];
			$_SESSION["usuario"]["idTipoUsuario"] = $data[0]["idTipoUsuario"];
			$_SESSION["usuario"]["idCliente"] = $data[0]["idCliente"];
			$_SESSION["usuario"]["cliente"] = $data[0]["cliente"];
			$_SESSION["usuario"]["duracionOperaciones"] = $data[0]["duracionOperaciones"];
			if ( $data[0]["cambioClave"] == 1) {
				header("location: ../home.php?s=" . cPrincipal);
			} else {
				header("location: ../home.php?s=" . cCambioClave);
			}

		} else {
				
			header("location: ../index.php?e=1");
			
		}
		/*foreach ( $datas as $data ) {
			echo $data["nombre"] . " - " . $data["id"] . "<br/>";
		}*/
	break;
	
	case "nuevaVenta":
	$max = $db->max("operaciones_h", "id");

	$last_operacion_id = $db->insert("operaciones", [
										"id" => $max + 1,
										"codOperacion" => $_POST["txtCodigoOperacion"],
										"nombre" => strtoupper($_POST["txtNombre"]),
										"email" => $_POST["txtEmailCliente"],
										"numControl" => strtoupper($_POST["txtNumeroFactura"]),
										"monto" => number_format($_POST["txtMontoFactura"], 2, ".", ""),
										"idVirtualPoint" => $_POST["rdoVirtualPoint"],
										"duracionOperaciones" => $_SESSION["usuario"]["duracionOperaciones"],
										"idUsuario" => $_SESSION["usuario"]["id"],
										"idCliente" => $_SESSION["usuario"]["idCliente"],
										"#fecCreacion" => "NOW()",
										"estatus" => "1",
										]);
	
		header("location: ../home.php?s" . cPrincipal);
	break;
	case "nuevoCliente":
		$txtFecActivacion = ( $_POST["txtFecActivacion"] == "" )?null:date("Y-m-d", strtotime($_POST["txtFecActivacion"]));
		
		$last_operacion_id = $db->insert("clientes", [
										"nombre" => $_POST["txtNombre"],
										"rif" => $_POST["txtRif"],
										"idEstado" => $_POST["cmbEstado"],
										"idMunicipio" => $_POST["cmbMunicipio"],
										"direccion" => $_POST["txtDireccion"],
										"telefono" => $_POST["txtTelefono"],
										"personaContacto" => $_POST["txtPersonaContacto"],
										"idTipoCobranza" => $_POST["cmbTipoCobranza"],
										"tasa" => $_POST["txtTasa"],
										"intervalo" => $_POST["txtIntervalo"],
										"montoAfiliacion" => $_POST["txtMontoAfiliacion"],
										"duracionOperaciones" => $_POST["txtDuracionOperaciones"],
										"numeroUsuarios" => $_POST["txtNumeroUsuarios"],
										"idUsuario" => $_SESSION["usuario"]["id"],
										"#fecCreacion" => "NOW()",
										"fecActivacion" => $txtFecActivacion,
										"estatus" => "1",
										]);
		header("location: ../home.php?s=" . cClientes);
	break;
	case "editCliente":
		$txtFecActivacion = ( $_POST["txtFecActivacion"] == "" )?null:date("Y-m-d", strtotime($_POST["txtFecActivacion"]));

		$last_operacion_id = $db->update("clientes", [
										"nombre" => $_POST["txtNombre"],
										"rif" => $_POST["txtRif"],
										"idEstado" => $_POST["cmbEstado"],
										"idMunicipio" => $_POST["cmbMunicipio"],
										"direccion" => $_POST["txtDireccion"],
										"telefono" => $_POST["txtTelefono"],
										"personaContacto" => $_POST["txtPersonaContacto"],
										"duracionOperaciones" => $_POST["txtDuracionOperaciones"],
										"numeroUsuarios" => $_POST["txtNumeroUsuarios"],
										"idTipoCobranza" => $_POST["cmbTipoCobranza"],
										"tasa" => $_POST["txtTasa"],
										"montoAfiliacion" => $_POST["txtMontoAfiliacion"],
										"intervalo" => $_POST["txtIntervalo"],
										"idUsuario" => $_SESSION["usuario"]["id"],
										"#fecCreacion" => "NOW()",
										"fecActivacion" => $txtFecActivacion,
										"estatus" => "1",
										],
										["id" => $_GET["id"] ]);
		header("location: ../home.php?s=" . cClientes);
	break;
	case "delCliente":
		$last_operacion_id = $db->delete("clientes", [ "id" =>  $_GET["id"] ]);
		header("location: ../home.php?s=" . cClientes);
	break;
	case "nuevoUsuario":
		$last_operacion_id = $db->insert("usuarios", [
										"nombre" => $_POST["txtNombre"],
										"usuario" => $_POST["txtUsuario"],
										"clave" => $_POST["txtClave"],
										"extension" => $_POST["txtExtension"],
										"idTipoUsuario" => $_POST["cmbTipoUsuario"],
										"idCliente" => $_POST["cmbCliente"],
										"idUsuario" => $_SESSION["usuario"]["id"],
										"#fecCreacion" => "NOW()",
										"estatus" => "1",
										"cambioClave" => "1",
										]);
		header("location: ../home.php?s=" . cUsuarios);
	break;
	case "editUsuario":
		$last_operacion_id = $db->update("usuarios", [
										"nombre" => $_POST["txtNombre"],
										"usuario" => $_POST["txtUsuario"],
										"clave" => $_POST["txtClave"],
										"extension" => $_POST["txtExtension"],
										"idTipoUsuario" => $_POST["cmbTipoUsuario"],
										"idCliente" => $_POST["cmbCliente"],
										"idUsuario" => $_SESSION["usuario"]["id"],
										"#fecCreacion" => "NOW()",
										"estatus" => "1",
										"cambioClave" => "1",
										],
										["id" => $_GET["id"] ]);
		header("location: ../home.php?s=" . cUsuarios);
	break;
	case "delUsuario":
		$last_operacion_id = $db->delete("usuarios", [ "id" =>  $_GET["id"] ]);
		header("location: ../home.php?s=" . cUsuarios);
	break;
	case "nuevoBanco":
		$last_operacion_id = $db->insert("bancos", [
										"nombre" => $_POST["txtNombre"],
										"idUsuario" => $_SESSION["usuario"]["id"],
										"#fecCreacion" => "NOW()",
										"estatus" => "1",
										]);
		header("location: ../home.php?s=" . cBancos);
	break;
	case "editBanco":
		$last_operacion_id = $db->update("bancos", [
										"nombre" => $_POST["txtNombre"],
										"idUsuario" => $_SESSION["usuario"]["id"],
										"#fecCreacion" => "NOW()",
										"estatus" => "1",
										],
										["id" => $_GET["id"] ]);
		header("location: ../home.php?s=" . cBancos);
	break;
	case "delBanco":
		$last_operacion_id = $db->delete("bancos", [ "id" =>  $_GET["id"] ]);
		header("location: ../home.php?s=" . cBancos);
	break;
	case "nuevoVirtualPoint":
		$URL = "https://e-payment.megasoft.com.ve/payment/action/procesar-compra?cod_afiliacion=" . $_POST["txtCodAfiliacion"] . "&transcode=" . $_POST["txtTranscode"];
		$last_operacion_id = $db->insert("virtual_points", [
										"descripcion" => $_POST["txtDescripcion"],
										"idCliente" => $_POST["cmbCliente"],
										"codAfiliacion" => $_POST["txtCodAfiliacion"],
										"transcode" => $_POST["txtTranscode"],
										"url" => $URL,
										"idBanco" => $_POST["cmbBanco"],
										"idUsuario" => $_SESSION["usuario"]["id"],
										"#fecCreacion" => "NOW()",
										"estatus" => "1"
										]);
		header("location: ../home.php?s=" . cVirtualPoints);
	break;
	case "editVirtualPoint":
		$URL = "https://e-payment.megasoft.com.ve/payment/action/procesar-compra?cod_afiliacion=" . $_POST["txtCodAfiliacion"] . "&transcode=" . $_POST["txtTranscode"];
		$last_operacion_id = $db->update("virtual_points", [
										"descripcion" => $_POST["txtDescripcion"],
										"idCliente" => $_POST["cmbCliente"],
										"codAfiliacion" => $_POST["txtCodAfiliacion"],
										"transcode" => $_POST["txtTranscode"],
										"url" => $URL,
										"idBanco" => $_POST["cmbBanco"],
										"idUsuario" => $_SESSION["usuario"]["id"],
										"#fecCreacion" => "NOW()",
										"estatus" => "1"
										],
										["id" => $_GET["id"] ]);
		header("location: ../home.php?s=" . cVirtualPoints);
	break;
	case "delete":
		$a = split("_", $_GET["tabla"]);
		$b = ucfirst($a[0]) . ucfirst($a[1]);
		$redirigir = c . $b;
		$last_operacion_id = $db->delete($_GET["tabla"], [ "id" =>  $_GET["id"] ]);
		header("location: ../home.php?s=" . constant($redirigir));
	break;
	
	
	
	case "estatus":
		$estatus = ( $_GET["e"] == 1 )?0:1;
		$a = split("_", $_GET["tabla"]);
		$b = ucfirst($a[0]) . ucfirst($a[1]);
		$redirigir = c . $b;
		$last_operacion_id = $db->update($_GET["tabla"], ["estatus" => $estatus], [ "id" =>  $_GET["id"] ]);
		header("location: ../home.php?s=" . constant($redirigir));
	break;
	
	case "cargaComboCiudad":
		$salida = "";
		$idEstado = $_POST["idEstado"];
		$datas = $db->select("localidades",["id", "nombre"], ["AND" => ["tabla" => "municipio", "localidad_id" => $idEstado], "ORDER" => "nombre ASC"]);
		foreach ( $datas as $data ) {
        	$salida .= '<option value=' . $data["id"] . '">' . $data["nombre"] . '</option>';
		}
		echo $salida;
	break;
	
	case "enviaOperacionesH":
		$datos = $db->query("call st_operaciones_historial(" . base64_decode($_GET["id"]) . ")");
		header("location: ../home.php?s=" . cPrincipal);
	break;
	
	case "duplicaOperacion":
		$datos = $db->query("call st_operaciones_duplica(" . base64_decode($_GET["id"]) . ")");
		header("location: ../home.php?s=" . cPrincipal);
	break;
}
