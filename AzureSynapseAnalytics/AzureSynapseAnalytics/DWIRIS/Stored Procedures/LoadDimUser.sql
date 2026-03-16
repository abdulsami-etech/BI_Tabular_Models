CREATE PROC [DWIRIS].[LoadDimUser] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimUser') is not null
		drop table #TempDimUser

-- Get delta rows
	create table #TempDimUser with (distribution = round_robin, heap) as 
	
			--  SFDC DATA
	select	
				a.ADLSBatchID						as ADLSBatchID
		  ,		a.ADLSTimestamp						as ADLSTimestamp
		  ,		a.LZBatchID							as LZBatchID
		  ,		convert(char(40), '')				as DWHash
		  ,		hub.SKUser							as SKUser
		  ,		a.[ID]								as KeyUser
		  ,		'SFDC'								as SourceSystem
		  ,		a.[UserName]						as UserName
		  ,		a.[UserType]						as UserType
		  ,		a.[FirstName]						as FirstName
		  ,		a.[LastName]						as LastName
		  ,		a.[Name]							as [Name]
		  ,		a.[Email]							as Email
		  ,		a.[Alias]							as Alias
		  ,		a.[Title]							as Title
		  ,		a.[EmployeeNumber]					as EmployeeNumber
		  ,		a.[CompanyName]						as CompanyName
		  ,		a.[Department]						as Department
		  ,		a.[Division]						as Division
		  ,		a.[Hire_Date__c]					as EmpHireDate
		  ,		a.[City]							as City
		  ,		a.[Country]							as Country
		  ,		a.[Region__c]						as Region
		  ,		a.[State]							as [State]
		  ,		a.[PostalCode]						as PostalCode
		  ,		a.[Street]							as [Address]
		  ,		a.[Phone]							as Phone
		  ,		a.[CreatedDate]						as CreatedDate
		  ,		a.[AccountId]						as AccountId
		  ,		NULL								as [MAT_ID]
		  ,		a.[Is_iTero_Rep__c]					as IsiTeroRep
		  ,		a.[ManagerId]						as ManagerId
		  ,		a.[Role_On_Territory__c]			as RoleOnTerritory
		  ,		a.[IsActive]						as IsActive

	from [SrcSFDC].[User] a
		inner join DWIRIS.HubUser hub on hub.KeyUser=a.ID
	where a.ID is not null
		and a.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimUser where SourceSystem='SFDC')
	UNION ALL

	select	
				g.ADLSBatchID						as ADLSBatchID
		  ,		g.ADLSTimestamp						as ADLSTimestamp
		  ,		g.LZBatchID							as LZBatchID
		  ,		convert(char(40), '')				as DWHash
		  ,		hub.SKUser							as SKUser
		  ,		g.[ID]								as KeyUser
		  ,		'SFDC'								as SourceSystem
		  ,		g.[Name]							as UserName
		  ,		g.[Type]							as UserType
		  ,		isnull(g.[Name],'')					as FirstName
		  ,		isnull(g.[Name],'')					as LastName
		  ,		isnull(g.[Name],'')					as [Name]
		  ,		isnull(g.[Email],'')				as Email
		  ,		NULL								as Alias
		  ,		NULL								as Title
		  ,		NULL								as EmployeeNumber
		  ,		NULL								as CompanyName
		  ,		NULL								as Department
		  ,		NULL								as Division
		  ,		NULL								as EmpHireDate
		  ,		NULL								as City
		  ,		NULL								as Country
		  ,		NULL								as Region
		  ,		NULL								as [State]
		  ,		NULL								as PostalCode
		  ,		NULL								as [Address]
		  ,		NULL								as Phone
		  ,		g.[CreatedDate]						as CreatedDate
		  ,		NULL								as AccountId
		  ,		NULL								as [MAT_ID]
		  ,		NULL								as IsiTeroRep
		  ,		NULL								as ManagerId
		  ,		NULL								as RoleOnTerritory
		  ,		1									as IsActive

	from [SrcSFDC].[Group] g
		inner join DWIRIS.HubUser hub on hub.KeyUser=g.[Id]
	where g.ID is not null
		and g.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimUser where SourceSystem='SFDC')

		UNION ALL

		--  MAT DATA
	select	
				a.ADLSBatchID						as ADLSBatchID
		  ,		a.ADLSTimestamp						as ADLSTimestamp
		  ,		a.LZBatchID							as LZBatchID
		  ,		convert(char(40), '')				as DWHash
		
		  ,		hub.SKUser							as SKUser
		  ,		convert(nchar(18),a.[ContactID])	as KeyUser

		  ,		'MAT'								as SourceSystem
		  ,		NULL								as UserName
		  ,		ctt.[ContactTypeGenericDescription]	as UserType
		  ,		a.[FirstName]						as FirstName
		  ,		a.[LastName]						as LastName
		  ,		ISNULL(a.[FirstName]+a.[LastName],'N/A')			as [Name]
		  ,		'N/A'								as Email
		  ,		NULL								as Alias
		  ,		NULL								as Title
		  ,		NULL								as EmployeeNumber
		  ,		NULL								as CompanyName
		  ,		NULL								as Department
		  ,		NULL								as Division
		  ,		NULL								as EmpHireDate
		  ,		adr.[TownName]						as [City]
		  ,		adr.[CountryName]					as [Country]
		  ,		NULL								as Region
		  ,		NULL								as [State]
		  ,		adr.[PostalCode]					as PostalCode
		  ,		adr.[Address]						as [Address]
		  ,		p.Phone								as Phone
		  ,		ISNULL(a.[DateCreated],'1900-01-01') as CreatedDate
		  ,		NULL								as AccountId
		  ,		a.[ContactID]						as [MAT_ID]
		  ,		NULL								as IsiTeroRep
		  ,		NULL								as ManagerId
		  ,		NULL								as RoleOnTerritory
		  ,		ISNULL(a.[RowStatusID],'N/A')		as IsActive

	from [SrcMAT].[Contact] a
		inner join DWIRIS.HubUser hub on hub.KeyUser=convert(nchar(18),a.ContactID)
		left join (
					  select 
						ContactID,
						[Address],
						TownName,
						CountryName,
						PostalCode from (
					  select 
						c.ContactID, 
						isnull(a.AddressLine1,'') + ' ' + isnull(a.AddressLine2,'') + ' ' +isnull(a.AddressLine3,'') as [Address],
						a.TownName,
						a.CountyName as CountryName,
						a.PostalCode,
					ROW_NUMBER() OVER (PARTITION BY c.ContactID, c.AddressTypeID ORDER BY c.DateUpdated DESC) as num 
					  from [SrcMAT].Contact_AddressTypeLink c 
					  join [SrcMAT].[Address] a
						on a.AddressID = c.AddressID
					  where c.RowStatusID <> 5 and c.AddressTypeID = 4) ad -- c.AddressTypeID = 4 - adress BillTo (if need to change - check AdressType table in MAT)
					  where ad.num = 1) adr
			on adr.ContactID = a.[ContactID]
		left join (
					  select 
							ContactID,
							[Phone] from (
						  select 
							c.ContactID, 
							p.PhoneNumber as [Phone],
							ROW_NUMBER() OVER (PARTITION BY c.ContactID, c.PhoneTypeID ORDER BY c.DateUpdated DESC) as num 
						  from [SrcMAT].Contact_PhoneTypeLink c 
						  join [SrcMAT].[Phone] p
							on p.PhoneID = c.PhoneID
						  where c.RowStatusID <> 5 and c.PhoneTypeID = 2) phn
						  where phn.num = 1)
				p
		on p.ContactID = a.[ContactID]
		left join (
				    select 
						ContactID,
						ContactTypeGenericDescription
					from (
						  select 
							c.ContactID,
							ct.ContactTypeGenericDescription,
							ROW_NUMBER() OVER (PARTITION BY c.ContactID ORDER BY c.DateUpdated DESC, c.ContactTypeLinkID DESC) as num 
						from [SrcMAT].Contact_ContactTypeLink c
						 join [SrcMAT].[ContactType] ct
							on c.ContactTypeID = ct.ContactTypeID 
						 ) t
				   where t.num =1
				) ctt
			on ctt.ContactID = a.[ContactID]
	where a.ContactID is not null
		and a.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimUser where SourceSystem='MAT')



	--update HASH  (HASH DOES NOT INCLUDE BUSINESS KEY AND ETL FIELDS!!! )
	update #TempDimUser set DWHash=
		convert(char(40),
			hashbytes('SHA1',
					   convert(nvarchar,ISNULL(SourceSystem,''))
				  +'|'+convert(nvarchar,ISNULL(UserName,''))
				  +'|'+convert(nvarchar,ISNULL(UserType,''))
				  +'|'+convert(nvarchar,ISNULL(FirstName,''))
				  +'|'+convert(nvarchar,ISNULL(LastName,''))
				  +'|'+convert(nvarchar,ISNULL([Name],''))
				  +'|'+convert(nvarchar,ISNULL(Email,''))
				  +'|'+convert(nvarchar,ISNULL(Alias,''))
				  +'|'+convert(nvarchar,ISNULL(Title,''))
				  +'|'+convert(nvarchar,ISNULL(EmployeeNumber,''))
				  +'|'+convert(nvarchar,ISNULL(CompanyName,''))
				  +'|'+convert(nvarchar,ISNULL(Department,''))
				  +'|'+convert(nvarchar,ISNULL(Division,''))
				  +'|'+convert(nvarchar,ISNULL(EmpHireDate,''))
				  +'|'+convert(nvarchar,ISNULL(City,''))
				  +'|'+convert(nvarchar,ISNULL(Country,''))
				  +'|'+convert(nvarchar,ISNULL(Region,''))
				  +'|'+convert(nvarchar,ISNULL([State],''))
				  +'|'+convert(nvarchar,ISNULL(PostalCode,''))
				  +'|'+convert(nvarchar,ISNULL([Address],''))
				  +'|'+convert(nvarchar,ISNULL(Phone,''))
				  +'|'+convert(nvarchar,ISNULL(CreatedDate,''))
				  +'|'+convert(nvarchar,ISNULL(AccountId,''))
				  +'|'+convert(nvarchar,ISNULL([MAT_ID],''))
				  +'|'+convert(nvarchar,ISNULL(IsiTeroRep,''))
				  +'|'+convert(nvarchar,ISNULL(ManagerId,''))
				  +'|'+convert(nvarchar,ISNULL(RoleOnTerritory,''))
				  +'|'+convert(nvarchar,ISNULL(IsActive,''))

				)
			,2)


	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimUser] where SKUser = -1)
	begin
		declare @Hash char(40) = ''

		begin try
			insert into DWIRIS.Dimuser (
				   [SKUser]
				  ,[ADLSBatchID]
				  ,[ADLSTimestamp]
				  ,[LZBatchID]
				  ,[DWBatchID]
				  ,[DWHash]
				  ,[KeyUser]

				  ,[SourceSystem]
				  ,[UserName]
				  ,[UserType]
				  ,[FirstName]
				  ,[LastName]
				  ,[Name]
				  ,[Email]
				  ,[Alias]
				  ,[Title]
				  ,[EmployeeNumber]
				  ,[CompanyName]
				  ,[Department]
				  ,[Division]
				  ,[EmpHireDate]
				  ,[City]
				  ,[Country]
				  ,[Region]
				  ,[State]
				  ,[PostalCode]
				  ,[Address]
				  ,[Phone]
				  ,[CreatedDate]
				  ,[AccountId]
				  ,[MAT_ID]
				  ,[IsiTeroRep]
				  ,[ManagerId]
				  ,[RoleOnTerritory]
				  ,[IsActive]
			)
			values (
					-1
				,	-1
				,	'19000101'
				,	-1
				,	@BatchID
				,	@Hash
				,	'N/A'
				
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'19000101'
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'19000101'
				,	'N/A'
				,	NULL
				,	'N/A'
				,	'N/A'
				,	'N/A'
				,	'N/A'
			)
		end try
		begin catch
			throw
		end catch
	end
	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimUser]
		set
			 ADLSBatchID = src.ADLSBatchID
			,ADLSTimestamp = src.ADLSTimestamp
			,LZBatchID = src.LZBatchID
			,DWBatchID = @BatchID
			,DWHash = src.DWHash

			,[SourceSystem]				=			src.[SourceSystem]
			,[UserName]					=			src.[UserName]
			,[UserType]					=			src.[UserType]
			,[FirstName]				=			src.[FirstName]
			,[LastName]					=			src.[LastName]
			,[Name]						=			src.[Name]
			,[Email]					=			src.[Email]
			,[Alias]					=			src.[Alias]
			,[Title]					=			src.[Title]
			,[EmployeeNumber]			=			src.[EmployeeNumber]
			,[CompanyName]				=			src.[CompanyName]
			,[Department]				=			src.[Department]
			,[Division]					=			src.[Division]
			,[EmpHireDate]				=			src.[EmpHireDate]
			,[City]						=			src.[City]
			,[Country]					=			src.[Country]
			,[Region]					=			src.[Region]
			,[State]					=			src.[State]
			,[PostalCode]				=			src.[PostalCode]
			,[Address]					=			src.[Address]
			,[Phone]					=			src.[Phone]
			,[CreatedDate]				=			src.[CreatedDate]
			,[AccountId]				=			src.[AccountId]
			,[MAT_ID]					=			src.[MAT_ID]
			,[IsiTeroRep]				=			src.[IsiTeroRep]
			,[ManagerId]				=			src.[ManagerId]
			,[RoleOnTerritory]			=			src.[RoleOnTerritory]
			,[IsActive]					=			src.[IsActive]
			
	from #TempDimUser src
	where [DWIRIS].[DimUser].SKUser=src.SKUser
		and [DWIRIS].[DimUser].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimUser_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimUser_Update', @rc = @RowsUpdated out




	--INSERT new rows
	insert into [DWIRIS].[DimUser] (
		   [SKUser]
		  ,[ADLSBatchID]
		  ,[ADLSTimestamp]
		  ,[LZBatchID]
		  ,[DWBatchID]
		  ,[DWHash]
		  ,[KeyUser]
		  ,[SourceSystem]
		  ,[UserName]
		  ,[UserType]
		  ,[FirstName]
		  ,[LastName]
		  ,[Name]
		  ,[Email]
		  ,[Alias]
		  ,[Title]
		  ,[EmployeeNumber]
		  ,[CompanyName]
		  ,[Department]
		  ,[Division]
		  ,[EmpHireDate]
		  ,[City]
		  ,[Country]
		  ,[Region]
		  ,[State]
		  ,[PostalCode]
		  ,[Address]
		  ,[Phone]
		  ,[CreatedDate]
		  ,[AccountId]
		  ,[MAT_ID]
		  ,[IsiTeroRep]
		  ,[ManagerId]
		  ,[RoleOnTerritory]
		  ,[IsActive]		   
		   )
	select 
		   [SKUser]
		  ,[ADLSBatchID]
		  ,[ADLSTimestamp]
		  ,[LZBatchID]
		  ,@BatchID
		  ,[DWHash]
		  ,[KeyUser]
		  ,[SourceSystem]
		  ,[UserName]
		  ,[UserType]
		  ,[FirstName]
		  ,[LastName]
		  ,[Name]
		  ,[Email]
		  ,[Alias]
		  ,[Title]
		  ,[EmployeeNumber]
		  ,[CompanyName]
		  ,[Department]
		  ,[Division]
		  ,[EmpHireDate]
		  ,[City]
		  ,[Country]
		  ,[Region]
		  ,[State]
		  ,[PostalCode]
		  ,[Address]
		  ,[Phone]
		  ,[CreatedDate]
		  ,[AccountId]
		  ,[MAT_ID]
		  ,[IsiTeroRep]
		  ,[ManagerId]
		  ,[RoleOnTerritory]
		  ,[IsActive]
	from #TempDimUser src
	where not exists(select dst.SKUser from DWIRIS.DimUser dst where dst.SKUser = src.SKUser)
	option (label = 'DWIRIS.LoadDimUser_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimUser_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end --procedure

