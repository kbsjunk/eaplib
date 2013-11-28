<?php

class Usr_Fld extends Model
{
	//public static $_id_column = 'code_type';

	function label_($tag=true) {
		$label = trim($this->label);
		
		if ($tag) {
			if ($label) {
				if (trim($this->skin_id)) {
					$label = "<label class='skinid'>$label</label>";
				}
				else {
					$label = "<label>$label</label>";
				}				
			}
			if ($this->mandatory_fg == 'Y') {
				$label .= '<div class="app-req-mandatory"><span title="Mandatory">*</span></div>';
			}
		}
		
		return $label;		
	}
	
	function field_($ix = 1) {
		
		$app_rqmnt_cd = safe_html_attr($this->app_rqmnt_cd);

		$id = "data-app-req='{$app_rqmnt_cd}' data-rsp-no='{$ix}' data-fld-id='{$this->response_field_id}'";
		
		if (trim($this->code_type)) { // Dropdown

			$field = $this->std_cd_()->dropdown_($id);
			
			/*$std_cd_vals = $this->std_cd_vals_();
			
			$field = "<select style='width:auto;' />";
			$field .= "<option value=''></option>";
			
			foreach($std_cd_vals as $std_cd_val) {
				$field .= "<option value='{$std_cd_val->code_id}'>{$std_cd_val->code_descr}</option>";
			}
			
			$field .= "</select>";*/
		}
		else { // Text box
			
			$placeholder = trim($this->watermark);
			$placeholder = $placeholder ? " placeholder='$placeholder'" : false;
			
			if ($this->maximum_length <= 70) {
				$field = "<input type='text' size='{$this->maximum_length}' style='width:auto;' $placeholder />";
			}
			elseif ($this->maximum_length <= 70) {
				$width = $this->maximum_length * 6;
				$field = "<input type='text' style='width:{$width}px;' $placeholder />";
			}
			elseif ($this->maximum_length < 200) {
				$field = "<textarea rows='2' style='width:480px;'></textarea>";
			}
			elseif ($this->maximum_length < 400) {
				$field = "<textarea rows='3' style='width:480px;'></textarea>";
			}
			else {
				$field = "<textarea rows='8' style='width:480px;'></textarea>";
			}
		}
		
		return $field;
	}
	
	public function std_cd() {
        return $this->belongs_to('Std_Cd', 'code_type')->with('std_cd_vals');
    }
	
	public function std_cd_() {
		return $this->std_cd;//()->find_one();
	}
	
	public function std_cd_vals_() {
		$std_cd = $this->std_cd_();
		
		if ($std_cd instanceof Std_Cd) {
			return $std_cd->std_cd_vals_();
		}
		
		return array();
    }
	
	
	
}