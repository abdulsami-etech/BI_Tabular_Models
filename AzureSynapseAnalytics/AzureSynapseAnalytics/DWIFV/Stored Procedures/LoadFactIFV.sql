CREATE PROC [DWIFV].[LoadFactIFV]
    @BatchID [int],
    @LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	set xact_abort on

	declare
        @RowsInserted	int = 0,
        @RowsUpdated	int = 0,
        @dt datetime=getdate()

    if object_id ('tempdb..#GroupedCases') is not null
    drop table #GroupedCases

    create table #GroupedCases with (CLUSTERED INDEX (patient_id), DISTRIBUTION = HASH(patient_id)) as
    SELECT
        pa.patient as patient_id,
        MIN(pa.id) as minPhotoID,
        CONVERT(VARCHAR(32),'Global') as Region,
        CONVERT(date,MIN(pa.creation_date)) as MinPhotoDate,
        MAX(TRY_CONVERT(bigint,pa.order_id)) as IDSOrderId,
        CONVERT(NVARCHAR(128), MAX(pa.owner_clinid)) as CreatedBy,
        CONVERT(BIT,MAX(CASE WHEN COALESCE(pa.photoSetpurpose,'INITIAL') = 'INITIAL' THEN 1 ELSE 0 END)) as IsInitial,
        CONVERT(BIT,NULL) as IsSuccessSim,
        CONVERT(BIGINT,NULL) as SKOrder,
        CONVERT(BIGINT,NULL) as OrderKey,
        CONVERT(Date,NULL) as CCAADate,
        CONVERT(VARCHAR(40),NULL) as DeliverableType,
        CONVERT(NVARCHAR (128),NULL) as ProductType,
        CONVERT(VARCHAR(40),NULL) as TreatmentCategory,
        CONVERT(BIGINT,NULL) as SKContact,
        CONVERT(INT,NULL) as SKIFVStatus,
        CONVERT(INT,NULL) as CCIFVUsage,
        CONVERT(DATE,NULL) as FirstIFVReviewDate,
        CONVERT(BIT,0) as IsReport
    from SrcImages.patient_assets pa
    where pa.asset_role_id=86/*SocialSmile*/
    group by pa.patient

    /*SrcImages.patient_assets is missing China photos. Here is a workaround*/
    INSERT #GroupedCases(patient_id, minPhotoID, Region, MinPhotoDate, IDSOrderId, CreatedBy, IsInitial,IsSuccessSim,IsReport)
    SELECT
        ssu.vpi_md5 as patient_id,
        MIN(ssu.id) as minPhotoID,
        CASE WHEN ssu.region='cn-north-1' Then 'China' Else 'Global' END as Region,
        CONVERT(date,MIN(ssu._time)) as MinPhotoDate,
        MAX(TRY_CONVERT(bigint,iua.vpiOrder)) as IDSOrderId,
        CONVERT(NVARCHAR(128), MAX(ssu.ownedBy)) as CreatedBy,
        CONVERT(BIT,MAX(CASE WHEN COALESCE(iua.psp,'INITIAL') = 'INITIAL' THEN 1 ELSE 0 END)) as IsInitial,
        MAX(CASE WHEN iua.ffresult = 'success' THEN 1 ELSE 0 END) as IsSuccessSim,
        CONVERT(BIT,0) as IsReport
    FROM SrcSplunk.SocialSmileUpload ssu
    JOIN SrcSplunk.ImagesUpdateAsset iua on iua.siaId=ssu.id
    group by ssu.vpi_md5,CASE WHEN ssu.region='cn-north-1' Then 'China' Else 'Global' END

    UPDATE #GroupedCases
    set  IsSuccessSim=1
    from (
        Select fss.vpi_md5,
               CASE WHEN fss.region='cn-north-1' Then 'China' Else 'Global' END as region
        from SrcSplunk.FisPhotorealisticSmile fss
        where fss.response = '201 CREATED'
    ) as SuccessSim
    where  SuccessSim.vpi_md5=#GroupedCases.patient_id and SuccessSim.region=#GroupedCases.region

    UPDATE #GroupedCases
    set  IsSuccessSim=1
    from (
        SELECT
            pa.patient,
            'Global' as Region
        from SrcImages.patient_assets pa
        where pa.asset_role_id=87 group by pa.patient
    ) as SuccessSim
    where  SuccessSim.patient=#GroupedCases.patient_id and SuccessSim.region=#GroupedCases.region

    UPDATE #GroupedCases
    SET
        SKOrder=do.SKOrder,
        OrderKey=do.KeyOrder,
        SKContact=do.SKContact,
        CCAADate=do.CCAADate,
        DeliverableType= do.LICaseSetupDeliverableType ,
        ProductType= do.ProductType,
        TreatmentCategory= do.TreatmentCategory
    from SrcSFDC.Apttus_Config2__Order__c o
    JOIN DW.DimOrderSFDC do on do.SFDCOrderNumber=o.Id
    where o.VIP_Order_ID__c = N'VOI'+CONVERT(nvarchar(32),#GroupedCases.IDSOrderId)


    ;With exludeStaff as (
        SELECT
            gc.patient_id,
            gc.region,
            CASE WHEN CHARINDEX ('$',gc.createdBy)>0 THEN SUBSTRING(gc.createdBy,0,CHARINDEX ('$',gc.createdBy))
                ELSE gc.createdBy
            END as [user_name]
        from #GroupedCases gc
    )
    UPDATE  #GroupedCases
    Set SKContact=dc.SKContact
    from exludeStaff es
    JOIN DW.DimContact dc on es.user_name=dc.ClinID
    where #GroupedCases.SKContact IS NULL  and es.patient_id=#GroupedCases.patient_id and es.region=#GroupedCases.region


    UPDATE #GroupedCases
    SET SKIFVStatus= CASE
            WHEN IsSuccessSim=1 THEN 9000 /*Success*/
            WHEN SKOrder IS NULL THEN 1000 /*Waiting for order to submit*/
            WHEN CCAADate IS NULL THEN 1500 /*Waiting for order to reach CCAA*/
            ELSE 2000 /*Failed*/
            END

    UPDATE #GroupedCases
    Set CCIFVUsage=CCIFVUsage.CCIFVUsage,
        FirstIFVReviewDate= CCIFVUsage.MinSessionDate
    from (SELECT
                 s.SAPOrderNumber,
                 SUM(COALESCE(s.IFVReview,0)+COALESCE(s.IFVModification,0)) as CCIFVUsage,
                 CONVERT(date,MIN(s.SessionStart)) as MinSessionDate
          from DWAppLog.DimSession s
          group by s.SAPOrderNumber
          HAVING SUM(COALESCE(s.IFVReview,0)+COALESCE(s.IFVModification,0))>0
          ) as CCIFVUsage
    where #GroupedCases.OrderKey=CCIFVUsage.SAPOrderNumber

    update #GroupedCases
    SET IsReport=1
    where isInitial=1 AND
    1= CASE
        WHEN MinPhotoDate<'2019-09-01' THEN 0
        WHEN COALESCE(TreatmentCategory,'Primary') <> 'Primary' THEN 0
        WHEN IsSuccessSim=1 THEN 1
        WHEN SKOrder IS NULL THEN 1
        WHEN  ProductType IN (
            'CLEAR_ALIGNER_GO'
            ,'FULL'
            ,'GO_PLUS'
            ,'GO_STD'
            ,'IGO_PLUS'
            ,'IGO_STD'
            ,'EXPRESS_FIVE'
            ,'EXPRESS_MAUI'
            ,'EXPRESS'
            ,'LITE'
            ,'LITE_MAUI'
	        ,'MODERATE_MAUI'
            ,'COMPREHENSIVE_MAUI'
            ,'TEEN') THEN 1
        END
    if object_id ('DWIFV.FactIFVNew', 'U') is not null
	drop table DWIFV.FactIFVNew

	create table DWIFV.FactIFVNew with (CLUSTERED INDEX (patient_id), DISTRIBUTION = HASH(patient_id)) as
	SELECT
		gc.Patient_id ,
	    @BatchID as DWBatchID,
		@dt as InsertDateTime,
        gc.MinPhotoID,
        gc.Region ,
        gc.MinPhotoDate ,
        gc.IDSOrderId ,
        gc.CreatedBy ,
        gc.IsInitial ,
        gc.IsSuccessSim ,
        gc.SKOrder ,
        gc.OrderKey ,
        gc.CCAADate ,
        gc.DeliverableType ,
        gc.TreatmentCategory ,
        gc.ProductType ,
        gc.SKContact ,
        gc.SKIFVStatus ,
        gc.CCIFVUsage,
        gc.FirstIFVReviewDate,
	    gc.IsReport
    FROM #GroupedCases gc

	if object_id ('DWIFV.FactIFV', 'U') is not null
	begin
		if object_id ('DWIFV.FactIFVPrevious', 'U') is not null
			drop table DWIFV.FactIFVPrevious

		rename object DWIFV.FactIFV to FactIFVPrevious
		rename object DWIFV.FactIFVNew to FactIFV
		drop table DWIFV.FactIFVPrevious
	end
	else
	begin
		rename object DWIFV.FactIFVNew to FactIFV
	end

	select @RowsInserted = count(*)
	from DWIFV.FactIFV

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

END