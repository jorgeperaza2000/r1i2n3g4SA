<?php
session_start();
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Ring - Payment Gateway</title>
        <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
        <!-- bootstrap 3.0.2 -->
        <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
        <!-- font Awesome -->
        <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
        <!-- Ionicons -->
        <link href="css/ionicons.min.css" rel="stylesheet" type="text/css" />
        <!-- Morris chart -->
        <link href="css/morris/morris.css" rel="stylesheet" type="text/css" />
        <!-- jvectormap -->
        <link href="css/jvectormap/jquery-jvectormap-1.2.2.css" rel="stylesheet" type="text/css" />
        <!-- fullCalendar -->
        <link href="css/fullcalendar/fullcalendar.css" rel="stylesheet" type="text/css" />
        <!-- Daterange picker -->
        <link href="css/daterangepicker/daterangepicker-bs3.css" rel="stylesheet" type="text/css" />
        <!-- bootstrap wysihtml5 - text editor -->
        <link href="css/bootstrap-wysihtml5/bootstrap3-wysihtml5.min.css" rel="stylesheet" type="text/css" />
        <!-- Theme style -->
        <link href="css/AdminLTE.css" rel="stylesheet" type="text/css" />
	</head>
<body>

<div style="width:500px;margin:auto;text-align:center;"><h1>Reporte de Operaciones</h1></div>
<div style="width:500px;margin:auto;text-align:center;"><h4>Fecha Desde: <?=$_SESSION["temp"]["POST"]["txtFecDesde"]?></h4></div>
<div style="width:500px;margin:auto;text-align:center;"><h4>Fecha Hasta: <?=$_SESSION["temp"]["POST"]["txtFecHasta"]?></h4></div>
<br>
<table id="example2" class="table table-bordered table-hover">
    <thead>
        <tr>
            <th>Id</th>
            <th>Codigo</th>
            <th>Factura</th>
            <th>Fecha</th>
            <th>Cliente</th>
            <th>Num. Tarjeta</th>
            <th>Fecha Oper.</th>
            <th>Estatus</th>
            <th>Autorización</th>
            <th>Monto</th>
        </tr>
    </thead>
    <tbody>
        <?php
        $datas = $_SESSION["query"];
		if ( count( $datas ) == 0 ) {
		?>
			<tr>
            	<td align="center" colspan="9">No se encontraron coincidencias</td>
            </tr>
		<?php	
		} else {
			foreach ($datas as $data) {
				$tarjeta = ($data["numTarjeta"]!="")?"XXXX-XXXX-XXXX-".substr($data["numTarjeta"], -4,4):"";
        ?>
                <tr>
                	<td><?=$data["id"]?></td>
                	<td><b><?=$data["codOperacion"]?></b></td>
                    <td><?=$data["numControl"]?></td>
                    <td><?=date("d-m-Y h:i:s", strtotime($data["fecCreacion"]))?></td>
                    <td><?=$data["nombre"]?><p><?=$data["docIdentidad"]?></p></td>
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
    </tbody>
</table>
</body>
</html>
<script type="text/javascript">
    window.print();
</script>