CREATE PROC [DWTOPS].[LoadDimCompleteReason] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimCompleteReason') is not null
		drop table #TempDimCompleteReason

	create table #TempDimCompleteReason with (distribution = round_robin, heap) as 
	select	max(t.ADLSBatchID)			as ADLSBatchID
		,	max(t.ADLSTimestamp)		as ADLSTimestamp
		,	max(t.LZBatchID)			as LZBatchID
		,	convert(char(40), '')		as DWHash
		,	h.SKCompleteReason			as SKCompleteReason
		,	convert(varchar(64), t.Complete_Reason) as KeyCompleteReason
		,	convert(varchar(8), 'No')	as IsCompletion
		,	convert(varchar(8), 'No')	as IsReject
		,	convert(varchar(8), 'No')	as IsRework
		,	convert(varchar(8), 'No')	as IsTask
	from SrcMESCorp.TRACKED_OBJECT_HISTORY t
	inner join DWTOPS.HubCompleteReason h on h.KeyCompleteReason = convert(varchar(64), t.Complete_Reason)
	where t.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWTOPS.DimCompleteReason)
	group by h.SKCompleteReason, convert(varchar(64), t.Complete_Reason)

	update #TempDimCompleteReason 
		set IsTask = 'Yes'
	where exists (select * from [SrcMESCorp].[Conf_ReasonCodes] c where c.ReportType = 'Task' and c.CompleteReason = #TempDimCompleteReason.KeyCompleteReason)

	update #TempDimCompleteReason 
		set IsCompletion = 'Yes'
	where exists (select * from [SrcMESCorp].[Conf_ReasonCodes] c where c.ReportType = 'Completions' and c.CompleteReason = #TempDimCompleteReason.KeyCompleteReason)

	update #TempDimCompleteReason 
		set IsReject = 'Yes'
	where exists (select * from [SrcMESCorp].[Conf_ReasonCodes] c where c.ReportType = 'Reject' and c.CompleteReason = #TempDimCompleteReason.KeyCompleteReason)

	update #TempDimCompleteReason 
		set IsRework = 'Yes'
	where exists (select * from [SrcMESCorp].[Conf_ReasonCodes] c where c.ReportType like 'ReWorks' and c.CompleteReason = #TempDimCompleteReason.KeyCompleteReason)

	update #TempDimCompleteReason 
		set DWHash =	convert(char(40), 
							hashbytes('SHA1', 
								KeyCompleteReason
								+ '|' + IsCompletion 
								+ '|' + IsReject
								+ '|' + IsRework
								+ '|' + IsTask
							), 2
						)

	if not exists (select * from DWTOPS.DimCompleteReason where SKCompleteReason = -1)
	begin
		declare @Hash char(40) = convert(char(40), hashbytes('SHA1', N'N/A'), 2)

		insert into DWTOPS.DimCompleteReason (
				SKCompleteReason
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyCompleteReason
			,	IsCompletion
			,	IsReject
			,	IsRework
			,	IsTask
		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,	'N/A'
			,	'N/A'
			,	'N/A'
			,	'N/A'
			,	'N/A'
		)
	end

	update DWTOPS.DimCompleteReason
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchID
		,	DWHash = src.DWHash
		,	IsCompletion = src.IsCompletion
		,	IsReject = src.IsReject
		,	IsRework = src.IsRework
		,	IsTask = src.IsTask
	from #TempDimCompleteReason src
	where DWTOPS.DimCompleteReason.SKCompleteReason = src.SKCompleteReason
		and DWTOPS.DimCompleteReason.DWHash != src.DWHash
	option (label = 'DWTOPS.LoadDimCompleteReason_Update');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimCompleteReason_Update', @rc = @RowsUpdated out

	insert into DWTOPS.DimCompleteReason (
			SKCompleteReason
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyCompleteReason
		,	IsCompletion
		,	IsReject
		,	IsRework
		,	IsTask
	)
	select	src.SKCompleteReason
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyCompleteReason
		,	src.IsCompletion
		,	src.IsReject
		,	src.IsRework
		,	src.IsTask
	from #TempDimCompleteReason src
	where not exists (select * from DWTOPS.DimCompleteReason dst where dst.SKCompleteReason = src.SKCompleteReason)
	option (label = 'DWTOPS.LoadDimCompleteReason_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimCompleteReason_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end
