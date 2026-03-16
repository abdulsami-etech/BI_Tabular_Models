Create PROC [DWTOPS].[LoadFactLotHistory] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) ,@IsForceFullLoad [bit] AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@IsFullLoad		bit = 0

set @IsFullLoad = isnull(@IsForceFullLoad, 0)--Set From Flag

	if not exists (select * from DWTOPS.FactLotHistory)
		set @IsFullLoad = 1

	if object_id ('DWTOPS.Temp_FactLotHistory', 'U') is not null
		drop table DWTOPS.Temp_FactLotHistory

	create table DWTOPS.Temp_FactLotHistory with (distribution = hash(DgnLotKey), heap) as 
	select	f.ADLSBatchId										as ADLSBatchId
		,	f.ADLSTimestamp										as ADLSTimestamp
		,	f.LZBatchID											as LZBatchID
		,   @BatchID                                            as DWBatchID
		,	f.DgnCompleteDateTime								as DgnCompleteDateTime
		,	f.DgnStartDateTime									as DgnStartDateTime
		,	f.DgnLotKey											as DgnLotKey
		,	f.DgnLotName										as DgnLotName
		,	f.DgnLotOrderItemKey								as DgnLotOrderItemKey
		,	f.DgnTobjHistoryKey									as DgnTobjHistoryKey
		,	f.DgnWorkOrderKey									as DgnWorkOrderKey
		,	f.DgnWorkOrderNumber								as DgnWorkOrderNumber
		,   f.DgnProductionTeam                                 as DgnProductionTeam
		,	CAST('No' AS Varchar(3))							as IsDuplicatedCompletion
		,	isnull(co.SKComment, -1)							as SKCompleteComment
		,	isnull(convert(int, convert(varchar(8), f.KeyCompleteDate, 112)), -1)	as SKCompleteDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyCompleteTime, 114), ':', '') + '00'), -1) as SKCompleteTime
		,	isnull(convert(int, convert(varchar(8), f.KeyCompleteDateUTC, 112)), -1)	as SKCompleteDateUTC
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyCompleteTimeUTC, 114), ':', '') + '00'), -1) as SKCompleteTimeUTC
		,	isnull(cr.SKCompleteReason, -1)						as SKCompleteReason
		,	isnull(tr.SKTeamRegion, -1)							as SKTeamRegion
		,	isnull(cu.SKUser, -1)								as SKCompleteUserName
		,	isnull(cp.SKCompletionPass,-1)						as SKCompletionPass
		,	isnull(do.SKDoctor, -1)								as SKDoctor
		,	isnull(op.SKOperation, -1)							as SKOperation
		,	isnull(pa.SKPart, -1)								as SKPart
		,	isnull(ro.SKRoute, -1)								as SKRoute
		,	isnull(rs.SKRouteStep, -1)							as SKRouteStep
		,	isnull(convert(int, convert(varchar(8), f.KeyStartDate, 112)), -1)	as SKStartDate
		,	isnull(convert(int, replace(convert(varchar(5), f.KeyStartTime, 114), ':', '') + '00'), -1) as SKStartTime
		,	isnull(su.SKUser, -1)								as SKStartUserName
		,	f.StartCount										as StartCount
		,	f.CompleteCount										as CompleteCount
		,	f.CompleteQuantity									as CompleteQuantity
		,	f.StartQuantity										as StartQuantity
		,	f.StartPauseDuration								as StartPauseDuration
		,	f.CompletePauseDuration								as CompletePauseDuration
		,	f.ClinCheckStatus									as ClinCheckStatus
		,   f.PostClinCheckFail                                 as PostClinCheckFail
		,	f.CycleTimeMinutes									as CycleTimeMinutes
		,   f.NewTreatmentFlow                                  as NewTreatmentFlow
	from SrcMESCorp.SrcFactLotHistory f
	left join DWTOPS.HubComment co on co.KeyComment = f.KeyCompleteComment
	left join DWTOPS.HubCompleteReason cr on cr.KeyCompleteReason = f.KeyCompleteReason
	left join DWTOPS.HubUser cu on cu.KeyUser = f.KeyCompleteUserName
	left join DWTOPS.HubDoctor do on do.KeyDoctor = f.KeyDoctor
	left join DWTOPS.HubOperation op on op.KeyOperation = f.KeyOperation
	left join DWTOPS.HubPart pa on pa.KeyPart = f.KeyPart
	left join DWTOPS.HubRoute ro on ro.KeyRoute = f.KeyRoute
	left join DWTOPS.HubRouteStep rs on rs.KeyRouteStep = f.KeyRouteStep
	left join DWTOPS.HubUser su on su.KeyUser = f.KeyStartUserName
	left join DWTOPS.DimCompletionPass cp on cp.KeyCompletionPass = f.KeyCompletionPass
	left join DWTOPS.HubTeamRegion tr on tr.KeyTeamRegion = f.KeyTeamRegion
	where isnull(f.KeyCompleteDateUTC, f.KeyStartDate) >= '20160101'
		and (
				@IsFullLoad = 1
			or	f.ADLSTimestamp >= isnull(@LastSuccessfullDWTimestamp, '19000101')
		)

	if object_id('tempdb..#EpubFails') is not null
		drop table #EpubFails	

	create table #EpubFails	(DgnTobjHistoryKey bigint not null)
	with (distribution = hash(DgnTobjHistoryKey), heap)	

