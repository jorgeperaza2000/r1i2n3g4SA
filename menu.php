<?php
function activaMenu( $seccion, $valor ) {
	if ( $seccion == $valor ) {
		return "active";
	}
}
?>
<section class="sidebar">
    <!-- Sidebar user panel -->
    <div class="user-panel">
        
    </div>
    <!-- search form 
    <form action="#" method="get" class="sidebar-form">
        <div class="input-group">
            <input type="text" name="q" class="form-control" placeholder="Buscar..."/>
            <span class="input-group-btn">
                <button type='submit' name='seach' id='search-btn' class="btn btn-flat"><i class="fa fa-search"></i></button>
            </span>
        </div>
    </form>-->
    <!-- /.search form -->
    <!-- sidebar menu: : style can be found in sidebar.less -->
    <ul class="sidebar-menu">
        <li class="<?=activaMenu($_SESSION["seccion"], 0)?>">
            <a href="home.php">
                <i class="fa fa-line-chart"></i> <span>Ventas en Proceso</span>
            </a>
        </li>
        <?php
        if ( $_SESSION["usuario"]["idTipoUsuario"] != 4 ) {
        ?>
        <li class="<?=activaMenu($_SESSION["seccion"], 1)?>">
            <a href="home.php?s=<?=cNuevaVenta;?>">
                <i class="fa fa-credit-card"></i> <span>Nueva Venta</span>
            </a>
        </li>
        <?php
        }
        ?>
        <li class="<?=activaMenu($_SESSION["seccion"], 6)?>">
            <a href="home.php?s=<?=cOperaciones?>">
                <i class="fa fa-line-chart"></i> <span>Historico de Ventas</span>
            </a>
        </li>
        <?php
        if ( $_SESSION["usuario"]["idTipoUsuario"] == 1 ) {
        ?>
            <li class="treeview <?=activaMenu($_SESSION["seccion"], 2)?>">
                <a href="#">
                    <i class="fa fa-suitcase"></i>
                    <span>Clientes</span>
                    <i class="fa fa-angle-left pull-right"></i>
                </a>
                <ul class="treeview-menu">
                    <li><a href="home.php?s=<?=cClientes;?>"><i class="fa fa-angle-double-right"></i> Buscar</a></li>
                    <li><a href="home.php?s=<?=cAddClientes;?>"><i class="fa fa-angle-double-right"></i> Crear</a></li>
                </ul>
            </li>
            <li class="treeview <?=activaMenu($_SESSION["seccion"], 3)?>">
                <a href="#">
                    <i class="fa fa-user"></i>
                    <span>Usuarios</span>
                    <i class="fa fa-angle-left pull-right"></i>
                </a>
                <ul class="treeview-menu">
                    <li><a href="home.php?s=<?=cUsuarios;?>"><i class="fa fa-angle-double-right"></i> Buscar</a></li>
                    <li><a href="home.php?s=<?=cAddUsuarios;?>"><i class="fa fa-angle-double-right"></i> Crear</a></li>
                </ul>
            </li>
            <li class="treeview <?=activaMenu($_SESSION["seccion"], 4)?>">
                <a href="#">
                    <i class="fa fa-user"></i>
                    <span>Bancos</span>
                    <i class="fa fa-angle-left pull-right"></i>
                </a>
                <ul class="treeview-menu">
                    <li><a href="home.php?s=<?=cBancos;?>"><i class="fa fa-angle-double-right"></i> Buscar</a></li>
                    <li><a href="home.php?s=<?=cAddBancos;?>"><i class="fa fa-angle-double-right"></i> Crear</a></li>
                </ul>
            </li>
            <li class="treeview <?=activaMenu($_SESSION["seccion"], 5)?>">
                <a href="#">
                    <i class="fa fa-user"></i>
                    <span>Puntos Virtuales</span>
                    <i class="fa fa-angle-left pull-right"></i>
                </a>
                <ul class="treeview-menu">
                    <li><a href="home.php?s=<?=cVirtualPoints;?>"><i class="fa fa-angle-double-right"></i> Buscar</a></li>
                    <li><a href="home.php?s=<?=cAddVirtualPoints;?>"><i class="fa fa-angle-double-right"></i> Crear</a></li>
                </ul>
            </li>
        <?php
        }
        ?>
        <li class="treeview <?=activaMenu($_SESSION["seccion"], 7)?>">
            <a href="#">
                <i class="fa fa-user"></i>
                <span>Reportes</span>
                <i class="fa fa-angle-left pull-right"></i>
            </a>
            <ul class="treeview-menu">
                <li><a href="home.php?s=<?=cReporteGeneral;?>"><i class="fa fa-angle-double-right"></i> General</a></li>
            </ul>
        </li>
        <?php
        if ( $_SESSION["usuario"]["idTipoUsuario"] <= 2 ) {
        ?>
            <li class="treeview <?=activaMenu($_SESSION["seccion"], 10)?>">
                <a href="#">
                    <i class="fa fa-user"></i>
                    <span>Estado de Cuenta</span>
                    <i class="fa fa-angle-left pull-right"></i>
                </a>
                <ul class="treeview-menu">
                    <li><a href="home.php?s=<?=cEstadoCuenta;?>"><i class="fa fa-angle-double-right"></i> Ver</a></li>
                </ul>
            </li>
        <?php
        }
        ?>
        
        <!--<li class="treeview">
            <a href="#">
                <i class="fa fa-laptop"></i>
                <span>UI Elements</span>
                <i class="fa fa-angle-left pull-right"></i>
            </a>
            <ul class="treeview-menu">
                <li><a href="pages/UI/general.html"><i class="fa fa-angle-double-right"></i> General</a></li>
                <li><a href="pages/UI/icons.html"><i class="fa fa-angle-double-right"></i> Icons</a></li>
                <li><a href="pages/UI/buttons.html"><i class="fa fa-angle-double-right"></i> Buttons</a></li>
                <li><a href="pages/UI/sliders.html"><i class="fa fa-angle-double-right"></i> Sliders</a></li>
                <li><a href="pages/UI/timeline.html"><i class="fa fa-angle-double-right"></i> Timeline</a></li>
            </ul>
        </li>
        <li class="treeview">
            <a href="#">
                <i class="fa fa-edit"></i> <span>Forms</span>
                <i class="fa fa-angle-left pull-right"></i>
            </a>
            <ul class="treeview-menu">
                <li><a href="pages/forms/general.html"><i class="fa fa-angle-double-right"></i> General Elements</a></li>
                <li><a href="pages/forms/advanced.html"><i class="fa fa-angle-double-right"></i> Advanced Elements</a></li>
                <li><a href="pages/forms/editors.html"><i class="fa fa-angle-double-right"></i> Editors</a></li>
            </ul>
        </li>
        <li class="treeview">
            <a href="#">
                <i class="fa fa-table"></i> <span>Tables</span>
                <i class="fa fa-angle-left pull-right"></i>
            </a>
            <ul class="treeview-menu">
                <li><a href="pages/tables/simple.html"><i class="fa fa-angle-double-right"></i> Simple tables</a></li>
                <li><a href="pages/tables/data.html"><i class="fa fa-angle-double-right"></i> Data tables</a></li>
            </ul>
        </li>
        <li>
            <a href="pages/calendar.html">
                <i class="fa fa-calendar"></i> <span>Calendar</span>
                <small class="badge pull-right bg-red">3</small>
            </a>
        </li>
        <li>
            <a href="pages/mailbox.html">
                <i class="fa fa-envelope"></i> <span>Mailbox</span>
                <small class="badge pull-right bg-yellow">12</small>
            </a>
        </li>
        <li class="treeview">
            <a href="#">
                <i class="fa fa-folder"></i> <span>Examples</span>
                <i class="fa fa-angle-left pull-right"></i>
            </a>
            <ul class="treeview-menu">
                <li><a href="pages/examples/invoice.html"><i class="fa fa-angle-double-right"></i> Invoice</a></li>
                <li><a href="pages/examples/login.html"><i class="fa fa-angle-double-right"></i> Login</a></li>
                <li><a href="pages/examples/register.html"><i class="fa fa-angle-double-right"></i> Register</a></li>
                <li><a href="pages/examples/lockscreen.html"><i class="fa fa-angle-double-right"></i> Lockscreen</a></li>
                <li><a href="pages/examples/404.html"><i class="fa fa-angle-double-right"></i> 404 Error</a></li>
                <li><a href="pages/examples/500.html"><i class="fa fa-angle-double-right"></i> 500 Error</a></li>
                <li><a href="pages/examples/blank.html"><i class="fa fa-angle-double-right"></i> Blank Page</a></li>
            </ul>
        </li>
        <li>
            <a href="home.php?s=<?=cMailBox?>">
                <i class="fa fa-envelope"></i> <span>Mailbox</span>
	        </a>
        </li>-->
    </ul>
</section>