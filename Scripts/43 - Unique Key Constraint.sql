USE ZDT
GO
-- Unique key constraints
-- Adding a new unique key constraint requires a schema stability lock after creation.
-- DATABASE PRE-RELEASE PHASE
BEGIN TRANSACTION
	ALTER TABLE dbo.LargeTable ADD CONSTRAINT [UQ_LargeTable_Id] UNIQUE(SomeUniqueNumber);
ROLLBACK TRANSACTION
GO

-- Another option is to create a unique nonclustered index, if you have Enterprise Edition.
-- It will also require a schema stability lock after creation when ONLINE = ON.
-- DATABASE PRE-RELEASE PHASE
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
-- DATABASE PRE-RELEASE PHASE
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
