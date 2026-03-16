CREATE VIEW [TABSAP].[OperationsVolume] AS WITH ManufacturingCTE AS
(SELECT DISTINCT 
[Sales Document]
,MAX([Mfg Order Actual End Date]) AS [Mfg Order Actual End Date ]
,[DatPrpPlant]
,[OrdAdqPlant]
,[TreatMPlant]
,[DDTPlant]
,[Mfg Material Number]
,[Data Prep Plant Name]
,[Order Acquisition Plant Name]
,[Treatment Plant Name]
,[DDT Plant Name] 
FROM [DWSAP].[OperationsManufacturingOrderItem] WITH(NOLOCK)
GROUP BY [Sales Document],[DatPrpPlant],[OrdAdqPlant],[TreatMPlant],[DDTPlant],[Mfg Material Number],[Data Prep Plant Name],[Order Acquisition Plant Name]
,[Treatment Plant Name],[DDT Plant Name]),

MaterialDocCTE AS
(SELECT 
[SalesDocument]
,MAX([Posting Date]) AS [Posting Date]
,[YearMonth],[Material Number] AS [Material]
,[Local Currency] AS [MB51 Local Currency]
,SUM([Amount in Local Currency]) AS [MB51 Amount in Local Currency]
,[Local Currency2] AS [MB51 Local Currency2]
,SUM([Amount in Local Currency2]) AS [Total MLO Cost] 
FROM [DWSAP].[OperationsMaterialDocumentItem] WITH(NOLOCK) WHERE [SalesDocument] IS NOT NULL AND [SalesDocument] <> 0 
GROUP BY [SalesDocument],[YearMonth],[Material Number],[Local Currency],[Local Currency2]),

DimCusAccountCTE AS
(SELECT 
Account_Number__c as AccountNumber
,[Name] as AccountName
FROM SrcSFDC.Account  INNER JOIN custom.GeographyHierarchy  ON ShippingCountryCode = CountryCode
WHERE Account_Number__c  IS NOT NULL),

ProfitCenterCTE AS
(SELECT 
[Profit Center]
,[Profit Center Text]
,[Profit center area]
,[Hedged/Unhedged]
,[GlobalRegionsExecutive] 
FROM [TABSAP].[OperationsDimProfitCenter] WITH(NOLOCK)),

ProductCTE AS
(SELECT 
[Product hierarchy]
,[Product Hierarchy Desc]
,[ProductGroup] 
FROM TABSAP.DimProduct WITH(NOLOCK)),

ChinaMarkupCTE AS
( SELECT   
[Sales Order]
,Material
,SUM([Base Cost in local curr]) AS [Base Cost in local curr]
,SUM([Mark Up in local curr]) AS [Mark Up in local curr]
,SUM([Base Cost in USD]) AS [Base Cost in USD]
,SUM([Mark-up in USD]) AS [Mark up in USD] 
FROM [DWSAP].[ChinaMarkup] cmu WITH(NOLOCK) 
INNER JOIN TABSAP.OperationsDimMaterial odm ON odm.[Material Number] = cmu.[Material] AND odm.[Material Type] = 'KMAT'
GROUP BY [Sales Order], Material)

