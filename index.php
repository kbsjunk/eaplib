<?php

define('TESTSITE', false);
define('DEV', false);

date_default_timezone_set('Australia/Melbourne');

define('S1ENV', 's1test');
error_reporting(DEV ? E_ALL : 0);
/* ------------------------------------------------- */
require 'vendor/autoload.php';
require 'app/functions.php';

/* ------------------------------------------------- */
// Configure Idiorm
	ORM::configure('mysql:host=localhost;dbname=eaplib'); //SET THIS
	ORM::configure('username', 'root'); //SET THIS
	ORM::configure('password', ''); //SET THIS

// Start Slim.
$app = new \Slim\Slim(
	array(
		'view' => new \Slim\Views\Twig,
		'log.writer' => new \kitbs\SlimLog\SlimLogWriter(array(
			'path' => './logs',
			'name_format' => 'Y-m-d',
			'message_format' => '%label% - %date% - %message%'
			))
		)
	);

$view = $app->view();
$view->parserExtensions = array(
	new \Slim\Views\TwigExtension(),
	new \kitbs\SlimTwigExts\SlimTwigExts(),
	);

/* ------------------------------------------------- */
// Require Routes
require 'app/routes.php';

/* ------------------------------------------------- */
// Run Application
$app->run();

die();

/* ------------------------------------------------- */
// Dump SQL Log
echo '<pre style="width:100%;word-wrap:normal;">';
print_r(ORM::get_query_log());
echo '</pre>';