-- 1. Clean slate: Drop the database if it exists and create it fresh
DROP DATABASE IF EXISTS employee;
CREATE DATABASE employee;
USE employee;

-- 2. Create the Location table first (independent table)
CREATE TABLE location (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location VARCHAR(30) NOT NULL UNIQUE
);

-- 3. Create the Departments table second (independent table)
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

-- 4. Create the Employees table last (dependent table with foreign keys)
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50) NOT NULL,
    gender ENUM('M', 'F') CHECK (gender IN ('M', 'F')),
    age INT CHECK (age >= 18),
    hire_date DATE DEFAULT (CURRENT_DATE),
    designation VARCHAR(100),
    department_id INT,
    location_id INT,
    salary DECIMAL(10, 2),
    CONSTRAINT fk_department FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES location(location_id)
);
USE employee;

-- Insert sample locations
INSERT INTO location (location) VALUES 
('New York'), 
('London'), 
('Bangalore');

-- Insert sample departments
INSERT INTO departments (department_id, department_name) VALUES 
(1, 'Engineering'), 
(2, 'Human Resources'), 
(3, 'Sales');

-- Insert sample employees
INSERT INTO employees (employee_id, employee_name, gender, age, designation, department_id, location_id, salary) VALUES 
(101, 'Alice Smith', 'F', 28, 'Software Engineer', 1, 1, 85000.00),
(102, 'Bob Jones', 'M', 34, 'HR Manager', 2, 2, 72000.00),
(103, 'Charlie Brown', 'M', 25, 'Sales Executive', 3, 3, 55000.00);
SELECT 
    e.employee_id, 
    e.employee_name, 
    e.gender, 
    e.age, 
    e.designation, 
    d.department_name, 
    l.location, 
    e.salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN location l ON e.location_id = l.location_id;

USE employee;

SELECT employee_name, designation, salary 
FROM employees 
WHERE salary > 60000 
ORDER BY salary DESC;
USE employee;

SELECT 
    d.department_name, 
    COUNT(e.employee_id) AS total_employees, 
    AVG(e.salary) AS average_salary
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name;
USE employee;

UPDATE employees 
SET salary = 90000.00, designation = 'Senior Software Engineer' 
WHERE employee_id = 101;

-- Run this check query right after to see the update!
SELECT employee_id, employee_name, designation, salary 
FROM employees 
WHERE employee_id = 101;
USE employee;

-- Delete an employee record
DELETE FROM employees WHERE employee_id = 103;

-- Check the remaining employees
SELECT * FROM employees;
USE employee;

-- Add a new column named "email" to the Employees table
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
-- Modify the data type of the "designation" column
ALTER TABLE employees MODIFY COLUMN designation VARCHAR(150);
-- Drop the "age" column from the Employees table
ALTER TABLE employees DROP COLUMN age;
-- Rename the "hire_date" column to "date_of_joining"
ALTER TABLE employees RENAME COLUMN hire_date TO date_of_joining;
USE employee;

-- Rename the "Departments" table to "Departments_Info"
RENAME TABLE departments TO departments_info;
RENAME TABLE location TO locations;
USE employee;

-- Truncate the Employees table
TRUNCATE TABLE employees;
USE employee;

-- Drop the Employees table
DROP TABLE IF EXISTS employees;
-- Drop the "employee" database
DROP DATABASE IF EXISTS employee;
-- =====================================================================
-- STEP 1: RECREATE DATABASE & TABLES (Assignment 1 Foundation)
-- =====================================================================
DROP DATABASE IF EXISTS employee;
CREATE DATABASE employee;
USE employee;

-- Location table
CREATE TABLE location (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location VARCHAR(30) NOT NULL UNIQUE
);

-- Departments table
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

-- Employees table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50) NOT NULL,
    gender ENUM('M', 'F') CHECK (gender IN ('M', 'F')),
    age INT CHECK (age >= 18),
    hire_date DATE DEFAULT (CURRENT_DATE),
    designation VARCHAR(100),
    department_id INT,
    location_id INT,
    salary DECIMAL(10, 2),
    CONSTRAINT fk_department FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES location(location_id)
);


-- =====================================================================
-- STEP 2: POPULATE TABLES WITH SAMPLE DATA
-- =====================================================================
INSERT INTO location (location) VALUES 
('New York'), 
('London'), 
('Bangalore'),
('Tokyo');

INSERT INTO departments (department_id, department_name) VALUES 
(1, 'Engineering'), 
(2, 'Human Resources'), 
(3, 'Sales'),
(4, 'Finance');

