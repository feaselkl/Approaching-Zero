-- Cleanup script.  Run this to remove all remaining objects.
USE ZDT
GO
DROP PROCEDURE IF EXISTS Raleigh2014.IncidentCode_GetIncidentCodes;
DROP PROCEDURE IF EXISTS Raleigh2014.IncidentCode_GetIncidentCodes01;
DROP PROCEDURE IF EXISTS Raleigh2014.IncidentCode_GetIncidentCodes02;
DROP PROCEDURE IF EXISTS Raleigh2014.IncidentCode_GetIncidentCodeByTypeList;
DROP TYPE IF EXISTS Raleigh2014.IncidentTypeType;
DROP PROCEDURE IF EXISTS Raleigh2014.IncidentCode_GetIncidentCodeByTypeList01;
DROP TYPE IF EXISTS Raleigh2014.IncidentTypeType01;

DROP PROCEDURE IF EXISTS dbo.LargeTable_GetRandomRecords;
DROP TABLE IF EXISTS dbo.LargeTable;
DROP TABLE IF EXISTS dbo.LargeHeap;
DROP VIEW IF EXISTS dbo.LargeTable;

DROP TABLE IF EXISTS dbo.ParentTable;
DROP TABLE IF EXISTS dbo.LargeTableWithConstraints;
DROP TABLE IF EXISTS dbo.LargeTable_DELETEME;

DROP TABLE IF EXISTS dbo.LargeTableSwitch;
DROP TABLE IF EXISTS dbo.LargeTableBigint;