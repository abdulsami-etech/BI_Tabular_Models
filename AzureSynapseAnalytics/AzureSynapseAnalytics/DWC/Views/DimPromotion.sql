CREATE VIEW [DWC].[DimPromotion] AS select  
		 [IncentiveID]
		,[IncentiveNumber]
		,[IncentiveCode]
		,[IncentiveName]
		,[IncentiveGroup]
		,[SAPPricingCondition]
		,[PromotionStartDate]
		,[PromotionEndDate]
		,[PromotionRegion]
		,[PromotionLengthDays]
		,[PromotionLengthType]
		,[PromotionSubUseType]
		,[PromotionUseType]

  FROM [DW].[DimPromotion];