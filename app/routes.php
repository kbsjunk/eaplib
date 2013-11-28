<?php

define('URL_CHARS_ALLOWED', '[-.\w\+>%]+');

function getAllTags() {
	return Model::factory('Tag')->select('tag')->distinct()->order_by_asc('tag')->find_many();
}

// Home
$app->get('/', function() use ($app) {

	$app->render('home.twig', array(
		'current_environment' => s1envdb(Options::get('current_environment')),
		'last_import' => date('g:i a \o\n j F Y', strtotime(Options::get('last_import')))
		));
	
})->name('home');

$app->notFound(function () use ($app) {
	$app->render('error.404.twig');
});

/* ------------------------------------------------- */

// Application Requirements
$app->get('/app_reqs', function() use ($app) {

	$app_reqs = Model::factory('App_Req')->with('doc_reqs', 'tags')->order_by_desc('active_fg')->order_by_asc('app_rqmnt_cd')->find_many();//->limit($per_page)->offset(10)
	return $app->render('app_req.list.twig', array('app_reqs' => $app_reqs));
	
})->name('app_reqs');

// Application Requirement Detail
$app->get('/app_req/(:app_req)', function($app_req = false) use ($app) {
	$app_req = Model::factory('App_Req')->with('spk_cats')->find_one($app_req);
	
	if (! $app_req->id() ) {
		$app->notFound();
	}
	return $app->render('app_req.detail.twig', array('app_req' => $app_req, 'all_tags' => getAllTags()));//);//
})->name('app_req')->conditions(array('app_req' => URL_CHARS_ALLOWED));

$app->post('/sub_req', function() use ($app) {
	
	$post = $app->request()->post();
	
	$app_rqmnt_cd = htmlspecialchars_decode(safe_html_attr($post['app_rqmnt_cd'], false));

	$sub_reqs = Model::factory('Sub_Req')
	->where('app_rqmnt_cd', $app_rqmnt_cd)
	->where('response_field_id', $post['response_field_id'])
	->find_many();
	
	$add_reqs = array();
	
	foreach ($sub_reqs as $sub_req) {
		if (
			($sub_req->crit_op == 'INCL' && preg_match('/(^|,)'.trim($post['crit_value'],',').'(,|$)/im', $sub_req->crit_value)) ||
			($sub_req->crit_op == 'EXCL' && !preg_match('/(^|,)'.trim($post['crit_value'],',').'(,|$)/im', $sub_req->crit_value))
			)
		{
			$add_reqs[] = $sub_req->sub_req_crt_grp;
		}
	}

	if (count($add_reqs)) {

		$app_reqs = Model::factory('App_Req')
		->where('parent_app_rqmnt_cd', htmlspecialchars_decode($app_rqmnt_cd))
		->where_in('sub_req_crt_grp', $add_reqs)
		->find_many();

		return $app->render('eapp.sub_req.twig', array('app_reqs' => $app_reqs));
	}

})->name('sub_req');

$app->post('/app_req_rspn', function() use ($app) {
	
	$post = $app->request()->post();
	
	$app_rqmnt_cd = htmlspecialchars_decode(safe_html_attr($post['app_rqmnt_cd'], false));

	$app_req = Model::factory('App_Req')->find_one($app_rqmnt_cd);
	
	if ($app_req->id() ) {
		
		if ($app_req->max_number_responses > $post['rspn_count']) {
			return $app->render('eapp.usr_fld.twig', array('app_req' => $app_req));
		}
	}
	
})->name('app_req_rspn');

/* ------------------------------------------------- */

// Tags AJAX
$app->post('/tags/(:rec_type)/(:rec_cd)', function($rec_type = false, $rec_cd = false) use ($app) {
	
	$rec_type = str_replace(' ', '_', ucwords(str_replace('_',' ',$rec_type)));
	$the_rec = Model::factory($rec_type)->find_one($rec_cd);
	
	if (! $the_rec->id() ) {
		$app->notFound();
	}
	
	$add_tags = $app->request()->post('tags');
	$has_tags = $the_rec->tags()->find_many();
	
	$delete_tags = array();
	
	foreach ($has_tags as $tag) {
		if (in_array($tag->tag, $add_tags)) {
			$add_tags = array_diff($add_tags, array($tag->tag));
		}
		else {
			//$delete_tags[] = $has_tag->tag;
			$tag->delete();
		}
	}
	
	foreach ($add_tags as $tag) {
		$new_tag = Model::factory('Tag')->create();
		$new_tag->rec_type = strtolower($rec_type);
		$new_tag->rec_cd = $rec_cd;
		$new_tag->tag = $tag;
		$new_tag->save();
	}
	
	
})->name('post_tags')->conditions(array('rec_cd' => URL_CHARS_ALLOWED));;

