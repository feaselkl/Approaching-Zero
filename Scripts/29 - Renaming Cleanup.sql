USE ZDT
GO
-- Renaming the table back for later scripts.
EXEC sp_rename
	@objname = N'dbo.TestLargeTable',
	@newname = 'LargeTable',
	@objtype = NULL;
GO