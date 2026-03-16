CREATE PROC [DWCONSDL].[LoadFactConsdlKPIConsolidated] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	Declare @CurrentDateTime datetime = GETUTCDATE();
	
	if object_id('tempdb..#TempFactConsdlKPIConsolidated') is not null
		drop table #TempFactConsdlKPIConsolidated

	create table #TempFactConsdlKPIConsolidated with (distribution = round_robin, heap) as 
	

---------------- All regions GA UVs, UPVs, Sessions  Monthly-------------------------------------

SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Monthly' AND Region = 'BRAZIL' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'BRAZIL' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))
UNION ALL
SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Monthly' AND Region = 'CANADA' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'CANADA' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))
UNION ALL
SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Monthly' AND Region = 'EMEA' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'EMEA' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))
UNION ALL
SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Monthly' AND Region = 'US' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'US' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))
UNION ALL
SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Monthly' AND Region = 'APAC' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'APAC' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))
UNION ALL
SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Monthly' AND Region = 'LATAM' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'LATAM' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))

UNION ALL

---------------- All regions GA UVs, UPVs, Sessions  Weekly-------------------------------------

SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Weekly' AND Region = 'BRAZIL' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'BRAZIL' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))
UNION ALL
SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Weekly' AND Region = 'CANADA' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'CANADA' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))
UNION ALL
SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Weekly' AND Region = 'EMEA' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'EMEA' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))
UNION ALL
SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Weekly' AND Region = 'US' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'US' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))
UNION ALL
SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Weekly' AND Region = 'APAC' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'APAC' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))
UNION ALL
SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Weekly' AND Region = 'LATAM' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'LATAM' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))

UNION ALL

---------------- All regions GA UVs, UPVs, Sessions  Quarterly-------------------------------------

SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Quarterly' AND Region = 'BRAZIL' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'BRAZIL' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))
UNION ALL
SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Quarterly' AND Region = 'CANADA' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'CANADA' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))
UNION ALL
SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Quarterly' AND Region = 'EMEA' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'EMEA' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))
UNION ALL
SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Quarterly' AND Region = 'US' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'US' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))
UNION ALL
SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Quarterly' AND Region = 'APAC' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'APAC' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))
UNION ALL
SELECT CONVERT(CHAR(40), '') AS DWHashKey,Region,CountryFromHostName,KPI, KPI AS KPIDetails, Level, StartDate, EndDate, KPIValue FROM DWCONSDL.FactGAUMsC
UNPIVOT (KPIValue FOR KPI IN (UVs, UPVs, Sessions)) unpvt
WHERE  Level = 'Quarterly' AND Region = 'LATAM' AND StartDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'LATAM' AND KPI IN ( 'UVs', 'UPVs', 'Sessions'))

UNION ALL

-------------------------------  Doc Locator Searches (unique) Monthly-------------------------------------------

-- US AND CANADA Doc Locator Searches (unique)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Doc Locator Searches (unique)' AS KPI
	  ,'Doc Locator Searches (unique)' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(distinct viewer_id) AS KPIValue 
FROM DWCONSDL.FactAlignDocLocSearches DLS
INNER JOIN [DW].[DimDateTime] DDT ON DLS.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON DLS.CountryCode = GH.CountryCode
WHERE DLS.CountryCode IN ('CA','US') AND DLS.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'NA' AND KPI = 'Doc Locator Searches (unique)')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate,GH.SecRegion,GH.Country

UNION ALL

-- EMEA Doc Locator Searches (unique)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Doc Locator Searches (unique)' AS KPI
	  ,'Doc Locator Searches (unique)' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,SUM(G_ID9) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'EMEA' AND KPI = 'Doc Locator Searches (unique)')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, CountryFromHostName

UNION ALL

-- BRAZIL Doc Locator Searches (unique)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'BRAZIL' AS Region
	  ,CountryFromHostName
	  ,'Doc Locator Searches (unique)' AS KPI
	  ,'Doc Locator Searches (unique)' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,SUM(G_ID1) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsBRAZILDailyC] FG
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'BRAZIL' AND KPI = 'Doc Locator Searches (unique)')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, CountryFromHostName

UNION ALL

-- LATAM Doc Locator Searches (unique)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,CountryFromHostName
	  ,'Doc Locator Searches (unique)' AS KPI
	  ,'Doc Locator Searches (unique)' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,SUM(G_ID1) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsLATAMDailyC] FG
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'LATAM' AND KPI = 'Doc Locator Searches (unique)')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, CountryFromHostName

UNION ALL

-- APAC Doc Locator Searches (unique)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'APAC' AS Region
	  , CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of APAC' END AS CountryFromHostName
	  ,'Doc Locator Searches (unique)' AS KPI
	  ,'Doc Locator Searches (unique)' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(DISTINCT FullVisitorId) AS KPIValue
FROM [SrcGoogleBigQuery].[GA_SessionHits_APAC] SH 
INNER JOIN [DW].[DimDateTime] DDT ON SH.VisitDate = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'APAC' AND CM.IsValid = 1
WHERE SH.PagePath='/find-a-doctor' AND SH.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'APAC' AND KPI = 'Doc Locator Searches (unique)' AND KPIDetails = 'Doc Locator Searches (unique)')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, CM.CountryFromHostName

UNION ALL

-------------------------------  Doc Locator Searches (unique) Weekly-------------------------------------------

-- US AND CANADA Doc Locator Searches (unique)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Doc Locator Searches (unique)' AS KPI
	  ,'Doc Locator Searches (unique)' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(distinct viewer_id) AS KPIValue 
FROM DWCONSDL.FactAlignDocLocSearches DLS
INNER JOIN [DW].[DimDateTime] DDT ON DLS.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON DLS.CountryCode = GH.CountryCode
WHERE DLS.CountryCode IN ('CA','US') AND DLS.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'NA' AND KPI = 'Doc Locator Searches (unique)')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate,GH.SecRegion,GH.Country

UNION ALL

-- EMEA Doc Locator Searches (unique)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Doc Locator Searches (unique)' AS KPI
	  ,'Doc Locator Searches (unique)' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,SUM(G_ID9) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'EMEA' AND KPI = 'Doc Locator Searches (unique)')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, CountryFromHostName

UNION ALL

-- BRAZIL Doc Locator Searches (unique)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'BRAZIL' AS Region
	  ,CountryFromHostName
	  ,'Doc Locator Searches (unique)' AS KPI
	  ,'Doc Locator Searches (unique)' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,SUM(G_ID1) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsBRAZILDailyC] FG
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'BRAZIL' AND KPI = 'Doc Locator Searches (unique)')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, CountryFromHostName

