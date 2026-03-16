CREATE VIEW [DWVirtualCare].[AF_FactDoctorsCurrentThresholds]
as

with all_data_databricks as (
		select
			CASE
		              WHEN CHARINDEX('$', [clin_id]) > 0 THEN SUBSTRING([clin_id], 0, CHARINDEX('$', [clin_id]))
			      ELSE [clin_id]
		    END as [clin_id],

			event_name,
			event_category,
			event_meta_data,
			created_at,
			row_number() over (partition by clin_id order by created_at desc) as rn
		FROM [SrcKafkaHeroku].[remote_care_web_event]
		where 
		  api_type='virtual-care'
		  and
			(   event_category in ('automatic_assessment_save') OR
				event_name='GET_DOCTOR_PROFILE'
			)
		  and event_meta_data <>'{}'
),

dat_databricks as (

	SELECT
		clin_id,
		event_name,
		event_category,
		created_at,

		ISNULL(
		CASE
			WHEN event_category in ('automatic_assessment_save')
			THEN JSON_VALUE(JSON_VALUE([event_meta_data],'$.doctor'),'$.alignerfit_assessment_enabled')

			--WHEN event_category in ('aligner_fit')
			--THEN JSON_VALUE(JSON_VALUE([event_meta_data],'$.aligner_fit'),'$.doc_preferences.alignerfit_assessment_enabled')

			WHEN event_name='GET_DOCTOR_PROFILE'
			THEN JSON_VALUE([event_meta_data],'$.data.data.attributes.alignerfit_assessment_enabled')
		END, 'false') as IsAssessmentEnabled,

		ISNULL(
		CASE
			WHEN event_category in ('automatic_assessment_save')
			THEN JSON_VALUE(JSON_VALUE([event_meta_data],'$.doctor'),'$.aligner_space_thresholds_attributes[0].upper')

			--WHEN event_category in ('aligner_fit')
			--THEN JSON_VALUE(JSON_VALUE([event_meta_data],'$.aligner_fit'),'$.doc_preferences.aligner_space_thresholds[0].upper')
			
			WHEN event_name='GET_DOCTOR_PROFILE'
			THEN JSON_VALUE(JSON_VALUE([event_meta_data],'$.data.data.attributes.aligner_space_thresholds'),'$[0].upper')

		END,0) as threshold_1,

		ISNULL(
		CASE
			WHEN event_category in ('automatic_assessment_save')
			THEN JSON_VALUE(JSON_VALUE([event_meta_data],'$.doctor'),'$.aligner_space_thresholds_attributes[1].upper')

			--WHEN event_category in ('aligner_fit')
			--THEN JSON_VALUE(JSON_VALUE([event_meta_data],'$.aligner_fit'),'$.doc_preferences.aligner_space_thresholds[1].upper')
			
			WHEN event_name='GET_DOCTOR_PROFILE'
			THEN JSON_VALUE(JSON_VALUE([event_meta_data],'$.data.data.attributes.aligner_space_thresholds'),'$[1].upper')

		END,0) as threshold_2,

		row_number() over (partition by clin_id order by created_at desc, event_name) as rn2 

	FROM all_data_databricks WHERE rn=1
)

SELECT
	clin_id,
	event_name,
	event_category,
	convert(date,left(created_at,10)) as created_at,
	IsAssessmentEnabled,
	convert(decimal(10,2),threshold_1) as threshold_1,
	convert(decimal(10,2),threshold_2) as threshold_2
FROM dat_databricks where rn2=1
and clin_id not in ('dtest', 'ftest', 'greatsmi','tphillrf')
