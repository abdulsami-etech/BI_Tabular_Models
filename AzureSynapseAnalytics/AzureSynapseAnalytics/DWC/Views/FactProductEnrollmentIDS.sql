CREATE VIEW [DWC].[FactProductEnrollmentIDS] AS
SELECT
    pe.SKContact,
    pe.ClinID,
    pe.ProductIDS,
    pe.EnrollmentDate,
    pe.SecRegion as Region
FROM DW.FactProductEnrollmentIDS pe
INNER JOIN dwglobal.GeographyRegion d
    ON d.RegionGroup = pe.SecRegion AND d.dataset='DWC'