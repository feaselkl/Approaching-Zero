USE ZDT
GO
-- Dropping an index -- can do in SE

-- DATABASE POST-RELEASE PHASE
DROP INDEX IF EXISTS [IX_LargeTable_SomeColumn] ON dbo.LargeTable;
GO