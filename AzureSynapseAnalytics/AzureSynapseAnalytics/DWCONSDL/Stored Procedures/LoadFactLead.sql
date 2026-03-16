CREATE PROC [DWCONSDL].[LoadFactLead] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	Declare @CurrentDateTime datetime = GETUTCDATE();
	
	if object_id('tempdb..#TempFactLead') is not null
		drop table #TempFactLead

	create table #TempFactLead with (distribution = round_robin, heap) as 

-- NA REGION	
SELECT 	CONVERT(CHAR(40), '') AS DWHashKey,
		a.Id,
		a.Lead_Region__c,
		'NA' AS Region,
		a.Country, 
		a.Lead_URL_Campaign__c,
		a.Lead_URL_Content__c,
		a.Lead_URL_Medium__c,
		a.Lead_URL_Source__c,
		a.Lead_URL_Term__c,
		a.Unsubscribe__c,
		a.Et4ae5__HasOptedOutOfMobile__C,
		cn.Professional_Category__c AS Channel, 
		SUBSTRING(a.Zip__c, 1, 5) AS Zip,
		CASE WHEN r.DeveloperName LIKE('Conversion_Call_Center_%')
			THEN 'Alorica'
			ELSE 'Americas' END AS 'Lead_Assigned',
		CASE
			WHEN a.Age__c IS NULL
			THEN '6) Unknown'
			WHEN a.Age__c BETWEEN 6 AND 10
			THEN '1) Young Child (6-10)'
			WHEN a.Age__c BETWEEN 11 AND 17
			THEN '2) Teen/Tween (11-17)'
			WHEN a.Age__c BETWEEN 18 AND 24
			THEN '3) Young Adult/Cusper (18-24)'
			WHEN a.Age__c BETWEEN 25 AND 34
			THEN '4) Adult (25-34)'
			ELSE '5) Older Adult (35+)'
		END AS Age_Segment,
		CASE
			WHEN a.Age__c IS NULL
			THEN 'Unknown'
			WHEN a.Age__c <= 19
			THEN 'Teen (<19)'
			ELSE 'Adult (20+)'
		END AS Age_Group,
		CASE
			WHEN a.Created_Date_Time__c IS NOT NULL
				AND a.First_Contact__c IS NOT NULL
                AND DATEDIFF(DAY, a.Created_Date_Time__c, a.First_Contact__c) = 0
			THEN 'a) Same Day'
			WHEN a.Created_Date_Time__c IS NOT NULL
                AND a.First_Contact__c IS NOT NULL
                AND DATEDIFF(DAY, a.Created_Date_Time__c, a.First_Contact__c) BETWEEN 1 AND 7
			THEN 'b) 1-7 Days Later'
			WHEN a.Created_Date_Time__c IS NOT NULL
                AND a.First_Contact__c IS NOT NULL
                AND DATEDIFF(DAY, a.Created_Date_Time__c, a.First_Contact__c) BETWEEN 8 AND 100
			THEN 'c) 8 or More Days Later'
			ELSE 'd) N/A'
		END AS Days_Between_Create_Contact,
		CASE
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c) BETWEEN 0 AND 4
			THEN 'a) Within 4 Days'
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c) BETWEEN 4 AND 30
			THEN 'b) 4-30 Days'
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c) BETWEEN 31 AND 120
			THEN 'c) More Than 30 Days'
			ELSE 'd) N/A'
		END AS Days_Between_Schedule_Consult,
		CASE
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c) BETWEEN 0 AND 120
			THEN DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c)
			ELSE NULL
		END AS Days_Between_Schedule_Consult2,
		CASE
			WHEN a.Created_Date_Time__c IS NOT NULL
                AND a.ClinCheck_Accepted_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Created_Date_Time__c, a.ClinCheck_Accepted_Date__c) BETWEEN 0 AND 300
			THEN DATEDIFF(DAY, a.Created_Date_Time__c, a.ClinCheck_Accepted_Date__c)
			ELSE NULL
		END AS Days_Between_Create_CCA2,
		CASE
			WHEN a.LeadSource IN('Smile Assessment')
                AND a.SA_Prospect_Status__c IN('I''d like to set up an appointment for a consultation')
			THEN 'Smile Assessment - I''d like to set up an appointment for a consultation'
			WHEN a.LeadSource IN('Smile Assessment')
                AND a.SA_Prospect_Status__c IN('I''ve made an appointment for a consultation')
			THEN 'Smile Assessment - I''ve made an appointment for a consultation'
			WHEN a.LeadSource IN('Smile Assessment')
                AND a.SA_Prospect_Status__c IN('I''ve just started my research')
			THEN 'Smile Assessment - I''ve just started my research'
			WHEN a.LeadSource IN('Smile Assessment')
			THEN 'Smile Assessment - Blank'
			WHEN a.LeadSource IS NULL
			THEN 'Blank'
			WHEN a.LeadSource = 'Socail Media'
			THEN 'Social Media'
			ELSE RTRIM(LTRIM(a.LeadSource))
		END AS Lead_Source_Granular,
		CASE
			WHEN a.LeadSource IN('Doc Locator')
			THEN 'Doc Locator'
			WHEN a.SA_Prospect_Status__c IN('I''d like to set up an appointment for a consultation', 'I''ve made an appointment for a consultation')
			THEN 'SA - Appointment'
			WHEN a.LeadSource IN('Request Appointment')
			THEN 'Request Appointment'
			WHEN a.LeadSource IN('Smile Assessment')
			THEN 'SA - Research'
			WHEN a.SA_Prospect_Status__c IN('I''ve just started my research')
			THEN 'SA - Research'
			WHEN a.LeadSource IN('Social Media')
			THEN 'Social Media'
			WHEN a.LeadSource IN('SDC')
			THEN 'SDC'
			WHEN a.LeadSource IN('Web', 'Website')
			THEN 'Website'
			WHEN a.LeadSource IN('Scan Office')
			THEN 'Scan Office'
			WHEN a.LeadSource IN('Contact Us')
			THEN 'Contact Us'
				ELSE 'Other'
		END	 AS Lead_Source,
		a.LeadSource AS LeadSourceOriginal,
		CASE
			WHEN a.I_am__c = 'adult'
			THEN 'an adult'
			ELSE a.I_am__c
		END AS Age_Group2, 
		CAST(a.Created_Date_Time__c AS DATE) AS Lead_Created_Date, 
		CAST(DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEADD(DAY, -1, a.Created_Date_Time__c)), DATEADD(DAY, -1, a.Created_Date_Time__c)) AS DATE) AS Lead_Created_Week, 
		DATEFROMPARTS(YEAR(a.Created_Date_Time__c), MONTH(a.Created_Date_Time__c), 1) AS Lead_Created_Month,
		CASE
			WHEN MONTH(a.Created_Date_Time__c) IN(1, 2, 3)
			THEN DATEFROMPARTS(YEAR(a.Created_Date_Time__c), 1, 1)
			WHEN MONTH(a.Created_Date_Time__c) IN(4, 5, 6)
			THEN DATEFROMPARTS(YEAR(a.Created_Date_Time__c), 4, 1)
			WHEN MONTH(a.Created_Date_Time__c) IN(7, 8, 9)
			THEN DATEFROMPARTS(YEAR(a.Created_Date_Time__c), 7, 1)
			WHEN MONTH(a.Created_Date_Time__c) IN(10, 11, 12)
			THEN DATEFROMPARTS(YEAR(a.Created_Date_Time__c), 10, 1)
		END AS Lead_Created_Quarter, 
		(YEAR(GETDATE()) - YEAR(a.Created_Date_Time__c)) * 12 + (MONTH(GETDATE()) - MONTH(a.Created_Date_Time__c)) AS Mos_Since_Created_Date,
		CASE
			WHEN a.First_Contact__c IS NOT NULL
			THEN CAST(a.First_Contact__c AS DATE)
			WHEN a.Scheduled_Date__c IS NOT NULL
			THEN CAST(a.Created_Date_Time__c AS DATE)
			WHEN a.Scheduled_Date__c IS NOT NULL
					AND a.First_Contact__c IS NULL
			THEN CAST(a.Scheduled_Date__c AS DATE)
			WHEN a.Consult_Date__c IS NOT NULL
					AND a.First_Contact__c IS NULL
			THEN CAST(a.Consult_Date__c AS DATE)
			WHEN a.Converted_Date__c IS NOT NULL
					AND a.First_Contact__c IS NULL
			THEN CAST(a.Converted_Date__c AS DATE)
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
					AND a.First_Contact__c IS NULL
			THEN CAST(a.ClinCheck_Accepted_Date__c AS DATE)
			ELSE a.First_Contact__c
		END AS First_Contact_Date, 
		DATEFROMPARTS(YEAR(CASE
                              WHEN a.First_Contact__c IS NOT NULL
                              THEN a.First_Contact__c
                              WHEN a.Scheduled_Date__c IS NOT NULL
                              THEN a.Created_Date_Time__c
                              ELSE a.First_Contact__c
                          END), MONTH(CASE
                                          WHEN a.First_Contact__c IS NOT NULL
                                          THEN a.First_Contact__c
                                          WHEN a.Scheduled_Date__c IS NOT NULL
                                          THEN a.Created_Date_Time__c
                                          ELSE a.First_Contact__c
                                      END), 1) AS First_Contact_Month,
		CASE
			WHEN a.First_Contact__c IS NULL
			THEN 0
			ELSE(YEAR(GETDATE()) - YEAR(CASE
                                           WHEN a.First_Contact__c IS NOT NULL
                                           THEN a.First_Contact__c
                                           WHEN a.Scheduled_Date__c IS NOT NULL
                                           THEN a.Created_Date_Time__c
                                           ELSE a.First_Contact__c
                                       END)) * 12 + (MONTH(GETDATE()) - MONTH(CASE
                                                                                  WHEN a.First_Contact__c IS NOT NULL
                                                                                  THEN a.First_Contact__c
                                                                                  WHEN a.Scheduled_Date__c IS NOT NULL
                                                                                  THEN a.Created_Date_Time__c
                                                                                  ELSE a.First_Contact__c
                                                                              END))
		END AS Mos_Since_First_Contact_Date,
		CASE
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.First_Contact__c IS NULL
                AND a.Scheduled_Date__c < a.Created_Date_Time__c
			THEN CAST(a.Created_Date_Time__c AS DATE)
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.First_Contact__c IS NOT NULL
                AND a.Scheduled_Date__c < a.First_Contact__c
			THEN CAST(a.First_Contact__c AS DATE)
			WHEN a.Consult_Date__c IS NOT NULL
                AND a.Scheduled_Date__c IS NULL
			THEN CAST(a.Consult_Date__c AS DATE)
			WHEN a.Converted_Date__c IS NOT NULL
                AND a.Scheduled_Date__c IS NULL
			THEN CAST(a.Converted_Date__c AS DATE)
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
                AND a.Scheduled_Date__c IS NULL
			THEN CAST(a.ClinCheck_Accepted_Date__c AS DATE)
			ELSE CAST(a.Scheduled_Date__c AS DATE)
		END AS Scheduled_Date, 
		DATEFROMPARTS(YEAR(a.Scheduled_Date__c), MONTH(a.Scheduled_Date__c), 1) AS Scheduled_Month,
		CASE
			WHEN a.Scheduled_Date__c IS NULL
			THEN 0
			ELSE(YEAR(GETDATE()) - YEAR(a.Scheduled_Date__c)) * 12 + (MONTH(GETDATE()) - MONTH(a.Scheduled_Date__c))
		END AS Mos_Since_Scheduled_Date,
		CASE
			WHEN a.Converted_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NULL
			THEN CAST(a.Converted_Date__c AS DATE)
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NULL
			THEN CAST(a.ClinCheck_Accepted_Date__c AS DATE)
			ELSE CAST(a.Consult_Date__c AS DATE)
		END AS Consultation_Date,
		CASE
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
			THEN 1
			WHEN a.Converted_Date__c IS NOT NULL
			THEN 1
			WHEN a.Consult_Date__c IS NOT NULL
				AND a.Consult_Date__c <= GETDATE()
			THEN 1
			ELSE 0
		END AS Lapsed_Consults,
		CASE
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
                AND a.Converted_Date__c IS NULL
			THEN CAST(a.ClinCheck_Accepted_Date__c AS DATE)
			ELSE CAST(a.Converted_Date__c AS DATE)
		END AS Converted_Date, 
		DATEFROMPARTS(YEAR(CAST(a.Converted_Date__c AS DATE)), MONTH(CAST(a.Converted_Date__c AS DATE)), 1) AS Converted_Month,
		CASE
			WHEN DATEADD(dd, 30, a.Created_Date_Time__c) >= a.Converted_Date__c
			THEN 1
			ELSE 0
		END AS Converted_Within_30_Days,
		CASE
			WHEN DATEADD(dd, 60, a.Created_Date_Time__c) >= a.Converted_Date__c
			THEN 1
			ELSE 0
		END AS Converted_Within_60_Days,
		CASE
			WHEN a.Converted_Date__c IS NULL
			THEN 0
			ELSE(YEAR(GETDATE()) - YEAR(a.Converted_Date__c)) * 12 + (MONTH(GETDATE()) - MONTH(a.Converted_Date__c))
		END AS Mos_Since_Converted_Date, 
		CAST(a.ClinCheck_Accepted_Date__c AS DATE) AS CCA_Date, 
		a.DID__c AS DID, 
		cn.Clinician_Id__C AS ClinID, 
		cn.Name AS Doctor_Name,
		CASE
           WHEN cn.MailingCountry  IS NOT NULL
                AND cn.MailingCity  NOT IN('', ' ')
                AND cn.MailingCity IS NOT NULL
                AND cn.MailingState NOT IN('', ' ')
			THEN concat(cn.MailingCity, ', ', cn.MailingState)
			ELSE ''
		END AS City_State, 
		d.Account_Number__c AS LID,
		CASE
			WHEN LOWER(Prospect_Status__c) = 'not interested'
			THEN 1
			ELSE 0
		END AS Not_Interested,
		CASE
			WHEN LOWER(Prospect_Status__c) = 'bad data'
			THEN 1
			ELSE 0
		END AS Bad_Data,
		CASE
			WHEN LOWER(Prospect_Status__c) = 'in progress'
			THEN 1
			ELSE 0
		END AS in_Progress,
		a.SystemModstamp
