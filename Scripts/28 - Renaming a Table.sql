USE ZDT
GO
-- Renaming a table

-- DATABASE RELEASE PHASE
BEGIN TRANSACTION
EXEC sp_rename
	@objname = N'dbo.LargeTable',
	@newname = 'TestLargeTable',
	@objtype = NULL;
EXEC (N'CREATE VIEW dbo.LargeTable AS
SELECT
	lt.Id,
	lt.SomeColumn,
	lt.SomeOtherColumn
FROM dbo.LargeTable lt;');
COMMIT TRANSACTION

-- Alter and deploy any procedures which call dbo.LargeTable.

-- DATABASE POST-RELEASE PHASE
DROP VIEW IF EXISTS dbo.LargeTable;
GO
