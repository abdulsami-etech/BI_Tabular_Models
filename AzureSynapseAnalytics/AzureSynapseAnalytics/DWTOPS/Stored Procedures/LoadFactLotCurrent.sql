CREATE PROC [DWTOPS].[LoadFactLotCurrent] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@IsFullLoad		bit = 0

set @IsFullLoad = isnull(@IsForceFullLoad, 0)--Set From Flag


	if not exists (select * from DWTOPS.FactLotCurrent)
		set @IsFullLoad = 1

	
	if object_id ('DWTOPS.Temp_FactLotCurrent', 'U') is not null
		drop table DWTOPS.Temp_FactLotCurrent


	create table DWTOPS.Temp_FactLotCurrent with (distribution = hash(DgnLotKey), heap) as 
	select	f.ADLSBatchID															as ADLSBatchID
		,	f.ADLSTimestamp															as ADLSTimestamp
		,	f.LZBatchID																as LZBatchID
		,   @BatchID                                                                as DWBatchID
		,	f.DgnCreationDateTime													as DgnCreationDateTime
		,	f.DgnCompleteDateTime													as DgnCompleteDateTime
		,	f.DgnExpirationDateTime													as DgnExpirationDateTime
		,	f.DgnFinishedDateTime													as DgnFinishedDateTime
		,	f.DgnLotKey																as DgnLotKey
		,	f.DgnLotName															as DgnLotName
		,	f.DgnPriority															as DgnPriority
		,	f.DgnLotOrderItemKey													as DgnLotOrderItemKey
		,	f.DgnPauseDateTime														as DgnPauseDateTime
		,	f.DgnPromisedDateTime													as DgnPromisedDateTime
		,	f.DgnShippedDateTime													as DgnShippedDateTime
		,	f.DgnStartDateTime														as DgnStartDateTime
		,	f.DgnStatus																as DgnStatus
		,	f.DgnTobjHistoryKey														as DgnTobjHistoryKey
		,	f.DgnTobjStatusKey														as DgnTobjStatusKey
		,	f.DgnWorkOrderKey														as DgnWorkOrderKey
		,	f.DgnWorkOrderNumber													as DgnWorkOrderNumber
		,   f.DgnQCPassFail                                                         as DgnQCPassFail
		,	isnull(tr.SKTeamRegion, -1)												as SKTeamRegion
		,	isnull(f.KeyTeamRegion, 'N/A')											as KeyTeamRegion
		,	isnull(cr.SKCompleteReason, -1)											as SKCompleteReason
		,	isnull(f.KeyCompleteReason, 'N/A')										as KeyCompleteReason
		,	isnull(convert(int, convert(varchar(8), f.KeyCompleteDate, 112)), -1)	as SKCompleteDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyCompleteTime, 114), ':', '') + '00'), -1) as SKCompleteTime
		,	isnull(convert(int, convert(varchar(8), f.KeyCreationDate, 112)), -1)	as SKCreationDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyCreationTime, 114), ':', '') + '00'), -1) as SKCreationTime
		,	isnull(do.SKDoctor, -1)													as SKDoctor
		,	isnull(f.KeyDoctor, 'N/A')												as KeyDoctor
		,	isnull(convert(int, convert(varchar(8), f.KeyExpirationDate, 112)), -1)	as SKExpirationDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyExpirationTime, 114), ':', '') + '00'), -1) as SKExpirationTime
		,	isnull(convert(int, convert(varchar(8), f.KeyFinishedDate, 112)), -1)	as SKFinishedDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyFinishedTime, 114), ':', '') + '00'), -1) as SKFinishedTime
		,	isnull(op.SKOperation, -1)												as SKOperation
		,	isnull(f.KeyOperation, -1)												as KeyOperation
		,	isnull(pa.SKPart, -1)													as SKPart
		,	isnull(f.KeyPart, 'N/A')												as KeyPart
		,	isnull(convert(int, convert(varchar(8), f.KeyPauseDate, 112)), -1)		as SKPauseDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyPauseTime, 114), ':', '') + '00'), -1) as SKPauseTime
		,	isnull(pla.SKPlant, -1)													as SKPlantActual
		,	isnull(f.KeyPlantActual, 'N/A')											as KeyPlantActual
		,	isnull(plo.SKPlant, -1)													as SKPlantOriginal
		,	isnull(f.KeyPlantOriginal, 'N/A')										as KeyPlantOriginal
		,	isnull(plp.SKPlant, -1)													as SKPlantPrevious
		,	isnull(f.KeyPlantPrevious, 'N/A')										as KeyPlantPrevious
		,	isnull(ro.SKRoute, -1)													as SKRoute
		,	isnull(f.KeyRoute, -1)													as KeyRoute
		,	isnull(rs.SKRouteStep, -1)												as SKRouteStep
		,	isnull(f.KeyRouteStep, -1)												as KeyRouteStep
		,	isnull(convert(int, convert(varchar(8), f.KeyPromisedDate, 112)), -1)	as SKPromisedDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyPromisedTime, 114), ':', '') + '00'), -1) as SKPromisedTime
		,	isnull(convert(int, convert(varchar(8), f.KeyShippedDate, 112)), -1)	as SKShippedDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyShippedTime, 114), ':', '') + '00'), -1) as SKShippedTime
		,	isnull(convert(int, convert(varchar(8), f.KeyStartDate, 112)), -1)		as SKStartDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyStartTime, 114), ':', '') + '00'), -1) as SKStartTime
		,	f.LotAgingHours															as LotAgingHours
		,	f.LotAgingDays															as LotAgingDays
	from SrcMESCorp.SrcFactLotCurrent f
	left join DWTOPS.HubCompleteReason cr on cr.KeyCompleteReason = f.KeyCompleteReason
	left join DWTOPS.HubDoctor do on do.KeyDoctor = f.KeyDoctor
	left join DWTOPS.HubOperation op on op.KeyOperation = f.KeyOperation
	left join DWTOPS.HubPart pa on pa.KeyPart = f.KeyPart
	left join DWTOPS.HubPlant pla on pla.KeyPlant = f.KeyPlantActual
	left join DWTOPS.HubPlant plo on plo.KeyPlant = f.KeyPlantOriginal
	left join DWTOPS.HubPlant plp on plp.KeyPlant = f.KeyPlantPrevious
	left join DWTOPS.HubRoute ro on ro.KeyRoute = f.KeyRoute
	left join DWTOPS.HubRouteStep rs on rs.KeyRouteStep = f.KeyRouteStep
	left join DWTOPS.HubTeamRegion tr on tr.KeyTeamRegion = f.KeyTeamRegion
	where f.DgnLastModifiedDate >= '20160101'
		and (
				@IsFullLoad = 1
			or	f.ADLSTimestamp >= isnull(@LastSuccessfullDWTimestamp, '19000101')
		)