FROM (SELECT Id,Country,Zip__c,Age__c,Created_Date_Time__c,First_Contact__c,Scheduled_Date__c,Consult_Date__c
			,ClinCheck_Accepted_Date__c,LeadSource,SA_Prospect_Status__c,Prospect_Status__c,I_am__c
			,Converted_Date__c,DID__c,RecordTypeId,OwnerId,Account__c,SystemModstamp,Lead_Region__c,Lead_URL_Campaign__c,Lead_URL_Content__c
			,Lead_URL_Medium__c,Lead_URL_Source__c,Lead_URL_Term__c, Unsubscribe__c, Et4ae5__HasOptedOutOfMobile__C 
			FROM SrcSFDC.LEAD WHERE SystemModstamp >= (SELECT ISNULL(MAX(SystemModstamp), '1900-01-01') FROM [DWCONSDL].[FactLead] WHERE Region = 'NA')) a
INNER JOIN SrcSFDC.RecordType b ON a.RecordTypeId = b.Id
LEFT JOIN SrcSFDC."User" c ON a.OwnerId = c.Id
LEFT JOIN SrcSFDC."UserRole" r ON c.UserRoleId = r.Id
LEFT JOIN SrcSFDC.Account d ON a.Account__c = d.Id
LEFT JOIN SrcSFDC.Contact cn on Coalesce(a.DID__c,d.Account_Number__c )= cn.account_Number__C and cn.Contact_Type__C='Doctor'
LEFT JOIN
(
    SELECT LeadID, 
           COUNT(*) AS LeadsHistory_Records, 
           MAX(CASE
                   WHEN Field IN('Owner')
                   THEN 1
                   ELSE 0
               END) AS Has_Owner_Record
    FROM SrcSFDC.LeadHistory
    GROUP BY LeadID
) f ON a.ID = f.LeadID
     LEFT JOIN
(
    SELECT DISTINCT 
           LeadID
    FROM SrcSFDC.LeadHistory
    WHERE NewValue IN ('Consumer Journey')
) g ON a.ID = g.LeadID
WHERE 
a.Country IN('United States', 'Canada') AND 
--CAST(a.Created_Date_Time__c AS DATE) BETWEEN '2021-01-01' AND '2021-01-31' AND 
b.Name IN('Consumer', 'Marketing Leads')
AND a.LeadSource NOT IN ('Parent Share Smile Quiz')
AND NOT(a.First_Contact__c IS NULL
        AND ((CAST(a.Created_Date_Time__c AS DATE) >= '2018-03-01'
              AND f.LeadID IS NOT NULL
              AND f.Has_Owner_Record = 0)
             OR g.LeadID IS NOT NULL))
AND NOT(a.First_Contact__c IS NULL
        AND a.LeadSource = 'Contact Us'
        AND CAST(a.Created_Date_Time__c AS DATE) BETWEEN '2018-08-14' AND '2018-08-31')
		
UNION ALL	
	