UNION ALL

-- LATAM Doc Locator Searches (unique)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,CountryFromHostName
	  ,'Doc Locator Searches (unique)' AS KPI
	  ,'Doc Locator Searches (unique)' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,SUM(G_ID1) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsLATAMDailyC] FG
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'LATAM' AND KPI = 'Doc Locator Searches (unique)')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, CountryFromHostName

UNION ALL

-- APAC Doc Locator Searches (unique)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'APAC' AS Region
	  , CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of APAC' END AS CountryFromHostName
	  ,'Doc Locator Searches (unique)' AS KPI
	  ,'Doc Locator Searches (unique)' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(DISTINCT FullVisitorId) AS KPIValue
FROM [SrcGoogleBigQuery].[GA_SessionHits_APAC] SH 
INNER JOIN [DW].[DimDateTime] DDT ON SH.VisitDate = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'APAC' AND CM.IsValid = 1
WHERE SH.PagePath='/find-a-doctor' AND SH.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'APAC' AND KPI = 'Doc Locator Searches (unique)' AND KPIDetails = 'Doc Locator Searches (unique)')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, CM.CountryFromHostName

UNION ALL

-------------------------------  Doc Locator Searches (unique) Quarterly-------------------------------------------

-- US AND CANADA Doc Locator Searches (unique)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Doc Locator Searches (unique)' AS KPI
	  ,'Doc Locator Searches (unique)' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(distinct viewer_id) AS KPIValue 
FROM DWCONSDL.FactAlignDocLocSearches DLS
INNER JOIN [DW].[DimDateTime] DDT ON DLS.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON DLS.CountryCode = GH.CountryCode
WHERE DLS.CountryCode IN ('CA','US') AND DLS.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'NA' AND KPI = 'Doc Locator Searches (unique)')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate,GH.SecRegion,GH.Country

UNION ALL

-- EMEA Doc Locator Searches (unique)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Doc Locator Searches (unique)' AS KPI
	  ,'Doc Locator Searches (unique)' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,SUM(G_ID9) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'EMEA' AND KPI = 'Doc Locator Searches (unique)')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, CountryFromHostName

UNION ALL

-- BRAZIL Doc Locator Searches (unique)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'BRAZIL' AS Region
	  ,CountryFromHostName
	  ,'Doc Locator Searches (unique)' AS KPI
	  ,'Doc Locator Searches (unique)' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,SUM(G_ID1) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsBRAZILDailyC] FG
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'BRAZIL' AND KPI = 'Doc Locator Searches (unique)')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, CountryFromHostName

UNION ALL

-- LATAM Doc Locator Searches (unique)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,CountryFromHostName
	  ,'Doc Locator Searches (unique)' AS KPI
	  ,'Doc Locator Searches (unique)' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,SUM(G_ID1) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsLATAMDailyC] FG
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'LATAM' AND KPI = 'Doc Locator Searches (unique)')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, CountryFromHostName

UNION ALL

-- APAC Doc Locator Searches (unique)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'APAC' AS Region
	  , CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of APAC' END AS CountryFromHostName
	  ,'Doc Locator Searches (unique)' AS KPI
	  ,'Doc Locator Searches (unique)' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(DISTINCT FullVisitorId) AS KPIValue
FROM [SrcGoogleBigQuery].[GA_SessionHits_APAC] SH 
INNER JOIN [DW].[DimDateTime] DDT ON SH.VisitDate = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'APAC' AND CM.IsValid = 1
WHERE SH.PagePath='/find-a-doctor' AND SH.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'APAC' AND KPI = 'Doc Locator Searches (unique)' AND KPIDetails = 'Doc Locator Searches (unique)')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, CM.CountryFromHostName

UNION ALL

--------------------------------- SMILE COMPLETIONS Monthly ----------------------------------------
-- EMEA Smile Completions  Smile Assessment (Goal ID1)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'Smile Assessment' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,SUM(G_ID1) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'EMEA' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile Assessment')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, CountryFromHostName

UNION ALL

-- EMEA Smile Completions  Smile View (Goal ID19)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'Smile View' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,SUM(G_ID19) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'EMEA' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile View')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, CountryFromHostName

UNION ALL

-- EMEA Smile Completions  Request an Appointment (Goal ID3)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'Request an Appointment' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,SUM(G_ID3) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'EMEA' AND KPI = 'Smile Completions' AND KPIDetails = 'Request an Appointment')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, CountryFromHostName

UNION ALL

-- EMEA Smile Completions  InfoKit (Adult & PoT) (Goal ID2)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'InfoKit (Adult & PoT)' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,SUM(G_ID2) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'EMEA' AND KPI = 'Smile Completions' AND KPIDetails = 'InfoKit (Adult & PoT)')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, CountryFromHostName

UNION ALL

-- EMEA Smile Completions  Request A Callback
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'Request A Callback' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,SUM(G_ID17) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'EMEA' AND KPI = 'Smile Completions' AND KPIDetails = 'Request A Callback')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, CountryFromHostName

UNION ALL

-- LATAM Smile Completions  Smile Assessment
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Smile Completions' AS KPI
	  ,'Smile Assessment' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource = 'Smile Assessment' AND L.Country  IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'LATAM' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile Assessment')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, L.Country

UNION ALL

-- LATAM Smile Completions  Request Appointment
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Smile Completions' AS KPI
	  ,'Request Appointment' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource = 'Request Appointment' AND L.Country  IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'LATAM' AND KPI = 'Smile Completions' AND KPIDetails = 'Request Appointment')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, L.Country

UNION ALL

-- LATAM Smile Completions  Send Results_SmileView
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Smile Completions' AS KPI
	  ,'Send Results_SmileView' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource = 'Send Results_SmileView' AND L.Country  IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'LATAM' AND KPI = 'Smile Completions' AND KPIDetails = 'Send Results_SmileView')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, L.Country

UNION ALL

-- LATAM Smile Completions  SmileView First Step
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Smile Completions' AS KPI
	  ,'SmileView First Step' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource = 'SmileView First Step' AND L.Country  IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'LATAM' AND KPI = 'Smile Completions' AND KPIDetails = 'SmileView First Step')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, L.Country

UNION ALL

-- LATAM Smile Completions  SmileView Learn More
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Smile Completions' AS KPI
	  ,'SmileView Learn More' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource = 'SmileView Learn More' AND L.Country  IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'LATAM' AND KPI = 'Smile Completions' AND KPIDetails = 'SmileView Learn More')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, L.Country



UNION ALL

-- US and CANADA Smile Completions FROM Smile Assesment (DWCONSDL.FactAlignSAWebsite2)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Smile Completions' AS KPI
	  ,'Smile Assessment' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(1) AS KPIValue 
