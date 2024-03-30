/**************** Data Masking************************/
/* Data masking types
--Make any changes on branch1 in the github itself
1) Default : The default mask, masks complete values in the specified column. To specify a mask for a particular column, 
             you have to use the “MASKED WITH” clause. Inside the MASKED WITH clause, you have to specify the FUNCTION that you want to use for 
			 masking. If you want to perform default masking, you use the “default()” function.*/
-- varchar.char,nvarchar --- xxxx
-- Date--1900-01-01
-- INT,BigINT-- 0
-- Decimal,float ---0.00

DROP TABLE IF EXISTS DefaultMask;
--DROP TABLE DefaultMask
     
CREATE TABLE DefaultMask
(
ID		       INT            PRIMARY KEY  IDENTITY (1,1) 
,Name VARCHAR(255)	MASKED WITH (FUNCTION = 'default()') NULL
,BirthDate     DATE		MASKED WITH (FUNCTION = 'default()') NOT NULL
,Social_Security  BIGINT		MASKED WITH (FUNCTION = 'default()') NOT NULL
);
GO

INSERT INTO DefaultMask
(
Name, BirthDate, Social_Security
)
VALUES 
('James Jones',  '1998-06-01', 784562145987),
( 'Pat Rice',  '1982-08-12', 478925416938),
('George Eliot',  '1990-05-07', 794613976431);

SELECT * FROM DefaultMask

/* In the output, you can see the unmasked values. This is because we returned the record as a database user that has full access rights. 
   Let’s create a new user that can only access the DefaultMask table and then select the records using our new user.*/

DROP USER IF EXISTS DefaultMaskTestUser;
-- Drop the user when it will available 
CREATE USER DefaultMaskTestUser WITHOUT LOGIN;

GRANT SELECT ON DefaultMask TO DefaultMaskTestUser;
 -- Provide permission to user to run select command on this table 

EXECUTE AS USER = 'DefaultMaskTestUser';
SELECT USER_NAME()
SELECT * FROM DefaultMask;
 REVERT;
 SELECT USER_NAME()
SELECT * FROM DefaultMask

/*
2) Partial :The default mask hides everything in the column it is applied to. What if we want to partially display the information in the column 
            while leaving some part of it hidden?
			This is where partial masks come in handy. To use a partial mask, you have to pass “partial(start characters, mask, end characters” as 
			the value for the function parameter of the MASKED WITH clause. It is important to mention that the partial mask is only applicable to 
			string type columns.*/
DROP TABLE IF EXISTS PartialMask;
        
CREATE TABLE PartialMask
(
ID		       INT              IDENTITY (1,1) PRIMARY KEY NOT NULL
,Name VARCHAR(255)	MASKED WITH (FUNCTION = 'partial(2, "****",2)') NULL
,Comment   NVARCHAR(255)		MASKED WITH (FUNCTION = 'partial(5, "XXXX", 5)') NOT NULL
);
GO

INSERT INTO PartialMask
(
  Name,  Comment
)
VALUES 
('James Jones',  'The tea was fantastic'),
( 'Pat Rice',  'I like these mangoes' ),
('George Eliot',  'I do not really like this');

SELECT * FROM PartialMask

DROP USER IF EXISTS PartialMaskTestUser;
CREATE USER  PartialMaskTestUser WITHOUT LOGIN;
        
GRANT SELECT ON PartialMask TO PartialMaskTestUser;  
        
EXECUTE AS USER = 'PartialMaskTestUser';  
SELECT * FROM PartialMask
REVERT
/* 
3) Email :The email mask is used to dynamically mask data which is in the email format. The function used is “email()”.
          Let’s create a new table with a column called Email and mask it using an email mask. */
 
DROP TABLE IF EXISTS EmailMask;
        
CREATE TABLE EmailMask
(
  ID	   INT IDENTITY (1,1) PRIMARY KEY NOT NULL
 ,Email VARCHAR(255)	MASKED WITH (FUNCTION =  'email()') NULL
         
);
GO

INSERT INTO EmailMask
(
 Email
)
VALUES 
('nickijames@yahoo.com'),
( 'loremipsum@gmail.com' ),
('geowani@hotmail.com');

DROP USER IF EXISTS EmailMaskTestUser;
CREATE USER EmailMaskTestUser WITHOUT LOGIN;
 
GRANT SELECT ON EmailMask TO EmailMaskTestUser;
 
EXECUTE AS USER = 'EmailMaskTestUser';
SELECT * FROM EmailMask
 
REVERT;

/* 
4) Random :The Random mask is used to mask the integer columns with random values. The range for random values is specified by the random function. 
           Look at the following example.*/
DROP TABLE IF EXISTS RandomMask;
        
