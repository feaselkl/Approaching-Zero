USE ZDT
GO
-- Creating a new procedure.
-- CREATE OR ALTER syntax introduced in SQL Server 2016.

-- DATABASE RELEASE PHASE
CREATE OR ALTER PROCEDURE Raleigh2014.IncidentCode_GetIncidentCodes
AS
BEGIN
	SELECT
		ic.IncidentCode,
		ic.IncidentDescription,
		ic.IncidentTypeID
	FROM Raleigh2014.IncidentCode ic;
END
GO

-- CODE RELEASE PHASE
	-- Run a simple console app which takes results and displays a message on the screen.
EXEC Raleigh2014.IncidentCode_GetIncidentCodes;
GO
