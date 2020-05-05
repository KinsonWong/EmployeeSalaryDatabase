CREATE DATABASE DB
ON
(NAME='DB',
FILENAME='e:\SQLDatabase\DB.mdf',
SIZE=5,
MAXSIZE=10,
FILEGROWTH=1)

LOG ON
(NAME='DBLog',
FILENAME='e:\SQLDatabase\DBLog.ldf',
SIZE=2,
MAXSIZE=5,
FILEGROWTH=1)

CREATE TABLE Department(
departmentNane varchar(30) NOT NULL ,
departmentNo char(4) NOT NULL
CHECK ((departmentNo LIKE '[1-9][0-9][0-9]' )AND departmentNo NOT LIKE '100'),
departmentNum int NULL,
CONSTRAINT DepartmentPK PRIMARY KEY (departmentNo)
)

CREATE TABLE Position(
positionName varchar(20) NOT NULL,
positionNo char(3) NOT NULL
CHECK ((positionNo LIKE '[0-9][0-9]') AND positionNo NOT LIKE '00'),
insurance NUMERIC(9,2) NULL,
housingFund NUMERIC(9,2) NULL,
basicSalary NUMERIC(9,2) NULL,
rewards NUMERIC(9,2) NULL,
welfare NUMERIC(9,2) NULL,
CONSTRAINT PositionPK PRIMARY KEY (positionNo)
)

CREATE TABLE Employee(
employeeName varchar(20) NOT NULL,
employeeNo char(8) NOT NULL
CHECK((employeeNo LIKE '1[0-9][0-9][0-9][0-9][0-9][0-9]')AND employeeNo NOT LIKE '1000000'),
sex char(2) NULL,
departmentNo char(4) NOT NULL
CHECK ((departmentNo LIKE '[1-9][0-9][0-9]')AND departmentNo NOT LIKE '100'),
positionNo char(3) NOT NULL
CHECK ((positionNo LIKE '[0-9][0-9]') AND positionNo NOT LIKE '00'),
birthday datetime NULL,
telephone char(15) NULL,
CONSTRAINT EmployeePK PRIMARY KEY (employeeNo),
CONSTRAINT EmployeeFk FOREIGN KEY (departmentNo) REFERENCES Department (departmentNo),
CONSTRAINT EmployeeFk2 FOREIGN KEY (positionNo) REFERENCES Position (positionNo)
)

CREATE TABLE Salary(
salary NUMERIC(9,2) DEFAULT 0 NOT NULL
CHECK (salary BETWEEN 0.0 AND 30000.0),
employeeNo char(4) NOT NULL
CHECK ((employeeNo LIKE '1[0-9][0-9][0-9][0-9][0-9][0-9]')AND employeeNo NOT LIKE '1000000'),
sMonth tinyint NOT NULL,
CONSTRAINT SalaryPK PRIMARY KEY (employeeNo,sMonth),
CONSTRAINT SalaryFK FOREIGN KEY (employeeNo) REFERENCES Employee (employeeNo)
)

CREATE INDEX DepartmentNoIdx ON Department (departmentNo)
CREATE INDEX EmployeeNoIdx ON Employee (employeeNo)
CREATE INDEX PositionNoIdx ON Position (positionNo)
CREATE INDEX SalaryIdx ON Salary (salary DESC)

CREATE VIEW SalaryView5000
AS
SELECT a.employeeNo,a.employeeName,d.departmentName,c.positionName,b.salary
FROM Employee a,Salary b,Position c ,Department d
WHERE b.employeeNo=a.employeeNo AND a.positionNo=c.positionNo AND d.departmentNo=a.departmentNo 
AND salary>=5000

CREATE VIEW DepartmentAvgSalaryView
AS
SELECT b.departmentNo,b.departmentName,AVG(salary) salaryAvg
FROM Salary a,Department b,Employee c
WHERE a.employeeNo=c.employeeNo AND b.departmentNo=c.departmentNo
GROUP BY b.departmentName,b.departmentNo

CREATE TRIGGER EmployeeIns
ON Employee FOR INSERT AS
BEGIN
DECLARE @departmentNo char(4)
IF(SELECT COUNT(*) FROM inserted)>1
ROLLBACK
ELSE
BEGIN
SELECT @departmentNo=departmentNo
FROM inserted
UPDATE Department SET departmentNum=departmentNum+1
WHERE departmentNo=@departmentNo
END
END
CREATE TRIGGER EmployeeDel
ON Employee FOR DELETE AS
BEGIN
DECLARE @departmentNo char(4)
IF(SELECT COUNT(*) FROM deleted)>1
ROLLBACK
ELSE
BEGIN
SELECT @departmentNo=departmentNo
FROM deleted
UPDATE Department SET departmentNum=departmentNum-1
WHERE departmentNo=@departmentNo
END
END
CREATE TRIGGER EmployeeUpt
ON Employee FOR UPDATE AS
BEGIN
DECLARE @oldDepartmentNo char(4),@newDepartmentNo char(4)
IF(SELECT COUNT(*) FROM deleted)>1
ROLLBACK
ELSE
BEGIN
SELECT @oldDepartmentNo=departmentNo
FROM deleted
SELECT @newDepartmentNo=departmentNo
FROM inserted
UPDATE Department SET departmentNum=departmentNum-1
WHERE departmentNo=@oldDepartmentNo
UPDATE Department SET departmentNum=departmentNum+1
WHERE departmentNo=@newDepartmentNo
END
END

CREATE TRIGGER SalaryIns
ON Salary FOR INSERT AS
BEGIN 
DECLARE @employeeNo char(8)
IF(SELECT COUNT(*) FROM inserted)>1
ROLLBACK
ELSE
BEGIN
SELECT @employeeNo=employeeNo
FROM inserted
UPDATE Salary SET salary=a.basicSalary+a.rewards+a.welfare-a.insurance-a.housingFund
FROM Position a,Employee b
WHERE b.positionNo=a.positionNo AND b.employeeNo=@employeeNo
END
END

CREATE PROCEDURE proEmployeeSalary (@employeeNo char(8),@sMonth tinyint)
AS
SELECT a.employeeNo,a.employeeName,d.departmentName,c.positionName,b.salary
FROM Employee a,Salary b,Position c,Department d
WHERE b.employeeNo=@employeeNo AND b.sMonth=@sMonth AND b.employeeNo=a.employeeNo AND a.positionNo=c.positionNo AND a.departmentNo=d.departmentNo

CREATE PROCEDURE proDepartmentSalary (@departmentNo char(4))
AS
SELECT a.employeeNo,a.employeeName,d.departmentNo,d.departmentName,c.positionName,b.salary,b.sMonth
FROM Employee a,Salary b,Position c,Department d
WHERE a.departmentNo=@departmentNo AND b.employeeNo=a.employeeNo AND a.positionNo=c.positionNo AND a.departmentNo=d.departmentNo 

CREATE PROCEDURE proDepartmentview (@departmentNo char(4))
AS
SELECT a.departmentNo,a.departmentName,a.departmentNum
FROM Department a
WHERE a.departmentNo=@departmentNo