SELECT  
SALES.[Sales Document]
,[Sales Document Item Category]
,[Sales Group]
,TRY_CONVERT(DATE,[Actual Goods Movement Date]) [Actual Goods Movement Date]
,SALES.[Profit Center]
,SALES.[Material]
,[Product Hierarchy Node]
,[Treatment Option]
,[DeliverableType]
,[Additional Customer Group1]
,[Additional Customer Group1 Description]
,[Sales Order Count]
,[TotalQuantity]
,[DeliverableQuantity]
,[Production Plant]
,[Production Plant Name]
,[Treatment Category]
,[Sales Order Type]
,[SFDC Order ID]
,[IDS Order ID]
,[Treatment ID]
,[CCA Date]
,[AMR Date]
,COALESCE (a.[ShipTo],vbpap.WE) [Ship To Party]
,COALESCE (sh.AccountName,kn.AccountName) [Ship To Party Name]
,[Sold To Party]
,COALESCE ( sot.AccountName,kn1.AccountName ) [Sold To Party Name]
,[Bill To Party]
,COALESCE (bt.AccountName,kn2.AccountName) [Bill To Party Name]
,a.[TreatingDoctor] [Treating Doctor]
,[Treating Doctor Name]
,a.[TreatmentLocation] [Treatment Location]
,[TreatmentLocationName]
,[Total Net Amount]
,[Total Net Amount Unit/Currency]
,[Order Quantity]
,[Actual Delivery Quantity]
,[Original Delivery Quantity]
,[FOCQuantity]
,[Compliance Indicator]
,[Division]
,[Distribution Channel]
,[Contact Professional Category]
,[Mandular Adjustment Flag]
,[DSO Flag]
,SALES.[YearMonth]
,[Mfg Order Actual End Date]
,[DatPrpPlant] as [Data Prep Plant]
,[Data Prep Plant Name]
,[OrdAdqPlant] as [Order Acquisition Plant]
,[Order Acquisition Plant Name]
,[DDTPlant] AS [DDT Plant]
,[DDT Plant Name] AS [DDT Plant Name]

--deriving Treatment Plant by applying some condition based on ProductGroup,OrdAdqPlant,DatPrpPlant,Production Plant
,CASE WHEN [ProductGroup] IN (SELECT [Product Group] FROM [DWSAP].[TreatMPlantConfig]) AND [DatPrpPlant] IS NOT NULL 
THEN [DatPrpPlant] 
WHEN [ProductGroup] IN (SELECT [Product Group] FROM [DWSAP].[TreatMPlantConfig]) AND [DatPrpPlant] IS NULL
AND [Production Plant] IN (SELECT [Production Plant] FROM  [DWSAP].[TreatMPlantConfig] WHERE [Production Plant] ='2101') 
THEN (SELECT [Treatment Plant] FROM [DWSAP].[TreatMPlantConfig] WHERE [Production Plant] = '2101')
WHEN [ProductGroup] IN (SELECT [Product Group] FROM [DWSAP].[TreatMPlantConfig]) AND [DatPrpPlant] IS NULL 
AND [Production Plant] IN (SELECT [Production Plant] FROM [DWSAP].[TreatMPlantConfig] WHERE [Production Plant] ='2801') 
THEN (SELECT [Treatment Plant] FROM [DWSAP].[TreatMPlantConfig] WHERE [Production Plant] = '2801') 
WHEN [ProductGroup] IN (SELECT [Product Group] FROM [DWSAP].[TreatMPlantConfig]) AND [DatPrpPlant] IS NULL 
AND [Production Plant] NOT IN (SELECT [Production Plant] FROM [DWSAP].[TreatMPlantConfig] WHERE [Production Plant] IS NOT NULL) 
AND [OrdAdqPlant] IN (SELECT [OrdAdqPlant] FROM [DWSAP].[TreatMPlantConfig] WHERE [OrdAdqPlant]='2101') 
THEN (SELECT [Treatment Plant] FROM [DWSAP].[TreatMPlantConfig] WHERE [Production Plant] = '2101') 
WHEN [ProductGroup] IN (SELECT [Product Group] FROM [DWSAP].[TreatMPlantConfig]) AND [DatPrpPlant] IS NULL 
AND [Production Plant] NOT IN (SELECT  [Production Plant] FROM [DWSAP].[TreatMPlantConfig] WHERE [Production Plant] IS NOT NULL) 
AND [OrdAdqPlant] IN (SELECT [OrdAdqPlant] FROM [DWSAP].[TreatMPlantConfig] WHERE [OrdAdqPlant]='2801') 
THEN (SELECT [Treatment Plant] FROM [DWSAP].[TreatMPlantConfig] WHERE [Production Plant] = '2801') ELSE [TreatMPlant] END AS [Treatment Plant]

