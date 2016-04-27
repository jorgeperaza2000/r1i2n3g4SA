			<!-- Right side column. Contains the navbar and content of the page -->
            <aside class="right-side">
                <!-- Content Header (Page header) -->
                <section class="content-header">
                    <h1>
                        Dashboard
                        <small>Visor de Ventas</small>
                    </h1>
                    <ol class="breadcrumb">
                        <li><a href="#"><i class="fa fa-dashboard"></i> Inicio</a></li>
                        <li class="active">Resumen</li>
                    </ol>
                </section>

                <!-- Main content -->
                <section class="content">
                    <div class="row">
                        <div class="col-xs-12">
                            <div class="box">
                                <div class="box-header">
                                    <h3 class="box-title">Ventas en Proceso</h3>                                    
                                </div><!-- /.box-header -->
                                <div class="box-body table-responsive">
                                	<?php
                                    showNotificacion();
                                    ?>
                                    <div style="text-align:center; width: 100%; margin-bottom: 10px;"><button id="btnRefrescar" class="btn btn-primary btn-lg">Refrescar</button></div>
                                    <table id="example2" class="table table-bordered table-hover">
                                        <thead>
                                            <tr>
                                            	<th>Id</th>
                                                <th>Codigo</th>
                                                <th>Cliente</th>
                                                <th>Factura</th>
                                                <th>Tiempo</th>
                                                <th>Monto</th>
                                                <th>Estatus</th>
                                                <th>Autorización</th>
                                                <th>Imprimir</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php
                                            if ( $_SESSION["usuario"]["idTipoUsuario"] == 1 ) {
                                            	$datas = $db->select("operaciones", "*", ["ORDER" => "id DESC" ]);
                                            } else {
                                            	$datas = $db->select("operaciones", "*", ["AND" =>[
													"idCliente" => $_SESSION["usuario"]["idCliente"]
													
												], "ORDER" => "id DESC" ]);
                                            }
                                            
											foreach ($datas as $data) {
												$datetime1 = strtotime($data["fecCreacion"]);
												$datetime2 = time();
												$horas = ( $datetime2 - $datetime1 ) / 3600;
												if ( $horas < 1 ) {
													$vigencia = "Hace minutos";
												} else {
													$vigencia = "Hace " . number_format($horas, 0) . " Hora(s)";
												}
												$duracionOperacion = $data["duracionOperaciones"];
                                            ?>
                                            <tr>
                                            	<td><?=$data["id"]?></td>
                                            	<td><b><?=$data["codOperacion"]?></b></td>
                                                <td><?=$data["nombre"]?></td>
                                                <td><?=$data["numControl"]?></td>
                                                <td><?=$vigencia?><p>Historico en <?=$duracionOperacion-number_format($horas, 0);?> Hrs.</p></td>
                                                <td><?=$data["monto"]?></td>
                                                <td><?=$data["estatus"]?></td>
                                                <td><?=$data["numAutorizacion"]?></td>
                                                <td align="center">
                                                	<a data-ajax="false" href="voucher.php?id=<?=base64_encode($data['id'])?>" target="_blank" ><i title="Ver Voucher" class="fa fa-ticket fa-2x"></i></a>
                                                	<?php
                                                	if ( ( $data["estatus"] == "Incompleta" ) || ( $data["estatus"] == "No Autorizada" ) || ( $data["estatus"] == "Autorizada" ) ) {
                                                	?>	
                                                	<a data-ajax="false" href="includes/functions.php?op=duplicaOperacion&id=<?=base64_encode($data['id'])?>"><i title="Duplicar Operacion" class="fa fa-copy fa-2x"></i></a>
                                                	<?php
													}
                                                	?>
                                                	<a data-ajax="false" href="includes/functions.php?op=enviaOperacionesH&id=<?=base64_encode($data['id'])?>"><i title="Enviar a Historial" class="fa fa-history fa-2x"></i></a>
                                                </td>
                                            </tr>
                                            <?php
											}
											?>
                                        </tbody>
                                    </table>
                                </div><!-- /.box-body -->
                            </div><!-- /.box -->
						</div>
                    </div>
                </section><!-- /.content -->
            </aside><!-- /.right-side -->
        </div><!-- ./wrapper -->

    </body>
</html>