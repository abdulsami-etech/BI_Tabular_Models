CREATE PROC [DWIRIS].[LoadHubTicket] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubTicket
		where [SKTicket] = -1
	)
	begin
		set identity_insert DWIRIS.HubTicket on
		begin try
			insert into DWIRIS.HubTicket (
					   [SKTicket]
					 , [KeyTicket]
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
			set identity_insert DWIRIS.HubTicket off;
			throw
		end catch
		set identity_insert DWIRIS.HubTicket off
	end   --if statement

	   
		
	-- Pull all business keys to temp table from MAT and SFDC

	if object_id('tempdb..#TempHubTicket') is not null
		drop table #TempHubTicket
		
	create table #TempHubTicket
		(
			TicketID nchar(36),
			SourceSystemCode varchar(10)
		)
		with (distribution = round_robin, heap) 

	insert into #TempHubTicket (TicketID, SourceSystemCode)
	select TicketID, SourceSystemCode 
	from (	
		select distinct convert(nchar(18),c.Id) as TicketID
			, 'SFDC' as SourceSystemCode 
		from [SrcSFDC].[Case] c
		left join SrcSFDC.RecordType rt
			on rt.Id = c.RecordTypeId
		where rt.Name in ('iTero RMA', 'iTero Support') 
		UNION

		select distinct convert(nchar(18), tt.TicketID)
			, 'MAT' as SourceSystemCode  
		from [SrcMAT].[svc_Ticket] tt
		where tt.TicketID not in (
			select tc.TicketID
			from SrcMAT.TicketComplaint tc
		)
	) t


	--insert new keys to hub
	insert into DWIRIS.HubTicket
	(
		[KeyTicket]
		, [DWBatchID]
		, [InsertDateTime]
		, [SourceSystemCode]
	)
	select TicketID
		, @BatchID
		, @dt
		, SourceSystemCode 
	from #TempHubTicket 
	where TicketID not in (
		select KeyTicket 
		from DWIRIS.HubTicket
	)
	option (label = 'DWIRIS.LoadHubTicket');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubTicket', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end

