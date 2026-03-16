CREATE VIEW [TABTOPS].[DimCountry]
AS select	SKCountry
	,	CountryCode
	,	CountryName
	,	Region as SubRegion
	,	RegionGroup as Region
from DW.DimCountry;