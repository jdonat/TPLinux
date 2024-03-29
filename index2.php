<?php
$pdo = new PDO("mysql:host=localhost;", 'root', '');
$pdo->query("CREATE DATABASE [IF NOT EXISTS] dbTest;");
$pdo->query("USE dbTest;");
$pdo->query("CREATE TABLE [IF NOT EXISTS] tableTest ( ID int, Name varchar(255) );");
$pdo->query("INSERT INTO tableTest ( 1, 'Anonymous' );");
$val = $pdo->query("SELECT * FROM tableTest;");


//$pdo->setAttribute(PDO::MYSQL_ATTR_USE_BUFFERED_QUERY, false);

//$unbufferedResult = $pdo->query("SELECT Name FROM City");
foreach ($val as $row) {
    echo $row['Name'] . PHP_EOL;
}
?>