$app->get('/tags', function() use ($app) {
	
	return $app->render('tags.list.twig', array('tags' => getAllTags()));
	
})->name('tags')->conditions(array('tag' => URL_CHARS_ALLOWED));;;

$app->get('/tag/(:tag)', function($tag = false) use ($app) {
	$tags = Model::factory('Tag')->where('tag', $tag)->find_many();

	return $app->render('tag.detail.twig', array('tags' => $tags, 'tag' => $tag));
})->name('tag')->conditions(array('tag' => URL_CHARS_ALLOWED));

/* ------------------------------------------------- */

// Document Requirements
$app->get('/doc_reqs', function() use ($app) {
	
	$doc_reqs = Model::factory('Doc_Req')->with('tags')->order_by_desc('active_fg')->order_by_asc('doc_rqmnt_cd')->find_many();
	return $app->render('doc_req.list.twig', array('doc_reqs' => $doc_reqs));
	
})->name('doc_reqs');

// Document Requirement Detail
$app->get('/doc_req/(:doc_req)', function($doc_req = false) use ($app) {
	$doc_req = Model::factory('Doc_Req')->find_one($doc_req);
	
	if (! $doc_req->id() ) {
		$app->notFound();
	}
	return $app->render('doc_req.detail.twig', array('doc_req' => $doc_req, 'all_tags' => getAllTags()));
})->name('doc_req')->conditions(array('doc_req' => URL_CHARS_ALLOWED));

/* ------------------------------------------------- */

// Standard Codes
$app->get('/std_cds', function() use ($app) {
	
	$std_cds = Model::factory('Std_Cd')->with('tags')->order_by_asc('code_type')->find_many();
	return $app->render('std_cd.list.twig', array('std_cds' => $std_cds));
	
})->name('std_cds');

// Standard Code Detail
$app->get('/std_cd/(:std_cd)', function($std_cd = false) use ($app) {
	$std_cd = Model::factory('Std_Cd')->with('app_reqs')->find_one($std_cd);
	
	if (! $std_cd->id() ) {
		$app->notFound();
	}
	
	return $app->render('std_cd.detail.twig', array('std_cd' => $std_cd, 'all_tags' => getAllTags()));
})->name('std_cd')->conditions(array('std_cd' => URL_CHARS_ALLOWED));

/* ------------------------------------------------- */

// Confirmation Emails
$app->get('/cnf_ems', function() use ($app) {
	
	$cnf_ems = Model::factory('Cnf_Em')->with('tags')->order_by_asc('eap_rspns_cd')->find_many();
	return $app->render('cnf_em.list.twig', array('cnf_ems' => $cnf_ems));
	
})->name('cnf_ems');

// Confirmation Email Details
$app->get('/cnf_em/(:cnf_em)', function($cnf_em = false) use ($app) {
	$cnf_em = Model::factory('Cnf_Em')->find_one($cnf_em);

	if (! $cnf_em->id() ) {
		$app->notFound();
	}
	
	return $app->render('cnf_em.detail.twig', array('cnf_em' => $cnf_em, 'all_tags' => getAllTags()));
})->name('cnf_em')->conditions(array('cnf_em' => URL_CHARS_ALLOWED));

/* ------------------------------------------------- */

// Study Package Codes
$app->get('/spk_cds', function() use ($app) {
	
	$spk_cds = Model::factory('Spk_Cd')->with(array('spk_vers'=>array('with'=>'customised')))->where('self_apply_fg', 'Y')->order_by_asc('spk_cd')->find_many();
	return $app->render('spk_cd.list.twig', array('spk_cds' => $spk_cds));
	
})->name('spk_cds');

