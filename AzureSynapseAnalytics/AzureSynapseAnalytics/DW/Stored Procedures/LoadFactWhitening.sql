CREATE PROC [DW].[LoadFactWhitening] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@IsFullLoad		bit = 0

	set @IsFullLoad = isnull(@IsForceFullLoad, 0)

	Declare @CurrentDateTime datetime = GETUTCDATE();
	
	if object_id('tempdb..#TempFactWhitening') is not null
		drop table #TempFactWhitening

	create table #TempFactWhitening with (distribution = round_robin, heap) as 
	
SELECT  DISTINCT ho.SKOrder
	, 	ho.KeyOrder AS SAPOrderNumber
	, 	ol.Product_Code__c AS MaterialNumber
	,	ol.Apttus_Config2__LineNumber__c AS LineNumber
	, 	oh.Patient_Age_Year__c AS PatientAge
	, 	p.Name AS Product
	, 	ol.Deliverable_Type__c AS DeliverableType
	, 	ISNULL(ola.Apttus_Config2__IncentiveCode__c, 'Full Price Case') AS IncentiveCode
	, 	oh.Case_Submission_Territory_Name__c AS AMRTerritoryCode
	, 	oh.CCA_Territory_Name__c AS CCATerritoryCode
	, 	ol.Apttus_Config2__ListPrice__c AS ListPrice
	, 	ol.Apttus_Config2__NetPrice__c AS NetPrice
	, 	ola.Discount_Amount__c AS DiscAmount
	, 	ola.Discount_Percent1__c AS DiscPerc
	, 	shp.SecRegion
	,	ol.Apttus_Config2__Quantity__c AS Quantity
	,	ol.Deliverable_Quantity__c AS DeliverableQty
FROM SrcSFDC.Apttus_Config2__OrderLineItem__c ol 
INNER JOIN SrcSFDC.apttus_Config2__Order__C oh ON ol.Apttus_Config2__OrderId__c= oh.id
INNER JOIN DW.HubOrder ho ON TRY_CONVERT(bigint,oh.SAP_ORDER_ID__c) = ho.KeyOrder
INNER JOIN SrcSFDC.product2 p ON ol.Apttus_Config2__ProductId__c = p.id
INNER JOIN DW.DimAccount shp ON oh.Apttus_Config2__ShipToAccountId__c= shp.KeyAccount
LEFT JOIN [SrcSFDC].[Apttus_Config2__OrderAdjustmentLineItem__c] ola ON ola.Apttus_Config2__LineItemId__c = ol.id
LEFT JOIN [DW].[DimTerritoryHierarchy] th ON isnull(oh.CCA_Territory_Name__c,oh.Case_Submission_Territory_Name__c) = th.TerritoryName AND th.TerritoryType='Invisalign'
WHERE Apttus_Config2__ProductId__c IN (SELECT id FROM SrcSFDC.product2 WHERE [description] like '%Whitening%') AND ISNULL(ol.Apttus_Config2__Quantity__c,0) > 0
	AND (ol.LastModifiedDate >= ISNULL(@LastSuccessfullDWTimestamp, '1900-01-01') OR @IsFullLoad=1)

	
	update DW.FactWhitening
		set	DWBatchID 				= 			@BatchID
		,	SAPOrderNumber			=			src.SAPOrderNumber
		,   PatientAge				=			src.PatientAge
		,	Product					=			src.Product
		,   DeliverableType			=			src.DeliverableType
		,   IncentiveCode			=			src.IncentiveCode
		,	AMRTerritoryCode		=			src.AMRTerritoryCode
		,   CCATerritoryCode		=			src.CCATerritoryCode
		,   ListPrice				=			src.ListPrice
		,   NetPrice				=			src.NetPrice
		,   DiscAmount				=			src.DiscAmount
		,   DiscPerc				=			src.DiscPerc
		,   SecRegion				=			src.SecRegion
		,   Quantity				=			src.Quantity
		,   DeliverableQty			=			src.DeliverableQty
		,	ModifiedDate			=			@CurrentDateTime
	from #TempFactWhitening src
	where DW.FactWhitening.SKOrder = src.SKOrder and DW.FactWhitening.MaterialNumber = src.MaterialNumber and DW.FactWhitening.LineNumber = src.LineNumber
	option (label = 'DW.LoadFactWhitening_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DW.LoadFactWhitening_Update', @rc = @RowsUpdated out

	insert into DW.FactWhitening (
			DWBatchID
		,	SKOrder
		,	SAPOrderNumber
		,	MaterialNumber
		,	LineNumber
		,	PatientAge
		,	Product
		,	DeliverableType
		,	IncentiveCode
		,	AMRTerritoryCode
		,	CCATerritoryCode
		,	ListPrice
		,	NetPrice
		,	DiscAmount
		,	DiscPerc
		,	SecRegion
		,	Quantity
		,	DeliverableQty
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	SKOrder
		,	SAPOrderNumber
		,	MaterialNumber
		,	LineNumber
		,	PatientAge
		,	Product
		,	DeliverableType
		,	IncentiveCode
		,	AMRTerritoryCode
		,	CCATerritoryCode
		,	ListPrice
		,	NetPrice
		,	DiscAmount
		,	DiscPerc
		,	SecRegion
		,	Quantity
		,	DeliverableQty
		,	@CurrentDateTime
		,	@CurrentDateTime
	from #TempFactWhitening src
	where not exists(select * from DW.FactWhitening dst where dst.SKOrder = src.SKOrder and dst.MaterialNumber = src.MaterialNumber and dst.LineNumber = src.LineNumber)
	option (label = 'DW.LoadFactWhitening_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadFactWhitening_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end