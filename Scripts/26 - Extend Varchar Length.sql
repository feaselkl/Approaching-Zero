USE ZDT
GO
-- Extending a varchar length

-- DATABASE RELEASE PHASE
ALTER TABLE dbo.LargeTable ALTER COLUMN SomeOtherColumn VARCHAR(56) NOT NULL;
GO
