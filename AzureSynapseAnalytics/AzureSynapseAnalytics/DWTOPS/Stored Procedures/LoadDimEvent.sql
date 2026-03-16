CREATE PROC [DWTOPS].[LoadDimEvent] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimEvent') is not null
		drop table #TempDimEvent

	create table #TempDimEvent with (distribution = round_robin, heap) as 
	select	max(t.ADLSBatchID)		as ADLSBatchID
		,	max(t.ADLSTimestamp)	as ADLSTimestamp
		,	max(t.LZBatchID)		as LZBatchID
		,	convert(char(40), hashbytes('SHA1', h.KeyEvent), 2) as DWHash
		,	h.SKEvent
		,	h.KeyEvent
	from SrcIDS.tblpuorderstatushistory t
	inner join DWTOPS.HubEvent h on h.KeyEvent = convert(varchar(33), t.event_type)
	where t.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWTOPS.DimEvent)
	group by h.SKEvent, h.KeyEvent

	if not exists (select * from DWTOPS.DimEvent where SKEvent = -1)
	begin
		declare @Hash char(40) = convert(char(40), hashbytes('SHA1', N'N/A'), 2)

		insert into DWTOPS.DimEvent (
				SKEvent
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyEvent
		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,	'N/A'
		)
	end

	insert into DWTOPS.DimEvent (
			SKEvent
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyEvent
	)
	select	src.SKEvent
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyEvent
	from #TempDimEvent src
	where not exists(select * from DWTOPS.DimEvent dst where dst.SKEvent = src.SKEvent)
	option (label = 'DWTOPS.LoadDimEvent_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimEvent_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end
