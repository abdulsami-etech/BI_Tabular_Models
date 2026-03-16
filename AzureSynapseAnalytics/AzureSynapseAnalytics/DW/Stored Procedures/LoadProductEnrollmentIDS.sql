CREATE PROC [DW].[LoadProductEnrollmentIDS]
    @BatchID [int],
    @LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	SET XACT_ABORT ON

	DECLARE
		@RowsInserted	int = 0,
		@RowsUpdated	int = 0,
		@dt datetime=getdate()

    IF OBJECT_ID ('tempdb..#Enrollment') IS NOT NULL
    DROP TABLE #Enrollment

    CREATE TABLE #Enrollment WITH (
       DISTRIBUTION = HASH ( [user_name] ),
       CLUSTERED INDEX (user_name)
    ) AS
    WITH tblCnPilotDoctors AS (
        SELECT top 1 WITH TIES
            pd.master_user_id,
            pd.product,
            pd.product_status,
            pd.create_date,
            pd._Region
        FROM SrcIDS.tblCnPilotDoctors pd
        ORDER BY ROW_NUMBER() over (PARTITION BY pd.master_user_id,pd.product ORDER BY CASE WHEN _Region = 'Global' THEN 1 ELSE 0 END)
    )
    SELECT 
        e.user_name, 
        e.product, 
        MIN(e.create_date) as create_date
    FROM (    
        SELECT 
            a.user_name, 
            d.product, 
            CONVERT(date,d.create_date) as create_date, d.product_status
        FROM tblCnPilotDoctors d
        JOIN SrcIDS.tblCnAccounts a ON d.master_user_id = a.master_user_id AND d._Region=a._Region
        WHERE d.product_status IN (0,1)

            UNION ALL

        SELECT 
            a.user_name, 
            pr.product,
            CONVERT(date,pr.create_date) as create_date, 
            1 as product_status
        FROM SrcIDS.tblCnAccounts a
        JOIN tblCnPilotDoctors pd 
            on pd.master_user_id = a.master_user_id 
            and pd.product_status=2 /*regional settings on*/
            and pd._Region=a._Region
        JOIN SrcSFDC.Contact d on a.contact_sfid = d.id
        JOIN SrcSFDC.Account acc on d.accountid = acc.id
        JOIN SrcIDS.tblPuRegionCountryMap rcm on rcm.country_code = acc.shippingcountrycode and rcm._Region=pd._Region
        JOIN SrcIDS.tblCnPilotRegions pr on 
            pr.disable_date IS NULL
            AND pr._Region=rcm._Region
            AND pr.product=pd.product
            AND (pr.region_code = rcm.region_code OR pr.country = acc.shippingcountrycode)
            AND pr.doctor_category = CASE
                        WHEN (N';' + acc.line_of_business__c + N';') like N'%;Invisalign Go;%'
                            AND (N';' + acc.line_of_business__c + N';') like N'%;Invisalign;%'
                            THEN N'INV_AND_ACC' /*Single Account*/
                        WHEN (N';' + acc.line_of_business__c + N';') like N'%;Invisalign Go;%'
                            THEN N'ACC' /*Invisalign Go*/
                        WHEN (N';' + acc.line_of_business__c + N';') like N'%;Invisalign;%'
                            THEN N'INV' /*Invisalign*/
                        WHEN (N';' + acc.line_of_business__c + N';') like N'%;REALINE;%'
                            THEN N'RLN' /*REALINE*/
                        WHEN (N';' + acc.line_of_business__c + N';') like N'%;NUME;%'
                            THEN N'NME' /*NUME*/
            END) e
    GROUP BY e.user_name, e.product
    HAVING MIN(product_status)=1

    IF OBJECT_ID ('DW.FactProductEnrollmentIDSNew', 'U') IS NOT NULL
	DROP TABLE DW.FactProductEnrollmentIDSNew

	CREATE TABLE DW.FactProductEnrollmentIDSNew WITH (CLUSTERED INDEX (SKContact), DISTRIBUTION = HASH(SKContact)) as
	SELECT
		c.SKContact,
	    c.ClinID,
	    e.product AS ProductIDS,
	    e.create_date AS EnrollmentDate,
	    c.SecRegion
    FROM #Enrollment e
	JOIN DW.DimContact c ON c.ClinID=e.[user_name]

	IF OBJECT_ID ('DW.FactProductEnrollmentIDS', 'U') IS NOT NULL
	BEGIN
		IF OBJECT_ID ('DW.FactProductEnrollmentIDSPrevious', 'U') IS NOT NULL
			DROP TABLE DW.FactProductEnrollmentIDSPrevious

		RENAME OBJECT DW.FactProductEnrollmentIDS TO FactProductEnrollmentIDSPrevious
		RENAME OBJECT DW.FactProductEnrollmentIDSNew TO FactProductEnrollmentIDS
		DROP TABLE DW.FactProductEnrollmentIDSPrevious
	END
	ELSE
	BEGIN
		RENAME OBJECT DW.FactProductEnrollmentIDSNew TO FactProductEnrollmentIDS
	END

	CREATE NONCLUSTERED INDEX [IX_FactProductEnrollmentIDSNew_ProductIDS]
    ON  DW.FactProductEnrollmentIDS([ProductIDS] ASC);

	SELECT @RowsInserted = COUNT(*)
	FROM DW.FactProductEnrollmentIDS

	SELECT @RowsInserted AS RowsInserted, @RowsUpdated AS RowsUpdated

END