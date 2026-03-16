CREATE PROC [DWIRIS].[LoadDimEvent] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimEvent') is not null
		drop table #TempDimEvent

-- Get delta rows
	create table #TempDimEvent with (distribution = round_robin, heap) as 
	select				
					 ht.SKEvent														as SKEvent
					,t.ADLSBatchID													as ADLSBatchID
					,t.ADLSTimestamp												as ADLSTimestamp
					,t.LZBatchID													as LZBatchID
					,convert(char(40), '')											as DWHash
					,t.Id 															as KeyEvent
					,hu.SKUser 														as SKUser
					,ha.SKAccount													as SKAccount
					,t.[CreatedDate] 												as CreatedDate
					,t.[WhatId] 													as WhatId
					,t.[Primary_Focus__c] 											as PrimaryFocus
					,t.[Subject] 													as [Subject]
					,t.[Status__c] 													as [Status]
					,t.[Call_Counter__c] 											as CallCounter
					,rt.[Name] 														as RecordTypeName
					,t.[IsDeleted] 													as IsDeleted
				from [SrcSFDC].[Event] t
				inner join DWIRIS.HubEvent ht
					on ht.KeyEvent = t.ID
				left join DWIRIS.HubUser hu
					on hu.KeyUser = t.OwnerId
				left join DW.HubAccount ha
					on ha.KeyAccount = t.AccountID
				left join [SrcSFDC].[RecordType] rt
					on rt.Id = t.RecordTypeId
				where t.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimEvent)
		
		
	--update HASH
	update #TempDimEvent set DWHash=
		convert(char(40),
			hashbytes('SHA1',
				         ISNULL(convert(nvarchar,KeyEvent),'')
					+'|'+ISNULL(convert(nvarchar,SKUser),'')
					+'|'+ISNULL(convert(nvarchar,SKAccount),'')
					+'|'+ISNULL(convert(nvarchar,CreatedDate),'')
					+'|'+ISNULL(convert(nvarchar,WhatId),'')
					+'|'+ISNULL(convert(nvarchar,PrimaryFocus),'')
					+'|'+ISNULL(convert(nvarchar,Subject),'')
					+'|'+ISNULL(convert(nvarchar,Status),'')
					+'|'+ISNULL(convert(nvarchar,CallCounter),'')
					+'|'+ISNULL(convert(nvarchar,RecordTypeName),'')
					+'|'+ISNULL(convert(nvarchar,IsDeleted),'')
				)
			,2)

	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimEvent] where SKEvent = -1)
	begin
		declare @Hash char(40) = ''

		insert into DWIRIS.DimEvent (
				[SKEvent],		
				[ADLSBatchID],
				[ADLSTimestamp],
				[LZBatchID],
				[DWBatchID],
				[DWHash],
				[KeyEvent],
				[CreatedDate],
				[WhatId],
				[PrimaryFocus],
				[Subject],
				[Status],
				[SKAccount],
				[SKUser],
				[CallCounter],
				[RecordTypeName],
				[IsDeleted]
		)
		values (
				-1					-- SKEvent
			,	-1					-- ADLSBatchID
			,	'19000101'			-- ADLSTimestamp
			,	-1					-- LZBatchID
			,	@BatchID			-- DWBatchID
			,	@Hash				-- DWHash
			,   'N/A'				--[KeyEvent]
			,	'19000101'			--[CreatedDate]
			,	'N/A'				--[WhatID]
			,	'N/A'				--[PrimaryFocus]
			,	'N/A'				--[Subject]
			,	'N/A'				--[Status]
			,	-1					-- SKAccount
			,	-1					-- SKUser
			,	-1					-- CallCounter
			,	'N/A'				--[RecordTypeName]
			,	'N/A'				--[IsDeleted]

	)
	end


	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimEvent]
		set
		   ADLSBatchID										=	src.ADLSBatchID
		  ,ADLSTimestamp									=	src.ADLSTimestamp
		  ,LZBatchID										=	src.LZBatchID
		  ,DWBatchID										=	@BatchID
		  ,DWHash											=	src.DWHash
 		  ,[KeyEvent]										=	src.[KeyEvent]
		  ,[CreatedDate]									=	src.[CreatedDate]
		  ,[WhatID]											=	src.[WhatID]
		  ,[PrimaryFocus]									=	src.[PrimaryFocus]
		  ,[Subject]										=	src.[Subject]
		  ,[Status]											=	src.[Status]
		  ,[SKAccount]										=	src.[SKAccount]
		  ,[SKUser]											=	src.[SKUser]
		  ,[CallCounter]									=	src.[CallCounter]
		  ,[RecordTypeName]									=	src.[RecordTypeName]
		  ,[IsDeleted]										=	src.[IsDeleted]
		  
	from #TempDimEvent src
	where [DWIRIS].[DimEvent].SKEvent	=	src.SKEvent
		and [DWIRIS].[DimEvent].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimEvent_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimEvent_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[DimEvent] (
				[SKEvent],		
				[ADLSBatchID],
				[ADLSTimestamp],
				[LZBatchID],
				[DWBatchID],
				[DWHash],
				[KeyEvent],
				[CreatedDate],
				[WhatId],
				[PrimaryFocus],
				[Subject],
				[Status],
				[SKAccount],
				[SKUser],
				[CallCounter],
				[RecordTypeName],
				[IsDeleted]
		   )
	select 
				[SKEvent],		
				[ADLSBatchID],
				[ADLSTimestamp],
				[LZBatchID],
				@BatchID,
				[DWHash],
				[KeyEvent],
				[CreatedDate],
				[WhatId],
				[PrimaryFocus],
				[Subject],
				[Status],
				[SKAccount],
				[SKUser],
				[CallCounter],
				[RecordTypeName],
				[IsDeleted]
	from #TempDimEvent src
	where not exists(select dst.SKEvent from DWIRIS.DimEvent dst where dst.SKEvent = src.SKEvent)
	option (label = 'DWIRIS.LoadDimEvent_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimEvent_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
	
end --procedure