<script type="text/javascript">
    $(function() {
        $('#example1').dataTable({
        	"oLanguage": {
	           "sSearch": "Filtrar:",
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
                        Puntos Virtuales
                        <small>Visor de Puntos Virtuales</small>
                    </h1>
                    <ol class="breadcrumb">
                        <li><a href="#"><i class="fa fa-dashboard"></i> Inicio</a></li>
                        <li class="active">Puntos Virtuales</li>
                    </ol>
                </section>

                <!-- Main content -->
                <section class="content">
                    <div class="row">
                        <div class="col-xs-12">
                            <div class="box">
                                <div class="box-header">
                                    <h3 class="box-title">Puntos Virtuales Activos e Inactivos</h3>                                    
                                </div><!-- /.box-header -->
                                <div class="box-body table-responsive">
                                    <table id="example1" class="table table-bordered table-striped">
                                        <thead>
                                            <tr>
                                                <th>Codigo</th>
                                                <th>Cliente</th>
                                                <th>Descripción</th>
                                                <th>Banco</th>
                                                <th>Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php
                                            $datas = $db->select("virtual_points", "*", ["ORDER" => ["estatus DESC", "id DESC"]]);
											foreach ($datas as $data) {
                                            ?>
                                            <tr>
                                            	<td><b><?=$data["id"]?></b></td>
                                                <td><?=buscaNombre($db, "clientes", $data["idCliente"])?></td>
                                                <td><?=$data["descripcion"]?></td>
                                                <td><?=buscaNombre($db, "bancos", $data["idBanco"])?></td>
                                                <td><?=estatus($data["estatus"])?></td>
                                                <td>
                                                	<a href="home.php?s=<?=cEditVirtualPoints?>&id=<?=$data["id"]?>"><i class="fa fa-pencil-square-o"></i></a>
                                                	<a href="includes/functions.php?op=estatus&id=<?=$data["id"]?>&e=<?=$data["estatus"]?>&tabla=virtual_points"><i class="<?=muestraToggle($data["estatus"])?>"></i></a>
                                                	<a href="includes/functions.php?op=delete&id=<?=$data["id"]?>&tabla=virtual_points"><i class="fa fa-remove"></i></a>
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