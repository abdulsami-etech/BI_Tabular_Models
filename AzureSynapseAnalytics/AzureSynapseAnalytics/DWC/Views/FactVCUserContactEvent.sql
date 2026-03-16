CREATE VIEW [DWC].[FactVCUserContactEvent]
AS SELECT l.SKUser
      ,l.SKContact
      ,l.SKEvent
      ,l.EventDate
	  ,l.RegionGroup
FROM DWVirtualCare.LinkUserContactEvent l
inner join dwglobal.GeographyRegion d on d.RegionGroup = l.RegionGroup and d.dataset='DWC';