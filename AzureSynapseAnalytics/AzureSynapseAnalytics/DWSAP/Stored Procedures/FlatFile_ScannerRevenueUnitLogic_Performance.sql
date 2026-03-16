CREATE PROC [DWSAP].[FlatFile_ScannerRevenueUnitLogic_Performance] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS 
BEGIN
--BI-12996 New procedure
DECLARE @lastdatetime AS datetime2,
@RowsInserted int = 0
, @RowsUpdated  int = 0
, @IsFullLoad   bit = 0





IF OBJECT_ID(N'tempdb..#temp_ScannerRevenuek','U') IS NOT NULL
DROP TABLE #temp_ScannerRevenuek
IF OBJECT_ID(N'tempdb..#RawScannerCounts','U') IS NOT NULL
DROP TABLE #RawScannerCounts
IF OBJECT_ID(N'tempdb..#ScannerDeliveryCounts','U') IS NOT NULL
DROP TABLE #ScannerDeliveryCounts
IF OBJECT_ID(N'tempdb..#DifferentSalesOrderCounts','U') IS NOT NULL
DROP TABLE #DifferentSalesOrderCounts 
IF OBJECT_ID(N'tempdb..#T','U') IS NOT NULL
DROP TABLE #T
IF OBJECT_ID(N'tempdb..#A','U') IS NOT NULL
DROP TABLE #A



SELECT ReportingDate,MAX(ADLSTIMESTAMP)ADLSTIMESTAMP INTO #T
FROM [SrcSAPFile].[ScannerRevenueUnit] 
GROUP BY  ReportingDate

SELECT * INTO #A FROM  [DWSAP].[ScannerRevenueUnitProcessed_Performance]

DELETE FROM [DWSAP].[ScannerRevenueUnitProcessed_Performance]

IF (EXISTS (SELECT * 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'DWSAP' 
AND  TABLE_NAME = 'ScannerRevenueUnitProcessed_Performance'))
BEGIN
SET @lastdatetime = (SELECT MAX(ADLSTimestamp) FROM [DWSAP].[ScannerRevenueUnitProcessed_Performance])
END
ELSE
BEGIN
SET @lastdatetime = '1900-01-01 12:00:00'
END



  
SELECT COUNT(*) as [RawScannerCount],[SalesOrder],
REPLACE(LTRIM(REPLACE([SalesLineItem],'0',' ')),' ','0') as SalesLineItem
INTO [#RawScannerCounts]
FROM SrcSAPFile.ScannerRevenueUnit sru  
GROUP BY SalesOrder ,SalesLineItem
  

  
SELECT COUNT(*) as [Count],[SalesOrder],
REPLACE(LTRIM(REPLACE(SalesLineItem,'0',' ')),' ','0') as SalesLineItem
INTO [#ScannerDeliveryCounts]
FROM (
SELECT scr.*  FROM SrcSAPFile.ScannerRevenueUnit scr  
LEFT JOIN [SrcSAP].[LIPS] [lips] ON 
scr.[SalesOrder] = REPLACE(LTRIM(REPLACE([lips].[VGBEL],'0',' ')),' ','0')
AND scr.SalesLineItem = REPLACE(LTRIM(REPLACE(lips.[VGPOS],'0',' ')),' ','0')) a 
GROUP BY SalesOrder ,SalesLineItem


SELECT  rsc.SalesLineItem,REPLACE(LTRIM(REPLACE([rsc].[SalesOrder],'0',' ')),' ','0') as [SalesOrder]
,[RawScannerCount],[Count]
INTO [#DifferentSalesOrderCounts]
FROM [#ScannerDeliveryCounts] sdc
INNER JOIN [#RawScannerCounts] rsc on 
REPLACE(LTRIM(REPLACE([sdc].[SalesOrder],'0',' ')),' ','0') = REPLACE(LTRIM(REPLACE(rsc.SalesOrder,'0',' ')),' ','0')
AND sdc.SalesLineItem = rsc.SalesLineItem
WHERE [RawScannerCount]<>[Count]
  
  
SELECT *, CASE WHEN [CA_PRIMRY] <> 'X' and [CA_SECNDRY] <> 'X' and [CA_OTHERS] <> 'X' 
and [itro_scr] <> 'X' and [itro_serv] <> 'X' then 'X' end [CA_UNKNOWN] 
INTO #temp_ScannerRevenuek
FROM(
SELECT 
scr.[LZBatchID],scr.[ADLSBatchID],scr.[ADLSTimestamp],@BatchID [DWBatchID],@LastSuccessfullDWTimestamp [DWTimeStamp]
,ISNULL(scr.SalesOrder,' ') [SalesOrder], scr.[ReportingDate] EventDate
,COALESCE(scr.[Ship-ToParty],od.[ShipTo]) [Ship-ToParty] 
,COALESCE(scr.[Sold-ToParty],od.[SoldTo]) [Sold-ToParty]
,COALESCE(scr.[SalesOrderType],vbak.[AUART]) [SalesOrderType]
,COALESCE(scr.[VolumeUnit],vbap.[VOLEH]) [VolumeUnit],
case when scr.ProfitCenter IS NULL THEN COALESCE(scr.[ProfitCenter], vbap.[PRCTR])
else COALESCE(CONCAT('000000',scr.[ProfitCenter]), vbap.[PRCTR]) END AS [ProfitCenter]
--,COALESCE(scr.[ProfitCenter],vbap.[PRCTR]) [ProfitCenter]
,COALESCE(scr.[Material],vbap.[MATNR]) [Material]
,COALESCE(scr.[CompanyCode],vbak.[BUKRS_VF]) [CompanyCode]
,COALESCE(scr.[PGIDate],likp.[WADAT_IST]) [PGIDate]
,COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]) [Product Hierarchy]
,COALESCE(scr.SalesDocumentItemCategory,vbap.PSTYV) [Item Category]
-- If field present in FlatFile is not null than take from flatfile else deriving it from OrderAttibutes
,scr.[PromoBucket]
,scr.[DateofMIM]
,'K4' [Fiscal Variant] -- HardCode for FiscalVariant
,'F' [FileYN] --HardCode for File Data
,cast(getdate() as date) [CreatedOnDate] -- Setting CreatedDate as current date
,getdate() [CreatedOn],CURRENT_USER  [User] -- Setting Fields for Created datetime and Current user
,case when LEFT(COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]),4) = 'A1S1' and LEFT(COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]),6) = 'A1S1U1' then 'X' else '3' end as [itro_scr] 
,case when LEFT(COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]),6) = 'A1S1U2' then 'X' else '4' end as [itro_serv] 
,case when LEFT(COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]),6) = 'A1S1U2' then '1' else null end as [Shipment Count] 
-- Deriving Itro_scr , Itro_serv, ShipmentCount based on Conditions applied for ProductHierarchy
,'ITERO-SCANNER' [Segment],'SCANNER REVENUE UNIT' [Volume Segment],'SCANNER REVENUE UNIT' [Volume Sub-Segment]
,'SCANNER_REVENUE_UNIT' [Cost Element(COPA)] -- HardCode fields
,Case when [ReportingRegion] = 'LATAM' then COALESCE(scr.[country],CA.[Country]) else vbak.[VKGRP] end [Sales Group]
--Deriving Sales Group
,Case when [ReportingRegion] = 'LATAM' then 1000 else vbak.[KOKRS] end [Controlling Area]
-- Deriving Controlling Area
,'Volume' [Process Name] -- HardCode ProcessName
,case when COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]) like 'A1A1%' then 'CLEAR ALIGNER'
when COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]) like 'A1S1%' then 'ITERO'
else null end as [Business Segment] 
-- Deriving Business Segment based on Product hierarchy field from FlatFile or VBAK
,COALESCE(scr.ActualDeliveryQuantity,lips.LFIMG) [ActualDeliveryQuantity]
,od.[AgeTierCode] [Age Tier],likp.[VOLUM] [Volume],likp.[NTGEW] [Net Weight],likp.[BTGEW] [Total Weight]
,lips.[VBELN] [Delivery],vbak.[ZZDELI_CATE] [Treatment Category],vbak.[VBTYP] [Document_Category]
,vbap.[ZZDELI_TYPE] [Delivery Type],vbap.[ABGRU] [Reason Rejection],vbap.[KNUMH] [KNUM]
,vbap.[PAOBJNR] [Profitability segment],vbap.[KOSTL] [CostCenter],vbak.[ZZCOMP_IND] [Compliance Indicator]