-- EMEA REGION
SELECT  CONVERT(CHAR(40), '') AS DWHashKey,
		a.Id,
		a.Lead_Region__c,
		'EMEA' AS Region,
		CASE WHEN a.Country IS NULL THEN 'Rest of EMEA' ELSE a.Country END AS Country,
		a.Lead_URL_Campaign__c,
		a.Lead_URL_Content__c,
		a.Lead_URL_Medium__c,
		a.Lead_URL_Source__c,
		a.Lead_URL_Term__c,
		a.Unsubscribe__c,
		a.Et4ae5__HasOptedOutOfMobile__C,
		cn.Professional_Category__c AS Channel, 
		SUBSTRING(a.Zip__c, 1, 5) AS Zip,
		NULL AS Lead_Assigned,  -- NEED LOGIC FOR EMEA IF REQUIRED
		CASE
			WHEN a.Age__c IS NULL
			THEN '6) Unknown'
			WHEN a.Age__c BETWEEN 6 AND 10
			THEN '1) Young Child (6-10)'
			WHEN a.Age__c BETWEEN 11 AND 17
			THEN '2) Teen/Tween (11-17)'
			WHEN a.Age__c BETWEEN 18 AND 24
			THEN '3) Young Adult/Cusper (18-24)'
			WHEN a.Age__c BETWEEN 25 AND 34
			THEN '4) Adult (25-34)'
			ELSE '5) Older Adult (35+)'
		END AS Age_Segment,
		CASE
			WHEN a.Age__c IS NULL
			THEN 'Unknown'
			WHEN a.Age__c <= 19
			THEN 'Teen (<19)'
			ELSE 'Adult (20+)'
		END AS Age_Group,
		CASE
			WHEN a.Created_Date_Time__c IS NOT NULL
				AND a.First_Contact__c IS NOT NULL
                AND DATEDIFF(DAY, a.Created_Date_Time__c, a.First_Contact__c) = 0
			THEN 'a) Same Day'
			WHEN a.Created_Date_Time__c IS NOT NULL
                AND a.First_Contact__c IS NOT NULL
                AND DATEDIFF(DAY, a.Created_Date_Time__c, a.First_Contact__c) BETWEEN 1 AND 7
			THEN 'b) 1-7 Days Later'
			WHEN a.Created_Date_Time__c IS NOT NULL
                AND a.First_Contact__c IS NOT NULL
                AND DATEDIFF(DAY, a.Created_Date_Time__c, a.First_Contact__c) BETWEEN 8 AND 100
			THEN 'c) 8 or More Days Later'
			ELSE 'd) N/A'
		END AS Days_Between_Create_Contact,
		CASE
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c) BETWEEN 0 AND 4
			THEN 'a) Within 4 Days'
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c) BETWEEN 4 AND 30
			THEN 'b) 4-30 Days'
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c) BETWEEN 31 AND 120
			THEN 'c) More Than 30 Days'
			ELSE 'd) N/A'
		END AS Days_Between_Schedule_Consult,
		CASE
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c) BETWEEN 0 AND 120
			THEN DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c)
			ELSE NULL
		END AS Days_Between_Schedule_Consult2,
		CASE
			WHEN a.Created_Date_Time__c IS NOT NULL
                AND a.ClinCheck_Accepted_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Created_Date_Time__c, a.ClinCheck_Accepted_Date__c) BETWEEN 0 AND 300
			THEN DATEDIFF(DAY, a.Created_Date_Time__c, a.ClinCheck_Accepted_Date__c)
			ELSE NULL
		END AS Days_Between_Create_CCA2,
		CASE
			WHEN a.LeadSource IN('Smile Assessment')
                AND a.SA_Prospect_Status__c IN('I''d like to set up an appointment for a consultation')
			THEN 'Smile Assessment - I''d like to set up an appointment for a consultation'
			WHEN a.LeadSource IN('Smile Assessment')
                AND a.SA_Prospect_Status__c IN('I''ve made an appointment for a consultation')
			THEN 'Smile Assessment - I''ve made an appointment for a consultation'
			WHEN a.LeadSource IN('Smile Assessment')
                AND a.SA_Prospect_Status__c IN('I''ve just started my research')
			THEN 'Smile Assessment - I''ve just started my research'
			WHEN a.LeadSource IN('Smile Assessment')
			THEN 'Smile Assessment - Blank'
			WHEN a.LeadSource IS NULL
			THEN 'Blank'
			WHEN a.LeadSource = 'Socail Media'
			THEN 'Social Media'
			ELSE RTRIM(LTRIM(a.LeadSource))
		END AS Lead_Source_Granular,
		CASE
			WHEN a.LeadSource IN('Doc Locator')
			THEN 'Doc Locator'
			WHEN a.SA_Prospect_Status__c IN('I''d like to set up an appointment for a consultation', 'I''ve made an appointment for a consultation')
			THEN 'SA - Appointment'
			WHEN a.LeadSource IN('Request Appointment')
			THEN 'Request Appointment'
			WHEN a.LeadSource IN('Smile Assessment')
			THEN 'SA - Research'
			WHEN a.SA_Prospect_Status__c IN('I''ve just started my research')
			THEN 'SA - Research'
			WHEN a.LeadSource IN('Social Media')
			THEN 'Social Media'
			WHEN a.LeadSource IN('SDC')
			THEN 'SDC'
			WHEN a.LeadSource IN('Web', 'Website')
			THEN 'Website'
			WHEN a.LeadSource IN('Scan Office')
			THEN 'Scan Office'
			WHEN a.LeadSource IN('Contact Us')
			THEN 'Contact Us'
				ELSE 'Other'
		END	 AS Lead_Source,
		a.LeadSource AS LeadSourceOriginal,
		CASE
			WHEN a.I_am__c = 'adult'
			THEN 'an adult'
			ELSE a.I_am__c
		END AS Age_Group2, 
		CAST(a.Created_Date_Time__c AS DATE) AS Lead_Created_Date, 
		CAST(DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEADD(DAY, -1, a.Created_Date_Time__c)), DATEADD(DAY, -1, a.Created_Date_Time__c)) AS DATE) AS Lead_Created_Week, 
		DATEFROMPARTS(YEAR(a.Created_Date_Time__c), MONTH(a.Created_Date_Time__c), 1) AS Lead_Created_Month,
		CASE
			WHEN MONTH(a.Created_Date_Time__c) IN(1, 2, 3)
			THEN DATEFROMPARTS(YEAR(a.Created_Date_Time__c), 1, 1)
			WHEN MONTH(a.Created_Date_Time__c) IN(4, 5, 6)
			THEN DATEFROMPARTS(YEAR(a.Created_Date_Time__c), 4, 1)
			WHEN MONTH(a.Created_Date_Time__c) IN(7, 8, 9)
			THEN DATEFROMPARTS(YEAR(a.Created_Date_Time__c), 7, 1)
			WHEN MONTH(a.Created_Date_Time__c) IN(10, 11, 12)
			THEN DATEFROMPARTS(YEAR(a.Created_Date_Time__c), 10, 1)
		END AS Lead_Created_Quarter, 
		(YEAR(GETDATE()) - YEAR(a.Created_Date_Time__c)) * 12 + (MONTH(GETDATE()) - MONTH(a.Created_Date_Time__c)) AS Mos_Since_Created_Date,
		CASE
			WHEN a.First_Contact__c IS NOT NULL
			THEN CAST(a.First_Contact__c AS DATE)
			WHEN a.Scheduled_Date__c IS NOT NULL
			THEN CAST(a.Created_Date_Time__c AS DATE)
			WHEN a.Scheduled_Date__c IS NOT NULL
					AND a.First_Contact__c IS NULL
			THEN CAST(a.Scheduled_Date__c AS DATE)
			WHEN a.Consult_Date__c IS NOT NULL
					AND a.First_Contact__c IS NULL
			THEN CAST(a.Consult_Date__c AS DATE)
			WHEN a.Converted_Date__c IS NOT NULL
					AND a.First_Contact__c IS NULL
			THEN CAST(a.Converted_Date__c AS DATE)
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
					AND a.First_Contact__c IS NULL
			THEN CAST(a.ClinCheck_Accepted_Date__c AS DATE)
			ELSE a.First_Contact__c
		END AS First_Contact_Date, 
		DATEFROMPARTS(YEAR(CASE
                              WHEN a.First_Contact__c IS NOT NULL
                              THEN a.First_Contact__c
                              WHEN a.Scheduled_Date__c IS NOT NULL
                              THEN a.Created_Date_Time__c
                              ELSE a.First_Contact__c
                          END), MONTH(CASE
                                          WHEN a.First_Contact__c IS NOT NULL
                                          THEN a.First_Contact__c
                                          WHEN a.Scheduled_Date__c IS NOT NULL
                                          THEN a.Created_Date_Time__c
                                          ELSE a.First_Contact__c
                                      END), 1) AS First_Contact_Month,
		CASE
			WHEN a.First_Contact__c IS NULL
			THEN 0
			ELSE(YEAR(GETDATE()) - YEAR(CASE
                                           WHEN a.First_Contact__c IS NOT NULL
                                           THEN a.First_Contact__c
                                           WHEN a.Scheduled_Date__c IS NOT NULL
                                           THEN a.Created_Date_Time__c
                                           ELSE a.First_Contact__c
                                       END)) * 12 + (MONTH(GETDATE()) - MONTH(CASE
                                                                                  WHEN a.First_Contact__c IS NOT NULL
                                                                                  THEN a.First_Contact__c
                                                                                  WHEN a.Scheduled_Date__c IS NOT NULL
                                                                                  THEN a.Created_Date_Time__c
                                                                                  ELSE a.First_Contact__c
                                                                              END))
		END AS Mos_Since_First_Contact_Date,
		CASE
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.First_Contact__c IS NULL
                AND a.Scheduled_Date__c < a.Created_Date_Time__c
			THEN CAST(a.Created_Date_Time__c AS DATE)
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.First_Contact__c IS NOT NULL
                AND a.Scheduled_Date__c < a.First_Contact__c
			THEN CAST(a.First_Contact__c AS DATE)
			WHEN a.Consult_Date__c IS NOT NULL
                AND a.Scheduled_Date__c IS NULL
			THEN CAST(a.Consult_Date__c AS DATE)
			WHEN a.Converted_Date__c IS NOT NULL
                AND a.Scheduled_Date__c IS NULL
			THEN CAST(a.Converted_Date__c AS DATE)
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
                AND a.Scheduled_Date__c IS NULL
			THEN CAST(a.ClinCheck_Accepted_Date__c AS DATE)
			ELSE CAST(a.Scheduled_Date__c AS DATE)
		END AS Scheduled_Date, 
		DATEFROMPARTS(YEAR(a.Scheduled_Date__c), MONTH(a.Scheduled_Date__c), 1) AS Scheduled_Month,
		CASE
			WHEN a.Scheduled_Date__c IS NULL
			THEN 0
			ELSE(YEAR(GETDATE()) - YEAR(a.Scheduled_Date__c)) * 12 + (MONTH(GETDATE()) - MONTH(a.Scheduled_Date__c))
		END AS Mos_Since_Scheduled_Date,
		CASE
			WHEN a.Converted_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NULL
			THEN CAST(a.Converted_Date__c AS DATE)
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NULL
			THEN CAST(a.ClinCheck_Accepted_Date__c AS DATE)
			ELSE CAST(a.Consult_Date__c AS DATE)
		END AS Consultation_Date,
		CASE
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
			THEN 1
			WHEN a.Converted_Date__c IS NOT NULL
			THEN 1
			WHEN a.Consult_Date__c IS NOT NULL
				AND a.Consult_Date__c <= GETDATE()
			THEN 1
			ELSE 0
		END AS Lapsed_Consults,
		CASE
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
                AND a.Converted_Date__c IS NULL
			THEN CAST(a.ClinCheck_Accepted_Date__c AS DATE)
			ELSE CAST(a.Converted_Date__c AS DATE)
		END AS Converted_Date, 
		DATEFROMPARTS(YEAR(CAST(a.Converted_Date__c AS DATE)), MONTH(CAST(a.Converted_Date__c AS DATE)), 1) AS Converted_Month,
		CASE
			WHEN DATEADD(dd, 30, a.Created_Date_Time__c) >= a.Converted_Date__c
			THEN 1
			ELSE 0
		END AS Converted_Within_30_Days,
		CASE
			WHEN DATEADD(dd, 60, a.Created_Date_Time__c) >= a.Converted_Date__c
			THEN 1
			ELSE 0
		END AS Converted_Within_60_Days,
		CASE
			WHEN a.Converted_Date__c IS NULL
			THEN 0
			ELSE(YEAR(GETDATE()) - YEAR(a.Converted_Date__c)) * 12 + (MONTH(GETDATE()) - MONTH(a.Converted_Date__c))
		END AS Mos_Since_Converted_Date, 
		CAST(a.ClinCheck_Accepted_Date__c AS DATE) AS CCA_Date, 
		a.DID__c AS DID, 
		cn.Clinician_Id__C AS ClinID, 
		cn.Name AS Doctor_Name,
		CASE
           WHEN cn.MailingCountry  IS NOT NULL
                AND cn.MailingCity  NOT IN('', ' ')
                AND cn.MailingCity IS NOT NULL
                AND cn.MailingState NOT IN('', ' ')
			THEN concat(cn.MailingCity, ', ', cn.MailingState)
			ELSE ''
		END AS City_State, 
		d.Account_Number__c AS LID,
		CASE
			WHEN LOWER(Prospect_Status__c) = 'not interested'
			THEN 1
			ELSE 0
		END AS Not_Interested,
		CASE
			WHEN LOWER(Prospect_Status__c) = 'bad data'
			THEN 1
			ELSE 0
		END AS Bad_Data,
		CASE
			WHEN LOWER(Prospect_Status__c) = 'in progress'
			THEN 1
			ELSE 0
		END AS in_Progress,
		a.SystemModstamp
