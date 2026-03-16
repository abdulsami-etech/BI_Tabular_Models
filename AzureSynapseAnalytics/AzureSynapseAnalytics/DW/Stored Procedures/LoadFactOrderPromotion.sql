CREATE PROC [DW].[LoadFactOrderPromotion] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@IsFullLoad		bit = 0

	set @IsFullLoad = isnull(@IsForceFullLoad, 0)

	if object_id('DW.Temp_FactOrderPromotion','U') is not null
		drop table DW.Temp_FactOrderPromotion

	CREATE TABLE [DW].[Temp_FactOrderPromotion]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[DWBatchID] [int] NOT NULL,
	[DWHash] [char](40) NULL,
	[SFDCOrderAdjustmentLineItemID] [nchar](18) NOT NULL,
	[SKPromotion] [bigint] NOT NULL,
	[SKOrder] [bigint] NOT NULL,
	[KeyOrder] [nvarchar](255) NULL,
	[IncentiveId] [nchar](18) NULL,
	[IncentiveCode] [nvarchar](255) NULL,
	[CurrencyCode] [nvarchar](3) NOT NULL,
	[DiscountAmount] [decimal](18, 2) NULL,
	[DiscPercent] [decimal](18, 2) NULL,
	[CouponCode] [nvarchar](6) NULL,
	[SecRegion] [varchar](10) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
	
)
ALTER TABLE [DW].[Temp_FactOrderPromotion] ADD CONSTRAINT PK_Temp_FactOrderPromotion PRIMARY KEY NONCLUSTERED ([SKPromotion]) NOT ENFORCED

	INSERT INTO [DW].[Temp_FactOrderPromotion]
	(
	   [ADLSBatchID]
      ,[ADLSTimestamp]
      ,[LZBatchID]
      ,[DWBatchID]
	  ,[DWHash]
	  ,[SFDCOrderAdjustmentLineItemID]
	  ,[SKPromotion]
	  ,[SKOrder]
	  ,[KeyOrder]
	  ,[IncentiveId]
	  ,[IncentiveCode]
	  ,[CurrencyCode]
	  ,[DiscountAmount]
	  ,[DiscPercent]
	  ,[CouponCode]
	  ,[SecRegion]
	  )
	select	
					oh.ADLSBatchID								as ADLSBatchID
			  ,		oh.ADLSTimestamp								as ADLSTimestamp
			  ,		oh.LZBatchID									as LZBatchID
			  ,     @BatchID									as DWBatchID
			  ,		convert(char(40), '')						as DWHash	
			  ,		convert(nvarchar(18), opromo.Id)			as SFDCOrderAdjustmentLineItemID
			  ,		ho.SKPromotion								as SKPromotion
			  ,		hor.SKOrder									as SKOrder
			  ,		convert(bigint, oh.SAP_Order_ID__c)			as KeyOrder
			  ,		convert(nvarchar(18), isnull(opromo.Apttus_Config2__IncentiveId__c, N'Unknown Promotion')) 	as IncentiveId
			  ,		opromo.Apttus_Config2__IncentiveCode__c							as IncentiveCode
			  ,		convert(char(3), opromo.CurrencyIsoCode)						as CurrencyCode
			  ,		convert(decimal(20, 5), opromo.Discount_Amount__c)				as DiscountAmount
			  ,		convert(decimal(20, 5), opromo.Discount_Percent__c)				as DiscPercent
			  ,		convert(nvarchar(12),opromo.Apttus_Config2__CouponCode__c)		as CouponCode
			  ,		DimReg.SecRegion												as SecRegion
from SrcSFDC.[Apttus_Config2__Order__c] oh
inner join DW.HubPromotion ho on ho.KeyPromotion = oh.id
inner join DW.HubOrder hor on hor.KeyOrder = try_convert(bigint, oh.SAP_Order_ID__c)
left join DW.HubAccount hubAccTL on hubAccTL.KeyAccount = oh.Treatment_Location__c
left join DW.DimAccount DimReg on DimReg.SKAccount = hubAccTL.SKAccount 
inner join SrcSFDC.Apttus_Config2__OrderLineItem__c olAl on oh.id = olAl.Apttus_Config2__OrderId__c
															and olAL.Apttus_Config2__ChargeType__c <> 'Standard Price' -- Aligner
															and olAl.Deliverable_Type__c <> 'AUTOFULFILLMENT'      
															and olAl.Quote_Order_Flag__c = 'Order'
															and olal.Treatment_Option__c <> 'TreatOpt'
