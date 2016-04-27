<?php
require_once "../nusoap/nusoap.php";

$server = new soap_server();
$server->configureWSDL( "login", "urn:login" );
  
$server->register( "fnGenerica",
    array( "usuario" => "xsd:string", "clave" => "xsd:string", "hashValidate" => "xsd:string" ),
    array( "return" => "xsd:string" ),
    "urn:login",
    "urn:login#fnGenerica",
    "rpc",
    "encoded",
    "Nos permite iniciar o no una sesion en el sistema." );

$post = file_get_contents( "php://input" );
$server->service( $post );


function fnGenerica( $usuario, $clave, $hashValidate ) 
{
    
    require_once "../../includes/db.php";
    
    if ( ( strlen( $hashValidate ) == 41 ) && ( substr( $hashValidate, 0, 1 ) == "*" ) )  //ES UN HASH VALIDO
    {
        
        $existHash = $db->count( "hash_clientes", "*", ["hashCliente" => $hashValidate] );
        
        if ( $existHash ) //SI EXISTE EL HASH SE PROCEDE CON EL PROCESO DE LOGIN
        {

            $user = $usuario;
            $pass = $clave;
            $login = [];
            $logueado = $db->query("SELECT 
                                    u.id,
                                    u.nombre,
                                    u.usuario,
                                    u.extension,
                                    u.estatus,
                                    u.cambioClave,
                                    u.idTipoUsuario,
                                    u.idCliente,
                                    c.nombre cliente,
                                    c.duracionOperaciones
                                FROM 
                                    usuarios u, clientes c 
                                WHERE 
                                    u.idCliente = c.id AND 
                                    u.usuario = '" . $user . "' AND 
                                    u.clave = PASSWORD('" . $pass . "')
                                LIMIT 1")->fetchAll();
            if ( count ( $logueado ) ) {

                $login = $logueado[0];

            } 
            
            if ( count( $login ) )
            {
                
                if ( $login["estatus"] == 0 )
                {
                    
                    $respuesta["errors"] = 2; //Usuario inactivo
                    return json_encode( $respuesta );
                    
                } else if ( $login["estatus"] == 1 )
                {
                    
                    $respuesta["datos"] = $login;
                    $respuesta["success"] = 0; //Login exitoso
                    return json_encode( $respuesta );

                } else if ( $login["estatus"] == 2 )
                {
                    
                    $respuesta["errors"] = 1; //Usuario bloqueado por el sistema
                    return json_encode( $respuesta );

                } 
            } else 
            {
               
                $respuesta["errors"] = 5; //Usuario o clave invalido
                return json_encode( $respuesta );

            }
        } else 
        {
            
            $respuesta["errors"] = 4; //Hash no existe en el sistema
            return json_encode( $respuesta );

        }
    } else 
    {
        
        $respuesta["errors"] = 3; //Hash invalido
        return json_encode( $respuesta );

    }
}
?>