FROM DWCONSDL.FactAlignSAWebsite2 SA
INNER JOIN [DW].[DimDateTime] DDT ON SA.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON SA.CountryCode = GH.CountryCode
WHERE SA.CountryCode IN ('CA','US')
AND SA.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'NA' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile Assessment')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate,GH.SecRegion,GH.Country

UNION ALL

-- US Smile Completions FROM Smile Quiz (SrcNASA.smile_quizzes)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'NA' AS Region  -- Only US in this table
	  ,'United States' AS Country
	  ,'Smile Completions' AS KPI
	  ,'Smile Quiz' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcNASA.smile_quizzes SQ
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,SQ.Created_at) = DDT.DateKey
WHERE SQ.created_at IS NOT NULL
AND (SQ.source NOT IN ('Parent Share Smile Quiz') OR SQ.source IS NULL) AND SQ.Created_at >= '2017-01-01'
AND CONVERT(DATE,SQ.Created_at) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'NA' AND CountryFromHostName = 'United States' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile Quiz')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate

UNION ALL

-- CANADA Smile Completions FROM Smile Quiz (SrcLASA.smile_quizzes)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'NA' AS Region  -- Only CANADA in this table in PROD
	  ,'Canada' AS Country
	  ,'Smile Completions' AS KPI
	  ,'Smile Quiz' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcLASA.smile_quizzes SQ
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,SQ.Created_at) = DDT.DateKey
WHERE SQ.created_at IS NOT NULL
AND (SQ.source NOT IN ('Parent Share Smile Quiz') OR SQ.source IS NULL) AND SQ.Created_at >= '2017-01-01'
AND CONVERT(DATE,SQ.Created_at) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'NA' AND CountryFromHostName = 'Canada' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile Quiz')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate

UNION ALL

-- US and CANADA Smile Completions FROM Request an Appointment (DWCONSDL.FactRequestApptWebsite2)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country 
	  ,'Smile Completions' AS KPI
	  ,'Request an Appointment' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(1) AS KPIValue 
FROM DWCONSDL.FactRequestApptWebsite2 RA
INNER JOIN [DW].[DimDateTime] DDT ON RA.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON RA.CountryCode = GH.CountryCode
WHERE RA.CountryCode IN ('CA','US') AND RA.RequestApptLeadSource NOT IN ('SmileView First Step','SmileView Learn More','SmileView RequestAppt', 'Send Results_SmileView',
'Retail SmileView', 'SmileView Consumer Event')
AND RA.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'NA' AND KPI = 'Smile Completions' AND KPIDetails = 'Request an Appointment')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate,GH.SecRegion,GH.Country

UNION ALL

-- APAC Smile Completions  free assessment (Goal ID4 and GoalID6)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'APAC' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'free assessment' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,(SUM(G_ID4) + SUM(G_ID6)) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsAPACDailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'APAC' AND KPI = 'Smile Completions' AND KPIDetails = 'free assessment')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, CountryFromHostName

UNION ALL

-- APAC Smile Completions  Request an Appointment (Goal ID5 and Goal ID7)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'APAC' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'Request an Appointment' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,(SUM(G_ID5) + SUM(G_ID7)) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsAPACDailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'APAC' AND KPI = 'Smile Completions' AND KPIDetails = 'Request an Appointment')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, CountryFromHostName

UNION ALL

--------------------------------- SMILE COMPLETIONS Weekly ----------------------------------------
-- EMEA Smile Completions  Smile Assessment (Goal ID1)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'Smile Assessment' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,SUM(G_ID1) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'EMEA' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile Assessment')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, CountryFromHostName

UNION ALL

-- EMEA Smile Completions  Smile View (Goal ID19)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'Smile View' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,SUM(G_ID19) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'EMEA' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile View')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, CountryFromHostName

UNION ALL

-- EMEA Smile Completions  Request an Appointment (Goal ID3)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'Request an Appointment' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,SUM(G_ID3) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'EMEA' AND KPI = 'Smile Completions' AND KPIDetails = 'Request an Appointment')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, CountryFromHostName

UNION ALL

-- EMEA Smile Completions  InfoKit (Adult & PoT) (Goal ID2)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'InfoKit (Adult & PoT)' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,SUM(G_ID2) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'EMEA' AND KPI = 'Smile Completions' AND KPIDetails = 'InfoKit (Adult & PoT)')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, CountryFromHostName

UNION ALL

-- EMEA Smile Completions  Request A Callback
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'Request A Callback' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,SUM(G_ID17) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'EMEA' AND KPI = 'Smile Completions' AND KPIDetails = 'Request A Callback')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, CountryFromHostName

UNION ALL

-- LATAM Smile Completions  Smile Assessment
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Smile Completions' AS KPI
	  ,'Smile Assessment' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource = 'Smile Assessment' AND L.Country  IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'LATAM' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile Assessment')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, L.Country

UNION ALL

-- LATAM Smile Completions  Request Appointment
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Smile Completions' AS KPI
	  ,'Request Appointment' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource = 'Request Appointment' AND L.Country  IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'LATAM' AND KPI = 'Smile Completions' AND KPIDetails = 'Request Appointment')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, L.Country

UNION ALL

-- LATAM Smile Completions  Send Results_SmileView
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Smile Completions' AS KPI
	  ,'Send Results_SmileView' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource = 'Send Results_SmileView' AND L.Country  IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'LATAM' AND KPI = 'Smile Completions' AND KPIDetails = 'Send Results_SmileView')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, L.Country

UNION ALL

-- LATAM Smile Completions  SmileView First Step
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Smile Completions' AS KPI
	  ,'SmileView First Step' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource = 'SmileView First Step' AND L.Country  IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'LATAM' AND KPI = 'Smile Completions' AND KPIDetails = 'SmileView First Step')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, L.Country

UNION ALL

-- LATAM Smile Completions  SmileView Learn More
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Smile Completions' AS KPI
	  ,'SmileView Learn More' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource = 'SmileView Learn More' AND L.Country  IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'LATAM' AND KPI = 'Smile Completions' AND KPIDetails = 'SmileView Learn More')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, L.Country



UNION ALL

-- US and CANADA Smile Completions FROM Smile Assesment (DWCONSDL.FactAlignSAWebsite2)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Smile Completions' AS KPI
	  ,'Smile Assessment' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(1) AS KPIValue 
FROM DWCONSDL.FactAlignSAWebsite2 SA
INNER JOIN [DW].[DimDateTime] DDT ON SA.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON SA.CountryCode = GH.CountryCode
WHERE SA.CountryCode IN ('CA','US')
AND SA.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'NA' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile Assessment')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate,GH.SecRegion,GH.Country

