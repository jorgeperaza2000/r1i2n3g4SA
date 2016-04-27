            <!-- Right side column. Contains the navbar and content of the page -->
            <aside class="right-side">
                <!-- Content Header (Page header) -->
                <section class="content-header">
                    <h1>
                        Editar Usuario
                        <small>Usuarios</small>
                    </h1>
                    <ol class="breadcrumb">
                        <li><a href="home.php"><i class="fa fa-dashboard"></i> Inicio</a></li>
                        <li class="active">Edición de Usuarios</li>
                    </ol>
                </section>
				<?php
                $reg = $db->get("usuarios", "*", ["id" => $_GET["id"] ]);
				?>
                <!-- Main content -->
                <section class="content">
                    <div class="row">
                        <!-- left column -->
                        <div class="col-md-6" style="float:none !important; margin: auto;">
                            <!-- general form elements -->
                            <div class="box box-primary">
                                <div class="box-header">
                                    <h3 class="box-title">Datos del Usuario</h3>
                                </div><!-- /.box-header -->
                                <!-- form start -->
                                <form role="form" action="<?=$urlWebServiceClient?>clienteUsuarios.php?idUsuario=<?=$_GET["id"]?>&accion=2" autocomplete="off" method="post">
                                    <div class="box-body">
                                    	<?php
	                                    showNotificacion();
	                                    ?>
                                        <div class="form-group">
                                        	<label for="txtNombre">* Nombre del Usuario</label>
	                                        <input type="text" name="txtNombre" value="<?=$reg["nombre"];?>" id="txtNombre" class="form-control" placeholder="Nombre">
	                                    </div>                                     
                                        <div class="form-group">
	                                        <label for="txtUsuario">* Usuario</label>
	                                        <input type="text" name="txtUsuario" value="<?=$reg["usuario"];?>" id="txtUsuario" class="form-control" placeholder="Usuario: ejemplo (jperez)">
	                                    </div>
	                                    <div class="form-group">
	                                        <label for="txtClave">* Clave</label>
	                                        <input type="password" name="txtClave" value="<?=$reg["clave"];?>" id="txtClave" class="form-control" placeholder="Clave">
	                                    </div>
	                                    <div class="form-group">
	                                        <label for="txtReClave">* Repita la Clave</label>
	                                        <input type="password" name="txtReClave" value="<?=$reg["clave"];?>" id="txtReClave" class="form-control" placeholder="Repita la Clave">
	                                    </div>
	                                    <div class="form-group">
	                                        <label for="txtExtension">* Extension</label>
	                                        <input type="text" name="txtExtension" value="<?=$reg["extension"];?>" id="txtExtension" class="form-control" placeholder="Extension en caso que sea necesario">
	                                    </div>
	                                    <?php
	                                    if ( $_SESSION["usuario"]["idTipoUsuario"] == 1 ) {
	                                    	$datas = $db->select("tipo_usuario",["id", "nombre", "descripcion"], ["estatus" => 1]);
	                                    } else {
	                                    	$datas = $db->select("tipo_usuario",["id", "nombre", "descripcion"], ["AND" => ["estatus" => 1, "mostrar" => 1]]);
	                                    }
	                                    ?>
	                                    <label for="cmbTipoUsuario">* Tipo</label>
	                                    <select name="cmbTipoUsuario" id="cmbTipoUsuario" class="form-control">
	                                    	<option value="0">-- SELECCIONE --</option>
	                                        <?php
	                                        foreach ( $datas as $data ) {
	                                        ?>
	                                        	<option <?=($reg["idTipoUsuario"] == $data["id"])?"selected":""?> value="<?=$data["id"]?>"><?=$data["nombre"]?></option>
	                                        <?php
											}
	                                        ?>
	                                    </select>
	                                    <?php
	                                    $datas = $db->select("clientes",["id", "nombre"], ["estatus" => 1]);
	                                    ?>
	                                    <label for="cmbCliente">* Cliente</label>
	                                    <select name="cmbCliente" id="cmbCliente" class="form-control">
	                                    	<option value="0">-- SELECCIONE --</option>
	                                        <?php
	                                        foreach ( $datas as $data ) {
	                                        ?>
	                                        	<option <?=($reg["idCliente"] == $data["id"])?"selected":""?> value="<?=$data["id"]?>"><?=$data["nombre"]?></option>
	                                        <?php
											}
	                                        ?>
	                                    </select>
                                    </div><!-- /.box-body -->
                                    <div class="box-footer">
                                        <button type="submit" id="btnSiguiente" class="btn btn-primary">Agregar</button>
                                    </div>
                                </form>
                            </div><!-- /.box -->
                        </div><!--/.col (right) -->
                    </div>   <!-- /.row -->
                </section><!-- /.content -->
            </aside><!-- /.right-side -->
        </div><!-- ./wrapper -->
    </body>
</html>