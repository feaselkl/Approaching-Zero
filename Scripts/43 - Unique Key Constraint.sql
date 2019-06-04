USE ZDT
GO
-- Unique key constraints
-- Add a new unique key constraint:  causes blocking!
BEGIN TRANSACTION
	ALTER TABLE dbo.LargeTable ADD CONSTRAINT [UQ_LargeTable_Id] UNIQUE(SomeUniqueNumber);
ROLLBACK TRANSACTION
GO

-- Better is creating a unique nonclustered index, if you have Enterprise Edition.
IF NOT EXISTS
(
	SELECT 1
	FROM sys.indexes i
	WHERE
		i.name = N'IX_LargeTable_SomeUniqueNumber'
)
BEGIN
	CREATE UNIQUE NONCLUSTERED INDEX [IX_LargeTable_SomeUniqueNumber] ON dbo.LargeTable
	(
		SomeUniqueNumber
	) WITH(ONLINE = ON);
END
GO

-- Change a unique index:  drop and recreate
DROP INDEX IF EXISTS [IX_LargeTable_SomeUniqueNumber] ON dbo.LargeTable;
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.indexes i
	WHERE
		i.name = N'IX_LargeTable_SomeUniqueNumber'
)
BEGIN
	CREATE UNIQUE NONCLUSTERED INDEX [IX_LargeTable_SomeUniqueNumber] ON dbo.LargeTable
	(
		SomeUniqueNumber,
		SomeOtherColumn
	) WITH(ONLINE = ON);
END
GO
