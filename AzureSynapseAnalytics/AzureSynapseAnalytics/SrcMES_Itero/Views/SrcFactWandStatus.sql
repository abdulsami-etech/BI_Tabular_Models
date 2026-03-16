CREATE VIEW [SrcMES_Itero].[SrcFactWandStatus]
AS SELECT 
       a.[ADLSTimeStamp]
	  ,a.[unit_key] as UnitKey
      ,a.[site_num]   as SiteNumber
      ,a.[serial_number] as SerialNumber
      ,a.[finished_time_u] as FinishedTime
      ,a.[part_number] as PartNumber
      ,a.[part_revision] as PartRevision
	  ,c.[Description] as WandDescription
      ,a.[original_unit_key] as OriginalUnitKey
      ,a.[uda_9] as UnitOperation
      ,a.[creation_time_u] as CreationTime
      ,a.[last_modified_time_u] as LastModifiedTime
      ,b.[route_name] as RouteName
      ,b.[route_step_name] as RouteStepName
      ,b.[queue_name] as QueueName
      ,b.[op_name] as OperationName
      ,b.[p_line_name] as  ProductionLine
      ,b.[wc_name] as WorkCenter
      ,b.[start_time_u] as StartTime
      ,b.[complete_time_u] as CompleteTime
      ,b.[status] as Status
      ,b.[state] as State
      ,b.[reason] as ReasonCode
	  ,CASE WHEN b.[p_line_name] like '%China%' then 'China' else 'Israel' end as ManufacturingCountry
	  ,CASE WHEN b.[p_line_name] like 'RTH%' then 'RTH' 
	        WHEN b.[p_line_name] like 'EVX%' then 'EVX' else  b.[p_line_name] end as Product
  FROM [SrcMES_Itero].[UNIT] as a 
  inner join [SrcMES_Itero].TRACKED_OBJECT_STATUS as b 
	on a.tobj_status_key =  b.tobj_status_key	 
	 AND a.site_num = b.site_num
 inner join [SrcMES_Itero].PART as c 
	 on c.part_number=a.part_number
	 and c.part_revision=a.part_revision
  where c.[description]='Wand Assembly';