if @IsFullLoad = 0
BEGIN

	begin tran

	delete from DWTOPS.FactLotCurrent
	where exists (
		select *
		from DWTOPS.Temp_FactLotCurrent s
		where s.DgnLotKey = DWTOPS.FactLotCurrent.DgnLotKey
	)
	option (Label = 'DWTOPS.LoadFactLotCurrent_Delete');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotCurrent_Delete', @rc = @RowsUpdated out

	insert into DWTOPS.FactLotCurrent (
				ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DgnCreationDateTime
			,	DgnCompleteDateTime
			,	DgnExpirationDateTime
			,	DgnFinishedDateTime
			,	DgnLotKey
			,	DgnLotName
			,	DgnPriority
			,	DgnLotOrderItemKey
			,	DgnPauseDateTime
			,	DgnPromisedDateTime
			,	DgnShippedDateTime
			,	DgnStartDateTime
			,	DgnStatus
			,	DgnTobjHistoryKey
			,	DgnTobjStatusKey
			,	DgnWorkOrderKey
			,	DgnWorkOrderNumber
			,   DgnQCPassFail
			,	SKCompleteDate
			,	SKCompleteReason
			,	KeyCompleteReason
			,	SKCompleteTime
			,	SKCreationDate
			,	SKCreationTime
			,	SKDoctor
			,	KeyDoctor
			,	SKExpirationDate
			,	SKExpirationTime
			,	SKFinishedDate
			,	SKFinishedTime
			,	SKTeamRegion
			,	KeyTeamRegion
			,	SKOperation
			,	KeyOperation
			,	SKPart
			,	KeyPart
			,	SKPauseDate
			,	SKPauseTime
			,	SKPlantActual
			,	KeyPlantActual
			,	SKPlantOriginal
			,	KeyPlantOriginal
			,   SKPlantPrevious
			,   KeyPlantPrevious
			,	SKRoute
			,	KeyRoute
			,	SKRouteStep
			,	KeyRouteStep
			,	SKPromisedDate
			,	SKPromisedTime
			,	SKShippedDate
			,	SKShippedTime
			,	SKStartDate
			,	SKStartTime
			,	LotAgingHours
			,	LotAgingDays
	)
	select	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	@BatchID
		,	DgnCreationDateTime
		,	DgnCompleteDateTime
		,	DgnExpirationDateTime
		,	DgnFinishedDateTime
		,	DgnLotKey
		,	DgnLotName
		,	DgnPriority
		,	DgnLotOrderItemKey
		,	DgnPauseDateTime
		,	DgnPromisedDateTime
		,	DgnShippedDateTime
		,	DgnStartDateTime
		,	DgnStatus
		,	DgnTobjHistoryKey
		,	DgnTobjStatusKey
		,	DgnWorkOrderKey
		,	DgnWorkOrderNumber
		,   DgnQCPassFail
		,	SKCompleteDate
		,	SKCompleteReason
		,	KeyCompleteReason
		,	SKCompleteTime
		,	SKCreationDate
		,	SKCreationTime
		,	SKDoctor
		,	KeyDoctor
		,	SKExpirationDate
		,	SKExpirationTime
		,	SKFinishedDate
		,	SKFinishedTime
		,	SKTeamRegion
		,	KeyTeamRegion
		,	SKOperation
		,	KeyOperation
		,	SKPart
		,	KeyPart
		,	SKPauseDate
		,	SKPauseTime
		,	SKPlantActual
		,	KeyPlantActual
		,	SKPlantOriginal
		,	KeyPlantOriginal
		,   SKPlantPrevious
		,   KeyPlantPrevious
		,	SKRoute
		,	KeyRoute
		,	SKRouteStep
		,	KeyRouteStep
		,	SKPromisedDate
		,	SKPromisedTime
		,	SKShippedDate
		,	SKShippedTime
		,	SKStartDate
		,	SKStartTime
		,	LotAgingHours
		,	LotAgingDays
	from DWTOPS.Temp_FactLotCurrent
	option (label = 'DWTOPS.LoadFactLotCurrent_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotCurrent_Insert', @rc = @RowsInserted out

	commit tran

	
end

 	else
	begin --full load
		if object_id ('DWTOPS.FactLotCurrentPrevious', 'U') is not null
			drop table DWTOPS.FactLotCurrentPrevious

		rename object DWTOPS.FactLotCurrent to FactLotCurrentPrevious
		rename object DWTOPS.Temp_FactLotCurrent to FactLotCurrent
		drop table DWTOPS.FactLotCurrentPrevious

		CREATE CLUSTERED COLUMNSTORE INDEX [IX_Clus_Colu_FactLotCurrent] ON  [DWTOPS].[FactLotCurrent]

		select @RowsInserted = count(*)
		from DWTOPS.FactLotCurrent 

	end

select @RowsInserted - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated

end