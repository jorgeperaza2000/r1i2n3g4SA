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
                        Usuarios
                        <small>Visor de Usuarios</small>
                    </h1>
                    <ol class="breadcrumb">
                        <li><a href="#"><i class="fa fa-dashboard"></i> Inicio</a></li>
                        <li class="active">Usuarios</li>
                    </ol>
                </section>

                <!-- Main content -->
                <section class="content">
                    <div class="row">
                        <div class="col-xs-12">
                            <div class="box">
                                <div class="box-header">
                                    <h3 class="box-title">Usuarios Activos e Inactivos</h3>                                    
                                </div><!-- /.box-header -->
                                <div class="box-body table-responsive">
                                    <?php
                                    showNotificacion();
                                    ?>
                                    <table id="example1" class="table table-bordered table-striped">
                                        <thead>
                                            <tr>
                                                <th>Codigo</th>
                                                <th>Nombre</th>
                                                <th>Usuario</th>
                                                <th>Cliente</th>
                                                <th>Tipo</th>
                                                <th>Estatus</th>
                                                <th>Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php
                                            if ( $_SESSION["usuario"]["idTipoUsuario"] == 1 ) {
                                                $datas = $db->select("usuarios", "*", ["ORDER" => ["estatus DESC", "id DESC"]]);    
                                            } else {
                                                $datas = $db->select("usuarios", "*", ["ORDER" => ["estatus DESC", "id DESC"]]);    
                                            }
                                            
											foreach ($datas as $data) {
                                            ?>
                                            <tr>
                                            	<td><b><?=$data["id"]?></b></td>
                                                <td><?=$data["nombre"]?></td>
                                                <td><?=$data["usuario"]?></td>
                                                <td><?=buscaNombre($db, "clientes", $data["idCliente"])?></td>
                                                <td><?=buscaNombre($db, "tipo_usuario", $data["idTipoUsuario"])?></td>
                                                <td><?=estatus($data["estatus"])?></td>
                                                <td>
                                                	<a href="home.php?s=<?=cEditUsuarios?>&id=<?=$data["id"]?>"><i class="fa fa-pencil-square-o"></i></a>
                                                	<a href="<?=$urlWebServiceClient?>clienteUsuarios.php?idUsuario=<?=$data["id"]?>&accion=4"><i class="<?=muestraToggle($data["estatus"])?>"></i></a>
                                                	<a href="<?=$urlWebServiceClient?>clienteUsuarios.php?idUsuario=<?=$data["id"]?>&accion=3"><i class="fa fa-remove"></i></a>
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