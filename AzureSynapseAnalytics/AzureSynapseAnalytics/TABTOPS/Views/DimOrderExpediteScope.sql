CREATE VIEW [TABTOPS].[DimOrderExpediteScope]
AS SELECT  
      [SKExpediteScope]
      ,[KeyExpediteScope] as ExpediteScope
FROM [DWTOPS].[DimExpediteScope];