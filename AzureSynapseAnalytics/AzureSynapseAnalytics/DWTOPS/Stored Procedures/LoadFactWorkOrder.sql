CREATE PROC [DWTOPS].[LoadFactWorkOrder] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@IsFullLoad		bit = 0

	set @IsFullLoad = isnull(@IsForceFullLoad, 0)--Set From Flag


	if not exists (select * from DWTOPS.FactWorkOrder)
		set @IsFullLoad = 1


	if object_id ('DWTOPS.Temp_FactWorkOrder', 'U') is not null
		drop table DWTOPS.Temp_FactWorkOrder


	create table DWTOPS.Temp_FactWorkOrder with (distribution = hash(DgnWorkOrderKey), heap) as 
	select	f.ADLSBatchID															as ADLSBatchID
		,	f.ADLSTimestamp															as ADLSTimestamp
		,	f.LZBatchID																as LZBatchID
		,   @BatchID                                                                as DWBatchID
		,	f.DgnAllMaterialReceivedDateTime										as DgnAllMaterialReceivedDateTime
		,	f.DgnVIPOrderNumber														as DgnVIPOrderNumber
		,	f.DgnWorkOrderKey														as DgnWorkOrderKey
		,	f.DgnWorkOrderNumber													as DgnWorkOrderNumber
		,	f.DgnIsRejectedImpression												as DgnIsRejectedImpression
        ,	f.DgnIsIPLEnabled												        as DgnIsIPLEnabled
		,	f.DgnIsScan																as DgnIsScan
		,	f.DgnIOScanType															as DgnIOScanType
		,	f.DgnHardwareVersion													as DgnHardwareVersion
		,	f.DgnSoftwareVersion													as DgnSoftwareVersion
		,	f.DgnDeliverableType													as DgnDeliverableType
		,	f.DgnTreatmentCategory													as DgnTreatmentCategory
		,	f.DgnStorageLocation													as DgnStorageLocation
		,   f.DgnPilotDescription                                                   as DgnPilotDescription
		,   f.DgnTreatmentFlow                                                      as DgnTreatmentFlow 
		,   f.DgnProcessingType														as DgnProcessingType	
		,   f.DgnMAFeature															as DgnMAFeature		
		,   f.DgnIsMTPSend															as DgnIsMTPSend		
		,   f.DgnSTPExecuted														as DgnSTPExecuted	
		,	isnull(do.SKDoctor, -1)													as SKDoctor
		,	isnull(ex.SKExpediteScope, -1)											as SKExpediteScope
		,	isnull(convert(int, convert(varchar(8), f.KeyMaterialReceivedDate, 112)), -1) as SKMaterialReceivedDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyMaterialReceivedTime, 114), ':', '') + '00'), -1) as SKMaterialReceivedTime
		,	isnull(convert(int, convert(varchar(8), f.KeyOrderCreationDate, 112)), -1) as SKOrderCreationDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyOrderCreationTime, 114), ':', '') + '00'), -1) as SKOrderCreationTime
		,	isnull(plo.SKPlant, -1) AS SKPlantOrderEntry
		,	isnull(co.SKCountry,-1) as SKCountry
		,   isnull(ocr.SKCancelReason,-1)                                           as SKCancelReason
		,   isnull(convert(int, convert(varchar(8), f.KeyCancelledDate, 112)), -1)  as SKCancelledDate
		,	f.DurationToFinishedInMinutes                                                                      
	from SrcMESCorp.SrcFactWorkOrder f
	left join DWTOPS.HubDoctor do on do.KeyDoctor = f.KeyDoctor
	left join DWTOPS.HubPlant plo on plo.KeyPlant = f.KeyPlantOrderEntry
	left join DWTOPS.HubExpediteScope ex on ex.KeyExpediteScope = f.KeyExpediteScope
	left join DW.DimCountry co on co.CountryCode = f.KeyCountryCode
	left join DWTOPS.DimOrderCancelReason ocr on ocr.CancelReasonCode = f.CancelledReason
	where f.DgnUOLastModifiedDate >= '20160101'
		and (
				@IsFullLoad = 1
			or	f.ADLSTimestamp >= isnull(@LastSuccessfullDWTimestamp, '19000101')
		)


