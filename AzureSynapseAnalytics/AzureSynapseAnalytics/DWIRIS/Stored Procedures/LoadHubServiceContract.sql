CREATE PROC [DWIRIS].[LoadHubServiceContract] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubServiceContract
		where [SKServiceContract] = -1
	)
	begin
		set identity_insert DWIRIS.HubServiceContract on
		begin try
			insert into DWIRIS.HubServiceContract (
					[SKServiceContract]
				,	[KeyServiceContract]
				,	DWBatchID
				,	InsertDateTime
			)
			values (
					-1
				,	'N/A'
				,	-1
				,	@dt
			)
		end try
		begin catch
			set identity_insert DWIRIS.HubServiceContract off;
			throw
		end catch
		set identity_insert DWIRIS.HubServiceContract off
	end   --if statement

		

	if object_id('tempdb..#TempHubServiceContract') is not null
		drop table #TempHubServiceContract
		
	create table #TempHubServiceContract with (distribution = round_robin, heap) as

	select Id as KeyServiceContract from SrcSFDC.ServiceContract

	--insert new keys to hub
	insert into DWIRIS.HubServiceContract
	(
		[KeyServiceContract],
		[DWBatchID],
		[InsertDateTime]
	)
	select KeyServiceContract
		, @BatchID
		, @dt 
	from #TempHubServiceContract
	where KeyServiceContract not in (
		select KeyServiceContract
		from DWIRIS.HubServiceContract
	)
	option (label = 'DWIRIS.LoadHubServiceContract');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubServiceContract', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
