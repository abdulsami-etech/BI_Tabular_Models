CREATE VIEW [TABTOPS].[FactMESProductivity]
AS With OMS_Area
As
(SELECT
	A.[areaID],
	REPLACE(A.[areaName],'Japan','Japan YK') AS areaName
FROM  [SrcMesOMS].[Area] A
WHERE [isActive] = 1
)
,OMS_AREA_GR
as
(
SELECT 
	A.[areaID]
	,B.[SKGroupRegion]
	,A.[areaName]
	,B.[GroupRegion]
FROM OMS_Area A
  LEFT JOIN [TABTOPS].[DimGroupRegion] B 
  ON B.[GroupRegion] = A.[areaName]
  )
  , stg1
  as
  (
  SELECT DISTINCT
		pm.productionMasterID,
		pd.productionDetailID,
		pm.dateProduction,
		pm.technicianID,
		pm.siteID,
		pm.areaID,
		pm.regionID,
		pm.cellID,
		pm.rttHeadID,
		op.operationAliasID,
		op_principal.operationAliasID AS 'operationAliasPrincipal',
		pm.principalOperationStandardTimeID,
		(pm.efficiency / 100.00) AS 'efficiency',
		pm.breastfeedingMasterID,
		pm.breakTimeMasterID,
		ISNULL(CONVERT(DECIMAL(8,2), bfd.totalMinutes / 60.00),0) AS 'totalHoursBF',
		pm.totalHoursDownTime,
		pm.totalHoursVADownTime,
		pd.effectiveTime AS 'effectiveTime', 
		CASE WHEN pd.isOvertime = 0 THEN  pd.effectiveTime- (ISNULL(CONVERT(DECIMAL(8,2), bfd.totalMinutes / 60.00),0) + pm.totalHoursVADownTime) ELSE pd.effectiveTime END AS 'effectiveTimeVA',
		CASE WHEN pd.isOvertime = 0 THEN  pd.effectiveTime- (ISNULL(CONVERT(DECIMAL(8,2), bfd.totalMinutes / 60.00),0) + pm.totalHoursVADownTime) ELSE pd.effectiveTime END AS 'realEffectiveTime',
		'totalNew_Or_Pvs' = CASE 
								WHEN  op.operationAliasID  != op_principal.operationAliasID
								THEN
									((pd.numberOfNewCases * (COALESCE(std.stdNewCase, std.stdPvs, 0.00) / NULLIF((pm.efficiency / 100.00),0))) / NULLIF(COALESCE(std_principal.stdNewCase, std_principal.stdPvs, 0.00),0))
								ELSE
									CONVERT(DECIMAL(10,3),(CASE WHEN pd.numberOfNewCases != 0 OR pd.numberOfReCC != 0 THEN pd.numberOfNewCases ELSE pd.PVS END))
								END,
		'totalCCMods_Or_Ios' = CASE 
							WHEN  op.operationAliasID  != op_principal.operationAliasID
							THEN
								((pd.numberOfReCC * (COALESCE(std.stdCCMods, std.stdIos, 0.00) / NULLIF((pm.efficiency / 100.00),0))) / NULLIF(COALESCE(std_principal.stdCCMods, std_principal.stdIos, 0.00),0))
							ELSE
								CONVERT(DECIMAL(10,3),(CASE WHEN pd.numberOfNewCases != 0 OR pd.numberOfReCC != 0 THEN pd.numberOfReCC ELSE pd.IOS END)) 
							END,
		pd.orderRegionID,
		pd.orderCategoryID,
		pd.operationID,
		pd.standardTimeID,
		pd.PVS,
		pd.IOS,
		COALESCE(std.stdNewCase, std.stdPvs, 0.00)	AS 'stdNewCase_Or_Pvs',
		COALESCE(std.stdCCMods, std.stdIos, 0.00)	AS 'stdCCMods_Or_Ios',
		COALESCE(std_principal.stdNewCase, std_principal.stdPvs, 0.00)	AS 'stdNewCase_Or_Pvs_Principal',
		COALESCE(std_principal.stdCCMods, std_principal.stdIos, 0.00)	AS 'stdCCMods_Or_Ios_Principal',
		pd.isOvertime
	--INTO #stg1
	FROM
		[SrcMesOMS].[ProductionMaster] pm
		INNER JOIN [SrcMesOMS].[ProductionDetail] pd ON pd.productionMasterID = pm.productionMasterID
		INNER JOIN [SrcMesOMS].[Technician] tech ON tech.technicianID = pm.technicianID
		INNER JOIN [SrcMesOMS].[User] us_tech ON us_tech.userID = tech.userID
		INNER JOIN [SrcMesOMS].[Operation] op ON op.operationID = pd.operationID
		INNER JOIN [SrcMesOMS].[Operation] op_principal ON op_principal.operationID = pm.principalOperationID
		LEFT JOIN  [SrcMesOMS].[StandardTimeDetail] std ON (std.standardTimeID = pd.standardTimeID AND std.orderCategoryID = pd.orderCategoryID)
		LEFT JOIN  [SrcMesOMS].[StandardTimeDetail] std_principal ON (
			std_principal.standardTimeID = pm.principalOperationStandardTimeID 
			AND std_principal.orderCategoryID = pd.orderCategoryID
		)
		LEFT JOIN [SrcMesOMS].[BreastfeedingDetail] bfd ON bfd.breastfeedingMasterID = pm.breastfeedingMasterID

	WHERE
		op_principal.operationAliasID in (4,13)
		AND
		pd.isOvertime = 0
		AND
		pm.dateProduction BETWEEN dateadd(month,-13,getdate()) AND Getdate()

		)
