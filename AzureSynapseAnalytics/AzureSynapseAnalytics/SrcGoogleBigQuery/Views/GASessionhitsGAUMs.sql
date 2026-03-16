CREATE VIEW [SrcGoogleBigQuery].[GASessionhitsGAUMs]
AS SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Daily' AS [Level]
			,	'CANADA' AS Region
			,	CONVERT(DATE, SHC.VisitDate) AS StartDate
			,	CONVERT(DATE, SHC.VisitDate) AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_CANADA] SHC
WHERE VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'CANADA' and [Level] = 'Daily' )
GROUP BY CONVERT(DATE, SHC.VisitDate)

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Weekly' AS [Level]
			,	'CANADA' AS Region
			,	DDT.CalYWeekStartDate AS StartDate
			,	DDT.CalYWeekEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_CANADA] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'CANADA' and [Level] = 'Weekly' )
GROUP BY DDT.CalYWeekStartDate, DDT.CalYWeekEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Monthly' AS [Level]
			,	'CANADA' AS Region
			,	DDT.MonthStartDate AS StartDate
			,	DDT.MonthEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_CANADA] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'CANADA' and [Level] = 'Monthly' )
GROUP BY DDT.MonthStartDate, DDT.MonthEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Quarterly' AS [Level]
			,	'CANADA' AS Region
			,	DDT.QuarterStartDate AS StartDate
			,	DDT.QuarterEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_CANADA] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'CANADA' and [Level] = 'Quarterly' )
GROUP BY DDT.QuarterStartDate, DDT.QuarterEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Yearly' AS [Level]
			,	'CANADA' AS Region
			,	DATEFROMPARTS([DDT].[YEAR], 1, 1) AS StartDate
			,	DATEFROMPARTS([DDT].[YEAR], 12, 31) AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_CANADA] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'CANADA' and [Level] = 'Yearly' )
GROUP BY [DDT].[Year]

-- For EMEA Region
UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Daily' AS [Level]
			,	'EMEA' AS Region
			,	CONVERT(DATE, SHC.VisitDate) AS StartDate
			,	CONVERT(DATE, SHC.VisitDate) AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_EMEA] SHC
WHERE VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'EMEA' and [Level] = 'Daily' )
GROUP BY CONVERT(DATE, SHC.VisitDate)

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Weekly' AS [Level]
			,	'EMEA' AS Region
			,	DDT.CalYWeekStartDate AS StartDate
			,	DDT.CalYWeekEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_EMEA] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'EMEA' and [Level] = 'Weekly' )
GROUP BY DDT.CalYWeekStartDate, DDT.CalYWeekEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Monthly' AS [Level]
			,	'EMEA' AS Region
			,	DDT.MonthStartDate AS StartDate
			,	DDT.MonthEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_EMEA] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'EMEA' and [Level] = 'Monthly' )
GROUP BY DDT.MonthStartDate, DDT.MonthEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Quarterly' AS [Level]
			,	'EMEA' AS Region
			,	DDT.QuarterStartDate AS StartDate
			,	DDT.QuarterEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_EMEA] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'EMEA' and [Level] = 'Quarterly' )
GROUP BY DDT.QuarterStartDate, DDT.QuarterEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Yearly' AS [Level]
			,	'EMEA' AS Region
			,	DATEFROMPARTS([DDT].[YEAR], 1, 1) AS StartDate
			,	DATEFROMPARTS([DDT].[YEAR], 12, 31) AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_EMEA] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'EMEA' and [Level] = 'Yearly' )
GROUP BY [DDT].[Year]

-- For US Region
UNION ALL



SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Daily' AS [Level]
			,	'US' AS Region
			,	CONVERT(DATE, SHC.VisitDate) AS StartDate
			,	CONVERT(DATE, SHC.VisitDate) AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_US] SHC
WHERE VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'US' and [Level] = 'Daily' )
GROUP BY CONVERT(DATE, SHC.VisitDate)

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Weekly' AS [Level]
			,	'US' AS Region
			,	DDT.CalYWeekStartDate AS StartDate
			,	DDT.CalYWeekEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_US] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'US' and [Level] = 'Weekly' )
GROUP BY DDT.CalYWeekStartDate, DDT.CalYWeekEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Monthly' AS [Level]
			,	'US' AS Region
			,	DDT.MonthStartDate AS StartDate
			,	DDT.MonthEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_US] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'US' and [Level] = 'Monthly' )
GROUP BY DDT.MonthStartDate, DDT.MonthEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Quarterly' AS [Level]
			,	'US' AS Region
			,	DDT.QuarterStartDate AS StartDate
			,	DDT.QuarterEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_US] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'US' and [Level] = 'Quarterly' )
GROUP BY DDT.QuarterStartDate, DDT.QuarterEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Yearly' AS [Level]
			,	'US' AS Region
			,	DATEFROMPARTS([DDT].[YEAR], 1, 1) AS StartDate
			,	DATEFROMPARTS([DDT].[YEAR], 12, 31) AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_US] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'US' and [Level] = 'Yearly' )
GROUP BY [DDT].[Year]

-- For BRAZIL Region
UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Daily' AS [Level]
			,	'BRAZIL' AS Region
			,	CONVERT(DATE, SHC.VisitDate) AS StartDate
			,	CONVERT(DATE, SHC.VisitDate) AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_BRAZIL] SHC
