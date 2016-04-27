<?php
//WEBSERVICE LOGIN
$mensajeLogin = ["errors" => [], "success" => []];
array_push( $mensajeLogin["errors"], 
            "Por favor, indique su nombre de usuario y clave",
            "Usuario bloqueado por el sistema",
            "Usuario inactivo", 
            "Hash invalido",
            "Hash no existe en el sistema",
            "Usuario o clave invalido",
            "Ocurrio un error, si esto persiste contacte al administrador del sistema",
            "Sistema en mantenimiento"
           );
array_push( $mensajeLogin["success"], 
            "Login exitoso"
           );

//WEBSERVICE USUARIOS
$mensajeUsuarios = ["errors" => [], "success" => []];
array_push( $mensajeUsuarios["errors"], 
            "Hash invalido",
            "Hash no existe en el sistema",
            "Por favor, complete todos los datos obligatorios",
            "Las claves no coinciden, intente nuevamente",
            "No se puedo eliminar el usuario, intente nuevamente",
            "Ocurrio un error, si esto persiste contacte al administrador del sistema",
            "Sistema en mantenimiento"
           );
array_push( $mensajeUsuarios["success"], 
            "Usuario creado con exito",
            "Usuario editado con exito",
            "Usuario eliminado con exito"
           );

//WEBSERVICE USUARIOS
$mensajeTransacciones = ["errors" => [], "success" => []];
array_push( $mensajeTransacciones["errors"], 
            "Hash invalido",
            "Hash no existe en el sistema",
            "Por favor, complete todos los datos obligatorios",
            "Ocurrio un error, si esto persiste contacte al administrador del sistema",
            "Sistema en mantenimiento"
           );
array_push( $mensajeTransacciones["success"], 
            "Transaccion exitosa"
           );