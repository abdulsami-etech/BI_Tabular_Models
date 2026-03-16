CREATE PROC [DWIRIS].[LoadDimServiceContract] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	if object_id('tempdb..#TempDimServiceContract') is not null
		drop table #TempDimServiceContract

-- Get delta rows
	create table #TempDimServiceContract with (distribution = round_robin, heap) as 
	select	
			sc.ADLSBatchID												as ADLSBatchID
		,	sc.ADLSTimestamp												as ADLSTimestamp
		,	sc.LZBatchID													as LZBatchID
		,	convert(char(40), '')											as DWHash
		,	hub.[SKServiceContract]											as [SKServiceContract]
		,   sc.Id															as [KeyServiceContract]
		,	cli.[AssetId]													as [KeyAsset]
		,	sc.[AccountId]													as [KeyAccount]
		,	cli.[LineItemNumber]											as [LineItemNumber]
		,	cli.[Product2Id] 												as [KeyProduct]
		,	cli.[Quantity] 													as [Quantity]
		,	sc.[ContractNumber] 											as [ContractNumber]
		,	sc.[Discount] 													as [Discount]
		,	sc.[StartDate] 													as [StartDate]
		,	sc.[EndDate] 													as [EndDate]
		,	sc.[GrandTotal] 												as [GrandTotal]
		,	sc.[Name] 														as [Name]
		,	sc.[ParentServiceContractId] 									as [ParentServiceContractId]
		,	sc.[Scanner_Serial_Number__c] 									as [ScannerSerialNumber]
		,	sc.[Ship_To_Account__c] 										as [ShipToAccount]
		,	sc.[ShippingHandling] 											as [ShippingHandling]
		,	sc.[Status] 													as [Status]
		,	sc.[Subtotal] 													as [SubTotal]
		,	sc.[Tax] 														as [Tax]
		,	sc.[Term] 														as [Term]
		,	sc.[TotalPrice] 												as [TotalPrice]
		,	sc.[Type__c] 													as [Type]
	from SrcSFDC.ServiceContract sc
inner join DWIRIS.HubServiceContract hub	
	on hub.KeyServiceContract = sc.Id
left join SrcSFDC.ContractLineItem cli
	on cli.ServiceContractId = sc.Id