// Study Package Code Detail
$app->get('/spk_cd/(:spk_cd(/:spk_ver))', function($spk_cd = false, $spk_ver = false) use ($app) {
	
	
	if ($spk_ver) { 
		$spk_cd = Model::factory('Spk_Ver')->find_one($spk_cd.'/'.$spk_ver);
	}
	else {
		$spk_cd = Model::factory('Spk_Ver')->where('spk_cd', $spk_cd)->order_by_desc('spk_ver_no')->find_one();
	}
	
	if (! $spk_cd->id() ) {
		$app->notFound();
	}
	
	if (!$spk_ver) $app->redirect($app->urlFor('spk_cd').$spk_cd->spk_cd.'/'.$spk_cd->spk_ver_no);
	
	return $app->render('spk_cd.detail.twig', array('spk_cd' => $spk_cd));
})->name('spk_cd')->conditions(array('spk_cd' => URL_CHARS_ALLOWED, 'spk_ver' => '\d'));

/* ------------------------------------------------- */

// Study Package Category Types
$app->get('/spk_cats', function() use ($app) {
	
	$spk_cats = Model::factory('Spk_Cat')->with('customised')->order_by_asc('spk_cat_type_cd')->find_many();
	return $app->render('spk_cat.list.twig', array('spk_cats' => $spk_cats));
	
})->name('spk_cats');

// Study Package Category Type Detail
$app->get('/spk_cat/(:spk_cat)', function($spk_cat = false) use ($app) {
	
	$spk_cat = Model::factory('Spk_Cat')->find_one($spk_cat);
	
	if (! $spk_cat->id() ) {
		$app->notFound();
	}
	
	return $app->render('spk_cat.detail.twig', array('spk_cat' => $spk_cat));
})->name('spk_cat')->conditions(array('spk_cat' => URL_CHARS_ALLOWED));

/* ------------------------------------------------- */

// Study Package Category Types
$app->get('/inst', function() use ($app) {
	$inst_app_reqs = Model::factory('Inst_App_Req')->with(
		array(
			'app_req' => array(
				'with' => 'doc_reqs,dsp_crts,usr_flds'
				),
			)
		)->find_many();
	$inst_cnf_ems = Model::factory('Inst_Cnf_Em')->with(
		array(
			'cnf_em' => array(
				'with' => 'dsp_crts'
				),
			)
		)->find_many();
	return $app->render('inst.detail.twig', array(
		'inst_app_reqs_' => $inst_app_reqs,
		'inst_cnf_ems_' => $inst_cnf_ems
		));
	
})->name('inst');

/* ------------------------------------------------- */

// SQL Queries
$app->get('/sql_queries', function() use ($app) {
	
	$sql_queries = Model::factory('SQL_Query')->order_by_asc('output_file')->find_many();
	return $app->render('sql_queries.list.twig', array('sql_queries' => $sql_queries));
	
})->name('sql_queries');

// SQL Query Detail
$app->get('/sql_query/(:sql_query)', function($sql_query = false) use ($app) {
	$sql_query = Model::factory('SQL_Query')->find_one($sql_query);
	
	if (! $sql_query->id() ) {
		$app->notFound();
	}
	
	return $app->render('sql_queries.detail.twig', array('sql_query' => $sql_query));
})->name('sql_query')->conditions(array('sql_query' => URL_CHARS_ALLOWED));

// Saved Script generation

$app->get('/stored_script', function() use ($app) {
	
	$sql_queries = Model::factory('SQL_Query')->order_by_asc('output_file')->find_many();
	$app->response()->header('Content-Type', 'text/plain;charset=utf-8');

	return $app->render('stored_script.twig', array(
		'sql_queries' => $sql_queries,
		'export_folder' => $app->request()->get('export_folder'),
		));
	
})->name('stored_script');

$app->get('/export', function() use ($app) {
	
	$sql_queries = Model::factory('SQL_Query')->order_by_asc('output_file')->find_many();

	return $app->render('export.form.twig', array(
		'sql_queries' => $sql_queries,
		'export_folder' => $app->request()->get('export_folder'),
		));

})->name('export');

// Import

$app->get('/import', function() use ($app) {
	
	return $app->render('import.form.twig', array(
		'message' => $app->request()->get('message'),
		'error' => $app->request()->get('error'),
		'logfile' => $app->request()->get('logfile'),
		));
})->name('import');

