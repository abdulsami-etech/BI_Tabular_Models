
create   procedure CTRL.ETLLogUpdate (
		@LogID					int = null
	,	@ObjectID				int = null
	,	@BatchID				int = null
	,	@PipelineName			varchar(50) = null
	,	@PipelineTriggerType	varchar(50) = null
	,	@LogType				varchar(50) = null
	,	@SinkPathRAW			varchar(256) = null
	,	@SinkName				varchar(256) = null
	,	@DataSliceStartValue	varchar(32) = null
	,	@DataSliceEndValue		varchar(32) = null
	,	@RowsInserted			int = null
	,	@RowsUpdated			int = null
	,	@FileSizeInBytes		bigint = null
	,	@ErrorMessage			nvarchar(4000) = null
)
as begin
	set nocount on

	declare @LoadStatus varchar(50)

	if @ErrorMessage is null --no errors
		if @LogID is null --new log
			set @LoadStatus = 'In Progress'
		else --ETL completed successfully
			set @LoadStatus = 'Success'
	else
		set @LoadStatus = 'Failure'

	if @LogID is null --new log
	begin
		insert into CTRL.ETLLog (
				ObjectID
			,	BatchID
			,	PipelineName
			,	PipelineTriggerType
			,	LogType
			,	SinkPathRAW
			,	SinkName
			,	DataSliceStartValue
			,	DataSliceEndValue
			,	StartTime
			,	LoadStatus
			,	FileSizeInBytes
		)
		values (
				@ObjectID
			,	@BatchID
			,	@PipelineName
			,	@PipelineTriggerType
			,	@LogType
			,	@SinkPathRAW
			,	@SinkName
			,	@DataSliceStartValue
			,	@DataSliceEndValue
			,	getdate()
			,	@LoadStatus
			,	@FileSizeInBytes
		)

		set @LogID = scope_identity()
	end
	else
	begin --update log
		update CTRL.ETLLog
			set	EndTime = getdate()
			,	LoadStatus = @LoadStatus
			,	SinkPathRAW = isnull(SinkPathRAW, @SinkPathRAW)
			,	SinkName = isnull(SinkName, @SinkName)
			,	DataSliceStartValue = isnull(DataSliceStartValue, @DataSliceStartValue)
			,	DataSliceEndValue = isnull(DataSliceEndValue, @DataSliceEndValue)
			,	RowsInserted = @RowsInserted
			,	RowsUpdated = @RowsUpdated
			,	FileSizeInBytes = isnull(FileSizeInBytes, @FileSizeInBytes)
			,	ErrorMessage = @ErrorMessage
		where LogID = @LogID
	end

	select @LogID as LogID
end
