<?php
class Tag extends Model
{
	public static $_id_column = 'id';
	public static $_table = 'uom_tags';

	public function rec() {
		$class_name = str_replace(' ', '_', ucwords(str_replace('_',' ',$this->rec_type)));
		return $this->belongs_to($class_name, 'rec_cd');
	}

	public function rec_() {
		return $this->rec;
	}

	public function rec_type_() {
		$list = array(
			'app_req' => 'Application Requirement',
			'doc_req' => 'Document Requirement',
			'cnf_em' => 'Confirmation Email',
			'std_cd' => 'Dropdown List',
			);

		if ($rec_type = $list[$this->rec_type]) return $rec_type;
		return $this->rec_type;
	}

	public function rec_title_() {
		$list = array(
			'app_req' => 'app_rqmnt_descr',
			'doc_req' => 'doc_rqmnt_descr',
			'cnf_em' => 'eap_rspns_descr',
			'std_cd' => 'code_type_descr',
			);

		if ($rec_title = $list[$this->rec_type]) return semicolon_br($this->rec_()->{$rec_title}, true);
	}


	function inactive() {
		return false;
	}

}

/*class App_Req_Tag extends Model
{



}

class Doc_Req_Tag extends Model
{



}

class Cnf_Em_Tag extends Model
{



}

class Std_Cd_Tag extends Model
{



}*/