where sc.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimServiceContract)

	--update HASH  (HASH DOES NOT INCLUDE BUSINESS KEY AND ETL FIELDS!!! )
	update #TempDimServiceContract set DWHash=
		convert(char(40),
			hashbytes('SHA1',
					     ISNULL(convert(nvarchar,[KeyAsset]),'')
					+'|'+ISNULL(convert(nvarchar,[KeyAccount]),'')  
					+'|'+ISNULL(convert(nvarchar,[LineItemNumber]),'')
					+'|'+ISNULL(convert(nvarchar,[KeyProduct]),'')
					+'|'+ISNULL(convert(nvarchar,[Quantity]),'')
					+'|'+ISNULL(convert(nvarchar,[ContractNumber]),'')
					+'|'+ISNULL(convert(nvarchar,[Discount]),'')
					+'|'+ISNULL(convert(nvarchar,[StartDate]),'')
					+'|'+ISNULL(convert(nvarchar,[EndDate]),'')
					+'|'+ISNULL(convert(nvarchar,[GrandTotal]),'')
					+'|'+ISNULL(convert(nvarchar,[Name]),'')
					+'|'+ISNULL(convert(nvarchar,[ParentServiceContractId]),'')
					+'|'+ISNULL(convert(nvarchar,[ScannerSerialNumber]),'')
					+'|'+ISNULL(convert(nvarchar,[ShipToAccount]),'')
					+'|'+ISNULL(convert(nvarchar,[ShippingHandling]),'')
					+'|'+ISNULL(convert(nvarchar,[Status]),'')
					+'|'+ISNULL(convert(nvarchar,[SubTotal]),'')
					+'|'+ISNULL(convert(nvarchar,[Tax]),'')
					+'|'+ISNULL(convert(nvarchar,[Term]),'')
					+'|'+ISNULL(convert(nvarchar,[TotalPrice]),'')
					+'|'+ISNULL(convert(nvarchar,[Type]),'')
				)
			,2)

	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimServiceContract] where SKServiceContract = -1)
	begin
		declare @Hash char(40) = ''

		begin try
			insert into DWIRIS.DimServiceContract (
				 [SKServiceContract]
				,[ADLSBatchID]
				,[ADLSTimestamp]
				,[LZBatchID]
				,[DWBatchID]
				,[DWHash]
				,[KeyServiceContract]
				,[KeyAsset]
				,[KeyAccount]
				,[LineItemNumber]
				,[KeyProduct]
				,[Quantity]
				,[ContractNumber]
				,[Discount]
				,[StartDate]
				,[EndDate]
				,[GrandTotal]
				,[Name]
				,[ParentServiceContractId]
				,[ScannerSerialNumber]
				,[ShipToAccount]
				,[ShippingHandling]
				,[Status]
				,[SubTotal]
				,[Tax]
				,[Term]
				,[TotalPrice]
				,[Type]

			)
			values (
					-1
				,	-1
				,	'19000101'
				,	-1
				,	@BatchID
				,	@Hash
				,	'N/A'			--KeyServiceContract
				,	'N/A'			--KeyAsset
				,	'N/A'			--KeyAccount
				,	'N/A'			--LineItemNumber
				,	'N/A'			--KeyProduct
				,	-1				--Quantity
				,	'N/A'			--ContractNumber
				,	-1				--Discount
				,	'1900-01-01'	--StartDate
				,	'1900-01-01'	--EndDate
				,	-1				--GrandTotal
				,	'N/A'			--Name
				,	'N/A'			--ParentServiceContractId
				,	'N/A'			--ScannerSerialNumber
				,	'N/A'			--ShipToAccount
				,	-1				--ShippingHandling
				,	-1				--Status
				,	-1				--SubTotal
				,	-1				--Tax
				,	-1				--Term
				,	-1				--TotalPrice
				,	'N/A'			--Type
			)
		end try
		begin catch
			throw
		end catch
	end
	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimServiceContract]
		set
			 [ADLSBatchID] = src.[ADLSBatchID],
			[ADLSTimestamp] = src.[ADLSTimestamp],
			[LZBatchID] = src.[LZBatchID],
			[DWBatchID] = @BatchID,
			[DWHash] = src.[DWHash],
			[KeyServiceContract] = src.[KeyServiceContract],
			[KeyAsset] = src.[KeyAsset],
			[KeyAccount] = src.[KeyAccount],
			[LineItemNumber] = src.[LineItemNumber],
			[KeyProduct] = src.[KeyProduct],
			[Quantity] = src.[Quantity],
			[ContractNumber] = src.[ContractNumber],
			[Discount] = src.[Discount],
			[StartDate] = src.[StartDate],
			[EndDate] = src.[EndDate],
			[GrandTotal] = src.[GrandTotal],
			[Name] = src.[Name],
			[ParentServiceContractId] = src.[ParentServiceContractId],
			[ScannerSerialNumber] = src.[ScannerSerialNumber],
			[ShipToAccount] = src.[ShipToAccount],
			[ShippingHandling] = src.[ShippingHandling],
			[Status] = src.[Status],
			[SubTotal] = src.[SubTotal],
			[Tax] = src.[Tax],
			[Term] = src.[Term],
			[TotalPrice] = src.[TotalPrice],
			[Type] = src.[Type]
	from #TempDimServiceContract src
	where [DWIRIS].[DimServiceContract].SKServiceContract = src.SKServiceContract
	and [DWIRIS].[DimServiceContract].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimServiceContract_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimServiceContract_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[DimServiceContract] (
				 [SKServiceContract]
				,[ADLSBatchID]
				,[ADLSTimestamp]
				,[LZBatchID]
				,[DWBatchID]
				,[DWHash]
				,[KeyServiceContract]
				,[KeyAsset]
				,[KeyAccount]
				,[LineItemNumber]
				,[KeyProduct]
				,[Quantity]
				,[ContractNumber]
				,[Discount]
				,[StartDate]
				,[EndDate]
				,[GrandTotal]
				,[Name]
				,[ParentServiceContractId]
				,[ScannerSerialNumber]
				,[ShipToAccount]
				,[ShippingHandling]
				,[Status]
				,[SubTotal]
				,[Tax]
				,[Term]
				,[TotalPrice]
				,[Type]
		   )
	select 
				 [SKServiceContract]
				,[ADLSBatchID]
				,[ADLSTimestamp]
				,[LZBatchID]
				,@BatchID
				,[DWHash]
				,[KeyServiceContract]
				,[KeyAsset]
				,[KeyAccount]
				,[LineItemNumber]
				,[KeyProduct]
				,[Quantity]
				,[ContractNumber]
				,[Discount]
				,[StartDate]
				,[EndDate]
				,[GrandTotal]
				,[Name]
				,[ParentServiceContractId]
				,[ScannerSerialNumber]
				,[ShipToAccount]
				,[ShippingHandling]
				,[Status]
				,[SubTotal]
				,[Tax]
				,[Term]
				,[TotalPrice]
				,[Type]
	from #TempDimServiceContract src
	where not exists(select dst.SKServiceContract from DWIRIS.DimServiceContract dst where dst.SKServiceContract = src.SKServiceContract)
	option (label = 'DWIRIS.LoadDimServiceContract_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimServiceContract_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end