CREATE PROC [DW].[LoadFactVolume] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit],@TreatmentCategory varchar (255),@RowsInserted int out,@RowsUpdated int out AS
BEGIN
	set nocount on
	set xact_abort on

	DECLARE @RowsInserted_IDS_MES	int = 0
		,	@RowsUpdated_IDS_MES	int = 0
		,	@RowsInserted_SFDC	int = 0
		,	@RowsUpdated_SFDC	int = 0
		-- ,	@RowsInserted	int = 0
		-- ,	@RowsUpdated	int = 0
		
	--DECLARE @TreatmentCategory	VARCHAR (255) = 'Primary'

	DECLARE @CurrentDateTime DATETIME = GETUTCDATE();
	DECLARE @CancelledMaxStatusDate DATE;
	SELECT @CancelledMaxStatusDate = ISNULL(MAX(StatusDate), '1900-01-01') FROM [DW].[FactVolume]  WHERE SKOrderStatus =  108
	
	IF OBJECT_ID(N'tempdb..#TempFactVolumeIncrementalIDs') IS NOT NULL DROP TABLE #TempFactVolumeIncrementalIDs
	CREATE TABLE #TempFactVolumeIncrementalIDs WITH (distribution = round_robin, heap) AS 
	
SELECT DISTINCT uo.object_key AS object_key, 80 AS SKOrderStatus FROM SrcMESCorp.uda_order uo
WHERE uo.ADLSTimestamp >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01')
AND uo.at_AllMaterialRecdTime_S IS NOT NULL

	
	IF OBJECT_ID(N'tempdb..#TempFactVolumeIncrementalIDs1') IS NOT NULL DROP TABLE #TempFactVolumeIncrementalIDs1
	CREATE TABLE #TempFactVolumeIncrementalIDs1 WITH (distribution = round_robin, heap) AS 

SELECT vip_order_id, SKOrderStatus, _Region FROM (
SELECT DISTINCT posh.vip_order_id AS vip_order_id, 100 AS SKOrderStatus, posh._Region 
, rank() over (partition by vip_order_id order by case when _Region = 'Global' then 1 else 0 end) as rnk
FROM SrcIDS.tblpuorderstatushistory posh 
WHERE posh.ADLSTimestamp >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01')
AND posh.event_type IN ('ClinCheckAccepted','ClinCheckAutoAccepted','FirstSevenTreatmentPurchased')
) osh WHERE rnk =1	
		
UNION ALL

SELECT vip_order_id, SKOrderStatus, _Region FROM (
SELECT DISTINCT posh.vip_order_id AS vip_order_id, 108 AS SKOrderStatus, posh._Region 
, rank() over (partition by vip_order_id order by case when _Region = 'Global' then 1 else 0 end) as rnk
FROM SrcIDS.tblpuorderstatushistory posh 
WHERE posh.ADLSTimestamp >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01')
AND posh.event_type = 'OrderCancelled'
) osh WHERE rnk =1	


UNION ALL

SELECT vip_order_id, SKOrderStatus, _Region FROM (
SELECT DISTINCT posh.vip_order_id AS vip_order_id, 118 AS SKOrderStatus, posh._Region 
, rank() over (partition by vip_order_id order by case when _Region = 'Global' then 1 else 0 end) as rnk
FROM SrcIDS.tblpuorderstatushistory posh 
WHERE posh.ADLSTimestamp >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01')
AND posh.event_type = 'OrderCancelled'
) osh WHERE rnk =1		
		
UNION ALL

SELECT vip_order_id, SKOrderStatus, _Region FROM (
SELECT DISTINCT osh.vip_order_id AS vip_order_id, 40 AS SKOrderStatus, osh._Region 
, rank() over (partition by vip_order_id order by case when _Region = 'Global' then 1 else 0 end) as rnk
FROM SrcIDS.tblPuOrderStatusHistory osh
WHERE osh.event_type in ('PaperFormSubmitted','TreatmentFormSubmitted','Orderinitiated','RetainerOrderCreated')
and osh.ADLSTimestamp >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01')
) osh WHERE rnk =1

UNION ALL

SELECT vip_order_id, SKOrderStatus, _Region FROM (
SELECT DISTINCT osh.vip_order_id AS vip_order_id, 85 AS SKOrderStatus, osh._Region 
, rank() over (partition by vip_order_id order by case when _Region = 'Global' then 1 else 0 end) as rnk
FROM SrcIDS.tblPuOrderStatusHistory osh
WHERE osh.event_type in ('ClinCheckUnderDevelopment','ClinCheckAwaitingApproval', 'ConvertOrderfromUnknown','OrderChangeSwitch', 'GenerateMTP', 'MTPModifyClinCheck')
and osh.ADLSTimestamp >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01')
) osh WHERE rnk =1

UNION ALL

SELECT vip_order_id, SKOrderStatus, _Region FROM (
SELECT DISTINCT osh.vip_order_id AS vip_order_id, 82 AS SKOrderStatus, osh._Region 
, rank() over (partition by vip_order_id order by case when _Region = 'Global' then 1 else 0 end) as rnk
FROM SrcIDS.tblPuOrderStatusHistory osh
WHERE osh.event_type in ('ClinCheckModified') --and osh.Region = 'Global' 
and osh.ADLSTimestamp >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01')
) osh WHERE rnk =1

UNION ALL

SELECT vip_order_id, SKOrderStatus, _Region FROM (
SELECT DISTINCT osh.vip_order_id AS vip_order_id, 60 AS SKOrderStatus, osh._Region 
, rank() over (partition by vip_order_id order by case when _Region = 'Global' then 1 else 0 end) as rnk
FROM SrcIDS.tblPuOrderStatusHistory osh
WHERE osh.event_type in ('MaterialsRequired','ClinicalHold') --and osh.Region = 'Global' 
and osh.ADLSTimestamp >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01')
) osh WHERE rnk =1
			  
UNION ALL

SELECT vip_order_id, SKOrderStatus, _Region FROM (
SELECT DISTINCT osh.vip_order_id AS vip_order_id, 109 AS SKOrderStatus, osh._Region 
, rank() over (partition by vip_order_id order by case when _Region = 'Global' then 1 else 0 end) as rnk
FROM SrcIDS.tblPuOrderStatusHistory osh
WHERE osh.event_type in ('ShipmentScheduled')  
and osh.ADLSTimestamp >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01')
) osh WHERE rnk =1

UNION ALL

SELECT vip_order_id, SKOrderStatus, _Region FROM (
SELECT DISTINCT tsh.primary_vip_order_id AS vip_order_id, 81 AS SKOrderStatus, tsh._Region 
, rank() over (partition by primary_vip_order_id order by case when _Region = 'Global' then 1 else 0 end) as rnk
FROM SrcIDS.tblPuTreatmentStatusHistory tsh
WHERE tsh.ADLSTimestamp >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01')
and tsh.tx_status_id = 2502
) tsh WHERE rnk =1

UNION ALL

SELECT vip_order_id, SKOrderStatus, _Region FROM (
SELECT DISTINCT tsh.primary_vip_order_id AS vip_order_id, 101 AS SKOrderStatus, tsh._Region 
, rank() over (partition by primary_vip_order_id order by case when _Region = 'Global' then 1 else 0 end) as rnk
FROM SrcIDS.tblPuTreatmentStatusHistory tsh
WHERE tsh.ADLSTimestamp >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01')
and tsh.tx_status_id = 2641
) tsh WHERE rnk =1;


IF OBJECT_ID(N'tempdb..#TempFactVolumeIncrementalIDs2') IS NOT NULL DROP TABLE #TempFactVolumeIncrementalIDs2
	CREATE TABLE #TempFactVolumeIncrementalIDs2 WITH (distribution = round_robin, heap) AS 
SELECT DISTINCT likp.[VBELN] AS VBELN, 110 AS SKOrderStatus FROM [SrcSAP].[LIKP] likp
WHERE  likp.[WADAT_IST]  <> '00000000'
AND likp.ADLSTimestamp  >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01')

	
	
IF OBJECT_ID(N'tempdb..#SrcSFDC_Apttus_Config2__Order__c') IS NOT NULL DROP TABLE #SrcSFDC_Apttus_Config2__Order__c
CREATE TABLE #SrcSFDC_Apttus_Config2__Order__c WITH (distribution = round_robin, heap) AS
SELECT try_convert(bigint,sfo.SAP_Order_ID__C) as SAP_Order_ID__C
, try_convert(bigint,SUBSTRING(sfo.vip_order_id__C,4,10)) as vip_order_id__C
, sfo.Treatment_Location__C
, sfo.Apttus_Config2__SoldToAccountId__c
, sfo.Apttus_Config2__ShipToAccountId__c
, sfo.Apttus_Config2__PrimaryContactId__c
, sfo.Patient_ID__c
, sfo.Treatment_Category__C
, sfo.Contact_ID__c
, sfo.Professional_Category__C
, sfo.Treatment_ID_Number__c
, sfo.Sold_To_Account_Number__c
, sfo.Ship_To_Account_Number__c
, sfo.ClinId__c
, sfo.Id
, sfo.Name
, sfo.Receipt_Date1__C
, sfo.CCA_Date1__C
, sfo.CCA_Date__C
, sfo.Cancelled_Date1__c
, sfo.ADLSTimestamp
FROM SrcSFDC.Apttus_Config2__Order__c sfo
WHERE sfo.Treatment_Category__C = @TreatmentCategory

	
	IF OBJECT_ID(N'tempdb..#Temp_IDS_MES') IS NOT NULL DROP TABLE #Temp_IDS_MES
	CREATE TABLE #Temp_IDS_MES WITH (distribution = round_robin, heap) AS 
	
-- SKOrderStatus 100

    SELECT	DISTINCT sfo.SAP_Order_ID__C AS SAPOrderNumber
		-- ,	REPLACE(sfo.VIP_Order_ID__C,'VOI','') as IDSOrderNumber
		,	sfo.VIP_Order_ID__C as IDSOrderNumber
        ,	NULL as IsRI
        ,	NULL as OrderType
		,	1 as IsKeyStatus
        ,	100 AS SKOrderStatus
		--,   hc.SKContact
		--,	ho.SKOrder
		--,	ha1.SKAccount AS SKAccountSoldTo
		--,	ha2.SKAccount AS SKAccountShipTo
		--,	ha3.SKAccount AS SKAccountTreatmentLocation
        ,	posh.cc_accept_date AS StatusDate
        ,	a.ShippingCountryCode as CountryCode
		--,	gh.SecRegion
        ,	sfo.Patient_ID__c AS PatientSFID
        ,	CONVERT(DATE, null) as ReceiptDate
        ,	sapd.PRODH ProductHierarchy
        ,	sapd.ZZDELI_TYPE DeliverableType
        ,	sapd.ZZTREAT_OPT TreatmentOption
		,	sfo.Treatment_Category__C AS TreatmentCategory
		,	TRY_CONVERT(INT, sapd.MATNR) AS MaterialNumber
		,	TRY_CONVERT(INT, sapd.PRCTR) AS ProfitCenter
		,	sfo.Contact_ID__c  AS ContactNumber
		,	sfo.Professional_Category__C AS ProfCat
		,	sfo.Treatment_ID_Number__c AS TreatmentID
		,	sfo.Sold_To_Account_Number__c AS SoldTo
		,	sfo.Ship_To_Account_Number__c AS ShipTo
		,	a.Account_Number__c AS TreatmentLocation
		,	sapd.PSTYV AS ItemCategory
		,	sfo.ClinId__c AS ClinID
		,	sfo.Id AS SFOrderId
		,	sfo.Name AS SFOrderNumber
		,	CASE WHEN sld.Type = 'Group' AND sld.ParentID IS NULL THEN 'Yes' ELSE 'No' END IsDSO
		,	posh.ADLSTimestamp
		,	'IDS' AS Source
		,	sfo.Apttus_Config2__PrimaryContactId__c
		,	sfo.Apttus_Config2__SoldToAccountId__c
		,	sfo.Apttus_Config2__ShipToAccountId__c
		,	a.id
		,	posh._Region
    FROM SrcIDS.tblpuorderstatushistory posh
	INNER JOIN #TempFactVolumeIncrementalIDs1 tmp1 ON posh.vip_order_id = tmp1.vip_order_id and tmp1.SKOrderStatus = 100 and posh._Region = tmp1._Region
    INNER JOIN #SrcSFDC_Apttus_Config2__Order__c sfo ON posh.vip_order_id = sfo.vip_order_id__C --SUBSTRING(sfo.vip_order_id__C,4,10)
    INNER JOIN SrcSFDC.Account a ON sfo.Treatment_Location__C = a.id
	INNER JOIN SrcSFDC.Account sld ON sfo.Apttus_Config2__SoldToAccountId__c = sld.id
    INNER JOIN SrcSAP.VBAP sapd ON RIGHT(CONCAT('000',sfo.SAP_Order_ID__C),10)= sapd.VBELN
    WHERE sfo.Treatment_Category__C = @TreatmentCategory
        AND sapd.PSTYV IN ('Z001','Z002','Z003','Z004','Z005','Z006','Z008')
        AND sapd.ZZTREAT_OPT <> 'UNKNOWN'
        AND posh.event_type IN ('ClinCheckAccepted','ClinCheckAutoAccepted','FirstSevenTreatmentPurchased') 
    	
			
    UNION ALL
	

