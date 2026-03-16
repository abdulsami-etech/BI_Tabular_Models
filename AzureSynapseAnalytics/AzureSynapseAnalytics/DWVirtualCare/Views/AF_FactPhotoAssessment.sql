CREATE VIEW [DWVirtualCare].[AF_FactPhotoAssessment]
as

with
dat_new as (
	SELECT
		_region+'|'+convert(nvarchar,_partition)+'|'+convert(nvarchar,_offset) as [uuid],
		_timestamp as created_at,

		asset_group_id,
		user_id as [patient_id],
		_timestamp as [timestamp],
		--JSON_VALUE(d.[event_meta_data],'$.statistics.processing_time') as [processing_time],
		--JSON_VALUE(d.[event_meta_data],'$.statistics.total_request_time') as [total_reqiest_time],
		
		JSON_VALUE(ag.value,'$.asset_id')			as [asset_id],
		JSON_VALUE(ag.value,'$.clin_id')			as [clin_id],
		JSON_VALUE(ag.value,'$.asset_type')			as [asset_type],
		JSON_VALUE(ag.value,'$.severity_level')		as [severity_level],
		JSON_VALUE(ag.value,'$.severity_label')		as [severity_label],
		JSON_VALUE(ag.value,'$.maximum_fit_issue')	as [maximum_fit_issue],
		JSON_VALUE(ag.value,'$.asset_file_name')	as [asset_file_name]

	FROM [SrcKafkaHeroku].[assets_outcome] d
	cross  apply openjson(JSON_QUERY(d.assets,'$'),'$') as ag
	where [asset_group_id] is not null
),

final_new as (
	SELECT 
		uuid,
		convert(date,left(created_at,10)) as created_at,
		asset_group_id,
		[patient_id],
		[timestamp],
		--convert(decimal(18,10),[processing_time]) as [processing_time],
		--convert(decimal(18,10),[total_reqiest_time]) as [total_reqiest_time],

		asset_id,
		clin_id,
		asset_type,
		[severity_level],
		[severity_label],
		convert(decimal(20,18),left([maximum_fit_issue],10)) as [maximum_fit_issue],
		[asset_file_name]

FROM dat_new
)

select * from final_new where created_at>='2021-10-17'