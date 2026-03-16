CREATE PROC [DWTOPS].[LoadDimUser] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimUser') is not null
		drop table #TempDimUser

	create table #TempDimUser with (distribution = round_robin, heap) as 
	select top (1) with ties	
			h.SKUser								as SKUser
		,	t.ADLSBatchID							as ADLSBatchID
		,	t.ADLSTimestamp							as ADLSTimestamp
		,	t.LZBatchID								as LZBatchID
		,	convert(char(40), '')					as DWHash
		,	convert(varchar(64), t.user_name)		as KeyUser
		,	t.user_key								as UserKey
		,	convert(varchar(64), t.first_name)		as FirstName
		,	convert(varchar(64), t.last_name)		as LastName
		,	convert(varchar(128),
				case when t.first_name is null
						and t.last_name is null 
					then null
					else isnull(t.first_name, '') + isnull(t.last_name, '') 
				end
			)										as FullName
		,	convert(varchar(255), t.description)	as UserDescription
		,	convert(varchar(50), t.category)		as UserCategory
		,	convert(varchar(80), tn.schedulename_s) as UserShift
	from SrcMESCorp.APP_USER t
	inner join DWTOPS.HubUser h on h.KeyUser = convert(varchar(64), t.user_name)
	left join (
		select top (1) with ties
				tp.atr_name
			,	ts.schedulename_s
		from SrcMESCorp.At_at_TechProfile tp   
		inner join SrcMESCorp.at_at_techschedule ts on ts.TechID_I = tp.Techid_i   
		where tp.profilename_s = 'primary' 
		order by row_number() over (partition by tp.atr_name order by ts.last_modified_time desc)
	) as tn on t.user_name = tn.atr_name   
	where t.Status = 'Normal'
	order by row_number() over (partition by convert(varchar(64), t.user_name) order by t.last_modified_time desc)

	update #TempDimUser
		set	DWHash = convert(char(40),
						hashbytes('SHA1', 
									convert(varchar, UserKey) 
							+ '|' + isnull(FirstName, 'N/A') 
							+ '|' + isnull(LastName, 'N/A') 
							+ '|' + isnull(FullName, 'N/A') 
							+ '|' + isnull(UserDescription, 'N/A') 
							+ '|' + isnull(UserCategory, 'N/A') 
							+ '|' + isnull(UserShift, 'N/A') 
						)
						, 2
					)

	if not exists (select * from DWTOPS.DimUser where SKUser = -1)
	begin
		declare @Hash char(40) = convert(char(40), hashbytes('SHA1', 'N/A'), 2)

		insert into DWTOPS.DimUser (
				SKUser
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyUser
			,	UserKey
			,	FirstName
			,	LastName
			,	FullName
			,	UserDescription
			,	UserCategory
			,	UserShift
		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,	'N/A'
			,	-1
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
		)
	end

	update DWTOPS.DimUser
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchId
		,	DWHash = src.DWHash
		,	UserKey = src.UserKey
		,	FirstName = src.FirstName
		,	LastName = src.LastName
		,	FullName = src.FullName
		,	UserDescription = src.UserDescription
		,	UserCategory = src.UserCategory
		,	UserShift = src.UserShift
	from #TempDimUser src
	where DWTOPS.DimUser.SKUser = src.SKUser
		and DWTOPS.DimUser.DWHash != src.DWHash
	option (label = 'DWTOPS.LoadDimUser_Update');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimUser_Update', @rc = @RowsUpdated out

	insert into DWTOPS.DimUser (
			SKUser
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyUser
		,	UserKey
		,	FirstName
		,	LastName
		,	FullName
		,	UserDescription
		,	UserCategory
		,	UserShift
	)
	select	src.SKUser
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyUser
		,	src.UserKey
		,	src.FirstName
		,	src.LastName
		,	src.FullName
		,	src.UserDescription
		,	src.UserCategory
		,	src.UserShift
	from #TempDimUser src
	where not exists(select * from DWTOPS.DimUser dst where dst.SKUser = src.SKUser)
	option (label = 'DWTOPS.LoadDimUser_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimUser_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end