-- SKOrderStatus 108
    SELECT	DISTINCT sfo.SAP_Order_ID__C AS SAPOrderNumber
		-- ,	REPLACE(sfo.VIP_Order_ID__C,'VOI','') as IDSOrderNumber
		,	sfo.VIP_Order_ID__C as IDSOrderNumber
        ,	NULL as IsRI
        ,	NULL as OrderType
		,	1 as IsKeyStatus
        ,	108 AS SKOrderStatus
		--,   hc.SKContact
		--,	ho.SKOrder
		--,	ha1.SKAccount AS SKAccountSoldTo
		--,	ha2.SKAccount AS SKAccountShipTo
		--,	ha3.SKAccount AS SKAccountTreatmentLocation
        ,	posh.cancelled_date AS StatusDate
        ,	a.ShippingCountryCode AS CountryCode 
		--,	gh.SecRegion
        ,	sfo.Patient_ID__c AS PatientSFID
        ,	CONVERT(DATE, sfo.Receipt_Date1__c) AS ReceiptDate
        ,	t.ProductHierarchy
        ,	sapd.ZZDELI_TYPE DeliverableType
        ,	sapd.ZZTREAT_OPT TreatmentOption
		,	sfo.Treatment_Category__C AS TreatmentCategory
		,	TRY_CONVERT(INT, sapd.MATNR) AS MaterialNumber
		,	TRY_CONVERT(INT, sapd.PRCTR) AS ProfitCenter
		,	sfo.Contact_ID__c  AS ContactNumber
		,	sfo.Professional_Category__C AS ProfCat
		,	sfo.Treatment_ID_Number__c AS TreatmentID
		,	sfo.Sold_To_Account_Number__c AS SoldTo
		,	sfo.Ship_To_Account_Number__c AS ShipTo
		,	a.Account_Number__c AS TreatmentLocation
		,	sapd.PSTYV AS ItemCategory
		,	sfo.ClinId__c AS ClinID
		,	sfo.Id AS SFOrderId
		,	sfo.Name AS SFOrderNumber
		,	CASE WHEN sld.Type = 'Group' AND sld.ParentID IS NULL THEN 'Yes' ELSE 'No' END IsDSO
		,	posh.ADLSTimestamp
		,	'IDS' AS Source
		,	sfo.Apttus_Config2__PrimaryContactId__c
		,	sfo.Apttus_Config2__SoldToAccountId__c
		,	sfo.Apttus_Config2__ShipToAccountId__c
		,	a.id
		,	posh._Region
    FROM SrcIDS.tblpuorderstatushistory posh
	INNER JOIN #TempFactVolumeIncrementalIDs1 tmp1 ON posh.vip_order_id = tmp1.vip_order_id and tmp1.SKOrderStatus = 108 and posh._Region = tmp1._Region
    INNER JOIN #SrcSFDC_Apttus_Config2__Order__c sfo ON posh.vip_order_id = sfo.vip_order_id__C --SUBSTRING(sfo.vip_order_id__C,4,10)
    INNER JOIN SrcSFDC.Account a ON sfo.Treatment_Location__C = a.id
	INNER JOIN SrcSFDC.Account sld ON sfo.Apttus_Config2__SoldToAccountId__c = sld.id
    INNER JOIN SrcSAP.VBAP sapd ON RIGHT(CONCAT('000',sfo.SAP_Order_ID__C),10) = sapd.VBELN
    INNER JOIN SrcSAPFile.TreatmentOption t ON sapd.ZZTREAT_OPT = t.SAPTreatmentOption
    WHERE sfo.Treatment_Category__C = @TreatmentCategory      
        AND sfo.Receipt_Date1__C is not null
        AND sapd.PSTYV = 'Z000'
        AND sapd.ZZTREAT_OPT <> 'UNKNOWN'
        AND posh.event_type = 'OrderCancelled'
		

	
    UNION ALL


-- SKOrderStatus 118
    SELECT	DISTINCT sfo.SAP_Order_ID__C AS SAPOrderNumber
		-- ,	REPLACE(sfo.VIP_Order_ID__C,'VOI','') as IDSOrderNumber
		,	sfo.VIP_Order_ID__C as IDSOrderNumber
        ,	NULL as IsRI
        ,	NULL as OrderType
		,	1 as IsKeyStatus
        ,	118 AS SKOrderStatus
		--,   hc.SKContact
		--,	ho.SKOrder
		--,	ha1.SKAccount AS SKAccountSoldTo
		--,	ha2.SKAccount AS SKAccountShipTo
		--,	ha3.SKAccount AS SKAccountTreatmentLocation
        ,	posh.cancelled_date AS StatusDate
        ,	a.ShippingCountryCode AS CountryCode
		--,	gh.SecRegion
        ,	sfo.Patient_ID__c AS PatientSFID
        ,	CONVERT(DATE, NULL) AS ReceiptDate
        ,	t.ProductHierarchy
        ,	sapd.ZZDELI_TYPE DeliverableType
        ,	sapd.ZZTREAT_OPT TreatmentOption
		,	sfo.Treatment_Category__C AS TreatmentCategory
		,	TRY_CONVERT(INT, sapd.MATNR) AS MaterialNumber
		,	TRY_CONVERT(INT, sapd.PRCTR) AS ProfitCenter
		,	sfo.Contact_ID__c  AS ContactNumber
		,	sfo.Professional_Category__C AS ProfCat
		,	sfo.Treatment_ID_Number__c AS TreatmentID
		,	sfo.Sold_To_Account_Number__c AS SoldTo
		,	sfo.Ship_To_Account_Number__c AS ShipTo
		,	a.Account_Number__c AS TreatmentLocation
		,	sapd.PSTYV AS ItemCategory
		,	sfo.ClinId__c AS ClinID
		,	sfo.Id AS SFOrderId
		,	sfo.Name AS SFOrderNumber
		,	CASE WHEN sld.Type = 'Group' AND sld.ParentID IS NULL THEN 'Yes' ELSE 'No' END IsDSO
		,	posh.ADLSTimestamp
		,	'IDS' AS Source
		,	sfo.Apttus_Config2__PrimaryContactId__c
		,	sfo.Apttus_Config2__SoldToAccountId__c
		,	sfo.Apttus_Config2__ShipToAccountId__c
		,	a.id
		,	posh._Region
    FROM SrcIDS.tblpuorderstatushistory posh
	INNER JOIN #TempFactVolumeIncrementalIDs1 tmp1 ON posh.vip_order_id = tmp1.vip_order_id and tmp1.SKOrderStatus = 118 and posh._Region = tmp1._Region
    INNER JOIN #SrcSFDC_Apttus_Config2__Order__c sfo ON posh.vip_order_id = sfo.vip_order_id__C --SUBSTRING(sfo.vip_order_id__C,4,10)
    INNER JOIN SrcSFDC.Account a ON sfo.Treatment_Location__C = a.id
	INNER JOIN SrcSFDC.Account sld ON sfo.Apttus_Config2__SoldToAccountId__c = sld.id
    INNER JOIN SrcSAP.VBAP sapd ON RIGHT(CONCAT('000',sfo.SAP_Order_ID__C),10)= sapd.VBELN
    INNER JOIN SrcSAPFile.TreatmentOption t ON sapd.ZZTREAT_OPT = t.SAPTreatmentOption
    WHERE sfo.Treatment_Category__C = @TreatmentCategory   
        AND sfo.Receipt_Date1__C is not NULL
        AND sapd.PSTYV IN ('Z001','Z002','Z003','Z004','Z005','Z006','Z008')
        AND sapd.ZZTREAT_OPT <> 'UNKNOWN'
        AND posh.event_type = 'OrderCancelled'
        AND  CONVERT(DATE, CCA_Date1__c)  <= CONVERT(DATE, sfo.Cancelled_Date1__c) 
			
UNION ALL			
 
-- SKOrderStatus 80
	SELECT	DISTINCT wo.order_number AS SAPOrderNumber
		-- ,	REPLACE(sfo.VIP_Order_ID__C,'VOI','') as IDSOrderNumber
		,	sfo.VIP_Order_ID__C as IDSOrderNumber
        ,	NULL as IsRI
        ,	NULL as OrderType
		,	1 as IsKeyStatus
        ,	80 AS SKOrderStatus
		--,   hc.SKContact
		--,	ho.SKOrder
		--,	ha1.SKAccount AS SKAccountSoldTo
		--,	ha2.SKAccount AS SKAccountShipTo
		--,	ha3.SKAccount AS SKAccountTreatmentLocation
        ,	CONVERT(DATETIME,SUBSTRING(uo.at_AllMaterialRecdTime_S, 1, LEN(uo.at_AllMaterialRecdTime_S) - 3) ) AS StatusDate
        ,	a.ShippingCountryCode AS CountryCode
		--,	gh.SecRegion
        ,	sfo.Patient_ID__c AS PatientSFID
        ,	CONVERT(DATE, NULL) AS ReceiptDate
        ,	t.ProductHierarchy
        ,	uo.at_DeliverableType_S DeliverableType
        ,	uo.at_TreatmentOption_S TreatmentOption
		,	sfo.Treatment_Category__C AS TreatmentCategory
		,	TRY_CONVERT(INT, sapd.MATNR) AS MaterialNumber
		,	TRY_CONVERT(INT, sapd.PRCTR) AS ProfitCenter
		,	sfo.Contact_ID__c  AS ContactNumber
		,	sfo.Professional_Category__C AS ProfCat
		,	sfo.Treatment_ID_Number__c AS TreatmentID
		,	sfo.Sold_To_Account_Number__c AS SoldTo
		,	sfo.Ship_To_Account_Number__c AS ShipTo
		,	a.Account_Number__c AS TreatmentLocation
		,	sapd.PSTYV AS ItemCategory
		,	sfo.ClinId__c AS ClinID
		,	sfo.Id AS SFOrderId
		,	sfo.Name AS SFOrderNumber
		,	CASE WHEN sld.Type = 'Group' AND sld.ParentID IS NULL THEN 'Yes' ELSE 'No' END IsDSO
		,	uo.ADLSTimestamp
		,	'MESCorp' AS Source
		,	sfo.Apttus_Config2__PrimaryContactId__c
		,	sfo.Apttus_Config2__SoldToAccountId__c
		,	sfo.Apttus_Config2__ShipToAccountId__c
		,	a.id
		,	'_EMPTY_' AS _Region
    FROM SrcMESCorp.Work_Order wo
    INNER JOIN SrcMESCorp.uda_order uo  ON uo.object_key = wo.order_key
	INNER JOIN #TempFactVolumeIncrementalIDs tmp ON uo.object_key = tmp.object_key and tmp.SKOrderStatus = 80
    INNER JOIN #SrcSFDC_Apttus_Config2__Order__c sfo ON wo.order_number = sfo.SAP_Order_id__C
    INNER JOIN SrcSFDC.Account a ON sfo.Treatment_Location__C = a.id
	INNER JOIN SrcSFDC.Account sld ON sfo.Apttus_Config2__SoldToAccountId__c = sld.id
    INNER JOIN SrcSAPFile.TreatmentOption t ON uo.at_TreatmentOption_S = t.SAPTreatmentOption
    LEFT JOIN SrcSAP.VBAP sapd ON RIGHT(CONCAT('000',sfo.SAP_Order_ID__C),10)= sapd.VBELN AND sapd.PSTYV='Z000' AND sapd.ZZTREAT_OPT <> 'UNKNOWN'
    WHERE sfo.Treatment_Category__C = @TreatmentCategory      
         AND uo.at_AllMaterialRecdTime_S IS NOT NULL
		
UNION ALL

-- SKOrderStatus 40
select	DISTINCT convert(bigint, pom.jde_order_id) as SAPOrderNumber
        ,	convert(bigint, osh.vip_order_id) as IDSOrderNumber
        ,	osh.IsRI as IsRI
        ,	osh.vip_order_type as OrderType
		,	1 as IsKeyStatus
        ,	40 AS SKOrderStatus 
		--,   hc.SKContact
		--,	ho.SKOrder
		--,	ha1.SKAccount AS SKAccountSoldTo
		--,	ha2.SKAccount AS SKAccountShipTo
		--,	ha3.SKAccount AS SKAccountTreatmentLocation
        ,	osh.StatusDate as StatusDate
        ,	a.ShippingCountryCode AS CountryCode
		--,	gh.SecRegion
        ,	sfo.Patient_ID__c AS PatientSFID
        --,	lips.werks  AS Plant
        ,	CONVERT(date, null) AS ReceiptDate
        ,	t.ProductHierarchy
        -- ,	sapd.ZZDELI_TYPE DeliverableType
        -- ,	sapd.ZZTREAT_OPT TreatmentOption
		,	uo.at_DeliverableType_S DeliverableType
        ,	uo.at_TreatmentOption_S TreatmentOption
		,	sfo.Treatment_Category__C AS TreatmentCategory
        --,	ISNULL(sapd.[ZZTOT_QTY],0) [DeliverableQuantity]
        --,	ISNULL(sapd.[ZZTOTAL_QTY],0) [TotalAlignerQuantity]
		-- ,	vbak.[ZZDELI_CATE] AS TreatmentCategory
		,	TRY_CONVERT(INT, sapd.MATNR) AS MaterialNumber
		,	TRY_CONVERT(INT, sapd.PRCTR) AS ProfitCenter
		,	sfo.Contact_ID__c  AS ContactNumber
		,	sfo.Professional_Category__C AS ProfCat
		,	sfo.Treatment_ID_Number__c AS TreatmentID
		,	sfo.Sold_To_Account_Number__c AS SoldTo
		,	sfo.Ship_To_Account_Number__c AS ShipTo
		,	a.Account_Number__c AS TreatmentLocation
		,	sapd.PSTYV AS ItemCategory
		,	sfo.ClinId__c AS ClinID
		,	sfo.Id AS SFOrderId
		,	sfo.Name AS SFOrderNumber
		,	CASE WHEN sld.Type = 'Group' AND sld.ParentID IS NULL THEN 'Yes' ELSE 'No' END IsDSO
		,	osh.ADLSTimestamp
		,	'IDS' AS Source
		,	sfo.Apttus_Config2__PrimaryContactId__c
		,	sfo.Apttus_Config2__SoldToAccountId__c
		,	sfo.Apttus_Config2__ShipToAccountId__c
		,	a.id
		,	osh._Region
from (
      select  osh.vip_order_id
             ,convert(nvarchar(32)
			 ,case osh.event_type when 'PaperFormSubmitted'             then N'Submit'
                                  when 'TreatmentFormSubmitted'         then N'Submit'
                                  when 'Orderinitiated'                 then N'Submit'
                                  when 'RetainerOrderCreated'           then N'Submit'
                                  end) as OrderStatusCode
             ,case osh.event_type when 'PaperFormSubmitted'             then osh.tx_submit_date
                                  when 'TreatmentFormSubmitted'         then osh.tx_submit_date
                                  when 'Orderinitiated'                 then osh.tx_submit_date
                                  when 'RetainerOrderCreated'           then osh.tx_submit_date
								  end as StatusDate
             ,case when osh.event_type = 'MaterialsRequired' and 
			 (osh.hold_reason like '%NewUpperIntraOralScanRequired%' or          
			  osh.hold_reason like '%NewLowerIntraOralScanRequired%' or
			  osh.hold_reason like '%NewLowerImpressionRequired%'    or
			  osh.hold_reason like '%NewUpperImpressionRequired%') then convert(bit, 1) else convert(bit, 0)
                                  end as IsRI --rejected impressions
             ,vip_order_type as vip_order_type
			 ,osh.ADLSTimestamp
			 ,osh._Region
              from SrcIDS.tblPuOrderStatusHistory osh
              where (--(BatchID > 0 and BatchID <= 0) or 
			  1 = 1)    
			  and osh.event_type in ('PaperFormSubmitted','TreatmentFormSubmitted','Orderinitiated','RetainerOrderCreated') --and osh.Region = 'Global' 
	) osh
