CREATE PROC [DWIRIS].[LoadDimTicketItem] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimTicketItem') is not null
		drop table #TempDimTicketItem

-- Get delta rows
	create table #TempDimTicketItem with (distribution = round_robin, heap) as 
	select 
		hti.SKTicketItem
		, iopd.ADLSBatchID											as ADLSBatchID
		, iopd.ADLSTimestamp										as ADLSTimestamp
		, iopd.LZBatchID											as LZBatchID
		, convert(char(40), '')										as DWHash
		, iopd.Id													as KeyTicketItem
		, ha.SKAsset
		--, cas.AccountID			as AccountID
		, ht.SKTicket
		, convert(int, convert(char(8), cas.CreatedDate, 112))		as SKCreatedDate
		, cas.CreatedDate											as CreatedDate
		, 1															as IsRMA
		, cas.Return_Type__c										as IsDOA
		, isnull(iopd.Asset_Type__c, iopd.[Name])					as ReplacedType
		, N''														as ReplacedSN
		, asset.SerialNumber										as ReplacementSN
		, cas.Tracking_Number__c									as TrackingNumber
		, cas_support.[Description]									as ReportedIssue
		, cas.Root_Cause__c											as RootCause
		, N''														as ApprovedStatus
		,Replacement_Reason__c										as ReplacementReason
		,ht_p.SKTicket												as SKParentTicket
		,iopd.IsDeleted												as IsDeleted
		,isnull(asset.[Description],pr2.[Name])						as ProductName
		,isnull(asset.[StockKeepingUnit],pr2.[ProductCode])			as ProductCode
		,cas.Incoming_Tracking_Number__c							as IncomingTrackingNumber   
		,cas.Quote_Proposal_ID__c									as QuoteProposalID
		,pr2.Apttus_Config2__ProductType__c							as ProductGroup
		,case when gr.Id is not null then 1 else 0 end as [IsInvalid]
	from SrcSFDC.[Case] cas
	join SrcSFDC.Itero_Order_Product_Details__c iopd
		on iopd.Ticket__c = cas.Id
	join SrcSFDC.RecordType rt
		on cas.RecordTypeId = rt.Id
	left join SrcSFDC.[Case] cas_support
		on cas.ParentId = cas_support.Id
	--	SK Ticket Item
	left join DWIRIS.HubTicketItem hti
		on hti.KeyTicketItem = iopd.Id
	--	SK Ticket
	left join DWIRIS.HubTicket ht
		on ht.KeyTicket = cas.Id
	--	SK Asset
	left join SrcSFDC.Asset asset
		on iopd.Asset__c = asset.Id
	left join DWIRIS.HubAsset ha
		on ha.KeyAsset = convert(nvarchar(160), asset.SerialNumber)
	--	Parent SK Ticket
	left join DWIRIS.HubTicket ht_p
		on ht_p.KeyTicket = cas_support.Id
	left join [SrcSFDC].[Product2] pr2
		on pr2.Id = iopd.Product1__c
	left join SrcSFDC.[Group] gr
		on gr.Id = cas.OwnerID and gr.[Name] = 'Invalid Tickets'
	where rt.[Name] in (N'iTero RMA', N'iTero Support')
	union all

	select 
		hti.SKTicketItem
		, link.ADLSBatchID			as ADLSBatchID
		, link.ADLSTimestamp		as ADLSTimestamp
		, link.LZBatchID			as LZBatchID
		, convert(char(40), '')		as DWHash
		, convert(nchar(18), track.ID)								as KeyTicketItem
		, null														as SKAsset
		--, hac.SKAccount
		, ht.SKTicket
		, convert(int, convert(char(8), link.DateCreated, 112))		as SKCreatedDate
		, link.DateCreated											as CreatedDate
		, track.IsRMA
		, case when track.IsDOA = 1 then N'DOA'
			   when track.IsDOA = 0 then N'Not DOA'
			   else N'Unknown'
		  end														as IsDOA
		, case link.ItemID when 50081 then N'Base Unit'
						   when 50082 then N'Wand'
						   when 50111 then N'Cable'
						   when 50075 then N'Cable'
						   when 50121 then N'Full system'
						   when 50083 then N'Full system'
						   when 50084 then N'Full system'
						   when 50115 then N'Wheeled Stand'
						   when 50086 then N'Wheeled Stand'
						   else i.ItemGenericDescription 
		  end														as ReplacedType
		, case when i.ItemID in (50111 , 50075)			--	cables
			   then N'Cable --> No serial'
			   when i.ItemID = 50081					--	base unit
					and track.ReplacedSerial = N''  
			   then ec. SerialIdentifier
			   when i.ItemID = 50082					--	wand
					and track.ReplacedSerial = N''  
			   then ec. SerialIdentifier
			   when i.ItemID IN (50121, 50083, 50084)	--	full system
					and track.ReplacedSerial = N''  
			   then ec.SerialIdentifier
			   else track.ReplacedSerial
		  end														as ReplacedSN
		, ser.SerialCode											as ReplacementSN
		, track.Tracking											as TrackingNumber
		, track.ReportedIssue
		, track.RootCause
		, case link.ApprovalStatus	when 1 then N'Not yet'
									when 2 then N'Approved'
									when 3 then N'Rejected'
		  end														as ApprovedStatus
		,convert(nchar(18), NULL)									as ReplacementReason
		,-1															as SKParentTicket
		,0															as IsDeleted
		,NULL														as ProductName
		,NULL														as ProductCode
		,NULL														as IncomingTrackingNumber   
		,NULL														as QuoteProposalID 
		,NULL														as ProductGroup
		,NULL														as IsInvalid
	from SrcMAT.svc_Ticket tck
	join SrcMAT.svc_Ticket_PartsRequestLink link
		on tck.TicketID = link.TicketID
	left join SrcMAT.Items i
		on link.ItemID = i.ItemID
	left join SrcMAT.svc_Ticket_PartsTracking as track
		on link.svc_Ticket_PartsRequestLinkId = track.RequestLinkId
	left join SrcMAT.TransitionSerial as ser
		on track.TransitionSerialId = ser.TransitionSerialId
	left join SrcMAT.svc_EquipmentCard ec 
		on tck.TicketIssueEntityID = ec.EquipmentCardID 

	--	SK Ticket Item
	left join DWIRIS.HubTicketItem hti
		on hti.KeyTicketItem = convert(nchar(18), track.ID)
	--	SK Ticket
	left join DWIRIS.HubTicket ht
		on ht.KeyTicket = convert(nchar(18),tck.TicketID)

	where track.ID is not null;



	-- update HASH
	update #TempDimTicketItem set DWHash=
		convert(char(40),
			hashbytes('SHA1',
								  convert(nvarchar,ISNULL(KeyTicketItem,''))
							+'|'+convert(nvarchar,ISNULL(SKAsset,''))
							+'|'+convert(nvarchar,ISNULL(SKTicket,''))
							+'|'+convert(nvarchar,ISNULL(convert(nvarchar(50),SKCreatedDate),''))
							+'|'+convert(nvarchar,ISNULL(CreatedDate,''))
							+'|'+convert(nvarchar,ISNULL(IsRMA,''))
							+'|'+convert(nvarchar,ISNULL(IsDOA,''))
							+'|'+convert(nvarchar,ISNULL(ReplacedType,''))
							+'|'+convert(nvarchar,ISNULL(ReplacedSN,''))
							+'|'+convert(nvarchar,ISNULL(ReplacementSN,''))
							+'|'+convert(nvarchar,ISNULL(TrackingNumber,''))
							+'|'+convert(nvarchar,ISNULL(ReportedIssue,''))
							+'|'+convert(nvarchar,ISNULL(RootCause,''))
							+'|'+convert(nvarchar,ISNULL(ApprovedStatus,''))
							+'|'+convert(nvarchar,ISNULL(ReplacementReason,''))
							+'|'+convert(nvarchar,ISNULL(IsDeleted,''))
							+'|'+convert(nvarchar,ISNULL(ProductName,''))
							+'|'+convert(nvarchar,ISNULL(ProductCode,''))
							+'|'+convert(nvarchar,ISNULL(IncomingTrackingNumber,''))
							+'|'+convert(nvarchar,ISNULL(QuoteProposalID,''))
							+'|'+convert(nvarchar,ISNULL(ProductGroup,''))
							+'|'+convert(nvarchar,ISNULL(IsInvalid,''))

				)
			,2)


	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimTicketItem] where SKTicketItem = -1)
	begin
		declare @Hash char(40) = ''
		insert into DWIRIS.DimTicketItem (
				[SKTicketItem]
			,	[ADLSBatchID]
			,	[ADLSTimestamp]
			,	[LZBatchID]
			,	[DWBatchID]
			,	[DWHash]

			,	[KeyTicketItem]
			,	[SKAsset]
			,	[SKTicket]
			,	[SKCreatedDate]
			,	[CreatedDate]
	
			,	[IsRMA]
			,	[IsDOA]
			,	[ReplacedType]
			,	[ReplacedSN]
			,	[ReplacementSN]
			,	[TrackingNumber]
			,	[ReportedIssue]
			,	[RootCause]
			,	[ApprovedStatus]
			,	[ReplacementReason]
			,	[IsDeleted]
			,	[ProductName]
			,	[ProductCode]
			,	[IncomingTrackingNumber]
			,	[QuoteProposalID]
			,	[ProductGroup]
			,	[IsInvalid]
		)
		values (
				-1					-- SKTicketItem
			,	-1					-- ADLSBatchID
			,	'19000101'			-- ADLSTimestamp
			,	-1					-- LZBatchID
			,	@BatchID			-- DWBatchID
			,	@Hash				-- DWHash

			,	'0'					-- KeyTicketItem
			,	-1					-- SKAsset
			,	-1					-- SKTicket
			,	19000101			-- SKCreatedDate
			,	'19000101'			-- CreatedDate

			,	0					-- IsRMA
			,	N''					-- IsDOA
			,	N''					-- ReplacedType
			,	N''					-- ReplacedSN
			,	N''					-- ReplacementSN
			,	N''					-- TrackingNumber
			,	N''					-- ReportedIssue
			,	N''					-- RootCause
			,	N''					-- ApprovedStatus
			,	N''					-- ReplacementReason
			,	0					-- IsDeleted
			,	N''					-- ProductName
			,	N''					-- ProductCode
			,	N''					-- IncomingTrackingNumber
			,	N''					-- QuoteProposalID
			,	N''					-- ProductGroup
			,	0					-- IsInvalid
		)
	end
	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimTicketItem]
	set
			ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchID
		,	DWHash = src.DWHash

		,	[KeyTicketItem] = src.[KeyTicketItem]
		,	[SKAsset] = src.[SKAsset]
		,	[SKTicket] = src.[SKTicket]
		,	[SKCreatedDate] = src.[SKCreatedDate]
		,	[CreatedDate] = src.[CreatedDate]
	
		,	[IsRMA] = src.[IsRMA]
		,	[IsDOA] = src.[IsDOA]
		,	[ReplacedType] = src.[ReplacedType]
		,	[ReplacedSN] = src.[ReplacedSN]
		,	[ReplacementSN] = src.[ReplacementSN]
		,	[TrackingNumber] = src.[TrackingNumber]
		,	[ReportedIssue] = src.[ReportedIssue]
		,	[RootCause] = src.[RootCause]
		,	[ApprovedStatus] = src.[ApprovedStatus]
		,	[ReplacementReason] = src.[ReplacementReason]
		,   [IsDeleted]			= src.[IsDeleted]
		,   [ProductName]			= src.[ProductName]
		,   [ProductCode]			= src.[ProductCode]
		,	[IncomingTrackingNumber] = src.[IncomingTrackingNumber]
		,	[QuoteProposalID]		= src.[QuoteProposalID]
		,	[ProductGroup]			= src.[ProductGroup]
		,	[IsInvalid]				= src.[IsInvalid]
	from #TempDimTicketItem src
	where [DWIRIS].[DimTicketItem].SKTicketItem	= src.SKTicketItem
	and [DWIRIS].[DimTicketItem].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimTicketItem_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimTicketItem_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[DimTicketItem] (
			[SKTicketItem]
		,	[ADLSBatchID]
		,	[ADLSTimestamp]
		,	[LZBatchID]
		,	[DWBatchID]
		,	[DWHash]

		,	[KeyTicketItem]
		,	[SKAsset]
		,	[SKTicket]
		,	[SKCreatedDate]
		,	[CreatedDate]
	
		,	[IsRMA]
		,	[IsDOA]
		,	[ReplacedType]
		,	[ReplacedSN]
		,	[ReplacementSN]
		,	[TrackingNumber]
		,	[ReportedIssue]
		,	[RootCause]
		,	[ApprovedStatus]
		,	[ReplacementReason]
		,   [IsDeleted]
		,   [ProductName]
		,   [ProductCode]
		,	[IncomingTrackingNumber]
		,	[QuoteProposalID]
		,	[ProductGroup]
		,	[IsInvalid]
	)
	select 
			[SKTicketItem]
		,	[ADLSBatchID]
		,	[ADLSTimestamp]
		,	[LZBatchID]
		,	@BatchID
		,	[DWHash]


		,	[KeyTicketItem]
		,	[SKAsset]
		,	[SKTicket]
		,	[SKCreatedDate]
		,	[CreatedDate]
	
		,	[IsRMA]
		,	[IsDOA]
		,	[ReplacedType]
		,	[ReplacedSN]
		,	[ReplacementSN]
		,	[TrackingNumber]
		,	[ReportedIssue]
		,	[RootCause]
		,	[ApprovedStatus]
		,	[ReplacementReason]
		,   [IsDeleted]
		,   [ProductName]
		,   [ProductCode]
		,	[IncomingTrackingNumber]
		,	[QuoteProposalID]
		,	[ProductGroup]
		,	[IsInvalid]
	from #TempDimTicketItem src
	where not exists(select dst.SKTicketItem from DWIRIS.DimTicketItem dst where dst.SKTicketItem = src.SKTicketItem)
	option (label = 'DWIRIS.LoadDimTicketItem_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimTicketItem_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end --procedure

