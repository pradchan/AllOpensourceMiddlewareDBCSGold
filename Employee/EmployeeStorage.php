<?php
include("Employee.php");

class EmployeeStorage {

	private $conn;

	public function __construct() {
		$userName = getenv('DBAAS_USER_NAME') ? getenv('DBAAS_USER_NAME') : 'hr_user';
		$password = getenv('DBAAS_USER_PASSWORD') ? getenv('DBAAS_USER_PASSWORD') : 'welcome1';
		$default_descriptor = getenv('DBAAS_DEFAULT_CONNECT_DESCRIPTOR') ? getenv('DBAAS_DEFAULT_CONNECT_DESCRIPTOR') : 'localhost/ORCL';
		$this->conn = oci_connect($userName, $password, $default_descriptor);
		if (!$this->conn) {
			$e = oci_error();
			trigger_error(htmlentities($e['message'], ENT_QUOTES), E_USER_ERROR);
			echo "connection error. Failed.....";
		}
	}

	public function getAll() {
		$data = Array();
		$query = 'SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NO, TO_CHAR(HIRE_DATE, \'YYYY-MM-DD\') AS HIRE_DATE, SALARY FROM EMPLOYEES';

		$stid = oci_parse($this->conn, $query);
		oci_execute($stid);

		while ($row = oci_fetch_array($stid, OCI_ASSOC + OCI_RETURN_NULLS)) {
			$employee = new Employee();
			$employee->employee_id = $row['EMPLOYEE_ID'];
			$employee->first_name = $row['FIRST_NAME'];
			$employee->last_name = $row['LAST_NAME'];
			$employee->email = $row['EMAIL'];
			$employee->phone_no = $row['PHONE_NO'];
			$employee->hire_date = $row['HIRE_DATE'];
			$employee->salary = $row['SALARY'];
			array_push($data, $employee);
		}
		return $data;
	}

	public function search($criteria, $value) {
		$data = Array();
		if ($criteria=='employeeid'){
			$filter = 'EMPLOYEE_ID';
		}else if ($criteria=='firstname'){
			$filter = 'FIRST_NAME';
		}else if ($criteria=='email'){
			$filter = 'EMAIL';
		}
		$value = '%' . $value . '%';
		$query = 'SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NO, TO_CHAR(HIRE_DATE, \'YYYY-MM-DD\') AS HIRE_DATE, SALARY FROM EMPLOYEES WHERE ' . $filter . ' LIKE :value';
		$stmt = oci_parse($this->conn, $query);
		oci_bind_by_name($stmt, ':value', $value, -1);
		oci_execute($stmt);
		while ($row = oci_fetch_array($stmt, OCI_ASSOC + OCI_RETURN_NULLS)) {
			$employee = new Employee();
			$employee->employee_id = $row['EMPLOYEE_ID'];
			$employee->first_name = $row['FIRST_NAME'];
			$employee->last_name = $row['LAST_NAME'];
			$employee->email = $row['EMAIL'];
			$employee->phone_no = $row['PHONE_NO'];
			$employee->hire_date = $row['HIRE_DATE'];
			$employee->salary = $row['SALARY'];
			array_push($data, $employee);
		}
		return $data;
	}

	public function delete($id) {
		$query = 'DELETE FROM EMPLOYEES WHERE employee_id = :id';
		$stmt = oci_parse($this->conn, $query);
		oci_bind_by_name($stmt, ':id', $id, -1);
		oci_execute($stmt);
	}

	public function update($employee) {
		$query = 'UPDATE EMPLOYEES SET FIRST_NAME=:first_name, LAST_NAME=:last_name, EMAIL=:email, PHONE_NO=:phone_no, HIRE_DATE=TO_DATE(:hire_date, \'yyyy-mm-dd\'), SALARY=:salary '
				. 'WHERE EMPLOYEE_ID=:employee_id';
				$stmt = oci_parse($this->conn, $query);
				oci_bind_by_name($stmt, ':first_name', $employee->first_name);
				oci_bind_by_name($stmt, ':last_name', $employee->last_name);
				oci_bind_by_name($stmt, ':email', $employee->email);
				oci_bind_by_name($stmt, ':phone_no', $employee->phone_no);
				oci_bind_by_name($stmt, ':hire_date', $employee->hire_date);
				oci_bind_by_name($stmt, ':salary', $employee->salary);
				oci_bind_by_name($stmt, ':employee_id', $employee->employee_id);
				oci_execute($stmt);
	}

	public function save($employee) {
		$query = 'INSERT INTO EMPLOYEES (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NO, HIRE_DATE, SALARY) '
				. 'VALUES(:employee_id, :first_name, :last_name, :email, :phone_no, TO_DATE(:hire_date, \'yyyy-mm-dd\'), :salary)';
				$stmt = oci_parse($this->conn, $query);
				oci_bind_by_name($stmt, ':employee_id', $employee->employee_id);
				oci_bind_by_name($stmt, ':first_name', $employee->first_name);
				oci_bind_by_name($stmt, ':last_name', $employee->last_name);
				oci_bind_by_name($stmt, ':email', $employee->email);
				oci_bind_by_name($stmt, ':phone_no', $employee->phone_no);
				oci_bind_by_name($stmt, ':hire_date', $employee->hire_date);
				oci_bind_by_name($stmt, ':salary', $employee->salary);
				oci_execute($stmt);
	}

	public function get($id) {
		$query = 'SELECT * FROM EMPLOYEES WHERE EMPLOYEE_ID=?';
		$statement = $this->dbc->prepare($query);
		$statement->bindParam(1, $id);
		$statement->execute();
		$row = $statement->fetch();
		$employee = new Employee();
		$employee->employee_id = $row['EMPLOYEE_ID'];
		$employee->first_name = $row['FIRST_NAME'];
		$employee->last_name = $row['LAST_NAME'];
		$employee->email = $row['EMAIL'];
		$employee->phone_no = $row['PHONE_NO'];
		$employee->hire_date = $row['HIRE_DATE'];
		$employee->salary = $row['SALARY'];
		return $employee;
	}

}

?>