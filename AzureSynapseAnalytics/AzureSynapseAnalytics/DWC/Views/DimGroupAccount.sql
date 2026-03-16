CREATE VIEW [DWC].[DimGroupAccount] AS
SELECT 		ga.SKAccount
		,	ga.AccountNumber
		,	ga.DWBatchID
		,	ga.DWHash
		,	ga.SKDSOAccount
		,	ga.DSOAccountNumber
		,	ga.DSOAccountName
		,	ga.BDM
		,	ga.RM
		,	ga.SM
		,	ga.ASD
		,	ga.BDMTerritoryName
		,	ga.RMTerritoryName
		,	ga.SMTerritoryName
		,	ga.ASDTerritoryName
		,	ga.BDMConcat
		,	ga.RMConcat
		,	ga.SMConcat
		,	ga.ASDConcat
		,	ga.SKBDMUser
		,	ga.BDMUserId
		,	ga.SKRMUser
		,	ga.RMUserId
		,	ga.SKSMUser
		,	ga.SMUserId
		,	ga.SKASDUser
		,	ga.ASDUserId
		,	ga.BDMIdentifier
		,	ga.RMIdentifier
		,	ga.SMIdentifier
		,	ga.ASDIdentifier
		,	a.SecRegion
  FROM [DW].[DimGroupAccount] ga
  INNER JOIN [DW].[DimAccount] a ON ga.SKAccount = a.SKAccount
  INNER JOIN dwglobal.GeographyRegion d on d.RegionGroup = a.SecRegion and d.dataset='DWC';


