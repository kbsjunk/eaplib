<?php
class Std_Cd extends Model
{
	public static $_id_column = 'code_type';
	
	public function std_cd_vals() {
		return $this->has_many('Std_Cd_Val', 'code_type')->order_by_desc('active_fg')->order_by_asc('seq_no');
	}

	public function std_cd_vals_() {
		return $this->std_cd_vals;
	}

	public function inactive() {
		return false;
	}

	
	public function dropdown_($id = false) {
		
		$std_cd_vals = $this->std_cd_vals_();
		
		$field = "<select $id style='width:auto;'>";
		$field .= "<option value=''></option>";
		
		foreach($std_cd_vals as $std_cd_val) {
			if (!$std_cd_val->inactive())
			$field .= "<option value='{$std_cd_val->code_id}'>{$std_cd_val->code_descr}</option>";
		}
		
		$field .= "</select>";
		
		return $field;
	}
	
	public function app_reqs() {
		return $this->has_many_through('App_Req', 'App_Req_Std_Cd', 'code_type', 'app_rqmnt_cd')->order_by_desc('active_fg')->order_by_asc('app_rqmnt_cd');
	}
	
	public function app_reqs_($active=true) {
		return $this->app_reqs;//()->find_many();
	}
	
	public function tags() {
		return $this->has_many('Tag', 'rec_cd')->where('rec_type', 'std_cd');
	}
	public function tags_() {
		$all_tags = $this->tags;//()->select('tag')->find_many();
		
		$tags = array();
		
		foreach($all_tags as $tag) {
			$tags[] = $tag->tag;
		}
		
		return $tags;
	}
	
}

class Std_Cd_Val extends Model
{
	//public static $_id_column = 'code_type';
	
	public function inactive() {
		return $this->active_fg != 'Y';
	}
	
}

class App_Req_Std_Cd extends Model
{
	
	
	
}