if @IsFullLoad = 0
BEGIN
	begin tran

	delete from DWTOPS.FactLotHistory
	where exists (
		select *
		from DWTOPS.Temp_FactLotHistory s
		where s.DgnTobjHistoryKey = DWTOPS.FactLotHistory.DgnTobjHistoryKey
	)
	option (Label = 'DWTOPS.LoadFactLotHistory_Delete');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Delete', @rc = @RowsUpdated out

	insert into DWTOPS.FactLotHistory (
			ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DgnCompleteDateTime
		,	DgnStartDateTime
		,	DgnLotKey
		,	DgnLotName
		,	DgnLotOrderItemKey
		,	DgnTobjHistoryKey
		,	DgnWorkOrderKey
		,	DgnWorkOrderNumber
		,   DgnProductionTeam
		,	IsDuplicatedCompletion
		,	SKCompleteComment
		,	SKCompleteDate
		,	SKCompleteTime
		,	SKCompleteDateUTC
		,	SKCompleteTimeUTC
		,	SKCompleteReason
		,   SKTeamRegion
		,	SKCompleteUserName
		,	SKCompletionPass
		,	SKDoctor
		,	SKOperation
		,	SKPart
		,	SKRoute
		,	SKRouteStep
		,	SKStartDate
		,	SKStartTime
		,	SKStartUserName
		,	StartCount
		,	CompleteCount
		,	CompleteQuantity
		,	StartQuantity
		,	StartPauseDuration
		,	CompletePauseDuration
		,	ClinCheckStatus
		,   PostClinCheckFail
		,	CycleTimeMinutes
		,   NewTreatmentFlow
	)
	select	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	@BatchID
		,	DgnCompleteDateTime
		,	DgnStartDateTime
		,	DgnLotKey
		,	DgnLotName
		,	DgnLotOrderItemKey
		,	DgnTobjHistoryKey
		,	DgnWorkOrderKey
		,	DgnWorkOrderNumber
		,   DgnProductionTeam
		,	IsDuplicatedCompletion
		,	SKCompleteComment
		,	SKCompleteDate
		,	SKCompleteTime
		,	SKCompleteDateUTC
		,	SKCompleteTimeUTC
		,	SKCompleteReason
		,   SKTeamRegion
		,	SKCompleteUserName
		,	SKCompletionPass
		,	SKDoctor
		,	SKOperation
		,	SKPart
		,	SKRoute
		,	SKRouteStep
		,	SKStartDate
		,	SKStartTime
		,	SKStartUserName
		,	StartCount
		,	CompleteCount
		,	CompleteQuantity
		,	StartQuantity
		,	StartPauseDuration
		,	CompletePauseDuration
		,	ClinCheckStatus
		,   PostClinCheckFail
		,	CycleTimeMinutes
		,   NewTreatmentFlow
	from DWTOPS.Temp_FactLotHistory
	option (label = 'DWTOPS.LoadFactLotHistory_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Insert', @rc = @RowsInserted out

	insert into #EpubFails (DgnTobjHistoryKey)
	select t.DgnTobjHistoryKey
	from (
		select	TOH.DgnTobjHistoryKey , DOP.OperationName
			,	lead(DOP.OperationName) over (partition by TOH.DgnLotKey order by TOH.DgnCompleteDateTime desc) as PriorOperation
			,	lead(DCR.KeyCompleteReason) over (partition by TOH.DgnLotKey order by TOH.DgnCompleteDateTime desc) as PriorCompleteReason
		from DWTOPS.FactLotHistory TOH
		inner join DWTOPS.DimOperation DOP on DOP.SKOperation = TOH.SKOperation
		inner join DWTOPS.DimCompleteReason DCR	on DCR.SKCompleteReason = TOH.SKCompleteReason
		where exists (
			select *
			from DWTOPS.Temp_FactLotHistory t
			where t.DgnLotKey = TOH.DgnLotKey
		)
		and DOP.OperationName in ('Setup & Stage', 'DDT Bite0', 'Treat','epub')  and TOH.DgnCompleteDateTime  is not null
	) t
	where t.PriorOperation = 'epub' and t.OperationName in ('Setup & Stage', 'DDT Bite0', 'Treat') 
		and t.PriorCompleteReason not like '%Auto%'

	update DWTOPS.FactLotHistory
		set IsDuplicatedCompletion = 'Yes'
	from #EpubFails t
	where t.DgnTobjHistoryKey = DWTOPS.FactLotHistory.DgnTobjHistoryKey 
		and DWTOPS.FactLotHistory.IsDuplicatedCompletion = 'No'

	commit tran
end

 else
	begin --full load
		if object_id ('DWTOPS.FactLotHistoryPrevious', 'U') is not null
			drop table DWTOPS.FactLotHistoryPrevious

		rename object DWTOPS.FactLotHistory to FactLotHistoryPrevious
		rename object DWTOPS.Temp_FactLotHistory to FactLotHistory
		drop table DWTOPS.FactLotHistoryPrevious

		CREATE CLUSTERED COLUMNSTORE INDEX [IX_Clus_Colu_FactLotHistory] ON  [DWTOPS].[FactLotHistory]

        CREATE NONCLUSTERED INDEX [IX_FactLotHistory_SKCompleteDate] ON [DWTOPS].[FactLotHistory]
        (
        	[SKCompleteDate] ASC
        )WITH (DROP_EXISTING = OFF)
		select @RowsInserted = count(*) from DWTOPS.FactLotHistory

        insert into #EpubFails (DgnTobjHistoryKey)
	    select t.DgnTobjHistoryKey
	    from (
	    	select	TOH.DgnTobjHistoryKey , DOP.OperationName
	    		,	lead(DOP.OperationName) over (partition by TOH.DgnLotKey order by TOH.DgnCompleteDateTime desc) as PriorOperation
	    		,	lead(DCR.KeyCompleteReason) over (partition by TOH.DgnLotKey order by TOH.DgnCompleteDateTime desc) as PriorCompleteReason
	    	from DWTOPS.FactLotHistory TOH
	    	inner join DWTOPS.DimOperation DOP on DOP.SKOperation = TOH.SKOperation
	    	inner join DWTOPS.DimCompleteReason DCR	on DCR.SKCompleteReason = TOH.SKCompleteReason
	    	where DOP.OperationName in ('Setup & Stage', 'DDT Bite0', 'Treat','epub')  and TOH.DgnCompleteDateTime  is not null
	    ) t
	    where t.PriorOperation = 'epub' and t.OperationName in ('Setup & Stage', 'DDT Bite0', 'Treat') 
	    	and t.PriorCompleteReason not like '%Auto%'
	    
	    update DWTOPS.FactLotHistory
	    	set IsDuplicatedCompletion = 'Yes'
	    from #EpubFails t
	    where t.DgnTobjHistoryKey = DWTOPS.FactLotHistory.DgnTobjHistoryKey 
	    	and DWTOPS.FactLotHistory.IsDuplicatedCompletion = 'No'



   end

	select @RowsInserted - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated
end