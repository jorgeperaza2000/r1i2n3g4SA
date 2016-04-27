<?php
$xmlFile = "http://172.30.100.41/ring_request/xml/" . base64_decode( $_GET["id"] ) . ".xml";
$xm = simplexml_load_file($xmlFile);
$descripcion = $xm->descripcion;
$authid = $xm->authid;
$voucher = "";
foreach($xm->voucher->linea as $linea ) {
	if ( strlen($linea->UT) > 1 ) {
		$linea = $linea->UT;
	}
	if (strlen($linea) > 2 ) {
		if ( stristr($linea, 'FIRMA__:') ) {
			$voucher .= "FIRMA : ___________________" . "<br>";
		} elseif ( stristr($linea, 'C.I.___:') ) {
			$voucher .= "C.I. : ___________________" . "<br>";
		} else { 
			$voucher .= str_replace("_", "&nbsp;", $linea) . "<br>";
		}
	} else {
		$voucher .= "<br>";	
	}
}

//print_r($resultadoXML);
$cadenaEmail = $voucher;
echo $cadenaEmail;
?>
<script type="text/javascript">
	window.print();
</script>
