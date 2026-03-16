CREATE VIEW [SrcMESCorp].[SrcFactWorkOrder] 
AS select	wo.ADLSBatchID																as ADLSBatchID
	,	wo.ADLSTimestamp															as ADLSTimestamp
	,	wo.LZBatchID																as LZBatchID
	,	dateadd(hh,
			case 
				when uo.at_AllMaterialRecdTime_S like '%PST%' then 8
				when uo.at_AllMaterialRecdTime_S like '%PDT%' then 7
			end, 
			cast(substring(uo.at_AllMaterialRecdTime_S, 1, len(uo.at_AllMaterialRecdTime_S) - 3) as datetime2(3))
		)																			as DgnAllMaterialReceivedDateTime
	,	uo.at_VipOrderNumber_S														as DgnVIPOrderNumber
	,	wo.order_key																as DgnWorkOrderKey
	,	wo.order_number																as DgnWorkOrderNumber
	,	case when uo.at_IsRejectedImpressions_I = 1
			then 'Yes' 
			else 'No'
		end																			as DgnIsRejectedImpression
	,	case when uo.[at_ProcessingType_S] like '%IPL%' 
	        then 'Yes' 
			else 'No' 
		end                                                                         as DgnIsIPLEnabled
    ,	uo.at_IOScan_S																as DgnIsScan
    ,	uo.at_IOScanType_S															as DgnIOScanType
	,	uo.at_IOScanHardwareVersion_S												as DgnHardwareVersion
	,	uo.at_IOScanSoftwareVersion_S												as DgnSoftwareVersion
    ,	uo.at_DeliverableType_S														as DgnDeliverableType
    ,	uo.at_TreatmentCategory_S													as DgnTreatmentCategory
    ,	uo.at_StorageLocation_S														as DgnStorageLocation
	,   uo.at_Pilot_S                                                               as DgnPilotDescription
	,   uo.at_TreatmentFlow_S                                                       as DgnTreatmentFlow
	,	uo.last_modified_time_u														as DgnUOLastModifiedDate
	,   uo.at_ProcessingType_S                                                      as DgnProcessingType
	,	uo.at_MAFeature_I                                                           as DgnMAFeature
	,	uo.at_IsMTPSend_I															as DgnIsMTPSend
	,	uo.at_STPExecuted_I															as DgnSTPExecuted
	,	uo.at_DoctorID_S															as KeyDoctor
	,	uo.at_expedite_scope_S														as KeyExpediteScope
	,	convert(date,
			dateadd(hh,
				case 
					when uo.at_AllMaterialRecdTime_S like '%PST%' then 8
					when uo.at_AllMaterialRecdTime_S like '%PDT%' then 7
				end, 
				cast(substring(uo.at_AllMaterialRecdTime_S, 1, len(uo.at_AllMaterialRecdTime_S) - 3) as datetime2(3))
			)
		)																			as KeyMaterialReceivedDate
	,	convert(time(0),
			dateadd(hh,
				case 
					when uo.at_AllMaterialRecdTime_S like '%PST%' then 8
					when uo.at_AllMaterialRecdTime_S like '%PDT%' then 7
				end, 
				cast(substring(uo.at_AllMaterialRecdTime_S, 1, len(uo.at_AllMaterialRecdTime_S) - 3) as datetime2(3))
			)
		)																			as KeyMaterialReceivedTime
	,	convert(date, wo.creation_time_u)											as KeyOrderCreationDate
    ,	convert(time(0), wo.creation_time_u)										as KeyOrderCreationTime
	,	uo.at_PlantOA_S																as KeyPlantOrderEntry
	,	uo.at_Country_S																as KeyCountryCode
	,	datediff(mi, wo.creation_time_u, wo.finished_time_u)						as DurationToFinishedInMinutes
	,   convert(date, osh.cancelled_date)                                           as KeyCancelledDate
	,	osh.cancelled_reason                                                        as CancelledReason 
from SrcMESCorp.Work_Order wo
inner join SrcMESCorp.uda_order uo on uo.object_key = wo.order_key
left join (SELECT jde_order_id,vip_order_id,_Region, Row_number()over(partition by jde_order_id,vip_order_id order by case when _Region = 'Global' then 1 else 0 end ) AS latest FROM SrcIDS.tblcnpatientordermap) pom on pom.jde_order_id = wo.order_number   and pom.latest =1
left join (Select vip_order_id ,
				  cancelled_date,
				  cancelled_reason,
				  _Region,
				  Row_number()over(partition by vip_order_id,_Region order by event_id asc ) as FstRow  
		   from SrcIDS.tblpuorderstatushistory where event_type='OrderCancelled') osh on osh.vip_order_id = pom.vip_order_id and FstRow = 1 and osh._Region = pom._Region and  osh.cancelled_date is not null ;
GO