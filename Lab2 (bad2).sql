/*CIS530 - Lab Assignment 2
Name: Dean Choi
ID: 2690159
Object: Creating a Company Database Schema and Populating with Data*/
--using master database
USE master;
--creating a database named COMPANY at a specific file location, with a size of 8MB, and a simple log at the specified file location
CREATE DATABASE [COMPANY]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'COMPANY', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\COMPANY.mdf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'COMPANY_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\COMPANY_log.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
GO

--creating the two tables in the COMPANY database
use [COMPANY];
--creating the EMPLOYEE table
CREATE TABLE dbo.EMPLOYEE (
	Fname		varchar(15)		not null,
	Minit		char,
	Lname		varchar(15)		not null,
	Ssn			char(9)			not null,
	Bdate		date,
	Address		varchar(30),
	Sex			char,
	Salary		decimal(10,2),
	SuperSsn	char(9),
	Dno			int				not null,
	primary key (Ssn),			-- Set Ssn as primary key
);

--Add in the unary one-to-many relationship of Supervisor Ssn to Employee Ssn within the EMPLOYEE TABLE.
ALTER TABLE EMPLOYEE
ADD CONSTRAINT FKCONSTR1
Foreign key (SuperSsn) References EMPLOYEE(Ssn);

--creating the DEPARTMENT table
CREATE TABLE dbo.DEPARTMENT (
	Dname			varchar(15)		not null,
	Dnumber			int				not null,
	MgrSsn			char(9)			not null,
	MgrStartDate	DATE,
	primary key (Dnumber),		--pk set as Department number
	unique (Dname),		--each Department_Name should be unique as well (could be a secondary key)
	foreign key (MgrSSn) References EMPLOYEE(SSN)	--foreign key constraint that references a managing employee from the employee table
);

--Since DEPARTMENT table has been created, can add the Department number relationship to the EMPLOYEE TABLE (one-to-many)
ALTER TABLE EMPLOYEE
ADD CONSTRAINT FKCONSTR2
Foreign key (Dno) References DEPARTMENT (Dnumber);

--creating DEPT_LOCATIONS table
CREATE TABLE DEPT_LOCATIONS (
	Dnumber		int				not null,
	Dlocation	varchar(15)		not null,
	primary key (Dnumber, Dlocation),	--created a composite primary key for this table
	foreign key (Dnumber) References DEPARTMENT(Dnumber)	--foreign key constraint that Dnumber reference comes from DEPARTMENT table
);

--creating DEPENDENT table
CREATE TABLE DEPENDENT(
	Essn			char(9)			not null,
	Dependent_name	varchar(15)		not null,
	Sex				char(1),
	Bdate			date,
	Relationship	varchar(10),
	primary key (Essn, Dependent_name),		--composite primary key of Employee's SSN and the dependent's name
	foreign key (Essn) References EMPLOYEE(Ssn)		--foreign key constr where Essn references the Ssn from the EMPLOYEE TABLE
);

--creating PROJECT table, before final WORKS_ON table as that references the primary key of the PROJECT TABLE
CREATE TABLE PROJECT(
	Pname		varchar(15)		not null,
	Pnumber		int				not null,
	Plocation	varchar(15),
	Dnum		int				not null,
	primary key (Pnumber),		--pk set as the Project number
	unique (Pname),				--set Project_Name as a secondary key that must be unique as well
	foreign key (Dnum) References DEPARTMENT(Dnumber)	--fk constr
);

--creating WORKS_ON table (final one)
CREATE TABLE WORKS_ON(
	Essn		char(9)			not null,
	Pno			int				not null,
	Hours		decimal(3,1)	not null,
	primary key (Essn, Pno),	--composite pk
	foreign key (Essn) References EMPLOYEE(Ssn),
	foreign key (Pno) References PROJECT(Pnumber)
);



--POPULATING THE COMPANY DATABASE using SQL DML with the given data
use [COMPANY];

/*We will populate the EMPLOYEE table first. Since it is the first table that we need to populate, we cannot avoid having to temporarily
disable the foreign key constraint/check between Dno (in EMPLOYEE) anbd Dnumber (in DEPARTMENT) as there are no values in the DEPARTMENT
table. We also must disable the unary one-to-many fk constraint of MgrSsn to Ssn within the Employee table as well. We do this via the 
"NOCHECK CONSTRAINT" command". Date values have been added as YYYY-MM-DD. It can be cast and converted to whichever string format that you
prefer on output if needed.*/
ALTER TABLE EMPLOYEE
NOCHECK CONSTRAINT FKCONSTR1, FKCONSTR2;

