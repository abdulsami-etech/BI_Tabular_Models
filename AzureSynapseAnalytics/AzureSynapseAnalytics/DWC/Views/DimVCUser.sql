CREATE VIEW [DWC].[DimVCUser] as
SELECT
	u.SKUser,
	u.KeyUser,
	u.KeyClinID,
	u.SKContact,
	u.RegionGroup,
	s.ProductName,
    COALESCE(ua.IsActive,0) as IsActive,
    ua.InviteDate
FROM DWVirtualCare.HubUser u
LEFT JOIN DWVirtualCare.SatUser s on u.SKUser=s.SKUser
INNER JOIN dwglobal.GeographyRegion d on d.RegionGroup = u.RegionGroup and d.dataset='DWC'
LEFT JOIN (
    SELECT SKUser,
           MIN(CASE WHEN SKEvent = 1 THEN EventDate END) as InviteDate,
           MAX(CASE WHEN SKEvent = 4 THEN 1 ELSE 0 END)  as IsActive
    FROM DWVirtualCare.LinkUserContactEvent
    WHERE SKEvent IN (1, 4) /*Invite, Feedback received*/
    GROUP BY SKUser
) as ua on ua.SKUser=u.SKUser