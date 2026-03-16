CREATE VIEW [DWC].[DimVCEvent]
AS SELECT SKEvent
      ,EventName
  FROM DWVirtualCare.DictEvent;