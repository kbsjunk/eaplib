<?php
class Spk_Cd extends Model
{
	public static $_id_column = 'spk_cd';


	public function inactive() {
		return $this->self_apply_fg != 'Y';
	}



// Versions

	public function spk_vers() {
		return $this->has_many('Spk_Ver', 'spk_cd')->order_by_desc('spk_ver_no');
	}

	public function spk_vers_() {
		return $this->spk_vers;//()->order_by_desc('spk_ver_no')->find_many();		
	}


}

class Spk_App_Req extends Model
{



}

class Spk_Cnf_Em extends Model
{



}

class Spk_Ver extends Model
{
	public static $_id_column = 'spk_id';

	public function spk_stage_cd_() {
		$list = array(
			'AC' => 'Active',
			'DR' => 'Draft',
			'DS' => 'Discontinued',
			'PL' => 'Planned',
			'PO' => 'Phasing Out'
			);

		return $list[$this->spk_stage_cd];
	}

	public function inactive() {
		return $this->self_apply_fg != 'Y';
	}
	public function inherit_inactive() {
		return $this->inherit_active_fg != 'Y';
	}

// Active Version

	public function active_ver() {
		if ($this->spk_stage_cd == 'AC') {
			return $this;
		}

		$active_ver = Model::factory('Spk_Ver')
					->where('spk_no', $this->spk_no)
					->where('spk_stage_cd', 'AC')
					->order_by_desc('spk_ver_no')
					->find_one();

					return $active_ver;
	}


// Category Type

	public function spk_cat() {
		return $this->belongs_to('Spk_Cat', 'spk_cat_type_cd');
	}

	public function spk_cat_() {
		return $this->spk_cat;//()->find_one();
	}

// SPK Application Requirements

	public function spk_app_reqs() {
		return $this->has_many_through('App_Req', 'Spk_App_Req', 'spk_id', 'app_rqmnt_cd')
		->select('seq_no')
		->select('spk_app_req.active_fg', 'inherit_active_fg')
		->select_expr('CASE WHEN spk_app_req.active_fg = "N" THEN "spk_cat" ELSE "" END', 'inherit')
		->order_by_asc('seq_no')
		->with('usr_flds', 'dsp_crts', 'doc_reqs')
		;
	}

	public function customised() {
		return $this->has_many_through('App_Req', 'Spk_App_Req', 'spk_id', 'app_rqmnt_cd');
	}
	public function customised_() {
		return count($this->customised);
	}

	public function spk_app_reqs_() {
		return $this->spk_app_reqs;//()->find_many();
	}

// SPK CAT Application Requirements

	public function spk_cat_app_reqs_() {
		return $this->spk_cat_()->app_reqs_();
	}

// All Inherited Application Requirements

	public function app_reqs_() {

		$spk_cat = $this->spk_cat_()->app_reqs_();
		$spk = $this->spk_app_reqs_();

		$used = array();

		foreach ($spk_cat as $app_req) {
			if ($app_req->inherit_active_fg == 'Y') {
				if (!$app_req->inherit) $app_req->inherit = 'spk_cat';
				$used[$app_req->app_rqmnt_cd] = $app_req;
			}
		}

		foreach ($spk as $app_req) {
			$used[$app_req->app_rqmnt_cd] = $app_req;
		}

		return $used;

	}

// SPK Application Requirements

	public function spk_cnf_ems() {
		return $this->has_many_through('Cnf_Em', 'Spk_Cnf_Em', 'spk_id', 'eap_rspns_cd')
		->select('seq_no')
		->select('spk_cnf_em.active_fg', 'inherit_active_fg')
		->select_expr('CASE WHEN spk_cnf_em.active_fg = "N" THEN "spk_cat" ELSE "" END', 'inherit')
		->order_by_asc('seq_no')
		->with('dsp_crts')
		;
	}

	public function spk_cnf_ems_() {
		return $this->spk_cnf_ems;//()->find_many();
	}

// SPK CAT Application Requirements

	public function spk_cat_cnf_ems_() {
		return $this->spk_cat_()->cnf_ems_();
	}

// All Inherited Application Requirements

	public function cnf_ems_() {

		$spk_cat = $this->spk_cat_()->cnf_ems_();
		$spk = $this->spk_cnf_ems_();

		$used = array();

		foreach ($spk_cat as $cnf_em) {
			if ($cnf_em->inherit_active_fg == 'Y') {
				if (!$cnf_em->inherit) $cnf_em->inherit = 'spk_cat';
				$used[$cnf_em->eap_rspns_cd] = $cnf_em;
			}
		}

		foreach ($spk as $cnf_em) {
			$used[$cnf_em->eap_rspns_cd] = $cnf_em;
		}

		return $used;

	}

}

// SELECT * FROM (
// SELECT inst_app_req.app_rqmnt_cd, spk_ver.spk_id, spk_ver.spk_cat_type_cd, inst_app_req.seq_no, inst_app_req.active_fg,
// 'inst' AS `inherit_from`
// FROM `inst_app_req`
// LEFT JOIN spk_ver ON (1=1)
// WHERE NOT EXISTS (
//     SELECT * FROM spk_cat_app_req
//     WHERE spk_cat_app_req.active_fg = 'N' AND
//     spk_cat_app_req.spk_cat_type_cd = spk_ver.spk_cat_type_cd AND
//     spk_cat_app_req.app_rqmnt_cd = inst_app_req.app_rqmnt_cd
//     )
// AND
// NOT EXISTS (
//     SELECT * FROM spk_app_req
//     WHERE spk_app_req.active_fg = 'N' AND
//     spk_app_req.spk_id = spk_ver.spk_id AND
//     spk_app_req.app_rqmnt_cd = inst_app_req.app_rqmnt_cd
//     )
// UNION
// SELECT spk_cat_app_req.app_rqmnt_cd, spk_ver.spk_id, spk_cat_app_req.spk_cat_type_cd, spk_cat_app_req.seq_no, spk_cat_app_req.active_fg,
// 'spk_cat' AS 'inherit_from'
// FROM spk_cat_app_req
// LEFT JOIN spk_ver ON (spk_ver.spk_cat_type_cd = spk_cat_app_req.spk_cat_type_cd)
// WHERE NOT EXISTS (
//     SELECT * FROM spk_app_req
//     WHERE spk_app_req.active_fg = 'N' AND
//     spk_app_req.spk_id = spk_ver.spk_id AND
//     spk_app_req.app_rqmnt_cd = spk_cat_app_req.app_rqmnt_cd
//     )
// UNION
// SELECT spk_app_req.app_rqmnt_cd, spk_app_req.spk_id, spk_ver.spk_cat_type_cd, spk_app_req.seq_no, spk_app_req.active_fg,
// 'spk' AS 'inherit_from'
// FROM spk_app_req INNER JOIN spk_ver ON (spk_app_req.spk_id = spk_ver.spk_id)
// ) AS spk_sallasd
// WHERE spk_id = '038AB/2'