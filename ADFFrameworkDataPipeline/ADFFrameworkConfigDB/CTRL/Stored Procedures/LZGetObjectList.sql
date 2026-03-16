
CREATE procedure CTRL.LZGetObjectList (
		@SourceSystemList	varchar(1000) = null --for all sources if null
	,	@Destination		varchar(64)
	,	@ObjectList			varchar(8000) = null
)
as
begin
	set nocount on

	declare @ObjectsToProcess table (LZObjectID int);  

	begin tran

	update CTRL.LZObject with (tablockx)
		set Status = 'In Progress'
		,	DateUpdated = getdate()
	output inserted.LZObjectID  
	into @ObjectsToProcess
	where (@SourceSystemList is null or SourceSystem in (select value from string_split(@SourceSystemList, ',')))
		and Destination = @Destination
		and IsActive = 1
		and Status = 'Ready'
		and (isnull(@ObjectList, '') = '' or LZObjectID in (select value from string_split(@ObjectList, ',')))

	select	LZObjectID
		,	SourceSystem
		,	ObjectName
		,	iif(SourceSystem = 'SFDC', SFDCFlattenedHistoryColumnList, null) as SFDCFlattenedHistoryColumnList
	from CTRL.LZObject
	where LZObjectID in (select LZObjectID from @ObjectsToProcess)

	commit tran

end
