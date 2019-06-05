USE ZDT
GO
-- Change an identity column from int to bigint
-- PREP WORK
IF NOT EXISTS
(
	SELECT 1
	FROM sys.tables t
	WHERE
		t.name = N'LargeTableBigint'
)
BEGIN
	CREATE TABLE dbo.LargeTableBigint
	(
		Id BIGINT IDENTITY(1,1) NOT NULL,
		SomeUniqueNumber INT NOT NULL,
		ParentKeyId TINYINT NOT NULL,
		SomeColumn VARCHAR(50) NOT NULL,
		SomeOtherColumn VARCHAR(50) NOT NULL,
		CONSTRAINT [PK_LargeTableBigint] PRIMARY KEY CLUSTERED(Id)
	);
END
GO

-- Create a trigger which inserts into both tables.
CREATE OR ALTER TRIGGER [TR_LargeTable_TEMP] ON dbo.LargeTable
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
SET NOCOUNT ON;
	-- Setting identity insertion on requires giving some serious rights to the caller.
	-- If you don't care about the specific IDs getting inserted, you could turn this off,
	-- but that will make it more difficult to piece together which records are in the new table.
	SET IDENTITY_INSERT dbo.LargeTableBigint ON;

	INSERT INTO dbo.LargeTableBigInt
	(
		Id,
		SomeUniqueNumber,
		ParentKeyId,
		SomeColumn,
		SomeOtherColumn
	)
	SELECT
		i.Id,
		i.SomeUniqueNumber,
		i.ParentKeyId,
		i.SomeColumn,
		i.SomeOtherColumn
	FROM INSERTED i
		LEFT OUTER JOIN dbo.LargeTableBigint lt
			ON i.Id = lt.Id
	WHERE
		lt.Id IS NULL;

	UPDATE lt
	SET
		SomeUniqueNumber = i.SomeUniqueNumber,
		ParentKeyId = i.ParentKeyId,
		SomeColumn = i.SomeColumn,
		SomeOtherColumn = i.SomeOtherColumn
	FROM dbo.LargeTableBigint lt
		INNER JOIN INSERTED i
			ON lt.Id = i.Id;

	DELETE lt
	FROM dbo.LargeTableBigint lt
		INNER JOIN DELETED d
			ON d.Id = lt.Id
		LEFT OUTER JOIN INSERTED i
			ON d.Id = i.Id
	WHERE
		i.Id IS NULL;

	SET IDENTITY_INSERT dbo.LargeTableBigint OFF;
END
GO

-- Now start inserting records.
SET NOCOUNT ON;
SET IDENTITY_INSERT dbo.LargeTableBigint ON;
DECLARE
	@LatestIdFinished INT = 0;
DECLARE @IdBatch TABLE
(
	Id INT
);

-- Start from the beginning.  That might be a negative value.
SELECT
	@LatestIdFinished = MIN(Id)
FROM dbo.LargeTable;

WHILE(1=1)
BEGIN
	DELETE FROM @IdBatch;

	INSERT INTO dbo.LargeTableBigint
	(
		Id,
		SomeUniqueNumber,
		ParentKeyId,
		SomeColumn,
		SomeOtherColumn
	)
	OUTPUT INSERTED.Id INTO @IdBatch(Id)
	SELECT TOP(10000)
		lt.Id,
		lt.SomeUniqueNumber,
		lt.ParentKeyId,
		lt.SomeColumn,
		lt.SomeOtherColumn
	FROM dbo.LargeTable lt
		LEFT OUTER JOIN dbo.LargeTableBigint ltwc
			ON lt.Id = ltwc.Id
	WHERE
		-- NOTE:  we are using >= here because the min ID could be MIN(INT) and we can't go below that.
		-- This is slightly less efficient because we're guaranteed to get no more than 9999 rows after
		-- the first batch, but it does let us use one loop instead of a first query and then a loop.
		lt.Id >= @LatestIdFinished
		AND ltwc.Id IS NULL;

	IF(@@ROWCOUNT) = 0
		BREAK;

	RAISERROR('Another batch completed...', 10, 1) WITH NOWAIT;

	SELECT
		@LatestIdFinished = MAX(Id)
	FROM @IdBatch;
END
GO
SET IDENTITY_INSERT dbo.LargeTableBigint OFF;
GO

-- Example calls to show that the trigger works as expected.
-- Note that we insert and update multiple rows.
INSERT INTO dbo.LargeTable
(
	SomeUniqueNumber,
	ParentKeyId,
	SomeColumn,
	SomeOtherColumn
)
VALUES
(51004884, 3, 'Test Column', 'This is a test'),
(51004885, 4, 'Test Column 2', 'This is a test'),
(51004886, 5, 'Test Column 3', 'This is a test');

SELECT TOP(20) * FROM dbo.LargeTable WHERE SomeColumn LIKE 'Test Column%';
SELECT TOP(20) * FROM dbo.LargeTableBigint WHERE SomeColumn LIKE 'Test Column%';

UPDATE dbo.LargeTable
SET SomeOtherColumn = 'This is really a test'
WHERE SomeOtherColumn = 'This is a test';

SELECT TOP(20) * FROM dbo.LargeTable WHERE SomeColumn LIKE 'Test Column%';
SELECT TOP(20) * FROM dbo.LargeTableBigint WHERE SomeColumn LIKE 'Test Column%';

-- DATABASE RELEASE PHASE
	-- Here we can deploy any scripts which need to call the new column.

-- DATABASE POST-RELEASE PHASE
-- Note that this is done in ONE transaction.  This *is* a blocking action, and by doing it all at once, we prevent any weird antics like a last-second insertion.
BEGIN TRANSACTION
	DROP TRIGGER [TR_LargeTable_TEMP];
	-- Rename the old table and its constraint.
	EXEC sp_rename N'dbo.LargeTable', N'LargeTable_DELETEME';
	EXEC sp_rename N'dbo.PK_LargeTable', N'PK_LargeTable_DELETEME', N'OBJECT';
	-- Rename the new table and its constraints.
	EXEC sp_rename N'dbo.LargeTableBigint', N'LargeTable';
	EXEC sp_rename N'dbo.PK_LargeTableBigint', N'PK_LargeTable', N'OBJECT';
COMMIT TRANSACTION

-- Then, after the next release (or whenever you deem it safe), you can drop LargeTable_DELETEME.
DROP TABLE IF EXISTS dbo.LargeTable_DELETEME;
GO
