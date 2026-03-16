CREATE PROC [DWIRIS].[LoadDimVctTraining] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimVctTraining') is not null
		drop table #TempDimVctTraining

-- Get delta rows
	create table #TempDimVctTraining with (distribution = round_robin, heap) as 
	select 
	
			hvc.SKVctTraining														as SKVctTraining
		,	c.ADLSBatchID															as ADLSBatchID
		,	c.ADLSTimestamp															as ADLSTimestamp
		,	c.LZBatchID																as LZBatchID
		,	convert(char(40), '')													as DWHash
		,	hvc.KeyVctTraining														as KeyVctTraining
		,	c.CaseNumber															as [TicketNumber]
		,	vct.Completed__c														as [IsCompleted]
		,	vct.CreatedDate															as [CreatedDate]
		,	vct.Id																	as [Id]
		,	vct.Invisalign__c														as [IsInvisalign]
		,	vct.IsDeleted															as [IsDeleted]
		,	vct.[Name]																as [Name]
		,	vct.[no_of_Participants__c]												as [NumberOfParticipants]
		,	rt.[Name]																as [RecordType]
		,	vct.Method_of_Training__c												as [MethodOfTraining]
		,	vct.Modules_Completed__c												as [ModulesCompleted]
		,	vct.Status__c															as [Status]
		,	vct.Total_Time__c														as [TotalTime]
		,	vct.Type__c																as [Type]
		,	vct.VCT_Training_Date__c												as [VCTTrainingDate]
		,	vct.Basic__c															as [IsBasic]
		,	vct.Ortho__c															as [IsOrtho]
		,	vct.Other_SW__c															as [IsOtherSW]
		,	vct.Restorative__c														as [IsRestorative]
		,	dac.AccountNumber														as [AccountNumber]
		,	isnull(con.Contact_ID__c,dcprim.ContactNumber)							as [ContactNumber]  
		,	dac.MATID																as [MATID]
		,	CASE 
				WHEN cpar.Ticket_Type__c = 'Laboratory'
				THEN 1
				else 0
			end																		as [Lab]
	from SrcSFDC.[Case] c
	join SrcSFDC.VCT_Training__C vct
		on vct.Case__c = c.Id
	join DWIRIS.HubVctTraining hvc
		on hvc.KeyVctTraining = vct.Id
	left join SrcSFDC.RecordType rt
		on rt.Id = vct.RecordTypeId
	left join DW.HubAccount hac
		on hac.KeyAccount = c.AccountID
	left join DW.DimAccount dac
		on hac.SKAccount = dac.SKAccount
	left join SrcSFDC.Contact con
		on con.Id = c.ContactId
	left join (select 
					ContactNumber,
					PrimaryAccountID
			  from (select 
						ContactNumber,
						PrimaryAccountID,  
						ROW_NUMBER() OVER(PARTITION BY PrimaryAccountID ORDER BY CreatedDate DESC) num
					from DW.DimContact
					where Status = 'Active'
					) res
			where num = 1
		) dcprim
		on dcprim.PrimaryAccountID = c.AccountID
	left join SrcSFDC.[Case] cpar
		on c.ParentId = cpar.Id
	where c.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimVctTraining)

