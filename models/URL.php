<?php
class URL extends Model
{
	public static $_id_column = 'id';
	public static $_table = 'uom_urls';
	
	public function rec() {
		$class_name = str_replace(' ', '_', ucwords(str_replace('_',' ',$this->rec_type)));
		return $this->belongs_to($class_name, 'rec_cd');
	}
	
	public function rec_() {
		return $this->rec;//()->find_one();
	}
	
	public function rec_type_() {
		$list = array(
			'app_req' => 'Application Requirement',
			'doc_req' => 'Document Requirement',
			'cnf_em' => 'Confirmation Email'
		);
		
		if ($rec_type = $list[$this->rec_type]) return $rec_type;
		return $this->rec_type;
	}
	
	public function rec_title_() {
		$list = array(
			'app_req' => 'app_rqmnt_descr',
			'doc_req' => 'doc_rqmnt_descr',
			'cnf_em' => 'eap_rspns_descr'
		);
		
		if ($rec_title = $list[$this->rec_type]) return semicolon_br($this->rec_()->{$rec_title}, true);
	}
	
	public function checkURL() {
		$this->email = stripos($this->url, '@') !== FALSE;
		
		if (!$this->email) {
			$url = $this->url;
			$this->status = checkURL($url);
			$this->redirect = $url != $this->url;
			$this->check_times = $this->check_times+1;
		}
		else {
			$this->status = NULL;
		}
		$this->save();
	}	
	
	public function url_($link = true) {
		if ($this->url) {
			if ($link) {
				if ($this->email) {
					return sprintf('<a href="mailto:%s">%s</a>',
								   $this->url,
								   $this->url
								  );
				}
				else {
					return sprintf('<a href="%s" target="_blank">%s</a>',
								   $this->url,
								   str_replace('/', '/<wbr>', $this->url)
								  );
				}
			}
			else {
				return str_replace('/', '/<wbr>', $this->url);
			}
		}
	}
	
	public function error_() {
	
		if ($this->email) return false;
		
		return !in_array(substr($this->status, 0, 1), array(2, 3));
	}
	
	public function error_sign_() {
		
		if ($this->email) {
			return false;
			$icon = 'question-sign';
			$text = 'muted';
			$title = 'Unable to Check Email';
		}
		else {
			
			$error = substr($this->status, 0, 1);
			
			switch ($error) {
				case 2:
				$icon = 'ok-sign';
				$text = 'text-success';
				$title = 'Success';
				break;
				case 3:
				case '-':
				$icon = 'circle-arrow-right';
				$text = 'text-warning';
				$title = 'Redirection';
				break;
				case 4:
				case 5:
				$icon = 'exclamation-sign';
				$text = 'text-error';
				$title = 'Error';
				break;
				default:
				$icon = 'question-sign';
				$text = 'muted';
				$title = 'Unknown';
				break;
			}
			
		}
		
		$sign = sprintf(' <i class="icon-%s %s" title="%s"></i>', $icon, $text, $title );
		
		if ($this->redirect) {
			$sign = ' <i class="icon-circle-arrow-right text-warning" title="Redirection"></i>'.$sign;
		}
		
		return $sign;
	}
	
	public function status_() {
		
		if ($this->email) return '';
		
		$list = array(
			'-1' => 'Too Many Redirects',
			'200' => 'OK',
			'301' => 'Moved Permanently',
			'302' => 'Moved Temporarily',
			'401' => 'Unauthorized',
			'403' => 'Forbidden',
			'404' => 'Not Found',
			'408' => 'Timeout',
			'500' => 'Internal Server Error',
			'502' => 'Bad Gateway',
			'503' => 'Service Unavailable',
		);
		
		if (!$status = @$list[$this->status]) {
			switch (substr($this->status, 0, 1)) {
				case '2':
				$status = 'Success';
				break;
				case '3':
				case '-':
				$status = 'Redirection';
				break;
				case '4':
				$status = 'Client Error';
				break;
				case '5':
				$status = 'Server Error';
				break;
				default:
				$status = 'Unknown Status';
			}
		}
		$error = $this->error_() ? 'warning' : 'success';
		return $this->status . ' ' . $status;
	}
	
	public function status_date_() {
		
		if ($this->email) return '';
		
		$date = new DateTime($this->status_date);
		$date->setTimezone(new DateTimeZone('Australia/Melbourne'));
		
		return $date->format("d/m/Y g:i A");
	}
	
}