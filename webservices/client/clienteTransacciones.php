<?php
require_once "../nusoap/nusoap.php";
require_once "../../includes/global.php";

//INICIALIZACION DE VARIABLES Y PARAMETROS
$codOperacion = $_POST["txtCodigoOperacion"];
$nombre = strtoupper($_POST["txtNombre"]);
$email = $_POST["txtEmailCliente"];
$numControl = strtoupper($_POST["txtNumeroFactura"]);
$monto = number_format($_POST["txtMontoFactura"], 2, ".", "");
$idVirtualPoint = $_POST["rdoVirtualPoint"];
$duracionOperaciones = $_SESSION["usuario"]["duracionOperaciones"];
$idUsuario = $_SESSION["usuario"]["id"];
$idCliente = $_SESSION["usuario"]["idCliente"];
$hash = "*E6CC90B878B948C35E92B003C792C46C58C4AF40";

if ( ( $codOperacion == "" ) || ( $nombre == "" ) || ( $email == "" ) || ( $numControl == "" ) || ( $monto == "" ) || ( $idVirtualPoint == "" ) || ( $duracionOperaciones == "" ) || ( $idUsuario == "" ) || ( $idCliente == "" ) ) 
{

    setNotificacion( $mensajeTransacciones["errors"][2], "error");
    header("location: ../../home.php");

}

$cliente = new nusoap_client($urlWebServiceServer . "transacciones.wsdl", true);

/*$insertLocal = $db->insert("operaciones_h", [
                                "codOperacion" => $codOperacion, 
                                "nombre" => $nombre, 
                                "email" => $email, 
                                "numControl" => $numControl, 
                                "monto" => $monto, 
                                "idVirtualPoint" => $idVirtualPoint, 
                                "duracionOperaciones" => $duracionOperaciones, 
                                "idUsuario" => $idUsuario, 
                                "idCliente" => $idCliente, 
                                "#fecCreacion" => "NOW()",
                                "estatus" => "1",
                                ]);*/

$result = $cliente->call( "fnGenerica", array( 
                                                "codOperacion" => $codOperacion, 
                                                "nombre" => $nombre, 
                                                "email" => $email, 
                                                "numControl" => $numControl, 
                                                "monto" => $monto, 
                                                "idVirtualPoint" => $idVirtualPoint, 
                                                "duracionOperaciones" => $duracionOperaciones, 
                                                "idUsuario" => $idUsuario, 
                                                "idCliente" => $idCliente, 
                                                "hashValidate" => $hash ) );
  
if ( $cliente->fault ) {
    
    echo "<h2>Fault</h2><pre>";
    print_r($result);
    echo "</pre>";

} else 
{
    
    $error = $cliente->getError();
    
    if ( $error ) 
    {
     
        setNotificacion( $mensajeTransacciones["errors"][4], "error");
        //setNotificacion( $error, "error"); //MOSTRAR ERROR REAL
        header("location: ../../home.php");
    
    } else 
    {

        
        //SE RECIBEN LOS DATOS DESDE EL WEB SERVICE Y SE DECODIFICA EL ARREGLO JSON 
        $datos = json_decode( $result );
        
        //SI ES UN MENSAJE SATISFACTORIO SE MUESTRA Y SE REDIRECCIONA
        if ( isset($datos->success) )
        {

            setNotificacion($mensajeTransacciones["success"][$datos->success], "success");
            header("location: ../../home.php?e=3");

        //SI ES UN MENSAJE DE ERROR SE MUESTRA Y SE REDIRECCIONA
        } else {

            setNotificacion($mensajeTransacciones["errors"][$datos->errors], "error");
            header("location: ../../home.php");

        }

    }
}
