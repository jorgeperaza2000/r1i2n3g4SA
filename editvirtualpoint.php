            <!-- Right side column. Contains the navbar and content of the page -->
            <aside class="right-side">
                <!-- Content Header (Page header) -->
                <section class="content-header">
                    <h1>
                        Editar Punto Virtual
                        <small>Punto Virtuales</small>
                    </h1>
                    <ol class="breadcrumb">
                        <li><a href="home.php"><i class="fa fa-dashboard"></i> Inicio</a></li>
                        <li class="active">Edición de Punto Virtuales</li>
                    </ol>
                </section>
				<?php
                $reg = $db->get("virtual_points", "*", ["id" => $_GET["id"] ]);
				?>
                <!-- Main content -->
                <section class="content">
                    <div class="row">
                        <!-- left column -->
                        <div class="col-md-6" style="float:none !important; margin: auto;">
                            <!-- general form elements -->
                            <div class="box box-primary">
                                <div class="box-header">
                                    <h3 class="box-title">Datos del Punto Virtual</h3>
                                </div><!-- /.box-header -->
                                <!-- form start -->
                                <form role="form" id="frmAddVirtualPoint" action="includes/functions.php?op=editVirtualPoint&id=<?=$_GET["id"]?>" method="post">
                                    <div class="box-body">
                                        
                                        <div class="form-group">
                                        	<label for="txtDescripcion">Descripición</label>
	                                        <input type="text" name="txtDescripcion" value="<?=$reg["descripcion"];?>" id="txtDescripcion" class="form-control" placeholder="Descripción">
	                                    </div>                                     
                                        <?php
	                                    $datas = $db->select("clientes",["id", "nombre"], ["ORDER" => "nombre ASC"]);
	                                    ?>
	                                    <label for="cmbCliente">Cliente</label>
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
	                                    <div class="form-group">
	                                        <label for="txtCodAfiliacion">C&oacute;digo de Afiliaci&oacute;n</label>
	                                        <input type="text" name="txtCodAfiliacion" id="txtCodAfiliacion" value="<?=$reg["codAfiliacion"]?>" class="form-control" placeholder="Afiliaci&oacute;n">
	                                    </div>
	                                    <div class="form-group">
	                                        <label for="txtTranscode">Transcode</label>
	                                        <input type="text" name="txtTranscode" id="txtTranscode" value="<?=$reg["transcode"]?>" class="form-control" placeholder="Transcode">
	                                    </div>
	                                    <?php
	                                    $datas = $db->select("bancos",["id", "nombre"], ["ORDER" => "nombre ASC"]);
	                                    ?>
	                                    <label for="cmbBanco">Banco</label>
	                                    <select name="cmbBanco" id="cmbBanco" class="form-control">
	                                    	<option value="0">-- SELECCIONE --</option>
	                                        <?php
	                                        foreach ( $datas as $data ) {
	                                        ?>
	                                        	<option <?=($reg["idBanco"] == $data["id"])?"selected":""?> value="<?=$data["id"]?>"><?=$data["nombre"]?></option>
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
<script type="text/javascript">
	$(document).ready(function(){
		$('#frmAddVirtualPoint').submit(function( e ){
			if( $('#txtDescripcion').val() == "" ) {
				alert("Todos los campos son obligatorios");
				$('#txtDescripcion').focus(); e.preventDefault();
			} else if( $('#cmbCliente').val() == "0" ) {
				alert("Todos los campos son obligatorios");
				$('#cmbCliente').focus(); e.preventDefault();
			} else if( $('#txtCodAfiliacion').val() == "" ) {
				alert("Todos los campos son obligatorios");
				$('#txtCodAfiliacion').focus(); e.preventDefault();
			} else if( $('#txtTranscode').val() == "" ) {
				alert("Todos los campos son obligatorios");
				$('#txtTranscode').focus(); e.preventDefault();
			} else if( $('#cmbBanco').val() == "0" ) {
				alert("Todos los campos son obligatorios");
				$('#cmbBanco').focus(); e.preventDefault();
			} else {
				return true;
			}
		});
		
		$("#cmbEstado").trigger("change");
	});
</script>