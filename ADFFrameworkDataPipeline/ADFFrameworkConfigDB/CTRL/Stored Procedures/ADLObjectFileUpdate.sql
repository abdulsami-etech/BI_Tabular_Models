

CREATE procedure CTRL.ADLObjectFileUpdate (
		@FileName			varchar(128)
	,	@Destinations		varchar(256) = null
	,	@Destination		varchar(64) = null
	,	@FilePath			varchar(128) = null
	,	@ObjectID			int = null
	,	@Status				varchar(32)
	,	@IsFullLoad			bit = null
	,	@FileSizeInBytes	bigint = null
	,	@ADLSBatchID		int = null
)
as begin
	set nocount on

	if @Destination is not null --update
	begin
		select	@IsFullLoad = IsFullLoad
			,	@ObjectID = ObjectID
		from CTRL.ADLObjectFile 
		where FileName = @FileName 
			and Destination = @Destination

		if @IsFullLoad = 1 and @Status = 'Completed'
		begin
			--we need to update files that were skipped
			update CTRL.ADLObjectFile
				set	Status = 'Skipped'
				,	DateUpdated = getdate()
			where ObjectID = @ObjectID
				and Destination = @Destination
				and Status = 'Ready'
				and FileName < @FileName
		end

		update CTRL.ADLObjectFile
			set	Status = @Status
			,	DateUpdated = getdate()
		where FileName = @FileName
			and Destination = @Destination
	end
	else
	begin --insert new row(s)
		insert into CTRL.ADLObjectFile (
				FileName
			,	Destination
			,	FilePath
			,	ObjectID
			,	Status
			,	DateUpdated
			,	IsFullLoad
			,	FileSizeInBytes
			,	ADLSBatchID
		)
		select	@FileName
			,	s.value
			,	@FilePath
			,	@ObjectID
			,	@Status
			,	getdate()
			,	@IsFullLoad
			,	@FileSizeInBytes
			,	@ADLSBatchID
		from string_split(@Destinations, ',') s
	end
end
