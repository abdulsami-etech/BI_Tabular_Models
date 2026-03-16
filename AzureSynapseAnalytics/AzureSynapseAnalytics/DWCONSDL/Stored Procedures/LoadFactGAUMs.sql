CREATE PROC [DWCONSDL].[LoadFactGAUMs] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	Declare @CurrentDateTime datetime = GETUTCDATE();
	
	if object_id('tempdb..#TempFactGAUMs') is not null
		drop table #TempFactGAUMs

	create table #TempFactGAUMs with (distribution = round_robin, heap) as 
	
SELECT DWHashKey
			,	[Level]
			,	Region
			,	StartDate
			,	EndDate
			,	UVs
			,	UPVs
			,	Sessions

FROM [SrcGoogleBigQuery].[GASessionhitsGAUMs]


update #TempFactGAUMs set DWHashKey=
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, [Level]), N'N/A')
				  + N'|' + isnull(convert(nvarchar, StartDate), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Region), N'N/A')
				)
			, 2)

	
	update DWCONSDL.FactGAUMs
		set	DWBatchID 				= 			@BatchID
		,	UVs						=			src.UVs
		,   UPVs					=			src.UPVs
		,	Sessions				=			src.Sessions
		,	ModifiedDate			=			@CurrentDateTime
	from #TempFactGAUMs src
	where DWCONSDL.FactGAUMs.DWHashKey = src.DWHashKey
		and (DWCONSDL.FactGAUMs.UVs != src.UVs or  DWCONSDL.FactGAUMs.UPVs != src.UPVs or  DWCONSDL.FactGAUMs.Sessions != src.Sessions)
	option (label = 'DWCONSDL.LoadFactGAUMs_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAUMs_Update', @rc = @RowsUpdated out

	insert into DWCONSDL.FactGAUMs (
			DWBatchID
		,	DWHashKey
		,	[Level]
		,	Region
		,	StartDate
		,	EndDate
		,	UVs
		,	UPVs
		,	Sessions
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	DWHashKey
		,	[Level]
		,	Region
		,	StartDate
		,	EndDate
		,	UVs
		,	UPVs
		,	Sessions
		,	@CurrentDateTime
		,	@CurrentDateTime
	from #TempFactGAUMs src
	where not exists(select * from DWCONSDL.FactGAUMs dst where dst.DWHashKey = src.DWHashKey)
	option (label = 'DWCONSDL.LoadFactGAUMs_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAUMs_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end