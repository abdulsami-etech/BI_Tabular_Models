CREATE PROC [DW].[LoadDimSharedContact] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0), @IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@CurrentDate	datetime2(0) = getdate()
		
	
	if object_id('tempdb..#TempDimSharedContact') is not null
	drop table #TempDimSharedContact

	create table #TempDimSharedContact with (distribution = round_robin, heap) as 
	
	select top (1) with ties
			ha.SKAccount
		, 	sc.Account__C as KeyAccount
		,	convert(char(40), '') as DWHash
		, 	sc.Account_Number__C as AccountNumber
		, 	sc.Contact__C as KeyContact
		, 	hc.SKContact
		,	sc.LastModifiedDate
		, 	a.SecRegion
	from srcSfdc.Shared_Contact__C sc
	inner join dw.hubAccount ha on sc.Account__C = ha.KeyAccount
	inner join dw.hubContact hc on sc.Contact__C = hc.KeyContact
	inner join dw.dimaccount a on ha.SKAccount = a.SKAccount
	inner join dw.dimContact c on hc.SKContact = c.SKContact
	where c.Status='Active' and c.ContactType='Doctor' and c.LineOfBusiness like '%Invisalign%'
	order by row_number() over(partition by ha.SKAccount, hc.SKContact order by sc.LastModifiedDate desc)
		
		
		
	update #TempDimSharedContact set DWHash=
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, KeyAccount), N'N/A')
				  + N'|' + isnull(convert(nvarchar, AccountNumber), N'N/A')
				  + N'|' + isnull(convert(nvarchar, KeyContact), N'N/A')
				  + N'|' + isnull(convert(nvarchar, LastModifiedDate), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SecRegion), N'N/A')
				 
				)
			, 2)

	if not exists (select * from DW.DimSharedContact where SKAccount = -1)
	begin
		declare @Hash char(40) = ''

		insert into DW.DimSharedContact (
				SKAccount
			,	KeyAccount
			,	DWBatchId
			,	DWHash
			,	AccountNumber
			,	KeyContact
			,	SKContact
			,	LastModifiedDate
			,	SecRegion
			,	CreatedDate
			,	ModifiedDate
		)
		values (
				-1
			,	N'N/A'
			,	@BatchID
			,	@Hash
			,	N'N/A'
			,	N'N/A'
			,	-1
			,	'19000101'
			,	N'N/A'
			,	'19000101'
			,	'19000101'
		)
	end

	update DW.DimSharedContact
		set	DWBatchID 				= 			@BatchID
		,	DWHash					= 			src.DWHash
		,	KeyAccount				=			src.KeyAccount
		,	AccountNumber			=			src.AccountNumber
		,	KeyContact				=			src.KeyContact
		,	LastModifiedDate		=			src.LastModifiedDate
		,	SecRegion				=			src.SecRegion
		,	ModifiedDate 			= 			@CurrentDate
	from #TempDimSharedContact src
	where DW.DimSharedContact.SKAccount = src.SKAccount and DW.DimSharedContact.SKContact = src.SKContact
		and DW.DimSharedContact.DWHash != src.DWHash
	option (label = 'DW.LoadDimSharedContact_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimSharedContact_Update', @rc = @RowsUpdated out

	insert into DW.DimSharedContact (
			SKAccount
		,	KeyAccount
		,	DWBatchId
		,	DWHash
		,	AccountNumber
		,	KeyContact
		,	SKContact
		,	LastModifiedDate
		,	SecRegion
		,	CreatedDate
		,	ModifiedDate
	)
	select	src.SKAccount
		,	src.KeyAccount
		,	@BatchID
		,	src.DWHash
		,	src.AccountNumber
		,	src.KeyContact
		,	src.SKContact
		,	src.LastModifiedDate
		,	src.SecRegion
		,	@CurrentDate
		,	@CurrentDate
	from #TempDimSharedContact src
	where not exists(select * from DW.DimSharedContact dst where dst.SKAccount = src.SKAccount and dst.SKContact = src.SKContact)
	option (label = 'DW.LoadDimSharedContact_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimSharedContact_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end

