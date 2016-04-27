<?php
session_start();
echo fnGenerica("","","","","","","","1","*E6CC90B878B948C35E92B003C792C46C58C4AF40");

function fnGenerica( $nombre, $usuario, $clave, $reclave, $extension, $tipoUsuario, $idCliente, $accion, $hashValidate ) 
{
    
    require_once "../../includes/db.php";
    
    $datos = $db->debug()->query("UPDATE usuarios SET estatus = IF(estatus=1, 0, 1) WHERE id = " . $idUsuario);
}