INNER JOIN #TempFactVolumeIncrementalIDs1 tmp1 ON osh.vip_order_id = tmp1.vip_order_id and tmp1.SKOrderStatus = 40 and osh._Region = tmp1._Region
INNER JOIN SrcIDS.tblCnPatientOrderMap pom ON osh.vip_order_id = pom.vip_order_id and osh._Region = pom._Region
INNER JOIN SrcMESCorp.Work_Order wo ON wo.order_number = pom.[jde_order_id]
INNER JOIN SrcMESCorp.uda_order uo  ON uo.object_key = wo.order_key
-- INNER JOIN [SrcSAP].[LIPS] lips ON lips.[VGBEL] = pom.[jde_order_id]
-- INNER JOIN [SrcSAP].[VBAP] vbap ON vbap.[VBELN] = lips.[VGBEL] AND vbap.[POSNR] = lips.[VGPOS]
INNER JOIN SrcSAPFile.DeliverableType Dt ON dt.SAPDeliverableType = uo.at_DeliverableType_S
-- INNER JOIN [SrcSAP].[VBAK] vbak ON vbak.[VBELN] = vbap.[VBELN]
INNER JOIN #SrcSFDC_Apttus_Config2__Order__c sfo ON wo.order_number = sfo.SAP_Order_id__C
INNER JOIN SrcSFDC.Account a ON sfo.Treatment_Location__c = a.id
INNER JOIN SrcSFDC.Account sld ON sfo.Apttus_Config2__SoldToAccountId__c = sld.id
INNER JOIN SrcSAPFile.TreatmentOption t ON uo.at_TreatmentOption_S = t.SAPTreatmentOption
LEFT JOIN SrcSAP.VBAP sapd ON RIGHT(CONCAT('000',sfo.SAP_Order_ID__C),10)= sapd.VBELN AND sapd.PSTYV='Z000'
-- LEFT JOIN TabSAP.DimProduct p ON sapd.PRODH = p.[Product Hierarchy]
WHERE pom.jde_order_id > 0 --and pom.Region = 'Global' 
AND sfo.Treatment_Category__C = @TreatmentCategory
AND osh.StatusDate >= '20151001'

UNION ALL

-- SKOrderStatus 85,90,93,95,79,83
select	DISTINCT convert(bigint, pom.jde_order_id) as SAPOrderNumber
        ,	convert(bigint, osh.vip_order_id) as IDSOrderNumber
        ,	osh.IsRI as IsRI
        ,	osh.vip_order_type as OrderType
		,	0 as IsKeyStatus
        ,	dos.SKOrderStatus 
		--,   hc.SKContact
		--,	ho.SKOrder
		--,	ha1.SKAccount AS SKAccountSoldTo
		--,	ha2.SKAccount AS SKAccountShipTo
		--,	ha3.SKAccount AS SKAccountTreatmentLocation
        ,	osh.StatusDate as StatusDate
        ,	a.ShippingCountryCode AS CountryCode
		--,	gh.SecRegion
        ,	sfo.Patient_ID__c AS PatientSFID
        --,	lips.werks  AS Plant
        ,	CONVERT(date, null) AS ReceiptDate
		 ,	t.ProductHierarchy
		,	uo.at_DeliverableType_S DeliverableType
        ,	uo.at_TreatmentOption_S TreatmentOption
        -- ,	sapd.PRODH ProductHierarchy
        -- ,	sapd.ZZDELI_TYPE DeliverableType
        -- ,	sapd.ZZTREAT_OPT TreatmentOption
		
        --,	ISNULL(sapd.[ZZTOT_QTY],0) [DeliverableQuantity]
        --,	ISNULL(sapd.[ZZTOTAL_QTY],0) [TotalAlignerQuantity]
		-- ,	vbak.[ZZDELI_CATE] AS TreatmentCategory
		,	sfo.Treatment_Category__C AS TreatmentCategory
		,	TRY_CONVERT(INT, sapd.MATNR) AS MaterialNumber
		,	TRY_CONVERT(INT, sapd.PRCTR) AS ProfitCenter
		,	sfo.Contact_ID__c  AS ContactNumber
		,	sfo.Professional_Category__C AS ProfCat
		,	sfo.Treatment_ID_Number__c AS TreatmentID
		,	sfo.Sold_To_Account_Number__c AS SoldTo
		,	sfo.Ship_To_Account_Number__c AS ShipTo
		,	a.Account_Number__c AS TreatmentLocation
		,	sapd.PSTYV AS ItemCategory
		,	sfo.ClinId__c AS ClinID
		,	sfo.Id AS SFOrderId
		,	sfo.Name AS SFOrderNumber
		,	CASE WHEN sld.Type = 'Group' AND sld.ParentID IS NULL THEN 'Yes' ELSE 'No' END IsDSO
		,	osh.ADLSTimestamp
		,	'IDS' AS Source
		,	sfo.Apttus_Config2__PrimaryContactId__c
		,	sfo.Apttus_Config2__SoldToAccountId__c
		,	sfo.Apttus_Config2__ShipToAccountId__c
		,	a.id
		,	osh._Region
from (
      select  osh.vip_order_id
             ,convert(nvarchar(32)
			 ,case osh.event_type when 'ClinCheckUnderDevelopment'		then N'CCUD'
                                  when 'ClinCheckAwaitingApproval'		then N'CCAA'
								  when 'ConvertOrderfromUnknown'        then N'UnknownOrderConverted'
                                  when 'OrderChangeSwitch'              then N'ProductSwitch'
                                  when 'GenerateMTP'                    then N'MtpGen'
                                  when 'MTPModifyClinCheck'             then N'MtpMCC'
                                  end) as OrderStatusCode
             ,case osh.event_type when 'ClinCheckUnderDevelopment'		then osh.modified_date
                                  when 'ClinCheckAwaitingApproval'		then osh.modified_date
								  when 'ConvertOrderfromUnknown'        then osh.modified_date
                                  when 'OrderChangeSwitch'              then osh.modified_date
                                  when 'GenerateMTP'                    then osh.modified_date
                                  when 'MTPModifyClinCheck'             then osh.modified_date
								  end as StatusDate
             ,case when osh.event_type = 'MaterialsRequired' and 
			 (osh.hold_reason like '%NewUpperIntraOralScanRequired%' or          
			  osh.hold_reason like '%NewLowerIntraOralScanRequired%' or
			  osh.hold_reason like '%NewLowerImpressionRequired%'    or
			  osh.hold_reason like '%NewUpperImpressionRequired%') then convert(bit, 1) else convert(bit, 0)
                                  end as IsRI --rejected impressions
             ,vip_order_type as vip_order_type
			 ,osh.ADLSTimestamp
			 ,osh._Region
              from SrcIDS.tblPuOrderStatusHistory osh
              where (--(BatchID > 0 and BatchID <= 0) or 
			  1 = 1)    
			  and osh.event_type in ('ClinCheckUnderDevelopment','ClinCheckAwaitingApproval', 'ConvertOrderfromUnknown','OrderChangeSwitch', 'GenerateMTP', 'MTPModifyClinCheck') --and osh.Region = 'Global' 
	) osh
INNER JOIN #TempFactVolumeIncrementalIDs1 tmp1 ON osh.vip_order_id = tmp1.vip_order_id and tmp1.SKOrderStatus = 85 and osh._Region = tmp1._Region
INNER JOIN SrcIDS.tblCnPatientOrderMap pom ON osh.vip_order_id = pom.vip_order_id and osh._Region = pom._Region
INNER JOIN SrcMESCorp.Work_Order wo ON wo.order_number = pom.[jde_order_id]
INNER JOIN SrcMESCorp.uda_order uo  ON uo.object_key = wo.order_key
-- INNER JOIN [SrcSAP].[LIPS] lips ON lips.[VGBEL] = pom.[jde_order_id]
-- INNER JOIN [SrcSAP].[VBAP] vbap ON vbap.[VBELN] = lips.[VGBEL] AND vbap.[POSNR] = lips.[VGPOS]
INNER JOIN SrcSAPFile.DeliverableType Dt ON dt.SAPDeliverableType = uo.at_DeliverableType_S
-- INNER JOIN SrcSAPFile.DeliverableType Dt ON dt.SAPDeliverableType = vbap.[ZZDELI_TYPE]
-- INNER JOIN [SrcSAP].[VBAK] vbak ON vbak.[VBELN] = vbap.[VBELN]
INNER JOIN #SrcSFDC_Apttus_Config2__Order__c sfo ON wo.order_number = sfo.SAP_Order_id__C
INNER JOIN SrcSFDC.Account a ON sfo.Treatment_Location__c = a.id
INNER JOIN SrcSFDC.Account sld ON sfo.Apttus_Config2__SoldToAccountId__c = sld.id
INNER JOIN SrcSAPFile.TreatmentOption t ON uo.at_TreatmentOption_S = t.SAPTreatmentOption
-- INNER JOIN TabSAP.DimProduct p ON vbap.PRODH = p.[Product Hierarchy]
INNER JOIN [DW].[DimOrderStatus] dos ON osh.OrderStatusCode = dos.OrderStatusCode
LEFT JOIN SrcSAP.VBAP sapd ON RIGHT(CONCAT('000',sfo.SAP_Order_ID__C),10)= sapd.VBELN AND sapd.PSTYV='Z000'
where pom.jde_order_id > 0 --and pom.Region = 'Global' 
AND sfo.Treatment_Category__C = @TreatmentCategory
and osh.StatusDate >= '20151001'

UNION ALL

-- SKOrderStatus 82
select	DISTINCT convert(bigint, pom.jde_order_id) as SAPOrderNumber
        ,	convert(bigint, osh.vip_order_id) as IDSOrderNumber
        ,	osh.IsRI as IsRI
        ,	osh.vip_order_type as OrderType
		,	0 as IsKeyStatus
        ,	82 AS SKOrderStatus 
		--,   hc.SKContact
		--,	ho.SKOrder
		--,	ha1.SKAccount AS SKAccountSoldTo
		--,	ha2.SKAccount AS SKAccountShipTo
		--,	ha3.SKAccount AS SKAccountTreatmentLocation
        ,	osh.StatusDate as StatusDate
        ,	a.ShippingCountryCode AS CountryCode
		--,	gh.SecRegion
        ,	sfo.Patient_ID__c AS PatientSFID
        --,	lips.werks  AS Plant
        ,	CONVERT(date, null) AS ReceiptDate
		,	t.ProductHierarchy
		,	uo.at_DeliverableType_S DeliverableType
        ,	uo.at_TreatmentOption_S TreatmentOption
		,	sfo.Treatment_Category__C AS TreatmentCategory
        -- ,	sapd.PRODH ProductHierarchy
        -- ,	sapd.ZZDELI_TYPE DeliverableType
        -- ,	sapd.ZZTREAT_OPT TreatmentOption
        --,	ISNULL(sapd.[ZZTOT_QTY],0) [DeliverableQuantity]
        --,	ISNULL(sapd.[ZZTOTAL_QTY],0) [TotalAlignerQuantity]
		-- ,	vbak.[ZZDELI_CATE] AS TreatmentCategory
		,	TRY_CONVERT(INT, sapd.MATNR) AS MaterialNumber
		,	TRY_CONVERT(INT, sapd.PRCTR) AS ProfitCenter
		,	sfo.Contact_ID__c  AS ContactNumber
		,	sfo.Professional_Category__C AS ProfCat
		,	sfo.Treatment_ID_Number__c AS TreatmentID
		,	sfo.Sold_To_Account_Number__c AS SoldTo
		,	sfo.Ship_To_Account_Number__c AS ShipTo
		,	a.Account_Number__c AS TreatmentLocation
		,	sapd.PSTYV AS ItemCategory
		,	sfo.ClinId__c AS ClinID
		,	sfo.Id AS SFOrderId
		,	sfo.Name AS SFOrderNumber
		,	CASE WHEN sld.Type = 'Group' AND sld.ParentID IS NULL THEN 'Yes' ELSE 'No' END IsDSO
		,	osh.ADLSTimestamp
		,	'IDS' AS Source
		,	sfo.Apttus_Config2__PrimaryContactId__c
		,	sfo.Apttus_Config2__SoldToAccountId__c
		,	sfo.Apttus_Config2__ShipToAccountId__c
		,	a.id
		,	osh._Region
from (
      select  osh.vip_order_id
             ,convert(nvarchar(32)
			 ,case osh.event_type when 'ClinCheckModified'				then N'CCMOD'
                                  end) as OrderStatusCode
             ,case osh.event_type when 'ClinCheckModified'				then osh.cc_mod_date
								  end as StatusDate
             ,case when osh.event_type = 'MaterialsRequired' and 
			 (osh.hold_reason like '%NewUpperIntraOralScanRequired%' or          
			  osh.hold_reason like '%NewLowerIntraOralScanRequired%' or
			  osh.hold_reason like '%NewLowerImpressionRequired%'    or
			  osh.hold_reason like '%NewUpperImpressionRequired%') then convert(bit, 1) else convert(bit, 0)
                                  end as IsRI --rejected impressions
             ,vip_order_type as vip_order_type
			 ,osh.ADLSTimestamp
			 ,osh._Region
              from SrcIDS.tblPuOrderStatusHistory osh
              where (--(BatchID > 0 and BatchID <= 0) or 
			  1 = 1)    
			  and osh.event_type in ('ClinCheckModified') --and osh.Region = 'Global' 
	) osh
INNER JOIN #TempFactVolumeIncrementalIDs1 tmp1 ON osh.vip_order_id = tmp1.vip_order_id and tmp1.SKOrderStatus = 82 and osh._Region = tmp1._Region
INNER JOIN SrcIDS.tblCnPatientOrderMap pom ON osh.vip_order_id = pom.vip_order_id and osh._Region = pom._Region
INNER JOIN SrcMESCorp.Work_Order wo ON wo.order_number = pom.[jde_order_id]
INNER JOIN SrcMESCorp.uda_order uo  ON uo.object_key = wo.order_key
-- INNER JOIN [SrcSAP].[LIPS] lips ON lips.[VGBEL] = pom.[jde_order_id]
-- INNER JOIN [SrcSAP].[VBAP] vbap ON vbap.[VBELN] = lips.[VGBEL] AND vbap.[POSNR] = lips.[VGPOS]
-- INNER JOIN SrcSAPFile.DeliverableType Dt ON dt.SAPDeliverableType = vbap.[ZZDELI_TYPE]
INNER JOIN SrcSAPFile.DeliverableType Dt ON dt.SAPDeliverableType = uo.at_DeliverableType_S
-- INNER JOIN [SrcSAP].[VBAK] vbak ON vbak.[VBELN] = vbap.[VBELN]
INNER JOIN #SrcSFDC_Apttus_Config2__Order__c sfo ON wo.order_number = sfo.SAP_Order_id__C
INNER JOIN SrcSFDC.Account a ON sfo.Treatment_Location__c = a.id
INNER JOIN SrcSFDC.Account sld ON sfo.Apttus_Config2__SoldToAccountId__c = sld.id
-- INNER JOIN TabSAP.DimProduct p ON vbap.PRODH = p.[Product Hierarchy]
INNER JOIN SrcSAPFile.TreatmentOption t ON uo.at_TreatmentOption_S = t.SAPTreatmentOption
LEFT JOIN SrcSAP.VBAP sapd ON RIGHT(CONCAT('000',sfo.SAP_Order_ID__C),10)= sapd.VBELN AND sapd.PSTYV='Z000'
where pom.jde_order_id > 0 --and pom.Region = 'Global' 
AND sfo.Treatment_Category__C = @TreatmentCategory
and osh.StatusDate >= '20151001'

