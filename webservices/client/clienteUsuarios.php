<?php
require_once "../nusoap/nusoap.php";
require_once "../../includes/global.php";

//INICIALIZACION DE VARIABLES Y PARAMETROS
$idUsuario = isset($_GET["idUsuario"])?$_GET["idUsuario"]:"";
$nombre = isset($_POST["txtNombre"])?$_POST["txtNombre"]:"";
$usuario = isset($_POST["txtUsuario"])?$_POST["txtUsuario"]:"";
$clave = isset($_POST["txtClave"])?$_POST["txtClave"]:"";
$reclave = isset($_POST["txtReClave"])?$_POST["txtReClave"]:"";
$extension = isset($_POST["txtExtension"])?$_POST["txtExtension"]:"";
$tipoUsuario = isset($_POST["cmbTipoUsuario"])?$_POST["cmbTipoUsuario"]:"0";
$idCliente = isset($_POST["cmbCliente"])?$_POST["cmbCliente"]:"0";
$accion = isset($_GET["accion"])?$_GET["accion"]:"";
$hash = "*E6CC90B878B948C35E92B003C792C46C58C4AF40";

//SWITCH PARA VALIDACIONES SEGUN ACCION
switch ( $accion ) {
    case '1': //Crear
        
        if ( ( $nombre == "" ) || ( $usuario == "" ) || ( $clave == "" ) || ( $reclave == "" ) || ( $tipoUsuario == 0 ) || ( $idCliente == 0 ) )
        {

                setNotificacion( $mensajeUsuarios["errors"][2], "error");
                header("location: ../../home.php?s=" . cAddUsuarios);

        } else 
        {

            if ( $clave != $reclave ) 
            {

                setNotificacion( $mensajeUsuarios["errors"][3], "error");
                header("location: ../../home.php?s=" . cAddUsuarios);    

            } else
            {

                $cliente = new nusoap_client($urlWebServiceServer . "usuarios.wsdl", true);

            }

        } 

        break;

    case '2': //Editar
        
        if ( ( $nombre == "" ) || ( $usuario == "" ) || ( $clave == "" ) || ( $reclave == "" ) || ( $tipoUsuario == 0 ) || ( $idCliente == 0 ) )
        {

                setNotificacion( $mensajeUsuarios["errors"][2], "error");
                header("location: ../../home.php?s=" . cEditUsuarios . "&id=" . $idUsuario);    

        } else 
        {

            if ( $clave != $reclave ) 
            {

                setNotificacion( $mensajeUsuarios["errors"][3], "error");
                header("location: ../../home.php?s=" . cEditUsuarios . "&id=" . $idUsuario);

            } else
            {

                $cliente = new nusoap_client($urlWebServiceServer . "usuarios.wsdl", true);

            }

        } 

        break;

    case '3': //Eliminar
        
        if ( $idUsuario == "" ) 
        {

                setNotificacion( $mensajeUsuarios["errors"][5], "error");
                header("location: ../../home.php?s=" . cUsuarios);

        } else 
        {

                $cliente = new nusoap_client($urlWebServiceServer . "usuarios.wsdl", true);

        } 

        break;

    case '4': //Cambio de estatus
        
        if ( $idUsuario == "" ) 
        {

                setNotificacion( $mensajeUsuarios["errors"][5], "error");
                header("location: ../../home.php?s=" . cUsuarios);

        } else 
        {

                $cliente = new nusoap_client($urlWebServiceServer . "usuarios.wsdl", true);

        } 

        break;
    
}

//SE REALIZA EL LLAMADO AL METODO FNGENERICA EN EL WEBSERVICE
$result = $cliente->call("fnGenerica", array("idUsuario" => $idUsuario, "nombre" => $nombre, "usuario" => $usuario, "clave" => $clave, "reclave" => $reclave, "extension" => $extension, "tipoUsuario" => $tipoUsuario, "idCliente" => $idCliente, "accion" => $accion, "hashValidate" => $hash));

//SI FALLA SE IMPRIME EL ERROR
if ( $cliente->fault ) 
{
    
    echo "<h2>Fault</h2><pre>";
    print_r($result);
    echo "</pre>";

} else 
{
    
    //SI OCURRE UN ERROR SE MUESTRA
    $error = $cliente->getError();
    
    if ( $error ) 
    {
     
        header("location: ../../home.php?s=" . cAddUsuarios . "&e=6");
    
    } else 
    {

        //SE RECIBEN LOS DATOS DESDE EL WEB SERVICE Y SE DECODIFICA EL ARREGLO JSON 
        $datos = json_decode( $result );
        //SI ES UN MENSAJE SATISFACTORIO SE MUESTRA Y SE REDIRECCIONA
        if ( isset($datos->success) )
        {
            setNotificacion($mensajeUsuarios["success"][$datos->success], "success");
            header("location: ../../home.php?s=" . cUsuarios);

        //SI ES UN MENSAJE DE ERROR SE MUESTRA Y SE REDIRECCIONA
        } else {

            setNotificacion($mensajeUsuarios["errors"][$datos->errors], "error");
            header("location: ../../home.php?s=" . cUsuarios);

        }

    }

}