--deriving Treatment Plant Name by applying some condition based on ProductGroup,OrdAdqPlant,DatPrpPlant,Production Plant
,CASE WHEN [ProductGroup] IN (SELECT [Product Group] FROM [DWSAP].[TreatMPlantConfig]) AND [DatPrpPlant] IS NOT NULL 
THEN [Data Prep Plant Name]   
WHEN [ProductGroup] IN (SELECT [Product Group] FROM [DWSAP].[TreatMPlantConfig]) AND [DatPrpPlant] IS NULL 
AND [Production Plant] = '2101' THEN [Production Plant Name] 
WHEN [ProductGroup] IN (SELECT [Product Group] FROM [DWSAP].[TreatMPlantConfig]) AND [DatPrpPlant] IS NULL AND [Production Plant] = '2801' 
THEN [Production Plant Name] 
WHEN [ProductGroup] IN (SELECT [Product Group] FROM [DWSAP].[TreatMPlantConfig]) AND [DatPrpPlant] IS NULL 
AND [Production Plant] NOT IN ('2101','2801') AND [OrdAdqPlant] = '2101' 
THEN [Order Acquisition Plant Name] 
WHEN [ProductGroup] IN (SELECT [Product Group] FROM [DWSAP].[TreatMPlantConfig]) AND [DatPrpPlant] IS NULL 
AND [Production Plant] NOT IN('2101','2801') AND [OrdAdqPlant] = '2801' 
THEN [Order Acquisition Plant Name] ELSE [Treatment Plant Name] END AS [Treatment Plant Name]

,[ProductGroup]
,[Profit Center Text]
,[GlobalRegionsExecutive] AS [Region]
,[Posting Date]
,[MB51 Local Currency]
,[MB51 Amount in Local Currency]
,[MB51 Local Currency2]
,[Total MLO Cost]
,[Base Cost in local curr]
,[Mark Up in local curr]
,[Base Cost in USD]
,[Mark up in USD] 

FROM 
DWSAP.OperationsSalesDeliveryDetails SALES WITH(NOLOCK) 
LEFT JOIN  
ManufacturingCTE Manufacturing 
ON Manufacturing.[Sales Document] = SALES.[Sales Document] AND Manufacturing.[Mfg Material Number] = SALES.[Material] 
LEFT JOIN 
MaterialDocCTE 
ON MaterialDocCTE.[SalesDocument] = SALES.[Sales Document] AND MaterialDocCTE.[Material]= SALES.[Material] AND SALES.[YearMonth] = MaterialDocCTE.[YearMonth]
LEFT JOIN 
[TabSAP].[DimOrderAttributes] a ON TRY_CONVERT(BIGINT,a.[OrderNumber]) = SALES.[Sales Document]
LEFT JOIN 
ProfitCenterCTE ProfitCTE ON ProfitCTE.[Profit Center] = SALES.[Profit Center]
LEFT JOIN 
ProductCTE ProdCTE ON SALES.[Product Hierarchy Node] = ProdCTE.[Product hierarchy]
LEFT JOIN 
ChinaMarkupCTE CMUCTE ON CMUCTE.[Sales Order] = SALES.[Sales Document] AND CMUCTE.[Material] = SALES.[Material]
LEFT JOIN 
DWSAP.VBPA_Pivoted_v2 vbpap ON SALES.[Sales Document] = TRY_CONVERT(BIGINT,vbpap.VBELN) 
LEFT JOIN 
DimCusAccountCTE sh ON sh.AccountNumber = a.ShipTo 
LEFT JOIN 
DimCusAccountCTE bt ON bt.AccountNumber = a.BillTo 
LEFT JOIN 
DimCusAccountCTE sot ON sot.AccountNumber = a.SoldTo 
LEFT JOIN 
DimCusAccountCTE kn ON TRY_CONVERT(BIGINT,vbpap.WE) = TRY_CONVERT(BIGINT,kn.AccountNumber) 
LEFT JOIN 
DimCusAccountCTE kn1 ON TRY_CONVERT(BIGINT,vbpap.AG) = TRY_CONVERT(BIGINT,kn1.AccountNumber) 
LEFT JOIN 
DimCusAccountCTE kn2 ON TRY_CONVERT(BIGINT,vbpap.RE) = TRY_CONVERT(BIGINT,kn2.AccountNumber)
WHERE SALES.[Sales Document Item Category] IN ('Z001','Z002','Z004','Z005','Z006') ;



