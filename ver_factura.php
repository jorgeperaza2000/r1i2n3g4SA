<aside class="right-side">                
    <!-- Content Header (Page header) -->
    <?php
    $sub_total = 0;
    $data = $db->get("facturas", "*", ["id" => $_GET["id"]]); 
    ?>
    <section class="content-header">
        <h1>
            Factura
            <small>#<?=$data["numFactura"]?></small>
        </h1>
        <ol class="breadcrumb">
            <li><a href="#"><i class="fa fa-dashboard"></i> Inicio</a></li>
            <li><a href="home.php?s=<?=cEstadoCuenta?>"><i class="fa fa-file-text-o"></i> Estado de Cuenta</a></li>
            <li class="active">Factura</li>
        </ol>
    </section>

    <!-- Main content -->
    <section class="content invoice">                    
        <!-- title row -->
        <div class="row">
            <div class="col-xs-12">
                <h2 class="page-header">
                    <i class="fa fa-globe"></i> Oriantech C.A.
                    <small class="pull-right">Fecha: <?=date("d-m-y", strtotime($data["fecFactura"]))?></small>
                </h2>                            
            </div><!-- /.col -->
        </div>
        <!-- info row -->
        <div class="row invoice-info">
            <div class="col-sm-4 invoice-col">
                <address>
                    <strong>Cliente: <?=buscaNombre($db, "clientes", $data["idCliente"])?></strong><br>
                    <?=buscaNombre($db, "clientes", $data["idCliente"], "direccion")?><br>
                    Teléfono: <?=buscaNombre($db, "clientes", $data["idCliente"], "telefono")?><br>
                    Atención: <?=buscaNombre($db, "clientes", $data["idCliente"], "personaContacto")?><br>
                </address>
            </div><!-- /.col -->
            <div class="col-sm-4 invoice-col">
                <!--To
                <address>
                    <strong>John Doe</strong><br>
                    795 Folsom Ave, Suite 600<br>
                    San Francisco, CA 94107<br>
                    Phone: (555) 539-1037<br/>
                    Email: john.doe@example.com
                </address>-->
            </div><!-- /.col -->
            <div class="col-sm-4 invoice-col">
                <b>Fectura #<?=$data["numFactura"]?></b><br/>
                <br/>
                <b>Vencimiento:</b> <?=date("d-m-y", strtotime($data["fecFactura"] . "+ 5 day"))?><br/>
            </div><!-- /.col -->
        </div><!-- /.row -->

        <!-- Table row -->
        <div class="row">
            <div class="col-xs-12 table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th align="center">Cantidad</th>
                            <th>Descripción</th>
                            <th>Subtotal</th>
                            <th>Total</th>
                        </tr>                                    
                    </thead>
                    <tbody>
                    <?php
                    $items = $db->select("detalle_factura", "*", ["idFactura" => $_GET["id"]]); 
                    foreach ($items as $item) {
                    ?>
                        <tr>
                            <td align="center"><?=number_format($item["cantidad"], 0)?></td>
                            <td><?=$item["descripcion"]?></td>
                            <td>Bs. <?=number_format($item["montoUnitario"],2,',','.')?></td>
                            <td>Bs. <?=number_format($item["montoTotal"],2,',','.')?></td>
                        </tr>
                    <?php
                        $sub_total = $item["montoTotal"] + $sub_total;
                    }
                    ?>
                    </tbody>
                </table>                            
            </div><!-- /.col -->
        </div><!-- /.row -->

        <div class="row">
            <!-- accepted payments column -->
            <div class="col-xs-6">
                <p class="lead">Metodos de Pago:</p>
                <p class="text-muted well well-sm no-shadow" style="margin-top: 10px;">
                    - Emitir cheque a nombre de Oriantech C.A.<br><br>
                    - Realizar transferencia a nombre de Oriantech C.A.<br>
                    &nbsp;&nbsp;&nbsp;&nbsp;° Número de Cuenta: 0102-0102-12-0102-123456.<br>
                    &nbsp;&nbsp;&nbsp;&nbsp;° Banco: Banesco Banco Universal.<br>
                    &nbsp;&nbsp;&nbsp;&nbsp;° RIF: J-123123123-9<br>
                    &nbsp;&nbsp;&nbsp;&nbsp;° Email: cxc@oriantech.com<br>
                </p>
            </div><!-- /.col -->
            <div class="col-xs-6">
                <p class="lead">Monto a Pagar</p>
                <div class="table-responsive">
                    <table class="table">
                        <tr>
                            <th style="width:50%">Subtotal:</th>
                            <td>Bs. <?=number_format($sub_total,2,',','.')?></td>
                        </tr>
                        <tr>
                            <th>IVA (<?=$data["iva"]?>%)</th>
                            <td>Bs. <?=number_format($impuesto = ($sub_total*($data["iva"]/100)),2,',','.')?></td>
                        </tr>
                        <tr>
                            <th>Total:</th>
                            <td>Bs. <?=number_format($impuesto+$sub_total,2,',','.')?></td>
                        </tr>
                    </table>
                </div>
            </div><!-- /.col -->
        </div><!-- /.row -->

        <!-- this row will not appear when printing -->
        <div class="row no-print">
            <div class="col-xs-12">
                <button class="btn btn-success pull-right"><i class="fa fa-credit-card"></i> Reportar Pago</button>  
                <button class="btn btn-primary pull-right" onclick="window.print();" style="margin-right: 5px;"><i class="fa fa-print"></i> Imprimir</button>
            </div>
        </div>
    </section><!-- /.content -->
</aside>