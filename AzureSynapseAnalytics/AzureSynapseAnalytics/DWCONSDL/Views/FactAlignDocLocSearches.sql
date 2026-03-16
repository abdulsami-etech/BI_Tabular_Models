CREATE VIEW [DWCONSDL].[FactAlignDocLocSearches]
AS SELECT	e.viewer_id
	,	CONVERT(date, e.created_at)	AS DateKey
	,	-1							AS AudienceSegmentKey
	,	search_postal_code	AS ZipCode-- Added to Join with DimDMA
	,	CASE WHEN e.search_postal_code LIKE '%[a-z]%' THEN 'CA' ELSE 'US' END AS CountryCode
	,	e.search_filter AS SearchFilter
FROM SrcNADocLoc.event_logs e 
WHERE e.log_type = 'ResultsLoad' 
AND e.viewer_id IS NOT NULL

UNION ALL

SELECT	e.viewer_id
	,	CONVERT(date, e.created_at)	AS DateKey
	,	-1							AS AudienceSegmentKey
	,	search_postal_code	AS ZipCode-- Added to Join with DimDMA
	,	e.search_country AS CountryCode
	,	e.search_filter AS SearchFilter
FROM SrcLADocLoc.latam_event_logs e 
WHERE e.log_type = 'ResultsLoad' 
AND e.viewer_id IS NOT NULL;