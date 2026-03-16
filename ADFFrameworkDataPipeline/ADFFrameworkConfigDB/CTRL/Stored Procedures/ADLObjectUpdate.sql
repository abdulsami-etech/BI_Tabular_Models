CREATE procedure CTRL.ADLObjectUpdate (
		@ObjectID				int
	,	@DataSliceStartValue	varchar(32) = null
	,	@DataSliceEndValue		varchar(32) = null
	,	@Status					varchar(32)
	,	@ADLSTimestamp			datetime2(0) = null
)
as begin
	set nocount on

	if @Status = 'Failed'
	begin
		update CTRL.ADLObject
			set	Status = @Status
			,	DateUpdated = getdate()
		where ObjectID = @ObjectID
	end
	else
	begin --success
		if exists (select * from CTRL.ADLObject where ObjectId = @ObjectID and IsInitialOnly = 1)
		begin
			--needed only for initial loading of large objects or for full reload
			update CTRL.ADLObject
				set	Status = @Status
				,	DateUpdated = getdate()
				,	IsActive = 0
				,	LastSuccessfullADLSTimestamp = @ADLSTimestamp
			where ObjectID = @ObjectID
		end else begin
			if @DataSliceStartValue in ('', 'null')
				set @DataSliceStartValue = null

			if @DataSliceEndValue in ('', 'null')
				set @DataSliceEndValue = null

			declare @DataSliceValueDataType varchar(32)
                ,   @DataSliceStartValueSQLVar sql_variant
                ,   @DataSliceEndValueSQLVar sql_variant

			select @DataSliceValueDataType = DataSliceValueDataType
			from CTRL.ADLObject
			where ObjectId = @ObjectID

            if @DataSliceValueDataType = 'Datetime'
            begin
                set @DataSliceStartValueSQLVar = convert(datetime2(7), @DataSliceStartValue)
                set @DataSliceEndValueSQLVar = convert(datetime2(7), @DataSliceEndValue)
            end
            else if @DataSliceValueDataType = 'Numeric'
            begin
                set @DataSliceStartValueSQLVar = convert(bigint, @DataSliceStartValue)
                set @DataSliceEndValueSQLVar = convert(bigint, @DataSliceEndValue)
            end 
            else 
            begin
                set @DataSliceStartValueSQLVar = convert(varchar, @DataSliceStartValue)
                set @DataSliceEndValueSQLVar = convert(varchar, @DataSliceEndValue)
            end

			update CTRL.ADLObject
				set	DataSliceStartValue = @DataSliceStartValueSQLVar
				,	DataSliceEndValue = @DataSliceEndValueSQLVar
				,	Status = @Status
				,	DateUpdated = getdate()
				,	LastSuccessfullADLSTimestamp = @ADLSTimestamp
			where ObjectID = @ObjectID
		end
	end
end

