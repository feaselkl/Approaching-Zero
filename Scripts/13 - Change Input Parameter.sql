USE ZDT
GO
-- Changing an input parameter on a stored procedure
-- We might need to create a new procedure because calling code
--	has expectations regarding parameters.

-- DATABASE RELEASE PHASE
CREATE OR ALTER PROCEDURE Raleigh2014.IncidentCode_GetIncidentCodes02
(
@IncidentTypeID INT = NULL
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
	WHERE
		it.IncidentTypeID = ISNULL(@IncidentTypeID, it.IncidentTypeID);
END
GO

-- CODE RELEASE PHASE
	-- Switch to a version of the app which passes in IncidentTypeID

-- DATABASE POST-RELEASE PHASE
DROP PROCEDURE IF EXISTS Raleigh2014.IncidentCode_GetIncidentCodes01;
GO
