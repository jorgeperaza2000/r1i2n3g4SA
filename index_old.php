<?php
include "includes/cookies.php";
$language = getCookie();
if ( $language == "" ) {
	$language = "en";
}
include "lang/" . $language . ".php";
?>
<!DOCTYPE html>
<html class="bg-black">
    <head>
        <meta charset="UTF-8">
        <title><?=$lang["general"]["tit_module"];?>Card Club C.A.</title>
        <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
        <!-- jQuery 2.0.2 -->
        <script src="js/jquery.min.js"></script>
        <!-- Bootstrap -->
        <script src="js/bootstrap.min.js" type="text/javascript"></script>
        <!-- Funciones javascripts genericas -->
        <script src="js/functions.js"></script>
             
        <!-- bootstrap 3.0.2 -->
        <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />
        <!-- font Awesome -->
        <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />
        <!-- Theme style -->
        <link href="css/AdminLTE.css" rel="stylesheet" type="text/css" />

        <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
        <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
        <!--[if lt IE 9]>
          <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
          <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
        <![endif]-->
    </head>
    <body class="bg-black">
    	
        <div class="form-box" id="login-box">
            
            <div class="header"><?=$lang["login"]["tit_sign_in"];?></div>
            
            <form action="principal.php" method="post">

                <div class="body bg-gray">
                	
                	<div class="form-language">
                        <div class="sep-language">
                       		<img src="img/vzla.png" <?=($language == "es")?'':'class="desaturada"';?> width="55" id="es">
                       		<p>Español</p>
                       	</div>
                       	<div class="sep-language">
                        	<img src="img/usa.png" <?=($language == "en")?'':'class="desaturada"';?> width="50" id="en">
                        	<p>English</p>
                        </div>
                    </div>
                	<div class="form-language">                	
	                    <div class="form-group">
	                        <input type="text" name="userid" class="form-control" placeholder="<?=$lang["login"]["txt_th_user"];?>"/>
	                    </div>
	                    <div class="form-group">
	                        <input type="password" name="password" class="form-control" placeholder="<?=$lang["login"]["txt_th_pass"];?>"/>
	                    </div>          
	                    <div class="form-group">
	                        <input type="checkbox" name="remember_me"/> <?=$lang["login"]["chk_remember_me"];?>
	                    </div>
                     </div>
                     
                </div>

                <div class="footer">                                                               
                    <button type="submit" class="btn bg-olive btn-block"><?=$lang["login"]["btn_sign_me_in"];?></button>  
                    <p><a href="#"><?=$lang["login"]["lnk_forgot_pass"];?></a></p>
                </div>

            </form>

        </div>
	    <div class="wait-box" id="wait-box">
	    	<div class="wait-box-children" id="wait-box-children">
		    	<img src="img/loading-blue.gif" width="120" />
		    </div>
	    </div>
		
    </body>
</html>