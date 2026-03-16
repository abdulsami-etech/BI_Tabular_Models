CREATE VIEW [DWVirtualCare].[AF_FactEventSentInstructionsHistory]
as

with 
raw_data_old as (
		select
		    uuid,
			null as _timestamp,
			CASE
		            WHEN CHARINDEX('$', [clin_id]) > 0 THEN SUBSTRING([clin_id], 0, CHARINDEX('$', [clin_id]))
			    ELSE [clin_id]
		        END as [clin_id],
			event_name,
			event_category,
			event_meta_data,
			created_at,
			patient_id as patient_guid
			--row_number() over (partition by clin_id,patient_id order by created_at desc) as rn
		FROM [SrcEventHub].[VirtualCare]
		where 
		  api_type='virtual-care'
		  and event_meta_data <>'{}'
		  and event_category='sent_instructions'
			
),

dat_old as (
	SELECT
		uuid,
		_timestamp,
		clin_id,
		created_at,
		patient_guid,
		event_meta_data,

		JSON_VALUE([event_meta_data],'$.notification.aligner_stage') as current_stage,
		JSON_VALUE([event_meta_data],'$.type') as asset_type,
		JSON_VALUE([event_meta_data],'$.aligner_fit.maximum_fit_issue') as maximum_fit_issue,
		JSON_VALUE([event_meta_data],'$.aligner_fit.calculated_asset_severity') as calculated_asset_severity,
		JSON_VALUE([event_meta_data],'$.aligner_fit.doc_preferences.aligner_space_thresholds[0].upper') as doc_threshold1,
		JSON_VALUE([event_meta_data],'$.aligner_fit.doc_preferences.aligner_space_thresholds[1].upper') as doc_threshold2,
		JSON_VALUE([event_meta_data],'$.file_name') as file_name,
	    JSON_VALUE([event_meta_data],'$.notification.messages.body') as messageText,
		JSON_VALUE([event_meta_data],'$.notification.asset_group_id') as asset_group
	FROM raw_data_old d
),

final_data_old as (

	SELECT distinct
		uuid,
		_timestamp,
		clin_id,
		convert(date,left(created_at,10)) as created_at,
		patient_guid,
		event_meta_data,
		current_stage,
		asset_type,
		convert(decimal(10,4),maximum_fit_issue) as maximum_fit_issue,
		calculated_asset_severity,
		convert(decimal(10,2),doc_threshold1) as doc_threshold1,
		convert(decimal(10,2),doc_threshold2) as doc_threshold2,
		file_name,
		messageText,
		asset_group

	FROM dat_old
)

select * from final_data_old   where created_at<'2021-10-14'