UNION ALL

-- SKOrderStatus 60,88
select	DISTINCT convert(bigint, pom.jde_order_id) as SAPOrderNumber
        ,	convert(bigint, osh.vip_order_id) as IDSOrderNumber
        ,	osh.IsRI as IsRI
        ,	osh.vip_order_type as OrderType
		,	0 as IsKeyStatus
        ,	dos.SKOrderStatus 
		--,   hc.SKContact
		--,	ho.SKOrder
		--,	ha1.SKAccount AS SKAccountSoldTo
		--,	ha2.SKAccount AS SKAccountShipTo
		--,	ha3.SKAccount AS SKAccountTreatmentLocation
        ,	osh.StatusDate as StatusDate
        ,	a.ShippingCountryCode AS CountryCode
		--,	gh.SecRegion
        ,	sfo.Patient_ID__c AS PatientSFID
        --,	lips.werks  AS Plant
        ,	CONVERT(date, null) AS ReceiptDate
		,	t.ProductHierarchy
		,	uo.at_DeliverableType_S DeliverableType
        ,	uo.at_TreatmentOption_S TreatmentOption
		,	sfo.Treatment_Category__C AS TreatmentCategory
        -- ,	sapd.PRODH ProductHierarchy
        -- ,	sapd.ZZDELI_TYPE DeliverableType
        -- ,	sapd.ZZTREAT_OPT TreatmentOption
        --,	ISNULL(sapd.[ZZTOT_QTY],0) [DeliverableQuantity]
        --,	ISNULL(sapd.[ZZTOTAL_QTY],0) [TotalAlignerQuantity]
		-- ,	vbak.[ZZDELI_CATE] AS TreatmentCategory
		,	TRY_CONVERT(INT, sapd.MATNR) AS MaterialNumber
		,	TRY_CONVERT(INT, sapd.PRCTR) AS ProfitCenter
		,	sfo.Contact_ID__c  AS ContactNumber
		,	sfo.Professional_Category__C AS ProfCat
		,	sfo.Treatment_ID_Number__c AS TreatmentID
		,	sfo.Sold_To_Account_Number__c AS SoldTo
		,	sfo.Ship_To_Account_Number__c AS ShipTo
		,	a.Account_Number__c AS TreatmentLocation
		,	sapd.PSTYV AS ItemCategory
		,	sfo.ClinId__c AS ClinID
		,	sfo.Id AS SFOrderId
		,	sfo.Name AS SFOrderNumber
		,	CASE WHEN sld.Type = 'Group' AND sld.ParentID IS NULL THEN 'Yes' ELSE 'No' END IsDSO
		,	osh.ADLSTimestamp
		,	'IDS' AS Source
		,	sfo.Apttus_Config2__PrimaryContactId__c
		,	sfo.Apttus_Config2__SoldToAccountId__c
		,	sfo.Apttus_Config2__ShipToAccountId__c
		,	a.id
		,	osh._Region
from (
      select  osh.vip_order_id
             ,convert(nvarchar(32)
			 ,case osh.event_type when 'MaterialsRequired'              then N'MaterialsPending'
                                  when 'ClinicalHold'                   then N'ClinicalHold'
                                  end) as OrderStatusCode
             ,case osh.event_type when 'MaterialsRequired'              then osh.hold_date
                                  when 'ClinicalHold'                   then osh.hold_date
								  end as StatusDate
             ,case when osh.event_type = 'MaterialsRequired' and 
			 (osh.hold_reason like '%NewUpperIntraOralScanRequired%' or          
			  osh.hold_reason like '%NewLowerIntraOralScanRequired%' or
			  osh.hold_reason like '%NewLowerImpressionRequired%'    or
			  osh.hold_reason like '%NewUpperImpressionRequired%') then convert(bit, 1) else convert(bit, 0)
                                  end as IsRI --rejected impressions
             ,vip_order_type as vip_order_type
			 ,osh.ADLSTimestamp
			 ,osh._Region
              from SrcIDS.tblPuOrderStatusHistory osh
              where (--(BatchID > 0 and BatchID <= 0) or 
			  1 = 1)    
			  and osh.event_type in ('MaterialsRequired','ClinicalHold') --and osh.Region = 'Global' 
	) osh
INNER JOIN #TempFactVolumeIncrementalIDs1 tmp1 ON osh.vip_order_id = tmp1.vip_order_id and tmp1.SKOrderStatus = 60 and osh._Region = tmp1._Region
INNER JOIN SrcIDS.tblCnPatientOrderMap pom ON osh.vip_order_id = pom.vip_order_id and osh._Region = pom._Region
INNER JOIN SrcMESCorp.Work_Order wo ON wo.order_number = pom.[jde_order_id]
INNER JOIN SrcMESCorp.uda_order uo  ON uo.object_key = wo.order_key
-- INNER JOIN [SrcSAP].[LIPS] lips ON lips.[VGBEL] = pom.[jde_order_id]
-- INNER JOIN [SrcSAP].[VBAP] vbap ON vbap.[VBELN] = lips.[VGBEL] AND vbap.[POSNR] = lips.[VGPOS]
INNER JOIN SrcSAPFile.DeliverableType Dt ON dt.SAPDeliverableType = uo.at_DeliverableType_S
-- INNER JOIN [SrcSAP].[VBAK] vbak ON vbak.[VBELN] = vbap.[VBELN]
INNER JOIN #SrcSFDC_Apttus_Config2__Order__c sfo ON wo.order_number = sfo.SAP_Order_id__C
INNER JOIN SrcSFDC.Account a ON sfo.Treatment_Location__c = a.id
INNER JOIN SrcSFDC.Account sld ON sfo.Apttus_Config2__SoldToAccountId__c = sld.id
INNER JOIN SrcSAPFile.TreatmentOption t ON uo.at_TreatmentOption_S = t.SAPTreatmentOption
-- INNER JOIN TabSAP.DimProduct p ON vbap.PRODH = p.[Product Hierarchy]
INNER JOIN [DW].[DimOrderStatus] dos ON osh.OrderStatusCode = dos.OrderStatusCode
LEFT JOIN SrcSAP.VBAP sapd ON RIGHT(CONCAT('000',sfo.SAP_Order_ID__C),10)= sapd.VBELN AND sapd.PSTYV='Z000'
where pom.jde_order_id > 0 --and pom.Region = 'Global' 
AND sfo.Treatment_Category__C = @TreatmentCategory
and osh.StatusDate >= '20151001'

UNION ALL

-- SKOrderStatus 109
select	DISTINCT convert(bigint, pom.jde_order_id) as SAPOrderNumber
        ,	convert(bigint, osh.vip_order_id) as IDSOrderNumber
        ,	osh.IsRI as IsRI
        ,	osh.vip_order_type as OrderType
		,	0 as IsKeyStatus
        ,	109 AS SKOrderStatus 
		--,   hc.SKContact
		--,	ho.SKOrder
		--,	ha1.SKAccount AS SKAccountSoldTo
		--,	ha2.SKAccount AS SKAccountShipTo
		--,	ha3.SKAccount AS SKAccountTreatmentLocation
        ,	osh.StatusDate as StatusDate
        ,	a.ShippingCountryCode AS CountryCode
		--,	gh.SecRegion
        ,	sfo.Patient_ID__c AS PatientSFID
        --,	lips.werks  AS Plant
        ,	CONVERT(date, null) AS ReceiptDate
		,	t.ProductHierarchy
		,	uo.at_DeliverableType_S DeliverableType
        ,	uo.at_TreatmentOption_S TreatmentOption
		,	sfo.Treatment_Category__C AS TreatmentCategory
        -- ,	sapd.PRODH ProductHierarchy
        -- ,	sapd.ZZDELI_TYPE DeliverableType
        -- ,	sapd.ZZTREAT_OPT TreatmentOption
        --,	ISNULL(sapd.[ZZTOT_QTY],0) [DeliverableQuantity]
        --,	ISNULL(sapd.[ZZTOTAL_QTY],0) [TotalAlignerQuantity]
		-- ,	vbak.[ZZDELI_CATE] AS TreatmentCategory
		,	TRY_CONVERT(INT, sapd.MATNR) AS MaterialNumber
		,	TRY_CONVERT(INT, sapd.PRCTR) AS ProfitCenter
		,	sfo.Contact_ID__c  AS ContactNumber
		,	sfo.Professional_Category__C AS ProfCat
		,	sfo.Treatment_ID_Number__c AS TreatmentID
		,	sfo.Sold_To_Account_Number__c AS SoldTo
		,	sfo.Ship_To_Account_Number__c AS ShipTo
		,	a.Account_Number__c AS TreatmentLocation
		,	sapd.PSTYV AS ItemCategory
		,	sfo.ClinId__c AS ClinID
		,	sfo.Id AS SFOrderId
		,	sfo.Name AS SFOrderNumber
		,	CASE WHEN sld.Type = 'Group' AND sld.ParentID IS NULL THEN 'Yes' ELSE 'No' END IsDSO
		,	osh.ADLSTimestamp
		,	'IDS' AS Source
		,	sfo.Apttus_Config2__PrimaryContactId__c
		,	sfo.Apttus_Config2__SoldToAccountId__c
		,	sfo.Apttus_Config2__ShipToAccountId__c
		,	a.id
		,	osh._Region
from (
      select  osh.vip_order_id
             ,convert(nvarchar(32)
			 ,case osh.event_type when 'ShipmentScheduled'              then N'ShipmentScheduled'
                                  end) as OrderStatusCode
             ,case osh.event_type when 'ShipmentScheduled'              then osh.promised_ship_date
								  end as StatusDate
             ,case when osh.event_type = 'MaterialsRequired' and 
			 (osh.hold_reason like '%NewUpperIntraOralScanRequired%' or          
			  osh.hold_reason like '%NewLowerIntraOralScanRequired%' or
			  osh.hold_reason like '%NewLowerImpressionRequired%'    or
			  osh.hold_reason like '%NewUpperImpressionRequired%') then convert(bit, 1) else convert(bit, 0)
                                  end as IsRI --rejected impressions
             ,vip_order_type as vip_order_type
			 ,osh.ADLSTimestamp
			 ,osh._Region
              from SrcIDS.tblPuOrderStatusHistory osh
              where (--(BatchID > 0 and BatchID <= 0) or 
			  1 = 1)    
			  and osh.event_type in ('ShipmentScheduled') --and osh.Region = 'Global'
	) osh
INNER JOIN #TempFactVolumeIncrementalIDs1 tmp1 ON osh.vip_order_id = tmp1.vip_order_id and tmp1.SKOrderStatus = 109 and osh._Region = tmp1._Region
INNER JOIN SrcIDS.tblCnPatientOrderMap pom ON osh.vip_order_id = pom.vip_order_id and osh._Region = pom._Region
INNER JOIN SrcMESCorp.Work_Order wo ON wo.order_number = pom.[jde_order_id]
INNER JOIN SrcMESCorp.uda_order uo  ON uo.object_key = wo.order_key
-- INNER JOIN [SrcSAP].[LIPS] lips ON lips.[VGBEL] = pom.[jde_order_id]
-- INNER JOIN [SrcSAP].[VBAP] vbap ON vbap.[VBELN] = lips.[VGBEL] AND vbap.[POSNR] = lips.[VGPOS]
INNER JOIN SrcSAPFile.DeliverableType Dt ON dt.SAPDeliverableType = uo.at_DeliverableType_S
-- INNER JOIN [SrcSAP].[VBAK] vbak ON vbak.[VBELN] = vbap.[VBELN]
INNER JOIN #SrcSFDC_Apttus_Config2__Order__c sfo ON wo.order_number = sfo.SAP_Order_id__C
INNER JOIN SrcSFDC.Account a ON sfo.Treatment_Location__c = a.id
INNER JOIN SrcSFDC.Account sld ON sfo.Apttus_Config2__SoldToAccountId__c = sld.id
INNER JOIN SrcSAPFile.TreatmentOption t ON uo.at_TreatmentOption_S = t.SAPTreatmentOption
-- INNER JOIN TabSAP.DimProduct p ON vbap.PRODH = p.[Product Hierarchy]
LEFT JOIN SrcSAP.VBAP sapd ON RIGHT(CONCAT('000',sfo.SAP_Order_ID__C),10)= sapd.VBELN AND sapd.PSTYV='Z000'
where pom.jde_order_id > 0 --and pom.Region = 'Global' 
AND sfo.Treatment_Category__C = @TreatmentCategory
and osh.StatusDate >= '20151001'

UNION ALL

-- SKOrderStatus 81
select	DISTINCT convert(bigint, pom.jde_order_id) as SAPOrderNumber
        ,	convert(bigint, tsh.last_vip_order_id) as IDSOrderNumber
        ,	0 as IsRI
        ,	100 as  OrderType
        ,	0 as IsKeyStatus
        ,	81 as SKOrderStatus 
		--,   hc.SKContact
		--,	ho.SKOrder
		--,	ha1.SKAccount AS SKAccountSoldTo
		--,	ha2.SKAccount AS SKAccountShipTo
		--,	ha3.SKAccount AS SKAccountTreatmentLocation
        ,	tsh.modified_date as StatusDate
        ,	a.ShippingCountryCode AS CountryCode
		--,	gh.SecRegion
        ,	sfo.Patient_ID__c AS PatientSFID
        --,	lips.werks  AS Plant
        ,	CONVERT(date, null) AS ReceiptDate
		,	t.ProductHierarchy
		,	uo.at_DeliverableType_S DeliverableType
        ,	uo.at_TreatmentOption_S TreatmentOption
		,	sfo.Treatment_Category__C AS TreatmentCategory
        -- ,	vbap.PRODH ProductHierarchy
        -- ,	vbap.ZZDELI_TYPE DeliverableType
        -- ,	vbap.ZZTREAT_OPT TreatmentOption
        --,	ISNULL(vbap.[ZZTOT_QTY],0) [DeliverableQuantity]
        --,	ISNULL(vbap.[ZZTOTAL_QTY],0) [TotalAlignerQuantity]
		-- ,	vbak.[ZZDELI_CATE] AS TreatmentCategory
		,	TRY_CONVERT(INT, sapd.MATNR) AS MaterialNumber
		,	TRY_CONVERT(INT, sapd.PRCTR) AS ProfitCenter
		,	sfo.Contact_ID__c  AS ContactNumber
		,	sfo.Professional_Category__C AS ProfCat
		,	sfo.Treatment_ID_Number__c AS TreatmentID
		,	sfo.Sold_To_Account_Number__c AS SoldTo
		,	sfo.Ship_To_Account_Number__c AS ShipTo
		,	a.Account_Number__c AS TreatmentLocation
		,	sapd.PSTYV AS ItemCategory
		,	sfo.ClinId__c AS ClinID
		,	sfo.Id AS SFOrderId
		,	sfo.Name AS SFOrderNumber
		,	CASE WHEN sld.Type = 'Group' AND sld.ParentID IS NULL THEN 'Yes' ELSE 'No' END IsDSO
		,	tsh.ADLSTimestamp
		,	'IDS' AS Source
		,	sfo.Apttus_Config2__PrimaryContactId__c
		,	sfo.Apttus_Config2__SoldToAccountId__c
		,	sfo.Apttus_Config2__ShipToAccountId__c
		,	a.id
		,	tsh._Region
