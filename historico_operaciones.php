			<!-- Right side column. Contains the navbar and content of the page -->
            <aside class="right-side">
                <!-- Content Header (Page header) -->
                <section class="content-header">
                    <h1>
                        Reportes
                        <small>Historial de Operaciones</small>
                    </h1>
                    <ol class="breadcrumb">
                        <li><a href="#"><i class="fa fa-dashboard"></i> Inicio</a></li>
                        <li class="active">Reportes</li>
                    </ol>
                </section>

                <!-- Main content -->
                <section class="content">
                    <div class="row">
                        <div class="col-xs-12">
                            <div class="box">
                                <div class="box-header">
                                    <h3 class="box-title">Historial de Operaciones</h3>                                    
                                </div><!-- /.box-header -->
                                <div class="box-body table-responsive">
                                	<?php
                                	$txtCodOperacion = isset($_POST["txtCodOperacion"])?$_POST["txtCodOperacion"]:"";
                                	$txtDocIdentidad = isset($_POST["txtDocIdentidad"])?$_POST["txtDocIdentidad"]:"";
                                	$txtFecDesde = isset($_POST["txtFecDesde"])?$_POST["txtFecDesde"]:"";
                                	$txtFecHasta = isset($_POST["txtFecHasta"])?$_POST["txtFecHasta"]:"";
                                	?>
									<form name="frmFiltroOperaciones" method="post" action="#">
										<input type="hidden" name="txtBuscar" value="1">
										<table data-role="table" id="movie-table" class="ui-responsive table-stroke" data-column-btn-text="Columnas">
											<thead>
												<tr>
													<td style="vertical-align: middle !important;"><label for="txtCodOperacion">Identificador</label><input class="form-control" type="text" name="txtCodOperacion" id="txtCodOperacion" value="<?=$txtCodOperacion;?>"></td>
													<td style="vertical-align: middle !important;"></td>
													<td style="vertical-align: middle !important;"><label for="txtDocIdentidad">Cedula de Identidad:</label><input class="form-control" type="text" name="txtDocIdentidad" id="txtDocIdentidad" value="<?=$txtDocIdentidad;?>"></td>
													<td style="vertical-align: middle !important;"></td>
												</tr>
												<tr>
													<td style="vertical-align: middle !important;"><label for="txtFecDesde">Fecha Desde</label><input class="form-control" type="text" name="txtFecDesde" id="txtFecDesde" data-inputmask="'alias': 'dd/mm/yyyy'" data-mask value="<?=$txtFecDesde;?>"></td>
													<td style="vertical-align: middle !important;"></td>
													<td style="vertical-align: middle !important;"><label for="txtFecHasta">Fecha Hasta</label><input class="form-control" type="text" name="txtFecHasta" id="txtFecHasta" data-inputmask="'alias': 'dd/mm/yyyy'" data-mask value="<?=$txtFecHasta;?>"></td>
													<td style="vertical-align: middle !important;"></td>
												</tr>
												<tr>
													<td colspan="4">
														<button class="btn btn-primary" id="btnSiguiente" type="submit">Buscar</button>
													</td>
												</tr>
											</thead>
										</table>
									</form>
									
                                    <table id="example2" class="table table-bordered table-hover">
                                        <thead>
                                            <tr>
                                                <th>Id</th>
                                                <th>Codigo</th>
                                                <th>Cliente</th>
                                                <th>Factura</th>
                                                <th>Fecha</th>
                                                <th>Estatus</th>
                                                <th>Autorización</th>
                                                <th>Monto</th>
                                                <th>Imprimir</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php
                                            if ( !isset( $_POST["txtBuscar"] ) ) {
								                if ( $_SESSION["usuario"]["idTipoUsuario"] == 1 ) {
									                $datas = $db->select("operaciones_h", "*", ["LIMIT" => 5, "ORDER" => "id DESC" ]);
												} else {
													$datas = $db->select("operaciones_h", "*", ["AND" =>[
															"idCliente" => $_SESSION["usuario"]["idCliente"]
														], "LIMIT" => 5, "ORDER" => "id DESC" ]);
												}
											} else {
												$condicionCodOperacion = "";
												$condicionDocIdentidad = "";
												
												if ($_POST["txtCodOperacion"] != "") {
													$condicionCodOperacion = "AND codOperacion LIKE '%" . $_POST["txtCodOperacion"] . "%'";
												}
												if ($_POST["txtDocIdentidad"] != "") {
													$condicionDocIdentidad = "AND docIdentidad LIKE '%" . $_POST["txtDocIdentidad"] . "%'";
												}
												$fechaDesde = ($_POST["txtFecDesde"] != "")?"'".date("Y-m-d", strtotime($_POST["txtFecDesde"]))."'":"";
												$fechaHasta = ($_POST["txtFecHasta"] != "")?"'".date("Y-m-d", strtotime($_POST["txtFecHasta"]))."'":"";
												$condicFecha = "";
												if ( ( $fechaDesde != "" ) && ( $fechaHasta != "" ) ) {
													$condicFecha = "AND 
																	(DATE_FORMAT(fecCreacion,'%Y-%m-%d') BETWEEN " . $fechaDesde . " 
																	AND " . $fechaHasta . ") ";
												}
												if ( $_SESSION["usuario"]["idTipoUsuario"] == 1 ) {
													$cliente = " 1 = 1 ";
												} else {
													$cliente = "idCliente = '" . $_SESSION["usuario"]["idCliente"] . "'";
												}
												
												$datas = $db->query("SELECT * FROM operaciones_h WHERE 
																		" . $cliente . " " .
																		$condicionCodOperacion . " " .
																		$condicionDocIdentidad . " " .
																		$condicFecha . " 
																		ORDER BY id DESC")->fetchAll();
											}
											foreach ($datas as $data) {
                                            ?>
	                                            <tr>
	                                            	<td><?=$data["id"]?></td>
	                                            	<td><b><?=$data["codOperacion"]?></b></td>
	                                                <td><?=$data["nombre"]?><p><?=$data["docIdentidad"]?></p></td>
	                                                <td><?=$data["numControl"]?></td>
	                                                <td><?=$data["fecCreacion"]?></td>
	                                                <td><?=$data["estatus"]?></td>
	                                                <td><?=$data["numAutorizacion"]?></td>
	                                                <td><?=$data["monto"]?></td>
	                                                <td align="center">
	                                                	<a data-ajax="false" href="voucher.php?id=<?=base64_encode($data['id'])?>" target="_blank" ><i title="Ver Voucher" class="fa fa-ticket fa-2x"></i></a>
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
<script>
	$(document).ready(function(){
		$("#txtFecDesde").inputmask("dd-mm-yyyy", {"placeholder": "dd-mm-yyyy"});
		$("#txtFecHasta").inputmask("dd-mm-yyyy", {"placeholder": "dd-mm-yyyy"});
	});
</script>