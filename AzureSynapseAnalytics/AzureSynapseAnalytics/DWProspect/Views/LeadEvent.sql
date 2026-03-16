CREATE VIEW DWProspect.LeadEvent as
SELECT
    kh.event_name,
    kh.event_category,
    kh.event_action,
    CASE WHEN CHARINDEX ('$',kh.clin_id)>0 THEN SUBSTRING(kh.clin_id,0,CHARINDEX ('$',kh.clin_id))
        ELSE kh.clin_id
    END as clin_id,
    kh.lead_id,
    kh.status,
    kh.created_at
from [SrcKafkaHeroku].[remote_care_web_event] kh with (NOLOCK)
where kh.app_name='con-leadwebapp' and TRY_CONVERT(date, LEFT(kh.created_at, 10))>='2021-11-01'
UNION ALL
SELECT
    lwa.event_name,
    lwa.event_category,
    lwa.event_action,
    CASE WHEN CHARINDEX ('$',lwa.clin_id)>0 THEN SUBSTRING(lwa.clin_id,0,CHARINDEX ('$',lwa.clin_id))
        ELSE lwa.clin_id
    END as clin_id,
    lwa.lead_id,
    lwa.status,
    lwa.created_at
from SrcAvro.LeadWebApp lwa
where TRY_CONVERT(date, LEFT(lwa.created_at, 10))<'2021-11-01'
group by
    lwa.event_name,
    lwa.event_category,
    lwa.event_action,
    CASE WHEN CHARINDEX ('$',lwa.clin_id)>0 THEN SUBSTRING(lwa.clin_id,0,CHARINDEX ('$',lwa.clin_id))
        ELSE lwa.clin_id
    END,
    lwa.lead_id,
    lwa.status,
    lwa.created_at