--Inserting the various records into the EMPLOYEE table
INSERT INTO EMPLOYEE VALUES ('John', 'B', 'Smith', '123456789', '1955-01-09', '731 Fondren, Houston, TX', 'M', 30000, '987654321', 5);
INSERT INTO EMPLOYEE VALUES ('Franklin', 'T', 'Wong', '333445555', '1945-12-08', '638 Voss, Houston, TX', 'M', 40000, '888665555', 5);
INSERT INTO EMPLOYEE VALUES ('Joyce', 'A', 'English', '453453453', '1962-12-31', '5631 Rice, Houston, TX', 'F', 25000, '333445555', 5);
INSERT INTO EMPLOYEE VALUES ('Ramesh', 'K', 'Narayan', '666884444', '1952-09-15', '975 Fire Oak, Humble, TX', 'M', 38000, '333445555', 5);
INSERT INTO EMPLOYEE VALUES ('James', 'E', 'Borg', '888665555', '1927-11-10', '450 Stone, Houston, TX', 'M', 55000, NULL, 1);
INSERT INTO EMPLOYEE VALUES ('Jennifer', 'S', 'Wallace', '987654321', '1931-06-20', '291 Berry, Bellaire, TX', 'F', 43000, '888665555', 4);
INSERT INTO EMPLOYEE VALUES ('Ahmad', 'V', 'Jabbar', '987987987', '1959-03-29', '980 Dallas, Houston, TX', 'M', 25000, '987654321', 4);
INSERT INTO EMPLOYEE VALUES ('Alicia', 'J', 'Zelaya', '999887777', '1958-06-19', '3321 Castle, Spring, TX', 'F', 25000, '987654321', 4);
INSERT INTO EMPLOYEE VALUES ('Bad', 'S', 'SuperBad', '999887777', '1958-06-19', '3321 Castle, Spring, TX', 'F', 25000, '987654321', NULL);
INSERT INTO EMPLOYEE VALUES ('Really', ' ', NULL, '123456789', ' ', '731 Fondren, Houston, TX', 'M', 30000, '111111111', 99);
INSERT INTO EMPLOYEE VALUES ('So', 'T', 'Bad', NULL, NULL, '638 Voss, Houston, TX', 'M', 1, '888665555', 12221);

--We can now re-enable the fk constr on the unary one-to-many relationship of MgrSsn and Ssn within the EMPLOYEE table
ALTER TABLE EMPLOYEE
CHECK CONSTRAINT FKCONSTR1;

SELECT * FROM EMPLOYEE;

use [COMPANY];
--Now we insert the various records into the DEPARTMENT table
INSERT INTO DEPARTMENT VALUES ('Headquarters', '1', '888665555', '1971-06-19');
INSERT INTO DEPARTMENT VALUES ('Administration', '4', '987654321', '1975-01-01');
INSERT INTO DEPARTMENT VALUES ('Research', '5', '333445555', '1978-05-22');
INSERT INTO DEPARTMENT VALUES ('Automation', '7', '123456789', '2006-10-05');

SELECT * FROM DEPARTMENT;

--We can now re-enable the foreign key constraint on Department number between the EMPLOYEE and DEPARTMENT tables
ALTER TABLE EMPLOYEE
CHECK CONSTRAINT FKCONSTR2;

use [COMPANY];
--Insert records into the DEPENDENT table
INSERT INTO DEPENDENT VALUES
('123456789', 'Alice', 'F', '1978-12-31', 'Daughter'),
('123456789', 'Elizabeth', 'F', '1957-05-05', 'Spouse'),
('123456789', 'Michael', 'M', '1978-01-01', 'Son'),
('333445555', 'Alice', 'F', '1976-04-05', 'Daughter'),
('333445555', 'Joy', 'F', '1948-05-03', 'Spouse'),
('333445555', 'Theodore', 'M', '1973-10-25', 'Son'),
('987654321', 'Abner', 'M', '1932-02-29', 'Spouse');

SELECT * FROM DEPENDENT;

use [COMPANY];
--Insert into DEPT_LOCATIONS table
INSERT INTO DEPT_LOCATIONS VALUES
(1, 'Houston'),
(4, 'Stafford'),
(5, 'Bellaire'),
(5, 'Sugarland'),
(5, 'Houston');

SELECT * FROM DEPT_LOCATIONS;

use [COMPANY];
--Insert into PROJECT Table
INSERT INTO PROJECT VALUES
('ProductX', 1, 'Bellaire', 5),
('ProductY', 2, 'Sugarland', 5),
('ProductZ', 3, 'Houston', 5),
('Computerization', 10, 'Stafford', 4),
('Reorganization', 20, 'Houston', 1),
('Newbenefits', 30, 'Stafford', 4);

SELECT * FROM PROJECT;


use [COMPANY];
--Insert into WORKS_ON table. Note: For the one record with 'null' for its hours, we have defaulted to inserting '0' for the value
-- as we did not allow a null for that value in our DDL.

INSERT INTO WORKS_ON VALUES
('123456789', 1, 32.5),
('123456789', 2, 7.5),
('333445555', 2, 10),
('333445555', 3, 10),
('333445555', 10, 10),
('333445555', 20, 10),
('453453453', 1, 20),
('453453453', 2, 20),
('666884444', 3, 40),
('888665555', 20, 0),
('987654321', 20, 15),
('987654321', 30, 20),
('987987987', 10, 35),
('987987987', 30, 5),
('999887777', 10, 10),
('999887777', 30, 30);

SELECT * FROM WORKS_ON;

USE master;
--Drops the database from master and this is allowed because all of its tables within have been dropped 
Drop DATABASE [COMPANY];