if @IsFullLoad = 0
BEGIN

	begin tran

	delete from DWTOPS.FactWorkOrder
	where exists (
		select *
		from DWTOPS.Temp_FactWorkOrder s
		where s.DgnWorkOrderKey = DWTOPS.FactWorkOrder.DgnWorkOrderKey
	)
	option (Label = 'DWTOPS.LoadFactWorkOrder_Delete');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactWorkOrder_Delete', @rc = @RowsUpdated out

	insert into DWTOPS.FactWorkOrder (
			ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DgnAllMaterialReceivedDateTime
		,	DgnVIPOrderNumber
		,	DgnWorkOrderKey
		,	DgnWorkOrderNumber
		,	DgnIsRejectedImpression
		,   DgnIsIPLEnabled
		,	DgnIsScan
		,	DgnIOScanType
		,	DgnHardwareVersion
		,	DgnSoftwareVersion
		,	DgnDeliverableType
		,	DgnTreatmentCategory
		,	DgnStorageLocation
		,   DgnPilotDescription
		,   DgnTreatmentFlow
		,	DgnProcessingType
		,	DgnMAFeature		
		,	DgnIsMTPSend		
		,	DgnSTPExecuted	
		,	SKDoctor
		,	SKExpediteScope
		,	SKMaterialReceivedDate
		,	SKMaterialReceivedTime
		,	SKOrderCreationDate
		,	SKOrderCreationTime
		,	SKPlantOrderEntry
		,	SKCountry
		,   SKCancelReason
		,   SKCancelledDate
		,	DurationToFinishedInMinutes
	)
	select	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DgnAllMaterialReceivedDateTime
		,	DgnVIPOrderNumber
		,	DgnWorkOrderKey
		,	DgnWorkOrderNumber
		,	DgnIsRejectedImpression
        ,   DgnIsIPLEnabled
		,	DgnIsScan
		,	DgnIOScanType
		,	DgnHardwareVersion
		,	DgnSoftwareVersion
		,	DgnDeliverableType
		,	DgnTreatmentCategory
		,	DgnStorageLocation
		,   DgnPilotDescription
		,   DgnTreatmentFlow
		,	DgnProcessingType
		,	DgnMAFeature		
		,	DgnIsMTPSend		
		,	DgnSTPExecuted	
		,	SKDoctor
		,	SKExpediteScope
		,	SKMaterialReceivedDate
		,	SKMaterialReceivedTime
		,	SKOrderCreationDate
		,	SKOrderCreationTime
		,	SKPlantOrderEntry
		,	SKCountry
		,   SKCancelReason
		,   SKCancelledDate
		,	DurationToFinishedInMinutes
	from DWTOPS.Temp_FactWorkOrder
	option (label = 'DWTOPS.LoadFactWorkOrder_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactWorkOrder_Insert', @rc = @RowsInserted out

	commit tran

	
  end

  	else
	begin --full load
		if object_id ('DWTOPS.FactWorkOrderPrevious', 'U') is not null
			drop table DWTOPS.FactWorkOrderPrevious

		rename object DWTOPS.FactWorkOrder to FactWorkOrderPrevious
		rename object DWTOPS.Temp_FactWorkOrder to FactWorkOrder
		drop table DWTOPS.FactWorkOrderPrevious

		CREATE CLUSTERED COLUMNSTORE INDEX [IX_Clus_Colu_FactWorkOrder] ON [DWTOPS].[FactWorkOrder]

		select @RowsInserted = count(*)
		from DWTOPS.FactWorkOrder 

	end

select @RowsInserted - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated

end
GO