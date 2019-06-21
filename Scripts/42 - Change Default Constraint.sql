USE ZDT
GO
-- Change a default constraint:  drop and recreate

-- DATABASE RELEASE PHASE
IF NOT EXISTS
(
	SELECT 1
	FROM sys.default_constraints dc
	WHERE
		dc.name = N'DF_LargeTable_SomeColumn'
		AND dc.definition LIKE '%Something New%'
)
BEGIN
	ALTER TABLE dbo.LargeTable DROP CONSTRAINT [DF_LargeTable_SomeColumn];
	ALTER TABLE dbo.LargeTable ADD CONSTRAINT [DF_LargeTable_SomeColumn] DEFAULT (N'Something New') FOR SomeColumn;
END
GO
