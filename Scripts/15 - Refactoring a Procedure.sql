USE ZDT
GO
-- Refactoring a stored procedure but not changing the signature.

-- DATABASE RELEASE PHASE
CREATE OR ALTER PROCEDURE Raleigh2014.IncidentCode_GetIncidentCodes02
(
@IncidentTypeID INT = NULL
)
AS
BEGIN
	-- Here we are modifying the internals of our stored procedure but not
	-- changing the signature--that is, the input parameters and output
	-- result set.
	-- Notice that we can actually change behavior, but as long as we do not
	-- change the signature, it's ZDT safe.

	SET @IncidentTypeID = NULLIF(@IncidentTypeID, 0);

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
