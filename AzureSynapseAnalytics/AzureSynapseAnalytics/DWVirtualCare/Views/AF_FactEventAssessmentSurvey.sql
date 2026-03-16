CREATE VIEW [DWVirtualCare].[AF_FactEventAssessmentSurvey]
as
with DATABRICKS_DATA as (

		select distinct
			 _region+'|'+convert(nvarchar,_partition)+'|'+convert(nvarchar,_offset) as [uuid]
			,_timestamp
			,patient_id
			,event_name
			,CASE
				 WHEN CHARINDEX('$', [clin_id]) > 0 THEN SUBSTRING([clin_id], 0, CHARINDEX('$', [clin_id]))
					ELSE [clin_id]
			 END as [clin_id]
			,[app_name]
			,app_version
			,api_type
			,event_action
			,event_category
			,created_at
			,convert(date,[created_at]) as EventDate
	
			,JSON_VALUE( 
					JSON_VALUE([event_meta_data],'$.formData'),
					'$.aligner_fit_feedback.selectedOption')	as Is_AutoAssessment_Correct_answer

			,COALESCE(
				   JSON_VALUE(JSON_VALUE([event_meta_data],'$.formData'),'$.aligner_fit_feedback.detail.large'),
				   JSON_VALUE(JSON_VALUE([event_meta_data],'$.formData'),'$.aligner_fit_feedback.detail.small'),
				   JSON_VALUE(JSON_VALUE([event_meta_data],'$.formData'),'$.aligner_fit_feedback.detail.custom'),
				   'N/A') as survey_answer

			,JSON_VALUE(JSON_VALUE([event_meta_data],'$.formData'),'$.aligner_fit.maximum_fit_issue') as Maximum_Fit_Issue
			,JSON_VALUE(JSON_VALUE([event_meta_data],'$.formData'),'$.aligner_fit.severity_level') as Severity_Level
			,JSON_VALUE(JSON_VALUE([event_meta_data],'$.formData'),'$.aligner_fit.size_of_pixel') as Size_of_Pixel
			,JSON_VALUE(JSON_VALUE([event_meta_data],'$.formData'),'$.aligner_fit.calculated_asset_severity') as Asset_Severity
			,JSON_VALUE(JSON_VALUE([event_meta_data],'$.formData'),'$.type') as Form_Type
			,JSON_VALUE(JSON_VALUE([event_meta_data],'$.formData'),'$.id')   as Form_Id
			,JSON_VALUE(JSON_VALUE([event_meta_data],'$.formData'),'$.aligner_fit.doc_preferences.alignerfit_assessment_enabled') as IsAssessmentEnabled
			,JSON_VALUE(JSON_VALUE([event_meta_data],'$.formData'),'$.aligner_fit.doc_preferences.aligner_space_thresholds[1].lower') as Threshold_1
			,JSON_VALUE(JSON_VALUE([event_meta_data],'$.formData'),'$.aligner_fit.doc_preferences.aligner_space_thresholds[1].upper') as Threshold_2

			,row_number() OVER (PARTITION BY clin_id, patient_id, created_at order by _timestamp desc) as rn
		from [SrcKafkaHeroku].[remote_care_web_event]
		where [event_category]='survey_submit'
		and event_meta_data <>'{}'

		UNION

		SELECT distinct
			 _region+'|'+convert(nvarchar,_partition)+'|'+convert(nvarchar,_offset) as [uuid]
			,_timestamp
			,patient_id
			,event_name
			,CASE
				 WHEN CHARINDEX('$', [clin_id]) > 0 THEN SUBSTRING([clin_id], 0, CHARINDEX('$', [clin_id]))
					ELSE [clin_id]
			 END as [clin_id]
			,[app_name]
			,app_version
			,api_type
			,event_action
			,event_category
			,created_at
			,convert(date,[created_at]) as EventDate

			,'Skip'	as Is_AutoAssessment_Correct_answer
			,'Skip'	as survey_answer

			,NULL as Maximum_Fit_Issue
			,NULL as Severity_Level
			,NULL as Size_of_Pixel
			,NULL as Asset_Severity
			,NULL as Form_Type
			,NULL as Form_Id
			,NULL as IsAssessmentEnabled
			,NULL as Threshold_1
			,NULL as Threshold_2

			,row_number() OVER (PARTITION BY clin_id, patient_id, created_at order by _timestamp desc) as rn
		FROM [SrcKafkaHeroku].[remote_care_web_event]
		WHERE event_category = 'survey_skip'
)

select * from DATABRICKS_DATA where EventDate>='2021-10-01' and rn=1