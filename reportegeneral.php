			<!-- Right side column. Contains the navbar and content of the page -->
            <aside class="right-side">
                <!-- Content Header (Page header) -->
                <section class="content-header">
                    <h1>
                        Reportes
                        <small>General</small>
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
                                    <h3 class="box-title">Reporte General</h3>                                    
                                </div><!-- /.box-header -->
                                <div class="box-body table-responsive">
                                	<?php
                                	$txtFecDesde = isset($_POST["txtFecDesde"])?$_POST["txtFecDesde"]:date("d-m-Y");
                                	$txtFecHasta = isset($_POST["txtFecHasta"])?$_POST["txtFecHasta"]:date("d-m-Y");
                                	$cboTransaccion = isset($_POST["cboTransaccion"])?$_POST["cboTransaccion"]:"";
                                	?>
									<form name="frmFiltroOperaciones" method="post" action="#">
										<input type="hidden" name="txtBuscar" value="1">
										<table data-role="table" id="movie-table" class="ui-responsive table-stroke" data-column-btn-text="Columnas">
											<thead>
												<tr>
													<td style="vertical-align: middle !important;"><label for="txtFecDesde">Fecha Desde</label><input class="form-control" type="text" name="txtFecDesde" id="txtFecDesde" data-inputmask="'alias': 'dd/mm/yyyy'" data-mask value="<?=$txtFecDesde;?>"></td>
													<td style="vertical-align: middle !important;"></td>
													<td style="vertical-align: middle !important;"><label for="txtFecHasta">Fecha Hasta</label><input class="form-control" type="text" name="txtFecHasta" id="txtFecHasta" data-inputmask="'alias': 'dd/mm/yyyy'" data-mask value="<?=$txtFecHasta;?>"></td>
													<td style="vertical-align: middle !important;"></td>
												</tr>
												<tr>
													<td style="vertical-align: middle !important;">
														<label for="cboTransaccion">Transaccion</label>
														<select name="cboTransaccion" id="cboTransaccion" class="form-control" >
															<option <?=($cboTransaccion==0)?"selected":"";?> value="0">-- Todas --</option>
															<option <?=($cboTransaccion==4)?"selected":"";?> value="4">No Autorizada</option>
															<option <?=($cboTransaccion==5)?"selected":"";?> value="5">Autorizada</option>
														</select>							
													</td>
													<td style="vertical-align: middle !important;"></td>
													<td style="vertical-align: middle !important;"></td>
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
									<div class="botonera">
										<a target="_blank" href="reportegeneralexcel.php" title="Imprimir"><i class="fa fa-file-excel-o fa-2x"></i></a>
										<a target="_blank" href="reportegeneraldet.php" title="Imprimir"><i class="fa fa-print fa-2x"></i></a>
									</div>
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
                                            $datas = "";
                                            if ( count( $_POST ) == 0 ) {
								            ?>
								            	<tr>
	                                            	<td align="center" colspan="9">Seleccione algunos criterios de busqueda</td>
	                                            </tr>
								            <?php
											} else {
												$_SESSION["temp"]["POST"] = $_POST;
												$condicionCboTransaccion = "";
												
												if ($_POST["cboTransaccion"] != 0) {
													$condicionCboTransaccion = "AND estatus = " . $_POST["cboTransaccion"];
												} else {
													$condicionCboTransaccion = "AND estatus NOT IN (1,2,3)";
												}
												$fechaDesde = ($_POST["txtFecDesde"] != "")?"'".date("Y-m-d", strtotime($_POST["txtFecDesde"]))."'":date("Y-m-d");
												$fechaHasta = ($_POST["txtFecHasta"] != "")?"'".date("Y-m-d", strtotime($_POST["txtFecHasta"]))."'":date("Y-m-d");
												$condicFecha = "";
												if ( ( $fechaDesde != "" ) && ( $fechaHasta == "" ) ) {
													$condicFecha = "AND 
																	(DATE_FORMAT(fecCreacion,'%Y-%m-%d') >= " . $fechaDesde . ") ";
												}
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
																		$condicionCboTransaccion . " " .
																		$condicFecha . " 
																		ORDER BY id DESC")->fetchAll();
												if ( count( $datas ) == 0 ) {
												?>
													<tr>
		                                            	<td align="center" colspan="9">No se encontraron coincidencias</td>
		                                            </tr>
												<?php	
												} else {
													$_SESSION["query"] = $datas;
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