UNION ALL

-- US Smile Completions FROM Smile Quiz (SrcNASA.smile_quizzes)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'NA' AS Region  -- Only US in this table
	  ,'United States' AS Country
	  ,'Smile Completions' AS KPI
	  ,'Smile Quiz' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcNASA.smile_quizzes SQ
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,SQ.Created_at) = DDT.DateKey
WHERE SQ.created_at IS NOT NULL
AND (SQ.source NOT IN ('Parent Share Smile Quiz') OR SQ.source IS NULL) AND SQ.Created_at >= '2017-01-01'
AND CONVERT(DATE,SQ.Created_at) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'NA' AND CountryFromHostName = 'United States' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile Quiz')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate

UNION ALL

-- CANADA Smile Completions FROM Smile Quiz (SrcLASA.smile_quizzes)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'NA' AS Region  -- Only CANADA in this table in PROD
	  ,'Canada' AS Country
	  ,'Smile Completions' AS KPI
	  ,'Smile Quiz' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcLASA.smile_quizzes SQ
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,SQ.Created_at) = DDT.DateKey
WHERE SQ.created_at IS NOT NULL
AND (SQ.source NOT IN ('Parent Share Smile Quiz') OR SQ.source IS NULL) AND SQ.Created_at >= '2017-01-01'
AND CONVERT(DATE,SQ.Created_at) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'NA' AND CountryFromHostName = 'Canada' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile Quiz')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate

UNION ALL

-- US and CANADA Smile Completions FROM Request an Appointment (DWCONSDL.FactRequestApptWebsite2)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country 
	  ,'Smile Completions' AS KPI
	  ,'Request an Appointment' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(1) AS KPIValue 
FROM DWCONSDL.FactRequestApptWebsite2 RA
INNER JOIN [DW].[DimDateTime] DDT ON RA.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON RA.CountryCode = GH.CountryCode
WHERE RA.CountryCode IN ('CA','US') AND RA.RequestApptLeadSource NOT IN ('SmileView First Step','SmileView Learn More','SmileView RequestAppt', 'Send Results_SmileView',
'Retail SmileView', 'SmileView Consumer Event')
AND RA.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'NA' AND KPI = 'Smile Completions' AND KPIDetails = 'Request an Appointment')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate,GH.SecRegion,GH.Country

UNION ALL

-- APAC Smile Completions  free assessment (Goal ID4 and GoalID6)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'APAC' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'free assessment' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,(SUM(G_ID4) + SUM(G_ID6)) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsAPACDailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'APAC' AND KPI = 'Smile Completions' AND KPIDetails = 'free assessment')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, CountryFromHostName

UNION ALL

-- APAC Smile Completions  Request an Appointment (Goal ID5 and Goal ID7)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'APAC' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'Request an Appointment' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,(SUM(G_ID5) + SUM(G_ID7)) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsAPACDailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'APAC' AND KPI = 'Smile Completions' AND KPIDetails = 'Request an Appointment')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, CountryFromHostName

UNION ALL

--------------------------------- SMILE COMPLETIONS Quarterly ----------------------------------------
-- EMEA Smile Completions  Smile Assessment (Goal ID1)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'Smile Assessment' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,SUM(G_ID1) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'EMEA' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile Assessment')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, CountryFromHostName

UNION ALL

-- EMEA Smile Completions  Smile View (Goal ID19)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'Smile View' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,SUM(G_ID19) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'EMEA' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile View')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, CountryFromHostName

UNION ALL

-- EMEA Smile Completions  Request an Appointment (Goal ID3)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'Request an Appointment' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,SUM(G_ID3) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'EMEA' AND KPI = 'Smile Completions' AND KPIDetails = 'Request an Appointment')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, CountryFromHostName

UNION ALL

-- EMEA Smile Completions  InfoKit (Adult & PoT) (Goal ID2)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'InfoKit (Adult & PoT)' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,SUM(G_ID2) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'EMEA' AND KPI = 'Smile Completions' AND KPIDetails = 'InfoKit (Adult & PoT)')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, CountryFromHostName

UNION ALL

-- EMEA Smile Completions  Request A Callback
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'Request A Callback' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,SUM(G_ID17) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsEMEADailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'EMEA' AND KPI = 'Smile Completions' AND KPIDetails = 'Request A Callback')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, CountryFromHostName

UNION ALL

-- LATAM Smile Completions  Smile Assessment
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Smile Completions' AS KPI
	  ,'Smile Assessment' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource = 'Smile Assessment' AND L.Country  IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'LATAM' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile Assessment')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, L.Country

UNION ALL

-- LATAM Smile Completions  Request Appointment
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Smile Completions' AS KPI
	  ,'Request Appointment' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource = 'Request Appointment' AND L.Country  IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'LATAM' AND KPI = 'Smile Completions' AND KPIDetails = 'Request Appointment')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, L.Country

UNION ALL

-- LATAM Smile Completions  Send Results_SmileView
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Smile Completions' AS KPI
	  ,'Send Results_SmileView' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource = 'Send Results_SmileView' AND L.Country  IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'LATAM' AND KPI = 'Smile Completions' AND KPIDetails = 'Send Results_SmileView')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, L.Country

UNION ALL

-- LATAM Smile Completions  SmileView First Step
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Smile Completions' AS KPI
	  ,'SmileView First Step' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource = 'SmileView First Step' AND L.Country  IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'LATAM' AND KPI = 'Smile Completions' AND KPIDetails = 'SmileView First Step')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, L.Country

UNION ALL

-- LATAM Smile Completions  SmileView Learn More
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Smile Completions' AS KPI
	  ,'SmileView Learn More' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource = 'SmileView Learn More' AND L.Country  IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'LATAM' AND KPI = 'Smile Completions' AND KPIDetails = 'SmileView Learn More')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, L.Country



UNION ALL

-- US and CANADA Smile Completions FROM Smile Assesment (DWCONSDL.FactAlignSAWebsite2)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Smile Completions' AS KPI
	  ,'Smile Assessment' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(1) AS KPIValue 
FROM DWCONSDL.FactAlignSAWebsite2 SA
INNER JOIN [DW].[DimDateTime] DDT ON SA.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON SA.CountryCode = GH.CountryCode
WHERE SA.CountryCode IN ('CA','US')
AND SA.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'NA' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile Assessment')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate,GH.SecRegion,GH.Country

UNION ALL

