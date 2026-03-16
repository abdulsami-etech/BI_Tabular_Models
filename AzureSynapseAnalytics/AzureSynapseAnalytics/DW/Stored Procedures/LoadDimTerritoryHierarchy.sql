CREATE PROC [DW].[LoadDimTerritoryHierarchy] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimTerritoryHierarchy') is not null
		drop table #TempDimTerritoryHierarchy

	create table #TempDimTerritoryHierarchy with (distribution = round_robin, heap) as 
	with Territories as (
		select	hub.SKTerritory				as SKTerritory
			,	t.ADLSBatchID				as ADLSBatchID
			,	t.ADLSTimestamp				as ADLSTimestamp
			,	t.LZBatchID					as LZBatchID
			,	convert(char(40), '')		as DWHash
			,	t.Id						as KeyTerritory
			,	t.ParentTerritory2Id		as KeyTerritoryParent
			,	t.Territory_ID__c			as TerritoryName
			,	tp.MasterLabel				as TerritoryType
			,	isnull(hubUser.SKUser, -1)	as SKUserOwner
			,	isnull(u.Name, N'N/A')		as OwnerUserName
			,	isnull(convert(nvarchar(64), u.FederationIdentifier), N'N/A')	as OwnerUserEmail
			,	isnull(ur.Name, N'N/A')		as OwnerUserRole
		from SrcSFDC.Territory2 t
		inner join DW.HubTerritory hub on hub.KeyTerritory = t.Id
		inner join SrcSFDC.Territory2Type tp on tp.Id = t.Territory2TypeId
		left join (
			select top (1) with ties
					Territory2Id
				,	UserId
			from SrcSFDC.UserTerritory2Association
			where isnull(RoleInTerritory2, N'') not in ('Delegated', 'Delegated TM')
			order by row_number() over (partition by Territory2Id order by IsActive desc, SystemModStamp desc)
		) usr on usr.Territory2Id = t.Id
		left join SrcSFDC.[User] u on u.Id = usr.UserId
		left join SrcSFDC.UserRole ur on ur.Id = u.UserRoleId
		left join DW.HubUser hubUser on hubUser.KeyUser = usr.UserId
	)
	select	coalesce(L8.SKTerritory, L7.SKTerritory, L6.SKTerritory, L5.SKTerritory, L4.SKTerritory, L3.SKTerritory, L2.SKTerritory, L1.SKTerritory) as SKTerritory --leaf level - PK
		,	coalesce(L8.ADLSBatchID, L7.ADLSBatchID, L6.ADLSBatchID, L5.ADLSBatchID, L4.ADLSBatchID, L3.ADLSBatchID, L2.ADLSBatchID, L1.ADLSBatchID) as ADLSBatchID
		,	coalesce(L8.ADLSTimestamp, L7.ADLSTimestamp, L6.ADLSTimestamp, L5.ADLSTimestamp, L4.ADLSTimestamp, L3.ADLSTimestamp, L2.ADLSTimestamp, L1.ADLSTimestamp) as ADLSTimestamp
		,	coalesce(L8.LZBatchID, L7.LZBatchID, L6.LZBatchID, L5.LZBatchID, L4.LZBatchID, L3.LZBatchID, L2.LZBatchID, L1.LZBatchID) as LZBatchID
		,	convert(char(40), '') as DWHash
		,	coalesce(L8.KeyTerritory, L7.KeyTerritory, L6.KeyTerritory, L5.KeyTerritory, L4.KeyTerritory, L3.KeyTerritory, L2.KeyTerritory, L1.KeyTerritory) as KeyTerritory
		,	coalesce(L8.TerritoryName, L7.TerritoryName, L6.TerritoryName, L5.TerritoryName, L4.TerritoryName, L3.TerritoryName, L2.TerritoryName, L1.TerritoryName) as TerritoryName
		,	coalesce(L8.TerritoryType, L7.TerritoryType, L6.TerritoryType, L5.TerritoryType, L4.TerritoryType, L3.TerritoryType, L2.TerritoryType, L1.TerritoryType) as TerritoryType
		,	coalesce(L8.SKUserOwner, L7.SKUserOwner, L6.SKUserOwner, L5.SKUserOwner, L4.SKUserOwner, L3.SKUserOwner, L2.SKUserOwner, L1.SKUserOwner) as SKUserOwner
		,	coalesce(L8.OwnerUserName, L7.OwnerUserName, L6.OwnerUserName, L5.OwnerUserName, L4.OwnerUserName, L3.OwnerUserName, L2.OwnerUserName, L1.OwnerUserName) as OwnerUserName
		,	coalesce(L8.OwnerUserEmail, L7.OwnerUserEmail, L6.OwnerUserEmail, L5.OwnerUserEmail, L4.OwnerUserEmail, L3.OwnerUserEmail, L2.OwnerUserEmail, L1.OwnerUserEmail) as OwnerUserEmail
		,	coalesce(L8.OwnerUserRole, L7.OwnerUserRole, L6.OwnerUserRole, L5.OwnerUserRole, L4.OwnerUserRole, L3.OwnerUserRole, L2.OwnerUserRole, L1.OwnerUserRole) as OwnerUserRole

		,	coalesce(L7.SKTerritory, L6.SKTerritory, L5.SKTerritory, L4.SKTerritory, L3.SKTerritory, L2.SKTerritory, L1.SKTerritory) as SKTerritoryL7
		,	coalesce(L7.TerritoryName, L6.TerritoryName, L5.TerritoryName, L4.TerritoryName, L3.TerritoryName, L2.TerritoryName, L1.TerritoryName) as TerritoryNameL7
		,	coalesce(L7.SKUserOwner, L6.SKUserOwner, L5.SKUserOwner, L4.SKUserOwner, L3.SKUserOwner, L2.SKUserOwner, L1.SKUserOwner) as SKUserOwnerL7
		,	coalesce(L7.OwnerUserName, L6.OwnerUserName, L5.OwnerUserName, L4.OwnerUserName, L3.OwnerUserName, L2.OwnerUserName, L1.OwnerUserName) as OwnerUserNameL7
		,	coalesce(L7.OwnerUserEmail, L6.OwnerUserEmail, L5.OwnerUserEmail, L4.OwnerUserEmail, L3.OwnerUserEmail, L2.OwnerUserEmail, L1.OwnerUserEmail) as OwnerUserEmailL7
		,	coalesce(L7.OwnerUserRole, L6.OwnerUserRole, L5.OwnerUserRole, L4.OwnerUserRole, L3.OwnerUserRole, L2.OwnerUserRole, L1.OwnerUserRole) as OwnerUserRoleL7

		,	coalesce(L6.SKTerritory, L5.SKTerritory, L4.SKTerritory, L3.SKTerritory, L2.SKTerritory, L1.SKTerritory) as SKTerritoryL6
		,	coalesce(L6.TerritoryName, L5.TerritoryName, L4.TerritoryName, L3.TerritoryName, L2.TerritoryName, L1.TerritoryName) as TerritoryNameL6
		,	coalesce(L6.SKUserOwner, L5.SKUserOwner, L4.SKUserOwner, L3.SKUserOwner, L2.SKUserOwner, L1.SKUserOwner) as SKUserOwnerL6
		,	coalesce(L6.OwnerUserName, L5.OwnerUserName, L4.OwnerUserName, L3.OwnerUserName, L2.OwnerUserName, L1.OwnerUserName) as OwnerUserNameL6
		,	coalesce(L6.OwnerUserEmail, L5.OwnerUserEmail, L4.OwnerUserEmail, L3.OwnerUserEmail, L2.OwnerUserEmail, L1.OwnerUserEmail) as OwnerUserEmailL6
		,	coalesce(L6.OwnerUserRole, L5.OwnerUserRole, L4.OwnerUserRole, L3.OwnerUserRole, L2.OwnerUserRole, L1.OwnerUserRole) as OwnerUserRoleL6

		,	coalesce(L5.SKTerritory, L4.SKTerritory, L3.SKTerritory, L2.SKTerritory, L1.SKTerritory) as SKTerritoryL5
		,	coalesce(L5.TerritoryName, L4.TerritoryName, L3.TerritoryName, L2.TerritoryName, L1.TerritoryName) as TerritoryNameL5
		,	coalesce(L5.SKUserOwner, L4.SKUserOwner, L3.SKUserOwner, L2.SKUserOwner, L1.SKUserOwner) as SKUserOwnerL5
		,	coalesce(L5.OwnerUserName, L4.OwnerUserName, L3.OwnerUserName, L2.OwnerUserName, L1.OwnerUserName) as OwnerUserNameL5
		,	coalesce(L5.OwnerUserEmail, L4.OwnerUserEmail, L3.OwnerUserEmail, L2.OwnerUserEmail, L1.OwnerUserEmail) as OwnerUserEmailL5
		,	coalesce(L5.OwnerUserRole, L4.OwnerUserRole, L3.OwnerUserRole, L2.OwnerUserRole, L1.OwnerUserRole) as OwnerUserRoleL5

		,	coalesce(L4.SKTerritory, L3.SKTerritory, L2.SKTerritory, L1.SKTerritory) as SKTerritoryL4
		,	coalesce(L4.TerritoryName, L3.TerritoryName, L2.TerritoryName, L1.TerritoryName) as TerritoryNameL4
		,	coalesce(L4.SKUserOwner, L3.SKUserOwner, L2.SKUserOwner, L1.SKUserOwner) as SKUserOwnerL4
		,	coalesce(L4.OwnerUserName, L3.OwnerUserName, L2.OwnerUserName, L1.OwnerUserName) as OwnerUserNameL4
		,	coalesce(L4.OwnerUserEmail, L3.OwnerUserEmail, L2.OwnerUserEmail, L1.OwnerUserEmail) as OwnerUserEmailL4
		,	coalesce(L4.OwnerUserRole, L3.OwnerUserRole, L2.OwnerUserRole, L1.OwnerUserRole) as OwnerUserRoleL4

		,	coalesce(L3.SKTerritory, L2.SKTerritory, L1.SKTerritory) as SKTerritoryL3
		,	coalesce(L3.TerritoryName, L2.TerritoryName, L1.TerritoryName) as TerritoryNameL3
		,	coalesce(L3.SKUserOwner, L2.SKUserOwner, L1.SKUserOwner) as SKUserOwnerL3
		,	coalesce(L3.OwnerUserName, L2.OwnerUserName, L1.OwnerUserName) as OwnerUserNameL3
		,	coalesce(L3.OwnerUserEmail, L2.OwnerUserEmail, L1.OwnerUserEmail) as OwnerUserEmailL3
		,	coalesce(L3.OwnerUserRole, L2.OwnerUserRole, L1.OwnerUserRole) as OwnerUserRoleL3

		,	coalesce(L2.SKTerritory, L1.SKTerritory) as SKTerritoryL2
		,	coalesce(L2.TerritoryName, L1.TerritoryName) as TerritoryNameL2
		,	coalesce(L2.SKUserOwner, L1.SKUserOwner) as SKUserOwnerL2
		,	coalesce(L2.OwnerUserName, L1.OwnerUserName) as OwnerUserNameL2
		,	coalesce(L2.OwnerUserEmail, L1.OwnerUserEmail) as OwnerUserEmailL2
		,	coalesce(L2.OwnerUserRole, L1.OwnerUserRole) as OwnerUserRoleL2

		,	L1.SKTerritory as SKTerritoryL1
		,	L1.TerritoryName as TerritoryNameL1
		,	L1.SKUserOwner as SKUserOwnerL1
		,	L1.OwnerUserName as OwnerUserNameL1
		,	L1.OwnerUserEmail as OwnerUserEmailL1
		,	L1.OwnerUserRole as OwnerUserRoleL1
	from Territories L1
	left join Territories L2 on L1.KeyTerritory = L2.KeyTerritoryParent
	left join Territories L3 on L2.KeyTerritory = L3.KeyTerritoryParent
	left join Territories L4 on L3.KeyTerritory = L4.KeyTerritoryParent
	left join Territories L5 on L4.KeyTerritory = L5.KeyTerritoryParent
	left join Territories L6 on L5.KeyTerritory = L6.KeyTerritoryParent
	left join Territories L7 on L6.KeyTerritory = L7.KeyTerritoryParent
	left join Territories L8 on L7.KeyTerritory = L8.KeyTerritoryParent
	where L1.KeyTerritoryParent is null

	update #TempDimTerritoryHierarchy set DWHash =
		convert(char(40),
			hashbytes('SHA1',
						 isnull(convert(nvarchar, TerritoryName), N'N/A')
				+ N'|' + isnull(convert(nvarchar, TerritoryType), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKUserOwner), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserName), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserEmail), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserRole), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKTerritoryL7), N'N/A')
				+ N'|' + isnull(convert(nvarchar, TerritoryNameL7), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKUserOwnerL7), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserNameL7), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserEmailL7), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserRoleL7), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKTerritoryL6), N'N/A')
				+ N'|' + isnull(convert(nvarchar, TerritoryNameL6), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKUserOwnerL6), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserNameL6), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserEmailL6), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserRoleL6), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKTerritoryL5), N'N/A')
				+ N'|' + isnull(convert(nvarchar, TerritoryNameL5), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKUserOwnerL5), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserNameL5), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserEmailL5), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserRoleL5), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKTerritoryL4), N'N/A')
				+ N'|' + isnull(convert(nvarchar, TerritoryNameL4), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKUserOwnerL4), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserNameL4), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserEmailL4), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserRoleL4), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKTerritoryL3), N'N/A')
				+ N'|' + isnull(convert(nvarchar, TerritoryNameL3), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKUserOwnerL3), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserNameL3), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserEmailL3), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserRoleL3), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKTerritoryL2), N'N/A')
				+ N'|' + isnull(convert(nvarchar, TerritoryNameL2), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKUserOwnerL2), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserNameL2), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserEmailL2), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserRoleL2), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKTerritoryL1), N'N/A')
				+ N'|' + isnull(convert(nvarchar, TerritoryNameL1), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKUserOwnerL1), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserNameL1), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserEmailL1), N'N/A')
				+ N'|' + isnull(convert(nvarchar, OwnerUserRoleL1), N'N/A')
			)
		, 2)

	if not exists (select * from DW.DimTerritoryHierarchy where SKTerritory = -1)
	begin
		declare @Hash char(40) = ''

		insert into DW.DimTerritoryHierarchy (
				SKTerritory
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyTerritory
			,	TerritoryName
			,	TerritoryType
			,	SKUserOwner
			,	OwnerUserName
			,	OwnerUserEmail
			,	OwnerUserRole
			,	SKTerritoryL7
			,	TerritoryNameL7
			,	SKUserOwnerL7
			,	OwnerUserNameL7
			,	OwnerUserEmailL7
			,	OwnerUserRoleL7
			,	SKTerritoryL6
			,	TerritoryNameL6
			,	SKUserOwnerL6
			,	OwnerUserNameL6
			,	OwnerUserEmailL6
			,	OwnerUserRoleL6
			,	SKTerritoryL5
			,	TerritoryNameL5
			,	SKUserOwnerL5
			,	OwnerUserNameL5
			,	OwnerUserEmailL5
			,	OwnerUserRoleL5
			,	SKTerritoryL4
			,	TerritoryNameL4
			,	SKUserOwnerL4
			,	OwnerUserNameL4
			,	OwnerUserEmailL4
			,	OwnerUserRoleL4
			,	SKTerritoryL3
			,	TerritoryNameL3
			,	SKUserOwnerL3
			,	OwnerUserNameL3
			,	OwnerUserEmailL3
			,	OwnerUserRoleL3
			,	SKTerritoryL2
			,	TerritoryNameL2
			,	SKUserOwnerL2
			,	OwnerUserNameL2
			,	OwnerUserEmailL2
			,	OwnerUserRoleL2
			,	SKTerritoryL1
			,	TerritoryNameL1
			,	SKUserOwnerL1
			,	OwnerUserNameL1
			,	OwnerUserEmailL1
			,	OwnerUserRoleL1
		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
		)
	end

	update DW.DimTerritoryHierarchy
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchID
		,	DWHash = src.DWHash
		,	TerritoryName = src.TerritoryName
		,	TerritoryType = src.TerritoryType
		,	SKUserOwner = src.SKUserOwner
		,	OwnerUserName = src.OwnerUserName
		,	OwnerUserEmail = src.OwnerUserEmail
		,	OwnerUserRole = src.OwnerUserRole
		,	SKTerritoryL7 = src.SKTerritoryL7
		,	TerritoryNameL7 = src.TerritoryNameL7
		,	SKUserOwnerL7 = src.SKUserOwnerL7
		,	OwnerUserNameL7 = src.OwnerUserNameL7
		,	OwnerUserEmailL7 = src.OwnerUserEmailL7
		,	OwnerUserRoleL7 = src.OwnerUserRoleL7
		,	SKTerritoryL6 = src.SKTerritoryL6
		,	TerritoryNameL6 = src.TerritoryNameL6
		,	SKUserOwnerL6 = src.SKUserOwnerL6
		,	OwnerUserNameL6 = src.OwnerUserNameL6
		,	OwnerUserEmailL6 = src.OwnerUserEmailL6
		,	OwnerUserRoleL6 = src.OwnerUserRoleL6
		,	SKTerritoryL5 = src.SKTerritoryL5
		,	TerritoryNameL5 = src.TerritoryNameL5
		,	SKUserOwnerL5 = src.SKUserOwnerL5
		,	OwnerUserNameL5 = src.OwnerUserNameL5
		,	OwnerUserEmailL5 = src.OwnerUserEmailL5
		,	OwnerUserRoleL5 = src.OwnerUserRoleL5
		,	SKTerritoryL4 = src.SKTerritoryL4
		,	TerritoryNameL4 = src.TerritoryNameL4
		,	SKUserOwnerL4 = src.SKUserOwnerL4
		,	OwnerUserNameL4 = src.OwnerUserNameL4
		,	OwnerUserEmailL4 = src.OwnerUserEmailL4
		,	OwnerUserRoleL4 = src.OwnerUserRoleL4
		,	SKTerritoryL3 = src.SKTerritoryL3
		,	TerritoryNameL3 = src.TerritoryNameL3
		,	SKUserOwnerL3 = src.SKUserOwnerL3
		,	OwnerUserNameL3 = src.OwnerUserNameL3
		,	OwnerUserEmailL3 = src.OwnerUserEmailL3
		,	OwnerUserRoleL3 = src.OwnerUserRoleL3
		,	SKTerritoryL2 = src.SKTerritoryL2
		,	TerritoryNameL2 = src.TerritoryNameL2
		,	SKUserOwnerL2 = src.SKUserOwnerL2
		,	OwnerUserNameL2 = src.OwnerUserNameL2
		,	OwnerUserEmailL2 = src.OwnerUserEmailL2
		,	OwnerUserRoleL2 = src.OwnerUserRoleL2
		,	SKTerritoryL1 = src.SKTerritoryL1
		,	TerritoryNameL1 = src.TerritoryNameL1
		,	SKUserOwnerL1 = src.SKUserOwnerL1
		,	OwnerUserNameL1 = src.OwnerUserNameL1
		,	OwnerUserEmailL1 = src.OwnerUserEmailL1
		,	OwnerUserRoleL1 = src.OwnerUserRoleL1
	from #TempDimTerritoryHierarchy src
	where DW.DimTerritoryHierarchy.SKTerritory = src.SKTerritory
		and DW.DimTerritoryHierarchy.DWHash != src.DWHash
	option (label = 'DW.LoadDimTerritoryHierarchy_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimTerritoryHierarchy_Update', @rc = @RowsUpdated out

	insert into DW.DimTerritoryHierarchy (
			SKTerritory
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyTerritory
		,	TerritoryName
		,	TerritoryType
		,	SKUserOwner
		,	OwnerUserName
		,	OwnerUserEmail
		,	OwnerUserRole
		,	SKTerritoryL7
		,	TerritoryNameL7
		,	SKUserOwnerL7
		,	OwnerUserNameL7
		,	OwnerUserEmailL7
		,	OwnerUserRoleL7
		,	SKTerritoryL6
		,	TerritoryNameL6
		,	SKUserOwnerL6
		,	OwnerUserNameL6
		,	OwnerUserEmailL6
		,	OwnerUserRoleL6
		,	SKTerritoryL5
		,	TerritoryNameL5
		,	SKUserOwnerL5
		,	OwnerUserNameL5
		,	OwnerUserEmailL5
		,	OwnerUserRoleL5
		,	SKTerritoryL4
		,	TerritoryNameL4
		,	SKUserOwnerL4
		,	OwnerUserNameL4
		,	OwnerUserEmailL4
		,	OwnerUserRoleL4
		,	SKTerritoryL3
		,	TerritoryNameL3
		,	SKUserOwnerL3
		,	OwnerUserNameL3
		,	OwnerUserEmailL3
		,	OwnerUserRoleL3
		,	SKTerritoryL2
		,	TerritoryNameL2
		,	SKUserOwnerL2
		,	OwnerUserNameL2
		,	OwnerUserEmailL2
		,	OwnerUserRoleL2
		,	SKTerritoryL1
		,	TerritoryNameL1
		,	SKUserOwnerL1
		,	OwnerUserNameL1
		,	OwnerUserEmailL1
		,	OwnerUserRoleL1
	)
	select	src.SKTerritory
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyTerritory
		,	src.TerritoryName
		,	src.TerritoryType
		,	src.SKUserOwner
		,	src.OwnerUserName
		,	src.OwnerUserEmail
		,	src.OwnerUserRole
		,	src.SKTerritoryL7
		,	src.TerritoryNameL7
		,	src.SKUserOwnerL7
		,	src.OwnerUserNameL7
		,	src.OwnerUserEmailL7
		,	src.OwnerUserRoleL7
		,	src.SKTerritoryL6
		,	src.TerritoryNameL6
		,	src.SKUserOwnerL6
		,	src.OwnerUserNameL6
		,	src.OwnerUserEmailL6
		,	src.OwnerUserRoleL6
		,	src.SKTerritoryL5
		,	src.TerritoryNameL5
		,	src.SKUserOwnerL5
		,	src.OwnerUserNameL5
		,	src.OwnerUserEmailL5
		,	src.OwnerUserRoleL5
		,	src.SKTerritoryL4
		,	src.TerritoryNameL4
		,	src.SKUserOwnerL4
		,	src.OwnerUserNameL4
		,	src.OwnerUserEmailL4
		,	src.OwnerUserRoleL4
		,	src.SKTerritoryL3
		,	src.TerritoryNameL3
		,	src.SKUserOwnerL3
		,	src.OwnerUserNameL3
		,	src.OwnerUserEmailL3
		,	src.OwnerUserRoleL3
		,	src.SKTerritoryL2
		,	src.TerritoryNameL2
		,	src.SKUserOwnerL2
		,	src.OwnerUserNameL2
		,	src.OwnerUserEmailL2
		,	src.OwnerUserRoleL2
		,	src.SKTerritoryL1
		,	src.TerritoryNameL1
		,	src.SKUserOwnerL1
		,	src.OwnerUserNameL1
		,	src.OwnerUserEmailL1
		,	src.OwnerUserRoleL1
	from #TempDimTerritoryHierarchy src
	where not exists (select * from DW.DimTerritoryHierarchy dst where dst.SKTerritory = src.SKTerritory)
	option (label = 'DW.LoadDimTerritoryHierarchy_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimTerritoryHierarchy_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
