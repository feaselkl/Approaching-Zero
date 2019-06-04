USE ZDT
GO
-- Removing a column from a stored procedure:
-- We need to create a new procedure because calling code expects
--	a column named IncidentDescription.

-- DATABASE RELEASE PHASE
CREATE OR ALTER PROCEDURE Raleigh2014.IncidentCode_GetIncidentCodes01
AS
BEGIN
	SELECT
		ic.IncidentCode,
		ic.IncidentTypeID,
		it.IncidentType
	FROM Raleigh2014.IncidentCode ic
		INNER JOIN Raleigh2014.IncidentType it
			ON ic.IncidentTypeID = it.IncidentTypeID;
END
GO

-- CODE RELEASE PHASE
	-- Switch to a version of the app which does not use IncidentDescription

-- DATABASE POST-RELEASE PHASE
DROP PROCEDURE IF EXISTS Raleigh2014.IncidentCode_GetIncidentCodes;
GO
