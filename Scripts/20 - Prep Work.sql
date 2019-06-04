USE ZDT
GO
-- PREP WORK.  Set up before running these examples.
-- Create a table with 4 million rows.  This will cause us
-- to take some time to make changes that are non-metadata.
DROP TABLE IF EXISTS dbo.LargeTable;
GO
CREATE TABLE dbo.LargeTable
(
	Id INT IDENTITY(1,1) NOT NULL,
	SomeColumn VARCHAR(50) NOT NULL,
	SomeOtherColumn VARCHAR(50) NOT NULL,
	CONSTRAINT [PK_LargeTable] PRIMARY KEY CLUSTERED(Id)
);
GO

INSERT INTO dbo.LargeTable
(
	SomeColumn,
	SomeOtherColumn
)
SELECT TOP(4000000)
	REPLICATE('A', 50),
	REPLICATE('Z', 50)
FROM sys.all_columns c1
	CROSS JOIN sys.all_columns c2
GO

--Create a heap table with 4 million rows.  This will cause us
-- to take some time to make changes that are non-metadata.
DROP TABLE IF EXISTS dbo.LargeHeap;
GO
CREATE TABLE dbo.LargeHeap
(
	Id INT IDENTITY(1,1) NOT NULL,
	SomeColumn VARCHAR(50) NOT NULL,
	SomeOtherColumn VARCHAR(50) NOT NULL,
	CONSTRAINT [PK_LargeHeap] PRIMARY KEY NONCLUSTERED(Id)
);
GO

INSERT INTO dbo.LargeHeap
(
	SomeColumn,
	SomeOtherColumn
)
SELECT TOP(4000000)
	REPLICATE('A', 50),
	REPLICATE('Z', 50)
FROM sys.all_columns c1
	CROSS JOIN sys.all_columns c2
GO

--Create a procedure which gets some arbitrary records from LargeTable.
CREATE OR ALTER PROCEDURE dbo.LargeTable_GetRandomRecords
(
@NumberOfRecords INT = 1000
)
AS
BEGIN
	SELECT TOP(@NumberOfRecords)
		lt.Id,
		lt.SomeColumn,
		lt.SomeOtherColumn
	FROM dbo.LargeTable lt
	ORDER BY
		NEWID();
END
GO