-- Inserting Columns For Initiator Company ID and Serial Numbers
,COALESCE(scr.SerialNumber,vbak.[ZZSR_NO]) [Serial Number], COALESCE(scr.InitiatorcompanyIDMAT,vbak.[ZZ_IN_COM_ID]) [Initiator Company ID]
,vbak.[ZZAMR_DATE] [AMR Date],vbak.[ZZCCS_DATE] [CCS Date],od.[CCADate],vbak.[ZZEXT_PID] [External Patient ID]
,vbak.[ZZVIP_ORD] [Source System Order],vbak.[ZZSFDC_ORD] [SFDC Order ID],vbap.[ZZFRE_QTY] [FoC Quantity]
,vbap.[ZZTOT_QTY] [Deliverable Quantity],vbap.[VRKME] [Sales Unit],vbap.[ZIEME] [Target Qu]
,vbap.[ZMENG] [Target Qty],vbap.[WAERK] [Document Currency],vbap.[NETPR] [Net Price],vbap.[NETWR] [Net Value]
,vbak.[KVGR1] [Customer Group1],vbak.[KVGR2] [Customer Group2],vbak.[KVGR3] [Customer Group3],vbak.[KVGR4] [Customer Group4]
,vbak.[KVGR5] [Customer Group5]
,REPLACE(LTRIM(REPLACE(vbap.[POSNR],'0',' ')),' ','0') [SalesOrder Item]
,vbak.[VKORG] [Sales Organization]
,vbak.[VTWEG] [Distribution Channel],vbap.[LGORT] [Storage Location],vbak.[SPART] [Division]
,vbak.[ZZEXT_TXID] [External Treatment I],vbap.[ZZTREAT_OPT] [Treatment Option],vbak.[ZZTREATMENT]
,vbak.[ZZ_STAGES] [MaxNoOfStages],od.TreatmentLocation,od.TreatingDoctor,od.OrderStages,od.StagesBucket
,vbap.[MVGR1] [MaterialGroup1],vbap.[MVGR2] [MaterialGroup2],vbap.[MVGR3] [MaterialGroup3],vbap.[MVGR4] [MaterialGroup4]
,vbap.[MVGR5] [MaterialGroup5],vbap.[ZZCLINICAL] [ClinicalStudy],vbap.[ZZTOTAL_QTY] [Total Quantity]
-- Extracting Fields from VBAK, VBAP,LIPS,LIKP,OrderAttributes and CustomerDetails
,case when vbak.[ZZDELI_CATE] = 'Primary' and COALESCE(scr.SalesDocumentItemCategory,vbap.PSTYV)  = 'Z001' then 'X' end [CA_PRIMRY]
,case when vbak.[ZZDELI_CATE] = 'Secondary' and COALESCE(scr.SalesDocumentItemCategory,vbap.PSTYV)  in ('Z002','Z003','Z004','Z005','Z006') then 'X' end [CA_SECNDRY]
,case when LEFT(COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]),4) <> 'A1S1' then 'X' end [CA_NONCAS]
--Deriving CA_Primary,CA_Secondary and CA_Unkown based on conditions
,Case when (case when vbak.[ZZDELI_CATE] = 'Primary' and COALESCE(scr.SalesDocumentItemCategory,vbap.PSTYV)  = 'Z001' then 'X' end  is null) and (case when vbak.[ZZDELI_CATE] = 'Secondary' and COALESCE(scr.SalesDocumentItemCategory,vbap.PSTYV)  in ('Z002','Z003','Z004','Z005','Z006') then 'X' end is null) then 'X' end [CA_OTHERS]
,vbap.[ABGRU] [ReasonRejection],vbap.[KWMENG] [Order Quantity],vbap.[KMPMG] [Withdraw Quantity]
,lips.[LFIMG] [Delivery Quantity],lips.[POSNR] [DeliveryItem],likp.[WADAT_IST] [ActualsGoodIssueDate]
,COALESCE(scr.[ReportingChannel],case when vbak.[VTWEG] = '20' then 21
when vbak.[VTWEG] = '10' and vbak.[KVGR1] = '01' then 11
when vbak.[VTWEG] = '10' and vbak.[KVGR1] = '02' then 12
when vbak.[VTWEG] = '10' and vbak.[KVGR1] = '03' then 13
when COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]) like 'A1S1%' and vbap.[MVGR5] = 'Z3' then 11
when COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]) like 'A1S1%' and vbap.[MVGR5] = 'Z2' then 12
when COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]) like 'A1S1%' then 12
when COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]) = 'A1A1T1C10301' then 11
else 12 end ) [Reporting Channel]
-- Deriving Reporting Channel based on Conditions
,COALESCE(scr.[ReportingDate],vbap.[AUDAT]) as [Document Date],CC.CertificationDate,year(CC.CertificationDate) CertificationYear
,CC.AdvantageTier,CC.ProfessionalCategory,CA.[Country],CA.[CountryGroup],CA.[RegionPC]
,CA.[RegionGroup],CA.[GlobalRegion],[ReportingRegion] [Reporting Region],COALESCE(scr.[Plant],vbap.[WERKS]) [Plant]
,VBAP.[MEINS] [Base Unit of Measure],VBAP.[GEWEI] [Weight Unit]
,VBAP.[ZZTREV_DATE] [Revenue Recognition]
,CASE 
WHEN VBAK.[ZZDELI_CATE] = 'Primary' 
THEN 'Paid'
WHEN VBAK.[ZZDELI_CATE] = 'Secondary' AND VBAP.ZZDELI_TYPE IN 
(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY'))
and VBAP.[ZZFRE_QTY] = 0 THEN 'Paid'
WHEN VBAK.[ZZDELI_CATE] = 'Secondary' AND VBAP.ZZDELI_TYPE IN 
(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY'))  
and VBAP.[ZZFRE_QTY] = VBAP.[ZZTOT_QTY] 
THEN 'Free'
WHEN VBAK.[ZZDELI_CATE] = 'Secondary' AND VBAP.ZZDELI_TYPE IN 
(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY'))  
and (VBAP.[ZZTOT_QTY] - VBAP.[ZZFRE_QTY]) > 0   
THEN 'Paid'
WHEN VBAK.[ZZDELI_CATE] = 'Secondary' AND VBAP.ZZDELI_TYPE IN 
(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY'))  
and (VBAP.[ZZTOT_QTY] - VBAP.[ZZFRE_QTY]) < 0   
THEN 'Error'
WHEN VBAK.[ZZDELI_CATE] = 'Secondary'  AND VBAP.ZZDELI_TYPE NOT IN 
(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY')) AND 
VBAP.[PRODH] LIKE 'A1A1%' AND VBAP.[NETPR] = '0.00' 
THEN 'Free'
WHEN VBAK.[ZZDELI_CATE] = 'Secondary'  AND VBAP.ZZDELI_TYPE NOT IN 
(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY')) AND 
VBAP.[PRODH] LIKE 'A1A1%' AND VBAP.[NETPR] <> '0.00' 
THEN 'Paid'
WHEN VBAK.[ZZDELI_CATE] ='' AND VBAP.[PRODH] LIKE 'A1S1U1%' 
THEN 'Paid'
WHEN VBAK.[ZZDELI_CATE] ='' AND VBAP.[PRODH] LIKE 'A1S1U2%' AND VBAP.[NETPR] = '0.00' 
THEN 'Free'
WHEN VBAK.[ZZDELI_CATE] ='' AND VBAP.[PRODH] LIKE 'A1S1U2%' AND VBAP.[NETPR] <> '0.00' 
THEN 'Paid' 
end [Free_Paid]

FROM [SrcSAPFile].[ScannerRevenueUnit] scr
LEFT JOIN [SrcSAP].[VBAK] vbak
ON scr.SalesOrder = REPLACE(LTRIM(REPLACE(vbak.[VBELN],'0',' ')),' ','0')
LEFT JOIN [SrcSAP].[VBAP] vbap 
ON scr.SalesOrder = REPLACE(LTRIM(REPLACE(vbap.[VBELN],'0',' ')),' ','0') 
and REPLACE(LTRIM(REPLACE(scr.[SalesLineItem],'0',' ')),' ','0') = REPLACE(LTRIM(REPLACE(vbap.[POSNR],'0',' ')),' ','0')
LEFT JOIN [SrcSAP].[LIPS] [lips] ON 
REPLACE(LTRIM(REPLACE(scr.[SalesOrder],'0',' ')),' ','0') = REPLACE(LTRIM(REPLACE(lips.[VGBEL],'0',' ')),' ','0')
AND REPLACE(LTRIM(REPLACE(scr.[SalesLineItem],'0',' ')),' ','0') = REPLACE(LTRIM(REPLACE(lips.[VGPOS],'0',' ')),' ','0')
LEFT JOIN [SrcSAP].[LIKP] [likp] ON lips.[VBELN] = likp.[VBELN]
LEFT JOIN [TABSAP].[DimOrderAttributes] od 
ON scr.[SalesOrder] = REPLACE(LTRIM(REPLACE(od.OrderNumber,'0',' ')),' ','0')
LEFT JOIN [TABSAP].[DimCustContact] CC ON CC.[ClinId] = od.[ClinID]
LEFT JOIN [TABSAP].[DimCusAccount] CA ON CA.[AccountNumber] = od.[TreatmentLocation]
WHERE scr.ADLSTimeStamp > Coalesce(@lastdatetime,'1900-01-01 12:00:00')
--AND scr.SalesOrder NOT IN (SELECT SalesOrder FROM [#DifferentSalesOrderCounts] )
--and scr.[SalesOrder] <> 'NULL' or (month(scr.ReportingDate) = 10 or month(scr.ReportingDate) = 11 or month(scr.ReportingDate) = 12 )
) a WHERE a.SalesOrder NOT IN (SELECT SalesOrder FROM [#DifferentSalesOrderCounts] )
and Concat(EventDate,':',ADLSTIMESTAMP)
  IN (SELECT Concat(ReportingDate,':',ADLSTIMESTAMP) FROM #T)


INSERT INTO #temp_ScannerRevenuek 

SELECT *, CASE WHEN [CA_PRIMRY] <> 'X' and [CA_SECNDRY] <> 'X' and [CA_OTHERS] <> 'X' 
and [itro_scr] <> 'X' and [itro_serv] <> 'X' then 'X' end [CA_UNKNOWN] 
--INTO #temp_ScannerRevenuek
FROM(
SELECT 
scr.[LZBatchID],scr.[ADLSBatchID],scr.[ADLSTimestamp],@BatchID [DWBatchID],@LastSuccessfullDWTimestamp [DWTimeStamp]
,ISNULL(scr.SalesOrder,' ') [SalesOrder] ,scr.[ReportingDate] EventDate
,COALESCE(scr.[Ship-ToParty],od.[ShipTo]) [Ship-ToParty] 
,COALESCE(scr.[Sold-ToParty],od.[SoldTo]) [Sold-ToParty]
,COALESCE(scr.[SalesOrderType],vbak.[AUART]) [SalesOrderType]
,COALESCE(scr.[VolumeUnit],vbap.[VOLEH]) [VolumeUnit],
case when scr.ProfitCenter IS NULL THEN COALESCE(scr.[ProfitCenter], vbap.[PRCTR])
else COALESCE(CONCAT('000000',scr.[ProfitCenter]), vbap.[PRCTR]) END AS [ProfitCenter]
--,COALESCE(scr.[ProfitCenter],vbap.[PRCTR]) [ProfitCenter]
,COALESCE(scr.[Material],vbap.[MATNR]) [Material]
,COALESCE(scr.[CompanyCode],vbak.[BUKRS_VF]) [CompanyCode]
,scr.[PGIDate] as  [PGIDate]
,COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]) [Product Hierarchy]
,COALESCE(scr.SalesDocumentItemCategory,vbap.PSTYV) [Item Category]
-- If field present in FlatFile is not null than take from flatfile else deriving it from OrderAttibutes
,scr.[PromoBucket]
,scr.[DateofMIM]
,'K4' [Fiscal Variant] -- HardCode for FiscalVariant
,'F' [FileYN] --HardCode for File Data
,cast(getdate() as date) [CreatedOnDate] -- Setting CreatedDate as current date
,getdate() [CreatedOn],CURRENT_USER  [User] -- Setting Fields for Created datetime and Current user
,case when LEFT(COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]),4) = 'A1S1' and LEFT(COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]),6) = 'A1S1U1' then 'X' else '3' end as [itro_scr] 
,case when LEFT(COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]),6) = 'A1S1U2' then 'X' else '4' end as [itro_serv] 
,case when LEFT(COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]),6) = 'A1S1U2' then '1' else null end as [Shipment Count] 
-- Deriving Itro_scr , Itro_serv, ShipmentCount based on Conditions applied for ProductHierarchy
,'ITERO-SCANNER' [Segment],'SCANNER REVENUE UNIT' [Volume Segment],'SCANNER REVENUE UNIT' [Volume Sub-Segment]
,'SCANNER_REVENUE_UNIT' [Cost Element(COPA)] -- HardCode fields
,Case when [ReportingRegion] = 'LATAM' then COALESCE(scr.[country],CA.[Country]) else vbak.[VKGRP] end [Sales Group]
--Deriving Sales Group
,Case when [ReportingRegion] = 'LATAM' then 1000 else vbak.[KOKRS] end [Controlling Area]
-- Deriving Controlling Area
,'Volume' [Process Name] -- HardCode ProcessName
,case when COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]) like 'A1A1%' then 'CLEAR ALIGNER'
when COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]) like 'A1S1%' then 'ITERO'
else null end as [Business Segment] 
-- Deriving Business Segment based on Product hierarchy field from FlatFile or VBAK
,scr.ActualDeliveryQuantity as  [ActualDeliveryQuantity]
,od.[AgeTierCode] [Age Tier], 0 [Volume], 0 [Net Weight],0 [Total Weight]
,'' [Delivery],vbak.[ZZDELI_CATE] [Treatment Category],vbak.[VBTYP] [Document_Category]
,vbap.[ZZDELI_TYPE] [Delivery Type],vbap.[ABGRU] [Reason Rejection],vbap.[KNUMH] [KNUM]
,vbap.[PAOBJNR] [Profitability segment],vbap.[KOSTL] [CostCenter],vbak.[ZZCOMP_IND] [Compliance Indicator]

