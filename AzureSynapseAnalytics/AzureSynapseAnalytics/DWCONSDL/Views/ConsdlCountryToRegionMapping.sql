CREATE VIEW [DWCONSDL].[ConsdlCountryToRegionMapping] AS 
SELECT  Region
	,	Country_RollUp
	,	Country
FROM [SrcCONSDL].[ConsdlCountryToRegionMapping];
	