CREATE VIEW [TABIRIS].[DimCaseType]
AS SELECT [SKCaseType]
      ,[KeyCaseType]
      ,[SourceSystem]
      ,[CaseTypeGenericDescription]
      ,[CaseTypeCategory]
      ,[CaseTypeGroupID]
      ,[CaseTypeDisplayOrder]
  FROM [DWIRIS].[DimCaseType];