--update HASH
	update #TempDimVctTraining set DWHash=
		convert(char(40),
			hashbytes('SHA1',
								
								 ISNULL(convert(nvarchar,[SKVctTraining]),'')
							+'|'+ISNULL(convert(nvarchar,[KeyVctTraining]),'')
							+'|'+ISNULL(convert(nvarchar,[TicketNumber]),'')
							+'|'+ISNULL(convert(nvarchar,[IsCompleted]),'')
							+'|'+ISNULL(convert(nvarchar,[CreatedDate]),'')
							+'|'+ISNULL(convert(nvarchar,[Id]),'')
							+'|'+ISNULL(convert(nvarchar,[IsInvisalign]),'')
							+'|'+ISNULL(convert(nvarchar,[IsDeleted]),'')
							+'|'+ISNULL(convert(nvarchar,[Name]),'')
							+'|'+ISNULL(convert(nvarchar,[NumberOfParticipants]),'')
							+'|'+ISNULL(convert(nvarchar,[RecordType]),'')
							+'|'+ISNULL(convert(nvarchar,[MethodOfTraining]),'')
							+'|'+ISNULL(convert(nvarchar,[ModulesCompleted]),'')
							+'|'+ISNULL(convert(nvarchar,[Status]),'')
							+'|'+ISNULL(convert(nvarchar,[TotalTime]),'')
							+'|'+ISNULL(convert(nvarchar,[Type]),'')
							+'|'+ISNULL(convert(nvarchar,[VCTTrainingDate]),'')
							+'|'+ISNULL(convert(nvarchar,[IsBasic]),'')
							+'|'+ISNULL(convert(nvarchar,[IsOrtho]),'')
							+'|'+ISNULL(convert(nvarchar,[IsOtherSW]),'')
							+'|'+ISNULL(convert(nvarchar,[IsRestorative]),'')
							+'|'+ISNULL(convert(nvarchar,[AccountNumber]),'')
							+'|'+ISNULL(convert(nvarchar,[ContactNumber]),'')
							+'|'+ISNULL(convert(nvarchar,[MATID]),'') 
							+'|'+ISNULL(convert(nvarchar,[Lab]),'') 
							

				)
			,2)


	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimVctTraining] where SKVctTraining = -1)
	begin
		declare @Hash char(40) = ''

		--set identity_insert DWIRIS.DimAsset on
		begin try
			insert into DWIRIS.DimVctTraining (
				    	[SKVctTraining]
					   ,[ADLSBatchID]
					   ,[ADLSTimestamp]
					   ,[LZBatchID]
					   ,[DWBatchID]
					   ,[DWHash]
					   ,[KeyVctTraining]
					   ,[TicketNumber]
					   ,[IsCompleted]
					   ,[CreatedDate]
					   ,[Id]
					   ,[IsInvisalign]
					   ,[IsDeleted]
					   ,[Name]
					   ,[NumberOfParticipants]
					   ,[RecordType]
					   ,[MethodOfTraining]
					   ,[ModulesCompleted]
					   ,[Status]
					   ,[TotalTime]
					   ,[Type]
					   ,[VCTTrainingDate]
					   ,[IsBasic]
					   ,[IsOrtho]
					   ,[IsOtherSW]
					   ,[IsRestorative]
					   ,[AccountNumber]
					   ,[ContactNumber]
					   ,[MATID]
					   ,[Lab]
			)
			values (
					-1					-- SKVctTraining
				,	-1					-- ADLSBatchID
				,	'19000101'			-- ADLSTimestamp
				,	-1					-- LZBatchID
				,	@BatchID			-- DWBatchID
				,	@Hash				-- DWHash
				,	'N/A'				--[KeyVctTraining]
				,	'N/A'				--[TicketNumber]
				,	-1					--[IsCompleted]
				,	'19000101'			--[CreatedDate]
				,	'N/A'				--[Id]
				,	-1					--[IsInvisalign]
				,	-1					--[IsDeleted]
				,	'N/A'				--[Name]
				,	-1					--[NumberOfParticipants]
				,	'N/A'				--[RecordType]
				,	'N/A'				--[MethodOfTraining]
				,	'N/A'				--[ModulesCompleted]
				,	'N/A'				--[Status]
				,	-1					--[TotalTime]
				,	'N/A'				--[Type]
				,	'19000101'			--[VCTTrainingDate]
				,	-1					--[IsBasic]
				,	-1					--[IsOrtho]
				,	-1					--[IsOtherSW]
				,	-1					--[IsRestorative]
				,	'N/A'				--[AccountNumber]
				,	'N/A'				--[ContactNumber]
				,	'N/A'				--[MATID]
				,	-1					--[Lab]
				
			)
		end try
		begin catch
		end catch

	end
	--  End  createing unknown element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimVctTraining]
		set
				[SKVctTraining] = src.[SKVctTraining],
				[ADLSBatchID] = src.[ADLSBatchID],
				[ADLSTimestamp] = src.[ADLSTimestamp],
				[LZBatchID] = src.[LZBatchID],
				[DWBatchID] = @BatchID,
				[DWHash] = src.[DWHash],
				[KeyVctTraining] = src.[KeyVctTraining],
				[TicketNumber] = src.[TicketNumber],
				[IsCompleted] = src.[IsCompleted],
				[CreatedDate] = src.[CreatedDate],
				[Id] = src.[Id],
				[IsInvisalign] = src.[IsInvisalign],
				[IsDeleted] = src.[IsDeleted],
				[Name] = src.[Name],
				[NumberOfParticipants] = src.[NumberOfParticipants],
				[RecordType] = src.[RecordType],
				[MethodOfTraining] = src.[MethodOfTraining],
				[ModulesCompleted] = src.[ModulesCompleted],
				[Status] = src.[Status],
				[TotalTime] = src.[TotalTime],
				[Type] = src.[Type],
				[VCTTrainingDate] = src.[VCTTrainingDate],
				[IsBasic] = src.[IsBasic],
				[IsOrtho] = src.[IsOrtho],
				[IsOtherSW] = src.[IsOtherSW],
				[IsRestorative] = src.[IsRestorative],
				[AccountNumber] = src.[AccountNumber],
				[ContactNumber] = src.[ContactNumber],	
				[MATID] = src.[MATID],
				[Lab] = src.[Lab]				


	from #TempDimVctTraining src
	where [DWIRIS].[DimVctTraining].SKVctTraining	=	src.SKVctTraining
		and [DWIRIS].[DimVctTraining].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimVctTraining_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimVctTraining_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[DimVctTraining] (
						[SKVctTraining]
					   ,[ADLSBatchID]
					   ,[ADLSTimestamp]
					   ,[LZBatchID]
					   ,[DWBatchID]
					   ,[DWHash]
					   ,[KeyVctTraining]
					   ,[TicketNumber]
					   ,[IsCompleted]
					   ,[CreatedDate]
					   ,[Id]
					   ,[IsInvisalign]
					   ,[IsDeleted]
					   ,[Name]
					   ,[NumberOfParticipants]
					   ,[RecordType]
					   ,[MethodOfTraining]
					   ,[ModulesCompleted]
					   ,[Status]
					   ,[TotalTime]
					   ,[Type]
					   ,[VCTTrainingDate]
					   ,[IsBasic]
					   ,[IsOrtho]
					   ,[IsOtherSW]
					   ,[IsRestorative]
					   ,[AccountNumber]
					   ,[ContactNumber]
					   ,[MATID]
					   ,[Lab]
)
	select 
						[SKVctTraining]
					   ,[ADLSBatchID]
					   ,[ADLSTimestamp]
					   ,[LZBatchID]
					   ,@BatchID
					   ,[DWHash]
					   ,[KeyVctTraining]
					   ,[TicketNumber]
					   ,[IsCompleted]
					   ,[CreatedDate]
					   ,[Id]
					   ,[IsInvisalign]
					   ,[IsDeleted]
					   ,[Name]
					   ,[NumberOfParticipants]
					   ,[RecordType]
					   ,[MethodOfTraining]
					   ,[ModulesCompleted]
					   ,[Status]
					   ,[TotalTime]
					   ,[Type]
					   ,[VCTTrainingDate]
					   ,[IsBasic]
					   ,[IsOrtho]
					   ,[IsOtherSW]
					   ,[IsRestorative]
					   ,[AccountNumber]
					   ,[ContactNumber]
					   ,[MATID]
					   ,[Lab]

	from #TempDimVctTraining src
	where not exists(
		select dst.SKVctTraining 
		from DWIRIS.[DimVctTraining] dst 
		where dst.SKVctTraining = src.SKVctTraining
	)
	option (label = 'DWIRIS.DimVctTraining_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.DimVctTraining_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
	
end --procedure