, stg2 
as
(SELECT DISTINCT 
	 	CONVERT(DATE,A.dateProduction) AS [dateProduction],
		isnull(convert(int, convert(varchar(8), A.dateProduction, 112)), -1) AS [SKDateProduction],
		A.siteID,
		A.areaID

	FROM stg1 as A
)
, stg2_EffectiveTim
as
(
	SELECT DISTINCT
		CONVERT(DATE,A.dateProduction) AS [dateProduction],
		isnull(convert(int, convert(varchar(8), A.dateProduction, 112)), -1) AS [SKDateProduction],
		A.siteID,
		A.areaID,
		A.cellID,
		A.technicianID,
		A.effectiveTime AS [effectiveTime],
		A.realEffectiveTime AS [realEffectiveTime]

	FROM stg1 A
WHERE A.isOvertime = 0
)
,stg1_Ratios
as
(SELECT 
		CONVERT(DATE,A.dateProduction) AS [dateProduction],
		isnull(convert(int, convert(varchar(8), A.dateProduction, 112)), -1) AS [SKDateProduction],
		A.siteID,
		A.areaID,
		A.cellID,
		A.orderCategoryID,
		A.efficiency,
		[Ratio] = (SUM(A.totalNew_Or_Pvs)* A.stdNewCase_Or_Pvs) + (SUM(A.totalCCMods_Or_Ios)* A.stdCCMods_Or_Ios),
		[Ratio_w_E] = (SUM(A.totalNew_Or_Pvs)* (A.stdNewCase_Or_Pvs/A.efficiency)) + (SUM(A.totalCCMods_Or_Ios)* (A.stdCCMods_Or_Ios/A.efficiency))

	FROM stg1 A

	WHERE A.isOvertime = 0
	GROUP BY
		CONVERT(DATE,A.dateProduction),
		isnull(convert(int, convert(varchar(8), A.dateProduction, 112)), -1),
		A.siteID,
		A.areaID,
		A.cellID,
		A.orderCategoryID,
		A.efficiency,
		A.stdNewCase_Or_Pvs,
		A.stdCCMods_Or_Ios
)
, RATIO
as
(
SELECT DISTINCT A.SKDateProduction, A.siteID, A.areaID, SUM(A.Ratio) AS [Ratio], 
SUM(A.Ratio_w_E) AS [Ratio_E]	
	FROM stg1_Ratios as A 
	GROUP BY A.SKDateProduction, A.siteID, A.areaID
)
, ET 
as
(SELECT DISTINCT B.SKDateProduction, B.siteID, B.areaID, 
SUM(B.effectiveTime) AS [effectiveTime], 
SUM(B.realEffectiveTime) AS [realEffectiveTime]
 FROM stg2_EffectiveTim as B 
 GROUP BY B.SKDateProduction, B.siteID, B.areaID
)
, FT
as
(
SELECT 
		A.SKDateProduction,
		A.siteID,
		A.areaID,
		B.Ratio,
		B.Ratio_E,
		C.effectiveTime,
		C.realEffectiveTime
	FROM stg2  as A
		INNER JOIN RATIO as	B 
		ON (B.SKDateProduction = A.SKDateProduction AND B.siteID = A.siteID AND B.areaID = A.areaID)
		INNER JOIN ET	 as	C 
		ON (C.SKDateProduction = A.SKDateProduction AND C.siteID = A.siteID AND C.areaID = A.areaID)
)

