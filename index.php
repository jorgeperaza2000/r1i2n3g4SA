<?php 
include_once "includes/global.php";
?>
<!DOCTYPE html>
<!--[if IE 8]> 				 <html class="no-js lt-ie9" lang="en" > <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en" > <!--<![endif]-->

  <head>  	
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1"> 
	<meta name="description" content="fresh Gray Bootstrap 3.0 Responsive Theme "/>
	<meta name="keywords" content="Template, Theme, web, html5, css3, Bootstrap,Bootstrap 3.0 Responsive Theme" />
	<meta name="author" content="Mindfreakerstuff"/>
    <link rel="shortcut icon" href="favicon.png"> 
    
	<title>Ring - Payment Gateway</title>
    <!-- Bootstrap core CSS -->
    <link href="css/login/bootstrap.css" rel="stylesheet">
    <link href="css/font-awesome.min.css" rel="stylesheet" type="text/css" />

    <!-- Custom styles for this template -->
    <link href="css/login/login.css" rel="stylesheet">
    <link href="css/login/animate-custom.css" rel="stylesheet">
   

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="js/html5shiv.js"></script>
      <script src="js/respond.min.js"></script>
    <![endif]-->
    
  </head>
    <body>
    	<!-- start Login box -->
    	<div class="container" id="login-block">
    		<div class="row">
			    <div class="col-sm-6 col-md-4 col-sm-offset-3 col-md-offset-4">
			       <div class="login-box clearfix animated flipInY">
			        	<div class="login-logo">
			        		<a href="#"><img src="img/ring.png" alt="Logo Ring" /></a>
			        	</div> 
			        	<hr />
			        	<div class="login-form">
			        					        		
                            <?php
                            showNotificacion();
                            ?>
							
			        		<form name="frmLogin" action="<?=$urlWebServiceClient?>clienteLogin.php" method="post"  >
						   		 <input type="text" name="txtUserName" placeholder="Usuario" required/> 
						   		 <input type="password" name="txtPassword" placeholder="Contraseña" required/> 
						   		 <div style="text-align:center; width: 100%; margin-bottom: 10px;"><button type="submit" class="btn btn-primary btn-lg">Aceptar</button></div>
							</form>	
							<div class="login-links"> 
					            <a href="#">
					          	   Olvidó su contraseña?
					            </a>
					            <br />
							</div>      		
			        	</div> 			        	
			       </div>
			    </div>
			</div>
    	</div>
     
      	<!-- End Login box -->
     	<footer class="container">
     		<p id="footer-text"><small>Copyright &copy; 2015 <a href="http://www.oriantech.com/">Oriantech C.A.</a></small></p>
     	</footer>
		
        <script src="js/jquery.min.js"></script>
        <script>window.jQuery || document.write('<script src="js/jquery-1.10.3.min.js"><\/script>')</script> 
        <script src="js/bootstrap.min.js"></script> 
        <script src="js/functions.js"></script> 
    </body>
</html>
