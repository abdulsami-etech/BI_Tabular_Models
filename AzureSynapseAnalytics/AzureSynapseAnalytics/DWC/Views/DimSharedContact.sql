CREATE VIEW [DWC].[DimSharedContact] AS
SELECT [SKAccount]
      ,[KeyAccount]
      ,[DWHash]
      ,[AccountNumber]
      ,[KeyContact]
      ,[SKContact]
      ,[LastModifiedDate]
      ,[SecRegion]
  FROM [DW].[DimSharedContact] sc
INNER JOIN dwglobal.GeographyRegion d on d.RegionGroup = sc.SecRegion and d.dataset='DWC';