create procedure CTRL.LZObjectUpdate (
		@LZObjectID			int
	,	@Status				varchar(32)
	,	@CurrentTimestamp	datetime2(0) = null
)
as begin
	set nocount on

	update CTRL.LZObject
		set	Status = @Status
		,	DateUpdated = getdate()
		,	LastSuccessfullLZTimestamp = isnull(@CurrentTimestamp, LastSuccessfullLZTimestamp)
	where LZObjectID = @LZObjectID

end
