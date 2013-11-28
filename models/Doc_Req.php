<?php

class Doc_Req extends Model
{
	public static $_id_column = 'doc_rqmnt_cd';
	
	public function doc_rqmnt_descr_() {
		return semicolon_br($this->doc_rqmnt_descr, true);
	}
	
	public function doc_rqmnt_full_descr_() {
		return semicolon_br($this->doc_rqmnt_full_descr, true);
	}
	
	public function inactive() {
		return $this->active_fg != 'Y';
	}

	public function app_reqs() {
		return $this->has_many_through('App_Req', 'App_Doc_Req', 'doc_rqmnt_cd', 'app_rqmnt_cd')->order_by_desc('active_fg');
	}
	
	public function app_reqs_() {
		return $this->app_reqs;//()->order_by_desc('active_fg')->find_many();
	}
	
	public function tags() {
		return $this->has_many('Tag', 'rec_cd')->where('rec_type', 'doc_req');
	}
	public function tags_() {
		$all_tags = $this->tags;//()->select('tag')->find_many();
		
		$tags = array();
		
		foreach($all_tags as $tag) {
			$tags[] = $tag->tag;
		}
		
		return $tags;
	}
	
	public function urls() {
		return $this->has_many('URL', 'rec_cd')->where('rec_type', 'doc_req');
	}
	public function urls_() {
		return $this->urls;//()->find_many();
	}
	public function findURLs() {
		return getURLs($this->doc_rqmnt_full_descr . PHP_EOL . $this->add_info_url_txt);
	}
	
}