FROM (SELECT Id,Country,Zip__c,Age__c,Created_Date_Time__c,First_Contact__c,Scheduled_Date__c,Consult_Date__c
			,ClinCheck_Accepted_Date__c,LeadSource,SA_Prospect_Status__c,Prospect_Status__c,I_am__c
			,Converted_Date__c,DID__c,RecordTypeId,OwnerId,Account__c,SystemModstamp,Lead_Region__c,Lead_URL_Campaign__c,Lead_URL_Content__c
			,Lead_URL_Medium__c,Lead_URL_Source__c,Lead_URL_Term__c, Unsubscribe__c, Et4ae5__HasOptedOutOfMobile__C 
			FROM SrcSFDC.LEAD WHERE SystemModstamp >= (SELECT ISNULL(MAX(SystemModstamp), '1900-01-01') FROM [DWCONSDL].[FactLead] WHERE Region = 'EMEA')) a
INNER JOIN SrcSFDC.RecordType b ON a.RecordTypeId = b.Id
LEFT JOIN SrcSFDC."User" c ON a.OwnerId = c.Id
LEFT JOIN SrcSFDC."UserRole" r ON c.UserRoleId = r.Id
LEFT JOIN SrcSFDC.Account d ON a.Account__c = d.Id
LEFT JOIN SrcSFDC.Contact cn on Coalesce(a.DID__c,d.Account_Number__c )= cn.account_Number__C and cn.Contact_Type__C='Doctor'
LEFT JOIN
(
    SELECT LeadID, 
           COUNT(*) AS LeadsHistory_Records, 
           MAX(CASE
                   WHEN Field IN('Owner')
                   THEN 1
                   ELSE 0
               END) AS Has_Owner_Record
    FROM SrcSFDC.LeadHistory
    GROUP BY LeadID
) f ON a.ID = f.LeadID
     LEFT JOIN
(
    SELECT DISTINCT 
           LeadID
    FROM SrcSFDC.LeadHistory
    WHERE NewValue IN ('Consumer Journey')
) g ON a.ID = g.LeadID
WHERE a.Lead_Region__c ='EUROPE' AND b.Name IN ('Consumer') AND a.OwnerId <> '005i000000923svAAA'

UNION ALL		

