$(document).ready(function(){
	//AL PRESIONAR EL BOTON REFRECAR VENTAS
	$("#btnRefrescar").bind("click", function(){
		location.reload();
	});
	
	$("#cmbEstado").change(function () {
		$("#cmbEstado option:selected").each(function () {
			idEstado = $(this).val();
			$("#cmbMunicipio").html('<option>Espere...</option>');
			$("#cmbMunicipio").prop('disabled', true);
			$.post("includes/functions.php?op=cargaComboCiudad", { idEstado: idEstado }, function(data){
				$("#cmbMunicipio").prop('disabled', false);
				$("#cmbMunicipio").html(data);
			});     
		});
	});
	
	if ( $(".notifications").length )
	{
		
		setTimeout(function() {
	        $(".notifications").fadeOut(1500);
	    },3000);
	}
	
});