-- Inserting Columns For Initiator Company ID and Serial Numbers
,COALESCE(scr.SerialNumber,vbak.[ZZSR_NO]) [Serial Number], COALESCE(scr.InitiatorcompanyIDMAT,vbak.[ZZ_IN_COM_ID]) [Initiator Company ID]
,vbak.[ZZAMR_DATE] [AMR Date],vbak.[ZZCCS_DATE] [CCS Date],od.[CCADate],vbak.[ZZEXT_PID] [External Patient ID]
,vbak.[ZZVIP_ORD] [Source System Order],vbak.[ZZSFDC_ORD] [SFDC Order ID],vbap.[ZZFRE_QTY] [FoC Quantity]
,vbap.[ZZTOT_QTY] [Deliverable Quantity],vbap.[VRKME] [Sales Unit],vbap.[ZIEME] [Target Qu]
,vbap.[ZMENG] [Target Qty],vbap.[WAERK] [Document Currency],vbap.[NETPR] [Net Price],vbap.[NETWR] [Net Value]
,vbak.[KVGR1] [Customer Group1],vbak.[KVGR2] [Customer Group2],vbak.[KVGR3] [Customer Group3],vbak.[KVGR4] [Customer Group4]
,vbak.[KVGR5] [Customer Group5]
,REPLACE(LTRIM(REPLACE(vbap.[POSNR],'0',' ')),' ','0') [SalesOrder Item]
,vbak.[VKORG] [Sales Organization]
,vbak.[VTWEG] [Distribution Channel],vbap.[LGORT] [Storage Location],vbak.[SPART] [Division]
,vbak.[ZZEXT_TXID] [External Treatment I],vbap.[ZZTREAT_OPT] [Treatment Option],vbak.[ZZTREATMENT]
,vbak.[ZZ_STAGES] [MaxNoOfStages],od.TreatmentLocation,od.TreatingDoctor,od.OrderStages,od.StagesBucket
,vbap.[MVGR1] [MaterialGroup1],vbap.[MVGR2] [MaterialGroup2],vbap.[MVGR3] [MaterialGroup3],vbap.[MVGR4] [MaterialGroup4]
,vbap.[MVGR5] [MaterialGroup5],vbap.[ZZCLINICAL] [ClinicalStudy],vbap.[ZZTOTAL_QTY] [Total Quantity]
-- Extracting Fields from VBAK, VBAP,LIPS,LIKP,OrderAttributes and CustomerDetails
,case when vbak.[ZZDELI_CATE] = 'Primary' and COALESCE(scr.SalesDocumentItemCategory,vbap.PSTYV)  = 'Z001' then 'X' end [CA_PRIMRY]
,case when vbak.[ZZDELI_CATE] = 'Secondary' and COALESCE(scr.SalesDocumentItemCategory,vbap.PSTYV)  in ('Z002','Z003','Z004','Z005','Z006') then 'X' end [CA_SECNDRY]
,case when LEFT(COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]),4) <> 'A1S1' then 'X' end [CA_NONCAS]
--Deriving CA_Primary,CA_Secondary and CA_Unkown based on conditions
,Case when (case when vbak.[ZZDELI_CATE] = 'Primary' and COALESCE(scr.SalesDocumentItemCategory,vbap.PSTYV)  = 'Z001' then 'X' end  is null) and (case when vbak.[ZZDELI_CATE] = 'Secondary' and COALESCE(scr.SalesDocumentItemCategory,vbap.PSTYV)  in ('Z002','Z003','Z004','Z005','Z006') then 'X' end is null) then 'X' end [CA_OTHERS]
,vbap.[ABGRU] [ReasonRejection],vbap.[KWMENG] [Order Quantity],vbap.[KMPMG] [Withdraw Quantity]
,0 [Delivery Quantity],'' [DeliveryItem], '' [ActualsGoodIssueDate]
,COALESCE(scr.[ReportingChannel],case when vbak.[VTWEG] = '20' then 21
when vbak.[VTWEG] = '10' and vbak.[KVGR1] = '01' then 11
when vbak.[VTWEG] = '10' and vbak.[KVGR1] = '02' then 12
when vbak.[VTWEG] = '10' and vbak.[KVGR1] = '03' then 13
when COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]) like 'A1S1%' and vbap.[MVGR5] = 'Z3' then 11
when COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]) like 'A1S1%' and vbap.[MVGR5] = 'Z2' then 12
when COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]) like 'A1S1%' then 12
when COALESCE(scr.[ProductHierarchyNode],vbap.[PRODH]) = 'A1A1T1C10301' then 11
else 12 end ) [Reporting Channel]
-- Deriving Reporting Channel based on Conditions
,COALESCE(scr.[ReportingDate],vbap.[AUDAT]) as [Document Date],CC.CertificationDate,year(CC.CertificationDate) CertificationYear
,CC.AdvantageTier,CC.ProfessionalCategory,CA.[Country],CA.[CountryGroup],CA.[RegionPC]
,CA.[RegionGroup],CA.[GlobalRegion],[ReportingRegion] [Reporting Region],COALESCE(scr.[Plant],vbap.[WERKS]) [Plant]
,VBAP.[MEINS] [BASe Unit of MeASure],VBAP.[GEWEI] [Weight Unit]
,VBAP.[ZZTREV_DATE] [Revenue Recognition]
,CASE 
WHEN VBAK.[ZZDELI_CATE] = 'Primary' 
THEN 'Paid'
WHEN VBAK.[ZZDELI_CATE] = 'Secondary' AND VBAP.ZZDELI_TYPE IN 
(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY'))
and VBAP.[ZZFRE_QTY] = 0 THEN 'Paid'
WHEN VBAK.[ZZDELI_CATE] = 'Secondary' AND VBAP.ZZDELI_TYPE IN 
(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY'))  
and VBAP.[ZZFRE_QTY] = VBAP.[ZZTOT_QTY] 
THEN 'Free'
WHEN VBAK.[ZZDELI_CATE] = 'Secondary' AND VBAP.ZZDELI_TYPE IN 
(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY'))  
and (VBAP.[ZZTOT_QTY] - VBAP.[ZZFRE_QTY]) > 0   
THEN 'Paid'
WHEN VBAK.[ZZDELI_CATE] = 'Secondary' AND VBAP.ZZDELI_TYPE IN 
(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY'))  
and (VBAP.[ZZTOT_QTY] - VBAP.[ZZFRE_QTY]) < 0   
THEN 'Error'
WHEN VBAK.[ZZDELI_CATE] = 'Secondary'  AND VBAP.ZZDELI_TYPE NOT IN 
(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY')) AND 
VBAP.[PRODH] LIKE 'A1A1%' AND VBAP.[NETPR] = '0.00' 
THEN 'Free'
WHEN VBAK.[ZZDELI_CATE] = 'Secondary'  AND VBAP.ZZDELI_TYPE NOT IN 
(SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY')) AND 
VBAP.[PRODH] LIKE 'A1A1%' AND VBAP.[NETPR] <> '0.00' 
THEN 'Paid'
WHEN VBAK.[ZZDELI_CATE] ='' AND VBAP.[PRODH] LIKE 'A1S1U1%' 
THEN 'Paid'
WHEN VBAK.[ZZDELI_CATE] ='' AND VBAP.[PRODH] LIKE 'A1S1U2%' AND VBAP.[NETPR] = '0.00' 
THEN 'Free'
WHEN VBAK.[ZZDELI_CATE] ='' AND VBAP.[PRODH] LIKE 'A1S1U2%' AND VBAP.[NETPR] <> '0.00' 
THEN 'Paid' 
end [Free_Paid]
FROM [SrcSAPFile].[ScannerRevenueUnit] scr
LEFT JOIN [SrcSAP].[VBAK] vbak ON 
scr.SalesOrder = REPLACE(LTRIM(REPLACE(vbak.[VBELN],'0',' ')),' ','0')
LEFT JOIN [SrcSAP].[VBAP] vbap 
ON scr.SalesOrder = REPLACE(LTRIM(REPLACE(vbap.[VBELN],'0',' ')),' ','0') 
and REPLACE(LTRIM(REPLACE(scr.[SalesLineItem],'0',' ')),' ','0') = REPLACE(LTRIM(REPLACE(vbap.[POSNR],'0',' ')),' ','0')
LEFT JOIN [SrcSAP].[LIPS] [lips] ON 
scr.[SalesOrder] = REPLACE(LTRIM(REPLACE(lips.[VGBEL],'0',' ')),' ','0')
AND REPLACE(LTRIM(REPLACE(scr.[SalesLineItem],'0',' ')),' ','0') = REPLACE(LTRIM(REPLACE(lips.[VGPOS],'0',' ')),' ','0')
LEFT JOIN [SrcSAP].[LIKP] [likp] ON lips.[VBELN] = likp.[VBELN]
LEFT JOIN [TABSAP].[DimOrderAttributes] od 
ON scr.[SalesOrder] = REPLACE(LTRIM(REPLACE(od.OrderNumber,'0',' ')),' ','0')
LEFT JOIN [TABSAP].[DimCustContact] CC ON CC.[ClinId] = od.[ClinID]
LEFT JOIN [TABSAP].[DimCusAccount] CA ON CA.[AccountNumber] = od.[TreatmentLocation]
WHERE scr.ADLSTimeStamp > Coalesce(@lastdatetime,'1900-01-01 12:00:00')
--AND scr.SalesOrder NOT IN (SELECT SalesOrder FROM [#DifferentSalesOrderCounts] )
--and scr.[SalesOrder] <> 'NULL' or (month(scr.ReportingDate) = 10 or month(scr.ReportingDate) = 11 or month(scr.ReportingDate) = 12 )
) a WHERE a.SalesOrder IN (SELECT SalesOrder FROM [#DifferentSalesOrderCounts] ) and
Concat(EventDate,':',ADLSTIMESTAMP)  IN (SELECT Concat(ReportingDate,':',ADLSTIMESTAMP) FROM #T)

-- JIRA NUMBER - BI-11264 



IF (EXISTS (SELECT * 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'DWSAP' 
AND  TABLE_NAME = 'ScannerRevenueUnitProcessed_Performance'))
BEGIN

INSERT INTO [DWSAP].[ScannerRevenueUnitProcessed_Performance]
([LZBatchID],[ADLSBatchID],[ADLSTimestamp],[DWBatchID],[DWTimeStamp],[SalesOrder],[EventDate],[Ship-ToParty],[Sold-ToParty],[SalesOrderType],[VolumeUnit]
,[ProfitCenter],[Material],[CompanyCode],[PGIDate],[Product Hierarchy],[Item Category],[PromoBucket],[DateofMIM],[Fiscal Variant],[FileYN],[CreatedOnDate]
,[CreatedOn],[User],[itro_scr],[itro_serv],[Shipment Count],[Segment],[Volume Segment],[Volume Sub-Segment],[Cost Element(COPA)],[Sales Group],[Controlling Area]
,[Process Name],[Business Segment],[ActualDeliveryQuantity],[Age Tier],[Volume],[Net Weight],[Total Weight],[Delivery],[Treatment Category],[Document_Category]
,[Delivery Type],[Reason Rejection],[KNUM],[Profitability segment],[CostCenter],[Compliance Indicator],[Serial Number],[Initiator Company ID],[AMR Date],[CCS Date]
,[CCADate],[External Patient ID],[Source System Order],[SFDC Order ID],[FoC Quantity],[Deliverable Quantity],[Sales Unit],[Target Qu],[Target Qty],[Document Currency]
,[Net Price],[Net Value],[Customer Group1],[Customer Group2],[Customer Group3],[Customer Group4],[Customer Group5],[SalesOrder Item],[Sales Organization]
,[Distribution Channel],[Storage Location],[Division],[External Treatment I],[Treatment Option],[ZZTREATMENT],[MaxNoOfStages],[TreatmentLocation],[TreatingDoctor]
,[OrderStages],[StagesBucket],[MaterialGroup1],[MaterialGroup2],[MaterialGroup3],[MaterialGroup4],[MaterialGroup5],[ClinicalStudy],[Total Quantity],[CA_PRIMRY]
,[CA_SECNDRY],[CA_NONCAS],[CA_OTHERS],[ReasonRejection],[Order Quantity],[Withdraw Quantity],[Delivery Quantity],[DeliveryItem],[ActualsGoodIssueDate]
,[Reporting Channel],[Document Date],[CertificationDate],[CertificationYear],[AdvantageTier],[ProfessionalCategory],[Country],[CountryGroup],[RegionPC]
,[RegionGroup],[GlobalRegion],[Reporting Region],[Plant],[Base Unit of Measure],[Weight Unit],[Revenue Recognition],[CA_UNKNOWN],[Free_Paid])  
SELECT 
[LZBatchID]
,[ADLSBatchID]
,[ADLSTimestamp]
,[DWBatchID]
,[DWTimeStamp]
,[SalesOrder]
,[EventDate]
,[Ship-ToParty]
,[Sold-ToParty]
,[SalesOrderType]
,[VolumeUnit]
,[ProfitCenter]
,[Material]
,[CompanyCode]
,[PGIDate]
,[Product Hierarchy]
,[Item Category]
,[PromoBucket]
,[DateofMIM]
,[Fiscal Variant]
,[FileYN]
,[CreatedOnDate]
,[CreatedOn]
,[User]
,[itro_scr]
,[itro_serv]
,[Shipment Count]
,[Segment]
,[Volume Segment]
,[Volume Sub-Segment]
,[Cost Element(COPA)]
,[Sales Group]
,[Controlling Area]
,[Process Name]
,[Business Segment]
,[ActualDeliveryQuantity]
,[Age Tier]
,[Volume]
,[Net Weight]
,[Total Weight]
,[Delivery]
,[Treatment Category]
,[Document_Category]
,[Delivery Type]
,[Reason Rejection]
,[KNUM]
,[Profitability segment]
,[CostCenter]
,[Compliance Indicator]
,[Serial Number]
,[Initiator Company ID]
,[AMR Date]
,[CCS Date]
,[CCADate]
,[External Patient ID]
,[Source System Order]
,[SFDC Order ID]
,[FoC Quantity]
,[Deliverable Quantity]
,[Sales Unit]
,[Target Qu]
,[Target Qty]
,[Document Currency]
,[Net Price]
,[Net Value]
,[Customer Group1]
,[Customer Group2]
,[Customer Group3]
,[Customer Group4]
,[Customer Group5]
,[SalesOrder Item]
,[Sales Organization]
,[Distribution Channel]
,[Storage Location]
,[Division]
,[External Treatment I]
,[Treatment Option]
,[ZZTREATMENT]
,[MaxNoOfStages]
,[TreatmentLocation]
,[TreatingDoctor]
,[OrderStages]
,[StagesBucket]
,[MaterialGroup1]
,[MaterialGroup2]
,[MaterialGroup3]
,[MaterialGroup4]
,[MaterialGroup5]
,[ClinicalStudy]
,[Total Quantity]
,[CA_PRIMRY]
,[CA_SECNDRY]
,[CA_NONCAS]
,[CA_OTHERS]
,[ReasonRejection]
,[Order Quantity]
,[Withdraw Quantity]
,[Delivery Quantity]
,[DeliveryItem]
,[ActualsGoodIssueDate]
,[Reporting Channel]
,[Document Date]
,[CertificationDate]
,[CertificationYear]
,[AdvantageTier]
,[ProfessionalCategory]
,[Country]
,[CountryGroup]
,[RegionPC]
,[RegionGroup]
,[GlobalRegion]
,[Reporting Region]
,[Plant]
,[Base Unit of Measure]
,[Weight Unit]
,[Revenue Recognition]
,[CA_UNKNOWN]
,[Free_Paid]
 FROM #temp_ScannerRevenuek

END 

ELSE

BEGIN
SELECT * INTO [DWSAP].[ScannerRevenueUnitProcessed_Performance] 
FROM #temp_ScannerRevenuek
END

DROP TABLE #temp_ScannerRevenuek
DROP TABLE [#RawScannerCounts]
DROP TABLE [#ScannerDeliveryCounts]
DROP TABLE [#DifferentSalesOrderCounts]
-- exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Delete', @rc = @RowsUpdated out
-- exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Insert', @rc = @RowsInserted out
select @RowsInserted - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated


;WITH CTE AS (
SELECT ROW_NUMBER() 
OVER(Partition By
[SalesOrder],[EventDate],[Ship-ToParty],[Sold-ToParty],[SalesOrderType],[VolumeUnit],[ProfitCenter],[Material],[CompanyCode],[PGIDate],[Product Hierarchy],[Item Category],[PromoBucket],[DateofMIM],[Fiscal Variant],[FileYN],[itro_scr],[itro_serv],[Shipment Count],[Segment],[Volume Segment],[Volume Sub-Segment],[Cost Element(COPA)],[Sales Group],[Controlling Area],[Process Name],[Business Segment],[ActualDeliveryQuantity],[Age Tier],[Volume],[Net Weight],[Total Weight],[Delivery],[Treatment Category],[Document_Category],[Delivery Type],[Reason Rejection],[KNUM],[Profitability segment],[CostCenter],[Compliance Indicator],[Serial Number],[Initiator Company ID],[AMR Date],[CCS Date],[CCADate],[External Patient ID],[Source System Order],[SFDC Order ID],[FoC Quantity],[Deliverable Quantity],[Sales Unit],[Target Qu],[Target Qty],[Document Currency],[Net Price],[Net Value],[Customer Group1],[Customer Group2],[Customer Group3],[Customer Group4],[Customer Group5],[SalesOrder Item],[Sales Organization],[Distribution Channel],[Storage Location],[Division],[External Treatment I],[Treatment Option],[ZZTREATMENT],[MaxNoOfStages],[TreatmentLocation],[TreatingDoctor],[OrderStages],[StagesBucket],[MaterialGroup1],[MaterialGroup2],[MaterialGroup3],[MaterialGroup4],[MaterialGroup5],[ClinicalStudy],[Total Quantity],[CA_PRIMRY],[CA_SECNDRY],[CA_NONCAS],[CA_OTHERS],[ReasonRejection],[Order Quantity],[Withdraw Quantity],[Delivery Quantity],[DeliveryItem],[ActualsGoodIssueDate],[Reporting Channel],[Document Date],[CertificationDate],[CertificationYear],[AdvantageTier],[ProfessionalCategory],[Country],[CountryGroup],[RegionPC],[RegionGroup],[GlobalRegion],[Reporting Region],[Plant],[BASe Unit of Measure],[Weight Unit],[Revenue Recognition],[CA_UNKNOWN],[Free_Paid]
Order By
[SalesOrder],[EventDate],[Ship-ToParty],[Sold-ToParty],[SalesOrderType],[VolumeUnit],[ProfitCenter],[Material],[CompanyCode],[PGIDate],[Product Hierarchy],[Item Category],[PromoBucket],[DateofMIM],[Fiscal Variant],[FileYN],[itro_scr],[itro_serv],[Shipment Count],[Segment],[Volume Segment],[Volume Sub-Segment],[Cost Element(COPA)],[Sales Group],[Controlling Area],[Process Name],[Business Segment],[ActualDeliveryQuantity],[Age Tier],[Volume],[Net Weight],[Total Weight],[Delivery],[Treatment Category],[Document_Category],[Delivery Type],[Reason Rejection],[KNUM],[Profitability segment],[CostCenter],[Compliance Indicator],[Serial Number],[Initiator Company ID],[AMR Date],[CCS Date],[CCADate],[External Patient ID],[Source System Order],[SFDC Order ID],[FoC Quantity],[Deliverable Quantity],[Sales Unit],[Target Qu],[Target Qty],[Document Currency],[Net Price],[Net Value],[Customer Group1],[Customer Group2],[Customer Group3],[Customer Group4],[Customer Group5],[SalesOrder Item],[Sales Organization],[Distribution Channel],[Storage Location],[Division],[External Treatment I],[Treatment Option],[ZZTREATMENT],[MaxNoOfStages],[TreatmentLocation],[TreatingDoctor],[OrderStages],[StagesBucket],[MaterialGroup1],[MaterialGroup2],[MaterialGroup3],[MaterialGroup4],[MaterialGroup5],[ClinicalStudy],[Total Quantity],[CA_PRIMRY],[CA_SECNDRY],[CA_NONCAS],[CA_OTHERS],[ReasonRejection],[Order Quantity],[Withdraw Quantity],[Delivery Quantity],[DeliveryItem],[ActualsGoodIssueDate],[Reporting Channel],[Document Date],[CertificationDate],[CertificationYear],[AdvantageTier],[ProfessionalCategory],[Country],[CountryGroup],[RegionPC],[RegionGroup],[GlobalRegion],[Reporting Region],[Plant],[BASe Unit of Measure],[Weight Unit],[Revenue Recognition],[CA_UNKNOWN],[Free_Paid]) AS [ROW],
[SalesOrder],[EventDate],[Ship-ToParty],[Sold-ToParty],[SalesOrderType],[VolumeUnit],[ProfitCenter],[Material],[CompanyCode],[PGIDate],[Product Hierarchy],[Item Category],[PromoBucket],[DateofMIM],[Fiscal Variant],[FileYN],[itro_scr],[itro_serv],[Shipment Count],[Segment],[Volume Segment],[Volume Sub-Segment],[Cost Element(COPA)],[Sales Group],[Controlling Area],[Process Name],[Business Segment],[ActualDeliveryQuantity],[Age Tier],[Volume],[Net Weight],[Total Weight],[Delivery],[Treatment Category],[Document_Category],[Delivery Type],[Reason Rejection],[KNUM],[Profitability segment],[CostCenter],[Compliance Indicator],[Serial Number],[Initiator Company ID],[AMR Date],[CCS Date],[CCADate],[External Patient ID],[Source System Order],[SFDC Order ID],[FoC Quantity],[Deliverable Quantity],[Sales Unit],[Target Qu],[Target Qty],[Document Currency],[Net Price],[Net Value],[Customer Group1],[Customer Group2],[Customer Group3],[Customer Group4],[Customer Group5],[SalesOrder Item],[Sales Organization],[Distribution Channel],[Storage Location],[Division],[External Treatment I],[Treatment Option],[ZZTREATMENT],[MaxNoOfStages],[TreatmentLocation],[TreatingDoctor],[OrderStages],[StagesBucket],[MaterialGroup1],[MaterialGroup2],[MaterialGroup3],[MaterialGroup4],[MaterialGroup5],[ClinicalStudy],[Total Quantity],[CA_PRIMRY],[CA_SECNDRY],[CA_NONCAS],[CA_OTHERS],[ReasonRejection],[Order Quantity],[Withdraw Quantity],[Delivery Quantity],[DeliveryItem],[ActualsGoodIssueDate],[Reporting Channel],[Document Date],[CertificationDate],[CertificationYear],[AdvantageTier],[ProfessionalCategory],[Country],[CountryGroup],[RegionPC],[RegionGroup],[GlobalRegion],[Reporting Region],[Plant],[BASe Unit of Measure],[Weight Unit],[Revenue Recognition],[CA_UNKNOWN],[Free_Paid]
From  DWSAP.[ScannerRevenueUnitProcessed_Performance] 
WITH(NOLOCK) )
DELETE FROM CTE WHERE [ROW]>1

Update  DWSAP.[ScannerRevenueUnitProcessed_Performance] set 
[Process Name]=y.[Process Name]
,[Age Tier]=y.[Age Tier]
,[Compliance Indicator]=y.[Compliance Indicator]
,[AMR Date]=y.[AMR Date]
,[CCS Date]=y.[CCS Date]
,[CCADate]=y.[CCADate]
,[External Patient ID]=y.[External Patient ID]
,[Source System Order]=y.[Source System Order]
,[Customer Group1]=y.[Customer Group1]
,[Customer Group2]=y.[Customer Group2]
,[Customer Group3]=y.[Customer Group3]
,[Customer Group4]=y.[Customer Group4]
,[Customer Group5]=y.[Customer Group5]
,[Storage Location]=y.[Storage Location]
,[External Treatment I]=y.[External Treatment I]
,[TreatmentLocation]=y.[TreatmentLocation]
,[OrderStages]=y.[OrderStages]
,[StagesBucket]=y.[StagesBucket]
,[Document Date]=y.[Document Date]
,[AdvantageTier]=y.[AdvantageTier]
,[ProfessionalCategory]=y.[ProfessionalCategory]
,[Free_Paid]=y.[Free_Paid]
FROM #A Y
WHERE DWSAP.[ScannerRevenueUnitProcessed_Performance].[Reporting Region]=Y.[Reporting Region]
AND DWSAP.[ScannerRevenueUnitProcessed_Performance].EventDate=Y.EventDate
AND DWSAP.[ScannerRevenueUnitProcessed_Performance].SalesOrder=Y.SalesOrder
AND DWSAP.[ScannerRevenueUnitProcessed_Performance].[SalesOrder Item]=Y.[SalesOrder Item]
AND DWSAP.[ScannerRevenueUnitProcessed_Performance].[Serial Number]=Y.[Serial Number]
AND DWSAP.[ScannerRevenueUnitProcessed_Performance].[Initiator Company ID]=Y.[Initiator Company ID]
DROP TABLE #A


;WITH CTE AS (
SELECT ROW_NUMBER() 
OVER(Partition By
[SalesOrder],[EventDate],[Ship-ToParty],[Sold-ToParty],[SalesOrderType],[VolumeUnit],[ProfitCenter],[Material],[CompanyCode],[PGIDate],[Product Hierarchy],[Item Category],[PromoBucket],[DateofMIM],[Fiscal Variant],[FileYN],[itro_scr],[itro_serv],[Shipment Count],[Segment],[Volume Segment],[Volume Sub-Segment],[Cost Element(COPA)],[Sales Group],[Controlling Area],[Process Name],[Business Segment],[ActualDeliveryQuantity],[Age Tier],[Volume],[Net Weight],[Total Weight],[Delivery],[Treatment Category],[Document_Category],[Delivery Type],[Reason Rejection],[KNUM],[Profitability segment],[CostCenter],[Compliance Indicator],[Serial Number],[Initiator Company ID],[AMR Date],[CCS Date],[CCADate],[External Patient ID],[Source System Order],[SFDC Order ID],[FoC Quantity],[Deliverable Quantity],[Sales Unit],[Target Qu],[Target Qty],[Document Currency],[Net Price],[Net Value],[Customer Group1],[Customer Group2],[Customer Group3],[Customer Group4],[Customer Group5],[SalesOrder Item],[Sales Organization],[Distribution Channel],[Storage Location],[Division],[External Treatment I],[Treatment Option],[ZZTREATMENT],[MaxNoOfStages],[TreatmentLocation],[TreatingDoctor],[OrderStages],[StagesBucket],[MaterialGroup1],[MaterialGroup2],[MaterialGroup3],[MaterialGroup4],[MaterialGroup5],[ClinicalStudy],[Total Quantity],[CA_PRIMRY],[CA_SECNDRY],[CA_NONCAS],[CA_OTHERS],[ReasonRejection],[Order Quantity],[Withdraw Quantity],[Delivery Quantity],[DeliveryItem],[ActualsGoodIssueDate],[Reporting Channel],[Document Date],[CertificationDate],[CertificationYear],[AdvantageTier],[ProfessionalCategory],[Country],[CountryGroup],[RegionPC],[RegionGroup],[GlobalRegion],[Reporting Region],[Plant],[BASe Unit of Measure],[Weight Unit],[Revenue Recognition],[CA_UNKNOWN],[Free_Paid]
Order By
[SalesOrder],[EventDate],[Ship-ToParty],[Sold-ToParty],[SalesOrderType],[VolumeUnit],[ProfitCenter],[Material],[CompanyCode],[PGIDate],[Product Hierarchy],[Item Category],[PromoBucket],[DateofMIM],[Fiscal Variant],[FileYN],[itro_scr],[itro_serv],[Shipment Count],[Segment],[Volume Segment],[Volume Sub-Segment],[Cost Element(COPA)],[Sales Group],[Controlling Area],[Process Name],[Business Segment],[ActualDeliveryQuantity],[Age Tier],[Volume],[Net Weight],[Total Weight],[Delivery],[Treatment Category],[Document_Category],[Delivery Type],[Reason Rejection],[KNUM],[Profitability segment],[CostCenter],[Compliance Indicator],[Serial Number],[Initiator Company ID],[AMR Date],[CCS Date],[CCADate],[External Patient ID],[Source System Order],[SFDC Order ID],[FoC Quantity],[Deliverable Quantity],[Sales Unit],[Target Qu],[Target Qty],[Document Currency],[Net Price],[Net Value],[Customer Group1],[Customer Group2],[Customer Group3],[Customer Group4],[Customer Group5],[SalesOrder Item],[Sales Organization],[Distribution Channel],[Storage Location],[Division],[External Treatment I],[Treatment Option],[ZZTREATMENT],[MaxNoOfStages],[TreatmentLocation],[TreatingDoctor],[OrderStages],[StagesBucket],[MaterialGroup1],[MaterialGroup2],[MaterialGroup3],[MaterialGroup4],[MaterialGroup5],[ClinicalStudy],[Total Quantity],[CA_PRIMRY],[CA_SECNDRY],[CA_NONCAS],[CA_OTHERS],[ReasonRejection],[Order Quantity],[Withdraw Quantity],[Delivery Quantity],[DeliveryItem],[ActualsGoodIssueDate],[Reporting Channel],[Document Date],[CertificationDate],[CertificationYear],[AdvantageTier],[ProfessionalCategory],[Country],[CountryGroup],[RegionPC],[RegionGroup],[GlobalRegion],[Reporting Region],[Plant],[BASe Unit of Measure],[Weight Unit],[Revenue Recognition],[CA_UNKNOWN],[Free_Paid]) AS [ROW],
[SalesOrder],[EventDate],[Ship-ToParty],[Sold-ToParty],[SalesOrderType],[VolumeUnit],[ProfitCenter],[Material],[CompanyCode],[PGIDate],[Product Hierarchy],[Item Category],[PromoBucket],[DateofMIM],[Fiscal Variant],[FileYN],[itro_scr],[itro_serv],[Shipment Count],[Segment],[Volume Segment],[Volume Sub-Segment],[Cost Element(COPA)],[Sales Group],[Controlling Area],[Process Name],[Business Segment],[ActualDeliveryQuantity],[Age Tier],[Volume],[Net Weight],[Total Weight],[Delivery],[Treatment Category],[Document_Category],[Delivery Type],[Reason Rejection],[KNUM],[Profitability segment],[CostCenter],[Compliance Indicator],[Serial Number],[Initiator Company ID],[AMR Date],[CCS Date],[CCADate],[External Patient ID],[Source System Order],[SFDC Order ID],[FoC Quantity],[Deliverable Quantity],[Sales Unit],[Target Qu],[Target Qty],[Document Currency],[Net Price],[Net Value],[Customer Group1],[Customer Group2],[Customer Group3],[Customer Group4],[Customer Group5],[SalesOrder Item],[Sales Organization],[Distribution Channel],[Storage Location],[Division],[External Treatment I],[Treatment Option],[ZZTREATMENT],[MaxNoOfStages],[TreatmentLocation],[TreatingDoctor],[OrderStages],[StagesBucket],[MaterialGroup1],[MaterialGroup2],[MaterialGroup3],[MaterialGroup4],[MaterialGroup5],[ClinicalStudy],[Total Quantity],[CA_PRIMRY],[CA_SECNDRY],[CA_NONCAS],[CA_OTHERS],[ReasonRejection],[Order Quantity],[Withdraw Quantity],[Delivery Quantity],[DeliveryItem],[ActualsGoodIssueDate],[Reporting Channel],[Document Date],[CertificationDate],[CertificationYear],[AdvantageTier],[ProfessionalCategory],[Country],[CountryGroup],[RegionPC],[RegionGroup],[GlobalRegion],[Reporting Region],[Plant],[BASe Unit of Measure],[Weight Unit],[Revenue Recognition],[CA_UNKNOWN],[Free_Paid]
From  DWSAP.[ScannerRevenueUnitProcessed_Performance] 
WITH(NOLOCK) )
DELETE FROM CTE WHERE [ROW]>1

END