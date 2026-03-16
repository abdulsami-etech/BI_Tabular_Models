CREATE VIEW [DWCONSDL].[FactRequestApptWebsite2]
AS WITH cf AS 
(SELECT  cf.email,   cf.phonenumber,  cf.segment,  cf.zip,  cf.created_at, cf.LeadSource, cf.opt_in
	, CASE WHEN cf.zip like '%[a-z]%' THEN 'CA' ELSE 'US' END AS CountryCode
  FROM SrcNASA.contact_providers cf
  UNION 
    SELECT  cf.email,   cf.phonenumber,  cf.segment,  cf.zip,  cf.created_at, cf.LeadSource, cf.opt_in
	, Country AS CountryCode
  FROM SrcLASA.contact_providers cf WHERE cf.country IS NOT NULL
  --WHERE cf.country='ca'
)
 SELECT CONVERT(date, created_at) AS DateKey   
 ,ISNULL(NULLIF(cf.lead_source,''),'Doc Locator') AS RequestApptLeadSource  
 ,l.LeadSource  
 ,cf.prospect_id prospect_id_text__C  
 , CASE WHEN  cf.prospect_id is null THEN 'No' ELSE 'Yes' END  IsTransferred   
 , cf.email
 , cf.phone_number
 , CONVERT(TINYINT, CASE WHEN cf.email != N'' THEN 0 ELSE 1 END) AS EMailContainsEmptyValue  
 , CONVERT(TINYINT, CASE WHEN cf.phone_number != N'' THEN 0 ELSE 1 END) AS PhoneContainsEmptyValue  
 , CASE WHEN cf.opt_in = 1 THEN 'Yes' ELSE 'No' END AS IsOptIn 
 , CASE WHEN DATEDIFF(MONTH, birthday, created_at) between 0 AND 19 * 12 - 1 THEN 2 --teen  
		ELSE CASE WHEN DATEDIFF(MONTH, birthday, created_at) >= 19 * 12   THEN 1 --adult  
		ELSE -1 END END AS AudienceSegmentKey 
 ,	CASE WHEN cf.zip like '%[a-z]%' THEN 'CA' ELSE 'US' END AS CountryCode
FROM SrcNADocLoc.contact_forms cf   
LEFT JOIN (SELECT Ld.email,Ld.LeadSource, max(Ld.prospect_id_text__C) prospect_id_text__C   
FROM  SrcSFDC.Lead Ld
INNER JOIN [SrcSFDC].[RecordType] RT ON [RecordTypeId] = RT.Id
WHERE RT.Name IN ('Consumer') 
GROUP BY Ld.email,Ld.LeadSource ) l  ON cf.email = l.Email  AND cf.lead_source = l.LeadSource    
  
UNION

SELECT CONVERT(date, created_at) AS DateKey  
 , ISNULL(NULLIF(cf.LeadSource,''),'Doc Locator') AS RequestApptLeadSource  
 , l.LeadSource  
 , l.prospect_id_text__C  
 , CASE WHEN  l.prospect_id_text__C is null THEN 'No' ELSE 'Yes' END  IsTransferred 
 , cf.email
 , cf.phonenumber 
 , CONVERT(tinyint, CASE WHEN cf.email != N'' THEN 0 ELSE 1 END) AS EMailContainsEmptyValue  
 , CONVERT(tinyint, CASE WHEN cf.phonenumber != N'' THEN 0 ELSE 1 END) AS PhoneContainsEmptyValue  
 , CASE WHEN cf.opt_in = 1 THEN 'Yes' ELSE 'No' END AS IsOptIn
 , CASE WHEN Segment = 'adult' THEN 1 --adult  
		WHEN Segment = 'teen' THEN 2  ELSE -1 END       AS AudienceSegmentKey  
 --,	CASE WHEN cf.zip like '%[a-z]%' THEN 'CA' ELSE 'US' END AS CountryCode
 , cf.CountryCode 
FROM   cf
LEFT JOIN (SELECT Ld.email,Ld.LeadSource, max(Ld.prospect_id_text__C) prospect_id_text__C   
FROM  SrcSFDC.Lead Ld
INNER JOIN [SrcSFDC].[RecordType] RT ON [RecordTypeId] = RT.Id
WHERE RT.Name IN ('Consumer') 
GROUP BY Ld.email,Ld.LeadSource ) l  ON cf.email = l.Email  AND cf.LeadSource = l.LeadSource  
WHERE CONVERT(date, created_at) >= '20180221';