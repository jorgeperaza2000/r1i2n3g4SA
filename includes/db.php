<?php
include 'medoo.php';
$db = new medoo([
	'database_type' => 'mysql',
	'database_name' => 'r1i2n3g4pro',
	'server' => 'localhost',
	'username' => 'root',
	'password' => '',
	'charset' => 'utf8',
	'port' => 3306,
	'option' => [ PDO::ATTR_CASE => PDO::CASE_NATURAL]
]);
require 'global.php';
?>