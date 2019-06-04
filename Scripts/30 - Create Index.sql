USE ZDT
GO
-- Create an index on a column -- easy to do with EE

-- DATABASE PRE-RELEASE PHASE
IF NOT EXISTS
(
	SELECT 1
	FROM sys.indexes i
	WHERE
		i.name = N'IX_LargeTable_SomeColumn'
)
BEGIN
	CREATE NONCLUSTERED INDEX [IX_LargeTable_SomeColumn] ON dbo.LargeTable
	(
		SomeColumn
	) WITH(DATA_COMPRESSION = PAGE, ONLINE = ON);
END
GO
