CREATE VIEW [DWVirtualCare].[AF_FactDoctorsAFDisabled]
as

with dat as (
	select  
		CASE
		              WHEN CHARINDEX('$', [clin_id]) > 0 THEN SUBSTRING([clin_id], 0, CHARINDEX('$', [clin_id]))
			      ELSE [clin_id]
		END as [clin_id],
		created_at,
		event_meta_data,
		row_number() over (partition by clin_id order by created_at desc) as rn
	from [SrcKafkaHeroku].[remote_care_web_event]
	where 
		event_name='GET_DOCTOR_PROFILE'
)
select distinct clin_id, convert(date,created_at) as created_at
from dat 
where 
rn=1 and
event_meta_data like '%assessment_enabled":"false%'