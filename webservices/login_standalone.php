<?php
/*
DESCRIPCION: WEB SERVICE DE INICIO DE SESION PARA LAS ESTACIONES STANDALONE DE RING.
EN ESTE MODULO SE CENTRALIZAN LOS LOGIN EN UNA BASE DE DATOS CENTRAL, PARA ASI TENER UN CONTROL DEL MANTENIMIENTO DE LOS USUARIOS POR CLIENTE.
AUTOR: JORGE PERAZA
EMAIL: JORGEM_PERAZA@HOTAMIL.COM
*/
session_start();
//header('Content-Type: application/xml; charset=utf-8');
include '../includes/db.php';

$mensajeSistema = [];
array_push($mensajeSistema, 
            "Login Exitoso", 
            "Usuario bloqueado por el sistema", 
            "Usuario inactivo", 
            "Hash invalido", 
            "Hash no existe en el sistema", 
            "Usuario o clave invalido", 
            "Sistema en mantenimiento"
           );

/*
SE RECIBE Y VALIDA EL HASH QUE IDENTIFICA AL EQUIPO EL CUAL HACE LA PETICION AL WEB SERVICE
*/

//INICIO DATOS DE PRUEBA
$_POST["hashClient"] = '*E6CC90B878B948C35E92B003C792C46C58C4AF40';
$_POST["user"] = "admin";
$_POST["pass"] = "ximplex";
//FIN DATOS DE PRUEBA

$hashValidate = $_POST["hashClient"];

if ( isValidMd5( $hashValidate ) == true ) //ES UN HASH VALIDO
{
    /*
    SE BUSCA EL CLIENTE DUEÑO DEL HASH PARA CONTINUAR CON EL PROCESO DE LOGIN DEL USUARIO
    */    
    $existHash = $db->count( "hash_clientes", "*", ["hashCliente" => $hashValidate] );
    if ( $existHash ) //SI EXISTE EL HASH SE PROCEDE CON EL PROCESO DE LOGIN
    {
        /*
        SE RECIBE Y VALIDA LA CADENA CON DATOS PARA EL LOGIN DEL USUARIO
        */
        $user = $_POST["user"];
        $pass = $_POST["pass"];
        $login = [];
        $login = $db->get( "usuarios", "*", 
                            ["AND" => 
                                [
                                "usuario" => $user,
                                "clave" => $pass
                                ]
                            ]
                        );
        if ( $login )
        {
            if ( $login["estatus"] == 0 )
            {
                $login = [];
                $login["idMensaje"] = "2";
                $login["mensaje"] = $mensajeSistema[$login["idMensaje"]];
                responseData( $login );
            } else if ( $login["estatus"] == 1 )
            {
                $login["idMensaje"] = "0";
                $login["mensaje"] = $mensajeSistema[$login["idMensaje"]];
                responseData( $login );
            } else if ( $login["estatus"] == 2 )
            {
                $login = [];
                $login["idMensaje"] = "1";
                $login["mensaje"] = $mensajeSistema[$login["idMensaje"]];
                responseData( $login );
            } 
        } else 
        {
            $login["idMensaje"] = "5";
            $login["mensaje"] = $mensajeSistema[$login["idMensaje"]];
            responseData( $login );
        }
    } else 
    {
        $login["idMensaje"] = "4";
        $login["mensaje"] = $mensajeSistema[$login["idMensaje"]];
        responseData( $login );
    }
} else 
{
    $login["idMensaje"] = "3";
    $login["mensaje"] = $mensajeSistema[$login["idMensaje"]];
    responseData( $login );
}

function responseData( $arrayData = null )
{
    if ( count( $arrayData ) ) 
    {
        echo json_encode( $arrayData );
    }
}

function isValidMd5( $md5 = "" ) 
{
    if ( ( strlen( $md5 ) == 41 ) && ( substr( $md5, 0, 1 ) == "*" ) ) 
    {
        return true;
    } 
    else 
    {
        return false;
    }
}