INSERT INTO employees (employee_id, employee_name, gender, age, hire_date, designation, department_id, location_id, salary) VALUES 
(101, 'Alice Smith', 'F', 28, '2015-06-10', 'Software Engineer', 1, 1, 85000.00),
(102, 'Bob Jones', 'M', 34, '2018-03-15', 'HR Manager', 2, 2, 72000.00),
(103, 'Charlie Brown', 'M', 25, '2018-09-20', 'Sales Analyst', 3, 3, 55000.00),
(104, 'Diana Prince', 'F', 29, '2014-11-05', NULL, 4, 1, 62000.00),
(105, 'Evan Wright', 'M', 41, '2018-01-12', 'Senior Data Analyst', 1, 3, 95000.00),
(106, 'Fiona Glen', 'F', 26, '2020-07-01', 'Finance Assistant', 4, 2, 48000.00);



-- 1. Distinct Values: Retrieve distinct salaries from the Employees table
SELECT DISTINCT salary 
FROM employees;

-- 2. Alias (AS): Provide aliases for "age" and "salary"
SELECT employee_name, age AS Employee_Age, salary AS Employee_Salary 
FROM employees;

-- 3. Where Clause & Operators:
-- a) Salary > 50000 and hired before 2016-01-01
SELECT * 
FROM employees 
WHERE salary > 50000 AND hire_date < '2016-01-01';

-- b) Find employee whose designation is missing and fill it with "Data Scientist"
UPDATE employees 
SET designation = 'Data Scientist' 
WHERE designation IS NULL;

-- Verify the update:
SELECT employee_id, employee_name, designation 
FROM employees;


-- --- Sorting and Grouping Data ---

-- 1. ORDER BY: Sorted by department ID ascending and salary descending
SELECT * 
FROM employees 
ORDER BY department_id ASC, salary DESC;

-- 2. LIMIT: Display the first 5 employees hired in the year 2018
SELECT * 
FROM employees 
WHERE YEAR(hire_date) = 2018 
LIMIT 5;

-- 3. Aggregate Functions:
-- a) Calculate the sum of all salaries in the Finance department
SELECT SUM(e.salary) AS total_finance_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE d.department_name = 'Finance';

-- b) Find the minimum age among all employees
SELECT MIN(age) AS minimum_age 
FROM employees;

-- 4. GROUP BY:
-- a) List the maximum salary for each location
SELECT l.location, MAX(e.salary) AS max_salary
FROM location l
LEFT JOIN employees e ON l.location_id = e.location_id
GROUP BY l.location;

-- b) Calculate average salary for each designation containing 'Analyst'
SELECT designation, AVG(salary) AS avg_salary
FROM employees
WHERE designation LIKE '%Analyst%'
GROUP BY designation;

-- 5. HAVING:
-- a) Find departments with less than 3 employees
SELECT d.department_name, COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
HAVING COUNT(e.employee_id) < 3;

-- b) Find locations with female employees whose average age is below 30
SELECT l.location, AVG(e.age) AS avg_age
FROM location l
JOIN employees e ON l.location_id = e.location_id
WHERE e.gender = 'F'
GROUP BY l.location
HAVING AVG(e.age) < 30;


-- --- Joins ---

-- 1. Inner Join: Names, designations, and department names where assigned
SELECT e.employee_name, e.designation, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- 2. Left Join: All departments and total employees (including empty ones)
SELECT d.department_name, COUNT(e.employee_id) AS total_employees
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name;

-- 3. Right Join: All locations and employee names (displaying NULL if none)
SELECT l.location, e.employee_name
FROM employees e
RIGHT JOIN location l ON e.location_id = l.location_id;
SELECT DISTINCT salary FROM employees;

SELECT employee_name, age AS Employee_Age, salary AS Employee_Salary 
FROM employees;

SELECT * FROM employees 
WHERE salary > 50000 AND hire_date < '2016-01-01';

UPDATE employees 
SET designation = 'Data Scientist' 
WHERE designation IS NULL;
SELECT * FROM employees 
ORDER BY department_id ASC, salary DESC;

SELECT * FROM employees 
WHERE YEAR(hire_date) = 2018 
LIMIT 5;

SELECT SUM(e.salary) AS total_finance_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE d.department_name = 'Finance';

SELECT MIN(age) AS minimum_age FROM employees;

SELECT l.location, MAX(e.salary) AS max_salary
FROM location l
LEFT JOIN employees e ON l.location_id = e.location_id
GROUP BY l.location;

SELECT designation, AVG(salary) AS avg_salary
FROM employees
WHERE designation LIKE '%Analyst%'
GROUP BY designation;

SELECT d.department_name, COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
HAVING COUNT(e.employee_id) < 3;

SELECT l.location, AVG(e.age) AS avg_age
FROM location l
JOIN employees e ON l.location_id = e.location_id
WHERE e.gender = 'F'
GROUP BY l.location
HAVING AVG(e.age) < 30;
SELECT e.employee_name, e.designation, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

SELECT d.department_name, COUNT(e.employee_id) AS total_employees
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name;

SELECT l.location, e.employee_name
FROM employees e
RIGHT JOIN location l ON e.location_id = l.location_id;

