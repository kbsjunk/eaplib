<?php

class Inst_App_Req extends Model
{
	
	public function app_req() {
		return $this->belongs_to('App_Req', 'app_rqmnt_cd');
	}
	
	public function app_req_() {
		return $this->app_req;//()->find_one();
	}
	
	public function inactive() {
		return $this->active_fg != 'Y';
	}
	
	public function inherit_active_fg() {
		return $this->active_fg;
	}
	
}

class Inst_Cnf_Em extends Model
{
	
	public function cnf_em() {
		return $this->belongs_to('Cnf_Em', 'eap_rspns_cd');
	}
	public function cnf_emz() {
		return $this->belongs_to('Cnf_Em', 'eap_rspns_cd');
	}
	public function cnf_em_() {
		return $this->cnf_em;//()->find_one();
	}
	
	public function inactive() {
		return $this->active_fg != 'Y';
	}
	
	public function inherit_active_fg() {
		return $this->active_fg;
	}
	
}