-- LATAM REGION
SELECT 	CONVERT(CHAR(40), '') AS DWHashKey,
		a.Id,
		a.Lead_Region__c,
		'LATAM' AS Region,
		a.Country, 
		a.Lead_URL_Campaign__c,
		a.Lead_URL_Content__c,
		a.Lead_URL_Medium__c,
		a.Lead_URL_Source__c,
		a.Lead_URL_Term__c,
		a.Unsubscribe__c,
		a.Et4ae5__HasOptedOutOfMobile__C,
		cn.Professional_Category__c AS Channel, 
		SUBSTRING(a.Zip__c, 1, 5) AS Zip,
		NULL AS Lead_Assigned,	-- NEED LOGIC FOR LATAM IF REQUIRED
		CASE
			WHEN a.Age__c IS NULL
			THEN '6) Unknown'
			WHEN a.Age__c BETWEEN 6 AND 10
			THEN '1) Young Child (6-10)'
			WHEN a.Age__c BETWEEN 11 AND 17
			THEN '2) Teen/Tween (11-17)'
			WHEN a.Age__c BETWEEN 18 AND 24
			THEN '3) Young Adult/Cusper (18-24)'
			WHEN a.Age__c BETWEEN 25 AND 34
			THEN '4) Adult (25-34)'
			ELSE '5) Older Adult (35+)'
		END AS Age_Segment,
		CASE
			WHEN a.Age__c IS NULL
			THEN 'Unknown'
			WHEN a.Age__c <= 19
			THEN 'Teen (<19)'
			ELSE 'Adult (20+)'
		END AS Age_Group,
		CASE
			WHEN a.Created_Date_Time__c IS NOT NULL
				AND a.First_Contact__c IS NOT NULL
                AND DATEDIFF(DAY, a.Created_Date_Time__c, a.First_Contact__c) = 0
			THEN 'a) Same Day'
			WHEN a.Created_Date_Time__c IS NOT NULL
                AND a.First_Contact__c IS NOT NULL
                AND DATEDIFF(DAY, a.Created_Date_Time__c, a.First_Contact__c) BETWEEN 1 AND 7
			THEN 'b) 1-7 Days Later'
			WHEN a.Created_Date_Time__c IS NOT NULL
                AND a.First_Contact__c IS NOT NULL
                AND DATEDIFF(DAY, a.Created_Date_Time__c, a.First_Contact__c) BETWEEN 8 AND 100
			THEN 'c) 8 or More Days Later'
			ELSE 'd) N/A'
		END AS Days_Between_Create_Contact,
		CASE
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c) BETWEEN 0 AND 4
			THEN 'a) Within 4 Days'
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c) BETWEEN 4 AND 30
			THEN 'b) 4-30 Days'
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c) BETWEEN 31 AND 120
			THEN 'c) More Than 30 Days'
			ELSE 'd) N/A'
		END AS Days_Between_Schedule_Consult,
		CASE
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c) BETWEEN 0 AND 120
			THEN DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c)
			ELSE NULL
		END AS Days_Between_Schedule_Consult2,
		CASE
			WHEN a.Created_Date_Time__c IS NOT NULL
                AND a.ClinCheck_Accepted_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Created_Date_Time__c, a.ClinCheck_Accepted_Date__c) BETWEEN 0 AND 300
			THEN DATEDIFF(DAY, a.Created_Date_Time__c, a.ClinCheck_Accepted_Date__c)
			ELSE NULL
		END AS Days_Between_Create_CCA2,
		CASE
			WHEN a.LeadSource IN('Smile Assessment')
                AND a.SA_Prospect_Status__c IN('I''d like to set up an appointment for a consultation')
			THEN 'Smile Assessment - I''d like to set up an appointment for a consultation'
			WHEN a.LeadSource IN('Smile Assessment')
                AND a.SA_Prospect_Status__c IN('I''ve made an appointment for a consultation')
			THEN 'Smile Assessment - I''ve made an appointment for a consultation'
			WHEN a.LeadSource IN('Smile Assessment')
                AND a.SA_Prospect_Status__c IN('I''ve just started my research')
			THEN 'Smile Assessment - I''ve just started my research'
			WHEN a.LeadSource IN('Smile Assessment')
			THEN 'Smile Assessment - Blank'
			WHEN a.LeadSource IS NULL
			THEN 'Blank'
			WHEN a.LeadSource = 'Socail Media'
			THEN 'Social Media'
			ELSE RTRIM(LTRIM(a.LeadSource))
		END AS Lead_Source_Granular,
		CASE
			WHEN a.LeadSource IN('Doc Locator')
			THEN 'Doc Locator'
			WHEN a.SA_Prospect_Status__c IN('I''d like to set up an appointment for a consultation', 'I''ve made an appointment for a consultation')
			THEN 'SA - Appointment'
			WHEN a.LeadSource IN('Request Appointment')
			THEN 'Request Appointment'
			WHEN a.LeadSource IN('Smile Assessment')
			THEN 'SA - Research'
			WHEN a.SA_Prospect_Status__c IN('I''ve just started my research')
			THEN 'SA - Research'
			WHEN a.LeadSource IN('Social Media')
			THEN 'Social Media'
			WHEN a.LeadSource IN('SDC')
			THEN 'SDC'
			WHEN a.LeadSource IN('Web', 'Website')
			THEN 'Website'
			WHEN a.LeadSource IN('Scan Office')
			THEN 'Scan Office'
			WHEN a.LeadSource IN('Contact Us')
			THEN 'Contact Us'
				ELSE 'Other'
		END	 AS Lead_Source,
		a.LeadSource AS LeadSourceOriginal,
		CASE
			WHEN a.I_am__c = 'adult'
			THEN 'an adult'
			ELSE a.I_am__c
		END AS Age_Group2, 
		CAST(a.Created_Date_Time__c AS DATE) AS Lead_Created_Date, 
		CAST(DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEADD(DAY, -1, a.Created_Date_Time__c)), DATEADD(DAY, -1, a.Created_Date_Time__c)) AS DATE) AS Lead_Created_Week, 
		DATEFROMPARTS(YEAR(a.Created_Date_Time__c), MONTH(a.Created_Date_Time__c), 1) AS Lead_Created_Month,
		CASE
			WHEN MONTH(a.Created_Date_Time__c) IN(1, 2, 3)
			THEN DATEFROMPARTS(YEAR(a.Created_Date_Time__c), 1, 1)
			WHEN MONTH(a.Created_Date_Time__c) IN(4, 5, 6)
			THEN DATEFROMPARTS(YEAR(a.Created_Date_Time__c), 4, 1)
			WHEN MONTH(a.Created_Date_Time__c) IN(7, 8, 9)
			THEN DATEFROMPARTS(YEAR(a.Created_Date_Time__c), 7, 1)
			WHEN MONTH(a.Created_Date_Time__c) IN(10, 11, 12)
			THEN DATEFROMPARTS(YEAR(a.Created_Date_Time__c), 10, 1)
		END AS Lead_Created_Quarter, 
		(YEAR(GETDATE()) - YEAR(a.Created_Date_Time__c)) * 12 + (MONTH(GETDATE()) - MONTH(a.Created_Date_Time__c)) AS Mos_Since_Created_Date,
		CASE
			WHEN a.First_Contact__c IS NOT NULL
			THEN CAST(a.First_Contact__c AS DATE)
			WHEN a.Scheduled_Date__c IS NOT NULL
			THEN CAST(a.Created_Date_Time__c AS DATE)
			WHEN a.Scheduled_Date__c IS NOT NULL
					AND a.First_Contact__c IS NULL
			THEN CAST(a.Scheduled_Date__c AS DATE)
			WHEN a.Consult_Date__c IS NOT NULL
					AND a.First_Contact__c IS NULL
			THEN CAST(a.Consult_Date__c AS DATE)
			WHEN a.Converted_Date__c IS NOT NULL
					AND a.First_Contact__c IS NULL
			THEN CAST(a.Converted_Date__c AS DATE)
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
					AND a.First_Contact__c IS NULL
			THEN CAST(a.ClinCheck_Accepted_Date__c AS DATE)
			ELSE a.First_Contact__c
		END AS First_Contact_Date, 
		DATEFROMPARTS(YEAR(CASE
                              WHEN a.First_Contact__c IS NOT NULL
                              THEN a.First_Contact__c
                              WHEN a.Scheduled_Date__c IS NOT NULL
                              THEN a.Created_Date_Time__c
                              ELSE a.First_Contact__c
                          END), MONTH(CASE
                                          WHEN a.First_Contact__c IS NOT NULL
                                          THEN a.First_Contact__c
                                          WHEN a.Scheduled_Date__c IS NOT NULL
                                          THEN a.Created_Date_Time__c
                                          ELSE a.First_Contact__c
                                      END), 1) AS First_Contact_Month,
		CASE
			WHEN a.First_Contact__c IS NULL
			THEN 0
			ELSE(YEAR(GETDATE()) - YEAR(CASE
                                           WHEN a.First_Contact__c IS NOT NULL
                                           THEN a.First_Contact__c
                                           WHEN a.Scheduled_Date__c IS NOT NULL
                                           THEN a.Created_Date_Time__c
                                           ELSE a.First_Contact__c
                                       END)) * 12 + (MONTH(GETDATE()) - MONTH(CASE
                                                                                  WHEN a.First_Contact__c IS NOT NULL
                                                                                  THEN a.First_Contact__c
                                                                                  WHEN a.Scheduled_Date__c IS NOT NULL
                                                                                  THEN a.Created_Date_Time__c
                                                                                  ELSE a.First_Contact__c
                                                                              END))
		END AS Mos_Since_First_Contact_Date,
		CASE
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.First_Contact__c IS NULL
                AND a.Scheduled_Date__c < a.Created_Date_Time__c
			THEN CAST(a.Created_Date_Time__c AS DATE)
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.First_Contact__c IS NOT NULL
                AND a.Scheduled_Date__c < a.First_Contact__c
			THEN CAST(a.First_Contact__c AS DATE)
			WHEN a.Consult_Date__c IS NOT NULL
                AND a.Scheduled_Date__c IS NULL
			THEN CAST(a.Consult_Date__c AS DATE)
			WHEN a.Converted_Date__c IS NOT NULL
                AND a.Scheduled_Date__c IS NULL
			THEN CAST(a.Converted_Date__c AS DATE)
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
                AND a.Scheduled_Date__c IS NULL
			THEN CAST(a.ClinCheck_Accepted_Date__c AS DATE)
			ELSE CAST(a.Scheduled_Date__c AS DATE)
		END AS Scheduled_Date, 
		DATEFROMPARTS(YEAR(a.Scheduled_Date__c), MONTH(a.Scheduled_Date__c), 1) AS Scheduled_Month,
		CASE
			WHEN a.Scheduled_Date__c IS NULL
			THEN 0
			ELSE(YEAR(GETDATE()) - YEAR(a.Scheduled_Date__c)) * 12 + (MONTH(GETDATE()) - MONTH(a.Scheduled_Date__c))
		END AS Mos_Since_Scheduled_Date,
		CASE
			WHEN a.Converted_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NULL
			THEN CAST(a.Converted_Date__c AS DATE)
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NULL
			THEN CAST(a.ClinCheck_Accepted_Date__c AS DATE)
			ELSE CAST(a.Consult_Date__c AS DATE)
		END AS Consultation_Date,
		CASE
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
			THEN 1
			WHEN a.Converted_Date__c IS NOT NULL
			THEN 1
			WHEN a.Consult_Date__c IS NOT NULL
				AND a.Consult_Date__c <= GETDATE()
			THEN 1
			ELSE 0
		END AS Lapsed_Consults,
		CASE
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
                AND a.Converted_Date__c IS NULL
			THEN CAST(a.ClinCheck_Accepted_Date__c AS DATE)
			ELSE CAST(a.Converted_Date__c AS DATE)
		END AS Converted_Date, 
		DATEFROMPARTS(YEAR(CAST(a.Converted_Date__c AS DATE)), MONTH(CAST(a.Converted_Date__c AS DATE)), 1) AS Converted_Month,
		CASE
			WHEN DATEADD(dd, 30, a.Created_Date_Time__c) >= a.Converted_Date__c
			THEN 1
			ELSE 0
		END AS Converted_Within_30_Days,
		CASE
			WHEN DATEADD(dd, 60, a.Created_Date_Time__c) >= a.Converted_Date__c
			THEN 1
			ELSE 0
		END AS Converted_Within_60_Days,
		CASE
			WHEN a.Converted_Date__c IS NULL
			THEN 0
			ELSE(YEAR(GETDATE()) - YEAR(a.Converted_Date__c)) * 12 + (MONTH(GETDATE()) - MONTH(a.Converted_Date__c))
		END AS Mos_Since_Converted_Date, 
		CAST(a.ClinCheck_Accepted_Date__c AS DATE) AS CCA_Date, 
		a.DID__c AS DID, 
		cn.Clinician_Id__C AS ClinID, 
		cn.Name AS Doctor_Name,
		CASE
           WHEN cn.MailingCountry  IS NOT NULL
                AND cn.MailingCity  NOT IN('', ' ')
                AND cn.MailingCity IS NOT NULL
                AND cn.MailingState NOT IN('', ' ')
			THEN concat(cn.MailingCity, ', ', cn.MailingState)
			ELSE ''
		END AS City_State, 
		d.Account_Number__c AS LID,
		CASE
			WHEN LOWER(Prospect_Status__c) = 'not interested'
			THEN 1
			ELSE 0
		END AS Not_Interested,
		CASE
			WHEN LOWER(Prospect_Status__c) = 'bad data'
			THEN 1
			ELSE 0
		END AS Bad_Data,
		CASE
			WHEN LOWER(Prospect_Status__c) = 'in progress'
			THEN 1
			ELSE 0
		END AS in_Progress,
		a.SystemModstamp