FROM SrcIDS.tblPuTreatmentStatusHistory tsh
INNER JOIN #TempFactVolumeIncrementalIDs1 tmp1 ON tsh.last_vip_order_id = tmp1.vip_order_id and tmp1.SKOrderStatus = 81 and tsh._Region = tmp1._Region
INNER JOIN SrcIDS.tblCnPatientOrderMap pom on tsh.last_vip_order_id = pom.vip_order_id and tsh._Region = pom._Region
INNER JOIN SrcMESCorp.Work_Order wo ON wo.order_number = pom.[jde_order_id]
INNER JOIN SrcMESCorp.uda_order uo  ON uo.object_key = wo.order_key
-- INNER JOIN [SrcSAP].[LIPS] lips ON lips.[VGBEL] = pom.[jde_order_id]
-- INNER JOIN [SrcSAP].[VBAP] vbap ON vbap.[VBELN] = lips.[VGBEL] AND vbap.[POSNR] = lips.[VGPOS]
INNER JOIN SrcSAPFile.DeliverableType Dt ON dt.SAPDeliverableType = uo.at_DeliverableType_S
-- INNER JOIN [SrcSAP].[VBAK] vbak ON vbak.[VBELN] = vbap.[VBELN]
INNER JOIN #SrcSFDC_Apttus_Config2__Order__c sfo ON wo.order_number = sfo.SAP_Order_id__C
INNER JOIN SrcSFDC.Account a ON sfo.Treatment_Location__c = a.id
INNER JOIN SrcSFDC.Account sld ON sfo.Apttus_Config2__SoldToAccountId__c = sld.id
INNER JOIN SrcSAPFile.TreatmentOption t ON uo.at_TreatmentOption_S = t.SAPTreatmentOption
-- INNER JOIN TabSAP.DimProduct p ON vbap.PRODH = p.[Product Hierarchy]
LEFT JOIN SrcSAP.VBAP sapd ON RIGHT(CONCAT('000',sfo.SAP_Order_ID__C),10)= sapd.VBELN AND sapd.PSTYV='Z000'
WHERE 1=1 and tsh.tx_status_id = 2502 /*MtpAR*/ 
AND sfo.Treatment_Category__C = @TreatmentCategory
and pom.jde_order_id > 0

UNION ALL

-- SKOrderStatus 101
select	DISTINCT convert(bigint, pom.jde_order_id) as SAPOrderNumber
        ,	convert(bigint, tsh.last_vip_order_id) as IDSOrderNumber
        ,	0 as IsRI
        ,	LastOrderType.vip_order_type as OrderType
        ,	0 as IsKeyStatus
        ,	101 as SKOrderStatus 
		--,   hc.SKContact
		--,	ho.SKOrder
		--,	ha1.SKAccount AS SKAccountSoldTo
		--,	ha2.SKAccount AS SKAccountShipTo
		--,	ha3.SKAccount AS SKAccountTreatmentLocation
        ,	tsh.modified_date as StatusDate
        ,	a.ShippingCountryCode AS CountryCode
		--,	gh.SecRegion
        ,	sfo.Patient_ID__c AS PatientSFID
        --,	lips.werks  AS Plant
        ,	CONVERT(date, null) AS ReceiptDate
		,	t.ProductHierarchy
		,	uo.at_DeliverableType_S DeliverableType
        ,	uo.at_TreatmentOption_S TreatmentOption
		,	sfo.Treatment_Category__C AS TreatmentCategory
        -- ,	sapd.PRODH ProductHierarchy
        -- ,	sapd.ZZDELI_TYPE DeliverableType
        -- ,	sapd.ZZTREAT_OPT TreatmentOption
        --,	ISNULL(sapd.[ZZTOT_QTY],0) [DeliverableQuantity]
        --,	ISNULL(sapd.[ZZTOTAL_QTY],0) [TotalAlignerQuantity]
		-- ,	vbak.[ZZDELI_CATE] AS TreatmentCategory
		,	TRY_CONVERT(INT, sapd.MATNR) AS MaterialNumber
		,	TRY_CONVERT(INT, sapd.PRCTR) AS ProfitCenter
		,	sfo.Contact_ID__c  AS ContactNumber
		,	sfo.Professional_Category__C AS ProfCat
		,	sfo.Treatment_ID_Number__c AS TreatmentID
		,	sfo.Sold_To_Account_Number__c AS SoldTo
		,	sfo.Ship_To_Account_Number__c AS ShipTo
		,	a.Account_Number__c AS TreatmentLocation
		,	sapd.PSTYV AS ItemCategory
		,	sfo.ClinId__c AS ClinID
		,	sfo.Id AS SFOrderId
		,	sfo.Name AS SFOrderNumber
		,	CASE WHEN sld.Type = 'Group' AND sld.ParentID IS NULL THEN 'Yes' ELSE 'No' END IsDSO
		,	tsh.ADLSTimestamp
		,	'IDS' AS Source
		,	sfo.Apttus_Config2__PrimaryContactId__c
		,	sfo.Apttus_Config2__SoldToAccountId__c
		,	sfo.Apttus_Config2__ShipToAccountId__c
		,	a.id
		,	tsh._Region
FROM SrcIDS.tblPuTreatmentStatusHistory tsh
INNER JOIN #TempFactVolumeIncrementalIDs1 tmp1 ON tsh.last_vip_order_id = tmp1.vip_order_id and tmp1.SKOrderStatus = 101 and tsh._Region = tmp1._Region
INNER JOIN SrcIDS.tblCnPatientOrderMap pom on tsh.last_vip_order_id = pom.vip_order_id and tsh._Region = pom._Region
INNER JOIN (
              SELECT top 1 with ties
                             vip_order_id
                            ,vip_order_type
							,_Region
              FROM SrcIDS.tblpuorderstatushistory
              where event_type IN ('MTPAcceptClinCheck','ClinCheckAccepted','ClinCheckAutoAccepted')
              and vip_order_type IN (97,99,100,106,107)
              --and Region = 'Global'     
			  ORDER BY ROW_NUMBER() OVER (PARTITION BY vip_order_id  ORDER BY modified_date DESC)
              ) LastOrderType on LastOrderType.vip_order_id=pom.vip_order_id and LastOrderType._Region = pom._Region
-- INNER JOIN [SrcSAP].[LIPS] lips ON lips.[VGBEL] = pom.[jde_order_id]
-- INNER JOIN [SrcSAP].[VBAP] vbap ON vbap.[VBELN] = lips.[VGBEL] AND vbap.[POSNR] = lips.[VGPOS]
INNER JOIN SrcMESCorp.Work_Order wo ON wo.order_number = pom.[jde_order_id]
INNER JOIN SrcMESCorp.uda_order uo  ON uo.object_key = wo.order_key
INNER JOIN SrcSAPFile.DeliverableType Dt ON dt.SAPDeliverableType = uo.at_DeliverableType_S
-- INNER JOIN [SrcSAP].[VBAK] vbak ON vbak.[VBELN] = vbap.[VBELN]
INNER JOIN #SrcSFDC_Apttus_Config2__Order__c sfo ON wo.order_number = sfo.SAP_Order_id__C
INNER JOIN SrcSFDC.Account a ON sfo.Treatment_Location__c = a.id
INNER JOIN SrcSFDC.Account sld ON sfo.Apttus_Config2__SoldToAccountId__c = sld.id
INNER JOIN SrcSAPFile.TreatmentOption t ON uo.at_TreatmentOption_S = t.SAPTreatmentOption
-- INNER JOIN TabSAP.DimProduct p ON vbap.PRODH = p.[Product Hierarchy]
LEFT JOIN SrcSAP.VBAP sapd ON RIGHT(CONCAT('000',sfo.SAP_Order_ID__C),10)= sapd.VBELN AND sapd.PSTYV='Z000'
WHERE 1=1 and tsh.tx_status_id = 2641 /*MtpEPQ*/
AND sfo.Treatment_Category__C = @TreatmentCategory
and pom.jde_order_id > 0
        
		
	IF OBJECT_ID(N'tempdb..#SAPShipments') IS NOT NULL DROP table #SAPShipments     
	CREATE TABLE #SAPShipments WITH  ( distribution =round_robin, heap) 
	AS
	
-- SKOrderStatus 110
    SELECT	DISTINCT CONVERT(bigint, lips.[VGBEL]) AS [SAPOrderNumber]
		-- ,	REPLACE(sfo.VIP_Order_ID__C,'VOI','') as IDSOrderNumber
		,	sfo.VIP_Order_ID__C as IDSOrderNumber
        ,	NULL as IsRI
        ,	NULL as OrderType
		,	1 as IsKeyStatus
        ,	110 AS SKOrderStatus 
		,   hc.SKContact
		,	ho.SKOrder
		,	ha1.SKAccount AS SKAccountSoldTo
		,	ha2.SKAccount AS SKAccountShipTo
		,	ha3.SKAccount AS SKAccountTreatmentLocation
        ,	TRY_CONVERT(date,likp.[WADAT_IST]) AS StatusDate
        ,	a.ShippingCountryCode AS CountryCode
		,	gh.SecRegion
        ,	sfo.Patient_ID__c AS PatientSFID
        ,	lips.werks  AS Plant
        ,	CONVERT(date, null) AS ReceiptDate
        ,	vbap.PRODH ProductHierarchy
        ,	vbap.ZZDELI_TYPE DeliverableType
        ,	vbap.ZZTREAT_OPT TreatmentOption
        ,	ISNULL(vbap.[ZZTOT_QTY],0) [DeliverableQuantity]
        ,	ISNULL(vbap.[ZZTOTAL_QTY],0) [TotalAlignerQuantity]
		-- ,	vbak.[ZZDELI_CATE] AS TreatmentCategory
		,	@TreatmentCategory AS TreatmentCategory
		,	TRY_CONVERT(INT, vbap.MATNR) AS MaterialNumber
		,	TRY_CONVERT(INT, vbap.PRCTR) AS ProfitCenter
		,	sfo.Contact_ID__c  AS ContactNumber
		,	sfo.Professional_Category__C AS ProfCat
		,	sfo.Treatment_ID_Number__c AS TreatmentID
		,	sfo.Sold_To_Account_Number__c AS SoldTo
		,	sfo.Ship_To_Account_Number__c AS ShipTo
		,	a.Account_Number__c AS TreatmentLocation
		,	vbap.PSTYV AS ItemCategory
		,	sfo.ClinId__c AS ClinID
		,	sfo.Id AS SFOrderId
		,	sfo.Name AS SFOrderNumber
		,	CASE WHEN sld.Type = 'Group' AND sld.ParentID IS NULL THEN 'Yes' ELSE 'No' END IsDSO
		,	likp.ADLSTimestamp
		,	'SAP' AS Source
FROM [SrcSAP].[LIKP] likp
INNER JOIN #TempFactVolumeIncrementalIDs2 tmp2 ON likp.[VBELN] = tmp2.VBELN and tmp2.SKOrderStatus = 110
INNER JOIN [SrcSAP].[LIPS] lips ON lips.[VBELN] = likp.[VBELN]
INNER JOIN [SrcSAP].[VBAP] vbap ON vbap.[VBELN] = lips.[VGBEL]
        AND vbap.[POSNR] = lips.[VGPOS]