inner join SrcSFDC.Apttus_Config2__OrderAdjustmentLineItem__c opromo on olal.id = opromo.Apttus_Config2__LineItemId__c 
where 
oh.Send_To_SAP_Type__c is not null and 
oh.SAP_Order_ID__c not like '%[^0-9]%' --getting only ones which can be converted to bigint
and opromo.CurrencyIsoCode is not null
and opromo.Discount_Amount__c is not null
	and (oh.ADLSTimestamp >= isnull(@LastSuccessfullDWTimestamp, '1900-01-01') or @IsFullLoad=1)
	


	--update HASH 
	update DW.Temp_FactOrderPromotion set DWHash=
		convert(char(40),
			hashbytes('SHA1',
				isnull(convert(nvarchar, SFDCOrderAdjustmentLineItemID), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKPromotion), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKOrder), N'N/A')
				+ N'|' + isnull(convert(nvarchar, KeyOrder), N'N/A')
				+ N'|' + isnull(convert(nvarchar, IncentiveId), N'N/A')
				+ N'|' + isnull(convert(nvarchar, IncentiveCode), N'N/A')
				+ N'|' + isnull(convert(nvarchar, CurrencyCode), N'N/A')
				+ N'|' + isnull(convert(nvarchar, DiscountAmount), N'N/A')
				+ N'|' + isnull(convert(nvarchar, DiscPercent), N'N/A')
				+ N'|' + isnull(convert(nvarchar, CouponCode), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SecRegion), N'N/A')
				)
			,2)
	if @IsFullLoad = 0
	begin
	update DW.FactOrderPromotion
		set	[ADLSBatchID] = src.[ADLSBatchID]
      ,[ADLSTimestamp] = src.[ADLSTimestamp]
      ,[LZBatchID]	= src.[ADLSBatchID]
      ,[DWBatchID]	= src.[DWBatchID]
      ,[DWHash]	= src.[DWHash]
      ,[SFDCOrderAdjustmentLineItemID]=src.[SFDCOrderAdjustmentLineItemID]
	  ,[SKOrder]=src.[SKOrder]
	  ,[KeyOrder]=src.[KeyOrder]
	  ,[IncentiveId]=src.[IncentiveId]
	  ,[IncentiveCode]=src.[IncentiveCode]
	  ,[CurrencyCode]=src.[CurrencyCode]
	  ,[DiscountAmount]=src.[DiscountAmount]
	  ,[DiscPercent]=src.[DiscPercent]
	  ,[CouponCode]=src.[CouponCode]
	  ,[SecRegion]=src.[SecRegion]
	  from DW.Temp_FactOrderPromotion src
		where DW.FactOrderPromotion.SKPromotion = src.SKPromotion 
			and DW.FactOrderPromotion.DWHash != src.DWHash
		option (label = 'DW.LoadFactOrderPromotion_Update');

		exec CTRL.GetLastRowCount @Label = 'DW.LoadFactOrderPromotion_Update', @rc = @RowsUpdated out

	insert into DW.FactOrderPromotion (
	  [ADLSBatchID]
	  ,[ADLSTimestamp]
	  ,[LZBatchID]
	  ,[DWBatchID]
	  ,[DWHash]
	  ,[SFDCOrderAdjustmentLineItemID]
	  ,[SKPromotion]
	  ,[SKOrder]
	  ,[KeyOrder]
	  ,[IncentiveId]
	  ,[IncentiveCode]
	  ,[CurrencyCode]
	  ,[DiscountAmount]
	  ,[DiscPercent]
	  ,[CouponCode]
	  ,[SecRegion]
	  )
		select	 
	  [ADLSBatchID]
	  ,[ADLSTimestamp]
	  ,[LZBatchID]
	  ,[DWBatchID]
	  ,[DWHash]
	  ,[SFDCOrderAdjustmentLineItemID]
	  ,[SKPromotion]
	  ,[SKOrder]
	  ,[KeyOrder]
	  ,[IncentiveId]
	  ,[IncentiveCode]
	  ,[CurrencyCode]
	  ,[DiscountAmount]
	  ,[DiscPercent]
	  ,[CouponCode]
	  ,[SecRegion]
		from DW.Temp_FactOrderPromotion src
		where not exists (select dst.SKPromotion from DW.FactOrderPromotion dst where dst.SKPromotion = src.SKPromotion )
		option (label = 'DW.LoadFactOrderPromotion_Insert');

		exec CTRL.GetLastRowCount @Label = 'DW.LoadFactOrderPromotion_Insert', @rc = @RowsInserted out

		if object_id ('DW.Temp_FactOrderPromotion', 'U') is not null
		drop table DW.Temp_FactOrderPromotion
	end
	else
	begin --full load
		if object_id ('DW.FactOrderPromotionPrevious', 'U') is not null
			drop table DW.FactOrderPromotionPrevious

		rename object DW.FactOrderPromotion to FactOrderPromotionPrevious
		rename object DW.Temp_FactOrderPromotion to FactOrderPromotion

		if object_id ('DW.FactOrderPromotionPrevious', 'U') is not null
		drop table DW.FactOrderPromotionPrevious
		rename object DW.PK_Temp_FactOrderPromotion to PK_FactOrderPromotion
		
		select @RowsInserted = count(*)
		from DW.FactOrderPromotion

	end

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end


