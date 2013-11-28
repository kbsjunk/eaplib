<?php

class Spk_Cat extends Model
{
	public static $_id_column = 'spk_cat_type_cd';
	
	
	public function inactive() {
		return $this->self_apply_fg != 'Y';
	}
	public function inherit_inactive() {
		return $this->inherit_active_fg != 'Y';
	}
	
	public function study_type_cd_() {
		$list = array(
			'$CWK' => 'Coursework',
			'$HDR' => 'HD Research',
			'$HDC' => 'HD Coursework'
		);
		
		return $list[$this->study_type_cd];
	}
	
	public function spk_cat_lvl_cd_() {
		$list = array(
			'UG' => 'Undergraduate',
			'PG' => 'Postgraduate',
			'O' => 'Other',
			'N' => 'Non Award'
		);
		
		return $list[$this->spk_cat_lvl_cd];
	}
	
	public function spk_cat_app_reqs() {
		return $this->has_many_through('App_Req', 'Spk_Cat_App_Req', 'spk_cat_type_cd', 'app_rqmnt_cd')
			->select('spk_cat_app_req.seq_no')
			->select('spk_cat_app_req.active_fg', 'inherit_active_fg')
			->order_by_asc('seq_no')
			->with('usr_flds', 'dsp_crts', 'doc_reqs')
			;
	}
	
	public function spk_cat_app_reqs_() {
		return $this->spk_cat_app_reqs;//()->find_many();
	}
	
	// All Inherited Application Requirements
	
	public function app_reqs_() {
		
		$inst = Model::factory('Inst_App_Req')->with(
		array(
			'app_req' => array(
				'with' => 'doc_reqs,dsp_crts,usr_flds'
				),
			)
		)->where('active_fg', 'Y')->find_many();
		$spk_cat = $this->spk_cat_app_reqs_();
		
		$used = array();
		
		foreach ($inst as $inst_app_req) {
			$app_req = $inst_app_req->app_req_();
			if (!$app_req->inherit) $app_req->inherit = 'inst';
			$app_req->inherit_active_fg = $app_req->active_fg;
			
			$used[$app_req->app_rqmnt_cd] = $app_req;
			
		}
		
		foreach ($spk_cat as $app_req) {
			$used[$app_req->app_rqmnt_cd] = $app_req;
		}
		
		return $used;
		
	}
	
	public function customised() {
		return $this->has_many_through('App_Req', 'Spk_Cat_App_Req', 'spk_cat_type_cd', 'app_rqmnt_cd');
	}
	public function customised_() {
		return count($this->customised);
	}
	
	public function spk_cat_cnf_ems() {
		return $this->has_many_through('Cnf_Em', 'Spk_Cat_Cnf_Em', 'spk_cat_type_cd', 'eap_rspns_cd')
			->select('spk_cat_cnf_em.seq_no')
			->select('spk_cat_cnf_em.active_fg', 'inherit_active_fg')
			->order_by_asc('seq_no')
			->with('dsp_crts')
			;
	}
	
	public function spk_cat_cnf_ems_() {
		return $this->spk_cat_cnf_ems()->find_many();
	}
	
	// All Inherited Application Requirements
	
	public function cnf_ems_() {
		
		$inst = Model::factory('Inst_Cnf_Em')->with('dsp_crts')->where('active_fg', 'Y')->find_many();
		$spk_cat = $this->spk_cat_cnf_ems_();
		
		$used = array();
		
		foreach ($inst as $inst_cnf_em) {
			$cnf_em = $inst_cnf_em->cnf_em_();
			if (!$cnf_em->inherit) $cnf_em->inherit = 'inst';
			$cnf_em->inherit_active_fg = $cnf_em->active_fg;
			
			$used[$cnf_em->eap_rspns_cd] = $cnf_em;
			
			//print_r($cnf_em);
			
		}
		
		foreach ($spk_cat as $cnf_em) {
			$used[$cnf_em->eap_rspns_cd] = $cnf_em;
		}
		
		return $used;
		
	}


	
}

class Spk_Cat_App_Req extends Model
{
	
	
	
}

class Spk_Cat_Cnf_Em extends Model
{
	
	
	
}