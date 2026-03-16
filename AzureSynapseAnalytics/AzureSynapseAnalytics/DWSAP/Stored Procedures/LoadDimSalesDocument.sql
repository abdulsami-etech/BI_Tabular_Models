CREATE PROC [DWSAP].[LoadDimSalesDocument] @BatchID [int],@LAStSuccessfullDWTimestamp [datetime2](0) AS  
--Set current datetime for incremental updates
BEGIN
	DECLARE  @lAStdatetime datetime
			,@RowsInserted	int = 0
			,@RowsUpdated	int = 0
			,@IsFullLoad	bit = 0
			IF (EXISTS (SELECT *
                 FROM INFORMATION_SCHEMA.TABLES
                 WHERE TABLE_SCHEMA = 'DWSAP'
                 AND  TABLE_NAME = 'DimSalesDocument'))
			BEGIN
	SET @lAStdatetime = (SELECT ISNULL(MAX(CONVERT(datetime,ADLSTimestamp)) ,'1900-01-01 00:00:00') FROM DWSAP.DimSalesDocument)
	END
	ELSE
	BEGIN
	SET @lAStdatetime = '1900-01-01 00:00:00'
	END
	

	BEGIN TRANSACTION; 

	DELETE  DWSAP.DimSalesDocument
	FROM  DWSAP.DimSalesDocument
	INNER JOIN SrcSAP.VBAP 
	ON  
	--Jira Number BI-11966
	--Removing Initial Zeros from the Sales Order and Item in the joining condition for 9 digit Sales Order.
	(REPLACE(LTRIM(REPLACE(SrcSAP.VBAP.VBELN,'0',' ')),' ','0')  = DWSAP.DimSalesDocument.[Sales Document]  and 
	REPLACE(LTRIM(REPLACE(SrcSAP.VBAP.POSNR,'0',' ')),' ','0') = DWSAP.DimSalesDocument.[Sales Document Item]
	) WHERE SrcSAP.VBAP.ADLSTimestamp>@lAStdatetime
	print('Deleting the common Records')
	
	
	INSERT INTO DWSAP.DimSalesDocument
	   SELECT 
		   c.ADLSTimestamp
		   ,CONCAT (YEAR (c.AUDAT),'-',MONTH(c.AUDAT)) AS [PartitionColumn]
		   
		   --Jira Number BI-11966
		   --Removing zeros while Inserting the new values from the VBAP into Sales Document Table(For Sales Document and Sales Document Item)
		  ,REPLACE(LTRIM(REPLACE(c.[VBELN],'0',' ')),' ','0') AS [Sales Document]
		  ,REPLACE(LTRIM(REPLACE(c.[POSNR] ,'0',' ')),' ','0') AS [Sales Document Item]	
		  ,c.[KWMENG] [OrderQuantity]
		  ,b.[AUART] [Sales Document Type]
		  ,b.[VBTYP] [Sales Document Category]
		  ,c.[PSTYV] [Item Category-Sales Document]
		  ,b.[FKARA] [Billing Type]
		  --,a.[Id] [SFDC Order ID]
		  /*JIRA : BI-11264*/
		  ,CASE WHEN a.AgeTierCode > 80 THEN -1
		        WHEN a.AgeTierCode IS NULL AND  REPLACE(LTRIM(REPLACE(a.OrderNumber ,'0',' ')),' ','0') = REPLACE(LTRIM(REPLACE(b.VBELN ,'0',' ')),' ','0') THEN -1 
		        WHEN a.AgeTierCode < -1 THEN -1 
		        ELSE a.[AgeTierCode] END AS [Age Tier] /* Less than -1 is also -1*/
		  ,a.[OrderStages] AS [Order Stages]
		  ,a.[Stagesbucket] AS [Stage Bucket]
		  ,a.[PatientType]
		  ,a.[ProductType]
		  ,a.[TreatingDoctor]
		  ,COALESCE (REPLACE(LTRIM(REPLACE(a.[ShipTo],'0',' ')),' ','0'),REPLACE(LTRIM(REPLACE(vbpap.WE,'0',' ')),' ','0')) AS [ShipTo]
		  ,COALESCE (REPLACE(LTRIM(REPLACE(a.[SoldTo],'0',' ')),' ','0'),REPLACE(LTRIM(REPLACE(vbpap.AG,'0',' ')),' ','0'))  AS [SoldTo]
		  --,a.[AMRDate]
		  ,a.[CCADate]
		  --,a.[ShipDate]
