CREATE VIEW [DWC].[FactOrderPromotion] AS select  
	   [SFDCOrderAdjustmentLineItemID]
	  ,[SKOrder]
	  ,[KeyOrder]
	  ,[IncentiveId]
	  ,[IncentiveCode]
	  ,[CurrencyCode]
	  ,[DiscountAmount]
	  ,[DiscPercent]
	  ,[CouponCode]
	  ,[SecRegion]
  FROM [DW].[FactOrderPromotion] o
  inner join dwglobal.GeographyRegion d on d.RegionGroup = o.SecRegion and d.dataset='DWC';