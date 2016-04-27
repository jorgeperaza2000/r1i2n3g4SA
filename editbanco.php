            <!-- Right side column. Contains the navbar and content of the page -->
            <aside class="right-side">
                <!-- Content Header (Page header) -->
                <section class="content-header">
                    <h1>
                        Editar Banco
                        <small>Bancos</small>
                    </h1>
                    <ol class="breadcrumb">
                        <li><a href="home.php"><i class="fa fa-dashboard"></i> Inicio</a></li>
                        <li class="active">Edición de Bancos</li>
                    </ol>
                </section>
				<?php
                $reg = $db->get("bancos", "*", ["id" => $_GET["id"] ]);
				?>
                <!-- Main content -->
                <section class="content">
                    <div class="row">
                        <!-- left column -->
                        <div class="col-md-6" style="float:none !important; margin: auto;">
                            <!-- general form elements -->
                            <div class="box box-primary">
                                <div class="box-header">
                                    <h3 class="box-title">Datos del Banco</h3>
                                </div><!-- /.box-header -->
                                <!-- form start -->
                                <form role="form" action="includes/functions.php?op=editBanco&id=<?=$_GET["id"]?>" autocomplete="off" method="post">
                                    <div class="box-body">
                                        
                                        <div class="form-group">
                                        	<label for="txtNombre">Nombre del Banco</label>
	                                        <input type="text" name="txtNombre" value="<?=$reg["nombre"];?>" id="txtNombre" class="form-control" placeholder="Nombre">
	                                    </div>                                     
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