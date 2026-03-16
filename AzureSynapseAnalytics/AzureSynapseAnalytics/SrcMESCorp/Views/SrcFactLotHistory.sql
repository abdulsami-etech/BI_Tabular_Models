CREATE VIEW [SrcMESCorp].[SrcFactLotHistory]
AS WITH TreatmentHistory
AS
(
	SELECT 
			object_key,
			new_treatment_flow , op_name,
			last_modified_time_u  ,ISNULL(lead(last_modified_time_u ) over(Partition by object_key order by  last_modified_time_u ASC) , GETUTCDate()) AS Next_last_modified  
	FROM [SrcMESCorp].[DC_at_TreatmentHistory]
)
SELECT * FROM (
select	t.ADLSBatchID														as ADLSBatchID
	,	t.ADLSTimestamp															as ADLSTimestamp
	,	t.LZBatchID																as LZBatchID
	,	t.complete_time_u														as DgnCompleteDateTime
	,	t.start_time_u															as DgnStartDateTime
	,	lo.lot_key																as DgnLotKey
	,	lo.lot_name																as DgnLotName
	,	lo.order_item_key														as DgnLotOrderItemKey
	,	t.tobj_history_key														as DgnTobjHistoryKey
	,	lo.order_key															as DgnWorkOrderKey
	,	wo.order_number															as DgnWorkOrderNumber
	,   pth.ProductionTeam                                                      as DgnProductionTeam
	,	t.complete_comment														as KeyCompleteComment
	,	convert(date, t.complete_time)											as KeyCompleteDate
	,	convert(time(0), t.complete_time)										as KeyCompleteTime
	,	convert(date, t.complete_time_u)										as KeyCompleteDateUTC
	,	convert(time(0), t.complete_time_u)										as KeyCompleteTimeUTC
	,	convert(varchar(64), t.complete_reason)									as KeyCompleteReason
	,	convert(varchar(64), t.complete_user_name)								as KeyCompleteUserName
	,	isnull(lo.uda_5, 'N/A')													as KeyTeamRegion
	,	woa.at_DoctorID_S														as KeyDoctor
	,	t.op_key																as KeyOperation
	,	convert(varchar(64), lo.part_number) + '^' + convert(varchar(64), lo.part_revision) as KeyPart
	,	t.route_key																as KeyRoute
	,	t.route_step_key														as KeyRouteStep
	,	convert(date, t.start_time)										  	    as KeyStartDate
	,	convert(time(0), t.start_time)										    as KeyStartTime
	,	convert(date, t.start_time_u)										    as KeyStartDateUTC
	,	convert(time(0), t.start_time_u)										as KeyStartTimeUTC
	,	convert(varchar(64), t.start_user_name)									as KeyStartUserName
	,	case 
			when t.Complete_Count = 0 then 'Current'
			when t.Complete_Count = 1 then 'FirstPass'
			when t.Complete_Count > 1 then 'NotFirstPass' 
		end																		as KeyCompletionPass
	,	t.Start_Count															as StartCount
	,	t.Complete_Count														as CompleteCount
	,	t.Complete_Quantity														as CompleteQuantity
	,	t.Start_Quantity														as StartQuantity
	,	t.Start_Pause_Duration													as StartPauseDuration
	,	t.Complete_Pause_Duration												as CompletePauseDuration
	,	case 
			when t.op_name = 'ClinCheck' 
				then	case 
							when t.complete_reason = 'OK' then 'CCA' 
							when t.complete_reason = 'QC-Req' then 'QC' 
							when t.complete_reason = 'Fail' then 'CCFailed'
							when t.complete_reason in ('Switch','Switch_1') then 'Switch'
							when t.complete_reason is null then 'CCAA'
						else t.complete_reason 
				end
			else null
		end																		as ClinCheckStatus
	,  CASE WHEN t.complete_time_u > ( SELECT MIN(a.complete_time_u)  FROM    SrcMESCorp.TRACKED_OBJECT_HISTORY a   
                                                     WHERE a.tobj_key = t.tobj_key  AND a.op_name  = 'ClinCheck' AND a.complete_reason = 'Fail' )           
                                                           THEN 1 ELSE 0 END    as PostClinCheckFail

	,	datediff(mi, t.start_time_u, t.complete_time_u)							as CycleTimeMinutes
	, Row_number() over(Partition by t.tobj_history_key	 order by pth.last_modified_time_u desc) AS RNum
	, th.new_treatment_flow													    as NewTreatmentFlow
from SrcMESCorp.TRACKED_OBJECT_HISTORY t
inner join SrcMESCorp.Lot lo on lo.lot_key = t.tobj_key
inner join SrcMESCorp.Work_Order wo on wo.order_key = lo.order_key
inner join SrcMESCorp.UDA_Order woa	on woa.object_key = wo.order_key
Left  join [SrcMESCorp].[DC_at_ProductionTeamHstr] pth on  pth.TechName = t.complete_user_name AND t.complete_time between pth.EffectiveFrom AND pth.EffectiveTo
left join TreatmentHistory  TH ON TH.object_key = lo.lot_key and  t.complete_time_u Between TH.last_modified_time_u and TH.Next_last_modified
)LotHis WHERE LotHis.RNum= 1;