Create VIEW [TABSAP].[OperationsDimProfitCenter] AS 
SELECT 
  [Controlling Area] 
  --Replacing leading zeros to get profit center
  , 
  REPLACE(
    LTRIM(
      REPLACE([Profit Center], '0', ' ')
    ), 
    ' ', 
    '0'
  ) [Profit Center], 
  [Profit Center Text], 
  [Person Responsible], 
  [Profit center area], 
  [Segment for Segmental Reporting], 
  [Hedged/Unhedged], 
  [PROFIT_CENTER_KEY], 
  [BusinessSegmentSubgroup], 
  [BusinessLine], 
  [GlobalRegionsExecutive], 
  [GlobalRegionsExternal], 
  [GlobalRegionsManagement], 
  [GlobalRegionsManagementSubgroup], 
  [BusinessSegment], 
  [Markets], 
  [GlobalRegionsManufacturing] 
FROM 
  [TABSAP].[DimProfitCenter] 
  --Filtering out the data where valid to date lies in 99991231
WHERE 
  [Valid To Date] = '99991231';