$app->post('/import', function() use ($app) {

	if (empty($_FILES['uploadfile']['name'])) {
		return $app->redirect($app->urlFor('import').'?error=nofile');
	}
	
	define('UPLOAD_DIR', dirname(__FILE__).'/../uploads/');
	
	$file = $_FILES['uploadfile']['name'];
	$tmpfile = $_FILES['uploadfile']['tmp_name'];

	$filename = preg_replace('@^([A-Z0-9]+[0-9]{14})?eaplib_@im', 'eaplib_', $file);

	$log = $app->getLog();
	$log->getWriter()->settings('name_format', 'Y-m-d_His');
	$log->getWriter()->settings('filename', pathinfo($filename, PATHINFO_FILENAME));

	$logfile = pathinfo($log->getWriter()->filename(), PATHINFO_FILENAME);

	$log->info("==================================================");
	$log->info("Attempting to import $file.");
	$log->info("--------------------------------------------------");

	if (file_exists(UPLOAD_DIR . $file)) {
		$log->warn("File $file has already been uploaded.");
		$log->info("Import of $filename not necessary.");
		$log->info("==================================================");
	}

	$uploadedhash = md5_file($tmpfile);
	
	$existing = glob(UPLOAD_DIR.'eaplib_*.xml');
	
	if (count($existing)) {

		sort($existing);
		$existing = array_pop($existing);
		$existinghash = md5_file($existing);

		if ($uploadedhash == $existinghash) {
			$log->warn("File $file has not been modified since the last import.");
			$log->info("Import of $filename not necessary.");
			$log->info("==================================================");
		}
		
	}

	if (move_uploaded_file($tmpfile, UPLOAD_DIR . $filename) === true) {
		$inputFileName = UPLOAD_DIR . $filename;
	}

	if (!$xml = simplexml_load_file($inputFileName)) {
		$log->fatal("File $file is not a valid XML file.");
		$log->error("Import of $filename unsuccessful.");
		$log->info("==================================================");
		return $app->redirect($app->urlFor('import').'?message=invalid&logfile='.$logfile);
	}

	if (!isset($xml->exportTables->exportTable)) {
		$log->fatal("File $file does not contain an array of tables to import.");
		$log->error("Import of $filename unsuccessful.");
		$log->info("==================================================");
		return $app->redirect($app->urlFor('import').'?message=invalid&logfile='.$logfile);
	}

	if (isset($xml->exportSource)) {

		$dataEnvironment = @$xml->exportSource->environment;
		$dataDate = @$xml->exportSource->date;

		$log->info("Data exported from $dataEnvironment at $dataDate.");
		$log->info("==================================================");
	}

	$log->info("--------------------------------------------------");

	foreach ($xml->exportTables->exportTable as $export) {

		$tableName = $export->tableName;

		$log->info("Importing table $tableName from $file.");

	$firstRowHeaders = true;

	$tableData = str_getcsv(trim(str_replace("\n;;", ";;;;", $export->tableData)), "\n"); //parse the rows

	foreach($tableData as &$tableRow) {
	$tableRow = str_getcsv($tableRow); //parse the items in rows 
}

$sqlHeaders = get_sql_columns($tableName);

if ($firstRowHeaders) {
	$tableHeaders = array_values(array_shift($tableData));
	array_walk($tableHeaders, 'strtolowerwalk');
	array_walk($sqlHeaders, 'strtolowerwalk');

	if (count($sqlHeaders) <> count($tableHeaders)) {
		$log->fatal("The table $tableName in $file contains the wrong number of column headers.\nExpected headers are " . implode(", ", $sqlHeaders) . ".");
	}
	elseif ($sqlHeaders !== $tableHeaders) {
		$log->fatal("The table $tableName in $file contains the wrong column headers.\nExpected headers are " . implode(", ", $sqlHeaders) . ".");
	}
}
else {
	$tableHeaders = $sqlHeaders;
}

$tableHeaders = array_map('strtolower', $tableHeaders);

foreach ($tableData as $index => &$tableRow) {
	if (count($tableRow) <> count($tableHeaders)) {
		echo 'wrongnumcolumns-row '.$index . PHP_EOL;
		$log->warn("- Row $index in table $tableName contains the wrong number of columns.\nExpected " . count($tableHeaders) . " headers, found " . count($tableRow) . ".");
		$log->warn("- Row $index skipped.");
		$tableRow = false;
	}
	else {
		foreach ($tableRow as &$tableValue) {
			$tableValue = ORM::get_db()->quote($tableValue);
		}

		$tableRow = implode(",", $tableRow);
	}
}

$sql = "TRUNCATE $tableName";

$affected = ORM::get_db()->exec($sql);
$log->info("- Existing rows removed from $tableName.");

$tableHeadersString = "`".implode("`, `", $tableHeaders)."`";

$tableChunks = array_chunk($tableData, 200);
$added = 0;

foreach ($tableChunks as $tableRows) {
	$tableRowsString = implode('), (', $tableRows);
	$sql = "INSERT INTO $tableName ($tableHeadersString) VALUES ($tableRowsString)";

	$affected = ORM::get_db()->exec($sql);
	$added = $added + $affected;
	$log->info("- Inserted chunk of $affected rows into $tableName.");
}

$log->info("- Inserted total $added rows into $tableName.");
$log->info("Import of $tableName successful.");
$log->info("--------------------------------------------------");

}

$log->info("Import of $filename successful.");
$log->info("Saved import log file, updated environment variable.");

Options::set('current_environment', $dataEnvironment);
Options::set('last_import', $dataDate);

$log->info("==================================================");

return $app->redirect($app->urlFor('import').'?message=success&logfile='.$logfile);

});


