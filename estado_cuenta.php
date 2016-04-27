<script type="text/javascript">
    $(function() {
        $('#example1').dataTable({
        	"oLanguage": {
	           "sSearch": "Filtrar:",
               "sEmptyTable":"No se encontraron registros",
	           "sInfo": "Mostrando _START_ a _END_ de _TOTAL_ registros",
	           "oPaginate": {
	              "sPrevious": "Anterior",
	              "sNext": "Siguiente"
	           }	        
	        },
            "bPaginate": true,
            "bLengthChange": true,
            "bFilter": true,
            "bSort": false,
            "bInfo": true,
            "bAutoWidth": true
        });
    });
</script>
			<!-- Right side column. Contains the navbar and content of the page -->
            <aside class="right-side">
                <!-- Content Header (Page header) -->
                <section class="content-header">
                    <h1>
                        Estados de Cuenta
                        <small>Visor</small>
                    </h1>
                    <ol class="breadcrumb">
                        <li><a href="#"><i class="fa fa-dashboard"></i> Inicio</a></li>
                        <li class="active">Estado de Cuenta</li>
                    </ol>
                </section>

                <!-- Main content -->
                <section class="content">
                    <div class="row">
                        <div class="col-xs-12">
                            <div class="box">
                                <div class="box-header">
                                    <h3 class="box-title">Facturación Activa, Vencida y Pagada</h3>                                    
                                </div><!-- /.box-header -->
                                <div class="box-body table-responsive">
                                    <table id="example1" class="table table-bordered table-striped">
                                        <thead>
                                            <tr>
                                                <th>Número</th>
                                                <th>Fecha</th>
                                                <th>Cliente</th>
                                                <th>Estatus</th>
                                                <th>Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php
                                            if ( $_SESSION["usuario"]["idTipoUsuario"] == 1 ) {
                                                $datas = $db->select("facturas", "*", ["ORDER" => ["estatus DESC", "id DESC"]]);    
                                            } else {
                                                $datas = $db->select("facturas", "*", ["idCliente" => $_SESSION["usuario"]["idCliente"], "ORDER" => ["estatus DESC", "id DESC"]]);    
                                            }
                                            
											foreach ($datas as $data) {
                                            ?>
                                            <tr>
                                            	<td><b><?=$data["numFactura"]?></b></td>
                                                <td><?=$data["fecFactura"]?></td>
                                                <td><?=buscaNombre($db, "clientes", $data["idCliente"])?></td>
                                                <td><?=$data["estatus"]?></td>
                                                <td>
                                                	<a href="home.php?s=<?=cVerFactura?>&id=<?=$data["id"]?>"><i class="fa fa-file-text-o"></i></a>
                                                    <a href="home.php?s=<?=cReportarPago?>&id=<?=$data["id"]?>"><i class="fa fa-credit-card"></i></a>
                                                </td>
                                            </tr>
                                            <?php
											}
											?>
                                        </tbody>
                                    </table>
                                    <div style="text-align:center; width: 100%; margin-top: 10px;"><button id="btnRefrescar" class="btn btn-primary btn-lg">Refrescar</button></div>
                                </div><!-- /.box-body -->
                            </div><!-- /.box -->
						</div>
                    </div>
                </section><!-- /.content -->
            </aside><!-- /.right-side -->
        </div><!-- ./wrapper -->

    </body>
</html>