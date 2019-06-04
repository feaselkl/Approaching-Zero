USE ZDT
GO
-- Adding a non-nullable column with a default constraint.

-- DATABASE RELEASE PHASE
IF NOT EXISTS
(
	SELECT 1
	FROM sys.columns sc
	WHERE
		sc.object_id = OBJECT_ID('dbo.LargeTable')
		AND sc.name = N'NonNullableColumnWithDefault'
)
BEGIN
	ALTER TABLE dbo.LargeTable ADD NonNullableColumnWithDefault VARCHAR(40) NOT NULL
		CONSTRAINT [DF_LargeTable_NonNullableColumnWithDefault] DEFAULT('Good Default');
END
GO
