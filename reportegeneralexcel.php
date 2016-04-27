<?php
session_start();
header("Content-Type: application/vnd.ms-excel");
header("Expires: 0");
header("content-disposition: attachment;filename=ReporteGeneral.xls");
?>
<table>
    <tr>
        <td style="background-color:#ccc;">Id</td>
        <td style="background-color:#ccc;">Codigo</td>
        <td style="background-color:#ccc;">Factura</td>
        <td style="background-color:#ccc;">Fecha</td>
        <td style="background-color:#ccc;">Cliente</td>
        <td style="background-color:#ccc;">Cedula Identidad</td>
        <td style="background-color:#ccc;">Num. Tarjeta</td>
        <td style="background-color:#ccc;">Fecha Oper.</td>
        <td style="background-color:#ccc;">Estatus</td>
        <td style="background-color:#ccc;">Autorizacion</td>
        <td style="background-color:#ccc;">Monto</td>
    </tr>
    <?php
    $datas = $_SESSION["query"];
	if ( count( $datas ) == 0 ) {
	?>
		<tr>
        	<td align="center" colspan="10">No se encontraron coincidencias</td>
        </tr>
	<?php	
	} else {
		foreach ($datas as $data) {
			$tarjeta = ($data["numTarjeta"]!="")?"XXXX-XXXX-XXXX-".substr($data["numTarjeta"], -4,4):"";
    ?>
            <tr>
            	<td><?=$data["id"]?></td>
            	<td><?=$data["codOperacion"]?></td>
                <td><?=$data["numControl"]?></td>
                <td><?=date("d-m-Y h:i:s", strtotime($data["fecCreacion"]))?></td>
                <td><?=$data["nombre"]?></td>
                <td><?=$data["docIdentidad"]?></td>
                <td><?=$tarjeta?></td>
                <td><?=date("d-m-Y h:i:s", strtotime($data["fecOperacion"]))?></td>
                <td><?=$data["estatus"]?></td>
                <td><?=$data["numAutorizacion"]?></td>
                <td><?=$data["monto"]?></td>
            </tr>
    <?php
		}
	}
	?>
</table>