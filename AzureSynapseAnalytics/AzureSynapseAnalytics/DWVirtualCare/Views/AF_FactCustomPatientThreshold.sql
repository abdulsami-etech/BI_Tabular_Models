CREATE VIEW [DWVirtualCare].[AF_FactCustomPatientThreshold]
as

with dat as (
SELECT 
	ADLSTimeStamp,
	_region,
	_timestamp,
	event_name,
	event_category,
	event_action,
	CASE
		WHEN CHARINDEX('$', [clin_id]) > 0 THEN SUBSTRING([clin_id], 0, CHARINDEX('$', [clin_id]))
		ELSE [clin_id]
	END as [clin_id],
	patient_id,
	created_at,
	REPLACE(
		REPLACE(
			REPLACE(event_meta_data,'\"','"'),
			'{"assessmentSliderData":"[', '{"assessmentSliderData":['),
		'}]"}','}]}')
	as event_meta_data
FROM [SrcKafkaHeroku].[remote_care_web_event]
WHERE event_meta_data like '{"assessmentSliderData%' and patient_id<>''
)

SELECT 
	ADLSTimeStamp,
	_region as region,
	convert(date,_timestamp) as EventDate,
	event_name,
	event_category,
	event_action,
	[clin_id],
	patient_id,
	created_at,
	JSON_VALUE([event_meta_data],'$.assessmentSliderData[0].upper') as threshold_1,
	JSON_VALUE([event_meta_data],'$.assessmentSliderData[1].upper') as threshold_2
FROM dat