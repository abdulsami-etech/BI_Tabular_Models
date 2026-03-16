CREATE PROC [DWTOPS].[LoadFactPatientOrder] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@IsFullLoad		bit = 0

	if not exists (select * from DWTOPS.FactPatientOrder)
		set @IsFullLoad = 1

	if object_id('tempdb..#TempFactPatientOrder') is not null
		drop table #TempFactPatientOrder

	create table #TempFactPatientOrder with (distribution = hash(DgnVIPOrderID), heap) as 

	select	f.ADLSBatchID															as ADLSBatchID
		,	f.ADLSTimestamp															as ADLSTimestamp
		,	f.LZBatchID																as LZBatchID
		,	f.DgnCurrentRowFlag														as DgnCurrentRowFlag
		,	f.DgnCancelledDateTime													as DgnCancelledDateTime
		,	f.DgnCCAcceptDateTime													as DgnCCAcceptDateTime
		,	f.DgnCCModDateTime														as DgnCCModDateTime
		,	f.DgnCCExportDateTime													as DgnCCExportDateTime
		,	f.DgnCCExportID															as DgnCCExportID
		,	f.DgnCCReferDateTime													as DgnCCReferDateTime
		,	f.DgnCCSwitchDateTime													as DgnCCSwitchDateTime
		,	f.DgnClincheckLabReferredDateTime										as DgnClincheckLabReferredDateTime
		,	f.DgnHoldDateTime														as DgnHoldDateTime
		,	f.DgnWorkOrderNumber													as DgnWorkOrderNumber
		,	f.DgnModifiedDateTime													as DgnModifiedDateTime
		,	f.DgnMTPID																as DgnMTPID
		,	f.DgnOrderStatusHistoryID												as DgnOrderStatusHistoryID
		,	f.DgnPlanNumber															as DgnPlanNumber
		,	f.DgnPromisedShipDateTime												as DgnPromisedShipDateTime
		,	f.DgnRCAllMaterialsReceivedDateTime										as DgnRCAllMaterialsReceivedDateTime
		,	f.DgnRecievedDateTime													as DgnRecievedDateTime
		,	f.DgnRMANumber															as DgnRMANumber
		,	f.DgnSSShipDateTime														as DgnSSShipDateTime
		,	f.DgnSubmitDateTime														as DgnSubmitDateTime
		,	f.DgnSSTrackingNumber													as DgnSSTrackingNumber
		,	f.DgnVIPOrderID															as DgnVIPOrderID
		,	f.IsCCReviewRequired													as IsCCReviewRequired
		,	f.IsRCBoxExpected														as IsRCBoxExpected
		,	isnull(convert(int, convert(varchar(8), f.KeyCancelledDate, 112)), -1)	as SKCancelledDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyCancelledTime, 114), ':', '') + '00'), -1) as SKCancelledTime
		,	isnull(convert(int, convert(varchar(8), f.KeyCCAcceptDate, 112)), -1)	as SKCCAcceptDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyCCAcceptTime, 114), ':', '') + '00'), -1) as SKCCAcceptTime
		,	isnull(convert(int, convert(varchar(8), f.KeyCCExportDate, 112)), -1)	as SKCCExportDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyCCExportTime, 114), ':', '') + '00'), -1) as SKCCExportTime
		,	isnull(convert(int, convert(varchar(8), f.KeyCCModDate, 112)), -1)	as SKCCModDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyCCModTime, 114), ':', '') + '00'), -1) as SKCCModTime
		,	isnull(convert(int, convert(varchar(8), f.KeyCCReferDate, 112)), -1)	as SKCCReferDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyCCReferTime, 114), ':', '') + '00'), -1) as SKCCReferTime
		,	isnull(convert(int, convert(varchar(8), f.KeyCCSwitchDate, 112)), -1)	as SKCCSwitchDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyCCSwitchTime, 114), ':', '') + '00'), -1) as SKCCSwitchTime
		,	isnull(convert(int, convert(varchar(8), f.KeyClincheckLabReferredDate, 112)), -1)	as SKClincheckLabReferredDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyClincheckLabReferredTime, 114), ':', '') + '00'), -1) as SKClincheckLabReferredTime
		,	isnull(e.SKEvent, -1)													as SKEvent
		,	isnull(convert(int, convert(varchar(8), f.KeyHoldDate, 112)), -1)	as SKHoldDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyHoldTime, 114), ':', '') + '00'), -1) as SKHoldTime
		,	isnull(convert(int, convert(varchar(8), f.KeyModifiedDate, 112)), -1)	as SKModifiedDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyModifiedTime, 114), ':', '') + '00'), -1) as SKModifiedTime
		,	isnull(convert(int, convert(varchar(8), f.KeyPromisedShipDate, 112)), -1)	as SKPromisedShipDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyPromisedShipTime, 114), ':', '') + '00'), -1) as SKPromisedShipTime
		,	isnull(convert(int, convert(varchar(8), f.KeyRCAllMaterialsReceivedDate, 112)), -1)	as SKRCAllMaterialsReceivedDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyRCAllMaterialsReceivedTime, 114), ':', '') + '00'), -1) as SKRCAllMaterialsReceivedTime
		,	isnull(convert(int, convert(varchar(8), f.KeyRecievedDate, 112)), -1)	as SKRecievedDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyRecievedTime, 114), ':', '') + '00'), -1) as SKRecievedTime
		,	isnull(convert(int, convert(varchar(8), f.KeySSShipDate, 112)), -1)	as SKSSShipDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeySSShipTime, 114), ':', '') + '00'), -1) as SKSSShipTime
		,	isnull(convert(int, convert(varchar(8), f.KeySubmitDate, 112)), -1)	as SKSubmitDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeySubmitTime, 114), ':', '') + '00'), -1) as SKSubmitTime
		,	f.CCCount																as CCCount
		,	f.CCModCount															as CCModCount
		,	f.OrderedBatches														as OrderedBatches
		,	f.TreatedArches															as TreatedArches
		,	f.DurationToReceivedInMinutes											as DurationToReceivedInMinutes
		,	f.DurationToCCExportInMinutes											as DurationToCCExportInMinutes
		,	f.DurationToCCAcceptInMinutes											as DurationToCCAcceptInMinutes
		,	f.DurationToShippedInMinutes											as DurationToShippedInMinutes
	from SrcIDS.SrcFactPatientOrder f
	left join DWTOPS.HubEvent e on e.KeyEvent = f.KeyEvent
	where f.DgnModifiedDateTime >= '20160101'
	and f.DgnVIPOrderID in (
		select DgnVIPOrderID
		from SrcIDS.tblpuorderstatushistory
		where @IsFullLoad = 1
			or f.ADLSTimestamp >= isnull(@LastSuccessfullDWTimestamp, '19000101')
	)

	begin tran

	delete from DWTOPS.FactPatientOrder
	where exists (
		select *
		from #TempFactPatientOrder s
		where s.DgnVIPOrderID = DWTOPS.FactPatientOrder.DgnVIPOrderID
	)
	option (Label = 'DWTOPS.LoadFactPatientOrder_Delete');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactPatientOrder_Delete', @rc = @RowsUpdated out

	insert into DWTOPS.FactPatientOrder (
				ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DgnCurrentRowFlag
			,	DgnCancelledDateTime
			,	DgnCCAcceptDateTime
			,	DgnCCModDateTime
			,	DgnCCExportDateTime
			,	DgnCCExportID
			,	DgnCCReferDateTime
			,	DgnCCSwitchDateTime
			,	DgnClincheckLabReferredDateTime
			,	DgnHoldDateTime
			,	DgnWorkOrderNumber
			,	DgnModifiedDateTime
			,	DgnMTPID
			,	DgnOrderStatusHistoryID
			,	DgnPlanNumber
			,	DgnPromisedShipDateTime
			,	DgnRCAllMaterialsReceivedDateTime
			,	DgnRecievedDateTime
			,	DgnRMANumber
			,	DgnSSShipDateTime
			,	DgnSubmitDateTime
			,	DgnSSTrackingNumber
			,	DgnVIPOrderID
			,	IsCCReviewRequired
			,	IsRCBoxExpected
			,	SKCancelledDate
			,	SKCancelledTime
			,	SKCCAcceptDate
			,	SKCCAcceptTime
			,	SKCCExportDate
			,	SKCCExportTime
			,	SKCCModDate
			,	SKCCModTime
			,	SKCCReferDate
			,	SKCCReferTime
			,	SKCCSwitchDate
			,	SKCCSwitchTime
			,	SKClincheckLabReferredDate
			,	SKClincheckLabReferredTime
			,	SKEvent
			,	SKHoldDate
			,	SKHoldTime
			,	SKModifiedDate
			,	SKModifiedTime
			,	SKPromisedShipDate
			,	SKPromisedShipTime
			,	SKRCAllMaterialsReceivedDate
			,	SKRCAllMaterialsReceivedTime
			,	SKRecievedDate
			,	SKRecievedTime
			,	SKSSShipDate
			,	SKSSShipTime
			,	SKSubmitDate
			,	SKSubmitTime
			,	CCCount
			,	CCModCount
			,	OrderedBatches
			,	TreatedArches
			,	DurationToReceivedInMinutes
			,	DurationToCCExportInMinutes
			,	DurationToCCAcceptInMinutes
			,	DurationToShippedInMinutes
	)
	select	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	@BatchID
		,	DgnCurrentRowFlag
		,	DgnCancelledDateTime
		,	DgnCCAcceptDateTime
		,	DgnCCModDateTime
		,	DgnCCExportDateTime
		,	DgnCCExportID
		,	DgnCCReferDateTime
		,	DgnCCSwitchDateTime
		,	DgnClincheckLabReferredDateTime
		,	DgnHoldDateTime
		,	DgnWorkOrderNumber
		,	DgnModifiedDateTime
		,	DgnMTPID
		,	DgnOrderStatusHistoryID
		,	DgnPlanNumber
		,	DgnPromisedShipDateTime
		,	DgnRCAllMaterialsReceivedDateTime
		,	DgnRecievedDateTime
		,	DgnRMANumber
		,	DgnSSShipDateTime
		,	DgnSubmitDateTime
		,	DgnSSTrackingNumber
		,	DgnVIPOrderID
		,	IsCCReviewRequired
		,	IsRCBoxExpected
		,	SKCancelledDate
		,	SKCancelledTime
		,	SKCCAcceptDate
		,	SKCCAcceptTime
		,	SKCCExportDate
		,	SKCCExportTime
		,	SKCCModDate
		,	SKCCModTime
		,	SKCCReferDate
		,	SKCCReferTime
		,	SKCCSwitchDate
		,	SKCCSwitchTime
		,	SKClincheckLabReferredDate
		,	SKClincheckLabReferredTime
		,	SKEvent
		,	SKHoldDate
		,	SKHoldTime
		,	SKModifiedDate
		,	SKModifiedTime
		,	SKPromisedShipDate
		,	SKPromisedShipTime
		,	SKRCAllMaterialsReceivedDate
		,	SKRCAllMaterialsReceivedTime
		,	SKRecievedDate
		,	SKRecievedTime
		,	SKSSShipDate
		,	SKSSShipTime
		,	SKSubmitDate
		,	SKSubmitTime
		,	CCCount
		,	CCModCount
		,	OrderedBatches
		,	TreatedArches
		,	DurationToReceivedInMinutes
		,	DurationToCCExportInMinutes
		,	DurationToCCAcceptInMinutes
		,	DurationToShippedInMinutes
	from #TempFactPatientOrder
	option (label = 'DWTOPS.LoadFactPatientOrder_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactPatientOrder_Insert', @rc = @RowsInserted out

	commit tran

	select @RowsInserted - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated
end
