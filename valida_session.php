<?php
session_start();
if ( isset( $_SESSION["usuario"]["id"] ) ) {
	echo "1";
} else {
	echo "0";
}
?>
