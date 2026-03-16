create function CTRL.DWGetObjectList (@SchemaName varchar(64))
returns table as
return (
	select	DWObjectId
		,	ObjectName
		,	LastSuccessfullDWTimestamp
		,	IsForceFullLoadOnNextRun
		,	HubSPName
		,	SPName
		,	SCDSPName
		,	CTRL.GetLastSuccessfullTimestamp(DWObjectId) as NewLastSuccessfullDWTimestamp
	from CTRL.DWObject
	where SchemaName = @SchemaName
		and IsActive = 1
)