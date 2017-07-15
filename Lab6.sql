/*CIS530 - Lab Assignment 6
Name: Dean Choi
ID: 2690159
Object: Trigger and Store Procedure*/
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

--creating all the tables in the COMPANY database with primary keys and foreign key constraints
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
	Dno			int				not null	default 1,
	Constraint EMPPK
		primary key (Ssn),			-- Set Ssn as primary key
	Constraint EMPSUPERFK
		foreign key (SuperSsn) REFERENCES EMPLOYEE(Ssn) --ON DELETE SET NULL ON UPDATE CASCADE,
);

--Add in the unary one-to-many relationship of Supervisor Ssn to Employee Ssn within the EMPLOYEE TABLE.
/*ALTER TABLE EMPLOYEE
ADD Constraint EMPSUPERFK
		foreign key (SuperSsn) REFERENCES EMPLOYEE(Ssn) ON DELETE SET NULL;*/

--creating the DEPARTMENT table
CREATE TABLE dbo.DEPARTMENT (
	Dname			varchar(15)		not null,
	Dnumber			int				not null,
	MgrSsn			char(9)			not null	default '8886655555',
	MgrStartDate	DATE,
	Constraint DEPTPK
		primary key (Dnumber),		--pk set as Department number
	Constraint DEPTSK
		unique (Dname),		--each Department_Name should be unique as well (could be a secondary key)
	Constraint DEPTMGRFK
		foreign key (MgrSSn) References EMPLOYEE(SSN) --ON DELETE SET DEFAULT ON UPDATE CASCADE
		--foreign key constraint that references a managing employee from the employee table
);

--Since DEPARTMENT table has been created, can add the Department number relationship to the EMPLOYEE TABLE (one-to-many)
ALTER TABLE EMPLOYEE
ADD Constraint EMPDEPTFK
		foreign key (Dno) REFERENCES DEPARTMENT(Dnumber) --ON DELETE SET DEFAULT ON UPDATE CASCADE;

--creating DEPT_LOCATIONS table
CREATE TABLE DEPT_LOCATIONS (
	Dnumber		int				not null,
	Dlocation	varchar(15)		not null,
	primary key (Dnumber, Dlocation),	--created a composite primary key for this table
	Constraint EMPDETFK 
		foreign key (Dnumber) References DEPARTMENT(Dnumber) --ON DELETE CASCADE ON UPDATE CASCADE,
	--foreign key constraint that Dnumber reference comes from DEPARTMENT table
);

--creating DEPENDENT table
CREATE TABLE DEPENDENT(
	Essn			char(9)			not null,
	Dependent_name	varchar(15)		not null,
	Sex				char(1),
	Bdate			date,
	Relationship	varchar(10),
	primary key (Essn, Dependent_name),		--composite primary key of Employee's SSN and the dependent's name
	foreign key (Essn) References EMPLOYEE(Ssn) ON DELETE CASCADE	--foreign key constr where Essn references the Ssn from the EMPLOYEE TABLE
);