FROM (SELECT Id,Country,Zip__c,Age__c,Created_Date_Time__c,First_Contact__c,Scheduled_Date__c,Consult_Date__c
			,ClinCheck_Accepted_Date__c,LeadSource,SA_Prospect_Status__c,Prospect_Status__c,I_am__c
			,Converted_Date__c,DID__c,RecordTypeId,OwnerId,Account__c,SystemModstamp,Lead_Region__c,Lead_URL_Campaign__c,Lead_URL_Content__c
			,Lead_URL_Medium__c,Lead_URL_Source__c,Lead_URL_Term__c, Unsubscribe__c, Et4ae5__HasOptedOutOfMobile__C  
			FROM SrcSFDC.LEAD WHERE SystemModstamp >= (SELECT ISNULL(MAX(SystemModstamp), '1900-01-01') FROM [DWCONSDL].[FactLead]  WHERE Region = 'LATAM' )) a
INNER JOIN SrcSFDC.RecordType b ON a.RecordTypeId = b.Id
LEFT JOIN SrcSFDC."User" c ON a.OwnerId = c.Id
LEFT JOIN SrcSFDC."UserRole" r ON c.UserRoleId = r.Id
LEFT JOIN SrcSFDC.Account d ON a.Account__c = d.Id
LEFT JOIN SrcSFDC.Contact cn on Coalesce(a.DID__c,d.Account_Number__c )= cn.account_Number__C and cn.Contact_Type__C='Doctor'
LEFT JOIN
(
    SELECT LeadID, 
           COUNT(*) AS LeadsHistory_Records, 
           MAX(CASE
                   WHEN Field IN('Owner')
                   THEN 1
                   ELSE 0
               END) AS Has_Owner_Record
    FROM SrcSFDC.LeadHistory
    GROUP BY LeadID
) f ON a.ID = f.LeadID
     LEFT JOIN
(
    SELECT DISTINCT 
           LeadID
    FROM SrcSFDC.LeadHistory
    WHERE NewValue IN ('Consumer Journey')
) g ON a.ID = g.LeadID
WHERE a.Country IN ('Argentina',
'Bolivia',
'Brazil',
'Cayman Islands',
'Chile',
'Colombia',
'Costa Rica',
'Dominican Republic',
'Ecuador',
'El Salvador',
'French Guiana',
'Grenada',
'Guadeloupe',
'Guatemala',
'Guyana',
'Honduras',
'Jamaica',
'Martinique',
'Mexico',
'Nicaragua',
'Panama',
'Paraguay',
'Peru',
'Saint Barthelemy',
'Saint Kitts and Nevis',
'Trinidad and Tobago',
'Uruguay',
'Venezuela') AND b.Name IN ('Consumer')


UNION ALL		

