CREATE VIEW [DWC].[DimOrderTreatmentOption] AS
SELECT [TreatmentOptionKey]
      ,[SAPTreatmentOption]
      ,[TreatmentOption]
      ,[SortOrder]
      ,[ProductHierarchy]
      ,[TreatmentOptionHighLevel]
      ,[TreatmentOptionReportingLevel]
  FROM [SrcSAPFile].[TreatmentOption];