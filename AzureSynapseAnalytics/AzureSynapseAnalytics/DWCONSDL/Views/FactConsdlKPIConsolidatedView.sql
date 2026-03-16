CREATE VIEW [DWCONSDL].[FactConsdlKPIConsolidatedView] AS 
SELECT  Region
	,	GA_Region
	,	Country_RollUp
	,	Country
	,	KPI  
	,	KPIDetails
	,	[Level]
	,	StartDate
	,	EndDate  
    ,	KPIValue
	,	'HistoryFile' AS Source
FROM [DWCONSDL].[FactConsdlKPIConsolidatedHistory]
UNION ALL
-- Data excluded as part of LiveDatabase is part of HistoryFile
SELECT B.Region
	,	A.Region AS GA_Region
	,	B.Country_RollUp
	,	A.CountryFromHostName AS Country
	,	KPI  
	,	KPIDetails
	,	[Level]
	,	StartDate
	,	EndDate  
    ,	KPIValue
	,	'LiveDatabase' AS Source
FROM [DWCONSDL].[FactConsdlKPIConsolidated] A
INNER JOIN [DWCONSDL].[ConsdlCountryToRegionMapping] B
ON A.CountryFromHostName = B.Country
WHERE  NOT ( A.StartDate < '2021-05-01'
AND (B.Region = 'APAC' OR B.Country_RollUp = 'Rest of LatAm' )
AND A.KPI IN ('UVs', 'Doc Locator Searches (unique)', 'Smile Completions', 'Leads (Opt-ins)'))
AND NOT ( A.StartDate < '2021-07-01'
AND (B.Region = 'APAC') AND A.KPI = 'Smile Completions')
AND NOT ( [A].[Level] = 'Monthly' AND StartDate BETWEEN '2019-01-01' AND '2019-12-31'
AND (B.Region = 'EMEA' OR (B.Region = 'Americas' AND B.Country_RollUp != 'Rest of LatAm' ))
AND A.KPI IN ('UVs', 'Doc Locator Searches (unique)', 'Smile Completions', 'Leads (Opt-ins)'))
AND NOT ( [A].[Level] = 'Monthly' AND StartDate BETWEEN '2020-01-01' AND '2020-12-31'
AND (B.Region = 'EMEA' )
AND A.KPI = 'Leads (Opt-ins)');