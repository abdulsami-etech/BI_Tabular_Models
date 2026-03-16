CREATE PROC [DWIRIS].[LoadFactCreditRequest] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempFactCreditRequest') is not null
		drop table #TempFactCreditRequest

-- Get delta rows
	create table #TempFactCreditRequest with (distribution = round_robin, heap) as 
	SELECT 
		
				h.SKSalesContract											as SKSalesContract,
				c.ADLSBatchID,
				c.ADLSTimestamp,
				c.LZBatchID,
				convert(char(40), '')										as DWHash,
				c.ID														as KeySalesContract,
				
				isnull(ah.SKAccount, -1)									as SKAccount,
				isnull(th.SKTeam, -1)										as SKTeam,
				isnull(uh.SKUser, -1)										as SKUser,

				c.[CreatedDate]												as CreatedDate,
				YEAR (c.[CreatedDate])*10000+
				MONTH(c.[CreatedDate])*100+		
				DAY  (c.[CreatedDate])										as CreatedDateKey,

				c.[ClosedDate]												as ClosedDate,
				YEAR (c.[ClosedDate])*10000+
				MONTH(c.[ClosedDate])*100+		
				DAY  (c.[ClosedDate])										as ClosedDateKey,
				
				c.[Processing_completed_date__c]							as ProcessedDate,
				YEAR (c.[Processing_completed_date__c])*10000+
				MONTH(c.[Processing_completed_date__c])*100+		
				DAY  (c.[Processing_completed_date__c])						as ProcessedDateKey

	FROM SrcSFDC.[Case] c
	inner join DWIRIS.HubSalesContract h 
		on c.Id = h.KeySalesContract
		and h.SourceSystemCode = 'SFDC'
	left join SrcSFDC.Opportunity o 
		on c.Opportunity__c = o.Id
	left join SrcSFDC.[User] u 
		on c.OwnerId = u.Id
	left join DWIRIS.HubUser uh
		on u.Id = uh.KeyUser
	left join DWIRIS.HubAsset asseth
		on o.Scanner_SN__c = asseth.KeyAsset
	left join DW.HubAccount ah
		on c.KeyAccount = ah.AccountID
	left join DWIRIS.HubTeam th
		on c.Team_Function__c = th.KeyTeam

		
	--update HASH
	update #TempFactCreditRequest set DWHash=
		convert(char(40),
			hashbytes('SHA1',
				         ISNULL(convert(nvarchar,KeySalesContract),'')
					+'|'+ISNULL(convert(nvarchar,SKAccount),'')
					+'|'+ISNULL(convert(nvarchar,SKTeam),'')
					+'|'+ISNULL(convert(nvarchar,SKUser),'')
					+'|'+ISNULL(convert(nvarchar,CreatedDate),'')
					+'|'+ISNULL(convert(nvarchar,ClosedDate),'')
					+'|'+ISNULL(convert(nvarchar,ProcessedDate),'')
				)
			,2)


	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[FactCreditRequest] where SKSalesContract = -1)
	begin
		declare @Hash char(40) = ''

		insert into DWIRIS.FactCreditRequest (
				[SKSalesContract]
				,[ADLSBatchID]
				,[ADLSTimestamp]
				,[LZBatchID]
				,[DWBatchID]
				,[DWHash]
				,[KeySalesContract]
				,[SKAccount]
				,[SKTeam]
				,[SKUser]
				,[CreatedDate]
				,[CreatedDateKey]
				,[ClosedDate]
				,[ClosedDateKey]
				,[ProcessedDate]
				,[ProcessedDateKey]
				
		)
		values (
				-1					-- SKAsset
			,	-1					-- ADLSBatchID
			,	'19000101'			-- ADLSTimestamp
			,	-1					-- LZBatchID
			,	@BatchID			-- DWBatchID
			,	@Hash				-- DWHash
				
			,   'N/A'				--[KeySalesContract]
			,	-1					--[SKAccount]
			,	-1					--[SKTeam]
			,	-1					--[SKUser]
			,	'19000101'			--[CreatedDate]
			,	19000101			--[CreatedDateKey]
			,	'19000101'			--[ClosedDate]
			,	19000101			--[ClosedDateKey]
			,	'19000101'			--[ProcessedDate]
			,   19000101			--[ProcessedDateKey]
			)
	end
	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[FactCreditRequest]
		set
		     ADLSBatchID = src.ADLSBatchID
			,ADLSTimestamp = src.ADLSTimestamp
			,LZBatchID = src.LZBatchID
			,DWBatchID = @BatchID
			,DWHash = src.DWHash
			
		  ,[SKAccount]									=	src.[SKAccount]
		  ,[SKTeam]										=	src.[SKTeam]
		  ,[SKUser]										=	src.[SKUser]
		  ,[CreatedDate]								=	src.[CreatedDate]
 		  ,[CreatedDateKey]								=	src.[CreatedDateKey]
		  ,[ClosedDate]									=	src.[ClosedDate]
		  ,[ClosedDateKey]								=	src.[ClosedDateKey]
		  ,[ProcessedDate]								=	src.[ProcessedDate]
		  ,[ProcessedDateKey]							=	src.[ProcessedDateKey]
		  

	from #TempFactCreditRequest src
	where [DWIRIS].[FactCreditRequest].SKSalesContract	=	src.SKSalesContract
		and [DWIRIS].[FactCreditRequest].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadFactCreditRequest_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadFactCreditRequest_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[FactCreditRequest] (
				   [SKSalesContract]
				  ,[ADLSBatchID]
				  ,[ADLSTimestamp]
				  ,[LZBatchID]
				  ,[DWBatchID]
				  ,[DWHash]
				  ,[KeySalesContract]
				  ,[SKAccount]
				  ,[SKTeam]
				  ,[SKUser]
				  
				  ,[CreatedDate]
				  ,[CreatedDateKey]
				  ,[ClosedDate]
				  ,[ClosedDateKey]
				  ,[ProcessedDate]
				  ,[ProcessedDateKey]
				  
		   )
	select 
				   [SKSalesContract]
				  ,[ADLSBatchID]
				  ,[ADLSTimestamp]
				  ,[LZBatchID]
				  ,@BatchID
				  ,[DWHash]
				  ,[KeySalesContract]
				   ,[SKAccount]
				  ,[SKTeam]
				  ,[SKUser]
				  ,[CreatedDate]
				  ,[CreatedDateKey]
				  ,[ClosedDate]
				  ,[ClosedDateKey]
				  ,[ProcessedDate]
				  ,[ProcessedDateKey]

	from #TempFactCreditRequest src
	where not exists(select dst.SKSalesContract from DWIRIS.FactCreditRequest dst where dst.SKSalesContract = src.SKSalesContract)
	option (label = 'DWIRIS.LoadFactCreditRequest_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadFactCreditRequest_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
	
end --procedure

