CREATE PROC [DW].[LoadDimGroupAccount] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0), @IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@CurrentDate	datetime2(0) = getdate()
		
	if object_id('tempdb..#tmpGroupAccountsBDMs') is not null
	drop table #tmpGroupAccountsBDMs

	create table #tmpGroupAccountsBDMs with (distribution = round_robin, heap) as 
	select distinct dat.SKAccount as SKDSOAccount, dat.SKTerritory
		from DW.DimAccountTerritoryAssociation dat 
		inner join DW.DimTerritory dt on dat.SKTerritory = dt.SKTerritory
		where dt.TerritoryType IN ( N'BDM',N'SG')
		
	if object_id('tempdb..#tmpDimGroupAccount') is not null
		drop table #tmpDimGroupAccount
	create table #tmpDimGroupAccount (
			SKAccount					int				not null
		,	AccountNumber				nvarchar(40)	not null
		,	SKDSOAccount				int				not null
		,	DSOAccountNumber			nvarchar(40)	not null
		,	DSOAccountName				nvarchar(128)	not null
		,	SKTerritory					int				not null
	)
	with
	(
		distribution = round_robin,
		heap
	)

	insert into #tmpDimGroupAccount (
			SKAccount
		,	AccountNumber
		,	SKDSOAccount
		,	DSOAccountNumber
		,	DSOAccountName
		,	SKTerritory
	)
	select	isnull(a.SKAccount, ga.SKAccount) as SKAccount
		,	isnull(a.AccountNumber, ga.AccountNumber) as AccountNumber
		,	ga.SKAccount as SKDSOAccount
		,	ga.AccountNumber as DSOAccountNumber
		,	ga.AccountName as DSOAccountName
		,	bdm.SKTerritory
	from #tmpGroupAccountsBDMs bdm
	inner join DW.DimAccount ga on ga.SKAccount = bdm.SKDSOAccount
	left join DW.DimAccount a on a.SKParentLevel1 = ga.SKAccount
	where 
	--this filter identifies group accounts
	-- Removing below Group Account  and DSO - NA filter in order to roll Swanky smile into BDM hierarchy
	-- Changed by SSK 7-27-2018
		/*	ga.AccountType = N'Group'
		and ga.AccountSubType = N'DSO - NA'
		and  */
		ga.SKParentLevel1 is null

	--adding study group accounts
	insert into #tmpDimGroupAccount (
			SKAccount
		,	AccountNumber
		,	SKDSOAccount
		,	DSOAccountNumber
		,	DSOAccountName
		,	SKTerritory
	)
	select	a.SKAccount
		,	a.AccountNumber
		,	ga.SKAccount as SKDSOAccount
		,	ga.AccountNumber as DSOAccountNumber
		,	ga.AccountName as DSOAccountName
		,	bdm.SKTerritory
	from DW.DimAccount ga
	inner join #tmpGroupAccountsBDMs bdm on ga.SKAccount = bdm.SKDSOAccount
	inner join DW.DimAccount a on a.StudyGroupName = ga.KeyAccount
									and a.SKAccount != ga.SKAccount
	where not exists (--only new ones
		select *
		from #tmpDimGroupAccount t
		where t.SKAccount = a.SKAccount
	)
	
	

	--adding group account itself to the Account level of the hierarchy
	insert into #tmpDimGroupAccount (
			SKAccount
		,	AccountNumber
		,	SKDSOAccount
		,	DSOAccountNumber
		,	DSOAccountName
		,	SKTerritory
	)
	select distinct
			ga.SKDSOAccount
		,	ga.DSOAccountNumber
		,	ga.SKDSOAccount
		,	ga.DSOAccountNumber
		,	ga.DSOAccountName
		,	ga.SKTerritory
	from #tmpDimGroupAccount ga
	where not exists (--only new ones
		select *
		from #tmpDimGroupAccount t
		where t.SKAccount = ga.SKDSOAccount
	)

	--adding LIDs
	insert into #tmpDimGroupAccount (
			SKAccount
		,	AccountNumber
		,	SKDSOAccount
		,	DSOAccountNumber
		,	DSOAccountName
		,	SKTerritory
	)
	select	a.SKAccount
		,	a.AccountNumber
		,	did.SKDSOAccount
		,	did.DSOAccountNumber
		,	did.DSOAccountName
		,	did.SKTerritory
	from #tmpDimGroupAccount did
	inner join DW.DimAccount a on a.SKParentLevel1 = did.SKAccount
	where not exists (--only new ones
		select *
		from #tmpDimGroupAccount t
		where t.SKAccount = a.SKAccount
		)
		
		
		
		
		
		
		if object_id('tempdb..#TempDimGroupAccount') is not null
		drop table #TempDimGroupAccount

	create table #TempDimGroupAccount with (distribution = round_robin, heap) as 
	
		select tdga.SKAccount
		,	tdga.AccountNumber
		,	convert(char(40), '')	as DWHash
		,	tdga.SKDSOAccount
		,	tdga.DSOAccountNumber
		,	tdga.DSOAccountName
		--Person names
		,	convert(nvarchar(150), isnull(u6.UserName, N'Unassigned')) as BDM
		,	convert(nvarchar(150), isnull(u3.UserName, N'Unassigned (' + coalesce(u3.UserName, dth.TerritoryNameL3, 'Unassigned') + ')'))	as RM
		,	convert(nvarchar(150), isnull(u4.UserName, N'Unassigned (' + coalesce(u4.UserName, dth.TerritoryNameL4, 'Unassigned') + ')'))	as SM
		,	convert(nvarchar(150), isnull(u2.UserName, N'Unassigned (' + coalesce(u1.UserName, dth.TerritoryNameL2, 'Unassigned') + ')'))	as ASD
		-- ,	dth.OwnerUserNameL6 as BDM
		-- ,	dth.OwnerUserNameL3 as RM
		-- ,	dth.OwnerUserNameL4 as SM
		-- ,	dth.OwnerUserNameL2 as ASD

		----Territory names
		,	convert(nvarchar(50), isnull(dth.TerritoryNameL6, N'Unassigned')) as BDMTerritoryName
		,	convert(nvarchar(50), isnull(dth.TerritoryNameL3, N'Unassigned')) as RMTerritoryName
		,	convert(nvarchar(50), isnull(dth.TerritoryNameL4, N'Unassigned')) as SMTerritoryName
		,	convert(nvarchar(50), isnull(dth.TerritoryNameL2, N'Unassigned (' + coalesce(dth.TerritoryNameL1, 'Unassigned') + ')')) as ASDTerritoryName
		-- ,	dth.TerritoryNameL6 as BDMTerritoryName
		-- ,	dth.TerritoryNameL3 as RMTerritoryName
		-- ,	dth.TerritoryNameL4 as SMTerritoryName
		-- ,	dth.TerritoryNameL2 as ASDTerritoryName

		----Concatenated person with label, to use as member_name in the dimension
		,	convert(nvarchar(150),
				isnull(u6.UserName, N'Unassigned') + ' ('+ isnull(dth.TerritoryNameL6, N'Unassigned') +')'
			) as BDMConcat
		,	convert(nvarchar(150),
				isnull(u3.UserName, N'Unassigned')  +' ('+ isnull(dth.TerritoryNameL3, N'Unassigned')   +')'
			) as RMConcat
			,	convert(nvarchar(150),
				isnull(u4.UserName, N'Unassigned')  +' ('+ isnull(dth.TerritoryNameL4, N'Unassigned')   +')'
			) as SMConcat
		,	convert(nvarchar(150),
				isnull(u2.UserName, N'Unassigned')+' ('  + isnull(dth.TerritoryNameL2, N'Unassigned') +')'
			) as ASDConcat

		-- ,	convert(nvarchar(100),
				-- isnull(dth.OwnerUserNameL6, N'Unassigned') + ' ('+ isnull(dth.TerritoryNameL6, N'Unassigned') +')'
			-- ) as BDMConcat
		-- ,	convert(nvarchar(100),
				-- isnull(dth.OwnerUserNameL3, N'Unassigned')  +' ('+ isnull(dth.TerritoryNameL3, N'Unassigned')   +')'
			-- ) as RMConcat
			-- ,	convert(nvarchar(100),
				-- isnull(dth.OwnerUserNameL4, N'Unassigned')  +' ('+ isnull(dth.TerritoryNameL4, N'Unassigned')   +')'
			-- ) as SMConcat
		-- ,	convert(nvarchar(100),
				-- isnull(dth.OwnerUserNameL2, N'Unassigned')+' ('  + isnull(dth.TerritoryNameL2, N'Unassigned') +')'
			-- ) as ASDConcat

		-- User Ids
		,	u6.SKUser as SKBDMUser
		,	u6.KeyUser as BDMUserId
		,	u3.SKUser as SKRMUser
		,	u3.KeyUser as RMUserId
		,	u4.SKUser as SKSMUser
		,	u4.KeyUser as SMUserId
		,	u2.SKUser as SKASDUser
		,	u2.KeyUser as ASDUserId
		
		-- User Identifiers
		,	convert(nvarchar(32), 
				case when charindex('@', u6.FederationIdentifier) > 1
					then substring(u6.FederationIdentifier, 1, charindex('@', u6.FederationIdentifier) - 1)
					else isnull(u6.FederationIdentifier, N'Unknown')
				end
			) as BDMIdentifier
		,	convert(nvarchar(32), 
				case when charindex('@', u3.FederationIdentifier) > 1
					then substring(u3.FederationIdentifier, 1, charindex('@', u3.FederationIdentifier) - 1)
					else isnull(u3.FederationIdentifier, N'Unknown')
				end
			) as RMIdentifier
			,	convert(nvarchar(32), 
				case when charindex('@', u4.FederationIdentifier) > 1
					then substring(u4.FederationIdentifier, 1, charindex('@', u4.FederationIdentifier) - 1)
					else isnull(u4.FederationIdentifier, N'Unknown')
				end
			) as SMIdentifier
		,	convert(nvarchar(32), 
				case when charindex('@', u2.FederationIdentifier) > 1
					then substring(u2.FederationIdentifier, 1, charindex('@', u2.FederationIdentifier) - 1)
					else isnull(u2.FederationIdentifier, N'Unknown')
				end
			) as ASDIdentifier
	from #tmpDimGroupAccount tdga
	inner join DW.DimTerritoryHierarchy dth  
		on dth.SKTerritory = tdga.SKTerritory
	left join DW.DimUser u1  
		on u1.SKUser = dth.SKUserOwnerL1
	left join DW.DimUser u2  			  
		on u2.SKUser = dth.SKUserOwnerL2
	left join DW.DimUser u3 			  
		on u3.SKUser = dth.SKUserOwnerL3
	left join DW.DimUser u4 			  
		on u4.SKUser = dth.SKUserOwnerL4
	left join DW.DimUser u6  			  
		on u6.SKUser = dth.SKUserOwnerL6	
		
	
		
		
		
	update #TempDimGroupAccount set DWHash=
		convert(char(40),
			hashbytes('SHA1',
						  isnull(convert(nvarchar, AccountNumber), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SKDSOAccount), N'N/A')
				  + N'|' + isnull(convert(nvarchar, DSOAccountNumber), N'N/A')
				  + N'|' + isnull(convert(nvarchar, DSOAccountName), N'N/A')
				  + N'|' + isnull(convert(nvarchar, BDM), N'N/A')
				  + N'|' + isnull(convert(nvarchar, RM), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SM), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ASD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, BDMTerritoryName), N'N/A')
				  + N'|' + isnull(convert(nvarchar, RMTerritoryName), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SMTerritoryName), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ASDTerritoryName), N'N/A')
				  + N'|' + isnull(convert(nvarchar, BDMConcat), N'N/A')
				  + N'|' + isnull(convert(nvarchar, RMConcat), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SMConcat), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ASDConcat), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SKBDMUser), N'N/A')
				  + N'|' + isnull(convert(nvarchar, BDMUserId), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SKRMUser), N'N/A')
				  + N'|' + isnull(convert(nvarchar, RMUserId), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SKSMUser), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SMUserId), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SKASDUser), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ASDUserId), N'N/A')
				  + N'|' + isnull(convert(nvarchar, BDMIdentifier), N'N/A')
				  + N'|' + isnull(convert(nvarchar, RMIdentifier), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SMIdentifier), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ASDIdentifier), N'N/A')
				)
			, 2)

	if not exists (select * from DW.DimGroupAccount where SKAccount = -1)
	begin
		declare @Hash char(40) = ''

		insert into DW.DimGroupAccount (
				SKAccount
			,	AccountNumber
			,	DWBatchID
			,	DWHash
			,	SKDSOAccount
			,	DSOAccountNumber
			,	DSOAccountName
			,	BDM
			,	RM
			,	SM
			,	ASD
			,	BDMTerritoryName
			,	RMTerritoryName
			,	SMTerritoryName
			,	ASDTerritoryName
			,	BDMConcat
			,	RMConcat
			,	SMConcat
			,	ASDConcat
			,	SKBDMUser
			,	BDMUserId
			,	SKRMUser
			,	RMUserId
			,	SKSMUser
			,	SMUserId
			,	SKASDUser
			,	ASDUserId
			,	BDMIdentifier
			,	RMIdentifier
			,	SMIdentifier
			,	ASDIdentifier
			,	CreatedDate
			,	ModifiedDate
		)
		values (
				-1
			,	N'N/A'
			,	@BatchID
			,	@Hash
			,	-1
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	-1
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	'19000101'
			,	'19000101'
		)
	end

	update DW.DimGroupAccount
		set	DWBatchID 				= 			@BatchID
		,	DWHash					= 			src.DWHash
		,	AccountNumber			=			src.AccountNumber
		,	SKDSOAccount			=			src.SKDSOAccount
		,	DSOAccountNumber		=			src.DSOAccountNumber
		,	BDM						=			src.BDM
		,	RM						=			src.RM
		,	SM						=			src.SM
		,	ASD						=			src.ASD
		,	BDMTerritoryName		=			src.BDMTerritoryName
		,	RMTerritoryName			=			src.RMTerritoryName
		,	SMTerritoryName			=			src.SMTerritoryName
		,	ASDTerritoryName		=			src.ASDTerritoryName
		,	BDMConcat				=			src.BDMConcat
		,	RMConcat				=			src.RMConcat
		,	SMConcat				=			src.SMConcat
		,	ASDConcat				=			src.ASDConcat
		,	SKBDMUser				=			src.SKBDMUser
		,	BDMUserId				=			src.BDMUserId
		,	SKRMUser				=			src.SKRMUser
		,	RMUserId				=			src.RMUserId
		,	SKSMUser				=			src.SKSMUser
		,	SMUserId				=			src.SMUserId
		,	SKASDUser				=			src.SKASDUser
		,	ASDUserId				=			src.ASDUserId
		,	BDMIdentifier			=			src.BDMIdentifier
		,	RMIdentifier			=			src.RMIdentifier
		,	SMIdentifier			=			src.SMIdentifier
		,	ASDIdentifier			=			src.ASDIdentifier
		,	ModifiedDate 			= 			@CurrentDate
	from #TempDimGroupAccount src
	where DW.DimGroupAccount.SKAccount = src.SKAccount
		and DW.DimGroupAccount.DWHash != src.DWHash
	option (label = 'DW.LoadDimGroupAccount_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimGroupAccount_Update', @rc = @RowsUpdated out

	insert into DW.DimGroupAccount (
			SKAccount
		,	AccountNumber
		,	DWBatchID
		,	DWHash
		,	SKDSOAccount
		,	DSOAccountNumber
		,	DSOAccountName
		,	BDM
		,	RM
		,	SM
		,	ASD
		,	BDMTerritoryName
		,	RMTerritoryName
		,	SMTerritoryName
		,	ASDTerritoryName
		,	BDMConcat
		,	RMConcat
		,	SMConcat
		,	ASDConcat
		,	SKBDMUser
		,	BDMUserId
		,	SKRMUser
		,	RMUserId
		,	SKSMUser
		,	SMUserId
		,	SKASDUser
		,	ASDUserId
		,	BDMIdentifier
		,	RMIdentifier
		,	SMIdentifier
		,	ASDIdentifier
		,	CreatedDate
		,	ModifiedDate
	)
	select	src.SKAccount
		,	src.AccountNumber
		,	@BatchID
		,	src.DWHash
		,	src.SKDSOAccount
		,	src.DSOAccountNumber
		,	src.DSOAccountName
		,	src.BDM
		,	src.RM
		,	src.SM
		,	src.ASD
		,	src.BDMTerritoryName
		,	src.RMTerritoryName
		,	src.SMTerritoryName
		,	src.ASDTerritoryName
		,	src.BDMConcat
		,	src.RMConcat
		,	src.SMConcat
		,	src.ASDConcat
		,	src.SKBDMUser
		,	src.BDMUserId
		,	src.SKRMUser
		,	src.RMUserId
		,	src.SKSMUser
		,	src.SMUserId
		,	src.SKASDUser
		,	src.ASDUserId
		,	src.BDMIdentifier
		,	src.RMIdentifier
		,	src.SMIdentifier
		,	src.ASDIdentifier
		,	@CurrentDate
		,	@CurrentDate
	from #TempDimGroupAccount src
	where not exists(select * from DW.DimGroupAccount dst where dst.SKAccount = src.SKAccount)
	option (label = 'DW.LoadDimGroupAccount_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimGroupAccount_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end

