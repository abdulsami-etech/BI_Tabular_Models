CREATE PROC [DWIRIS].[LoadHubCaseType] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubCaseType
		where [SKCaseType] = -1
	)
	begin
		set identity_insert DWIRIS.HubCaseType on
		begin try
			insert into DWIRIS.HubCaseType (
					[SKCaseType]
				,	[KeyCaseType]
				,	DWBatchID
				,	SourceSystemCode
				,	InsertDateTime
			)
			values (
					-1
				,	-1
				,	-1
				,	'N/A'
				,	@dt
			)
		end try
		begin catch
			set identity_insert DWIRIS.HubCaseType off;
			throw
		end catch
		set identity_insert DWIRIS.HubCaseType off
	end   --if statement

	   
		
	insert into DWIRIS.HubCaseType
	(
		[KeyCaseType],
		[DWBatchID],
		[SourceSystemCode],
		[InsertDateTime]
	)
	select CaseTypeId as KeyCase
		, @BatchID
		, 'MAT'
		, @dt 
	from [SrcMAT].[Case_CaseTypes]
	where CaseTypeId not in (
		select [KeyCaseType]
		from DWIRIS.HubCaseType where [SourceSystemCode]='MAT'
	)
	option (label = 'DWIRIS.HubCaseType');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.HubCaseType', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end