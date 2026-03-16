CREATE VIEW [SrcIDS].[SrcFactPatientOrder]
AS select
		t.ADLSBatchID															as ADLSBatchID
	,	t.ADLSTimestamp															as ADLSTimestamp
	,	t.LZBatchID																as LZBatchID
	,	case when s.order_status_history_id is not null
			then convert(bit, 1)
			else convert(bit, 0) 
		end																		as DgnCurrentRowFlag
	,	t.cancelled_date														as DgnCancelledDateTime
	,	t.cc_accept_date														as DgnCCAcceptDateTime
	,	t.cc_mod_date															as DgnCCModDateTime
	,	t.cc_export_date														as DgnCCExportDateTime
	,	t.cc_export_id															as DgnCCExportID
	,	t.cc_refer_Date															as DgnCCReferDateTime
	,	t.cc_switch_date														as DgnCCSwitchDateTime
	,	t.clincheck_lab_Referred_date											as DgnClincheckLabReferredDateTime
	,	t.hold_date																as DgnHoldDateTime
	,	p.jde_order_id															as DgnWorkOrderNumber
	,	t.modified_date															as DgnModifiedDateTime
	,	t.mtp_id																as DgnMTPID
	,	t.order_status_history_id												as DgnOrderStatusHistoryID
	,	t.plan_Number															as DgnPlanNumber
	,	t.promised_ship_date													as DgnPromisedShipDateTime
	,	t.rc_all_materials_received_date										as DgnRCAllMaterialsReceivedDateTime
	,	t.rc_received_date														as DgnRecievedDateTime
	,	t.rma_number															as DgnRMANumber
	,	t.ss_ship_date															as DgnSSShipDateTime
	,	t.tx_submit_date														as DgnSubmitDateTime
	,	t.ss_tracking_Number													as DgnSSTrackingNumber
	,	t.vip_order_id															as DgnVIPOrderID
	,	t.cc_review_flag														as IsCCReviewRequired
	,	t.rc_box_expected														as IsRCBoxExpected
	,	t.cancelled_date														as KeyCancelledDate
	,	t.cancelled_date														as KeyCancelledTime
	,	convert(date, t.cc_accept_date)											as KeyCCAcceptDate
	,	convert(time(0), t.cc_accept_date)										as KeyCCAcceptTime
	,	convert(date, t.cc_export_date)											as KeyCCExportDate
	,	convert(time(0), t.cc_export_date)										as KeyCCExportTime
	,	convert(date, t.cc_mod_date)											as KeyCCModDate
	,	convert(time(0), t.cc_mod_date)											as KeyCCModTime
	,	convert(date, t.cc_refer_Date)											as KeyCCReferDate
	,	convert(time(0), t.cc_refer_Date)										as KeyCCReferTime
	,	convert(date, t.cc_switch_date)											as KeyCCSwitchDate
	,	convert(time(0), t.cc_switch_date)										as KeyCCSwitchTime
	,	convert(date, t.clincheck_lab_Referred_date)							as KeyClincheckLabReferredDate
	,	t.clincheck_lab_Referred_date											as KeyClincheckLabReferredTime
	,	convert(varchar(33), t.event_type)										as KeyEvent
	,	convert(date, t.hold_date)												as KeyHoldDate
	,	convert(time(0), t.hold_date)											as KeyHoldTime
	,	convert(date, t.modified_date)											as KeyModifiedDate
	,	convert(time(0), t.modified_date)										as KeyModifiedTime
	,	convert(date, t.promised_ship_date)										as KeyPromisedShipDate
	,	convert(time(0), t.promised_ship_date)									as KeyPromisedShipTime
	,	convert(date, t.rc_all_materials_received_date)							as KeyRCAllMaterialsReceivedDate
	,	convert(time(0), t.rc_all_materials_received_date)						as KeyRCAllMaterialsReceivedTime
	,	convert(date, t.rc_received_date)										as KeyRecievedDate
	,	convert(time(0), t.rc_received_date)									as KeyRecievedTime
	,	convert(date, t.ss_ship_date)											as KeySSShipDate
	,	convert(time(0), t.ss_ship_date)										as KeySSShipTime
	,	convert(date, t.tx_submit_date)											as KeySubmitDate
	,	t.tx_submit_date														as KeySubmitTime
	,	t.cc_count																as CCCount
	,	t.cc_mod_count															as CCModCount
	,	t.tx_ordered_batches													as OrderedBatches
	,	t.tx_treated_arches														as TreatedArches
	,	datediff(mi, t.tx_submit_date, t.rc_received_date)						as DurationToReceivedInMinutes
	,	datediff(mi, t.tx_submit_Date, t.cc_export_date)						as DurationToCCExportInMinutes
	,	datediff(mi, t.tx_submit_date, t.cc_accept_date)						as DurationToCCAcceptInMinutes
	,	datediff(mi, t.tx_submit_date, t.ss_ship_date)							as DurationToShippedInMinutes
from SrcIDS.tblpuorderstatushistory t
inner join (SELECT jde_order_id,vip_order_id,_Region,adlstimestamp, Row_number()over(partition by jde_order_id,vip_order_id order by case when _Region = 'Global' then 1 else 0 end ) AS latest FROM SrcIDS.tblcnpatientordermap) p on p.vip_order_id = t.vip_order_id and P._Region  = t._Region and P.latest =1
left join SrcIDS.tblpuorderstatus s	on s.vip_order_id = t.vip_order_id and s._Region = t._Region and s.order_status_history_id = t.order_status_history_id;


