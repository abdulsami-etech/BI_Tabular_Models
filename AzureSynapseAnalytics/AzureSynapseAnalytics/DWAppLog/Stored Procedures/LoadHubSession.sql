CREATE PROC [DWAppLog].[LoadHubSession] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN

	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWAppLog.HubSession
		where SKSession = -1
	)
	begin
		set identity_insert DWAppLog.HubSession on
		begin try
			insert into DWAppLog.HubSession (
					   SKSession
					 , KeyTrace
					 , KeyTs
					 , DWBatchID
					 , InsertDateTime
					 , SourceSystemCode
			)
			values (
					-1
				,	'N/A'
				,	'2020-01-01'
				,	-1
				,	@dt
				,   'N/A'
			)
		end try
		begin catch
			set identity_insert DWAppLog.HubSession off;
			throw
		end catch
		set identity_insert DWAppLog.HubSession off
	end   --if statement

	   
		
	-- Pull all business keys to temp table

	if object_id('tempdb..#TempHubSession') is not null
		drop table #TempHubSession
		
	create table #TempHubSession
		(
			KeyTrace			nvarchar(100)		NOT NULL,
			KeyTs				datetimeoffset		NOT NULL,
			SourceSystemCode	varchar(10)
		)
		with (distribution = round_robin, heap) 

	insert into #TempHubSession (KeyTrace,KeyTs, SourceSystemCode)
	Select 
		cc.trace ,
		cc.ts,
		'CCProCloud' as SourceSystemCode
	from SrcSplunk.CCCloud_AppInit cc
	where cc.action='Application.Init'
	and cc.trace IS NOT NULL
	and cc.ts IS NOT NULL
	and cc.ADLSTimestamp>=@LastSuccessfullDWTimestamp

	--insert new keys to hub
	insert into DWAppLog.HubSession
	(
		KeyTrace
		,KeyTs
		, DWBatchID
		, InsertDateTime
		, SourceSystemCode
	)
	select 
		T.KeyTrace
		,T.KeyTs
		, @BatchID
		, @dt
		, T.SourceSystemCode 
	from #TempHubSession  T
	LEFT JOIN DWAppLog.HubSession H on H.KeyTrace=T.KeyTrace and  H.KeyTs=T.KeyTs
	where H.KeyTrace IS NULL
	option (label = 'DWAppLog.LoadHubSession');

	exec CTRL.GetLastRowCount @Label = 'DWAppLog.LoadHubSession', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end