/* ------------------------------------------------- */

$app->get('/urls', function() use ($app) {

	$urls = Model::factory('URL')->order_by_asc('email')->order_by_desc('url')->order_by_asc('rec_cd')->find_many();
	return $app->render('url.list.twig', array('urls' => $urls));
	
})->name('urls');

$app->post('/check_urls/(:rec_type)/(:rec_cd)', function($rec_type = false, $rec_cd = false) use ($app) {
	
	$rec_type = str_replace(' ', '_', ucwords(str_replace('_',' ',$rec_type)));
	$the_rec = Model::factory($rec_type)->find_one($rec_cd);
	
	if (! $the_rec->id() ) {
		$app->notFound();
	}
	
	$add_urls = $the_rec->findURLs();
	$has_urls = $the_rec->urls()->find_many();
	
	$delete_urls = array();
	
	foreach ($has_urls as $url) {
		if (in_array($url->url, $add_urls)) {
			$add_urls = array_diff($add_urls, array($url->url));
			$url->checkURL();
		}
		else {
			$url->delete();
		}
	}
	
	foreach ($add_urls as $url) {
		$new_url = Model::factory('URL')->create();
		$new_url->rec_type = strtolower($rec_type);
		$new_url->rec_cd = $rec_cd;
		$new_url->url = $url;
		$new_url->checkURL();
	}
	
	$has_urls = $the_rec->urls()->find_many();
	return $app->render('url.subdetail.twig', array('urls' => $has_urls));
	
	
})->name('check_urls')->conditions(array('rec_cd' => URL_CHARS_ALLOWED, 'rec_type' => URL_CHARS_ALLOWED));;

// Import Logs
$app->get('/import_log/(:logfile)', function($logfile = false) use ($app) {

	$log = $app->getLog();
	$filename = $log->getWriter()->setting('path') . DIRECTORY_SEPARATOR . $logfile . '.'. $log->getWriter()->setting('extension');
	
	if ( !file_exists($filename)) {
		$app->notFound();
	}

	$logdata = file($filename);

	return $app->render('logfile.detail.twig', array(
		'logfile' => $logfile,
		'logdata' => $logdata,
		));
	
})->name('import_log')->conditions(array('logfile' => URL_CHARS_ALLOWED));

$app->get('/import_logs', function() use ($app) {

	$log = $app->getLog();
	$filepath = $log->getWriter()->setting('path');

	$import_logs = glob($filepath . DIRECTORY_SEPARATOR . '*eaplib*.log');
	
	if (count($import_logs)) {
		sort($import_logs);

		foreach ($import_logs as &$import_log) {
			
			$filename = pathinfo($import_log, PATHINFO_FILENAME);
			
			preg_match('@^(?P<date>[0-9]{4}-[0-9]{2}-[0-9]{2})_[0-9]{6}_(?P<filename>.*)$@', $filename, $match);
			$match['logfile'] = $filename;

			$import_log = $match;
		}
	}
	
	return $app->render('logfile.list.twig', array('import_logs' => $import_logs));
	
})->name('import_logs');
