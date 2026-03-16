CREATE VIEW [TABTOPS].[FactLotAFABLeadTime]
AS SELECT 
       [DgnCompleteDateTime] as CompleteDateTime
      ,[DgnLotKey] as LotKey
      ,[SKPlant] 
      ,[SKCompleteDate]
      ,[SkCountry]
      ,[LeadTimeHour]
  FROM [DWTOPS].[FactLotAFABLeadTime];