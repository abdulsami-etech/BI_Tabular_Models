CREATE PROC [DWTOPS].[LoadFactTicketComplaints] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@IsFullLoad		bit = 0

	if not exists (select * from DWTOPS.FactTicketComplaints)
		set @IsFullLoad = 1

	if object_id('tempdb..#TempFactTicketComplaints') is not null
		drop table #TempFactTicketComplaints


	create table #TempFactTicketComplaints with (distribution = hash(DgnCaseNumber), heap) as 

	select	f.ADLSBatchId										as ADLSBatchId
		,	f.ADLSTimestamp										as ADLSTimestamp
		,	f.LZBatchID											as LZBatchID
		,	f.DgnCaseNumber							         	as DgnCaseNumber
		,   f.DgnStatus                                         as DgnStatus
		,	f.DgnCreatedDate							        as DgnCreatedDate
		,	f.DgnComplaintType							     	as DgnComplaintType
		,	f.DgnComplaintSubType								as DgnComplaintSubType
		,	f.DgnManufacturingSite								as DgnManufacturingSite
		,   f.KeyDoctor                                         as DgnDoctor
		,	f.DgnRegion							             	as DgnRegion
		,	isnull(do.SKDoctor, -1)								as SKDoctor

        ,   isnull(convert(int, convert(varchar(8), f.KeyCreatedDate, 112)), -1)	as SKCreatedDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyCreatedTime, 114), ':', '') + '00'), -1) as SKCreatedTime
	    ,   isnull(op.SKPlant, -1)					        	as SKPlantOriginal
		,   isnull(oa.SKPlant, -1)					        	as SKPlantActual
		,   f.IsDesignExecution                                 as IsDesignExecution
		,   f.IsProductEnvelope                                 as IsProductEnvelope
		,   f.IsSystemORSoftware                                as IsSystemORSoftware
		,   f.IsUnspecifiedExpectation                          as IsUnspecifiedExpectation
		,   f.IsAlignerManufacturing                            as IsAlignerManufacturing
		,   f.IsViveraRetainer                                  as IsViveraRetainer
		,   f.IsNonValid                                        as IsNonValid

	from SrcSFDC.SrcFactTicketComplaints f

	left join DWTOPS.HubDoctor do on do.KeyDoctor = f.KeyDoctor
	left join DWTOPS.HubPlant op on op.KeyPlant = f.KeyPlantOriginal
	left join DWTOPS.HubPlant oa on oa.KeyPlant = f.KeyPlantActual

	where 
		 (
				@IsFullLoad = 1
			or	f.ADLSTimestamp >= isnull(@LastSuccessfullDWTimestamp, '19000101')
		)

		


	begin tran

	delete from DWTOPS.FactTicketComplaints
	where exists (
		select *
		from #TempFactTicketComplaints s
		where s.DgnCaseNumber = DWTOPS.FactTicketComplaints.DgnCaseNumber
	)
	option (Label = 'DWTOPS.LoadFactTicketComplaints_Delete');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactTicketComplaints_Delete', @rc = @RowsUpdated out


	delete from DWTOPS.FactTicketComplaints
	where not exists (
		select *
		from SrcSFDC.SrcFactTicketComplaints s
		where s.DgnCaseNumber = DWTOPS.FactTicketComplaints.DgnCaseNumber
	)
	option (Label = 'DWTOPS.LoadFactTicketComplaints_DeleteOld');

	

	INSERT INTO [DWTOPS].[FactTicketComplaints]
           ([ADLSBatchID]
           ,[ADLSTimestamp]
           ,[LZBatchID]
           ,[DWBatchID]
           ,[DgnCaseNumber]
		   ,[DgnStatus]
           ,[DgnCreatedDate]
		   ,[DgnComplaintType]
           ,[DgnComplaintSubType]
           ,[DgnManufacturingSite]
		   ,[DgnDoctor]
           ,[DgnRegion]
           ,[SKDoctor]
           ,[SKCreatedDate]
           ,[SKCreatedTime]
           ,[SkPlantOriginal]
		   ,[SKPlantActual]
           ,[IsDesignExecution]
           ,[IsProductEnvelope]
           ,[IsSystemORSoftware]
           ,[IsUnspecifiedExpectation]
		   ,[IsAlignerManufacturing]
		   ,[IsViveraRetainer]
		   ,[IsNonValid])



	select	[ADLSBatchID]
           ,[ADLSTimestamp]
           ,[LZBatchID]
           ,@BatchID
           ,[DgnCaseNumber]
		   ,[DgnStatus]
           ,[DgnCreatedDate]
		   ,[DgnComplaintType]
           ,[DgnComplaintSubType]
           ,[DgnManufacturingSite]
		   ,[DgnDoctor]
           ,[DgnRegion]
           ,[SKDoctor]
           ,[SKCreatedDate]
           ,[SKCreatedTime]
           ,[SkPlantOriginal]
		   ,[SKPlantActual]
           ,[IsDesignExecution]
           ,[IsProductEnvelope]
           ,[IsSystemORSoftware]
           ,[IsUnspecifiedExpectation]
		   ,[IsAlignerManufacturing]
		   ,[IsViveraRetainer]
		   ,[IsNonValid]
	from #TempFactTicketComplaints

	option (label = 'DWTOPS.LoadFactTicketComplaints_Insert');



	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactTicketComplaints_Insert', @rc = @RowsInserted out


	commit tran

	select @RowsInserted - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated
end