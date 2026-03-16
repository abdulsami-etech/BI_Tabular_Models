CREATE PROC [DWIRIS].[LoadHubVctTraining] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubVctTraining
		where [SKVctTraining] = -1
	)
	begin
		set identity_insert DWIRIS.HubVctTraining on
		begin try
			insert into DWIRIS.HubVctTraining (
					   [SKVctTraining]
					 , [KeyVctTraining]
					 , [DWBatchID]
					 , [InsertDateTime]
					 , [SourceSystemCode]
			)
			values (
					-1
				,	'N/A'
				,	-1
				,	@dt
				,   'N/A'
			)
		end try
		begin catch
			set identity_insert DWIRIS.HubVctTraining off;
			throw
		end catch
		set identity_insert DWIRIS.HubVctTraining off
	end   --if statement

	   
		
	-- Pull all business keys to temp table from MAT and SFDC

	if object_id('tempdb..#TempHubVctTraining') is not null
		drop table #TempHubVctTraining
		
	create table #TempHubVctTraining
		(
			ID nchar(36),
			SourceSystemCode varchar(10)
		)
		with (distribution = round_robin, heap) 

	insert into #TempHubVctTraining (ID, SourceSystemCode)
		select distinct convert(nchar(18),vct.Id) as ID
			, 'SFDC' as SourceSystemCode 
		from [SrcSFDC].[VCT_Training__C] vct
	


	--insert new keys to hub
	insert into DWIRIS.HubVctTraining
	(
		  [KeyVctTraining]
		, [DWBatchID]
		, [InsertDateTime]
		, [SourceSystemCode]
	)
	select ID
		, @BatchID
		, @dt
		, SourceSystemCode 
	from #TempHubVctTraining
	where ID not in (
		select KeyVctTraining
		from DWIRIS.HubVctTraining
	)
	option (label = 'DWIRIS.LoadHubVctTraining');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubVctTraining', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
