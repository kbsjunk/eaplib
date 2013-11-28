<?php

class OptionHandler extends Model
{
	public static $_table = 'options';
	public static $_id_column = 'option_name';
	
}

class Options
{
	public static function get($option_name) {
		$option = Model::factory('OptionHandler')->find_one($option_name);
		
		if (! $option->id() ) return false;

		return $option->option_value;
	}
	public static function set($option_name, $option_value) {
		$option = Model::factory('OptionHandler')->find_one($option_name);
		
		if (! $option->id() ) {
			$option = Model::factory('OptionHandler')->create();
			$option->option_name = $option_name;
		}

		$option->option_value = $option_value;

		return $option->save();
	}
}