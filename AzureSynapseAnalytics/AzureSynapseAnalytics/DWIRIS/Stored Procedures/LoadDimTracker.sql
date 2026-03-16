CREATE PROC [DWIRIS].[LoadDimTracker] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	if object_id('tempdb..#TempDimTracker') is not null
		drop table #TempDimTracker

-- Get delta rows
	create table #TempDimTracker with (distribution = round_robin, heap) as 
	select	
			a.ADLSBatchID										as ADLSBatchID
		,	a.ADLSTimestamp										as ADLSTimestamp
		,	a.LZBatchID											as LZBatchID
		,	convert(char(40), '')								as DWHash
		,	hub.[SKTracker]										as [SKTracker]
		,	isnull(ha.SKAsset,-1)								as SKAsset
		,	a.[Name]											as [TrackerName]
		,	a.tracking_message__c								as [TrackingMessage]
		,	a.tracking_number__c								as [TrackingNumber]
		,	a.tracking_status__c								as [TrackingStatus]
		,	a.scheduled_delivery_delivered_date__c				as [ScheduledDeliveryDeliveredDate]
		,	a.carrier__c										as [Carrier]
		,	a.shipped_date__c									as [ShippedDate]
		,	'SFDC'												as [SourceSystem]
		,   a.Opportunity__c									as [OpportunityId]
		,	a.Processing_status__c								as [ProcessingStatus]
		,	ht.KeyTicket										as [KeyTicket]
	from  SrcSFDC.Tracker__c a
	inner join DWIRIS.HubTracker hub 
		on hub.KeyTracker = a.[Id]
	left join SrcSFDC.Asset asset
		on asset.Id = a.Asset__c
	left join DWIRIS.HubAsset ha
		on ha.KeyAsset = asset.SerialNumber
	left join DWIRIS.HubTicket ht
		on ht.KeyTicket = a.Ticket__c
	where a.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimTracker where SourceSystem='SFDC')

	


	--update HASH  (HASH DOES NOT INCLUDE BUSINESS KEY AND ETL FIELDS!!! )
	update #TempDimTracker set DWHash=
		convert(char(40),
			hashbytes('SHA1',
					   ISNULL(convert(nvarchar,SourceSystem),'')
				  +'|'+ISNULL(convert(nvarchar,SKAsset),'')
				  +'|'+ISNULL(convert(nvarchar,TrackerName),'')
				  +'|'+ISNULL(convert(nvarchar,TrackingMessage),'')
				  +'|'+ISNULL(convert(nvarchar,TrackingNumber),'')
				  +'|'+ISNULL(convert(nvarchar,TrackingStatus),'')
				  +'|'+ISNULL(convert(nvarchar,ScheduledDeliveryDeliveredDate),'')
				  +'|'+ISNULL(convert(nvarchar,Carrier),'')
				  +'|'+ISNULL(convert(nvarchar,ShippedDate),'')
				  +'|'+ISNULL(convert(nvarchar,OpportunityId),'')
				  +'|'+ISNULL(convert(nvarchar,ProcessingStatus),'')
				  +'|'+ISNULL(convert(nvarchar,KeyTicket),'')
				)
			,2)


	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimTracker] where SKTracker = -1)
	begin
		declare @Hash char(40) = ''

		begin try
			insert into DWIRIS.DimTracker (
				 [SKTracker]
				,[ADLSBatchID]
				,[ADLSTimestamp]
				,[LZBatchID]
				,[DWBatchID]
				,[DWHash]
				,[SourceSystem]
				,[SKAsset]
				,[TrackerName]
				,[TrackingMessage]
				,[TrackingNumber]
				,[TrackingStatus]
				,[ScheduledDeliveryDeliveredDate]
				,[Carrier]
				,[ShippedDate]
				,[OpportunityId]
				,[ProcessingStatus]
				,[KeyTicket]
			)
			values (
					-1
				,	-1
				,	'19000101'
				,	-1
				,	@BatchID
				,	@Hash
				
				,	'N/A' --SourceSystem
				,	-1	  --SKAsset
				,	'N/A' --TrackerName
				,	'N/A' --TrackingMessage
				,	'N/A' --TrackingNumber
				,	'N/A' --TrackingStatus
				,	'1900-01-01' --ScheduledDeliveryDeliveredDate
				,	'N/A' --Carrier
				,	'1900-01-01' --ShippedDate
				,	'N/A' --OpportunityId
				,	'N/A' --ProcessingStatus
				,	'N/A' --KeyTicket
			)
		end try
		begin catch
			throw
		end catch
	end
	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimTracker]
		set
			 ADLSBatchID = src.ADLSBatchID
			,ADLSTimestamp = src.ADLSTimestamp
			,LZBatchID = src.LZBatchID
			,DWBatchID = @BatchID
			,DWHash = src.DWHash
			,[SourceSystem]									=			src.[SourceSystem]
			,[SKAsset]										=			src.[SKAsset]
			,[TrackerName]									=			src.[TrackerName]
			,[TrackingMessage]								=			src.[TrackingMessage]
			,[TrackingNumber]								=			src.[TrackingNumber]
			,[TrackingStatus]								=			src.[TrackingStatus]
			,[ScheduledDeliveryDeliveredDate]				=			src.[ScheduledDeliveryDeliveredDate]
			,[Carrier]										=			src.[Carrier]
			,[ShippedDate]									=			src.[ShippedDate]
			,[OpportunityId]								=		src.[OpportunityId]
			,[ProcessingStatus]								=		src.[ProcessingStatus]
			,[KeyTicket]									=		src.[KeyTicket]
	from #TempDimTracker src
	where [DWIRIS].[DimTracker].SKTracker = src.SKTracker
	and [DWIRIS].[DimTracker].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimTracker_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimTracker_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[DimTracker] (
				 [SKTracker]
				,[ADLSBatchID]
				,[ADLSTimestamp]
				,[LZBatchID]
				,[DWBatchID]
				,[DWHash]
				,[SourceSystem]
				,[SKAsset]
				,[TrackerName]
				,[TrackingMessage]
				,[TrackingNumber]
				,[TrackingStatus]
				,[ScheduledDeliveryDeliveredDate]
				,[Carrier]
				,[ShippedDate]
				,[OpportunityId]
				,[ProcessingStatus]
				,[KeyTicket]
		   )
	select 
				 [SKTracker]
				,[ADLSBatchID]
				,[ADLSTimestamp]
				,[LZBatchID]
				,@BatchID
				,[DWHash]

				,[SourceSystem]
				,[SKAsset]
				,[TrackerName]
				,[TrackingMessage]
				,[TrackingNumber]
				,[TrackingStatus]
				,[ScheduledDeliveryDeliveredDate]
				,[Carrier]
				,[ShippedDate]
				,[OpportunityId]
				,[ProcessingStatus]
				,[KeyTicket]
	from #TempDimTracker src
	where not exists(select dst.SKTracker from DWIRIS.DimTracker dst where dst.SKTracker = src.SKTracker)
	option (label = 'DWIRIS.LoadDimTracker_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimTracker_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end