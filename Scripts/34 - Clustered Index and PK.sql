USE ZDT
GO
-- Clustered index is also the primary key

-- DATABASE PRE-RELEASE PHASE
-- This transaction should be very fast.
BEGIN TRANSACTION
ALTER TABLE dbo.LargeTable DROP CONSTRAINT PK_LargeTable;
ALTER TABLE dbo.LargeTable ADD CONSTRAINT [PK_LargeTable] PRIMARY KEY NONCLUSTERED(Id);
COMMIT TRANSACTION
-- This will take a while but will be an online operation.
CREATE CLUSTERED INDEX [CIX_LargeTable] ON dbo.LargeTable
(
	SomeColumn
)
WITH(DATA_COMPRESSION = PAGE, ONLINE = ON);
GO

-- DATABASE RELEASE PHASE might include changes to procedures which this new CI helps.