-- APAC REGION
SELECT 	CONVERT(CHAR(40), '') AS DWHashKey,
		a.Id,
		a.Lead_Region__c,
		'APAC' AS Region,
		a.Country, 
		a.Lead_URL_Campaign__c,
		a.Lead_URL_Content__c,
		a.Lead_URL_Medium__c,
		a.Lead_URL_Source__c,
		a.Lead_URL_Term__c,
		a.Unsubscribe__c,
		a.Et4ae5__HasOptedOutOfMobile__C,
		cn.Professional_Category__c AS Channel, 
		SUBSTRING(a.Zip__c, 1, 5) AS Zip,
		NULL AS Lead_Assigned,	-- NEED LOGIC FOR APAC IF REQUIRED
		CASE
			WHEN a.Age__c IS NULL
			THEN '6) Unknown'
			WHEN a.Age__c BETWEEN 6 AND 10
			THEN '1) Young Child (6-10)'
			WHEN a.Age__c BETWEEN 11 AND 17
			THEN '2) Teen/Tween (11-17)'
			WHEN a.Age__c BETWEEN 18 AND 24
			THEN '3) Young Adult/Cusper (18-24)'
			WHEN a.Age__c BETWEEN 25 AND 34
			THEN '4) Adult (25-34)'
			ELSE '5) Older Adult (35+)'
		END AS Age_Segment,
		CASE
			WHEN a.Age__c IS NULL
			THEN 'Unknown'
			WHEN a.Age__c <= 19
			THEN 'Teen (<19)'
			ELSE 'Adult (20+)'
		END AS Age_Group,
		CASE
			WHEN a.Created_Date_Time__c IS NOT NULL
				AND a.First_Contact__c IS NOT NULL
                AND DATEDIFF(DAY, a.Created_Date_Time__c, a.First_Contact__c) = 0
			THEN 'a) Same Day'
			WHEN a.Created_Date_Time__c IS NOT NULL
                AND a.First_Contact__c IS NOT NULL
                AND DATEDIFF(DAY, a.Created_Date_Time__c, a.First_Contact__c) BETWEEN 1 AND 7
			THEN 'b) 1-7 Days Later'
			WHEN a.Created_Date_Time__c IS NOT NULL
                AND a.First_Contact__c IS NOT NULL
                AND DATEDIFF(DAY, a.Created_Date_Time__c, a.First_Contact__c) BETWEEN 8 AND 100
			THEN 'c) 8 or More Days Later'
			ELSE 'd) N/A'
		END AS Days_Between_Create_Contact,
		CASE
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c) BETWEEN 0 AND 4
			THEN 'a) Within 4 Days'
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c) BETWEEN 4 AND 30
			THEN 'b) 4-30 Days'
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c) BETWEEN 31 AND 120
			THEN 'c) More Than 30 Days'
			ELSE 'd) N/A'
		END AS Days_Between_Schedule_Consult,
		CASE
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c) BETWEEN 0 AND 120
			THEN DATEDIFF(DAY, a.Scheduled_Date__c, a.Consult_Date__c)
			ELSE NULL
		END AS Days_Between_Schedule_Consult2,
		CASE
			WHEN a.Created_Date_Time__c IS NOT NULL
                AND a.ClinCheck_Accepted_Date__c IS NOT NULL
                AND DATEDIFF(DAY, a.Created_Date_Time__c, a.ClinCheck_Accepted_Date__c) BETWEEN 0 AND 300
			THEN DATEDIFF(DAY, a.Created_Date_Time__c, a.ClinCheck_Accepted_Date__c)
			ELSE NULL
		END AS Days_Between_Create_CCA2,
		CASE
			WHEN a.LeadSource IN('Smile Assessment')
                AND a.SA_Prospect_Status__c IN('I''d like to set up an appointment for a consultation')
			THEN 'Smile Assessment - I''d like to set up an appointment for a consultation'
			WHEN a.LeadSource IN('Smile Assessment')
                AND a.SA_Prospect_Status__c IN('I''ve made an appointment for a consultation')
			THEN 'Smile Assessment - I''ve made an appointment for a consultation'
			WHEN a.LeadSource IN('Smile Assessment')
                AND a.SA_Prospect_Status__c IN('I''ve just started my research')
			THEN 'Smile Assessment - I''ve just started my research'
			WHEN a.LeadSource IN('Smile Assessment')
			THEN 'Smile Assessment - Blank'
			WHEN a.LeadSource IS NULL
			THEN 'Blank'
			WHEN a.LeadSource = 'Socail Media'
			THEN 'Social Media'
			ELSE RTRIM(LTRIM(a.LeadSource))
		END AS Lead_Source_Granular,
		CASE
			WHEN a.LeadSource IN('Doc Locator')
			THEN 'Doc Locator'
			WHEN a.SA_Prospect_Status__c IN('I''d like to set up an appointment for a consultation', 'I''ve made an appointment for a consultation')
			THEN 'SA - Appointment'
			WHEN a.LeadSource IN('Request Appointment')
			THEN 'Request Appointment'
			WHEN a.LeadSource IN('Smile Assessment')
			THEN 'SA - Research'
			WHEN a.SA_Prospect_Status__c IN('I''ve just started my research')
			THEN 'SA - Research'
			WHEN a.LeadSource IN('Social Media')
			THEN 'Social Media'
			WHEN a.LeadSource IN('SDC')
			THEN 'SDC'
			WHEN a.LeadSource IN('Web', 'Website')
			THEN 'Website'
			WHEN a.LeadSource IN('Scan Office')
			THEN 'Scan Office'
			WHEN a.LeadSource IN('Contact Us')
			THEN 'Contact Us'
				ELSE 'Other'
		END	 AS Lead_Source,
		a.LeadSource AS LeadSourceOriginal,
		CASE
			WHEN a.I_am__c = 'adult'
			THEN 'an adult'
			ELSE a.I_am__c
		END AS Age_Group2, 
		CAST(a.Created_Date_Time__c AS DATE) AS Lead_Created_Date, 
		CAST(DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEADD(DAY, -1, a.Created_Date_Time__c)), DATEADD(DAY, -1, a.Created_Date_Time__c)) AS DATE) AS Lead_Created_Week, 
		DATEFROMPARTS(YEAR(a.Created_Date_Time__c), MONTH(a.Created_Date_Time__c), 1) AS Lead_Created_Month,
		CASE
			WHEN MONTH(a.Created_Date_Time__c) IN(1, 2, 3)
			THEN DATEFROMPARTS(YEAR(a.Created_Date_Time__c), 1, 1)
			WHEN MONTH(a.Created_Date_Time__c) IN(4, 5, 6)
			THEN DATEFROMPARTS(YEAR(a.Created_Date_Time__c), 4, 1)
			WHEN MONTH(a.Created_Date_Time__c) IN(7, 8, 9)
			THEN DATEFROMPARTS(YEAR(a.Created_Date_Time__c), 7, 1)
			WHEN MONTH(a.Created_Date_Time__c) IN(10, 11, 12)
			THEN DATEFROMPARTS(YEAR(a.Created_Date_Time__c), 10, 1)
		END AS Lead_Created_Quarter, 
		(YEAR(GETDATE()) - YEAR(a.Created_Date_Time__c)) * 12 + (MONTH(GETDATE()) - MONTH(a.Created_Date_Time__c)) AS Mos_Since_Created_Date,
		CASE
			WHEN a.First_Contact__c IS NOT NULL
			THEN CAST(a.First_Contact__c AS DATE)
			WHEN a.Scheduled_Date__c IS NOT NULL
			THEN CAST(a.Created_Date_Time__c AS DATE)
			WHEN a.Scheduled_Date__c IS NOT NULL
					AND a.First_Contact__c IS NULL
			THEN CAST(a.Scheduled_Date__c AS DATE)
			WHEN a.Consult_Date__c IS NOT NULL
					AND a.First_Contact__c IS NULL
			THEN CAST(a.Consult_Date__c AS DATE)
			WHEN a.Converted_Date__c IS NOT NULL
					AND a.First_Contact__c IS NULL
			THEN CAST(a.Converted_Date__c AS DATE)
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
					AND a.First_Contact__c IS NULL
			THEN CAST(a.ClinCheck_Accepted_Date__c AS DATE)
			ELSE a.First_Contact__c
		END AS First_Contact_Date, 
		DATEFROMPARTS(YEAR(CASE
                              WHEN a.First_Contact__c IS NOT NULL
                              THEN a.First_Contact__c
                              WHEN a.Scheduled_Date__c IS NOT NULL
                              THEN a.Created_Date_Time__c
                              ELSE a.First_Contact__c
                          END), MONTH(CASE
                                          WHEN a.First_Contact__c IS NOT NULL
                                          THEN a.First_Contact__c
                                          WHEN a.Scheduled_Date__c IS NOT NULL
                                          THEN a.Created_Date_Time__c
                                          ELSE a.First_Contact__c
                                      END), 1) AS First_Contact_Month,
		CASE
			WHEN a.First_Contact__c IS NULL
			THEN 0
			ELSE(YEAR(GETDATE()) - YEAR(CASE
                                           WHEN a.First_Contact__c IS NOT NULL
                                           THEN a.First_Contact__c
                                           WHEN a.Scheduled_Date__c IS NOT NULL
                                           THEN a.Created_Date_Time__c
                                           ELSE a.First_Contact__c
                                       END)) * 12 + (MONTH(GETDATE()) - MONTH(CASE
                                                                                  WHEN a.First_Contact__c IS NOT NULL
                                                                                  THEN a.First_Contact__c
                                                                                  WHEN a.Scheduled_Date__c IS NOT NULL
                                                                                  THEN a.Created_Date_Time__c
                                                                                  ELSE a.First_Contact__c
                                                                              END))
		END AS Mos_Since_First_Contact_Date,
		CASE
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.First_Contact__c IS NULL
                AND a.Scheduled_Date__c < a.Created_Date_Time__c
			THEN CAST(a.Created_Date_Time__c AS DATE)
			WHEN a.Scheduled_Date__c IS NOT NULL
                AND a.First_Contact__c IS NOT NULL
                AND a.Scheduled_Date__c < a.First_Contact__c
			THEN CAST(a.First_Contact__c AS DATE)
			WHEN a.Consult_Date__c IS NOT NULL
                AND a.Scheduled_Date__c IS NULL
			THEN CAST(a.Consult_Date__c AS DATE)
			WHEN a.Converted_Date__c IS NOT NULL
                AND a.Scheduled_Date__c IS NULL
			THEN CAST(a.Converted_Date__c AS DATE)
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
                AND a.Scheduled_Date__c IS NULL
			THEN CAST(a.ClinCheck_Accepted_Date__c AS DATE)
			ELSE CAST(a.Scheduled_Date__c AS DATE)
		END AS Scheduled_Date, 
		DATEFROMPARTS(YEAR(a.Scheduled_Date__c), MONTH(a.Scheduled_Date__c), 1) AS Scheduled_Month,
		CASE
			WHEN a.Scheduled_Date__c IS NULL
			THEN 0
			ELSE(YEAR(GETDATE()) - YEAR(a.Scheduled_Date__c)) * 12 + (MONTH(GETDATE()) - MONTH(a.Scheduled_Date__c))
		END AS Mos_Since_Scheduled_Date,
		CASE
			WHEN a.Converted_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NULL
			THEN CAST(a.Converted_Date__c AS DATE)
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
                AND a.Consult_Date__c IS NULL
			THEN CAST(a.ClinCheck_Accepted_Date__c AS DATE)
			ELSE CAST(a.Consult_Date__c AS DATE)
		END AS Consultation_Date,
		CASE
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
			THEN 1
			WHEN a.Converted_Date__c IS NOT NULL
			THEN 1
			WHEN a.Consult_Date__c IS NOT NULL
				AND a.Consult_Date__c <= GETDATE()
			THEN 1
			ELSE 0
		END AS Lapsed_Consults,
		CASE
			WHEN a.ClinCheck_Accepted_Date__c IS NOT NULL
                AND a.Converted_Date__c IS NULL
			THEN CAST(a.ClinCheck_Accepted_Date__c AS DATE)
			ELSE CAST(a.Converted_Date__c AS DATE)
		END AS Converted_Date, 
		DATEFROMPARTS(YEAR(CAST(a.Converted_Date__c AS DATE)), MONTH(CAST(a.Converted_Date__c AS DATE)), 1) AS Converted_Month,
		CASE
			WHEN DATEADD(dd, 30, a.Created_Date_Time__c) >= a.Converted_Date__c
			THEN 1
			ELSE 0
		END AS Converted_Within_30_Days,
		CASE
			WHEN DATEADD(dd, 60, a.Created_Date_Time__c) >= a.Converted_Date__c
			THEN 1
			ELSE 0
		END AS Converted_Within_60_Days,
		CASE
			WHEN a.Converted_Date__c IS NULL
			THEN 0
			ELSE(YEAR(GETDATE()) - YEAR(a.Converted_Date__c)) * 12 + (MONTH(GETDATE()) - MONTH(a.Converted_Date__c))
		END AS Mos_Since_Converted_Date, 
		CAST(a.ClinCheck_Accepted_Date__c AS DATE) AS CCA_Date, 
		a.DID__c AS DID, 
		cn.Clinician_Id__C AS ClinID, 
		cn.Name AS Doctor_Name,
		CASE
           WHEN cn.MailingCountry  IS NOT NULL
                AND cn.MailingCity  NOT IN('', ' ')
                AND cn.MailingCity IS NOT NULL
                AND cn.MailingState NOT IN('', ' ')
			THEN concat(cn.MailingCity, ', ', cn.MailingState)
			ELSE ''
		END AS City_State, 
		d.Account_Number__c AS LID,
		CASE
			WHEN LOWER(Prospect_Status__c) = 'not interested'
			THEN 1
			ELSE 0
		END AS Not_Interested,
		CASE
			WHEN LOWER(Prospect_Status__c) = 'bad data'
			THEN 1
			ELSE 0
		END AS Bad_Data,
		CASE
			WHEN LOWER(Prospect_Status__c) = 'in progress'
			THEN 1
			ELSE 0
		END AS in_Progress,
		a.SystemModstamp
FROM (SELECT Id,Country,Zip__c,Age__c,Created_Date_Time__c,First_Contact__c,Scheduled_Date__c,Consult_Date__c
			,ClinCheck_Accepted_Date__c,LeadSource,SA_Prospect_Status__c,Prospect_Status__c,I_am__c
			,Converted_Date__c,DID__c,RecordTypeId,OwnerId,Account__c,SystemModstamp,Lead_Region__c,Lead_URL_Campaign__c,Lead_URL_Content__c
			,Lead_URL_Medium__c,Lead_URL_Source__c,Lead_URL_Term__c, Unsubscribe__c, Et4ae5__HasOptedOutOfMobile__C  
			FROM SrcSFDC.LEAD WHERE SystemModstamp >= (SELECT ISNULL(MAX(SystemModstamp), '1900-01-01') FROM [DWCONSDL].[FactLead]  WHERE Region = 'APAC' )) a
     INNER JOIN SrcSFDC.RecordType b ON a.RecordTypeId = b.Id
     LEFT JOIN SrcSFDC."User" c ON a.OwnerId = c.Id
     LEFT JOIN SrcSFDC."UserRole" r ON c.UserRoleId = r.Id
     LEFT JOIN SrcSFDC.Account d ON a.Account__c = d.Id
     LEFT JOIN SrcSFDC.Contact cn on Coalesce(a.DID__c,d.Account_Number__c )= cn.account_Number__C and cn.Contact_Type__C='Doctor'
     LEFT JOIN
(
    SELECT LeadID, 
           COUNT(*) AS LeadsHistory_Records, 
           MAX(CASE
                   WHEN Field IN('Owner')
                   THEN 1
                   ELSE 0
               END) AS Has_Owner_Record
    FROM SrcSFDC.LeadHistory
    GROUP BY LeadID
) f ON a.ID = f.LeadID
     LEFT JOIN
(
    SELECT DISTINCT 
           LeadID
    FROM SrcSFDC.LeadHistory
    WHERE NewValue IN ('Consumer Journey')
) g ON a.ID = g.LeadID
WHERE (a.Lead_Region__c IN ('APAC -Others','APAC -China','APAC -HongKong','APAC -Japan','APAC -Australia') OR a.Country IN ('Fiji','Nepal','Pakistan','Sri Lanka',''))
AND b.Name IN ('Consumer');


