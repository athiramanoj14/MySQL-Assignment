CREATE DATABASE employee;
USE employee;

-- 2. Create the Location table
CREATE TABLE location (
    location_id INT PRIMARY KEY,
    location VARCHAR(30)
);

-- 3. Create the Departments table
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

-- 4. Create the Employees table (linking to departments and location)
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50),
    gender ENUM('M', 'F'),
    age INT,
    hire_date DATE,
    designation VARCHAR(100),
    department_id INT,
    location_id INT,
    salary DECIMAL(10, 2),
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (location_id) REFERENCES location(location_id)
);
-- 2. Table Alteration (ALTER): Modify the structure of the employees table
-- Add a new column named "email"
ALTER TABLE employees ADD COLUMN email VARCHAR(100);

-- Modify the data type of the "designation" column to support a wider range of values
ALTER TABLE employees MODIFY COLUMN designation VARCHAR(255);

-- Drop the "age" column from the Employees table
ALTER TABLE employees DROP COLUMN age;

-- Rename the "hire_date" column to "date_of_joining"
ALTER TABLE employees RENAME COLUMN hire_date TO date_of_joining;


-- 3. Table Renaming (RENAME): Rename tables
RENAME TABLE departments TO departments_info;
RENAME TABLE location TO locations;
-- 4. Table Truncation (TRUNCATE): Clear all data from the employees table
TRUNCATE TABLE employees;

-- 5. Database & Table Dropping (DROP): Drop the employees table and the employee database[cite: 2]
DROP TABLE IF EXISTS employees;
DROP DATABASE IF EXISTS employee;
-- Recreate the database with constraints
CREATE DATABASE employee;
USE employee;

-- Location Table (auto-increment ID, unique location)
CREATE TABLE location (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location VARCHAR(30) NOT NULL UNIQUE
);

-- Departments Table (unique department ID and name)
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

-- Employees Table with all constraints
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