WHERE VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'BRAZIL' and [Level] = 'Daily' )
GROUP BY CONVERT(DATE, SHC.VisitDate)

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Weekly' AS [Level]
			,	'BRAZIL' AS Region
			,	DDT.CalYWeekStartDate AS StartDate
			,	DDT.CalYWeekEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_BRAZIL] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'BRAZIL' and [Level] = 'Weekly' )
GROUP BY DDT.CalYWeekStartDate, DDT.CalYWeekEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Monthly' AS [Level]
			,	'BRAZIL' AS Region
			,	DDT.MonthStartDate AS StartDate
			,	DDT.MonthEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_BRAZIL] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'BRAZIL' and [Level] = 'Monthly' )
GROUP BY DDT.MonthStartDate, DDT.MonthEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Quarterly' AS [Level]
			,	'BRAZIL' AS Region
			,	DDT.QuarterStartDate AS StartDate
			,	DDT.QuarterEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_BRAZIL] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'BRAZIL' and [Level] = 'Quarterly' )
GROUP BY DDT.QuarterStartDate, DDT.QuarterEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Yearly' AS [Level]
			,	'BRAZIL' AS Region
			,	DATEFROMPARTS([DDT].[YEAR], 1, 1) AS StartDate
			,	DATEFROMPARTS([DDT].[YEAR], 12, 31) AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_BRAZIL] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'BRAZIL' and [Level] = 'Yearly' )
GROUP BY [DDT].[Year]

UNION ALL
-- For APAC Region

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Daily' AS [Level]
			,	'APAC' AS Region
			,	CONVERT(DATE, SHC.VisitDate) AS StartDate
			,	CONVERT(DATE, SHC.VisitDate) AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_APAC] SHC
WHERE VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'APAC' and [Level] = 'Daily' )
GROUP BY CONVERT(DATE, SHC.VisitDate)

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Weekly' AS [Level]
			,	'APAC' AS Region
			,	DDT.CalYWeekStartDate AS StartDate
			,	DDT.CalYWeekEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_APAC] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'APAC' and [Level] = 'Weekly' )
GROUP BY DDT.CalYWeekStartDate, DDT.CalYWeekEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Monthly' AS [Level]
			,	'APAC' AS Region
			,	DDT.MonthStartDate AS StartDate
			,	DDT.MonthEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_APAC] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'APAC' and [Level] = 'Monthly' )
GROUP BY DDT.MonthStartDate, DDT.MonthEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Quarterly' AS [Level]
			,	'APAC' AS Region
			,	DDT.QuarterStartDate AS StartDate
			,	DDT.QuarterEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_APAC] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'APAC' and [Level] = 'Quarterly' )
GROUP BY DDT.QuarterStartDate, DDT.QuarterEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Yearly' AS [Level]
			,	'APAC' AS Region
			,	DATEFROMPARTS([DDT].[YEAR], 1, 1) AS StartDate
			,	DATEFROMPARTS([DDT].[YEAR], 12, 31) AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_APAC] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'APAC' and [Level] = 'Yearly' )
GROUP BY [DDT].[Year]

UNION ALL
-- For LATAM Region

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Daily' AS [Level]
			,	'LATAM' AS Region
			,	CONVERT(DATE, SHC.VisitDate) AS StartDate
			,	CONVERT(DATE, SHC.VisitDate) AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_LATAM] SHC
WHERE VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'LATAM' and [Level] = 'Daily' )
GROUP BY CONVERT(DATE, SHC.VisitDate)

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Weekly' AS [Level]
			,	'LATAM' AS Region
			,	DDT.CalYWeekStartDate AS StartDate
			,	DDT.CalYWeekEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_LATAM] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'LATAM' and [Level] = 'Weekly' )
GROUP BY DDT.CalYWeekStartDate, DDT.CalYWeekEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Monthly' AS [Level]
			,	'LATAM' AS Region
			,	DDT.MonthStartDate AS StartDate
			,	DDT.MonthEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_LATAM] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'LATAM' and [Level] = 'Monthly' )
GROUP BY DDT.MonthStartDate, DDT.MonthEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Quarterly' AS [Level]
			,	'LATAM' AS Region
			,	DDT.QuarterStartDate AS StartDate
			,	DDT.QuarterEndDate AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_LATAM] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'LATAM' and [Level] = 'Quarterly' )
GROUP BY DDT.QuarterStartDate, DDT.QuarterEndDate

UNION ALL

SELECT		CONVERT(CHAR(40), '')	AS DWHashKey
			,	'Yearly' AS [Level]
			,	'LATAM' AS Region
			,	DATEFROMPARTS([DDT].[YEAR], 1, 1) AS StartDate
			,	DATEFROMPARTS([DDT].[YEAR], 12, 31) AS EndDate
			,	COUNT(DISTINCT SHC.FullVisitorId) AS UVs
			,	COUNT(DISTINCT CASE WHEN [SHC].[Type] = 'PAGE' THEN CONCAT(SHC.Id,Pagepath) ELSE NULL END) AS UPVs
			,	COUNT(DISTINCT SHC.Id) [Sessions]

FROM [SrcGoogleBigQuery].[GA_Sessionhits_LATAM] SHC
INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SHC.VisitDate) = DDT.DateKey
WHERE SHC.VisitDate >= (SELECT ISNULL(MAX(StartDate), '1900-01-01') FROM [DWCONSDL].[FactGAUMs] WHERE Region = 'LATAM' and [Level] = 'Yearly' )
GROUP BY [DDT].[Year];