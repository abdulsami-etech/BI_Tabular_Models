CREATE VIEW [DWAppLog].[CCCloud_Enrollment] AS 
SELECT
	ProductIDS AS product,
	ClinID AS ClinID,
	SKContact AS SKContact,
	EnrollmentDate as CreateDate_PT,
    1 as EnrollmentType,
    'Unknown' as EnrollmentName
FROM  [DWC].[FactProductEnrollmentIDS]
WHERE ProductIDS='webClinCheckCloud'
