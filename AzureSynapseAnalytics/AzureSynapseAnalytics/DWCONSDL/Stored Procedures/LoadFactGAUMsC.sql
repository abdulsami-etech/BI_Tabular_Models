CREATE PROC [DWCONSDL].[LoadFactGAUMsC] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	Declare @CurrentDateTime datetime = GETUTCDATE();
	
	if object_id('tempdb..#TempFactGAUMsC') is not null
		drop table #TempFactGAUMsC

	create table #TempFactGAUMsC with (distribution = round_robin, heap) as 
	
SELECT DWHashKey
			,	[Level]
			,	Region
			,	StartDate
			,	EndDate
			,   CountryFromHostName
			,	UVs
			,	UPVs
			,	Sessions

FROM [SrcGoogleBigQuery].[GASessionhitsGAUMsC]


update #TempFactGAUMsC set DWHashKey=
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, [Level]), N'N/A')
				  + N'|' + isnull(convert(nvarchar, StartDate), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Region), N'N/A')
				  + N'|' + isnull(convert(nvarchar, CountryFromHostName), N'N/A')
				)
			, 2)

	
	update DWCONSDL.FactGAUMsC
		set	DWBatchID 				= 			@BatchID
		,	UVs						=			src.UVs
		,   UPVs					=			src.UPVs
		,   Sessions				=			src.Sessions
		,	ModifiedDate			=			@CurrentDateTime
	from #TempFactGAUMsC src
	where DWCONSDL.FactGAUMsC.DWHashKey = src.DWHashKey
		and (DWCONSDL.FactGAUMsC.UVs != src.UVs or  DWCONSDL.FactGAUMsC.UPVs != src.UPVs or  DWCONSDL.FactGAUMsC.Sessions != src.Sessions)
	option (label = 'DWCONSDL.LoadFactGAUMsC_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAUMsC_Update', @rc = @RowsUpdated out

	insert into DWCONSDL.FactGAUMsC (
			DWBatchID
		,	DWHashKey
		,	[Level]
		,	Region
		,	StartDate
		,	EndDate
		,	CountryFromHostName
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
		,	CountryFromHostName
		,	UVs
		,	UPVs
		,	Sessions
		,	@CurrentDateTime
		,	@CurrentDateTime
	from #TempFactGAUMsC src
	where not exists(select * from DWCONSDL.FactGAUMsC dst where dst.DWHashKey = src.DWHashKey)
	option (label = 'DWCONSDL.LoadFactGAUMsC_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAUMsC_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end