--creating PROJECT table, before final WORKS_ON table as that references the primary key of the PROJECT TABLE
CREATE TABLE PROJECT(
	Pname		varchar(15)		not null,
	Pnumber		int				not null,
	Plocation	varchar(15),
	Dnum		int				not null,
	primary key (Pnumber),		--pk set as the Project number
	unique (Pname),				--set Project_Name as a secondary key that must be unique as well
	CONSTRAINT PROJDEPTFK
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


/* Lab 6 - Creating Triggers - Part 1
1). Before creating any trigger for this lab, Alter Table to Drop all the PK, FK, Unique Constraints, Cascade, Check options from the Tables 
Employee and Department for this lab to avoid any possible conflict with a system trigger or any table mutating problem. */

ALTER TABLE EMPLOYEE DROP CONSTRAINT EMPDEPTFK;
ALTER TABLE EMPLOYEE DROP CONSTRAINT EMPSUPERFK;
ALTER TABLE DEPARTMENT DROP CONSTRAINT DEPTMGRFK;
ALTER TABLE DEPT_LOCATIONS DROP CONSTRAINT EMPDETFK;
ALTER TABLE PROJECT DROP CONSTRAINT PROJDEPTFK;


/*2). Write(Create) triggers to implement Constraint EMPDEPTFK in Table Employee based on the following rules as defined in DDL for Employee:
		FK Dno of Employee On Delete SET DEFAULT (= 1 ) and FK Dno of Employee On Update CASCADE of Dnumber PK of Department*/
--Note: these are basic triggers without the SP_Audit_Dept stored procedure incorporated, and we will rewrite them later.
GO
CREATE TRIGGER EMPDEPTFK_ONDELETE ON DEPARTMENT
FOR DELETE AS
	BEGIN
		UPDATE EMPLOYEE SET EMPLOYEE.Dno=DEFAULT
		FROM EMPLOYEE AS E
		JOIN DELETED AS D ON D.Dnumber=E.Dno;
	END;
	GO

CREATE TRIGGER EMPDEPTFK_ONUPDATE ON DEPARTMENT
FOR UPDATE AS
	BEGIN
		DECLARE @NEW_DNUMBER INT
		SELECT @NEW_DNUMBER = I.Dnumber FROM INSERTED I
		UPDATE EMPLOYEE SET EMPLOYEE.Dno=@NEW_DNUMBER
		FROM EMPLOYEE AS E
		JOIN DELETED AS D ON D.Dnumber=E.Dno;
	END;
	GO

/*3). Write (Create) Stored Procedure SP_Audit_Dept that inserts all the history of the data of changes by the trigger you created in 
1) above into a table Audit_Dept_Table. See for the more specific instructions that are given in 2 below.*/
--first create audit table
CREATE TABLE Audit_Dept_Table(
	date_of_change		date,
	old_Dname			varchar(15),
	new_Dname			varchar(15),
	old_Dnumber			int,
	new_Dnumber			int,
	old_Mgrssn			char(9),
	new_Mgrssn			char(9),
	);

--Create SP_Audit_Dept stored procedure
GO
CREATE PROCEDURE SP_Audit_Dept
 @old_Dname		varchar(15), 
 @new_Dname		varchar(15), 
 @old_Dnumber	int,
 @new_Dnumber	int,
 @old_Mgrssn	char(9), 
 @new_Mgrssn	char(9) 
 AS
INSERT INTO Audit_Dept_Table VALUES (GETDATE(), @old_Dname, @new_Dname, @old_Dnumber, @new_Dnumber,@old_Mgrssn, @new_Mgrssn)
GO

/*4). Call the Stored procedure SP_Audit_Dept at the end of your Trigger to record all the history of the changes by the trigger.
This will actually all be done by rewriting the new triggers of EMPDEPTFK_ONDELETE and EMPDEPTFK_ONUPDATE within the next Part 2*/

/*Lab 6 - Part 2 - We will now write the Full triggers that include the SP_Audit_Dept for updating the Employees table when there 
is a change to the Department table. We will first drop our old triggers then rewrite each new one*/
GO
DROP TRIGGER EMPDEPTFK_ONUPDATE;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*2-1). On Update of the trigger, Insert the new record into a table named Audit_Dept_Table as follows: (date_of_change, old_Dname, new_Dname, old_Dnumber,
new_Dnumber, old_Mgrssn, new_Mgrssn)*/
CREATE TRIGGER EMPDEPTFK_ONUPDATE ON DEPARTMENT
FOR UPDATE AS
	BEGIN
		DECLARE @old_Dname		VARCHAR(15);
		DECLARE @old_Dnumber	INT;
		DECLARE @old_Mgrssn		CHAR(9);
		DECLARE @new_Dname		VARCHAR(15);
		DECLARE @new_Dnumber	INT;
		DECLARE @new_Mgrssn		CHAR(9);

		SELECT @NEW_DNUMBER = I.Dnumber FROM INSERTED I
		UPDATE EMPLOYEE SET EMPLOYEE.Dno=@NEW_DNUMBER
		FROM EMPLOYEE AS E
		JOIN DELETED AS D ON D.DNUMBER=E.DNO;

		DECLARE DD CURSOR FOR
		SELECT Dname,Dnumber,MgrSsn
		FROM deleted
		
		DECLARE ID CURSOR FOR
		SELECT Dname,Dnumber,MgrSsn
		FROM inserted

		OPEN DD 
			FETCH NEXT FROM DD INTO @old_Dname,@old_Dnumber,@old_Mgrssn
		OPEN ID
			FETCH NEXT FROM ID INTO @new_Dname,@new_Dnumber,@new_Mgrssn
		WHILE @@FETCH_STATUS=0
			BEGIN
				EXEC SP_Audit_Dept @old_Dname,@new_Dname, @old_Dnumber, @new_Dnumber, @old_Mgrssn,@new_Mgrssn;
				FETCH NEXT FROM DD INTO @old_Dname,@old_Dnumber,@old_Mgrssn
				FETCH NEXT FROM ID INTO @new_Dname,@new_Dnumber,@new_Mgrssn
			END
	END;
	CLOSE DD
	DEALLOCATE DD
	CLOSE ID
	DEALLOCATE ID;
GO


DROP TRIGGER EMPDEPTFK_ONDELETE;

