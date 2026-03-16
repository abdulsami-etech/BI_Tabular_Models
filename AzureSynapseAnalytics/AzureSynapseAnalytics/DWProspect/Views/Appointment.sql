CREATE VIEW DWProspect.Appointment as
WITH not_concierge as (
    SELECT l.id,
           lj.Lead_Status__c                       AS appointment_status,
           COALESCE(lj.createddate, l.createddate) AS created_date,
           lj.account__c                           AS account,
           lj.LeadSource__c                        AS source,
           l.Converted_to_Patient__c,
           l.Converted_Date__c,
		   l.Consult_Type__c 					   AS ConsultType,
		   l.Consult_Date__c 					   AS ConsultDate
    FROM SrcSFDC.lead l
             JOIN SrcSFDC.Lead_Journey__C lj ON lj.Lead__c = l.Id
    WHERE lj.LeadSource__c IN ('ADAPT', 'SmileView (In Office)', 'Invisalign Smile Station (Professional)', 'In-Office',
                               'Retainer Subscription', 'Invisalign Doctor Assessment')
),
concierge as (
    SELECT l.id,
           a.status__c                            AS appointment_status,
           COALESCE(a.createddate, l.createddate) AS created_date,
           a.account__c                           AS account,
           'Concierge'                            AS source,
           l.Converted_to_Patient__c,
           l.Converted_Date__c,
		   isnull(l.Consult_Type__c, a.Consult_Type__c)  AS  ConsultType,
		   isnull(l.Consult_Date__c, a.Consult_Date__c)  AS  ConsultDate
    FROM SrcSFDC.lead l
             JOIN SrcSFDC.appointment__c a ON a.lead__c = l.id
    WHERE a.lead_journey__c IS NULL
)
SELECT * FROM concierge
UNION ALL SELECT * FROM not_concierge