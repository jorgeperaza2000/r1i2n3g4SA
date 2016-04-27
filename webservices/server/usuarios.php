<?php
require_once "../nusoap/nusoap.php";

$server = new soap_server();
$server->configureWSDL( "usuarios", "urn:usuarios" );
  
$server->register( "fnGenerica",
    array( 
            "idUsuario" => "xsd:string",
            "nombre" => "xsd:string",
            "usuario" => "xsd:string", 
            "clave" => "xsd:string", 
            "reclave" => "xsd:string", 
            "extension" => "xsd:string", 
            "tipoUsuario" => "xsd:string", 
            "idCliente" => "xsd:string",
            "accion" => "xsd:string", //1. Crear, 2. Editar, 3. Eliminar
            "hashValidate" => "xsd:string"
         ),
    array( "return" => "xsd:string" ),
    "urn:usuarios",
    "urn:usuarios#fnGenerica",
    "rpc",
    "encoded",
    "Nos permite crear, editar o eliminar un usuario en el sistema." );

$post = file_get_contents( "php://input" );
$server->service( $post );


function fnGenerica( $idUsuario = null, $nombre, $usuario, $clave, $reclave, $extension = null, $tipoUsuario, $idCliente, $accion, $hashValidate ) 
{
    
    require_once "../../includes/db.php";
    
    if ( ( strlen( $hashValidate ) == 41 ) && ( substr( $hashValidate, 0, 1 ) == "*" ) )  //ES UN HASH VALIDO
    {

        $existHash = $db->count( "hash_clientes", "*", ["hashCliente" => $hashValidate] );
        
        if ( $existHash ) //SI EXISTE EL HASH SE PROCEDE CON EL PROCESO DE LOGIN
        {
        
            if ( $accion == 1 ) //Crear
            {

                $datos = $db->insert("usuarios", [
                                            "nombre" => $nombre,
                                            "usuario" => $usuario,
                                            "#clave" => "PASSWORD('" . $clave . "')",
                                            "extension" => $extension,
                                            "idTipoUsuario" => $tipoUsuario,
                                            "idCliente" => $idCliente,
                                            "idUsuario" => 1,//$_SESSION["usuario"]["id"],
                                            "#fecCreacion" => "NOW()",
                                            "estatus" => "1",
                                            "cambioClave" => "1",
                                            ]);
                $respuesta["success"] = 0;
                return json_encode( $respuesta );
                                    
            } else if ( $accion == 2 ) //Editar
            {

                $datos = $db->update("usuarios", [
                                            "nombre" => $nombre,
                                            "usuario" => $usuario,
                                            "#clave" => "PASSWORD('" . $clave . "')",
                                            "extension" => $extension,
                                            "idTipoUsuario" => $tipoUsuario,
                                            "idCliente" => $idCliente,
                                            "idUsuario" => 1,//$_SESSION["usuario"]["id"],
                                            "#fecCreacion" => "NOW()",
                                            "estatus" => "1",
                                            "cambioClave" => "1",
                                            ],
                                            ["id" => $idUsuario ]);
                $respuesta["success"] = 1;
                return json_encode( $respuesta );

            } else if ( $accion == 3 ) //Eliminar
            {

                $datos = $db->delete("usuarios", [ "id" =>  $idUsuario ]);
                
                $respuesta["success"] = 2;
                return json_encode( $respuesta );

            } else if ( $accion == 4 ) //Cambiar estatus
            {

                $datos = $db->query("UPDATE usuarios SET estatus = IF(estatus=1, 0, 1) WHERE id = " . $idUsuario);

                $respuesta["success"] = 1;
                return json_encode( $respuesta );

            }
        } else //El hash no existe en el sistema
        {

            $respuesta["errors"] = 1;
            return json_encode( $respuesta );    

        }
    } else //El hash es invalido
    {
        
        $respuesta["errors"] = 0;
        return json_encode( $respuesta );

    }
}
?>