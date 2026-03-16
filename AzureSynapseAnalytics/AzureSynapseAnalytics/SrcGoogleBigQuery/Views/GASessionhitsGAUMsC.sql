CREATE VIEW [SrcGoogleBigQuery].[GASessionhitsGAUMsC]
AS 
-- For CANADA Region
SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Daily' AS [Level]
			,	'CANADA' AS Region
			,	CONVERT(DATE, SHC.VisitDate) AS StartDate
			,	CONVERT(DATE, SHC.VisitDate) AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of CANADA' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_CANADA] SHC
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'CANADA' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'CANADA' and [Level] = 'Daily' )
GROUP BY CONVERT(DATE, SHC.VisitDate), CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Weekly' AS [Level]
			,	'CANADA' AS Region
			,	DDT.CalYWeekStartDate AS StartDate
			,	DDT.CalYWeekEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of CANADA' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_CANADA] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'CANADA' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'CANADA' and [Level] = 'Weekly' )
GROUP BY DDT.CalYWeekStartDate, DDT.CalYWeekEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Monthly' AS [Level]
			,	'CANADA' AS Region
			,	DDT.MonthStartDate AS StartDate
			,	DDT.MonthEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of CANADA' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_CANADA] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'CANADA' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'CANADA' and [Level] = 'Monthly' )
GROUP BY DDT.MonthStartDate, DDT.MonthEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Quarterly' AS [Level]
			,	'CANADA' AS Region
			,	DDT.QuarterStartDate AS StartDate
			,	DDT.QuarterEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of CANADA' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_CANADA] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'CANADA' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'CANADA' and [Level] = 'Quarterly' )
GROUP BY DDT.QuarterStartDate, DDT.QuarterEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Yearly' AS [Level]
			,	'CANADA' AS Region
			,	DATEFROMPARTS([DDT].[YEAR], 1, 1) AS StartDate
			,	DATEFROMPARTS([DDT].[YEAR], 12, 31) AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of CANADA' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_CANADA] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'CANADA' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'CANADA' and [Level] = 'Yearly' )
GROUP BY [DDT].[Year], CM.CountryFromHostName

-- For EMEA Region
UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Daily' AS [Level]
			,	'EMEA' AS Region
			,	CONVERT(DATE, SHC.VisitDate) AS StartDate
			,	CONVERT(DATE, SHC.VisitDate) AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of EMEA' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_EMEA] SHC
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'EMEA' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'EMEA' and [Level] = 'Daily' )
GROUP BY CONVERT(DATE, SHC.VisitDate), CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Weekly' AS [Level]
			,	'EMEA' AS Region
			,	DDT.CalYWeekStartDate AS StartDate
			,	DDT.CalYWeekEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of EMEA' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_EMEA] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'EMEA' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'EMEA' and [Level] = 'Weekly' )
GROUP BY DDT.CalYWeekStartDate, DDT.CalYWeekEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Monthly' AS [Level]
			,	'EMEA' AS Region
			,	DDT.MonthStartDate AS StartDate
			,	DDT.MonthEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of EMEA' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_EMEA] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'EMEA' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'EMEA' and [Level] = 'Monthly' )
GROUP BY DDT.MonthStartDate, DDT.MonthEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Quarterly' AS [Level]
			,	'EMEA' AS Region
			,	DDT.QuarterStartDate AS StartDate
			,	DDT.QuarterEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of EMEA' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_EMEA] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'EMEA' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'EMEA' and [Level] = 'Quarterly' )
GROUP BY DDT.QuarterStartDate, DDT.QuarterEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Yearly' AS [Level]
			,	'EMEA' AS Region
			,	DATEFROMPARTS([DDT].[YEAR], 1, 1) AS StartDate
			,	DATEFROMPARTS([DDT].[YEAR], 12, 31) AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of EMEA' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_EMEA] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'EMEA' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'EMEA' and [Level] = 'Yearly' )
GROUP BY [DDT].[Year], CM.CountryFromHostName

-- For US Region
UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Daily' AS [Level]
			,	'US' AS Region
			,	CONVERT(DATE, SHC.VisitDate) AS StartDate
			,	CONVERT(DATE, SHC.VisitDate) AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of US' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_US] SHC
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'US' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'US' and [Level] = 'Daily' )
GROUP BY CONVERT(DATE, SHC.VisitDate), CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Weekly' AS [Level]
			,	'US' AS Region
			,	DDT.CalYWeekStartDate AS StartDate
			,	DDT.CalYWeekEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of US' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_US] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'US' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'US' and [Level] = 'Weekly' )
GROUP BY DDT.CalYWeekStartDate, DDT.CalYWeekEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Monthly' AS [Level]
			,	'US' AS Region
			,	DDT.MonthStartDate AS StartDate
			,	DDT.MonthEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of US' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_US] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'US' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'US' and [Level] = 'Monthly' )
GROUP BY DDT.MonthStartDate, DDT.MonthEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Quarterly' AS [Level]
			,	'US' AS Region
			,	DDT.QuarterStartDate AS StartDate
			,	DDT.QuarterEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of US' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_US] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'US' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'US' and [Level] = 'Quarterly' )
GROUP BY DDT.QuarterStartDate, DDT.QuarterEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Yearly' AS [Level]
			,	'US' AS Region
			,	DATEFROMPARTS([DDT].[YEAR], 1, 1) AS StartDate
			,	DATEFROMPARTS([DDT].[YEAR], 12, 31) AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of US' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_US] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'US' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'US' and [Level] = 'Yearly' )
GROUP BY [DDT].[Year], CM.CountryFromHostName


