CREATE VIEW [TABSAP].[SecurityMappingOperation] AS 
SELECT 
  gi.GroupName, 
  gi.Region, 
  rcm.PlantCode, 
  gi.[PlantType], 
  ugm.Email, 
  gi.Dataset 
FROM 
  [SrcSec].[GroupInfoOperations] gi 
  LEFT JOIN [SrcSec].[RegionPlantcodeMapping] rcm ON gi.Region = rcm.Region 
  LEFT JOIN SrcSec.User2Groupmapping ugm on ugm.GroupName = gi.GroupName;