INNER JOIN SrcSAPFile.DeliverableType Dt ON dt.SAPDeliverableType = vbap.[ZZDELI_TYPE]
INNER JOIN [SrcSAP].[VBAK] vbak ON vbak.[VBELN] = vbap.[VBELN]
INNER JOIN #SrcSFDC_Apttus_Config2__Order__c sfo ON RIGHT(CONCAT('000',sfo.SAP_Order_ID__C),10) = vbak.[VBELN]
INNER JOIN SrcSFDC.Account a ON sfo.Treatment_Location__c = a.id
INNER JOIN SrcSFDC.Account sld ON sfo.Apttus_Config2__SoldToAccountId__c = sld.id
INNER JOIN TabSAP.DimProduct p ON vbap.PRODH = p.[Product Hierarchy]
INNER JOIN DW.HubContact hc ON hc.KeyContact = sfo.Apttus_Config2__PrimaryContactId__c 
INNER JOIN DW.HubAccount ha1 ON ha1.KeyAccount = sfo.Apttus_Config2__SoldToAccountId__c
INNER JOIN DW.HubAccount ha2 ON ha2.KeyAccount = sfo.Apttus_Config2__ShipToAccountId__c
INNER JOIN DW.HubAccount ha3 ON ha3.KeyAccount = a.id
INNER JOIN DW.HubOrder ho ON ho.KeyOrder =  lips.[VGBEL]
INNER JOIN [Custom].[GeographyHierarchy] gh ON gh.CountryCode = a.ShippingCountryCode
WHERE  likp.[WADAT_IST]  <> '00000000'         
        AND vbak.[ZZDELI_CATE] = @TreatmentCategory AND vbap.PSTYV IN ('Z001','Z002','Z003','Z004','Z005','Z006','Z008','ZFUL')
        --AND TRY_CONVERT(DATE, likp.[WADAT_IST]) < @tom
	
	
	IF OBJECT_ID('tempdb..#TempFactVolume') IS NOT NULL DROP TABLE #TempFactVolume

	CREATE TABLE #TempFactVolume WITH (distribution = round_robin, heap) AS 
	
	SELECT  CONVERT(CHAR(40), '') AS DWHashKey
		,	CONVERT(CHAR(40), '') AS DWHash
		,	t.SAPOrderNumber
		,	t.IDSOrderNumber
		,	t.IsKeyStatus
		,   t.SKOrderStatus
		,   hc.SKContact
		,	ho.SKOrder
		,	ha1.SKAccount AS SKAccountSoldTo
		,	ha2.SKAccount AS SKAccountShipTo
		,	ha3.SKAccount AS SKAccountTreatmentLocation
		,   CAST(MIN(t.StatusDate) AS DATE) AS StatusDate
		,   t.CountryCode
		,	gh.SecRegion
		,   t.PatientSFID 
		,   CASE SKOrderStatus WHEN 80 THEN 'New Order' END NewOrRestart
		,   CONVERT(int,NULL) AS Plant
		,	t.ReceiptDate
		,   t.ProductHierarchy
		,   t.TreatmentOption
		,   t.DeliverableType
		,	t.TreatmentCategory
		,	t.MaterialNumber
		,	t.ProfitCenter
		,	t.ContactNumber
		,	t.ProfCat
		,	t.TreatmentID
		,	t.SoldTo
		,	t.ShipTo
		,	t.TreatmentLocation
		,	t.ItemCategory
		,	t.ClinID
		,	t.SFOrderId
		,	t.SFOrderNumber
		,	t.IsDSO
		,   CONVERT(int,NULL) AS TotalAlignerQuantity
		,   CONVERT(int,NULL) AS DeliverableQuantity
		,   CASE WHEN t.IsKeyStatus = 1 THEN 1 ELSE COUNT(*) END AS StatusCount
		,	MIN(t.StatusDate) AS MinStatusDate
		,	MAX(t.StatusDate) AS MaxStatusDate
		,	MAX(t.ADLSTimestamp) AS ADLSTimestamp
		,	t.Source AS InsertedFromSource
		,	t.Source AS UpdatedFromSource
		,	t._Region
	FROM #Temp_IDS_MES t
	INNER JOIN DW.HubContact hc ON hc.KeyContact = t.Apttus_Config2__PrimaryContactId__c 
	INNER JOIN DW.HubAccount ha1 ON ha1.KeyAccount = t.Apttus_Config2__SoldToAccountId__c
	INNER JOIN DW.HubAccount ha2 ON ha2.KeyAccount = t.Apttus_Config2__ShipToAccountId__c
	INNER JOIN DW.HubAccount ha3 ON ha3.KeyAccount = t.id
	INNER JOIN DW.HubOrder ho ON ho.KeyOrder = t.SAPOrderNumber
	INNER JOIN [Custom].[GeographyHierarchy] gh ON gh.CountryCode = t.CountryCode
	GROUP BY	t.SAPOrderNumber
		,	t.IDSOrderNumber
		,	t.IsKeyStatus
		,   t.SKOrderStatus
		,   hc.SKContact
		,	ho.SKOrder
		,	ha1.SKAccount
		,	ha2.SKAccount
		,	ha3.SKAccount
		,   CONVERT(DATE, t.StatusDate)
		,   t.CountryCode
		,	gh.SecRegion
		,   t.PatientSFID
		,	t.ReceiptDate
		,   t.ProductHierarchy
		,   t.TreatmentOption
		,   t.DeliverableType
		,	t.TreatmentCategory
		,	t.MaterialNumber
		,	t.ProfitCenter
		,	t.ContactNumber
		,	t.ProfCat
		,	t.TreatmentID
		,	t.SoldTo
		,	t.ShipTo
		,	t.TreatmentLocation
		,	t.ItemCategory
		,	t.ClinID
		,	t.SFOrderId
		,	t.SFOrderNumber
		,	t.IsDSO
		,	t.Source
		,	t._Region
	
	UNION ALL

	SELECT 	CONVERT(CHAR(40), '') AS DWHashKey
		,	CONVERT(CHAR(40), '') AS DWHash
		,	t.SAPOrderNumber
		,	t.IDSOrderNumber
		,	t.IsKeyStatus
		,   t.SKOrderStatus
		,   t.SKContact
		,	t.SKOrder
		,	t.SKAccountSoldTo
		,	t.SKAccountShipTo
		,	t.SKAccountTreatmentLocation
		,   MIN(t.StatusDate) AS StatusDate
		,   t.CountryCode
		,	t.SecRegion
		,   NULL AS PatientSFID
		,   NULL AS NewOrRestart
		,   t.Plant
		,	t.ReceiptDate
		,   t.ProductHierarchy
		,   t.TreatmentOption
		,   t.DeliverableType
		,	t.TreatmentCategory
		,	t.MaterialNumber
		,	t.ProfitCenter
		,	t.ContactNumber
		,	t.ProfCat
		,	t.TreatmentID
		,	t.SoldTo
		,	t.ShipTo
		,	t.TreatmentLocation
		,	t.ItemCategory
		,	t.ClinID
		,	t.SFOrderId
		,	t.SFOrderNumber
		,	t.IsDSO
		,   SUM([TotalAlignerQuantity]) AS TotalAlignerQuantity
		,   SUM([DeliverableQuantity]) AS DeliverableQuantity
		,   COUNT(*) AS StatusCount
		,	MIN(t.StatusDate) AS MinStatusDate
		,	MAX(t.StatusDate) AS MaxStatusDate
		,	MAX(t.ADLSTimestamp) AS ADLSTimestamp
		,	t.Source AS InsertedFromSource
		,	t.Source AS UpdatedFromSource
		,	'_EMPTY_' AS _Region
	FROM #SAPShipments t
	GROUP BY	t.SAPOrderNumber
		,	t.IDSOrderNumber
		,	t.IsKeyStatus
		,   t.SKOrderStatus
		,   t.SKContact
		,	t.SKOrder
		,	t.SKAccountSoldTo
		,	t.SKAccountShipTo
		,	t.SKAccountTreatmentLocation
		,   CONVERT(DATE, t.StatusDate)
		,   t.CountryCode  
		,	t.SecRegion
		,	t.ReceiptDate
		,   t.Plant
		,   t.ProductHierarchy
		,   t.TreatmentOption
		,   t.DeliverableType
		,	t.TreatmentCategory
		,	t.MaterialNumber
		,	t.ProfitCenter
		,	t.ContactNumber
		,	t.ProfCat
		,	t.TreatmentID
		,	t.SoldTo
		,	t.ShipTo
		,	t.TreatmentLocation
		,	t.ItemCategory
		,	t.ClinID
		,	t.SFOrderId
		,	t.SFOrderNumber
		,	t.IsDSO
		,	t.Source;


	UPDATE #TempFactVolume SET DWHashKey=
		CONVERT(char(40),
			hashbytes('SHA1',ISNULL(CONVERT(nvarchar, SAPOrderNumber), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,IDSOrderNumber), N'N/A')
				    + N'|' + ISNULL(CONVERT(nvarchar,SKOrderStatus), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,PatientSFID), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,TreatmentCategory), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,TreatmentID), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,StatusDate), N'N/A')
				)
			, 2)
			, DWHash =
		CONVERT(char(40),
			hashbytes('SHA1',ISNULL(CONVERT(nvarchar,IsKeyStatus), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SKContact), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SKOrder), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SKAccountShipTo), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SKAccountSoldTo), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SKAccountTreatmentLocation), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,CountryCode), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SecRegion), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,Plant), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ReceiptDate), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ProductHierarchy), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,TreatmentOption), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,DeliverableType), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,MaterialNumber), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ProfitCenter), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ContactNumber), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ProfCat), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SoldTo), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ShipTo), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,TreatmentLocation), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ItemCategory), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ClinID), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SFOrderId), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SFOrderNumber), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,IsDSO), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,TotalAlignerQuantity), N'N/A')
				    + N'|' + ISNULL(CONVERT(nvarchar,DeliverableQuantity), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,StatusCount), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,MinStatusDate), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,MaxStatusDate), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ADLSTimestamp), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,InsertedFromSource), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,UpdatedFromSource), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,_Region), N'N/A')
				)
			, 2)

 	
	UPDATE DW.FactVolume
		SET	DWBatchID 									= 			@BatchID
		,	DWHash										=			src.DWHash
		,	SKContact									=			src.SKContact
		,	SKOrder										=			src.SKOrder
		,	SKAccountShipTo								=			src.SKAccountShipTo
		,	SKAccountSoldTo								=			src.SKAccountSoldTo
		,	SKAccountTreatmentLocation					=			src.SKAccountTreatmentLocation
		,	CountryCode									=			src.CountryCode
		,	SecRegion									=			src.SecRegion
		,	Plant										=			src.Plant
		,	ReceiptDate									=			src.ReceiptDate
		,	ProductHierarchy							=			src.ProductHierarchy
		,	TreatmentOption								=			src.TreatmentOption
		,	DeliverableType								=			src.DeliverableType
		,	MaterialNumber								=			src.MaterialNumber
		,	ProfitCenter								=			src.ProfitCenter
		,	ContactNumber								=			src.ContactNumber
		,	ProfCat										=			src.ProfCat
		,	SoldTo										=			src.SoldTo
		,	ShipTo										=			src.ShipTo
		,	TreatmentLocation							=			src.TreatmentLocation
		,	ItemCategory								=			src.ItemCategory
		,	ClinID										=			src.ClinID
		,	SFOrderId									=			src.SFOrderId
		,	SFOrderNumber								=			src.SFOrderNumber
		,	IsDSO										=			src.IsDSO
		,	TotalAlignerQuantity                        =           src.TotalAlignerQuantity
		,	DeliverableQuantity                			=           src.DeliverableQuantity
		,	StatusCount                					=           src.StatusCount
		,	MinStatusDate                				=           src.MinStatusDate
		,	MaxStatusDate                				=           src.MaxStatusDate
		,	ADLSTimestamp								=			src.ADLSTimestamp
		,	UpdatedFromSource							=			src.UpdatedFromSource
		,	_Region										=			src._Region
		,	ModifiedDate								=			@CurrentDateTime
	FROM #TempFactVolume src
	WHERE DW.FactVolume.DWHashKey = src.DWHashKey
		AND DW.FactVolume.DWHash != src.DWHash AND NOT ( DW.FactVolume._Region NOT IN ('_EMPTY_', 'Global') AND src._Region = 'Global')
	OPTION (label = 'DW.LoadFactVolume_Update');
	
	EXEC CTRL.GetLastRowCount @Label = 'DW.LoadFactVolume_Update', @rc = @RowsUpdated_IDS_MES OUT

	INSERT INTO DW.FactVolume (
			DWBatchID
		,	DWHashKey
		,	DWHash
		,	SAPOrderNumber
		,	IDSOrderNumber
		,	IsKeyStatus
		,	SKOrderStatus
		,   SKContact
		,	SKOrder
		,	SKAccountSoldTo
		,	SKAccountShipTo
		,	SKAccountTreatmentLocation
		,	StatusDate
		,	CountryCode
		,	SecRegion
		,	PatientSFID
		,	NewOrRestart
		,	Plant
		,	ReceiptDate
		,	ProductHierarchy
		,	TreatmentOption
		,	DeliverableType
		,	TreatmentCategory
		,	MaterialNumber
		,	ProfitCenter
		,	ContactNumber
		,	ProfCat
		,	TreatmentID
		,	SoldTo
		,	ShipTo
		,	TreatmentLocation
		,	ItemCategory
		,	ClinID
		,	SFOrderId
		,	SFOrderNumber
		,	IsDSO
		,	TotalAlignerQuantity
		,	DeliverableQuantity
		,	StatusCount
		,	MinStatusDate
		,	MaxStatusDate
		,	ADLSTimestamp
		,	InsertedFromSource
		,	UpdatedFromSource
		,	_Region
		,	CreatedDate
		,	ModifiedDate
	)
	SELECT	@BatchID
		,	DWHashKey
		,	DWHash
		,	SAPOrderNumber
		,	IDSOrderNumber
		,	IsKeyStatus
		,	SKOrderStatus
		,   SKContact
		,	SKOrder
		,	SKAccountSoldTo
		,	SKAccountShipTo
		,	SKAccountTreatmentLocation
		,	StatusDate
		,	CountryCode
		,	SecRegion
		,	PatientSFID
		,	NewOrRestart
		,	Plant
		,	ReceiptDate
		,	ProductHierarchy
		,	TreatmentOption
		,	DeliverableType
		,	TreatmentCategory
		,	MaterialNumber
		,	ProfitCenter
		,	ContactNumber
		,	ProfCat
		,	TreatmentID
		,	SoldTo
		,	ShipTo
		,	TreatmentLocation
		,	ItemCategory
		,	ClinID
		,	SFOrderId
		,	SFOrderNumber
		,	IsDSO
		,	TotalAlignerQuantity
		,	DeliverableQuantity
		,	StatusCount
		,	MinStatusDate
		,	MaxStatusDate
		,	ADLSTimestamp
		,	InsertedFromSource
		,	UpdatedFromSource
		,	_Region
		,	@CurrentDateTime
		,	@CurrentDateTime
	FROM #TempFactVolume src
	WHERE NOT EXISTS(SELECT * FROM DW.FactVolume dst WHERE dst.DWHashKey = src.DWHashKey)
	OPTION (label = 'DW.LoadFactVolume_insert');
	
exec CTRL.GetLastRowCount @Label = 'DW.LoadFactVolume_insert', @rc = @RowsInserted_IDS_MES out

IF OBJECT_ID(N'tempdb..#TempFactVolumeIncrementalIDs') IS NOT NULL DROP TABLE #TempFactVolumeIncrementalIDs
IF OBJECT_ID(N'tempdb..#TempFactVolumeIncrementalIDs1') IS NOT NULL DROP TABLE #TempFactVolumeIncrementalIDs1
IF OBJECT_ID(N'tempdb..#TempFactVolumeIncrementalIDs2') IS NOT NULL DROP TABLE #TempFactVolumeIncrementalIDs2
IF OBJECT_ID(N'tempdb..#Temp_IDS_MES') IS NOT NULL DROP TABLE #Temp_IDS_MES
IF OBJECT_ID(N'tempdb..#SAPShipments') IS NOT NULL DROP table #SAPShipments
IF OBJECT_ID('tempdb..#TempFactVolume') IS NOT NULL DROP TABLE #TempFactVolume
	
--------------------------  FROM SFDC SOURCE ------------------------------------------
IF OBJECT_ID(N'tempdb..#TempFactVolumeIncrementalSFDC') IS NOT NULL DROP TABLE #TempFactVolumeIncrementalSFDC
	CREATE TABLE #TempFactVolumeIncrementalSFDC WITH (distribution = round_robin, heap) AS 
	
