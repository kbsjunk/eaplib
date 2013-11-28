<?php

class SQL_Query extends Model
{
	public static $_table = 'uom_sql_queries';
	public static $_id_column = 'output_file';
	
	public function query_($use_pre=true, $include_env = true, $close_semicolon=true) {
		$query = $this->query;
		$env = $this->s1env();
		
		$query = str_replace($this->s1envs(), '[ENV]', $query);
		
		if ($include_env && $env) {
			$query = str_replace('[ENV]', $env.'.', $query);
		}
		else {
			$query = str_replace('[ENV]', '', $query);
		}
		
		$query = rtrim(trim($query), ';') . ($close_semicolon ? ';' : false);
		
		SqlFormatter::$use_pre = $use_pre;
		return SqlFormatter::format($query);
	}
	
	public function s1env() {
		global $app;
		$env = $app->request()->get('s1env');
		if ($env == 'none') return false;
		return $env ? $env : S1ENV;
	}
	
	public function s1envs() {
		return array('s1test', 's1uat', 's1prodsupport', 's1prod');//, 's1upgrade', 's1sandbox'
	}
}
