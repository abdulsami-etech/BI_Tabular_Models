CREATE PROC [DWTOPS].[LoadDimComment] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimComment') is not null
		drop table #TempDimComment

	create table #TempDimComment with (distribution = round_robin, heap) as 
	select	max(ADLSBatchID)	as ADLSBatchID
		,	max(ADLSTimestamp)	as ADLSTimestamp
		,	max(LZBatchID)		as LZBatchID
		,	convert(char(40), hashbytes('SHA1', h.KeyComment), 2) as DWHash
		,	h.SKComment			as SKComment
		,	h.KeyComment		as KeyComment
	from SrcMESCorp.TRACKED_OBJECT_HISTORY t
	inner join DWTOPS.HubComment h on h.KeyComment = t.complete_comment
	where t.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWTOPS.DimComment)
	group by h.SKComment, h.KeyComment

	if not exists (select * from DWTOPS.DimComment where SKComment = -1)
	begin
		declare @Hash char(40) = convert(char(40), hashbytes('SHA1', N'N/A'), 2)

		insert into DWTOPS.DimComment (
				SKComment
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyComment
		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,	N'N/A'
		)
	end

	insert into DWTOPS.DimComment (
			SKComment
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyComment
	)
	select	src.SKComment
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyComment
	from #TempDimComment src
	where not exists(select * from DWTOPS.DimComment dst where dst.SKComment = src.SKComment)
	option (label = 'DWTOPS.LoadDimComment_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimComment_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end
