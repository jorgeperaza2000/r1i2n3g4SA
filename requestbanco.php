<?php
session_start();
include "includes/db.php";
//$arg = 2;
$arg = $argv[1];
$data = $db->get("operaciones","*", array("id" => $arg));

$numTarjet = "&pan=" . $data["numTarjeta"];
$codSeguridad = "&cvv2=" . $data["codSeguridad"];
$nacion = nacionalidadCorta( $data["nacionalidad"] );
$cedulaIdentidad = "&cid=" . $nacion.$data["docIdentidad"];
$fecVencim = "&expdate=" . $data["fecVencimiento"];	
if ( strlen ( $data["fecVencimiento"] ) == 3 ) {
	$fecVencim = "&expdate=0" . $data["fecVencimiento"];
}
$monto = "&amount=" . $data["monto"];
$cliente = "&client=" . str_replace(' ', '%20', $data["nombre"]);
$factura = "&factura=" . $data["numControl"];

$strUrl = "https://e-payment.megasoft.com.ve/payment/action/procesar-compra?cod_afiliacion=67201442&transcode=0141".$numTarjet.$codSeguridad.$cedulaIdentidad.$fecVencim.$monto.$cliente.$factura;
$string = file_get_contents($strUrl);

$xml = $data["id"].'.xml';

if ( file_exists($xml) ){
	unlink($xml);	
}

$fp = fopen("/var/www/html/ring/xml/" . $xml, "a");
$write = fputs($fp, $string);
fclose($fp);

$resultadoXML = new SimpleXMLElement($string);

$estatus = ( $resultadoXML->authid == "" ) ? 4 : 5;

$descripcion = $resultadoXML->descripcion;

$authid = $resultadoXML->authid;

$data = $db->update("operaciones", array(
						"respuesta" => "$descripcion", 
						"numAutorizacion" => "$authid", 
						"#fecOperacion" => "NOW()", 
						"estatus" => $estatus
						), 
						array("id" => $arg)
					);


function nacionalidadCorta( $nacion ) {
	if ( $nacion == 1 ) {
		return "V";	
	} elseif ( $nacion == 2) {
		return "E";
	}
}
?>
