USE ZDT
GO
-- Shrinking a varchar length
-- We CANNOT shrink a table column without locking the table.
BEGIN TRANSACTION
	--Stop immediately because it locks the table.
	ALTER TABLE dbo.LargeTable ALTER COLUMN SomeOtherColumn VARCHAR(50) NOT NULL;
ROLLBACK TRANSACTION
-- Instead, we will need to add a new column, backfill, drop the old column, and rename.

-- DATABASE PRE-RELEASE PHASE
IF NOT EXISTS
(
	SELECT 1
	FROM sys.columns sc
	WHERE
		sc.object_id = OBJECT_ID('dbo.LargeTable')
		AND sc.name = N'SomeOtherColumn2'
)
BEGIN
	ALTER TABLE dbo.LargeTable ADD SomeOtherColumn2 VARCHAR(50) NULL;
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
		i.name = N'IX_LargeTable_SomeOtherColumn_SomeOtherColumn2'
)
BEGIN
	CREATE NONCLUSTERED INDEX [IX_LargeTable_SomeOtherColumn_SomeOtherColumn2] ON dbo.LargeTable
	(
		SomeOtherColumn
	)
	WHERE
	(
		SomeOtherColumn2 IS NULL
	) WITH(DATA_COMPRESSION = PAGE, ONLINE = ON);
END
	-- Show that we can still query dbo.LargeTable and execute dbo.LargeTable_GetRandomRecords; while this index is building.
GO

-- Create a trigger which inserts into both columns.
CREATE OR ALTER TRIGGER [TR_LargeTable_SomeOtherColumn2_TEMP] ON dbo.LargeTable
AFTER INSERT, UPDATE
AS
BEGIN
SET NOCOUNT ON;
	UPDATE lt
	SET
		SomeOtherColumn2 = i.SomeOtherColumn
	FROM INSERTED i
		INNER JOIN dbo.LargeTable lt
			ON i.Id = lt.Id;
END
GO

-- Example calls to show that the trigger works as expected.
-- Note that we insert and update multiple rows.
INSERT INTO dbo.LargeTable
(
	SomeColumn,
	SomeOtherColumn
)
VALUES
('Test Column', 'This is a test'),
('Test Column 2', 'This is a test'),
('Test Column 3', 'This is a test');

SELECT TOP(10) * FROM dbo.LargeTable ORDER BY Id DESC;

UPDATE dbo.LargeTable
SET SomeOtherColumn = 'This is really a test'
WHERE SomeOtherColumn = 'This is a test';

SELECT TOP(10) * FROM dbo.LargeTable ORDER BY Id DESC;

-- Now start updating records.
SET NOCOUNT ON;
WHILE(1=1)
BEGIN
	UPDATE TOP(10000) lt
	SET 
		SomeOtherColumn2 = LEFT(SomeOtherColumn, 50)
	FROM dbo.LargeTable lt WITH(INDEX([IX_LargeTable_SomeOtherColumn_SomeOtherColumn2]))
	WHERE
		SomeOtherColumn2 IS NULL;

	IF(@@ROWCOUNT) < 10000
		BREAK;
END

-- DATABASE RELEASE PHASE
	-- Here we can deploy any scripts which need to call the new column.

-- DATABASE POST-RELEASE PHASE
-- Note that this is done in ONE transaction.  This *is* a blocking action, and by doing it all at once, we prevent any weird antics like a last-second insertion.
BEGIN TRANSACTION
	DROP INDEX [IX_LargeTable_SomeOtherColumn_SomeOtherColumn2] ON dbo.LargeTable;
	DROP TRIGGER [TR_LargeTable_SomeOtherColumn2_TEMP];
	ALTER TABLE dbo.LargeTable DROP COLUMN SomeOtherColumn;
	EXEC sp_rename N'dbo.LargeTable.SomeOtherColumn2', N'SomeOtherColumn';
COMMIT TRANSACTION
GO
