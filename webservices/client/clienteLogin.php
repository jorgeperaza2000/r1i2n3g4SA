<?php
require_once "../nusoap/nusoap.php";
require_once "../../includes/global.php";

//INICIALIZACION DE VARIABLES Y PARAMETROS
$user = $_POST["txtUserName"];
$password = $_POST["txtPassword"];
$hash = "*E6CC90B878B948C35E92B003C792C46C58C4AF40";

if ( ( $user == "" ) || ( $password == "" ) ) 
{

    setNotificacion( $mensajeLogin["errors"][0], "error");
    header("location: ../../index.php");

}

$cliente = new nusoap_client($urlWebServiceServer . "login.wsdl", true);

$result = $cliente->call( "fnGenerica", array( "usuario" => $user, "clave" => $password, "hashValidate" => $hash ) );
  
if ( $cliente->fault ) {
    
    echo "<h2>Fault</h2><pre>";
    print_r($result);
    echo "</pre>";

} else 
{
    
    $error = $cliente->getError();
    
    if ( $error ) 
    {
     
        setNotificacion( $mensajeLogin["errors"][6], "error");
        //setNotificacion( $error, "error"); //MOSTRAR ERROR REAL
        header("location: ../../index.php");
    
    } else 
    {

        
        //SE RECIBEN LOS DATOS DESDE EL WEB SERVICE Y SE DECODIFICA EL ARREGLO JSON 
        $datos = json_decode( $result );
        
        //SI ES UN MENSAJE SATISFACTORIO SE MUESTRA Y SE REDIRECCIONA
        if ( isset($datos->success) )
        {

            $_SESSION["usuario"]["id"] = $datos->datos->id;
            $_SESSION["usuario"]["nombre"] = $datos->datos->nombre;
            $_SESSION["usuario"]["usuario"] = $datos->datos->usuario;
            $_SESSION["usuario"]["idTipoUsuario"] = $datos->datos->idTipoUsuario;
            $_SESSION["usuario"]["idCliente"] = $datos->datos->idCliente;
            $_SESSION["usuario"]["cliente"] = $datos->datos->cliente;
            $_SESSION["usuario"]["duracionOperaciones"] = $datos->datos->duracionOperaciones;

            header("location: ../../home.php?s=" . cPrincipal);

        //SI ES UN MENSAJE DE ERROR SE MUESTRA Y SE REDIRECCIONA
        } else {

            setNotificacion($mensajeLogin["errors"][$datos->errors], "error");
            header("location: ../../index.php");

        }

    }
}
