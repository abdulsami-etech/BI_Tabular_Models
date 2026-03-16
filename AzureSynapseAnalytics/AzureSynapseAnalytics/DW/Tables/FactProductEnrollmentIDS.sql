CREATE TABLE DW.FactProductEnrollmentIDS (
	SKContact		int				NOT NULL,
	ClinID			nvarchar(50)	NOT NULL,
	ProductIDS		nvarchar(256)	NOT NULL,
	EnrollmentDate	date			NOT NULL,
	SecRegion		varchar(10)		NOT NULL
	)
 WITH (CLUSTERED INDEX (SKContact), DISTRIBUTION = HASH(SKContact))

GO 
	CREATE NONCLUSTERED INDEX [IX_FactProductEnrollmentIDSNew_ProductIDS]
    ON  DW.FactProductEnrollmentIDS([ProductIDS] ASC);