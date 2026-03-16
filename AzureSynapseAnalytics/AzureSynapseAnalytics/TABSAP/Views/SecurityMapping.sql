CREATE VIEW [TABSAP].[SecurityMapping] AS SELECT  gi.GroupName , gi.Region,rcm .CompanyCode , ugm.Email  ,gi.Dataset 
FROM SrcSec.GroupInfo gi 
LEFT JOIN SrcSec.RegionCompcodeMapping  rcm ON gi.Region  = rcm .Region 
LEFT  JOIN SrcSec.User2Groupmapping  ugm on ugm.GroupName  = gi.GroupName
WHERE gi.GroupName NOT LIKE '%-NP';