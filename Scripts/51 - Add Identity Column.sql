USE ZDT
GO
-- Add an identity column to a table missing one

-- DATABASE PRE-RELEASE PHASE
CREATE TABLE dbo.LargeTableSwitch
(
	Id INT IDENTITY(1,1) NOT NULL,
	SomeUniqueNumber INT NOT NULL,
	ParentKeyId TINYINT NOT NULL,
	SomeColumn VARCHAR(50) NOT NULL,
	SomeOtherColumn VARCHAR(50) NOT NULL,
	CONSTRAINT [PK_LargeTableSwitch] PRIMARY KEY CLUSTERED(Id)
);

BEGIN TRANSACTION
	ALTER TABLE dbo.LargeTable SWITCH TO dbo.LargeTableSwitch;
	DROP TABLE dbo.LargeTable;
	EXEC sp_rename N'dbo.LargeTableSwitch', 'LargeTable';
	EXEC sp_rename N'dbo.PK_LargeTableSwitch', N'PK_LargeTable', N'OBJECT';
	--We have a rough idea of the max value so let's set to a much higher number to avoid collision.
	DBCC CHECKIDENT('dbo.LargeTable', RESEED, 25000000);
COMMIT TRANSACTION
GO

-- Scripts to test the process.
SELECT TOP(10) * FROM dbo.LargeTable;
SELECT TOP(10) * FROM dbo.LargeTableSwitch;
SELECT
	name,
	is_identity
FROM sys.columns
WHERE
	object_id = OBJECT_ID('dbo.LargeTable');
GO
