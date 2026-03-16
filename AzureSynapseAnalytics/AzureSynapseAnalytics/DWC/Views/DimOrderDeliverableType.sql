CREATE VIEW [DWC].[DimOrderDeliverableType] AS
SELECT [DeliverableTypeKey]
      ,[SAPDeliverableType]
      ,[TreatmentCategory]
      ,[DeliverableTypeName]
      ,[SortOrder]
      ,[SAPOrderType]
      ,[IncludeforNASalesRevenue]
      ,[IncludeforNATotalCaseCounts]
      ,[IncludeForNADetailCaseCounts]
      ,[ProductHierarchy]
      ,[AdditionalAlignerIncluded]
      ,[MaterialNumber]
  FROM [SrcSAPFile].[DeliverableType];