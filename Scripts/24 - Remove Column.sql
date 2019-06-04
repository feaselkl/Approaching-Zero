USE ZDT
GO
-- Remove a column with no constraints

-- DATABASE POST-RELEASE PHASE
IF EXISTS
(
	SELECT 1
	FROM sys.columns sc
	WHERE
		sc.object_id = OBJECT_ID('dbo.LargeTable')
		AND sc.name = N'SomeNullableColumn'
)
BEGIN
	ALTER TABLE dbo.LargeTable DROP COLUMN SomeNullableColumn;
	ALTER TABLE dbo.LargeTable DROP COLUMN SomeNotNullableColumn;
END
GO