Go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*2-2). On Delete of the trigger, Insert the changes into Audit_ Dept_Table table as well. Since there is no new record for delete, 
so insert NULL for the new record columns new_Dname, new_Dnumber, new_Mgrssn of Audit_ Dept_Table.*/
CREATE TRIGGER EMPDEPTFK_ONDELETE ON DEPARTMENT
FOR DELETE AS 
	BEGIN
		DECLARE @old_Dname		VARCHAR(15);
		DECLARE @old_Dnumber	INT;
		DECLARE @old_Mgrssn		CHAR(9);

		UPDATE EMPLOYEE SET EMPLOYEE.Dno=DEFAULT
		FROM EMPLOYEE AS E
		JOIN DELETED AS D ON D.DNUMBER=E.DNO;

		DECLARE Department CURSOR FOR
		SELECT Dname,Dnumber,MgrSsn
		FROM deleted
		
		OPEN Department 
			FETCH NEXT FROM Department INTO @old_Dname,@old_Dnumber,@old_Mgrssn
		WHILE @@FETCH_STATUS=0
			BEGIN
				EXEC SP_Audit_Dept @old_Dname,NULL, @old_Dnumber,NULL, @old_Mgrssn, NULL;
				FETCH NEXT FROM Department INTO @old_Dname,@old_Dnumber,@old_Mgrssn
			END
	END;
	
	CLOSE Department
	DEALLOCATE Department;
GO

--POPULATING THE COMPANY DATABASE using SQL DML with the given data
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



use [COMPANY];
--Now we insert the various records into the DEPARTMENT table
INSERT INTO DEPARTMENT VALUES ('Headquarters', '1', '888665555', '1971-06-19');
INSERT INTO DEPARTMENT VALUES ('Administration', '4', '987654321', '1975-01-01');
INSERT INTO DEPARTMENT VALUES ('Research', '5', '333445555', '1978-05-22');
INSERT INTO DEPARTMENT VALUES ('Automation', '7', '123456789', '2006-10-05');


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

use [COMPANY];
--Insert into DEPT_LOCATIONS table
INSERT INTO DEPT_LOCATIONS VALUES
(1, 'Houston'),
(4, 'Stafford'),
(5, 'Bellaire'),
(5, 'Sugarland'),
(5, 'Houston');

use [COMPANY];
--Insert into PROJECT Table
INSERT INTO PROJECT VALUES
('ProductX', 1, 'Bellaire', 5),
('ProductY', 2, 'Sugarland', 5),
('ProductZ', 3, 'Houston', 5),
('Computerization', 10, 'Stafford', 4),
('Reorganization', 20, 'Houston', 1),
('Newbenefits', 30, 'Stafford', 4);

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
GO


--From previous labs, Add yourself to the database (to Employee table). Show content of your view again.
use [COMPANY];
INSERT INTO EMPLOYEE VALUES ('Dean', 'J', 'Choi', '867530986', '1986-10-12', '8993 Creek Ln, Bview Hts, OH', 'M', 99999, '888665555', 4);
INSERT INTO WORKS_ON VALUES ('867530986', 10, 21.5), ('867530986', 20, 16.8); 
GO


--Lab 6 - Part 3 - Confirm activity of the Triggers with DML on Department table.
use [COMPANY];
--3-1).Before trigger and DML update
SELECT *
FROM DEPARTMENT;
SELECT *
FROM EMPLOYEE;
SELECT *
FROM Audit_Dept_Table;
GO
UPDATE DEPARTMENT
SET Dnumber = 99
WHERE Dnumber = 4;
GO
--After trigger and DML update
SELECT *
FROM DEPARTMENT;	--The Department of Administration which was Dnumber 4 has been changed to 99.
SELECT *
FROM EMPLOYEE;		--All Employee's who were in Dno 4 are now in Dno 99.
SELECT *
FROM Audit_Dept_Table;	--The "audit" / change of the number of Dept 4 to Dept 99 has been recorded with the date.

--3-2). Before trigger and DML delete
SELECT *
FROM DEPARTMENT;
SELECT *
FROM EMPLOYEE;
SELECT *
FROM Audit_Dept_Table;
GO
DELETE DEPARTMENT
WHERE Dnumber = 5;
GO
--After trigger and DML delete
SELECT *
FROM DEPARTMENT;	--The Department of Research, Dnumber 5, has been deleted from the table.
SELECT *
FROM EMPLOYEE;	--All employees who were in Dno 5, are now in Dno 1 as that is the DEFAULT.
SELECT *
FROM Audit_Dept_Table;	--The deletion of the Research Dept (Dnumber 5) has been recorded in the Audit table.


USE master;
--Drops the database from master and this is allowed because all of its tables within have been dropped 
Drop DATABASE [COMPANY];