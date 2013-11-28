<?php

class Cnf_Em extends Model
{
	public static $_id_column = 'eap_rspns_cd';
	
	public function eap_rspns_cd_() {
		return urlencode(safe_html_attr($this->eap_rspns_cd));
	}
	
	public function eap_rspns_descr_() {
		return semicolon_br($this->eap_rspns_descr, true);
	}
	
	public function eap_rspns_text_() {
		return semicolon_br(nbsps($this->eap_rspns_text), true);
	}
	
	public function inactive() {
		return $this->active_fg != 'Y';
	}
	
	public function inherit_inactive() {
		return $this->inherit_active_fg != 'Y';
	}
	
	// Display Criteria
	
	public function dsp_crts() {
		return $this->has_many('Cnf_Em_Crt', 'eap_rspns_cd');
	}
	
	public function dsp_crts_() {
		return $this->dsp_crts;//()->find_many();
	}
	
	// Study Packages
	
	public function spk_cds() {
		return $this->has_many_through('Spk_Ver', 'Spk_Cnf_Em', 'eap_rspns_cd', 'spk_id')
			->select('spk_cnf_em.active_fg', 'inherit_active_fg')
			->select_expr('CASE WHEN spk_cnf_em.active_fg = "N" THEN "spk_cat" ELSE "" END', 'inherit')
			->order_by_asc('spk_cd')
			->order_by_desc('spk_ver_no')
			;
	}
	
	public function spk_cds_() {
			return $this->spk_cds;
	}


	// Study Package Category Types
	
	public function spk_cats() {
		return $this->has_many_through('Spk_Cat', 'Spk_Cat_Cnf_Em', 'eap_rspns_cd', 'spk_cat_type_cd')
			->select('spk_cat_cnf_em.active_fg', 'inherit_active_fg')
			->select_expr('CASE WHEN spk_cat_cnf_em.active_fg = "N" THEN "inst" ELSE "" END', 'inherit')
			->order_by_asc('spk_cat_type_cd')
			;
	}
	public function spk_cats_() {
			return $this->spk_cats;
	}
	public function tags() {
		return $this->has_many('Tag', 'rec_cd')->where('rec_type', 'cnf_em');
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
		return $this->has_many('URL', 'rec_cd')->where('rec_type', 'cnf_em')->order_by_desc('email')->order_by_asc('status')->order_by_asc('url');
	}
	public function urls_() {
		return $this->urls;//()->find_many();
	}
	public function findURLs() {
		return getURLs($this->eap_rspns_text);
	}

	public function inherit_() {
		if (isset($this->inherit)) {
			return $this->inherit;
		}
	}
	
}

class Cnf_Em_Crt extends Model
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