SELECT DISTINCT aco.Id AS Id, 100 AS SKOrderStatus FROM [SrcSFDC].[Apttus_Config2__Order__c] aco
WHERE  aco.CCA_Date1__C is not null and aco.Treatment_Category__C = @TreatmentCategory
and aco.ADLSTimestamp  >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01')

UNION ALL

SELECT DISTINCT aco.Id AS Id, 108 AS SKOrderStatus FROM [SrcSFDC].[Apttus_Config2__Order__c] aco
WHERE  aco.Cancelled_Date1__c is not null and aco.Treatment_Category__C = @TreatmentCategory
and aco.ADLSTimestamp  >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01')

UNION ALL

SELECT DISTINCT aco.Id AS Id, 118 AS SKOrderStatus FROM [SrcSFDC].[Apttus_Config2__Order__c] aco
WHERE  aco.Cancelled_Date1__c is not null and aco.Treatment_Category__C = @TreatmentCategory
and aco.ADLSTimestamp  >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01')

UNION ALL

SELECT DISTINCT aco.Id AS Id, 80 AS SKOrderStatus FROM [SrcSFDC].[Apttus_Config2__Order__c] aco
WHERE  aco.Receipt_date1__C IS NOT NULL and aco.Treatment_Category__C = @TreatmentCategory
and aco.ADLSTimestamp  >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01');






IF OBJECT_ID(N'tempdb..#Temp_SFDC') IS NOT NULL DROP TABLE #Temp_SFDC
	CREATE TABLE #Temp_SFDC WITH (distribution = round_robin, heap) AS 
	
-- SKOrderStatus 100 SFDC Version

    SELECT	DISTINCT sfo.SAP_Order_ID__C AS SAPOrderNumber
		,	REPLACE(sfo.VIP_Order_ID__C,'VOI','') as IDSOrderNumber
        ,	NULL as IsRI
        ,	NULL as OrderType
		,	1 as IsKeyStatus
        ,	100 AS SKOrderStatus
		-- ,   hc.SKContact
		-- ,	ho.SKOrder
		-- ,	ha1.SKAccount AS SKAccountSoldTo
		-- ,	ha2.SKAccount AS SKAccountShipTo
		-- ,	ha3.SKAccount AS SKAccountTreatmentLocation
        ,	CONVERT(DATETIME, sfo.CCA_Date__C AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific standard time') AS StatusDate
        ,	a.ShippingCountryCode as CountryCode
		-- ,	gh.SecRegion
        ,	sfo.Patient_ID__c AS PatientSFID
        ,	CONVERT(DATE, null) as ReceiptDate
        ,	sapd.PRODH ProductHierarchy
        ,	sapd.ZZDELI_TYPE DeliverableType
        ,	sapd.ZZTREAT_OPT TreatmentOption
		,	sfo.Treatment_Category__C AS TreatmentCategory
		,	TRY_CONVERT(INT, sapd.MATNR) AS MaterialNumber
		,	TRY_CONVERT(INT, sapd.PRCTR) AS ProfitCenter
		,	sfo.Contact_ID__c  AS ContactNumber
		,	sfo.Professional_Category__C AS ProfCat
		,	sfo.Treatment_ID_Number__c AS TreatmentID
		,	sfo.Sold_To_Account_Number__c AS SoldTo
		,	sfo.Ship_To_Account_Number__c AS ShipTo
		,	a.Account_Number__c AS TreatmentLocation
		,	sapd.PSTYV AS ItemCategory
		,	sfo.ClinId__c AS ClinID
		,	sfo.Id AS SFOrderId
		,	sfo.Name AS SFOrderNumber
		,	CASE WHEN sld.Type = 'Group' AND sld.ParentID IS NULL THEN 'Yes' ELSE 'No' END IsDSO
		,	sfo.ADLSTimestamp
		,	'SFDC' AS Source
		,	sfo.Apttus_Config2__PrimaryContactId__c
		,	sfo.Apttus_Config2__SoldToAccountId__c
		,	sfo.Apttus_Config2__ShipToAccountId__c
		,	a.id
    FROM #SrcSFDC_Apttus_Config2__Order__c sfo
	INNER JOIN #TempFactVolumeIncrementalSFDC tmpSFDC ON sfo.Id = tmpSFDC.Id AND tmpSFDC.SKOrderStatus = 100
    INNER JOIN SrcSFDC.Account a ON sfo.Treatment_Location__C = a.id
	INNER JOIN SrcSFDC.Account sld ON sfo.Apttus_Config2__SoldToAccountId__c = sld.id
    INNER JOIN SrcSAP.VBAP sapd ON RIGHT(CONCAT('000',sfo.SAP_Order_ID__C),10)= sapd.VBELN
    WHERE sfo.Treatment_Category__C = @TreatmentCategory
        AND sapd.PSTYV IN ('Z001','Z002','Z003','Z004','Z005','Z006','Z008')
        AND sapd.ZZTREAT_OPT <> 'UNKNOWN' AND sfo.CCA_Date1__C IS NOT NULL

UNION ALL

-- SKOrderStatus 108 SFDC Version
    SELECT	DISTINCT sfo.SAP_Order_ID__C AS SAPOrderNumber
		,	REPLACE(sfo.VIP_Order_ID__C,'VOI','') as IDSOrderNumber
        ,	NULL as IsRI
        ,	NULL as OrderType
		,	1 as IsKeyStatus
        ,	108 AS SKOrderStatus
		-- ,   hc.SKContact
		-- ,	ho.SKOrder
		-- ,	ha1.SKAccount AS SKAccountSoldTo
		-- ,	ha2.SKAccount AS SKAccountShipTo
		-- ,	ha3.SKAccount AS SKAccountTreatmentLocation
        ,	sfo.Cancelled_Date1__c AS StatusDate
        ,	a.ShippingCountryCode AS CountryCode 
		-- ,	gh.SecRegion
        ,	sfo.Patient_ID__c AS PatientSFID
        ,	CONVERT(DATE, sfo.Receipt_Date1__c) AS ReceiptDate
        ,	t.ProductHierarchy
        ,	sapd.ZZDELI_TYPE DeliverableType
        ,	sapd.ZZTREAT_OPT TreatmentOption
		,	sfo.Treatment_Category__C AS TreatmentCategory
		,	TRY_CONVERT(INT, sapd.MATNR) AS MaterialNumber
		,	TRY_CONVERT(INT, sapd.PRCTR) AS ProfitCenter
		,	sfo.Contact_ID__c  AS ContactNumber
		,	sfo.Professional_Category__C AS ProfCat
		,	sfo.Treatment_ID_Number__c AS TreatmentID
		,	sfo.Sold_To_Account_Number__c AS SoldTo
		,	sfo.Ship_To_Account_Number__c AS ShipTo
		,	a.Account_Number__c AS TreatmentLocation
		,	sapd.PSTYV AS ItemCategory
		,	sfo.ClinId__c AS ClinID
		,	sfo.Id AS SFOrderId
		,	sfo.Name AS SFOrderNumber
		,	CASE WHEN sld.Type = 'Group' AND sld.ParentID IS NULL THEN 'Yes' ELSE 'No' END IsDSO
		,	sfo.ADLSTimestamp
		,	'SFDC' AS Source
		,	sfo.Apttus_Config2__PrimaryContactId__c
		,	sfo.Apttus_Config2__SoldToAccountId__c
		,	sfo.Apttus_Config2__ShipToAccountId__c
		,	a.id
    FROM #SrcSFDC_Apttus_Config2__Order__c sfo
	INNER JOIN #TempFactVolumeIncrementalSFDC tmpSFDC ON sfo.Id = tmpSFDC.Id AND tmpSFDC.SKOrderStatus = 108
    INNER JOIN SrcSFDC.Account a ON sfo.Treatment_Location__C = a.id
	INNER JOIN SrcSFDC.Account sld ON sfo.Apttus_Config2__SoldToAccountId__c = sld.id
    INNER JOIN SrcSAP.VBAP sapd ON RIGHT(CONCAT('000',sfo.SAP_Order_ID__C),10) = sapd.VBELN
    INNER JOIN SrcSAPFile.TreatmentOption t ON sapd.ZZTREAT_OPT = t.SAPTreatmentOption
    WHERE sfo.Treatment_Category__C = @TreatmentCategory   
        AND sfo.Receipt_Date1__C IS NOT NULL AND sfo.Cancelled_Date1__c IS NOT NULL
        AND sapd.PSTYV = 'Z000'
        AND sapd.ZZTREAT_OPT <> 'UNKNOWN'
		
UNION ALL

-- SKOrderStatus 118 SFDC Version

    SELECT	DISTINCT sfo.SAP_Order_ID__C AS SAPOrderNumber
		,	REPLACE(sfo.VIP_Order_ID__C,'VOI','') as IDSOrderNumber
        ,	NULL as IsRI
        ,	NULL as OrderType
		,	1 as IsKeyStatus
        ,	118 AS SKOrderStatus
		-- ,   hc.SKContact
		-- ,	ho.SKOrder
		-- ,	ha1.SKAccount AS SKAccountSoldTo
		-- ,	ha2.SKAccount AS SKAccountShipTo
		-- ,	ha3.SKAccount AS SKAccountTreatmentLocation
        ,	sfo.Cancelled_Date1__c AS StatusDate
        ,	a.ShippingCountryCode AS CountryCode
		-- ,	gh.SecRegion
        ,	sfo.Patient_ID__c AS PatientSFID
        ,	CONVERT(DATE, NULL) AS ReceiptDate
        ,	t.ProductHierarchy
        ,	sapd.ZZDELI_TYPE DeliverableType
        ,	sapd.ZZTREAT_OPT TreatmentOption
		,	sfo.Treatment_Category__C AS TreatmentCategory
		,	TRY_CONVERT(INT, sapd.MATNR) AS MaterialNumber
		,	TRY_CONVERT(INT, sapd.PRCTR) AS ProfitCenter
		,	sfo.Contact_ID__c  AS ContactNumber
		,	sfo.Professional_Category__C AS ProfCat
		,	sfo.Treatment_ID_Number__c AS TreatmentID
		,	sfo.Sold_To_Account_Number__c AS SoldTo
		,	sfo.Ship_To_Account_Number__c AS ShipTo
		,	a.Account_Number__c AS TreatmentLocation
		,	sapd.PSTYV AS ItemCategory
		,	sfo.ClinId__c AS ClinID
		,	sfo.Id AS SFOrderId
		,	sfo.Name AS SFOrderNumber
		,	CASE WHEN sld.Type = 'Group' AND sld.ParentID IS NULL THEN 'Yes' ELSE 'No' END IsDSO
		,	sfo.ADLSTimestamp
		,	'SFDC' AS Source
		,	sfo.Apttus_Config2__PrimaryContactId__c
		,	sfo.Apttus_Config2__SoldToAccountId__c
		,	sfo.Apttus_Config2__ShipToAccountId__c
		,	a.id
    FROM #SrcSFDC_Apttus_Config2__Order__c sfo
	INNER JOIN #TempFactVolumeIncrementalSFDC tmpSFDC ON sfo.Id = tmpSFDC.Id AND tmpSFDC.SKOrderStatus = 118
    INNER JOIN SrcSFDC.Account a ON sfo.Treatment_Location__C = a.id
	INNER JOIN SrcSFDC.Account sld ON sfo.Apttus_Config2__SoldToAccountId__c = sld.id
    INNER JOIN SrcSAP.VBAP sapd ON RIGHT(CONCAT('000',sfo.SAP_Order_ID__C),10)= sapd.VBELN
    INNER JOIN SrcSAPFile.TreatmentOption t ON sapd.ZZTREAT_OPT = t.SAPTreatmentOption
    WHERE sfo.Treatment_Category__C = @TreatmentCategory     
        AND sfo.Receipt_Date1__C IS NOT NULL AND sfo.Cancelled_Date1__c IS NOT NULL
        AND sapd.PSTYV IN ('Z001','Z002','Z003','Z004','Z005','Z006','Z008')
        AND sapd.ZZTREAT_OPT <> 'UNKNOWN'
        AND  CONVERT(DATE, CCA_Date1__c)  <= CONVERT(DATE, sfo.Cancelled_Date1__c) 

UNION ALL

-- SKOrderStatus 80 Missing MES AMR Date issue
	SELECT	DISTINCT wo.order_number AS SAPOrderNumber
		,	REPLACE(sfo.VIP_Order_ID__C,'VOI','') as IDSOrderNumber
        ,	NULL as IsRI
        ,	NULL as OrderType
		,	1 as IsKeyStatus
        ,	80 AS SKOrderStatus
		-- ,   hc.SKContact
		-- ,	ho.SKOrder
		-- ,	ha1.SKAccount AS SKAccountSoldTo
		-- ,	ha2.SKAccount AS SKAccountShipTo
		-- ,	ha3.SKAccount AS SKAccountTreatmentLocation
        ,	sfo.Receipt_date1__C AS StatusDate
        ,	a.ShippingCountryCode AS CountryCode
		-- ,	gh.SecRegion
        ,	sfo.Patient_ID__c AS PatientSFID
        ,	CONVERT(DATE, NULL) AS ReceiptDate
        ,	t.ProductHierarchy
        -- ,	sapd.ZZDELI_TYPE DeliverableType
        -- ,	sapd.ZZTREAT_OPT TreatmentOption
		,	uo.at_DeliverableType_S AS DeliverableType
		,	uo.at_TreatmentOption_S AS TreatmentOption
		,	sfo.Treatment_Category__C AS TreatmentCategory
		,	TRY_CONVERT(INT, sapd.MATNR) AS MaterialNumber
		,	TRY_CONVERT(INT, sapd.PRCTR) AS ProfitCenter
		,	sfo.Contact_ID__c  AS ContactNumber
		,	sfo.Professional_Category__C AS ProfCat
		,	sfo.Treatment_ID_Number__c AS TreatmentID
		,	sfo.Sold_To_Account_Number__c AS SoldTo
		,	sfo.Ship_To_Account_Number__c AS ShipTo
		,	a.Account_Number__c AS TreatmentLocation
		,	sapd.PSTYV AS ItemCategory
		,	sfo.ClinId__c AS ClinID
		,	sfo.Id AS SFOrderId
		,	sfo.Name AS SFOrderNumber
		,	CASE WHEN sld.Type = 'Group' AND sld.ParentID IS NULL THEN 'Yes' ELSE 'No' END IsDSO
		,	sfo.ADLSTimestamp
		,	'SFDC' AS Source
		,	sfo.Apttus_Config2__PrimaryContactId__c
		,	sfo.Apttus_Config2__SoldToAccountId__c
		,	sfo.Apttus_Config2__ShipToAccountId__c
		,	a.id
    FROM SrcMESCorp.Work_Order wo
    INNER JOIN SrcMESCorp.uda_order uo  ON uo.object_key = wo.order_key
    INNER JOIN #SrcSFDC_Apttus_Config2__Order__c sfo ON wo.order_number = sfo.SAP_Order_id__C
	INNER JOIN #TempFactVolumeIncrementalSFDC tmpSFDC ON sfo.Id = tmpSFDC.Id AND tmpSFDC.SKOrderStatus = 80
    INNER JOIN SrcSFDC.Account a ON sfo.Treatment_Location__C = a.id
	INNER JOIN SrcSFDC.Account sld ON sfo.Apttus_Config2__SoldToAccountId__c = sld.id
    INNER JOIN SrcSAPFile.TreatmentOption t ON uo.at_TreatmentOption_S = t.SAPTreatmentOption
	LEFT JOIN SrcSAP.VBAP sapd ON RIGHT(CONCAT('000',sfo.SAP_Order_ID__C),10)= sapd.VBELN AND sapd.PSTYV='Z000' AND sapd.ZZTREAT_OPT <> 'UNKNOWN'
    WHERE sfo.Treatment_Category__C = @TreatmentCategory
		AND uo.at_AllMaterialRecdTime_S IS NULL  AND sfo.Receipt_date1__C IS NOT NULL

IF OBJECT_ID('tempdb..#TempFactVolumeSFDC') IS NOT NULL DROP TABLE #TempFactVolumeSFDC

	CREATE TABLE #TempFactVolumeSFDC WITH (distribution = round_robin, heap) AS 
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
		,	CONVERT(CHAR(40), '') AS DWHash
		,	t.SAPOrderNumber
		,	t.IDSOrderNumber
		,	t.IsKeyStatus
		,   t.SKOrderStatus
		,   hc.SKContact
		,	ho.SKOrder
		,	ha1.SKAccount AS SKAccountSoldTo
		,	ha2.SKAccount AS SKAccountShipTo
		,	ha3.SKAccount AS SKAccountTreatmentLocation
		,   CAST(MIN(t.StatusDate) AS DATE) AS StatusDate
		,   t.CountryCode
		,	gh.SecRegion
		,   t.PatientSFID 
		,   CASE SKOrderStatus WHEN 80 THEN 'New Order' END NewOrRestart
		,   CONVERT(int,NULL) AS Plant
		,	t.ReceiptDate
		,   t.ProductHierarchy
		,   t.TreatmentOption
		,   t.DeliverableType
		,	t.TreatmentCategory
		,	t.MaterialNumber
		,	t.ProfitCenter
		,	t.ContactNumber
		,	t.ProfCat
		,	t.TreatmentID
		,	t.SoldTo
		,	t.ShipTo
		,	t.TreatmentLocation
		,	t.ItemCategory
		,	t.ClinID
		,	t.SFOrderId
		,	t.SFOrderNumber
		,	t.IsDSO
		,   CONVERT(int,NULL) AS TotalAlignerQuantity
		,   CONVERT(int,NULL) AS DeliverableQuantity
		,   CASE WHEN t.IsKeyStatus = 1 THEN 1 ELSE COUNT(*) END AS StatusCount
		,	MIN(t.StatusDate) AS MinStatusDate
		,	MAX(t.StatusDate) AS MaxStatusDate
		,	MAX(t.ADLSTimestamp) AS ADLSTimestamp
		,	t.Source AS InsertedFromSource
		,	t.Source AS UpdatedFromSource
		,	'_EMPTY_' AS _Region
	FROM #Temp_SFDC t
	INNER JOIN DW.HubContact hc ON hc.KeyContact = t.Apttus_Config2__PrimaryContactId__c 
	INNER JOIN DW.HubAccount ha1 ON ha1.KeyAccount = t.Apttus_Config2__SoldToAccountId__c
	INNER JOIN DW.HubAccount ha2 ON ha2.KeyAccount = t.Apttus_Config2__ShipToAccountId__c
	INNER JOIN DW.HubAccount ha3 ON ha3.KeyAccount = t.id
	INNER JOIN DW.HubOrder ho ON ho.KeyOrder = t.SAPOrderNumber
	INNER JOIN [Custom].[GeographyHierarchy] gh ON gh.CountryCode = t.CountryCode
	GROUP BY	t.SAPOrderNumber
		,	t.IDSOrderNumber
		,	t.IsKeyStatus
		,   t.SKOrderStatus
		,   hc.SKContact
		,	ho.SKOrder
		,	ha1.SKAccount
		,	ha2.SKAccount
		,	ha3.SKAccount
		,   CONVERT(DATE, t.StatusDate)
		,   t.CountryCode
		,	gh.SecRegion
		,   t.PatientSFID
		,	t.ReceiptDate
		,   t.ProductHierarchy
		,   t.TreatmentOption
		,   t.DeliverableType
		,	t.TreatmentCategory
		,	t.MaterialNumber
		,	t.ProfitCenter
		,	t.ContactNumber
		,	t.ProfCat
		,	t.TreatmentID
		,	t.SoldTo
		,	t.ShipTo
		,	t.TreatmentLocation
		,	t.ItemCategory
		,	t.ClinID
		,	t.SFOrderId
		,	t.SFOrderNumber
		,	t.IsDSO
		,	t.Source;



	UPDATE #TempFactVolumeSFDC SET DWHashKey=
		CONVERT(char(40),
			hashbytes('SHA1',ISNULL(CONVERT(nvarchar, SAPOrderNumber), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,IDSOrderNumber), N'N/A')
				    + N'|' + ISNULL(CONVERT(nvarchar,SKOrderStatus), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,PatientSFID), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,TreatmentCategory), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,TreatmentID), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,StatusDate), N'N/A')
				)
			, 2)
			, DWHash =
		CONVERT(char(40),
			hashbytes('SHA1',ISNULL(CONVERT(nvarchar,IsKeyStatus), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SKContact), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SKOrder), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SKAccountShipTo), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SKAccountSoldTo), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SKAccountTreatmentLocation), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,CountryCode), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SecRegion), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,Plant), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ReceiptDate), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ProductHierarchy), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,TreatmentOption), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,DeliverableType), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,MaterialNumber), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ProfitCenter), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ContactNumber), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ProfCat), N'N/A')					
					+ N'|' + ISNULL(CONVERT(nvarchar,SoldTo), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ShipTo), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,TreatmentLocation), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ItemCategory), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ClinID), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SFOrderId), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,SFOrderNumber), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,IsDSO), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,TotalAlignerQuantity), N'N/A')
				    + N'|' + ISNULL(CONVERT(nvarchar,DeliverableQuantity), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,StatusCount), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,MinStatusDate), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,MaxStatusDate), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,ADLSTimestamp), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,InsertedFromSource), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,UpdatedFromSource), N'N/A')
					+ N'|' + ISNULL(CONVERT(nvarchar,_Region), N'N/A')
				)
			, 2)

 	
	UPDATE DW.FactVolume
		SET	DWBatchID 									= 			@BatchID
		,	DWHash										=			src.DWHash
		,	StatusDate									=			src.StatusDate
		,	SKContact									=			src.SKContact
		,	SKOrder										=			src.SKOrder
		,	SKAccountShipTo								=			src.SKAccountShipTo
		,	SKAccountSoldTo								=			src.SKAccountSoldTo
		,	SKAccountTreatmentLocation					=			src.SKAccountTreatmentLocation
		,	CountryCode									=			src.CountryCode
		,	SecRegion									=			src.SecRegion
		,	Plant										=			src.Plant
		,	ReceiptDate									=			src.ReceiptDate
		,	ProductHierarchy							=			src.ProductHierarchy
		,	TreatmentOption								=			src.TreatmentOption
		,	DeliverableType								=			src.DeliverableType
		,	MaterialNumber								=			src.MaterialNumber
		,	ProfitCenter								=			src.ProfitCenter
		,	ContactNumber								=			src.ContactNumber
		,	ProfCat										=			src.ProfCat
		,	SoldTo										=			src.SoldTo
		,	ShipTo										=			src.ShipTo
		,	TreatmentLocation							=			src.TreatmentLocation
		,	ItemCategory								=			src.ItemCategory
		,	ClinID										=			src.ClinID
		,	SFOrderId									=			src.SFOrderId
		,	SFOrderNumber								=			src.SFOrderNumber
		,	IsDSO										=			src.IsDSO
		,	TotalAlignerQuantity                        =           src.TotalAlignerQuantity
		,	DeliverableQuantity                			=           src.DeliverableQuantity
		,	StatusCount                					=           src.StatusCount
		,	MinStatusDate                				=           src.MinStatusDate
		,	MaxStatusDate                				=           src.MaxStatusDate
		,	ADLSTimestamp								=			src.ADLSTimestamp
		,	UpdatedFromSource							=			src.UpdatedFromSource
		,	_Region										=			src._Region
		,	ModifiedDate								=			@CurrentDateTime
	FROM #TempFactVolumeSFDC src
	WHERE DW.FactVolume.DWHashKey = src.DWHashKey AND DW.FactVolume.UpdatedFromSource = 'SFDC'
		AND DW.FactVolume.DWHash != src.DWHash
	OPTION (label = 'DW.LoadFactVolume_SFDC_Update');
	
	EXEC CTRL.GetLastRowCount @Label = 'DW.LoadFactVolume_SFDC_Update', @rc = @RowsUpdated_SFDC OUT

	INSERT INTO DW.FactVolume (
			DWBatchID
		,	DWHashKey
		,	DWHash
		,	SAPOrderNumber
		,	IDSOrderNumber
		,	IsKeyStatus
		,	SKOrderStatus
		,   SKContact
		,	SKOrder
		,	SKAccountSoldTo
		,	SKAccountShipTo
		,	SKAccountTreatmentLocation
		,	StatusDate
		,	CountryCode
		,	SecRegion
		,	PatientSFID
		,	NewOrRestart
		,	Plant
		,	ReceiptDate
		,	ProductHierarchy
		,	TreatmentOption
		,	DeliverableType
		,	TreatmentCategory
		,	MaterialNumber
		,	ProfitCenter
		,	ContactNumber
		,	ProfCat
		,	TreatmentID
		,	SoldTo
		,	ShipTo
		,	TreatmentLocation
		,	ItemCategory
		,	ClinID
		,	SFOrderId
		,	SFOrderNumber
		,	IsDSO
		,	TotalAlignerQuantity
		,	DeliverableQuantity
		,	StatusCount
		,	MinStatusDate
		,	MaxStatusDate
		,	ADLSTimestamp
		,	InsertedFromSource
		,	UpdatedFromSource
		,	_Region
		,	CreatedDate
		,	ModifiedDate
	)
	SELECT	@BatchID
		,	DWHashKey
		,	DWHash
		,	SAPOrderNumber
		,	IDSOrderNumber
		,	IsKeyStatus
		,	SKOrderStatus
		,   SKContact
		,	SKOrder
		,	SKAccountSoldTo
		,	SKAccountShipTo
		,	SKAccountTreatmentLocation
		,	StatusDate
		,	CountryCode
		,	SecRegion
		,	PatientSFID
		,	NewOrRestart
		,	Plant
		,	ReceiptDate
		,	ProductHierarchy
		,	TreatmentOption
		,	DeliverableType
		,	TreatmentCategory
		,	MaterialNumber
		,	ProfitCenter
		,	ContactNumber
		,	ProfCat
		,	TreatmentID
		,	SoldTo
		,	ShipTo
		,	TreatmentLocation
		,	ItemCategory
		,	ClinID
		,	SFOrderId
		,	SFOrderNumber
		,	IsDSO
		,	TotalAlignerQuantity
		,	DeliverableQuantity
		,	StatusCount
		,	MinStatusDate
		,	MaxStatusDate
		,	ADLSTimestamp
		,	InsertedFromSource
		,	UpdatedFromSource
		,	_Region
		,	@CurrentDateTime
		,	@CurrentDateTime
	FROM #TempFactVolumeSFDC src
	WHERE NOT EXISTS(SELECT * FROM DW.FactVolume dst WHERE dst.DWHashKey = src.DWHashKey)
	OPTION (label = 'DW.LoadFactVolume_SFDC_insert');
	
