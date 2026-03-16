CREATE VIEW [DWCONSDL].[FactAlignSA]
AS WITH SA AS (
   SELECT   sa.source, sa.email, sa.phone, sa.receive_info_opt_in, sa.date_of_birth, sa.zip, sa.prospect_id, sa.research, sa.user_type, sa.created_at
   , CASE WHEN sa.zip like '%[a-z]%' THEN 'CA' ELSE 'US' END AS CountryCode
  FROM SrcNASA.smile_assessments sa
  UNION 
    SELECT   sa.source, sa.email, sa.phone, sa.receive_info_opt_in, sa.date_of_birth, sa.zip, sa.prospect_id, sa.research, sa.user_type, sa.created_at
  , Country AS CountryCode
  FROM SrcLASA.smile_assessments sa WHERE sa.country IS NOT NULL
  --WHERE sa.country='ca'
  )

SELECT CONVERT(date, sa.created_at) AS DateKey  
 , CASE WHEN sa.prospect_id != N'' THEN 1 ELSE NULL END AS LeadsTransferredToContactCenter
 , CONVERT(TINYINT, CASE WHEN sa.email != N'' THEN 0 ELSE 1 END) AS EMailContainsEmptyValue  
 , CONVERT(TINYINT, CASE WHEN sa.phone != N'' THEN 0 ELSE 1 END) AS PhoneContainsEmptyValue  
 , CASE WHEN sa.receive_info_opt_in = N'Yes' THEN 1 ELSE NULL END AS OptIns
 , sa.date_of_birth  
 ,  ISNULL(aud.AudienceSegmentKey,-1) AS AudienceSegmentKey  
 ,  ISNULL(loi.LevelOfInterestKey, -1) AS LevelOfInterestKey
,  CASE WHEN sa.zip like '%[a-z]%' THEN 'CA' ELSE 'US' END AS CountryCode 
FROM SrcNASA.smile_assessments sa  
LEFT JOIN DWCONSDL.DimLevelOfInterest loi ON sa.prospect_id != N''  
            and loi.LevelOfInterestName = sa.research  
LEFT JOIN DWCONSDL.UserType2AudienceSegment u2a  ON sa.user_type = u2a.UserType   
LEFT JOIN DWCONSDL.DimAudienceSegment aud  ON u2a.[AudienceSegment] = aud.AudienceSegment
WHERE CONVERT(date, sa.created_at) <='20180221'
UNION ALL  
SELECT CONVERT(date, sa.created_at) AS DateKey  
 , CASE WHEN  COALESCE(sa.prospect_id, l.prospect_id_text__C) != N'' THEN 1 ELSE NULL END AS LeadsTransferredToContactCenter    
 , CONVERT(TINYINT, CASE WHEN sa.email != N'' THEN 0 ELSE 1 END) AS EMailContainsEmptyValue  
 , CONVERT(TINYINT, CASE WHEN sa.phone != N'' THEN 0 ELSE 1 END) AS PhoneContainsEmptyValue  
 , CASE WHEN ISNULL(NullIf(sa.receive_info_opt_in,''), N'No') = N'Yes' THEN 1 ELSE NULL END AS OptIns
 , sa.date_of_birth  
 ,  ISNULL(aud.AudienceSegmentKey,-1) AS AudienceSegmentKey  
 ,  ISNULL(loi.LevelOfInterestKey, -1) AS LevelOfInterestKey  
 --,  CASE WHEN sa.zip like '%[a-z]%' THEN 'CA' ELSE 'US' END AS CountryCode  
 ,	sa.CountryCode
FROM   sa   
LEFT JOIN (SELECT Ld.email,Ld.LeadSource, max(Ld.prospect_id_text__C) prospect_id_text__C   
FROM  SrcSFDC.Lead Ld
INNER JOIN [SrcSFDC].[RecordType] RT ON [RecordTypeId] = RT.Id
WHERE RT.Name = 'Consumer'
GROUP BY Ld.email,Ld.LeadSource ) l ON sa.email = l.Email     
LEFT JOIN DWCONSDL.DimLevelOfInterest loi  ON  COALESCE(sa.prospect_id, l.prospect_id_text__C) != N''  
            and loi.LevelOfInterestName = sa.research  
LEFT JOIN DWCONSDL.UserType2AudienceSegment u2a  ON sa.user_type = u2a.UserType   
LEFT JOIN DWCONSDL.DimAudienceSegment aud  ON u2a.[AudienceSegment] = aud.AudienceSegment
WHERE CONVERT(date, sa.created_at) > '20180221';