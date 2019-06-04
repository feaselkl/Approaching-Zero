USE ZDT
GO
-- Adding a nullable column.

-- DATABASE RELEASE PHASE
IF NOT EXISTS
(
	SELECT 1
	FROM sys.columns sc
	WHERE
		sc.object_id = OBJECT_ID('dbo.LargeTable')
		AND sc.name = N'SomeNullableColumn'
)
BEGIN
	ALTER TABLE dbo.LargeTable ADD SomeNullableColumn VARCHAR(20) NULL;
END
GO
