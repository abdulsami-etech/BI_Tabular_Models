CREATE PROC [DWTOPS].[LoadHubComment] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@CurrentDate	datetime = getdate()

	if not exists (
		select *
		from DWTOPS.HubComment
		where SKComment = -1
	)
	begin
		set identity_insert DWTOPS.HubComment on
		begin try
			insert into DWTOPS.HubComment (
					SKComment
				,	KeyComment
				,	DWBatchID
				,	SourceSystemCode
				,	InsertDateTime
			)
			values (
					-1
				,	-1
				,	-1
				,	N'N/A'
				,	@CurrentDate
			)
		end try
		begin catch
			set identity_insert DWTOPS.HubComment off;
			throw
		end catch
		set identity_insert DWTOPS.HubComment off

	end

	insert into DWTOPS.HubComment (
			KeyComment
		,	DWBatchID
		,	SourceSystemCode
		,	InsertDateTime
	)
	select distinct 
			t.complete_comment as KeyComment
		,	@BatchID
		,	'MESCorp'
		,	@CurrentDate
	from SrcMESCorp.TRACKED_OBJECT_HISTORY t
	where t.complete_comment is not null
		and not exists (
				select *
				from DWTOPS.HubComment h
				where h.KeyComment = t.complete_comment
		)
	option (label = 'DWTOPS.LoadHubComment');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadHubComment', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