-- US Smile Completions FROM Smile Quiz (SrcNASA.smile_quizzes)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'NA' AS Region  -- Only US in this table
	  ,'United States' AS Country
	  ,'Smile Completions' AS KPI
	  ,'Smile Quiz' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcNASA.smile_quizzes SQ
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,SQ.Created_at) = DDT.DateKey
WHERE SQ.created_at IS NOT NULL
AND (SQ.source NOT IN ('Parent Share Smile Quiz') OR SQ.source IS NULL) AND SQ.Created_at >= '2017-01-01'
AND CONVERT(DATE,SQ.Created_at) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'NA' AND CountryFromHostName = 'United States' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile Quiz')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate

UNION ALL

-- CANADA Smile Completions FROM Smile Quiz (SrcLASA.smile_quizzes)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'NA' AS Region  -- Only CANADA in this table in PROD
	  ,'Canada' AS Country
	  ,'Smile Completions' AS KPI
	  ,'Smile Quiz' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcLASA.smile_quizzes SQ
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,SQ.Created_at) = DDT.DateKey
WHERE SQ.created_at IS NOT NULL
AND (SQ.source NOT IN ('Parent Share Smile Quiz') OR SQ.source IS NULL) AND SQ.Created_at >= '2017-01-01'
AND CONVERT(DATE,SQ.Created_at) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'NA' AND CountryFromHostName = 'Canada' AND KPI = 'Smile Completions' AND KPIDetails = 'Smile Quiz')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate

UNION ALL

-- US and CANADA Smile Completions FROM Request an Appointment (DWCONSDL.FactRequestApptWebsite2)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country 
	  ,'Smile Completions' AS KPI
	  ,'Request an Appointment' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(1) AS KPIValue 
FROM DWCONSDL.FactRequestApptWebsite2 RA
INNER JOIN [DW].[DimDateTime] DDT ON RA.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON RA.CountryCode = GH.CountryCode
WHERE RA.CountryCode IN ('CA','US') AND RA.RequestApptLeadSource NOT IN ('SmileView First Step','SmileView Learn More','SmileView RequestAppt', 'Send Results_SmileView',
'Retail SmileView', 'SmileView Consumer Event')
AND RA.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'NA' AND KPI = 'Smile Completions' AND KPIDetails = 'Request an Appointment')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate,GH.SecRegion,GH.Country

UNION ALL

-- APAC Smile Completions  free assessment (Goal ID4 and GoalID6)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'APAC' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'free assessment' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,(SUM(G_ID4) + SUM(G_ID6)) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsAPACDailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'APAC' AND KPI = 'Smile Completions' AND KPIDetails = 'free assessment')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, CountryFromHostName

UNION ALL

-- APAC Smile Completions  Request an Appointment (Goal ID5 and Goal ID7)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'APAC' AS Region
	  ,CountryFromHostName
	  ,'Smile Completions' AS KPI
	  ,'Request an Appointment' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,(SUM(G_ID5) + SUM(G_ID7)) AS KPIValue
FROM [DWCONSDL].[FactGAGoalsAPACDailyC] FG 
INNER JOIN [DW].[DimDateTime] DDT ON FG.VisitDate = DDT.DateKey
WHERE FG.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'APAC' AND KPI = 'Smile Completions' AND KPIDetails = 'Request an Appointment')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, CountryFromHostName

UNION ALL

---------------------------------------------------- Lead (Opt-ins) Monthly-------------------------------------------------------

-- US and CANADA Leads (Opt-ins) FROM Smile Assessment (DWCONSDL.FactAlignSAWebsite2)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country 
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Smile Assessment' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(CASE WHEN IsOptIn = 'Yes' THEN 1 ELSE NULL END) AS KPIValue 
FROM DWCONSDL.FactAlignSAWebsite2 SA
INNER JOIN [DW].[DimDateTime] DDT ON SA.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON SA.CountryCode = GH.CountryCode
WHERE SA.CountryCode IN ('CA','US')
AND SA.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'NA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Smile Assessment')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate,GH.SecRegion,GH.Country

UNION ALL

-- US Leads (Opt-ins) FROM Smile Quiz (SrcNASA.smile_quizzes)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'NA' AS Region  -- Only US in this table
	  ,'United States' AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Smile Quiz' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,SUM(CASE WHEN Opt_In IS NULL THEN 0 ELSE Opt_In END) AS KPIValue 
FROM SrcNASA.smile_quizzes SQ
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,SQ.Created_at) = DDT.DateKey
WHERE SQ.created_at IS NOT NULL
AND (SQ.source NOT IN ('Parent Share Smile Quiz') OR SQ.source IS NULL) AND SQ.Created_at >= '2017-01-01'
AND CONVERT(DATE,SQ.Created_at) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'NA' AND CountryFromHostName = 'United States' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Smile Quiz')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate

UNION ALL

-- US and CANADA Leads (Opt-ins) FROM Request an Appointment  (DWCONSDL.FactRequestApptWebsite2)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Request an Appointment' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(CASE WHEN IsOptIn = 'Yes' THEN 1 ELSE NULL END) AS KPIValue 
FROM DWCONSDL.FactRequestApptWebsite2 RA
INNER JOIN [DW].[DimDateTime] DDT ON RA.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON RA.CountryCode = GH.CountryCode
WHERE RA.CountryCode IN ('CA','US') AND RA.RequestApptLeadSource NOT IN ('SmileView First Step','SmileView Learn More','SmileView RequestAppt', 'Send Results_SmileView',
'Retail SmileView', 'SmileView Consumer Event')
AND RA.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'NA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Request an Appointment')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate,GH.SecRegion,GH.Country

UNION ALL

-- US and CANADA Leads (Opt-ins) FROM Doc Locator (DWCONSDL.FactAlignDocLoc)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Doc Locator' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(OptIns) AS KPIValue 
FROM DWCONSDL.FactAlignDocLoc DL
INNER JOIN [DW].[DimDateTime] DDT ON DL.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON DL.CountryCode = GH.CountryCode
WHERE DL.CountryCode IN ('CA','US') AND DL.Source IN ('Doc Locator','Request Appointment')
AND DL.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'NA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Doc Locator')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate,GH.SecRegion,GH.Country

UNION ALL

-- NA (US and CANADA) Leads (Opt-ins) FROM SmileView (DWCONSDL.FactAlignDocLoc)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'SmileView' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(OptIns) AS KPIValue 
FROM DWCONSDL.FactAlignDocLoc DL
INNER JOIN [DW].[DimDateTime] DDT ON DL.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON DL.CountryCode = GH.CountryCode
WHERE DL.CountryCode IN ('CA','US') AND Source IN ('SmileView First Step','SmileView Learn More','SmileView RequestAppt', 'Send Results_SmileView',
'Retail SmileView', 'SmileView Consumer Event')
AND DL.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'NA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'SmileView')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate,GH.SecRegion,GH.Country

