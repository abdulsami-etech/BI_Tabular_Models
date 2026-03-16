CREATE VIEW [TABTOPS].[FactLotAFABCNLeadTime]
AS SELECT 
       [DgnCompleteDateTime] as CompleteDateTime
      ,[DgnLotKey] as LotKey
      ,[SKPlant] 
      ,[SKCompleteDate]
      ,[SkCountry]
      ,[LeadTimeHour]
  FROM [DWTOPS].[FactLotAFABCNLeadTime];
GO