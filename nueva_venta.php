            <!-- Right side column. Contains the navbar and content of the page -->
            <aside class="right-side">
                <!-- Content Header (Page header) -->
                <section class="content-header">
                    <h1>
                        Generar Nueva Venta
                        <small>Cobranza</small>
                    </h1>
                    <ol class="breadcrumb">
                        <li><a href="home.php"><i class="fa fa-dashboard"></i> Inicio</a></li>
                        <li class="active">Cobranzas</li>
                    </ol>
                </section>

                <!-- Main content -->
                <section class="content">
                    <div class="row">
                        <!-- left column -->
                        <div class="col-md-6" style="float:none !important; margin: auto;">
                            <!-- general form elements -->
                            <div class="box box-primary">
                                <div class="box-header">
                                    <h3 class="box-title">Datos Principales</h3>
                                </div><!-- /.box-header -->
                                <!-- form start -->
                                <form role="form" id="frmNuevaVenta" action="<?=$urlWebServiceClient?>clienteTransacciones.php" method="post">
                                    <div class="box-body">
                                        <div class="form-group">
	                                        <label for="txtCodigoOperacion">Identificador</label>
                                        	<input type="text" name="txtCodigoOperacion" id="txtCodigoOperacion" class="form-control onlyNumber" placeholder="Identificador">
	                                    </div>
                                        <div class="form-group">
	                                        <label for="txtNombre">Nombre del Cliente</label>
                                        	<input type="text" name="txtNombre" id="txtNombre" class="form-control" placeholder="Nombre">
	                                    </div>                                     
                                        <div class="form-group">
	                                        <label for="txtEmailCliente">Email del Cliente</label><br>
                                        	<input type="text" name="txtEmailCliente" id="txtEmailCliente" class="form-control" placeholder="Email">
	                                    </div>
	                                    <div class="form-group">
	                                        <label for="txtNumeroFactura">Referencia</label>
                                        	<input type="text" name="txtNumeroFactura" id="txtNumeroFactura" class="form-control withoutSpace" placeholder="Ejemplo: Factura, Recibo, Nota de Entrega.">
	                                    </div>
                                        <div class="form-group">
											<label for="txtMontoFactura">Monto</label>
	                                        <input type="text" name="txtMontoFactura" id="txtMontoFactura" class="form-control" placeholder="Monto">
	                                    </div>
	                                    <?php
										$datas = $db->select("virtual_points",["id", "descripcion"], ["idCliente" => $_SESSION["usuario"]["idCliente"]]);
	                                    ?>
	                                    <label>Punto Virtual</label>
	                                    <div class="input-group">
	                                        <?php
	                                        foreach ( $datas as $data ) {
	                                        ?>
		                                        <input type="radio" name="rdoVirtualPoint" value="<?=$data["id"];?>" class="minimal"/> <?=$data["descripcion"];?>
	                                        <?php
											}
											?>
	                                    </div>
	                                    
                                    </div><!-- /.box-body -->

                                    <div class="box-footer">
                                        <button type="submit" id="btnSiguiente" class="btn btn-primary">Siguiente</button>
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
		$('#frmNuevaVenta').submit(function( e ){
			
			if( $('#txtCodigoOperacion').val() == "" ) {
				alert("Todos los campos son obligatorios");
				$('#txtCodigoOperacion').focus(); e.preventDefault();
			} else if( $('#txtNombre').val() == "" ) {
				alert("Todos los campos son obligatorios");
				$('#txtNombre').focus(); e.preventDefault();
			} else if( $('#txtEmailCliente').val() == "" ) {
				alert("Todos los campos son obligatorios");
				$('#txtEmailCliente').focus(); e.preventDefault();
			} else if($("#txtEmailCliente").val().indexOf('@', 0) == -1 || $("#txtEmailCliente").val().indexOf('.', 0) == -1) {
	            alert("El correo electrónico introducido no es valido.");
	            $('#txtEmailCliente').focus(); e.preventDefault();
	        } else if( $('#txtNumeroFactura').val() == "" ) {
				alert("Todos los campos son obligatorios");
				$('#txtNumeroFactura').focus(); e.preventDefault();
			} else if( $('#txtMontoFactura').val() == "" ) {
				alert("Todos los campos son obligatorios");
				$('#txtMontoFactura').focus(); e.preventDefault();
			} else  if ( ! $('input[name="rdoVirtualPoint"]').is(':checked')) {
				alert("Debe seleccionar un Virtual Point");
				e.preventDefault();
			} else {
				return true;
			}
			
		});

        $(".withoutSpace").keydown(function (e) {
	        if ( e.keyCode == 32 ) {
	            e.preventDefault();
	        }
	    });

		$(".onlyNumber").keydown(function (e) {
	        if ($.inArray(e.keyCode, [46, 8, 9, 27, 13]) !== -1 ||
	            (e.keyCode == 65 && e.ctrlKey === true) || 
	            (e.keyCode >= 35 && e.keyCode <= 39)) {
	                 return;
	        }
	 
	        if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
	            e.preventDefault();
	        }
	    });


	});
</script>