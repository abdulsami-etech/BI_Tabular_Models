CREATE PROC [DWIRIS].[LoadHubTicketItem] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknown element
	
	if not exists (
		select *
		from DWIRIS.HubTicketItem
		where [SKTicketItem] = -1
	)
	begin
		set identity_insert DWIRIS.HubTicketItem on
		begin try
			insert into DWIRIS.HubTicketItem (
					[SKTicketItem]
				,	[KeyTicketItem]
				,	[DWBatchID]
				,	[InsertDateTime]
				,	[SourceSystemCode]
			)
			values (
					-1
				,	N''
				,	-1
				,	@dt
				,   'N/A'
			)
		end try
		begin catch
			set identity_insert DWIRIS.HubTicketItem off;
			throw
		end catch
		set identity_insert DWIRIS.HubTicketItem off
	end   --if statement

	   
		
	-- Pull all business keys to temp table from MAT and SFDC

	if object_id('tempdb..#TempHubTicketItem') is not null
		drop table #TempHubTicketItem
		
	create table #TempHubTicketItem
		(
			TicketItemID nchar(18),
			SourceSystemCode varchar(10)
		)
		with (distribution = round_robin, heap) 

	insert into #TempHubTicketItem (
		TicketItemID
		, SourceSystemCode
	)
	select iopd.Id as TicketItemID
		, 'SFDC' as SourceSystemCode 
	from SrcSFDC.Itero_Order_Product_Details__c iopd
	union all
	select convert(nchar(18), track.ID) as TicketItemID
		, 'MAT' as SourceSystemCode
	from SrcMAT.svc_Ticket_PartsTracking track


	--insert new keys to hub
	insert into DWIRIS.HubTicketItem
	(
		KeyTicketItem
	,	DWBatchID
	,	InsertDateTime
	,	SourceSystemCode
	)
	select src.TicketItemID
		, @BatchID
		, @dt
		, src.SourceSystemCode 
	from #TempHubTicketItem src
	where src.TicketItemID not in (select dst.KeyTicketItem from DWIRIS.HubTicketItem dst)
	option (label = 'DWIRIS.LoadHubTicketItem');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubTicketItem', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end

