USE ZDT
GO
-- Change the clustered index when it is NOT the primary key

-- DATABASE PRE-RELEASE PHASE
IF NOT EXISTS
(
	SELECT 1
	FROM sys.indexes i
		INNER JOIN sys.index_columns ic
			ON i.index_id = ic.index_id
			AND i.object_id = ic.object_id
		INNER JOIN sys.columns sc
			ON ic.column_id = sc.column_id
			AND ic.object_id = sc.object_id
	WHERE
		i.name = N'CIX_LargeHeap'
		AND sc.name = N'SomeOtherColumn'
)
BEGIN
	CREATE CLUSTERED INDEX [CIX_LargeHeap] ON dbo.LargeHeap
	(
		SomeOtherColumn
	)
	WITH(DATA_COMPRESSION = PAGE, DROP_EXISTING = ON, ONLINE = ON);
END
GO

-- DATABASE RELEASE PHASE might include changes to procedures which this new CI helps.