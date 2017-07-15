/*CIS530 - Lab Assignment 1
Name: Dean Choi
ID: 2690159
Object: Creating a Relational Database Schema Using SQL and SQL Server*/
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

--creating the two tables in the COMPANY database of EMPLOYEE and DEPARTMENT without any primary keys or relationships
use [COMPANY];
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
	Dno			int				not null
);

CREATE TABLE dbo.DEPARTMENT (
	Dname		varchar(15)		not null,
	Dnumber		int				not null,
	MgrSsn		char(9)			not null,
	MgrStartDate	DATE
);

use [COMPANY];
--Inserting the various records into the EMPLOYEE table
INSERT INTO EMPLOYEE VALUES ('John', 'B', 'Smith', '123456789', '9-Jan-55', '731 Fondren, Houston, TX', 'M', 30000, '987654321', 5);
INSERT INTO EMPLOYEE VALUES ('Franklin', 'T', 'Wong', '333445555', '8-Dec-45', '638 Voss, Houston, TX', 'M', 40000, '888665555', 5);
INSERT INTO EMPLOYEE VALUES ('Joyce', 'A', 'English', '453453453', '31-Jul-62', '5631 Rice, Houston, TX', 'F', 25000, '333445555', 5);
INSERT INTO EMPLOYEE VALUES ('Ramesh', 'K', 'Narayan', '666884444', '15-Sep-52', '975 Fire Oak, Humble, TX', 'M', 38000, '333445555', 5);
INSERT INTO EMPLOYEE VALUES ('James', 'E', 'Borg', '888665555', '10-Nov-27', '450 Stone, Houston, TX', 'M', 55000, NULL, 1);
INSERT INTO EMPLOYEE VALUES ('Jennifer', 'S', 'Wallace', '987654321', '20-Jun-31', '291 Berry, Bellaire, TX', 'F', 43000, '888665555', 4);
INSERT INTO EMPLOYEE VALUES ('Ahmad', 'V', 'Jabbar', '987987987', '29-Mar-59', '980 Dallas, Houston, TX', 'M', 25000, '987654321', 4);
INSERT INTO EMPLOYEE VALUES ('Alicia', 'J', 'Zelaya', '999887777', '19-Jul-58', '3321 Castle, Spring, TX', 'F', 25000, '987654321', 4);
--Returns a record set of the populated EMPLOYEE table before dropping it (all tables must be dropped in order to drop a database later)
SELECT * FROM EMPLOYEE;
DROP TABLE EMPLOYEE;

use [COMPANY];
--Inserting the various records into the DEPARTMENT table
INSERT INTO DEPARTMENT VALUES ('Headquarters', '1', '888665555', '19-Jun-71');
INSERT INTO DEPARTMENT VALUES ('Administration', '4', '987654321', '01-Jan-85');
INSERT INTO DEPARTMENT VALUES ('Research', '5', '333445555', '22-May-78');
INSERT INTO DEPARTMENT VALUES ('Automation', '7', '123456789', '06-Oct-05');
--Returns a record set of the populated DEPARTMENT table before dropping it (all tables must be dropped in order to drop a database later)
SELECT * FROM DEPARTMENT;
DROP TABLE DEPARTMENT;

USE master;
--Drops the database from master and this is allowed because all of its tables within have been dropped 
Drop DATABASE [COMPANY];