SELECT DISTINCT 
		DATEADD(DAY,1,EOMONTH(D.KeyDate,-1)) AS Monthly,
		CONCAT(A.[SKGroupRegion],P.[SKPlant]) AS [SKGroupRegionPlant],
		[MTD_Ratio] = SUM(F.Ratio)  OVER (PARTITION BY CONCAT(A.[SKGroupRegion],P.[SKPlant]), DATEADD(DAY,1,EOMONTH(D.KeyDate,-1)) 
											ORDER BY  CONCAT(A.[SKGroupRegion],P.[SKPlant]), DATEADD(DAY,1,EOMONTH(D.KeyDate,-1))),
		[MTD_ET] = SUM(CONVERT(float,SUM(F.effectiveTime*60))) OVER (PARTITION BY CONCAT(A.[SKGroupRegion],P.[SKPlant]), DATEADD(DAY,1,EOMONTH(D.KeyDate,-1)) 
																		ORDER BY  CONCAT(A.[SKGroupRegion],P.[SKPlant]), DATEADD(DAY,1,EOMONTH(D.KeyDate,-1))),
		[YTD_Ratio] = SUM(F.Ratio)  OVER (PARTITION BY CONCAT(A.[SKGroupRegion],P.[SKPlant]), YEAR(DATEADD(DAY,1,EOMONTH(D.KeyDate,-1))) 
											ORDER BY  CONCAT(A.[SKGroupRegion],P.[SKPlant]), DATEADD(DAY,1,EOMONTH(D.KeyDate,-1))),
		[YTD_ET] = SUM(CONVERT(float,SUM(F.effectiveTime*60))) OVER (PARTITION BY CONCAT(A.[SKGroupRegion],P.[SKPlant]), YEAR(DATEADD(DAY,1,EOMONTH(D.KeyDate,-1))) 
																		ORDER BY  CONCAT(A.[SKGroupRegion],P.[SKPlant]), DATEADD(DAY,1,EOMONTH(D.KeyDate,-1))),
		[YTD_Ratio_Rolling] = SUM(F.Ratio)  OVER (PARTITION BY CONCAT(A.[SKGroupRegion],P.[SKPlant]), YEAR(DATEADD(DAY,1,EOMONTH(D.KeyDate,-1))) 
													ORDER BY  YEAR(DATEADD(DAY,1,EOMONTH(D.KeyDate,-1)))),
		[YTD_ET_Rolling] = SUM(CONVERT(float,SUM(F.effectiveTime*60))) OVER (PARTITION BY CONCAT(A.[SKGroupRegion],P.[SKPlant]), YEAR(DATEADD(DAY,1,EOMONTH(D.KeyDate,-1))) 
																				ORDER BY  YEAR(DATEADD(DAY,1,EOMONTH(D.KeyDate,-1))))


	FROM FT F
	INNER JOIN OMS_AREA_GR as A ON A.[areaID] = F.areaID
	INNER JOIN [SrcMesOMS].[Site] S ON S.[siteID] = F.siteID
	INNER JOIN [TABTOPS].[DimDate] D ON D.[SKDate] = F.SKDateProduction
	LEFT JOIN [TABTOPS].[DimPlant] P ON P.[PlantDescription] = (CASE WHEN D.[CalendarYear] = 2020 THEN REPLACE(S.[siteName],'(BV)','(CH)') ELSE S.[siteName] END)
	WHERE 
	A.[SKGroupRegion] IS NOT NULL
	GROUP BY
		DATEADD(DAY,1,EOMONTH(D.KeyDate,-1)),
		CONCAT(A.[SKGroupRegion],P.[SKPlant]),
		F.Ratio;