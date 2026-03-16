CREATE VIEW [DWCONSDL].[FactAlignDocLoc]
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
SELECT	CONVERT(date, created_at) AS DateKey
	, lead_source AS Source
	,	CASE WHEN  coalesce(cf.prospect_id, l.prospect_id_text__C) != '' AND isnull(opt_in,0) !=0 THEN 1 ELSE NULL END AS LeadsTransferedToContactCenter
	, 	cf.email
	, 	cf.phone_number
	,	CONVERT(TINYINT, CASE WHEN cf.email != N''  THEN 0 ELSE 1 END) AS EMailContainsEmptyValue
	,	CONVERT(TINYINT, CASE WHEN cf.phone_number != N'' THEN 0 ELSE 1 END) AS PhoneContainsEmptyValue
	,	CASE WHEN cf.opt_in = 1 THEN 1 ELSE NULL END AS OptIns
	,	CASE WHEN DATEDIFF(MONTH, birthday, created_at) between 0 AND 19 * 12 - 1 THEN 2 --teen
			ELSE	CASE WHEN DATEDIFF(MONTH, birthday, created_at) >= 19 * 12 THEN 1 --adult
			ELSE -1 END
		END	AS AudienceSegmentKey
	,   CASE WHEN cf.zip like '%[a-z]%' THEN 'CA' ELSE 'US' END AS CountryCode
	,	CASE WHEN    COALESCE(cf.prospect_id, l.prospect_id_text__C) != '' AND  ISNULL(NULLIF(lead_source,''),'Doc Locator') = N'Homepage opt-in'
			THEN 1 ELSE NULL END AS HomePageOptIn	
	,	CASE WHEN  COALESCE(cf.prospect_id, l.prospect_id_text__C) != '' AND  cf.lead_source = N'Website'
			THEN 1 ELSE NULL END AS RequestAnApptWeb
	,	CASE WHEN  COALESCE(cf.prospect_id, l.prospect_id_text__C) != '' AND  cf.lead_source = N'Email'
			THEN 1 ELSE NULL END AS RequestAnApptEmail
	,	CASE WHEN  COALESCE(cf.prospect_id, l.prospect_id_text__C) != '' AND  cf.lead_source = N'Social Media'
			THEN 1 ELSE NULL END AS RequestAnApptSocial
	,	CASE WHEN  COALESCE(cf.prospect_id, l.prospect_id_text__C) != '' AND ISNULL(cf.lead_source,'')  in  (N'Website', N'Email', N'Social Media')
			THEN 1 ELSE NULL END AS RequestAnAppt
	,	CASE WHEN  COALESCE(cf.prospect_id, l.prospect_id_text__C) != '' AND ISNULL(cf.lead_source,'') not in  (N'Website', N'Email', N'Social Media')
			THEN 1 ELSE NULL END AS DLScheduleAnAppt
FROM SrcNADocLoc.contact_forms cf 
LEFT JOIN (SELECT email, max(prospect_id_text__C) prospect_id_text__C 
FROM  SrcSFDC.Lead  
WHERE leadsource = 'Doc Locator' group by email ) l  on cf.email = l.Email  

UNION

SELECT	CONVERT(date, cf.created_at)	AS DateKey
	,   ISNULL(NULLIF(cf.LeadSource,''),'Doc Locator') AS Source
	,	CASE WHEN  l.prospect_id_text__C != ''  AND ISNULL(cf.opt_in,0) !=0 THEN 1 ELSE NULL END AS LeadsTransferedToContactCenter
	, 	cf.email
	, 	cf.phonenumber
	,	CONVERT(TINYINT, CASE WHEN cf.email != N'' THEN 0 ELSE 1 END) AS EMailContainsEmptyValue
	,	CONVERT(TINYINT, CASE WHEN cf.phonenumber != N'' THEN 0 ELSE 1 END) AS PhoneContainsEmptyValue
	,	CASE WHEN cf.opt_in = 1 THEN 1 ELSE NULL END AS OptIns
	,	CASE WHEN cf.Segment = 'adult' THEN 1 --adult
		    WHEN cf.Segment = 'teen' THEN 2 ELSE -1 END AS AudienceSegmentKey
	--,	CASE WHEN cf.zip LIKE '%[a-z]%' THEN 'CA' ELSE 'US' END AS CountryCode
	,	cf.CountryCode
	,	CASE WHEN    l.prospect_id_text__C != '' AND  ISNULL(NULLIF(cf.LeadSource,''),'Doc Locator') = N'Homepage opt-in'
			THEN 1 ELSE NULL END AS HomePageOptIn	
	,	CASE WHEN    l.prospect_id_text__C  != '' AND  ISNULL(NULLIF(cf.LeadSource,''),'Doc Locator') = N'Website'
			THEN 1 ELSE NULL END AS RequestAnApptWeb
	,	CASE WHEN l.prospect_id_text__C != '' AND  ISNULL(NULLIF(cf.LeadSource,''),'Doc Locator') = N'Email'
			THEN 1 ELSE NULL END AS RequestAnApptEmail
	,	CASE WHEN    l.prospect_id_text__C != '' AND  ISNULL(NULLIF(cf.LeadSource,''),'Doc Locator') in (N'Social Media', 'Social Media (Paid AND Non-Paid)')
			THEN 1 ELSE NULL END AS RequestAnApptSocial
	,	CASE WHEN   l.prospect_id_text__C != '' AND ISNULL(NULLIF(cf.LeadSource,''),'Doc Locator')  in  (N'Website', N'Email', N'Social Media', N'Social Media (Paid AND Non-Paid)', N'Request Appointment')
			THEN 1 ELSE NULL END AS RequestAnAppt
	,	CASE WHEN  l.prospect_id_text__C != '' AND ISNULL(NULLIF(cf.LeadSource,''),'Doc Locator')  in  (N'Doc Locator') THEN 1
		ELSE NULL END AS DLScheduleAnAppt
FROM   cf 
LEFT JOIN (SELECT email, max(prospect_id_text__C) prospect_id_text__C 
FROM  SrcSFDC.Lead  
WHERE leadsource = 'Doc Locator' group by email ) l  on cf.email = l.Email  
WHERE CONVERT(date, created_at) >='20180222';