UNION ALL

-- NA (US and CANADA) Leads (Opt-ins) - Other (DWCONSDL.FactAlignDocLoc)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Other' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(OptIns) AS KPIValue 
FROM DWCONSDL.FactAlignDocLoc DL
INNER JOIN [DW].[DimDateTime] DDT ON DL.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON DL.CountryCode = GH.CountryCode
WHERE DL.CountryCode IN ('CA','US') AND Source NOT IN ('Doc Locator','Request Appointment','SmileView First Step','SmileView Learn More','SmileView RequestAppt', 'Send Results_SmileView',
'Retail SmileView', 'SmileView Consumer Event')
AND DL.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'NA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Other')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate,GH.SecRegion,GH.Country


UNION ALL

-- LATAM Leads (Opt-ins) FROM SmileView (DWCONSDL.FactAlignDocLoc)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,GH.Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'SmileView' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(OptIns) AS KPIValue 
FROM DWCONSDL.FactAlignDocLoc DL
INNER JOIN [DW].[DimDateTime] DDT ON DL.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON DL.CountryCode = GH.CountryCode
WHERE GH.SecRegion = 'LATAM' AND Source IN ('SmileView First Step','SmileView Learn More','SmileView RequestAppt', 'Send Results_SmileView',
'Retail SmileView', 'SmileView Consumer Event')
AND DL.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'LATAM' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'SmileView')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate,GH.SecRegion,GH.Country

UNION ALL

-- LATAM Leads (Opt-ins)
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Leads (Opt-ins)' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource != 'SmileView (In Office)' AND L.Country IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'LATAM' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Leads (Opt-ins)')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, L.Country

UNION ALL

-- EMEA Leads (Opt-ins)
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CASE WHEN L.Country IS NULL THEN 'Rest of EMEA' ELSE L.Country END AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Leads (Opt-ins)' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE L.Lead_Region__c ='EUROPE' AND RT.Name = 'Consumer' AND L.OwnerId <> '005i000000923svAAA' 
AND NOT (L.Unsubscribe__c = 1 AND et4ae5__HasOptedOutOfMobile__c = 1)
AND  CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'EMEA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Leads (Opt-ins)')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, L.Country

UNION ALL

-- APAC Leads (Opt-ins) FROM SmileView (SrcSFDC.LEAD)
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'APAC' AS Region
	  ,L.Country AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'SmileView' AS KPIDetails
	  ,'Monthly' AS Level
	  ,DDT.MonthStartDate
	  ,DDT.MonthEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer'  AND Lead_Region__c LIKE 'APAC%'
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Monthly' AND Region = 'APAC' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'SmileView')
GROUP BY DDT.MonthStartDate,DDT.MonthEndDate, L.Country

UNION ALL

---------------------------------------------------- Lead (Opt-ins) Weekly-------------------------------------------------------

-- US and CANADA Leads (Opt-ins) FROM Smile Assessment (DWCONSDL.FactAlignSAWebsite2)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country 
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Smile Assessment' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(CASE WHEN IsOptIn = 'Yes' THEN 1 ELSE NULL END) AS KPIValue 
FROM DWCONSDL.FactAlignSAWebsite2 SA
INNER JOIN [DW].[DimDateTime] DDT ON SA.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON SA.CountryCode = GH.CountryCode
WHERE SA.CountryCode IN ('CA','US')
AND SA.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'NA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Smile Assessment')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate,GH.SecRegion,GH.Country

UNION ALL

-- US Leads (Opt-ins) FROM Smile Quiz (SrcNASA.smile_quizzes)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'NA' AS Region  -- Only US in this table
	  ,'United States' AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Smile Quiz' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,SUM(CASE WHEN Opt_In IS NULL THEN 0 ELSE Opt_In END) AS KPIValue 
FROM SrcNASA.smile_quizzes SQ
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,SQ.Created_at) = DDT.DateKey
WHERE SQ.created_at IS NOT NULL
AND (SQ.source NOT IN ('Parent Share Smile Quiz') OR SQ.source IS NULL) AND SQ.Created_at >= '2017-01-01'
AND CONVERT(DATE,SQ.Created_at) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'NA' AND CountryFromHostName = 'United States' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Smile Quiz')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate

UNION ALL

-- US and CANADA Leads (Opt-ins) FROM Request an Appointment  (DWCONSDL.FactRequestApptWebsite2)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Request an Appointment' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(CASE WHEN IsOptIn = 'Yes' THEN 1 ELSE NULL END) AS KPIValue 
FROM DWCONSDL.FactRequestApptWebsite2 RA
INNER JOIN [DW].[DimDateTime] DDT ON RA.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON RA.CountryCode = GH.CountryCode
WHERE RA.CountryCode IN ('CA','US') AND RA.RequestApptLeadSource NOT IN ('SmileView First Step','SmileView Learn More','SmileView RequestAppt', 'Send Results_SmileView',
'Retail SmileView', 'SmileView Consumer Event')
AND RA.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'NA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Request an Appointment')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate,GH.SecRegion,GH.Country

UNION ALL

-- US and CANADA Leads (Opt-ins) FROM Doc Locator (DWCONSDL.FactAlignDocLoc)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Doc Locator' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(OptIns) AS KPIValue 
FROM DWCONSDL.FactAlignDocLoc DL
INNER JOIN [DW].[DimDateTime] DDT ON DL.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON DL.CountryCode = GH.CountryCode
WHERE DL.CountryCode IN ('CA','US') AND DL.Source IN ('Doc Locator','Request Appointment')
AND DL.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'NA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Doc Locator')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate,GH.SecRegion,GH.Country

UNION ALL

-- NA (US and CANADA) Leads (Opt-ins) FROM SmileView (DWCONSDL.FactAlignDocLoc)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'SmileView' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(OptIns) AS KPIValue 
FROM DWCONSDL.FactAlignDocLoc DL
INNER JOIN [DW].[DimDateTime] DDT ON DL.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON DL.CountryCode = GH.CountryCode
WHERE DL.CountryCode IN ('CA','US') AND Source IN ('SmileView First Step','SmileView Learn More','SmileView RequestAppt', 'Send Results_SmileView',
'Retail SmileView', 'SmileView Consumer Event')
AND DL.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'NA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'SmileView')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate,GH.SecRegion,GH.Country

UNION ALL

