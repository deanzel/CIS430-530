/*CIS530 - Lab Assignment 2
Name: Dean Choi
ID: 2690159
Object: Creating a Company Database Schema and Populating with BAD Data*/
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

--creating one table in the COMPANY database
use [COMPANY];
--creating the EMPLOYEE table without any primary key restrictions or ‘not null’ constraints

CREATE TABLE dbo.EMPLOYEE (
	Fname		varchar(15),
	Minit		char,
	Lname		varchar(15),
	Ssn			char(9),
	Bdate		date,
	Address		varchar(30),
	Sex			char,
	Salary		decimal(10,2),
	SuperSsn	char(9),
	Dno			int
);




--POPULATING THE COMPANY DATABASE using SQL DML with BAD data
use [COMPANY];


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

SELECT * FROM EMPLOYEE;

USE master;
--Drops the database from master and this is allowed because all of its tables within have been dropped 
Drop DATABASE [COMPANY];