USE ZDT
GO
-- PREP WORK
DROP TABLE IF EXISTS dbo.LargeTable;
GO
CREATE TABLE dbo.LargeTable
(
	Id INT NOT NULL,
	SomeUniqueNumber INT NOT NULL,
	ParentKeyId TINYINT NOT NULL,
	SomeColumn VARCHAR(50) NOT NULL,
	SomeOtherColumn VARCHAR(50) NOT NULL,
	CONSTRAINT [PK_LargeTable] PRIMARY KEY CLUSTERED(Id)
);
GO
WITH
  Pass0 as (select 1 as C union all select 1), --2 rows
  Pass1 as (select 1 as C from Pass0 as A, Pass0 as B),--4 rows
  Pass2 as (select 1 as C from Pass1 as A, Pass1 as B),--16 rows
  Pass3 as (select 1 as C from Pass2 as A, Pass2 as B),--256 rows
  Pass4 as (select 1 as C from Pass3 as A, Pass3 as B),--65,536 rows
  Pass5 as (select 1 as C from Pass4 as A, Pass4 as B),--4.2 billion rows
  Tally as (select ROW_NUMBER() OVER(ORDER BY C) as N from Pass5)
INSERT INTO dbo.LargeTable
(
	Id,
	SomeUniqueNumber,
	ParentKeyId,
	SomeColumn,
	SomeOtherColumn
)
SELECT TOP(10000000)
	t.N,
	t.N,
	t.N % 10,
	REPLICATE('A', 50),
	REPLICATE('Z', 50)
FROM Tally t
GO
