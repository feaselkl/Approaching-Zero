USE ZDT
GO
-- Reseed an identity column

-- This requires a schema modification lock but is fast.
-- DATABASE RELEASE PHASE
DBCC CHECKIDENT('dbo.LargeTable', RESEED, 1);
GO