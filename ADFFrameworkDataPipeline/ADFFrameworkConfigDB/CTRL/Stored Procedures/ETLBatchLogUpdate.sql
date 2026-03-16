CREATE procedure CTRL.ETLBatchLogUpdate (
		@SourceSystem		varchar(32)
	,	@BatchID			int = null
	,	@ErrorMessage		nvarchar(4000) = null
)
as begin
	set nocount on

	declare @LoadStatus varchar(50)

	if @ErrorMessage is null --no errors
		if @BatchID is null --new batch
			set @LoadStatus = 'In Progress'
		else --ETL completed successfully
			set @LoadStatus = 'Success'
	else
		set @LoadStatus = 'Failure'

	if @BatchID is null --new batch
	begin
		while (1 = 1)
		begin
			select @BatchID = isnull(max(BatchID), 0) + 1
			from CTRL.ETLBatchLog
			where SourceSystem = @SourceSystem

			begin try
				insert into CTRL.ETLBatchLog (
						SourceSystem
					,	BatchID
					,	StartTime
					,	EndTime
					,	LoadStatus
					,	ErrorMessage
				)
				values (
						@SourceSystem
					,	@BatchID
					,	getdate()
					,	null
					,	@LoadStatus
					,	null
				)
				--inserted successfully, we can break the loop
				break
			end try
			begin catch
				continue --PK error happened, need to try again
			end catch
		end
	end
	else
	begin
		update CTRL.ETLBatchLog
			set	EndTime = getdate()
			,	LoadStatus = @LoadStatus
			,	ErrorMessage = @ErrorMessage
		where SourceSystem = @SourceSystem
			and BatchID = @BatchID
	end

	select @BatchID as BatchID

end