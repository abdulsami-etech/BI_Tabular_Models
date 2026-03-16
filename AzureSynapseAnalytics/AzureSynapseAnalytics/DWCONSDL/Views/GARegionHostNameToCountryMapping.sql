CREATE VIEW [DWCONSDL].[GARegionHostNameToCountryMapping]
AS SELECT  GARegion			
	,	HostName
	,	CountryFromHostName
	,	IsValid		
FROM [SrcCONSDL].[GARegionHostNameToCountryMapping];