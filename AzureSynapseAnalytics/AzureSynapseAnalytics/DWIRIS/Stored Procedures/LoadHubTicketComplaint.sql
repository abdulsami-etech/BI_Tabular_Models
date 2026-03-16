CREATE PROC [DWIRIS].[LoadHubTicketComplaint] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubTicketComplaint
		where [SKTicketComplaint] = -1
	)
	begin
		set identity_insert DWIRIS.HubTicketComplaint on
		begin try
			insert into DWIRIS.HubTicketComplaint (
					   [SKTicketComplaint]
					 , [KeyTicketComplaint]
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
			set identity_insert DWIRIS.HubTicketComplaint off;
			throw
		end catch
		set identity_insert DWIRIS.HubTicketComplaint off
	end   --if statement

	   
		
	-- Pull all business keys to temp table from MAT and SFDC

	if object_id('tempdb..#TempHubTicketComplaint') is not null
		drop table #TempHubTicketComplaint
		
	create table #TempHubTicketComplaint
		(
			TicketID nchar(36),
			SourceSystemCode varchar(10)
		)
		with (distribution = round_robin, heap) 

	insert into #TempHubTicketComplaint (TicketID, SourceSystemCode)
	select TicketID, SourceSystemCode 
	from (	
		select distinct convert(nchar(18),c.Id) as TicketID
			, 'SFDC' as SourceSystemCode 
		from [SrcSFDC].[Case] c
		left join SrcSFDC.RecordType rt
			on rt.Id = c.RecordTypeId
		where rt.Name in ('iTero Complaint') 
		UNION

		select distinct convert(nchar(18), tt.TicketID)
			, 'MAT' as SourceSystemCode  
		from [SrcMAT].[svc_Ticket] tt
		where tt.TicketID in (
			select tc.TicketID
			from SrcMAT.TicketComplaint tc
		)
	) t


	--insert new keys to hub
	insert into DWIRIS.HubTicketComplaint
	(
		[KeyTicketComplaint]
		, [DWBatchID]
		, [InsertDateTime]
		, [SourceSystemCode]
	)
	select TicketID
		, @BatchID
		, @dt
		, SourceSystemCode 
	from #TempHubTicketComplaint
	where TicketID not in (
		select KeyTicketComplaint
		from DWIRIS.HubTicketComplaint
	)
	option (label = 'DWIRIS.LoadHubTicketComplaint');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubTicketComplaint', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end

