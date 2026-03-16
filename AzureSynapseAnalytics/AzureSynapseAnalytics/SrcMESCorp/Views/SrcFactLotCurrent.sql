CREATE VIEW [SrcMESCorp].[SrcFactLotCurrent]
AS select	t.ADLSBatchID															as ADLSBatchID
	,	t.ADLSTimestamp															as ADLSTimestamp
	,	t.LZBatchID																as LZBatchID
	,	t.last_modified_time_u													as DgnLastModifiedDate
	,	lo.creation_time_u														as DgnCreationDateTime
	,	t.complete_time_u														as DgnCompleteDateTime
	,	lo.expiration_time_u													as DgnExpirationDateTime
	,	lo.finished_time_u														as DgnFinishedDateTime
	,	lo.lot_key																as DgnLotKey
	,	lo.lot_name																as DgnLotName
	,	lo.priority																as DgnPriority
	,	lo.order_item_key														as DgnLotOrderItemKey
	,	t.pause_time_u															as DgnPauseDateTime
	,	lo.promised_time_u														as DgnPromisedDateTime
	,	lo.shipped_time_u														as DgnShippedDateTime
	,	t.start_time_u															as DgnStartDateTime
	,	case
			when t.state = 'Pause' then 'Paused'   
			when t.status = 'Started' then 'Started'  
			when (t.status = 'Completed' and t.queue_name != 'EXIT') then 'Queued'  
			when t.status = 'Created' then 'Created'  
			when t.status = 'Closed' then 'Closed'  
			when t.queue_name = 'EXIT' then 'Completed'  
			when t.status = 'Finished' then 'Finished'  
			else 'NA'  
		end																		as DgnStatus
	,	t.tobj_history_key														as DgnTobjHistoryKey
	,	t.tobj_status_key														as DgnTobjStatusKey
	,	lo.order_key															as DgnWorkOrderKey
	,	wo.order_number															as DgnWorkOrderNumber
	,   case when bd.QCPass=1 then 'Pass' 
            when bd.QCPass=0 then 'Fail'
			else 'No QC' 
		end                                                                     as DgnQCPassFail
	,	isnull(lo.uda_5, 'N/A')													as KeyTeamRegion
	,	isnull(t.reason, 'N/A')													as KeyCompleteReason
	,	convert(date, t.complete_time_u)										as KeyCompleteDate
	,	convert(time(0), t.complete_time_u)										as KeyCompleteTime
	,	convert(date, lo.creation_time_u)										as KeyCreationDate
	,	convert(time(0), lo.creation_time_u)									as KeyCreationTime
	,	woa.at_DoctorID_S														as KeyDoctor
	,	convert(date, lo.expiration_time_u)										as KeyExpirationDate
	,	convert(time(0), lo.expiration_time_u)									as KeyExpirationTime
	,	convert(date, lo.finished_time_u)										as KeyFinishedDate
	,	convert(time(0), lo.finished_time_u)									as KeyFinishedTime
	,	case
			when t.status = 'Started'
				then t.op_key
			when t.status != 'Started'  
				then QRS.op_key 
		end																		as KeyOperation
	,	lo.part_number + '^' + lo.part_revision									as KeyPart
	,	convert(date, t.pause_time_u)											as KeyPauseDate
	,	convert(time(0), t.pause_time_u)										as KeyPauseTime
	,	loa.at_ActualPlant_S													as KeyPlantActual
	,	loa.at_Plant_S															as KeyPlantOriginal
	,   CTH.source_plant                                                        as KeyPlantPrevious
	,	t.route_key																as KeyRoute
	,	t.route_step_key														as KeyRouteStep
	,	convert(date, lo.promised_time_u)										as KeyPromisedDate
	,	convert(time(0), lo.promised_time_u)									as KeyPromisedTime
	,	convert(date, lo.shipped_time_u)										as KeyShippedDate
	,	convert(time(0), lo.shipped_time_u)										as KeyShippedTime
	,	convert(date, t.start_time_u)											as KeyStartDate
	,	convert(time(0), t.start_time_u)										as KeyStartTime
	,	case when t.status = 'Completed' and t.queue_name != 'EXIT'
			then 
				case when datediff(hh, lo.creation_time_u, t.complete_time_u) >= 0
					then datediff(hh, lo.creation_time_u, t.complete_time_u)
					else null
				end
			else datediff(hh, lo.creation_time_u, getutcdate())
		end																		as  LotAgingHours
	,	case when t.status = 'Completed' and t.queue_name != 'EXIT'
			then 
				case when datediff(dd, lo.creation_time_u, t.complete_time_u) >= 0
					then datediff(dd, lo.creation_time_u, t.complete_time_u)
					else null
				end
			else datediff(dd, lo.creation_time_u, getutcdate())
		end																		as LotAgingDays
from SrcMESCorp.Lot lo
inner join SrcMESCorp.uda_lot loa on loa.object_key = lo.lot_key
inner join SrcMESCorp.tracked_object_status t on lo.lot_key = t.tobj_key
inner join SrcMESCorp.Work_Order wo on wo.order_key = lo.order_key
inner join SrcMESCorp.UDA_Order woa	on woa.object_key = lo.order_key
left join (
	select	s.route_key
    	,	s.site_num
    	,	q.queue_key
    	,	s.route_step_name
		,	o.op_key
    	,	o.op_name
	from SrcMESCorp.ROUTE_ARC arc
	inner join SrcMESCorp.ROUTE_QUEUE q on arc.from_node_key = q.queue_key
	inner join SrcMESCorp.ROUTE_STEP s on arc.to_node_key = s.route_step_key
	inner join SrcMESCorp.OPERATION o on s.op_key = o.op_key
	where arc.main_path = 1
) QRS on QRS.queue_key = t.queue_key
left join (Select object_key,last_modified_time_u, QCPass,Row_number()over(partition by object_key order by last_modified_time_u desc ) as latest
from SrcMESCorp.DC_at_BinkyOEData) as bd
on lo.lot_key=bd.object_key and bd.latest=1
left join (Select object_key,last_modified_time_u, source_plant,Row_number()over(partition by object_key order by last_modified_time_u desc ) as latest
from SrcMESCorp.DC_at_CaseTransferHistory) as CTH
on lo.lot_key=CTH.object_key and CTH.latest=1;