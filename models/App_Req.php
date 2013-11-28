<?php

class App_Req extends Model
{
	public static $_id_column = 'app_rqmnt_cd';
	
	/*	public function href() {
		global $app;
		$cls = strtolower(get_class($this));
		$id = $this->_id_column;
		return $app->urlFor($cls, array($cls => $this->$id));
	}*/

	public function app_rqmnt_cd_() {
		return urlencode(safe_html_attr($this->app_rqmnt_cd));
	}
	
	public function app_rqmnt_descr_() {
		return semicolon_br($this->app_rqmnt_descr, true);
	}
	
	public function app_rqmnt_full_descr_() {
		return semicolon_br($this->app_rqmnt_full_descr, true);
	}
	
	public function parent_app_rqmnt_cd_() {
		return trim($this->parent_app_rqmnt_cd);
	}
	
	public function inactive() {
		return $this->active_fg != 'Y';
	}
	
	public function inherit_inactive() {
		return $this->inherit_active_fg != 'Y';
	}
	
	/*public function inherit_() {
		return strtoupper($this->inherit);
	}*/
	
	// Study Packages
	
	public function spk_cds() {
		return $this->has_many_through('Spk_Ver', 'Spk_App_Req', 'app_rqmnt_cd', 'spk_id')
			->select('spk_app_req.active_fg', 'inherit_active_fg')
			->select_expr('CASE WHEN spk_app_req.active_fg = "N" THEN "spk_cat" ELSE "" END', 'inherit')
			->order_by_asc('spk_cd')
			->order_by_desc('spk_ver_no')
			;
	}
	
	public function spk_cds_() {
			return $this->spk_cds;
	}
	// Study Package Category Types
	
	public function spk_cats() {
		return $this->has_many_through('Spk_Cat', 'Spk_Cat_App_Req', 'app_rqmnt_cd', 'spk_cat_type_cd')
			->select('spk_cat_app_req.active_fg', 'inherit_active_fg')
			->select_expr('CASE WHEN spk_cat_app_req.active_fg = "N" THEN "inst" ELSE "" END', 'inherit')
			->order_by_asc('spk_cat_type_cd')
			;
	}
	public function spk_cats_() {
			return $this->spk_cats;
	}
	
	// Document Requirements
	
	public function doc_reqs() {
		return $this->has_many_through('Doc_Req', 'App_Doc_Req', 'app_rqmnt_cd', 'doc_rqmnt_cd');
	}
	
	public function doc_reqs_() {
		return $this->doc_reqs;
		//return $this->doc_reqs()->find_many();
	}
	
	public function doc_rqmnt_comp_fg_() {
		$list = array(
			'A' => 'All',
			'O' => 'One Of',
			'N' => 'None'
		);
		
		if ($doc_rqmnt_comp_fg = $list[$this->doc_rqmnt_comp_fg]) return $doc_rqmnt_comp_fg;
		return $this->doc_rqmnt_comp_fg;
	}
	
	// User Response Fields
	
	public function usr_flds() {
		return $this->has_many('Usr_Fld', 'app_rqmnt_cd')->order_by_asc('seq_no')->with('std_cd');
	}
	
	public function usr_flds_() {
		// return $this->usr_flds()->order_by_asc('seq_no')->find_many();		
		return $this->usr_flds;
	}
	
	// Display Criteria
	
	public function dsp_crts() {
		return $this->has_many('App_Req_Crt', 'app_rqmnt_cd');
	}
	
	public function dsp_crts_() {
		return $this->dsp_crts;//()->find_many();
	}
	
	public function tags() {
		return $this->has_many('Tag', 'rec_cd')->where('rec_type', 'app_req');
	}
	public function tags_() {
		$all_tags = $this->tags;
		
		$tags = array();
		
		foreach($all_tags as $tag) {
			$tags[] = $tag->tag;
		}
		
		return $tags;
	}	
	
	public function urls() {
		return $this->has_many('URL', 'rec_cd')->where('rec_type', 'app_req')->order_by_desc('email')->order_by_asc('status')->order_by_asc('url');
	}
	public function urls_() {
		return $this->urls;//()->find_many();
	}
	public function findURLs() {
		return getURLs($this->app_rqmnt_full_descr);
	}
	
	public function inherit_() {
		if (isset($this->inherit)) {
			return $this->inherit;
		}
	}
	
	
}

class App_Doc_Req extends Model
{
		
	
}

class App_Req_Crt extends Model
{
	
	public function crit_op_() {
		$list = array(
			'INCL' => 'Is',
			'EXCL' => 'Is Not'
		);
		
		if ($crit_op = $list[$this->crit_op]) return $crit_op;
		return $this->crit_descr;
	}
	
	
}

class Sub_Req extends Model
{
	public static $_table = 'sub_req_crt';
	public static $_id_column = 'app_subreq_crit_id';
	
}