-- NA (US and CANADA) Leads (Opt-ins) - Other (DWCONSDL.FactAlignDocLoc)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Other' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(OptIns) AS KPIValue 
FROM DWCONSDL.FactAlignDocLoc DL
INNER JOIN [DW].[DimDateTime] DDT ON DL.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON DL.CountryCode = GH.CountryCode
WHERE DL.CountryCode IN ('CA','US') AND Source NOT IN ('Doc Locator','Request Appointment','SmileView First Step','SmileView Learn More','SmileView RequestAppt', 'Send Results_SmileView',
'Retail SmileView', 'SmileView Consumer Event')
AND DL.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'NA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Other')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate,GH.SecRegion,GH.Country

UNION ALL

-- LATAM Leads (Opt-ins) FROM SmileView (DWCONSDL.FactAlignDocLoc)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,GH.Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'SmileView' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(OptIns) AS KPIValue 
FROM DWCONSDL.FactAlignDocLoc DL
INNER JOIN [DW].[DimDateTime] DDT ON DL.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON DL.CountryCode = GH.CountryCode
WHERE GH.SecRegion = 'LATAM' AND Source IN ('SmileView First Step','SmileView Learn More','SmileView RequestAppt', 'Send Results_SmileView',
'Retail SmileView', 'SmileView Consumer Event')
AND DL.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'LATAM' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'SmileView')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate,GH.SecRegion,GH.Country

UNION ALL

-- LATAM Leads (Opt-ins)
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Leads (Opt-ins)' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource != 'SmileView (In Office)' AND L.Country IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'LATAM' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Leads (Opt-ins)')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, L.Country

UNION ALL

-- APAC Leads (Opt-ins) FROM SmileView (SrcSFDC.LEAD)
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'APAC' AS Region
	  ,L.Country AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'SmileView' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer'  AND Lead_Region__c LIKE 'APAC%'
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'APAC' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'SmileView')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, L.Country

UNION ALL

-- EMEA Leads (Opt-ins)
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CASE WHEN L.Country IS NULL THEN 'Rest of EMEA' ELSE L.Country END AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Leads (Opt-ins)' AS KPIDetails
	  ,'Weekly' AS Level
	  ,DDT.CalYWeekStartDate
	  ,DDT.CalYWeekEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE L.Lead_Region__c ='EUROPE' AND RT.Name = 'Consumer' AND L.OwnerId <> '005i000000923svAAA' 
AND NOT (L.Unsubscribe__c = 1 AND et4ae5__HasOptedOutOfMobile__c = 1)
AND  CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Weekly' AND Region = 'EMEA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Leads (Opt-ins)')
GROUP BY DDT.CalYWeekStartDate,DDT.CalYWeekEndDate, L.Country

UNION ALL

---------------------------------------------------- Lead (Opt-ins) Quarterly-------------------------------------------------------

-- US and CANADA Leads (Opt-ins) FROM Smile Assessment (DWCONSDL.FactAlignSAWebsite2)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country 
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Smile Assessment' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(CASE WHEN IsOptIn = 'Yes' THEN 1 ELSE NULL END) AS KPIValue 
FROM DWCONSDL.FactAlignSAWebsite2 SA
INNER JOIN [DW].[DimDateTime] DDT ON SA.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON SA.CountryCode = GH.CountryCode
WHERE SA.CountryCode IN ('CA','US')
AND SA.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'NA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Smile Assessment')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate,GH.SecRegion,GH.Country

UNION ALL

-- US Leads (Opt-ins) FROM Smile Quiz (SrcNASA.smile_quizzes)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,'NA' AS Region  -- Only US in this table
	  ,'United States' AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Smile Quiz' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,SUM(CASE WHEN Opt_In IS NULL THEN 0 ELSE Opt_In END) AS KPIValue 
FROM SrcNASA.smile_quizzes SQ
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,SQ.Created_at) = DDT.DateKey
WHERE SQ.created_at IS NOT NULL
AND (SQ.source NOT IN ('Parent Share Smile Quiz') OR SQ.source IS NULL) AND SQ.Created_at >= '2017-01-01'
AND CONVERT(DATE,SQ.Created_at) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'NA' AND CountryFromHostName = 'United States' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Smile Quiz')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate

UNION ALL

-- US and CANADA Leads (Opt-ins) FROM Request an Appointment  (DWCONSDL.FactRequestApptWebsite2)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Request an Appointment' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(CASE WHEN IsOptIn = 'Yes' THEN 1 ELSE NULL END) AS KPIValue 
FROM DWCONSDL.FactRequestApptWebsite2 RA
INNER JOIN [DW].[DimDateTime] DDT ON RA.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON RA.CountryCode = GH.CountryCode
WHERE RA.CountryCode IN ('CA','US') AND RA.RequestApptLeadSource NOT IN ('SmileView First Step','SmileView Learn More','SmileView RequestAppt', 'Send Results_SmileView',
'Retail SmileView', 'SmileView Consumer Event')
AND RA.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'NA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Request an Appointment')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate,GH.SecRegion,GH.Country

UNION ALL

-- US and CANADA Leads (Opt-ins) FROM Doc Locator (DWCONSDL.FactAlignDocLoc)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Doc Locator' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(OptIns) AS KPIValue 
FROM DWCONSDL.FactAlignDocLoc DL
INNER JOIN [DW].[DimDateTime] DDT ON DL.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON DL.CountryCode = GH.CountryCode
WHERE DL.CountryCode IN ('CA','US') AND DL.Source IN ('Doc Locator','Request Appointment')
AND DL.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'NA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Doc Locator')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate,GH.SecRegion,GH.Country

UNION ALL

-- NA (US and CANADA) Leads (Opt-ins) FROM SmileView (DWCONSDL.FactAlignDocLoc)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'SmileView' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(OptIns) AS KPIValue 
FROM DWCONSDL.FactAlignDocLoc DL
INNER JOIN [DW].[DimDateTime] DDT ON DL.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON DL.CountryCode = GH.CountryCode
WHERE DL.CountryCode IN ('CA','US') AND Source IN ('SmileView First Step','SmileView Learn More','SmileView RequestAppt', 'Send Results_SmileView',
'Retail SmileView', 'SmileView Consumer Event')
AND DL.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'NA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'SmileView')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate,GH.SecRegion,GH.Country

UNION ALL

-- NA (US and CANADA) Leads (Opt-ins) - Other (DWCONSDL.FactAlignDocLoc)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,CASE WHEN GH.Country = 'U.S.A' THEN 'United States' ELSE GH.Country END AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Other' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(OptIns) AS KPIValue 
FROM DWCONSDL.FactAlignDocLoc DL
INNER JOIN [DW].[DimDateTime] DDT ON DL.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON DL.CountryCode = GH.CountryCode
WHERE DL.CountryCode IN ('CA','US') AND Source NOT IN ('Doc Locator','Request Appointment','SmileView First Step','SmileView Learn More','SmileView RequestAppt', 'Send Results_SmileView',
'Retail SmileView', 'SmileView Consumer Event')
AND DL.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'NA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Other')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate,GH.SecRegion,GH.Country


