<?php

class Employee {
	public $employee_id;
	public $first_name;
	public $last_name;
	public $email;
	public $phone_no;
	public $hire_date;
	public $salary;
	
	public function set($arrayParams) {
		if (!empty($arrayParams['employee_id'])) {
			$this->employee_id = $arrayParams['employee_id'];
		}
		$this ->first_name = $arrayParams['first_name'];
		$this->last_name = $arrayParams['last_name'];
		$this->email = $arrayParams['email'];
		$this->phone_no = $arrayParams['phone_no'];
		$this->hire_date = $arrayParams['hire_date'];
		$this->salary = $arrayParams['salary'];
	}
}

?>