update #TempFactLead set DWHashKey=
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, Country), N'N/A')
				    + N'|' + isnull(convert(nvarchar,Lead_URL_Campaign__c), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Lead_URL_Content__c), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Lead_URL_Medium__c), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Lead_URL_Source__c), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Lead_URL_Term__c), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Unsubscribe__c), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Et4ae5__HasOptedOutOfMobile__C), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Channel), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Zip), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Lead_Assigned), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Age_Segment), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Age_Group), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Days_Between_Create_Contact), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Days_Between_Schedule_Consult), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Days_Between_Schedule_Consult2), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Days_Between_Create_CCA2), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Lead_Source_Granular), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Lead_Source), N'N/A')
					+ N'|' + isnull(convert(nvarchar,LeadSourceOriginal), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Age_Group2), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Lead_Created_Date), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Lead_Created_Week), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Lead_Created_Month), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Lead_Created_Quarter), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Mos_Since_Created_Date), N'N/A')
					+ N'|' + isnull(convert(nvarchar,First_Contact_Date), N'N/A')
					+ N'|' + isnull(convert(nvarchar,First_Contact_Month), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Mos_Since_First_Contact_Date), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Scheduled_Date), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Scheduled_Month), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Mos_Since_Scheduled_Date), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Consultation_Date), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Lapsed_Consults), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Converted_Date), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Converted_Within_30_Days), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Converted_Within_30_Days), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Mos_Since_Converted_Date), N'N/A')
					+ N'|' + isnull(convert(nvarchar,CCA_Date), N'N/A')
					+ N'|' + isnull(convert(nvarchar,DID), N'N/A')
					+ N'|' + isnull(convert(nvarchar,ClinID), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Doctor_Name), N'N/A')
					+ N'|' + isnull(convert(nvarchar,City_State), N'N/A')
					+ N'|' + isnull(convert(nvarchar,LID), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Not_Interested), N'N/A')
					+ N'|' + isnull(convert(nvarchar,Bad_Data), N'N/A')
					+ N'|' + isnull(convert(nvarchar,In_Progress), N'N/A')
					+ N'|' + isnull(convert(nvarchar,SystemModstamp), N'N/A')
				)
			, 2)

 	
	update DWCONSDL.FactLead
		set	DWBatchID 									= 			@BatchID
		,	DWHashKey									=			src.DWHashKey
		,	Country                                     =           src.Country
		,	Lead_URL_Campaign__c                		=           src.Lead_URL_Campaign__c
		,	Lead_URL_Content__c                			=           src.Lead_URL_Content__c
		,	Lead_URL_Medium__c                			=           src.Lead_URL_Medium__c
		,	Lead_URL_Source__c                			=           src.Lead_URL_Source__c
		,	Lead_URL_Term__c                			=           src.Lead_URL_Term__c
		,	Unsubscribe__c                				=           src.Unsubscribe__c
		,	Et4ae5__HasOptedOutOfMobile__C              =           src.Et4ae5__HasOptedOutOfMobile__C
		,	Channel                						=           src.Channel
		,	Zip                							=           src.Zip
		,	Lead_Assigned                				=           src.Lead_Assigned
		,	Age_Segment                					=           src.Age_Segment
		,	Age_Group                					=           src.Age_Group
		,	Days_Between_Create_Contact                	=           src.Days_Between_Create_Contact
		,	Days_Between_Schedule_Consult               =           src.Days_Between_Schedule_Consult
		,	Days_Between_Schedule_Consult2              =           src.Days_Between_Schedule_Consult2
		,	Days_Between_Create_CCA2                	=           src.Days_Between_Create_CCA2
		,	Lead_Source_Granular                		=           src.Lead_Source_Granular
		,	Lead_Source                					=           src.Lead_Source
		,	LeadSourceOriginal                			=           src.LeadSourceOriginal
		,	Age_Group2                					=           src.Age_Group2
		,	Lead_Created_Date                			=           src.Lead_Created_Date
		,	Lead_Created_Week                			=           src.Lead_Created_Week
		,	Lead_Created_Month                			=           src.Lead_Created_Month
		,	Lead_Created_Quarter                		=           src.Lead_Created_Quarter
		,	Mos_Since_Created_Date                		=           src.Mos_Since_Created_Date
		,	First_Contact_Date                			=           src.First_Contact_Date
		,	First_Contact_Month                			=           src.First_Contact_Month
		,	Mos_Since_First_Contact_Date                =           src.Mos_Since_First_Contact_Date
		,	Scheduled_Date                				=           src.Scheduled_Date
		,	Scheduled_Month                				=           src.Scheduled_Month
		,	Mos_Since_Scheduled_Date                	=           src.Mos_Since_Scheduled_Date
		,	Consultation_Date                			=           src.Consultation_Date
		,	Lapsed_Consults                				=           src.Lapsed_Consults
		,	Converted_Date                				=           src.Converted_Date
		,	Converted_Within_30_Days                	=           src.Converted_Within_30_Days
		,	Converted_Within_60_Days                	=           src.Converted_Within_60_Days
		,	Mos_Since_Converted_Date                	=           src.Mos_Since_Converted_Date
		,	CCA_Date                					=           src.CCA_Date
		,	DID                							=           src.DID
		,	ClinID                						=           src.ClinID
		,	Doctor_Name                					=           src.Doctor_Name
		,	City_State                					=           src.City_State
		,	LID                							=           src.LID
		,	Not_Interested                				=           src.Not_Interested
		,	Bad_Data                					=           src.Bad_Data
		,	In_Progress                					=           src.In_Progress
		,	SystemModstamp								=			src.SystemModstamp
		,	ModifiedDate								=			@CurrentDateTime
	from #TempFactLead src
	where DWCONSDL.FactLead.Id = src.Id
		and DWCONSDL.FactLead.DWHashKey != src.DWHashKey
	option (label = 'DWCONSDL.LoadFactLead_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactLead_Update', @rc = @RowsUpdated out

	insert into DWCONSDL.FactLead (
			DWBatchID
		,	DWHashKey
		,	Id
		,	Lead_Region__c
		,	Region
		,	Country
		,	Lead_URL_Campaign__c
		,	Lead_URL_Content__c
		,	Lead_URL_Medium__c
		,	Lead_URL_Source__c
		,	Lead_URL_Term__c
		,	Unsubscribe__c
		,	Et4ae5__HasOptedOutOfMobile__C
		,	Channel
		,	Zip
		,	Lead_Assigned
		,	Age_Segment
		,	Age_Group
		,	Days_Between_Create_Contact
		,	Days_Between_Schedule_Consult
		,	Days_Between_Schedule_Consult2
		,	Days_Between_Create_CCA2
		,	Lead_Source_Granular
		,	Lead_Source
		,	LeadSourceOriginal
		,	Age_Group2
		,	Lead_Created_Date
		,	Lead_Created_Week
		,	Lead_Created_Month
		,	Lead_Created_Quarter
		,	Mos_Since_Created_Date
		,	First_Contact_Date
		,	First_Contact_Month
		,	Mos_Since_First_Contact_Date
		,	Scheduled_Date
		,	Scheduled_Month
		,	Mos_Since_Scheduled_Date
		,	Consultation_Date
		,	Lapsed_Consults
		,	Converted_Date
		,	Converted_Within_30_Days
		,	Converted_Within_60_Days
		,	Mos_Since_Converted_Date
		,	CCA_Date
		,	DID
		,	ClinID
		,	Doctor_Name
		,	City_State
		,	LID
		,	Not_Interested
		,	Bad_Data
		,	In_Progress
		,	SystemModstamp
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	DWHashKey
		,	Id
		,	Lead_Region__c
		,	Region
		,	Country
		,	Lead_URL_Campaign__c
		,	Lead_URL_Content__c
		,	Lead_URL_Medium__c
		,	Lead_URL_Source__c
		,	Lead_URL_Term__c
		,	Unsubscribe__c
		,	Et4ae5__HasOptedOutOfMobile__C
		,	Channel
		,	Zip
		,	Lead_Assigned
		,	Age_Segment
		,	Age_Group
		,	Days_Between_Create_Contact
		,	Days_Between_Schedule_Consult
		,	Days_Between_Schedule_Consult2
		,	Days_Between_Create_CCA2
		,	Lead_Source_Granular
		,	Lead_Source
		,	LeadSourceOriginal
		,	Age_Group2
		,	Lead_Created_Date
		,	Lead_Created_Week
		,	Lead_Created_Month
		,	Lead_Created_Quarter
		,	Mos_Since_Created_Date
		,	First_Contact_Date
		,	First_Contact_Month
		,	Mos_Since_First_Contact_Date
		,	Scheduled_Date
		,	Scheduled_Month
		,	Mos_Since_Scheduled_Date
		,	Consultation_Date
		,	Lapsed_Consults
		,	Converted_Date
		,	Converted_Within_30_Days
		,	Converted_Within_60_Days
		,	Mos_Since_Converted_Date
		,	CCA_Date
		,	DID
		,	ClinID
		,	Doctor_Name
		,	City_State
		,	LID
		,	Not_Interested
		,	Bad_Data
		,	In_Progress
		,	SystemModstamp
		,	@CurrentDateTime
		,	@CurrentDateTime
	from #TempFactLead src
	where not exists(select * from DWCONSDL.FactLead dst where dst.Id = src.Id)
	option (label = 'DWCONSDL.LoadFactLead_Insert');
	
	UPDATE STATISTICS [DWCONSDL].[FactLead] (STATS_DWCONSDL_FactLead_Id);

	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactLead_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end