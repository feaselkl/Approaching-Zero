USE ZDT
GO
-- Backfilling a nullable column but without a default constraint

-- DATABASE PRE-RELEASE PHASE
IF NOT EXISTS
(
	SELECT 1
	FROM sys.columns sc
	WHERE
		sc.object_id = OBJECT_ID('dbo.LargeTable')
		AND sc.name = N'SomeNonDefaultColumn'
)
BEGIN
	ALTER TABLE dbo.LargeTable ADD SomeNonDefaultColumn VARCHAR(20) NULL;
END
GO
-- For each record, update SomeNonDefaultColumn to be whatever it should be.
-- Note that we want to do this in batches.  In this case, I'll create a supporting index.
-- We can create this index online because we're using Developer/Enterprise Edition.  With Standard Edition, no dice.
IF NOT EXISTS
(
	SELECT 1
	FROM sys.indexes i
	WHERE
		i.name = N'IX_LargeTable_SomeNonDefaultColumn'
)
BEGIN
	CREATE NONCLUSTERED INDEX [IX_LargeTable_SomeNonDefaultColumn] ON dbo.LargeTable
	(
		SomeNonDefaultColumn
	)
	INCLUDE
	(
		SomeColumn
	) WITH(DATA_COMPRESSION = PAGE, ONLINE = ON);
END
	-- Show that we can still query dbo.LargeTable and execute dbo.LargeTable_GetRandomRecords; while this index is building.
GO
-- Now start updating records.
SET NOCOUNT ON;
WHILE(1=1)
BEGIN
	UPDATE TOP(10000) dbo.LargeTable
	SET 
		SomeNonDefaultColumn = LEFT(SomeColumn, 20)
	WHERE
		SomeNonDefaultColumn IS NULL;

	IF(@@ROWCOUNT) < 10000
		BREAK;
END
	-- Show that we can still query dbo.LargeTable and execute dbo.LargeTable_GetRandomRecords; while this index is building.

-- DATABASE RELEASE PHASE
	-- Here we can deploy any scripts which need to call the new column.

-- DATABASE POST-RELEASE PHASE
-- Drop the index if we don't need if after the release.
DROP INDEX IF EXISTS [IX_LargeTable_SomeNonDefaultColumn] ON dbo.LargeTable;
GO