CREATE TABLE RandomMask
(
  ID	   INT IDENTITY (1,1) PRIMARY KEY NOT NULL
 ,SSN BIGINT	 MASKED WITH (FUNCTION = 'random(1,99)') NOT NULL   
 ,Age INT MASKED WITH (FUNCTION = 'random(1,9)') NOT NULL   
         
);
GO

INSERT INTO RandomMask
(
 SSN, Age
)
VALUES 
(478512369874, 56),
(697412365824, 78),
(896574123589, 28);

DROP USER IF EXISTS RandomMaskTestUser;
CREATE USER  RandomMaskTestUser WITHOUT LOGIN;
        
GRANT SELECT ON RandomMask TO RandomMaskTestUser;  
        
EXECUTE AS USER = 'RandomMaskTestUser';  
SELECT * FROM RandomMask
        
REVERT;

/* Add Masking in Existing Table: */

DROP TABLE IF EXISTS MaskData

CREATE TABLE MaskData
(
ID		       INT              IDENTITY (1,1) PRIMARY KEY NOT NULL
,Name VARCHAR(255)	
,BirthDate     DATE
,Social_Security  BIGINT
,Email varchar(250)
);
GO

INSERT INTO MaskData
(
Name, BirthDate, Social_Security,Email
)
VALUES 
('James Jones',  '1998-06-01', 784562145987,'James@xyz.com'),
( 'Pat Rice',  '1982-08-12', 478925416938,'Pat@abc.com'),
('George Eliot',  '1990-05-07', 794613976431,'George@mail.com');

SELECT * FROM MaskData
-- Add Default mask in existing column 
ALTER TABLE MaskData  
ALTER COLUMN Name varchar(255) MASKED WITH (FUNCTION = 'default()'); 

DROP USER IF EXISTS RandomMaskTestUser;
CREATE USER  RandomMaskTestUser WITHOUT LOGIN;
        
GRANT SELECT ON MaskData TO RandomMaskTestUser;  
        
EXECUTE AS USER = 'RandomMaskTestUser';  
SELECT * FROM MaskData
        
REVERT;

-- ADD email Masking in Existing column 
ALTER TABLE MaskData  
ALTER COLUMN email varchar(255) MASKED WITH (FUNCTION = 'email()'); 

DROP USER IF EXISTS RandomMaskTestUser;
CREATE USER  RandomMaskTestUser WITHOUT LOGIN;
        
GRANT SELECT ON MaskData TO RandomMaskTestUser;  
        
EXECUTE AS USER = 'RandomMaskTestUser';  
SELECT * FROM MaskData
        
REVERT;

-- Add Random masking in Existing column 

ALTER TABLE MaskData  
ALTER COLUMN Social_Security BIGINT MASKED WITH (FUNCTION = 'random(1,9)'); 

DROP USER IF EXISTS RandomMaskTestUser;
CREATE USER  RandomMaskTestUser WITHOUT LOGIN;
        
GRANT SELECT ON MaskData TO RandomMaskTestUser;  
        
EXECUTE AS USER = 'RandomMaskTestUser';  
SELECT * FROM MaskData
        
REVERT;

-- Change masking function in existing mask table 
ALTER TABLE MaskData  
ALTER COLUMN Social_Security BIGINT MASKED WITH (FUNCTION = 'default()'); 

DROP USER IF EXISTS RandomMaskTestUser;
CREATE USER  RandomMaskTestUser WITHOUT LOGIN;
        
GRANT SELECT ON MaskData TO RandomMaskTestUser;  
        
EXECUTE AS USER = 'RandomMaskTestUser';  
SELECT * FROM MaskData
        
REVERT;


-- Add Partial masking in Existing column 

ALTER TABLE MaskData  
ALTER COLUMN Name varchar(255) MASKED WITH (FUNCTION = 'partial(3,"XXXX",3)'); 

DROP USER IF EXISTS RandomMaskTestUser;
CREATE USER  RandomMaskTestUser WITHOUT LOGIN;
        
GRANT SELECT ON MaskData TO RandomMaskTestUser;  
        
EXECUTE AS USER = 'RandomMaskTestUser';  
SELECT * FROM MaskData
        
REVERT;
/*
A new system catalog view sys.masked_columns defined in SQL Server 2016, inherits sys.columns system view, can be used to retrieve information
about the current Dynamic Data Masking configuration. Value 1 for the is_masked column indicates that this column is masked using a masking function
identified in the masking_function column. The below T-SQL statement is used to retrieve the Dynamic Data Masking information by joining the 
sys.masked_columns view with the sys,tables view as follows: */

SELECT TBLS.name as TableName,MC.NAME ColumnName, MC.is_masked IsMasked, MC.masking_function MaskFunction  
FROM sys.masked_columns AS MC 
JOIN sys.tables AS TBLS   
ON MC.object_id = TBLS.object_id  
--WHERE is_masked = 1;   

/* Drop mask from Column */

ALTER TABLE MaskData
ALTER COLUMN Name DROP MASKED;


 


