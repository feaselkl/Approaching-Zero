USE ZDT
GO
-- Create a new clustered index
-- If you have the disk space, you can do this as an online operation,
-- but you'll need approximately 2X the disk space for the index.

-- DATABASE PRE-RELEASE PHASE
IF NOT EXISTS
(
	SELECT 1
	FROM sys.indexes i
	WHERE
		i.name = N'CIX_LargeHeap'
)
BEGIN
	CREATE CLUSTERED INDEX [CIX_LargeHeap] ON dbo.LargeHeap
	(
		SomeColumn
	)
	WITH(DATA_COMPRESSION = PAGE, ONLINE = ON);
END
GO

-- DATABASE RELEASE PHASE might include changes to procedures which this new CI helps.