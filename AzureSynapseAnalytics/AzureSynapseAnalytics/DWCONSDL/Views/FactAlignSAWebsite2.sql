CREATE VIEW [DWCONSDL].[FactAlignSAWebsite2]
AS WITH SA AS (
   SELECT  sa.source, sa.email, sa.phone ,sa.receive_info_opt_in, sa.date_of_birth, sa.zip, sa.prospect_id, sa.research, sa.user_type, sa.created_at
   , CASE WHEN sa.zip like '%[a-z]%' THEN 'CA' ELSE 'US' END AS CountryCode
  FROM SrcNASA.smile_assessments sa
  UNION 
    SELECT   sa.source, sa.email, sa.phone ,sa.receive_info_opt_in, sa.date_of_birth, sa.zip, sa.prospect_id, sa.research, sa.user_type, sa.created_at
	, Country AS CountryCode
  FROM SrcLASA.smile_assessments sa WHERE sa.country IS NOT NULL
  --WHERE sa.country='ca'
  )
 
 SELECT CONVERT(DATE, sa.created_at) AS DateKey
 , CAST(ISNULL(sa.source, 'Smile Assessment') AS nvarchar(250)) AS SALeadSource  
 , l.LeadSource  
 , l.prospect_id_text__C  
 , CASE WHEN  l.prospect_id_text__C IS NULL THEN 'No' ELSE 'Yes' END  IsTransferred 
 , CONVERT(TINYINT, CASE WHEN sa.email != N'' THEN 0 ELSE 1 END)        AS EMailContainsEmptyValue
 , CONVERT(TINYINT, CASE WHEN sa.phone != N'' THEN 0 ELSE 1 END) AS PhoneContainsEmptyValue  
 , ISNULL(NullIf(sa.receive_info_opt_in,''), N'No')  IsOptIn
 , sa.date_of_birth  
 ,  ISNULL(aud.AudienceSegmentKey,-1) AS AudienceSegmentKey  
 ,  ISNULL(loi.LevelOfInterestKey, -1) AS LevelOfInterestKey  
 --,  CASE WHEN sa.zip like '%[a-z]%' THEN 'CA' ELSE 'US' END AS CountryCode
 , sa.CountryCode
 , sa.zip as ZipCode
FROM  sa   
LEFT JOIN (SELECT Ld.email,Ld.LeadSource, max(Ld.prospect_id_text__C) prospect_id_text__C   
FROM  SrcSFDC.Lead Ld
INNER JOIN [SrcSFDC].[RecordType] RT ON [RecordTypeId] = RT.Id
WHERE RT.Name IN ('Consumer') 
GROUP BY Ld.email,Ld.LeadSource ) l ON sa.email = l.Email AND CAST(ISNULL(sa.source, 'Smile Assessment') AS nvarchar(250)) = l.LeadSource  
LEFT JOIN DWCONSDL.DimLevelOfInterest loi  ON  coalesce(sa.prospect_id, l.prospect_id_text__C) != N''  
            AND loi.LevelOfInterestName = sa.research  
LEFT JOIN DWCONSDL.UserType2AudienceSegment u2a  ON sa.user_type = u2a.UserType   
LEFT JOIN DWCONSDL.DimAudienceSegment aud  ON u2a.[AudienceSegment] = aud.AudienceSegment;