CREATE VIEW [DWVirtualCare].[AF_FactEventSentOnTrack]
as

with raw_data_databricks as (
		select
		    _region+'|'+convert(nvarchar,_partition)+'|'+convert(nvarchar,_offset) as [uuid],
			_timestamp,
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
		FROM [SrcKafkaHeroku].[remote_care_web_event]
		where 
		  api_type='virtual-care'
		  and event_meta_data<>'{}'
		  and event_category='sent_on_track'
			
),

dat_databricks as (
	SELECT
		uuid,
		_timestamp,
		clin_id,
		created_at,
		patient_guid,

		--JSON_VALUE(JSON_VALUE([event_meta_data],'$.aligner_fit'),'$.stage') as current_stage,
		--JSON_VALUE(JSON_VALUE([event_meta_data],'$.aligner_fit'),'$.type') as asset_type,
		JSON_VALUE(JSON_VALUE([event_meta_data],'$.aligner_fit'),'$.maximum_fit_issue') as maximum_fit_issue,
		JSON_VALUE(JSON_VALUE([event_meta_data],'$.aligner_fit'),'$.calculated_asset_severity') as calculated_asset_severity,
		JSON_VALUE(JSON_VALUE([event_meta_data],'$.aligner_fit'),'$.doc_preferences.aligner_space_thresholds[0].upper') as doc_threshold1,
		JSON_VALUE(JSON_VALUE([event_meta_data],'$.aligner_fit'),'$.doc_preferences.aligner_space_thresholds[1].upper') as doc_threshold2
		--JSON_VALUE(JSON_VALUE([event_meta_data],'$.aligner_fit'),'$.file_name') as file_name,
		--rn
	FROM raw_data_databricks d
),

final_databricks as (

	SELECT 
		uuid,
		_timestamp,
		clin_id,
		convert(date,left(created_at,10)) as created_at,
		patient_guid,
		convert(decimal(10,4),maximum_fit_issue) as maximum_fit_issue,
		calculated_asset_severity,
		convert(decimal(10,2),doc_threshold1) as doc_threshold1,
		convert(decimal(10,2),doc_threshold2) as doc_threshold2

	FROM dat_databricks
	where calculated_asset_severity is not null
)

select * from final_databricks where created_at>='2021-10-14'
