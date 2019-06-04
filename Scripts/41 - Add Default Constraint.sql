USE ZDT
GO
-- Adding a default constraint.

-- DATABASE PRE-RELEASE PHASE
IF NOT EXISTS
(
	SELECT 1
	FROM sys.default_constraints dc
	WHERE
		dc.name = N'DF_LargeTable_SomeColumn'
)
BEGIN
	ALTER TABLE dbo.LargeTable ADD CONSTRAINT [DF_LargeTable_SomeColumn] DEFAULT (N'Something') FOR SomeColumn;
END
GO
