CREATE PROC [DW].[LoadDimUser] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimUser') is not null
		drop table #TempDimUser

	create table #TempDimUser with (distribution = round_robin, heap) as 
	select	hub.SKUser
		,	u.ADLSBatchID
		,	u.ADLSTimestamp
		,	u.LZBatchID
		,	convert(char(40), '') as DWHash
		,	u.KeyUser
		,	u.SourceSystemCode
		,	u.UserName
		,	u.FirstName
		,	u.LastName
		,	u.Alias
		,	u.AlignSalesRepID
		,	u.UserRoleName
		,	u.FederationIdentifier
		,	u.CreatedDate
		,	u.IsActive
		,	u.ManagerID
		,	u.EmpHireDate
		,	u.Address
		,	u.City
		,	u.State
		,	u.Country
		,	u.PostalCode
		,	u.Phone
	from (
		select	u.ADLSBatchID									as ADLSBatchID
			,	u.ADLSTimestamp									as ADLSTimestamp
			,	u.LZBatchID										as LZBatchID
			,	u.Id											as KeyUser
			,	'SFDC'											as SourceSystemCode
			,	u.Name											as UserName
			,	convert(nvarchar(40), u.FirstName)				as FirstName
			,	convert(nvarchar(80), u.LastName)				as LastName
			,	u.Alias											as Alias
			,	u.AlignSalesRepID__c							as AlignSalesRepID
			,	ur.Name											as UserRoleName
			,	convert(nvarchar(64), u.FederationIdentifier)	as FederationIdentifier
			,	convert(date, u.CreatedDate)					as CreatedDate
			,	u.IsActive										as IsActive
			,	convert(nvarchar(18), u.ManagerID)				as ManagerID
			,	convert(date, u.Hire_Date__c)					as EmpHireDate
			,	u.Street										as [Address]
			,	u.City											as City
			,	u.[State]										as [State]
			,	u.Country										as Country
			,	u.PostalCode									as PostalCode
			,	convert(nvarchar(40), u.Phone)					as Phone
		from SrcSFDC.[User] u
		left join SrcSFDC.UserRole ur on ur.Id = u.UserRoleId

		union all

		select	u.ADLSBatchID									as ADLSBatchID
			,	u.ADLSTimestamp									as ADLSTimestamp
			,	u.LZBatchID										as LZBatchID
			,	convert(nvarchar(18),u.ContactID)				as KeyUser
			,	'MAT'											as SourceSystemCode
			,	convert(nvarchar(40), u.FirstName) + ' ' + convert(nvarchar(80), u.LastName) as UserName
			,	convert(nvarchar(40), u.FirstName)				as FirstName
			,	convert(nvarchar(80), u.LastName)				as LastName
			,	null											as Alias
			,	null											as AlignSalesRepID
			,	null											as UserRoleName
			,	null											as FederationIdentifier
			,	convert(date, u.DateCreated)					as CreatedDate
			,	case when u.RowStatusID = 1 then 1 else 0 end	as IsActive
			,	null											as ManagerID
			,	null											as EmpHireDate
			,	ad.Address										as Address
			,	ad.City											as City
			,	ad.State										as State
			,	ad.Country										as Country
			,	ad.PostalCode									as PostalCode
			,	convert(nvarchar(40), p.Phone)					as Phone
		from SrcMAT.Contact u
		left join (
			select top (1) with ties
					c.ContactID
				,	isnull(a.AddressLine1, '') + ' ' + isnull(a.AddressLine2, '') + ' ' + isnull(a.AddressLine3, '') as [Address]
				,	a.TownName as City
				,	StateNameEN as State
				,	co.CountryName as Country
				,	a.PostalCode
			from SrcMAT.Contact_AddressTypeLink c 
			inner join SrcMAT.[Address] a on a.AddressID = c.AddressID
			left join SrcMAT.lcl_Country co on co.CountryID = a.CountryID
			left join SrcMAT.CountryState s on s.CountryStateID = a.CountryStateID
			where c.RowStatusID <> 5 
				and c.AddressTypeID = 4
			order by row_number() over (partition by c.ContactID order by c.DateUpdated desc, c.IsPrimary desc, c.ContactAddressTypeID desc)
		) ad on ad.ContactID = u.ContactID
		left join (
			select top (1) with ties
					c.ContactID
				,	p.PhoneNumber as Phone
			from SrcMAT.Contact_PhoneTypeLink c 
			inner join SrcMAT.Phone p on p.PhoneID = c.PhoneID
			where c.RowStatusID <> 5 
				and c.PhoneTypeID = 2
			order by row_number() over (partition by c.ContactID order by c.DateUpdated desc)
		) p on p.ContactID = u.ContactID
	) u
	inner join DW.HubUser hub on hub.KeyUser = u.KeyUser
	--where u.ADLSTimestamp >= @LastSuccessfullDWTimestamp--(select isnull(max(ADLSTimestamp), '19000101') from DW.DimUser)

	update #TempDimUser set DWHash=
		convert(char(40),
			hashbytes('SHA1',
						 isnull(convert(nvarchar, SourceSystemCode), N'N/A')
				+ N'|' + isnull(convert(nvarchar, UserName), N'N/A')
				+ N'|' + isnull(convert(nvarchar, FirstName), N'N/A')
				+ N'|' + isnull(convert(nvarchar, LastName), N'N/A')
				+ N'|' + isnull(convert(nvarchar, Alias), N'N/A')
				+ N'|' + isnull(convert(nvarchar, AlignSalesRepID), N'N/A')
				+ N'|' + isnull(convert(nvarchar, UserRoleName), N'N/A')
				+ N'|' + isnull(convert(nvarchar, FederationIdentifier), N'N/A')
				+ N'|' + isnull(convert(nvarchar, CreatedDate), N'N/A')
				+ N'|' + isnull(convert(nvarchar, IsActive), N'N/A')
				+ N'|' + isnull(convert(nvarchar, ManagerID), N'N/A')
				+ N'|' + isnull(convert(nvarchar, EmpHireDate), N'N/A')
				+ N'|' + isnull(convert(nvarchar, Address), N'N/A')
				+ N'|' + isnull(convert(nvarchar, City), N'N/A')
				+ N'|' + isnull(convert(nvarchar, State), N'N/A')
				+ N'|' + isnull(convert(nvarchar, Country), N'N/A')
				+ N'|' + isnull(convert(nvarchar, PostalCode), N'N/A')
				+ N'|' + isnull(convert(nvarchar, Phone), N'N/A')
				)
			, 2)

	if not exists (select * from DW.DimUser where SKUser = -1)
	begin
		declare @Hash char(40) = ''
			,	@CurrentDate datetime2(7) = getdate()

		insert into DW.DimUser (
				SKUser
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyUser
			,	SourceSystemCode
			,	UserName
			,	FirstName
			,	LastName
			,	Alias
			,	AlignSalesRepID
			,	UserRoleName
			,	FederationIdentifier
			,	CreatedDate
			,	IsActive
			,	ManagerID
			,	EmpHireDate
			,	Address
			,	City
			,	State
			,	Country
			,	PostalCode
			,	Phone
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
			,	N'N/A'
			,	N'N/A'
			,	null
			,	null
			,	null
			,	null
			,	@CurrentDate
			,	1
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
		)
	end

	update DW.DimUser
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchID
		,	DWHash = src.DWHash
		,	SourceSystemCode = src.SourceSystemCode
		,	UserName = src.UserName
		,	FirstName = src.FirstName
		,	LastName = src.LastName
		,	Alias = src.Alias
		,	AlignSalesRepID = src.AlignSalesRepID
		,	UserRoleName = src.UserRoleName
		,	FederationIdentifier = src.FederationIdentifier
		,	CreatedDate = src.CreatedDate
		,	IsActive = src.IsActive
		,	ManagerID = src.ManagerID
		,	EmpHireDate = src.EmpHireDate
		,	Address = src.Address
		,	City = src.City
		,	State = src.State
		,	Country = src.Country
		,	PostalCode = src.PostalCode
		,	Phone = src.Phone
	from #TempDimUser src
	where DW.DimUser.SKUser = src.SKUser
		and DW.DimUser.DWHash != src.DWHash
	option (label = 'DW.LoadDimUser_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimUser_Update', @rc = @RowsUpdated out

	insert into DW.DimUser (
			SKUser
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyUser
		,	SourceSystemCode
		,	UserName
		,	FirstName
		,	LastName
		,	Alias
		,	AlignSalesRepID
		,	UserRoleName
		,	FederationIdentifier
		,	CreatedDate
		,	IsActive
		,	ManagerID
		,	EmpHireDate
		,	Address
		,	City
		,	State
		,	Country
		,	PostalCode
		,	Phone
	)
	select	src.SKUser
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyUser
		,	src.SourceSystemCode
		,	src.UserName
		,	src.FirstName
		,	src.LastName
		,	src.Alias
		,	src.AlignSalesRepID
		,	src.UserRoleName
		,	src.FederationIdentifier
		,	src.CreatedDate
		,	src.IsActive
		,	src.ManagerID
		,	src.EmpHireDate
		,	src.Address
		,	src.City
		,	src.State
		,	src.Country
		,	src.PostalCode
		,	src.Phone
	from #TempDimUser src
	where not exists (select * from DW.DimUser dst where dst.SKUser = src.SKUser)
	option (label = 'DW.LoadDimUser_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimUser_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