UNION ALL

-- LATAM Leads (Opt-ins) FROM SmileView (DWCONSDL.FactAlignDocLoc)
SELECT CONVERT(CHAR(40), '') AS DWHashKey
	  ,GH.SecRegion AS Region
	  ,GH.Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'SmileView' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(OptIns) AS KPIValue 
FROM DWCONSDL.FactAlignDocLoc DL
INNER JOIN [DW].[DimDateTime] DDT ON DL.DateKey = DDT.DateKey
INNER JOIN [Custom].[GeographyHierarchy] GH ON DL.CountryCode = GH.CountryCode
WHERE GH.SecRegion = 'LATAM' AND Source IN ('SmileView First Step','SmileView Learn More','SmileView RequestAppt', 'Send Results_SmileView',
'Retail SmileView', 'SmileView Consumer Event')
AND DL.DateKey >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'LATAM' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'SmileView')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate,GH.SecRegion,GH.Country

UNION ALL

-- LATAM Leads (Opt-ins)
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'LATAM' AS Region
	  ,L.Country AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Leads (Opt-ins)' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer' AND L.LeadSource != 'SmileView (In Office)' AND L.Country IN ('Argentina','Bolivia','Brazil','Cayman Islands','Chile',
'Colombia','Costa Rica','Dominican Republic','Ecuador','El Salvador','French Guiana','Grenada','Guadeloupe','Guatemala','Guyana','Honduras',
'Jamaica','Martinique','Mexico','Nicaragua','Panama','Paraguay','Peru','Saint Barthelemy','Saint Kitts and Nevis','Trinidad and Tobago','Uruguay','Venezuela')
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'LATAM' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Leads (Opt-ins)')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, L.Country

UNION ALL

SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'EMEA' AS Region
	  ,CASE WHEN L.Country IS NULL THEN 'Rest of EMEA' ELSE L.Country END AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'Leads (Opt-ins)' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE L.Lead_Region__c ='EUROPE' AND RT.Name = 'Consumer' AND L.OwnerId <> '005i000000923svAAA' 
AND NOT (L.Unsubscribe__c = 1 AND et4ae5__HasOptedOutOfMobile__c = 1)
AND  CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'EMEA' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'Leads (Opt-ins)')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, L.Country

UNION ALL

-- APAC Leads (Opt-ins) FROM SmileView (SrcSFDC.LEAD)
SELECT  CONVERT(CHAR(40), '') AS DWHashKey
	  ,'APAC' AS Region
	  ,L.Country AS Country
	  ,'Leads (Opt-ins)' AS KPI
	  ,'SmileView' AS KPIDetails
	  ,'Quarterly' AS Level
	  ,DDT.QuarterStartDate
	  ,DDT.QuarterEndDate
	  ,COUNT(1) AS KPIValue 
FROM SrcSFDC.LEAD L
INNER JOIN SrcSFDC.RecordType RT ON L.RecordTypeId = RT.Id
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE,L.Created_Date_Time__c) = DDT.DateKey
WHERE RT.Name = 'Consumer'  AND Lead_Region__c LIKE 'APAC%'
AND CONVERT(DATE,L.Created_Date_Time__c) >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactConsdlKPIConsolidated]
WHERE Level = 'Quarterly' AND Region = 'APAC' AND KPI = 'Leads (Opt-ins)' AND KPIDetails = 'SmileView')
GROUP BY DDT.QuarterStartDate,DDT.QuarterEndDate, L.Country;

update #TempFactConsdlKPIConsolidated set DWHashKey=
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, [Level]), N'N/A')
				  + N'|' + isnull(convert(nvarchar, StartDate), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Region), N'N/A')
				  + N'|' + isnull(convert(nvarchar, CountryFromHostName), N'N/A')
				  + N'|' + isnull(convert(nvarchar, KPI), N'N/A')
				  + N'|' + isnull(convert(nvarchar, KPIDetails), N'N/A')
				)
			, 2)

	
	update DWCONSDL.FactConsdlKPIConsolidated
		set	DWBatchID 				= 			@BatchID
		,	KPIValue				=			src.KPIValue
		,	ModifiedDate			=			@CurrentDateTime
	from #TempFactConsdlKPIConsolidated src
	where DWCONSDL.FactConsdlKPIConsolidated.DWHashKey = src.DWHashKey
		and (DWCONSDL.FactConsdlKPIConsolidated.KPIValue != src.KPIValue)
	option (label = 'DWCONSDL.LoadFactConsdlKPIConsolidated_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactConsdlKPIConsolidated_Update', @rc = @RowsUpdated out

	insert into DWCONSDL.FactConsdlKPIConsolidated (
			DWBatchID
		,	DWHashKey
		,	Region
		,	CountryFromHostName
		,	KPI
		,	KPIDetails	
		,	[Level]	
		,	StartDate
		,	EndDate
		,	KPIValue
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	DWHashKey
		,	Region
		,	CountryFromHostName
		,	KPI
		,	KPIDetails	
		,	[Level]	
		,	StartDate
		,	EndDate
		,	KPIValue
		,	@CurrentDateTime
		,	@CurrentDateTime
	from #TempFactConsdlKPIConsolidated src
	where not exists(select * from DWCONSDL.FactConsdlKPIConsolidated dst where dst.DWHashKey = src.DWHashKey)
	option (label = 'DWCONSDL.LoadFactConsdlKPIConsolidated_Insert');
	
	UPDATE STATISTICS [DWCONSDL].[FactConsdlKPIConsolidated] (STATS_DWCONSDL_FactConsdlKPIConsolidated_DWHashKey);
	UPDATE STATISTICS [DWCONSDL].[FactConsdlKPIConsolidated] (STATS_DWCONSDL_FactConsdlKPIConsolidated_StartDate);
	UPDATE STATISTICS [DWCONSDL].[FactConsdlKPIConsolidated] (STATS_DWCONSDL_FactConsdlKPIConsolidated_Level);
	UPDATE STATISTICS [DWCONSDL].[FactConsdlKPIConsolidated] (STATS_DWCONSDL_FactConsdlKPIConsolidated_Region);
	UPDATE STATISTICS [DWCONSDL].[FactConsdlKPIConsolidated] (STATS_DWCONSDL_FactConsdlKPIConsolidated_KPI);

	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactConsdlKPIConsolidated_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end