--		  ,COALESCE(a.[TreatmentCategory],CASE WHEN b.[ZZDELI_CATE] = '' THEN Null else b.[ZZDELI_CATE] end) [TreatmentCategory]
		  ,CASE WHEN b.[ZZDELI_CATE] = '' THEN Null else b.[ZZDELI_CATE] end [TreatmentCategory]
--		  ,a.[TreatmentCategory]
		 ,a.[TreatmentLocation]
		  ,a.[ClinID]
		  ,a.[ISIOScan] AS [Is IO Scan]
		  ,a.[ProfessionalCategory] [Professional Category]
		  --,d.[CertificationDate] [Certification Date]
		  --,year(d.[CertificationDate]) [CertificationYear]
		  ,a.[AdvantageTier] [Advantage Tier]
			,a.[AdvantageProgramName] [Advantage Program Name]
			,a.[MAF] [MAF]
		  ,b.VKORG AS [Sales Org]
		  ,b.SPART AS [Division]
          
          --Jira Number BI-11966
		  --Removing the initial zeros from SD and SDI for creating Sales Order Key
		  ,CONCAT( REPLACE(LTRIM(REPLACE(c.[VBELN] ,'0',' ')),' ','0'),'/',REPLACE(LTRIM(REPLACE(c.[POSNR] ,'0',' ')),' ','0')) AS [Sales Order Key]
		--,e.[Country] [Treatment Location – Country]
		--,e.[CountryGroup] [Treatment Loc-Country Group]
		--,e.[RegionPC] [Treatment Loc-Region]
		--,e.[RegionGroup] [Treatment Loc-Region Group]   
		--,e.[GlobalRegion] [Treatment Loc-Global Region Group]
		/*JIRA : BI-11264*/
		  ,CASE 
		      WHEN c.[ZZCOMP_IND] = ' ' 
			  THEN b.[ZZCOMP_IND] 
			  ELSE c.[ZZCOMP_IND] 
			  END AS [Compliance Indicator]
		--JIRA /**11264**/
		  ,CASE 
		     WHEN b.[ZZDELI_CATE] = 'Primary' 
			 THEN 'Paid'

			 WHEN b.[ZZDELI_CATE] = 'Secondary' AND ZZDELI_TYPE IN 
				  (SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY'))
				  and c.[ZZFRE_QTY] = 0 THEN 'Paid'
			 WHEN b.[ZZDELI_CATE] = 'Secondary' AND ZZDELI_TYPE IN 
				(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY'))  
				and c.[ZZFRE_QTY] = c.[ZZTOT_QTY] 
			 THEN 'Free'

			 WHEN b.[ZZDELI_CATE] = 'Secondary' AND ZZDELI_TYPE IN 
				(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY'))  
				and (c.[ZZTOT_QTY] - c.[ZZFRE_QTY]) > 0   
			 THEN 'Paid'

			 WHEN b.[ZZDELI_CATE] = 'Secondary' AND ZZDELI_TYPE IN 
				(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY'))  
				and (c.[ZZTOT_QTY] - c.[ZZFRE_QTY]) < 0   
			 THEN 'Error'

			 WHEN b.[ZZDELI_CATE] = 'Secondary'  AND ZZDELI_TYPE NOT IN 
				(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY')) AND 
				c.[PRODH] LIKE 'A1A1%' AND c.[NETPR] = '0.00' 
			 THEN 'Free'

			 WHEN b.[ZZDELI_CATE] = 'Secondary'  AND ZZDELI_TYPE NOT IN 
				(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY')) AND 
				c.[PRODH] LIKE 'A1A1%' AND c.[NETPR] <> '0.00' 
			 THEN 'Paid'

			 WHEN b.[ZZDELI_CATE] ='' AND c.[PRODH] LIKE 'A1S1U1%' 
			 THEN 'Paid'

			 WHEN b.[ZZDELI_CATE] ='' AND c.[PRODH] LIKE 'A1S1U2%' AND c.[NETPR] = '0.00' 
			 THEN 'Free'

			 WHEN b.[ZZDELI_CATE] ='' AND c.[PRODH] LIKE 'A1S1U2%' AND c.[NETPR] <> '0.00' 
			 THEN 'Paid' 
				end [Free_Paid]
		,b.[BSTNK] [PO Number]
		,c.[ZZTREAT_OPT] [Treatment Option]
		,c.[ZZDELI_TYPE] [Deliverable Type]
		,b.[ZZVIP_ORD] AS [IDSOrderID] 
		,b.[ZZSFDC_ORD] AS  [SFDCOrderID]
		/*Material*/
		,c.[MATKL] AS [Material Group]
		,c.[MATNR] AS [Material Number]
		,c.[MVGR1] AS [Material Group 1]
		,c.[MVGR2] AS [Material Group 2]
		,c.[MVGR3] AS [Material Group 3]
		,c.[MVGR4] AS [Material Group 4]
		,c.[MVGR5] AS [Material Group 5]
		/*Organizational Units*/
		,b.[VTWEG] AS [Distribution Channel]
		,b.VKGRP AS	[Sales Group]
		,b.VKBUR AS [Sales Office]
		,b.KOKRS AS [Controlling Area]
		,f.EKORG AS [PurchASing Org]
		/*Units*/
		,c.MEINS [BASe Unit of MeASure]
		,c.[VRKME] [Sales Unit]
		,'' [Unit of Dimension for length/Width/Height]
		,c.VOLEH [Volume Unit]
		,c.GEWEI [Weight Unit]
		/*Customer Data */
		,COALESCE (REPLACE(LTRIM(REPLACE(a.[BillTo],'0',' ')),' ','0'),REPLACE(LTRIM(REPLACE(vbpap.RE,'0',' ')),' ','0')) [Bill-to party]
		--,concat('0000',a.[ShipTo]) [Ship-to party]
		,a.[Payer]
--		,b.[KUNNR] [Sold-to party]
		,sh.[Country] [Country of ship-to party] 
		--,b.[BSTNK] [Customer number] 
		--,b.[KVGR1] [Customer Group]
		,b.[KVGR1] [Customer Group1]
		,b.[KVGR2] [Customer Group2]
		,b.[KVGR3] [Customer Group3]
		,b.[KVGR4] [Customer Group4]
		,b.[KVGR5] [Customer Group5]
			/*Additional Fields later added */
		--,c.[ZZCLINICAL] [Clinical Study]
		,b.[ZZSR_NO] [Equipment Serial Num]
		--,b.[ZZEXT_TXID] AS [External Treatment Id]
		,b.[ZZ_IN_COM_ID] AS [Initiator Company Id]
		,b.[ZZAMR_DATE] AS [AMR Date COPA]
		--,b.[ZZCCS_DATE] AS [CCS Date]
		,c.[ZZPROMO] AS [Promotion Bucket]
		,c.[ZZTREV_DATE] AS [Revenue Recognition]
		,c.[ZZTOTAL_QTY] AS [Total Quantity]
		,c.[AUDAT] AS [Document Date]
		,year(c.[AUDAT]) AS [Document Year]
		,a.UpperAlignerStartstage
		,a.UpperAlignerEndStage
		,a.LowerAlignerStartstage
		,a.LowerAlignerEndStage
		,a.[CustomerGroupType]
		,a.[IsDSOOrder]
		,c.[LGORT] [Storage Location]
		,vbpap.[ZA] [Align Retail]
		,vbpap.[ZM] [Employee Responsible]
		,vbpap.[ZF] [Financial Contact]
		,vbpap.[ZJ] [Junior Doctor]
		,vbpap.[ZS] [Submitting Student]
		,vbpap.[ZE] [Territory Manager]
		,CASE
		   WHEN a.AgeTierCode> 80 
		   THEN '80+' 
		   ELSE  age.[AgeTierRange] 
		   end AS [AgeTierRange]

		,CASE 
		   WHEN a.AgeTierCode> 80 OR a.AgeTierCode < -1 
		   THEN 'Unknown'

		   WHEN a.AgeTiercode IS NULL AND REPLACE(LTRIM(REPLACE(a.OrderNumber ,'0',' ')),' ','0') = REPLACE(LTRIM(REPLACE(b.VBELN ,'0',' ')),' ','0') 
		   THEN 'Unknown'
			  ELSE age.[AgeTierDetail] 
			  end AS [AgeTierDetail]

		,CASE 
		   WHEN a.AgeTierCode> 80 OR a.AgeTierCode < -1 
		   THEN 'Adult'

		   WHEN a.AgeTiercode IS NULL AND  REPLACE(LTRIM(REPLACE(a.OrderNumber ,'0',' ')),' ','0') = REPLACE(LTRIM(REPLACE(b.VBELN ,'0',' ')),' ','0') 
		   THEN 'Adult'
		     ELSE age.[AgeSegment] 
			 end AS [AgeSegment]


		,CASE 
		  WHEN a.AgeTierCode> 80 
		  THEN  'Adult (80+)' 
		  else age.[AgeCategory] 
		  end AS [AgeCategory]

		,makt.[MAKTX] [Material Text] 
		,COALESCE (bt.AccountName,kn2.AccountName)  AS [Bill-to party text]
		,COALESCE (sh.AccountName,kn.AccountName) AS [ShipTo Text]
		,COALESCE (sot.AccountName,kn1.AccountName) AS [SoldTo Text]
		,b.ZZTREATMENT AS [TreatmentId]
		,ISNULL(c.[KWMENG],0) [Order Quantity]
		  FROM [SrcSAP].[VBAP] c
		  INNER JOIN  [SrcSAP].[VBAK] b   
		  ON REPLACE(LTRIM(REPLACE(c.[VBELN] ,'0',' ')),' ','0') = REPLACE(LTRIM(REPLACE(b.[VBELN] ,'0',' ')),' ','0') 
		  --INNER JOIN [SrcSAP].[LIPS] lips ON lips.[VGBEL] = c.[VBELN] and lips.[VGPOS] = c.[POSNR]
		  --INNER JOIN [SrcSAP].[LIKP] likp ON likp.[VBELN] = lips.[VBELN]
		  LEFT JOIN  DWSAP.VBPA_Pivoted_v2 vbpap 
		  on REPLACE(LTRIM(REPLACE(b.[VBELN] ,'0',' ')),' ','0') = REPLACE(LTRIM(REPLACE(vbpap.VBELN ,'0',' ')),' ','0')
		  LEFT JOIN  SrcSAP.MAKT makt
		  on c.MATNR = makt.MATNR and makt.SPRAS = 'E'
		  LEFT JOIN  [TabSAP].[DimOrderAttributes] a 
		  ON REPLACE(LTRIM(REPLACE(a.[OrderNumber] ,'0',' ')),' ','0') = REPLACE(LTRIM(REPLACE(b.[VBELN] ,'0',' ')),' ','0')
		  LEFT JOIN [SrcSAPFile].[Age] age 
		  on age.AgeKey = a.[AgeTierCode]
		  LEFT JOIN [SrcSAP].[TVKO] f 
		  on f.[VKORG] = b.[VKORG]
		  LEFT JOIN  TABSAP.DimCusAccount sh 
		  on sh.AccountNumber = a.ShipTo 
		  LEFT JOIN TABSAP.DimCusAccount bt 
		  on bt.AccountNumber  = a.BillTo 
		  LEFT JOIN TABSAP.DimCusAccount sot 
		  on sot.AccountNumber  = a.SoldTo
		  LEFT JOIN  TABSAP.DimCusAccount kn 
		  on REPLACE(LTRIM(REPLACE(vbpap.WE, '0', ' ')),' ', '0') =kn.AccountNumber
		  LEFT JOIN  TABSAP.DimCusAccount kn1 
		  on REPLACE(LTRIM(REPLACE(vbpap.AG, '0', ' ')),' ', '0') =kn1.AccountNumber
		  LEFT JOIN  TABSAP.DimCusAccount kn2 
		  on REPLACE(LTRIM(REPLACE(vbpap.RE, '0', ' ')),' ', '0') =kn2.AccountNumber 
		  WHERE c.ADLSTimestamp > @lAStdatetime 
--JIRA NUMBER // BI-11264
		 /* AND CONCAT (REPLACE(LTRIM(REPLACE(c.[VBELN] ,'0',' ')),' ','0'),'/',REPLACE(LTRIM(REPLACE(c.[POSNR] ,'0',' ')),' ','0')) NOT IN ( SELECT  CONCAT (REPLACE(LTRIM(REPLACE(OBJECTID,'0',' ')),' ','0'),'/',CAST (RIGHT (TABKEY,6 ) AS int)) AS Sals
																		FROM SrcSAP.ZVOTC_CDHDR_POS1 zcp 
																		WHERE zcp.CHNGIND= 'D' ANd TABNAME = 'VBAP')
			*/				
																		
		  UPDATE DWSAP.DimSalesDocument
		  SET [Compliance Indicator] = NULL 
		  WHERE [Compliance Indicator] = ' '

	
	COMMIT;

select @RowsInserted - @RowsUpdated AS RowsInserted, @RowsUpdated AS RowsUpdated

--Checking Deleted Orders and Items in DIMSalesDocument When [Sales Document] only has CHNGIND= 'D'
;with CTE as(
SELECT  CONCAT (REPLACE(LTRIM(REPLACE(OBJECTID,'0',' ')),' ','0'),'/',CAST (RIGHT (TABKEY,6 ) AS int)) AS Sals,UDATE
FROM SrcSAP.ZVOTC_CDHDR_POS1 zcp
WHERE zcp.CHNGIND= 'D' ANd TABNAME = 'VBAP'),
CTE2 AS(
SELECT  CONCAT (REPLACE(LTRIM(REPLACE(OBJECTID,'0',' ')),' ','0'),'/',CAST (RIGHT (TABKEY,6 ) AS int)) AS Sals,UDATE
FROM SrcSAP.ZVOTC_CDHDR_POS1 zcp
WHERE zcp.CHNGIND= 'I' ANd TABNAME = 'VBAP')
DELETE FROM DWSAP.DIMSalesDocument
WHERE CONCAT (REPLACE(LTRIM(REPLACE([Sales Document],'0',' ')),' ','0'),'/'
,REPLACE(LTRIM(REPLACE([Sales Document Item],'0',' ')),' ','0'))
IN(SELECT A.Sals FROM CTE A WHERE A.Sals NOT IN(SELECT  Sals from CTE2))


--Checking Deleted Orders and Items in DIMSalesDocument 
--When [Sales Document] has both (CHNGIND= 'D' or CHNGIND= 'I') but D.UDATE>I.UDATE
;with CTE as(
SELECT  CONCAT (REPLACE(LTRIM(REPLACE(OBJECTID,'0',' ')),' ','0'),'/',CAST (RIGHT (TABKEY,6 ) AS int)) AS Sals,UDATE
FROM SrcSAP.ZVOTC_CDHDR_POS1 zcp
WHERE zcp.CHNGIND= 'D' ANd TABNAME ='LIPS'),
CTE2 AS(
SELECT  CONCAT (REPLACE(LTRIM(REPLACE(OBJECTID,'0',' ')),' ','0'),'/',CAST (RIGHT (TABKEY,6 ) AS int)) AS Sals,UDATE
FROM SrcSAP.ZVOTC_CDHDR_POS1 zcp
WHERE zcp.CHNGIND= 'I' ANd TABNAME = 'LIPS')
DELETE FROM DWSAP.DIMSalesDocument 
WHERE CONCAT (REPLACE(LTRIM(REPLACE([Sales Document],'0',' ')),' ','0'),'/'
,REPLACE(LTRIM(REPLACE([Sales Document Item],'0',' ')),' ','0'))
IN(SELECT A.Sals FROM CTE A JOIN CTE2 B ON A.Sals=B.Sals AND A.UDATE>B.UDATE)

----NEW JIRA BI-12223 --- Remove duplicate records from the FDL tables

;WITH CTE AS (
SELECT ROW_NUMBER() 
OVER(Partition By
[PartitionColumn],[Sales Document],[Sales Document Item],[OrderQuantity],[Sales Document Type],[Sales Document Category],[Item Category-Sales Document],[Billing Type],[Age Tier],[Order Stages],[Stage Bucket],[PatientType],[ProductType],[TreatingDoctor],[ShipTo],[SoldTo],[CCADate],[TreatmentCategory],[TreatmentLocation],[ClinID],[Is IO Scan],[Professional Category],[Advantage Tier],[Advantage Program Name],[MAF],[Sales Org],[Division],[Sales Order Key],[Compliance Indicator],[Free_Paid],[PO Number],[Treatment Option],[Deliverable Type],[IDSOrderID],[SFDCOrderID],[Material Group],[Material Number],[Material Group 1],[Material Group 2],[Material Group 3],[Material Group 4],[Material Group 5],[Distribution Channel],[Sales Group],[Sales Office],[Controlling Area],[Purchasing Org],[Base Unit of Measure],[Sales Unit],[Unit of Dimension for length/Width/Height],[Volume Unit],[Weight Unit],[Bill-to party],[Payer],[Country of ship-to party],[Customer Group1],[Customer Group2],[Customer Group3],[Customer Group4],[Customer Group5],[Equipment Serial Num],[Initiator Company Id],[AMR Date COPA],[Promotion Bucket],[Revenue Recognition],[Total Quantity],[Document Date],[Document Year],[UpperAlignerStartstage],[UpperAlignerEndStage],[LowerAlignerStartstage],[LowerAlignerEndStage],[CustomerGroupType],[IsDSOOrder],[Storage Location],[Align Retail],[Employee Responsible],[Financial Contact],[Junior Doctor],[Submitting Student],[Territory Manager],[AgeTierRange],[AgeTierDetail],[AgeSegment],[AgeCategory],[Material Text],[Bill-to party text],[ShipTo Text],[SoldTo Text],[TreatmentId],[Order Quantity]
Order By
[PartitionColumn],[Sales Document],[Sales Document Item],[OrderQuantity],[Sales Document Type],[Sales Document Category],[Item Category-Sales Document],[Billing Type],[Age Tier],[Order Stages],[Stage Bucket],[PatientType],[ProductType],[TreatingDoctor],[ShipTo],[SoldTo],[CCADate],[TreatmentCategory],[TreatmentLocation],[ClinID],[Is IO Scan],[Professional Category],[Advantage Tier],[Advantage Program Name],[MAF],[Sales Org],[Division],[Sales Order Key],[Compliance Indicator],[Free_Paid],[PO Number],[Treatment Option],[Deliverable Type],[IDSOrderID],[SFDCOrderID],[Material Group],[Material Number],[Material Group 1],[Material Group 2],[Material Group 3],[Material Group 4],[Material Group 5],[Distribution Channel],[Sales Group],[Sales Office],[Controlling Area],[Purchasing Org],[Base Unit of Measure],[Sales Unit],[Unit of Dimension for length/Width/Height],[Volume Unit],[Weight Unit],[Bill-to party],[Payer],[Country of ship-to party],[Customer Group1],[Customer Group2],[Customer Group3],[Customer Group4],[Customer Group5],[Equipment Serial Num],[Initiator Company Id],[AMR Date COPA],[Promotion Bucket],[Revenue Recognition],[Total Quantity],[Document Date],[Document Year],[UpperAlignerStartstage],[UpperAlignerEndStage],[LowerAlignerStartstage],[LowerAlignerEndStage],[CustomerGroupType],[IsDSOOrder],[Storage Location],[Align Retail],[Employee Responsible],[Financial Contact],[Junior Doctor],[Submitting Student],[Territory Manager],[AgeTierRange],[AgeTierDetail],[AgeSegment],[AgeCategory],[Material Text],[Bill-to party text],[ShipTo Text],[SoldTo Text],[TreatmentId],[Order Quantity]) AS [ROW],
[PartitionColumn],[Sales Document],[Sales Document Item],[OrderQuantity],[Sales Document Type],[Sales Document Category],[Item Category-Sales Document],[Billing Type],[Age Tier],[Order Stages],[Stage Bucket],[PatientType],[ProductType],[TreatingDoctor],[ShipTo],[SoldTo],[CCADate],[TreatmentCategory],[TreatmentLocation],[ClinID],[Is IO Scan],[Professional Category],[Advantage Tier],[Advantage Program Name],[MAF],[Sales Org],[Division],[Sales Order Key],[Compliance Indicator],[Free_Paid],[PO Number],[Treatment Option],[Deliverable Type],[IDSOrderID],[SFDCOrderID],[Material Group],[Material Number],[Material Group 1],[Material Group 2],[Material Group 3],[Material Group 4],[Material Group 5],[Distribution Channel],[Sales Group],[Sales Office],[Controlling Area],[Purchasing Org],[Base Unit of Measure],[Sales Unit],[Unit of Dimension for length/Width/Height],[Volume Unit],[Weight Unit],[Bill-to party],[Payer],[Country of ship-to party],[Customer Group1],[Customer Group2],[Customer Group3],[Customer Group4],[Customer Group5],[Equipment Serial Num],[Initiator Company Id],[AMR Date COPA],[Promotion Bucket],[Revenue Recognition],[Total Quantity],[Document Date],[Document Year],[UpperAlignerStartstage],[UpperAlignerEndStage],[LowerAlignerStartstage],[LowerAlignerEndStage],[CustomerGroupType],[IsDSOOrder],[Storage Location],[Align Retail],[Employee Responsible],[Financial Contact],[Junior Doctor],[Submitting Student],[Territory Manager],[AgeTierRange],[AgeTierDetail],[AgeSegment],[AgeCategory],[Material Text],[Bill-to party text],[ShipTo Text],[SoldTo Text],[TreatmentId],[Order Quantity]
From DWSAP.DimSalesDocument 
WITH(NOLOCK) WHERE FORMAT(TRY_CONVERT(DATE,[Document Date]),'yyyyMM')= FORMAT(GETDATE(),'yyyyMM'))
DELETE FROM CTE WHERE [ROW]>1
END;
