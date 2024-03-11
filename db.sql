use master;

IF DB_ID('Projekt') IS NOT NULL DROP DATABASE Projekt;

-- If database could not be created due to open connections, abort
IF @@ERROR = 3702 
   RAISERROR('Database cannot be dropped because there are still open connections.', 127, 127) WITH NOWAIT, LOG;

-- Create database
CREATE DATABASE Projekt;
GO

USE Projekt;
GO

CREATE TABLE Processor(
	processorid				INT			 NOT NULL IDENTITY,
	processorname			NVARCHAR(50) NOT NULL,
	corecount				INT			 NOT NULL,
	manufacturer			NVARCHAR(20) NOT NULL,
	socket					NVARCHAR(20) NOT NULL,

	PRIMARY KEY (processorid)
);

CREATE TABLE DisplayAdapter(
	displayid				INT			 NOT NULL IDENTITY,		
	displayname				NVARCHAR(20) NOT NULL,	
	GPUmemory				INT			 NOT NULL,
	manufacturer			NVARCHAR(20) NOT NULL,
	memorytype				NVARCHAR(20) NOT NULL,

	PRIMARY KEY (displayid)
);

CREATE TABLE RAM(
	ramid					INT			 NOT NULL	IDENTITY,			
	memory					NVARCHAR(20) NOT NULL,
	memorytype				NVARCHAR(20) NOT NULL,	

	PRIMARY KEY (ramid)
);

CREATE TABLE Computer(
	computerid			 INT		 NOT NULL	IDENTITY,
	computername		 NVARCHAR(20) NOT NULL,
	displayid			 INT,
	processorid			 INT,
	ramid  				 INT,
	
	PRIMARY KEY (computerid),
	--CONSTRAINT FK_Comp_RAM 
	FOREIGN KEY (ramid) REFERENCES RAM(ramid),
	FOREIGN KEY (processorid) REFERENCES Processor(processorid),
	FOREIGN KEY (displayid) REFERENCES DisplayAdapter(displayid),
);
GO



---------------------------Get data to DataGridView
CREATE PROCEDURE GetAllData
AS
BEGIN
	SELECT computerid as 'id', computername as 'Computer', processorname AS 'CPU', displayname as 'GPU', memory AS 'RAM' FROM Computer c
			JOIN DisplayAdapter d ON c.displayid = d.displayid
			JOIN Processor p ON c.processorid = p.processorid
			JOIN RAM r ON c.ramid = r.ramid	
END
GO

---------------------------Delete selected computer
CREATE PROCEDURE DeleteData(
	@id INT
)
AS
BEGIN
	DELETE	FROM Computer where computerid = @id
END
GO

---------------------------Create new computer
CREATE PROCEDURE CreateData(
	@computername VARCHAR(20),
	@displayname  VARCHAR(20),
	@processorname VARCHAR(20),
	@memory 	  VARCHAR(20)
)
AS
BEGIN
	DECLARE @displayid INT = (SELECT displayid FROM DisplayAdapter where displayname = @displayname)
	DECLARE @processorid INT = (SELECT processorid FROM Processor where processorname = @processorname)
	DECLARE @ramid INT = (SELECT ramid FROM RAM where memory = @memory)
	INSERT INTO Computer (computername, displayid, processorid, ramid)
	VALUES (@computername, @displayid, @processorid, @ramid)
END
GO

---------------------------Update computer
CREATE PROCEDURE UpdateData(
	@id INT,
	@computername VARCHAR(20),
	@displayname  VARCHAR(20),
	@processorname VARCHAR(20),
	@memory 	  VARCHAR(20)
)
AS
BEGIN	
	DECLARE @displayid INT = (SELECT displayid FROM DisplayAdapter where displayname = @displayname)
	DECLARE @processorid INT = (SELECT processorid FROM Processor where processorname = @processorname)
	DECLARE @ramid INT = (SELECT ramid FROM RAM where memory = @memory)
	UPDATE Computer
	SET computername = @computername, displayid = @displayid, processorid = @processorid, ramid = @ramid
	WHERE computerid = @id
END
GO

---------------------------Fill comboBox
CREATE PROCEDURE GetName(
	@index INT
)
AS
BEGIN
	IF(@index = 1)
	BEGIN
		SELECT displayname FROM DisplayAdapter
	END

	IF(@index = 2)
	BEGIN
		SELECT processorname FROM Processor
	END

	IF(@index = 3)
	BEGIN
		SELECT memory FROM RAM
	END
END
GO








INSERT INTO RAM (memory, memorytype)
VALUES  ('XPG 8GB', 'DDR 4'),
		('XPG 4GB', 'DDR 4'),
		('GOODRAM 8GB', 'DDR 4'),
		('XLR8 16GB', 'DDR 4'),
		('XLR8 8GB', 'DDR 4')
GO

INSERT INTO Processor(processorname, corecount, manufacturer, socket)
VALUES  ('Ryzen 9 5900X', 12, 'AMD', 'AM4'),
		('Core i7-11700K', 8, 'INTEL', 'LGA 1200'),
		('Core i9-13900K', 24, 'INTEL', 'LGA 1700')
GO

INSERT INTO DisplayAdapter(displayname, GPUmemory, manufacturer, memorytype)
VALUES  ('GeForce RTX 3060', 12, 'NVIDIA', 'GDDR 6'),
		('GeForce GT 1030', 2, 'NVIDIA', 'DDR 4'),
		('Radeon RX 580 GTS', 8, 'AMD', 'GDDR 5')
GO

INSERT INTO Computer(computername, displayid, processorid, ramid)
VALUES  ('PC1', 1, 1, 1),
		('PC2', 3, 2, 3),
		('PC3', 2, 3, 2)
GO