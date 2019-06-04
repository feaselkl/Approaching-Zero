USE ZDT
GO
-- Changing an input parameter with a table type
-- We need to create a new type and then a new procedure.
-- Prep phase.  This was the original create script.
IF NOT EXISTS
(
	SELECT *
	FROM sys.table_types t
	WHERE
		t.name = N'IncidentTypeType'
)
BEGIN
	CREATE TYPE Raleigh2014.IncidentTypeType AS TABLE
	(
		IncidentTypeID INT
	);
END
GO
CREATE OR ALTER PROCEDURE Raleigh2014.IncidentCode_GetIncidentCodeByTypeList
(
@IncidentTypes Raleigh2014.IncidentTypeType READONLY
)
AS
BEGIN
	SELECT
		ic.IncidentCode,
		ic.IncidentTypeID,
		it.IncidentType
	FROM Raleigh2014.IncidentCode ic
		INNER JOIN Raleigh2014.IncidentType it
			ON ic.IncidentTypeID = it.IncidentTypeID
		INNER JOIN @IncidentTypes itt
			ON ic.IncidentTypeID = itt.IncidentTypeID;
END
GO


-- Now we want to make a change.
-- DATABASE RELEASE PHASE
IF NOT EXISTS
(
	SELECT *
	FROM sys.table_types t
	WHERE
		t.name = N'IncidentTypeType01'
)
BEGIN
	CREATE TYPE Raleigh2014.IncidentTypeType01 AS TABLE
	(
		IncidentTypeID INT,
		IncidentType VARCHAR(55)
	);
END
GO
CREATE OR ALTER PROCEDURE Raleigh2014.IncidentCode_GetIncidentCodeByTypeList01
(
@IncidentTypes Raleigh2014.IncidentTypeType01 READONLY
)
AS
BEGIN
	SELECT
		ic.IncidentCode,
		ic.IncidentTypeID,
		itt.IncidentType
	FROM Raleigh2014.IncidentCode ic
		INNER JOIN @IncidentTypes itt
			ON ic.IncidentTypeID = itt.IncidentTypeID;
END
GO

-- CODE RELEASE PHASE
	-- Switch to a version which uses the new type and procedure.

-- DATABASE POST-RELEASE PHASE
DROP PROCEDURE IF EXISTS Raleigh2014.IncidentCode_GetIncidentCodeByTypeList;
DROP TYPE IF EXISTS Raleigh2014.IncidentTypeType;
GO
