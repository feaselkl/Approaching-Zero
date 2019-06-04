USE ZDT
GO
-- Remove a column with a constraint

-- DATABASE RELEASE PHASE
IF EXISTS
(
	SELECT 1
	FROM sys.columns sc
	WHERE
		sc.object_id = OBJECT_ID('dbo.LargeTable')
		AND sc.name = N'NonNullableColumnWithDefault'
)
BEGIN
	ALTER TABLE dbo.LargeTable DROP CONSTRAINT [DF_LargeTable_NonNullableColumnWithDefault];
	ALTER TABlE dbo.LargeTable DROP COLUMN NonNullableColumnWithDefault;
END
GO
