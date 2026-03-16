CREATE VIEW [DWCONSDL].[FactDocLocValue]
AS SELECT 			
	a.DateKey,		
	--b.Country,		
	a.CountryCode,		
	--b.CountryGroup,		
	a.ZipCode,		
	--b.DMACode,		
	b.DMAName,		
	count(distinct a.viewer_id) as Value		
			
FROM DWCONSDL.FactAlignDocLocSearches a		
--INNER JOIN DW.DimGeography b  on a.GeographyKey = b.GeographyKey		
LEFT JOIN [DWCONSDL].[DimDMA] b ON a.ZipCode = b.zip
	--This next section attempts to remove bot/scraping traffic--		
LEFT JOIN 	(SELECT viewer_id,
					count(*) as searches
					FROM DWCONSDL.FactAlignDocLocSearches a 
					--INNER JOIN DW.DimGeography b on a.GeographyKey = b.GeographyKey
					LEFT JOIN [DWCONSDL].[DimDMA] b ON a.ZipCode = b.zip
					GROUP BY viewer_id, b.DMAName
					HAVING count(*)>500 or count(distinct b.DMAName)>=5
			) d on a.viewer_id = d.viewer_id	
			
WHERE d.viewer_id is null			
AND a.DateKey between '01-01-2017' and (GETDATE()-1)			
			
GROUP BY a.DateKey
--, b.Country
, a.CountryCode
--, b.CountryGroup
, a.ZipCode
--, b.DMACode
, b.DMAName;