-- For BRAZIL Region
UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Daily' AS [Level]
			,	'BRAZIL' AS Region
			,	CONVERT(DATE, SHC.VisitDate) AS StartDate
			,	CONVERT(DATE, SHC.VisitDate) AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of BRAZIL' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_BRAZIL] SHC
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'BRAZIL' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'BRAZIL' and [Level] = 'Daily' )
GROUP BY CONVERT(DATE, SHC.VisitDate), CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Weekly' AS [Level]
			,	'BRAZIL' AS Region
			,	DDT.CalYWeekStartDate AS StartDate
			,	DDT.CalYWeekEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of BRAZIL' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_BRAZIL] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'BRAZIL' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'BRAZIL' and [Level] = 'Weekly' )
GROUP BY DDT.CalYWeekStartDate, DDT.CalYWeekEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Monthly' AS [Level]
			,	'BRAZIL' AS Region
			,	DDT.MonthStartDate AS StartDate
			,	DDT.MonthEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of BRAZIL' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_BRAZIL] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'BRAZIL' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'BRAZIL' and [Level] = 'Monthly' )
GROUP BY DDT.MonthStartDate, DDT.MonthEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Quarterly' AS [Level]
			,	'BRAZIL' AS Region
			,	DDT.QuarterStartDate AS StartDate
			,	DDT.QuarterEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of BRAZIL' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_BRAZIL] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'BRAZIL' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'BRAZIL' and [Level] = 'Quarterly' )
GROUP BY DDT.QuarterStartDate, DDT.QuarterEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Yearly' AS [Level]
			,	'BRAZIL' AS Region
			,	DATEFROMPARTS([DDT].[YEAR], 1, 1) AS StartDate
			,	DATEFROMPARTS([DDT].[YEAR], 12, 31) AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of BRAZIL' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_BRAZIL] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'BRAZIL' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'BRAZIL' and [Level] = 'Yearly' )
GROUP BY [DDT].[Year], CM.CountryFromHostName

UNION ALL
-- For APAC Region

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Daily' AS [Level]
			,	'APAC' AS Region
			,	CONVERT(DATE, SHC.VisitDate) AS StartDate
			,	CONVERT(DATE, SHC.VisitDate) AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of APAC' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_APAC] SHC
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'APAC' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'APAC' and [Level] = 'Daily' )
GROUP BY CONVERT(DATE, SHC.VisitDate), CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Weekly' AS [Level]
			,	'APAC' AS Region
			,	DDT.CalYWeekStartDate AS StartDate
			,	DDT.CalYWeekEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of APAC' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_APAC] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'APAC' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'APAC' and [Level] = 'Weekly' )
GROUP BY DDT.CalYWeekStartDate, DDT.CalYWeekEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Monthly' AS [Level]
			,	'APAC' AS Region
			,	DDT.MonthStartDate AS StartDate
			,	DDT.MonthEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of APAC' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_APAC] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'APAC' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'APAC' and [Level] = 'Monthly' )
GROUP BY DDT.MonthStartDate, DDT.MonthEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Quarterly' AS [Level]
			,	'APAC' AS Region
			,	DDT.QuarterStartDate AS StartDate
			,	DDT.QuarterEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of APAC' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_APAC] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'APAC' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'APAC' and [Level] = 'Quarterly' )
GROUP BY DDT.QuarterStartDate, DDT.QuarterEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Yearly' AS [Level]
			,	'APAC' AS Region
			,	DATEFROMPARTS([DDT].[YEAR], 1, 1) AS StartDate
			,	DATEFROMPARTS([DDT].[YEAR], 12, 31) AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of APAC' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_APAC] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'APAC' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'APAC' and [Level] = 'Yearly' )
GROUP BY [DDT].[Year], CM.CountryFromHostName

UNION ALL
-- For LATAM Region

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Daily' AS [Level]
			,	'LATAM' AS Region
			,	CONVERT(DATE, SHC.VisitDate) AS StartDate
			,	CONVERT(DATE, SHC.VisitDate) AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of LATAM' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_LATAM] SHC
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'LATAM' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'LATAM' and [Level] = 'Daily' )
GROUP BY CONVERT(DATE, SHC.VisitDate), CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Weekly' AS [Level]
			,	'LATAM' AS Region
			,	DDT.CalYWeekStartDate AS StartDate
			,	DDT.CalYWeekEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of LATAM' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_LATAM] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'LATAM' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'LATAM' and [Level] = 'Weekly' )
GROUP BY DDT.CalYWeekStartDate, DDT.CalYWeekEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Monthly' AS [Level]
			,	'LATAM' AS Region
			,	DDT.MonthStartDate AS StartDate
			,	DDT.MonthEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of LATAM' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_LATAM] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'LATAM' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'LATAM' and [Level] = 'Monthly' )
GROUP BY DDT.MonthStartDate, DDT.MonthEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Quarterly' AS [Level]
			,	'LATAM' AS Region
			,	DDT.QuarterStartDate AS StartDate
			,	DDT.QuarterEndDate AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of LATAM' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_LATAM] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'LATAM' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'LATAM' and [Level] = 'Quarterly' )
GROUP BY DDT.QuarterStartDate, DDT.QuarterEndDate, CM.CountryFromHostName

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Yearly' AS [Level]
			,	'LATAM' AS Region
			,	DATEFROMPARTS([DDT].[YEAR], 1, 1) AS StartDate
			,	DATEFROMPARTS([DDT].[YEAR], 12, 31) AS EndDate
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of LATAM' END AS CountryFromHostName
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_LATAM] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON CM.HostName = SHC.HostName AND CM.GARegion = 'LATAM' AND CM.IsValid = 1
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') from [DWCONSDL].[FactGAUMsC] WHERE Region = 'LATAM' and [Level] = 'Yearly' )
GROUP BY [DDT].[Year], CM.CountryFromHostName;

