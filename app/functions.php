<?php

function semicolon_br($str, $trim=false) {
	if ($trim) $str = trim($str, ';');
	return str_replace(';;', '<br>', $str);
}

function nbsps($str) {
	return str_replace('  ', '&nbsp;&nbsp;', $str);
}

function safe_html_attr($string, $escape = true) {
	$unsafe = array('#', '&', '%', '>','<');
	$safe = array('ZHSZ', 'ZAMZ', 'ZPCZ', 'ZGTZ','ZLTZ');

	if ($escape) {
		return str_replace($unsafe, $safe, $string);
	}
	else {
		return str_replace($safe, $unsafe, $string);
	}
	
}

function getURLs($string) {
	//
	preg_match_all('/\b(?:(?:(?:https?|ftp|file):\/\/|www\.|ftp\.)[-A-Z0-9+&@#\/%=~_|$?!:,.]*[A-Z0-9+&@#\/%=~_|$]|[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,6}\b)/im', $string, $result, PREG_PATTERN_ORDER);
	$result = $result[0];
	
	array_walk($result, 'processURLString');
	return array_unique($result);
}

function processURLString($urlString) {
	$urlString = trim($urlString);
	
	if($urlString) {
		$urlString = preg_replace('/https?:\/\//', '', $urlString);
		$urlString = trim($urlString);
		$urlString = 'http://'.$urlString;
	}
	
	return $urlString;
}

function findHeader($headers, $header = 'Location') {
	$results = explode("\r\n", $headers);
	
	foreach($results as $result) {
		if (stripos($result, $header . ':') !== FALSE) {
			list($key, $value) = explode(':', $result, 2);
			return trim($value);
		}
	}
}

function checkURL(&$url, $recursion = 0)
{
	// Simple check
	if (!$url) { return FALSE; }
	
	// Create cURL resource using the URL string passed in
	$curl_resource = curl_init($url);
	
	// Set cURL option and execute the "query"
	curl_setopt($curl_resource, CURLOPT_RETURNTRANSFER, true);
	//curl_setopt($curl_resource, CURLOPT_FOLLOWLOCATION, false);
	curl_setopt($curl_resource, CURLOPT_HEADER, true);
	/* 	curl_setopt($curl_resource, CURLOPT_NOBODY, true); */
	$headers = curl_exec($curl_resource);
	
	$status = curl_getinfo($curl_resource, CURLINFO_HTTP_CODE);
	
	if ($status == 301 || $status == 302) {
		$url = findHeader($headers, 'Location');
		$recursion++;
		if ($recursion < 10) {
			return checkURL($url);
		}
		else {
			return -1;
		}
	}
	
	curl_close($curl_resource);
	
	return $status;
	
/* 	if ($status == 301 || $status == 302) {
		$url = curl_getinfo($curl_resource, CURLINFO_REDIRECT_URL);
	}
	
	return $status; */
	
	//SKIP REST
	
	// Check for the 404 code (page must have a header that correctly display 404 error code according to HTML standards
	if(curl_getinfo($curl_resource, CURLINFO_HTTP_CODE) == 404) {
		// Code matches, close resource and return false
		curl_close($curl_resource);
		return FALSE;
	}
	else {
		// No matches, close resource and return true
		curl_close($curl_resource);
		return TRUE;
	}
	
	// Should never happen, but if something goofy got here, return false value
	return FALSE;
}

function get_sql_columns($table) {

	$db = 'appreq';
	$these_columns = ORM::for_table($table)->raw_query('SHOW COLUMNS FROM `'.$table.'`')->find_array();
	
	$columns = array();
	
	foreach ($these_columns as $col) {
		$columns[] = strtolower($col['Field']);
	}
	
	return $columns;
}

function strtolowerwalk(&$item, $key) {
	$item = strtolower($item);
}

function s1envdb($env) {
	$list = array(
		'TEST' => 'Test (s1test)',
		'PS' => 'ProdSupport (s1prodsupport)',
		'PROD' => 'Production (s1prod)',
		'UAT' => 'UAT (s1uat)',
		'UPGRADE' => 'Upgrade (s1upgrade)'
		);

	if (!isset($list[$env])) return $env;

	return $list[$env];
}

function filter_active_records($var) {
	return !$var->inactive();
}