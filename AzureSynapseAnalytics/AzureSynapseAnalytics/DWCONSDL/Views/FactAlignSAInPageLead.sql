CREATE VIEW [DWCONSDL].[FactAlignSAInPageLead]
AS SELECT	CONVERT(date, sa.created_at) AS DateKey
	,	CASE WHEN  COALESCE(sa.prospect_id, l.prospect_id_text__C) != N'' THEN 1 ELSE NULL END AS LeadsTransferredToContactCenter
	,	CONVERT(TINYINT, CASE WHEN sa.email != N'' THEN 0 ELSE 1 END) AS EMailContainsEmptyValue
	,	CONVERT(TINYINT, CASE WHEN sa.phone != N'' THEN 0 ELSE 1 END) AS PhoneContainsEmptyValue
	,	CASE WHEN sa.receive_info_opt_in = N'Yes' THEN 1 ELSE NULL END AS OptIns
	,	sa.date_of_birth
	,  ISNULL(aud.AudienceSegmentKey,-1) AS AudienceSegmentKey
	,  ISNULL(loi.LevelOfInterestKey, -1) AS LevelOfInterestKey
	,  CASE WHEN sa.zip LIKE '%[a-z]%' THEN 'CA' ELSE 'US' END AS CountryCode	
FROM SrcNASA.smile_assessments sa 
INNER JOIN (select email, leadsource, max(prospect_id_text__C) prospect_id_text__C 
FROM  SrcSFDC.Lead 
WHERE leadsource = 'in-page lead' GROUP BY email, leadsource ) l ON sa.email = l.Email   
LEFT JOIN DWCONSDL.DimLevelOfInterest loi  ON  COALESCE(sa.prospect_id, l.prospect_id_text__C) != N'' AND loi.LevelOfInterestName = sa.research
LEFT JOIN DWCONSDL.UserType2AudienceSegment u2a ON sa.user_type = u2a.usertype 
LEFT JOIN DWCONSDL.DimAudienceSegment aud  ON u2a.[AudienceSegment] = aud.AudienceSegment
WHERE CONVERT(date, sa.created_at) > '20180221';