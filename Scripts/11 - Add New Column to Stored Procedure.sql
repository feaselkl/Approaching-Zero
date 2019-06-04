USE ZDT
GO
-- Adding a new column to an existing stored procedure:
-- Note that your code generation mechanism might require ordering remain consistent.
--		That's something to check during testing to ensure you don't break anything.

--DATABASE RELEASE PHASE
CREATE OR ALTER PROCEDURE Raleigh2014.IncidentCode_GetIncidentCodes
AS
BEGIN
	SELECT
		ic.IncidentCode,
		ic.IncidentDescription,
		ic.IncidentTypeID,
		it.IncidentType
	FROM Raleigh2014.IncidentCode ic
		INNER JOIN Raleigh2014.IncidentType it
			ON ic.IncidentTypeID = it.IncidentTypeID;
END
GO
