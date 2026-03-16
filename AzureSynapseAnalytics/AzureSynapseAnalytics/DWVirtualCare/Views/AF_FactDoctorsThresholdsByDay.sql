CREATE VIEW [DWVirtualCare].[AF_FactDoctorsThresholdsByDay]
as

with 
dates as (
	select
		DateKey
	from DW.DimDateTime
	where DateKey>='2021-04-01' and DateKey<'9999-12-31'
),

databricks_latest_preferences as (
		select
			CASE
		              WHEN CHARINDEX('$', [clin_id]) > 0 THEN SUBSTRING([clin_id], 0, CHARINDEX('$', [clin_id]))
			      ELSE [clin_id]
		    END as [clin_id],
			event_name,
			event_category,
			event_meta_data,
			created_at
			--row_number() over (partition by clin_id order by created_at desc) as rn
		FROM [SrcKafkaHeroku].[remote_care_web_event]
		where 
		  api_type='virtual-care'
		  and event_meta_data<>'{}'
		  and
			(   event_category in ('automatic_assessment_save') OR
				event_name='GET_DOCTOR_PROFILE'
			)
			--and clin_id in ('eagilina')		
),

old_latest_preferences as (
		select
			CASE
		              WHEN CHARINDEX('$', [clin_id]) > 0 THEN SUBSTRING([clin_id], 0, CHARINDEX('$', [clin_id]))
			      ELSE [clin_id]
		        END as [clin_id],
			event_name,
			event_category,
			event_meta_data,
			created_at
			--row_number() over (partition by clin_id order by created_at desc) as rn
		FROM [SrcEventHub].[VirtualCare]
		where 
		  api_type='virtual-care'
		  and event_meta_data is not null
		  and
			(   event_category in ('automatic_assessment_save') OR
				event_name='GET_DOCTOR_PROFILE'
			)
			--and clin_id in ('eagilina')		
),

databricks_dat as (

	SELECT
		clin_id,
		event_name,
		event_category,
		created_at,

		CASE
			WHEN event_category in ('automatic_assessment_save')
			THEN JSON_VALUE(JSON_VALUE([event_meta_data],'$.doctor'),'$.alignerfit_assessment_enabled')

			--WHEN event_category in ('aligner_fit')
			--THEN JSON_VALUE(JSON_VALUE([event_meta_data],'$.aligner_fit'),'$.doc_preferences.alignerfit_assessment_enabled')

			WHEN event_name='GET_DOCTOR_PROFILE'
			THEN JSON_VALUE([event_meta_data],'$.data.data.attributes.alignerfit_assessment_enabled')
		END as IsAssessmentEnabled,

		CASE
			WHEN event_category in ('automatic_assessment_save')
			THEN JSON_VALUE(JSON_VALUE([event_meta_data],'$.doctor'),'$.aligner_space_thresholds_attributes[0].upper')

			--WHEN event_category in ('aligner_fit')
			--THEN JSON_VALUE(JSON_VALUE([event_meta_data],'$.aligner_fit'),'$.doc_preferences.aligner_space_thresholds[0].upper')
			
			WHEN event_name='GET_DOCTOR_PROFILE'
			THEN JSON_VALUE(JSON_VALUE([event_meta_data],'$.data.data.attributes.aligner_space_thresholds'),'$[0].upper')
		END as threshold_1,

		CASE
			WHEN event_category in ('automatic_assessment_save')
			THEN JSON_VALUE(JSON_VALUE([event_meta_data],'$.doctor'),'$.aligner_space_thresholds_attributes[1].upper')

			--WHEN event_category in ('aligner_fit')
			--THEN JSON_VALUE(JSON_VALUE([event_meta_data],'$.aligner_fit'),'$.doc_preferences.aligner_space_thresholds[1].upper')

			WHEN event_name='GET_DOCTOR_PROFILE'
			THEN JSON_VALUE(JSON_VALUE([event_meta_data],'$.data.data.attributes.aligner_space_thresholds'),'$[1].upper')
		END as threshold_2

	FROM databricks_latest_preferences
),

old_dat as (

	SELECT
		clin_id,
		event_name,
		event_category,
		created_at,

		CASE
			WHEN event_category in ('automatic_assessment_save')
			THEN JSON_VALUE([event_meta_data],'$.doctor.alignerfit_assessment_enabled')

			--WHEN event_category in ('aligner_fit')
			--THEN JSON_VALUE([event_meta_data],'$.aligner_fit.doc_preferences.alignerfit_assessment_enabled')

			WHEN event_name='GET_DOCTOR_PROFILE'
			THEN JSON_VALUE([event_meta_data],'$.data.data.attributes.alignerfit_assessment_enabled')
		END as IsAssessmentEnabled,

		CASE
			WHEN event_category in ('automatic_assessment_save')
			THEN JSON_VALUE([event_meta_data],'$.doctor.aligner_space_thresholds_attributes[0].upper')

			WHEN event_category in ('aligner_fit')
			THEN JSON_VALUE([event_meta_data],'$.aligner_fit.doc_preferences.aligner_space_thresholds[0].upper')
			
			WHEN event_name='GET_DOCTOR_PROFILE'
			THEN JSON_VALUE([event_meta_data],'$.data.data.attributes.aligner_space_thresholds[0].upper')
		END as threshold_1,

		CASE
			WHEN event_category in ('automatic_assessment_save')
			THEN JSON_VALUE([event_meta_data],'$.doctor.aligner_space_thresholds_attributes[1].upper')

			WHEN event_category in ('aligner_fit')
			THEN JSON_VALUE([event_meta_data],'$.aligner_fit.doc_preferences.aligner_space_thresholds[1].upper')

			WHEN event_name='GET_DOCTOR_PROFILE'
			THEN JSON_VALUE([event_meta_data],'$.data.data.attributes.aligner_space_thresholds[1].upper')
		END as threshold_2

	FROM old_latest_preferences
),

combined_data as (
	select * from databricks_dat union all select * from old_dat
),


dat2 as (

SELECT
	clin_id,
	--event_name,
	--event_category,
	created_at as created_at,

	ISNULL(IsAssessmentEnabled,'false') as IsAssessmentEnabled,
	convert(decimal(10,2),threshold_1) as threshold_1,
	convert(decimal(10,2),threshold_2) as threshold_2

FROM combined_data 
),

dat3 as (

	select
		clin_id,
		convert(date,left(created_at,10)) as created_at,
		FIRST_VALUE(IsAssessmentEnabled) over (partition by clin_id, convert(date,left(created_at,10)) order by created_at desc) as IsAssessmentEnabled,
		threshold_1,
		threshold_2,
		convert(date,
		left(
			LEAD(created_at,1,'9999-12-31') over (partition by clin_id order by created_at)
			,10)) as next_date
	from dat2
),

dat4 as (
	select 
		clin_id,
		created_at,
		max(IsAssessmentEnabled) as IsAssessmentEnabled,
		max(ISNULL(threshold_1,0)) as threshold_1,
		max(ISNULL(threshold_2,0)) as threshold_2,
		max(next_date) as next_date
	from dat3
	group by clin_id, created_at
),

dat5 as (

	select
		d.DateKey,
		dat4.clin_id,
		dat4.created_at as last_seen_at,
		dat4.IsAssessmentEnabled,
		dat4.threshold_1,
		dat4.threshold_2,
		max(IsAssessmentEnabled) over (partition by clin_id) as IsEverEnabled

	from dates d
		inner join dat4 on d.DateKey>=dat4.created_at and d.DateKey<dat4.next_date

)

select * from dat5 where IsEverEnabled='true'
