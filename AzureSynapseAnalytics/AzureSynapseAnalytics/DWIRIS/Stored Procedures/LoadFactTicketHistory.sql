CREATE PROC [DWIRIS].[LoadFactTicketHistory] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted		int = 0
		,	@RowsUpdated		int = 0
	
	if object_id('tempdb..#TempFactTicketHistory') is not null
		drop table #TempFactTicketHistory

	create table #TempFactTicketHistory with (distribution = round_robin, heap) as 
	select	a.ID					as ID
		,	a.ADLSBatchID				as ADLSBatchID
		,	a.ADLSTimestamp				as ADLSTimestamp
		,	a.LZBatchID					as LZBatchID
		,	a.Field						as [FieldType]
		,	a.oldValue					as [OldValue]
		,   a.createdDate				as [CreatedDate]
		,   isnull(dt.skdate,-1) as SKDate
		,	isnull(us.SKUser,-1)					as SKUser
		,	isnull(ticket.SKTicket,-1)					as SKTicket
		,	isnull(Complaints.SKTicketComplaint,-1)			as SKTicketComplaint
		,	isnull(Onboarding.SKTicketonboarding,-1)			as SKTicketonboarding
		,	isnull(Training.SKTicketTraining,-1)			as SKTicketTraining
	from srcsfdc.casehistory a
	inner join srcsfdc.[case] b on a.caseid=b.id
	inner join srcsfdc.recordtype c on c.id=b.recordtypeid
	inner join dw.dimdate dt on dt.keydate=cast(a.createddate as date)
	left join [DWIRIS].[hubuser] us on us.KeyUser = a.newvalue 
	left join [DWIRIS].[hubTicket] ticket on ticket.keyticket =a.caseid
	left join [DWIRIS].[hubTicketComplaint] Complaints on Complaints.keyticketComplaint =a.caseid
	left join [DWIRIS].[hubTicketOnboarding] Onboarding on Onboarding.keyticketOnboarding =a.caseid
	left join [DWIRIS].[hubTicketTraining] Training on Training.keytickettraining =a.caseid
	where a.ADLSTimestamp >= isnull(@LastSuccessfullDWTimestamp, '19000101')
		and c.Name in ('iTero RMA','iTero Support','iTero Complaint','iTero Onboarding','iTero Training')
		and a.field='owner'
	begin tran
		delete from DWIRIS.FactTicketHistory 
		where exists (
			select *
			from #TempFactTicketHistory s
			where s.ID = DWIRIS.FactTicketHistory.ID
		)
			option (Label = 'DWIRIS.FactTicketHistory_Delete');
			exec CTRL.GetLastRowCount @Label = 'DWIRIS.FactTicketHistory_Delete', @rc = @RowsUpdated out
		insert into DWIRIS.FactTicketHistory (
		    [ID]
		  ,[ADLSBatchID]
		  ,[ADLSTimestamp] 
		  ,[LZBatchID]
		  ,[DWBatchID] 
		  ,[FieldType]
		  ,[OldValue]
		  ,[CreatedDate]
		  ,[SKDate]
		  ,[SKUser]
		  ,[SKTicket]
		  ,[SKTicketComplaint]
		  ,[SKTicketonboarding]
		  ,[SKTicketTraining]
		)
		select	[ID]
			  ,[ADLSBatchID]
			  ,[ADLSTimestamp] 
			  ,[LZBatchID]
			  ,@BatchID 
			  ,[FieldType]
			  ,[OldValue]
			  ,[CreatedDate]
			  ,[SKDate]
			  ,[SKUser]
			  ,[SKTicket]
			  ,[SKTicketComplaint]
			  ,[SKTicketonboarding]
			  ,[SKTicketTraining]
		from #TempFactTicketHistory
		option (label = 'DWIRIS.FactTicketHistory_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.FactTicketHistory_Insert', @rc = @RowsInserted out
	commit tran

	select @RowsInserted as RowsInserted, 0 as RowsUpdated
	
end