exec CTRL.GetLastRowCount @Label = 'DW.LoadFactVolume_SFDC_insert', @rc = @RowsInserted_SFDC out

---------------------------------------------------------------------------------------
	
	IF OBJECT_ID(N'tempdb..#Cancellations') IS NOT NULL DROP TABLE #Cancellations  
	
CREATE TABLE #Cancellations WITH (distribution = round_robin, heap)
AS 
    SELECT  canc.SAPOrderNumber
        ,   PatientSFID
        ,   canc.StatusDate AS CancellationDate
		,	TreatmentCategory
    FROM DW.FactVolume canc
    where canc.SKOrderStatus = 108
        AND canc.ReceiptDate IS NOT NULL 
		AND canc.StatusDate >= CAST(DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @CancelledMaxStatusDate), 0) AS DATE)
	
	UPDATE nc SET nc.NewOrRestart = 'Restart'
	FROM DW.FactVolume nc
	INNER JOIN #Cancellations canc ON nc.PatientSFID = canc.PatientSFID AND nc.TreatmentCategory = canc.TreatmentCategory 
    AND DATEPART(qq, nc.StatusDate) = DATEPART(qq, canc.CancellationDate)
    AND YEAR(nc.StatusDate) = YEAR(canc.CancellationDate)
	WHERE nc.SAPOrderNumber > canc.SAPOrderNumber  and nc.SKOrderStatus=80
	
	UPDATE STATISTICS [DW].[FactVolume] (STATS_DW_FactVolume_DWHashKey)
	UPDATE STATISTICS [DW].[FactVolume] (STATS_DW_FactVolume_DWHash)

	IF OBJECT_ID(N'tempdb..#TempFactVolumeIncrementalSFDC') IS NOT NULL DROP TABLE #TempFactVolumeIncrementalSFDC
	IF OBJECT_ID(N'tempdb..#Temp_SFDC') IS NOT NULL DROP TABLE #Temp_SFDC
	IF OBJECT_ID('tempdb..#TempFactVolumeSFDC') IS NOT NULL DROP TABLE #TempFactVolumeSFDC
	IF OBJECT_ID(N'tempdb..#SrcSFDC_Apttus_Config2__Order__c') IS NOT NULL DROP TABLE #SrcSFDC_Apttus_Config2__Order__c
	IF OBJECT_ID(N'tempdb..#Cancellations') IS NOT NULL DROP TABLE #Cancellations
	
	SET @RowsInserted = @RowsInserted_IDS_MES + @RowsInserted_SFDC
	SET @RowsUpdated = @RowsUpdated_IDS_MES + @RowsUpdated_SFDC

	-- SELECT @RowsInserted AS RowsInserted, @RowsUpdated AS RowsUpdated
	

END