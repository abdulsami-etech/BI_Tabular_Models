CREATE PROC [DWIRIS].[LoadDimTask] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimTask') is not null
		drop table #TempDimTask

-- Get delta rows
	create table #TempDimTask with (distribution = round_robin, heap) as 
	select				
					 ht.SKTask														as SKTask
					,t.ADLSBatchID													as ADLSBatchID
					,t.ADLSTimestamp												as ADLSTimestamp
					,t.LZBatchID													as LZBatchID
					,convert(char(40), '')											as DWHash
					,t.Id 															as KeyTask
					,hu.SKUser 														as SKUser
					,ha.SKAccount													as SKAccount
					,t.[CreatedDate] 												as CreatedDate
					,t.[WhatId] 													as WhatId
					,t.[Primary_Focus__c] 											as PrimaryFocus
					,t.[Subject] 													as [Subject]
					,t.[Status] 													as [Status]
					,t.[Call_Counter__c] 											as CallCounter
					,rt.[Name] 														as RecordTypeName
					,t.[IsDeleted] 													as IsDeleted
				from [SrcSFDC].[Task] t
				inner join DWIRIS.HubTask ht
					on ht.KeyTask = t.ID
				left join DWIRIS.HubUser hu
					on hu.KeyUser = t.OwnerId
				left join DW.HubAccount ha
					on ha.KeyAccount = t.AccountID
				left join [SrcSFDC].[RecordType] rt
					on rt.Id = t.RecordTypeId
				where t.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimTask)
		
		
	--update HASH
	update #TempDimTask set DWHash=
		convert(char(40),
			hashbytes('SHA1',
				         ISNULL(convert(nvarchar,KeyTask),'')
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
	if not exists (select * from [DWIRIS].[DimTask] where SKTask = -1)
	begin
		declare @Hash char(40) = ''

		insert into DWIRIS.DimTask (
				[SKTask],		
				[ADLSBatchID],
				[ADLSTimestamp],
				[LZBatchID],
				[DWBatchID],
				[DWHash],
				[KeyTask],
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
				-1					-- SKTask
			,	-1					-- ADLSBatchID
			,	'19000101'			-- ADLSTimestamp
			,	-1					-- LZBatchID
			,	@BatchID			-- DWBatchID
			,	@Hash				-- DWHash
			,   'N/A'				--[KeyTask]
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
	update [DWIRIS].[DimTask]
		set
		   ADLSBatchID										=	src.ADLSBatchID
		  ,ADLSTimestamp									=	src.ADLSTimestamp
		  ,LZBatchID										=	src.LZBatchID
		  ,DWBatchID										=	@BatchID
		  ,DWHash											=	src.DWHash
 		  ,[KeyTask]										=	src.[KeyTask]
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
		  
	from #TempDimTask src
	where [DWIRIS].[DimTask].SKTask	=	src.SKTask
		and [DWIRIS].[DimTask].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimTask_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimTask_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[DimTask] (
				[SKTask],		
				[ADLSBatchID],
				[ADLSTimestamp],
				[LZBatchID],
				[DWBatchID],
				[DWHash],
				[KeyTask],
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
				[SKTask],		
				[ADLSBatchID],
				[ADLSTimestamp],
				[LZBatchID],
				@BatchID,
				[DWHash],
				[KeyTask],
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
	from #TempDimTask src
	where not exists(select dst.SKTask from DWIRIS.DimTask dst where dst.SKTask = src.SKTask)
	option (label = 'DWIRIS.LoadDimTask_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimTask_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
	
end --procedure