CREATE VIEW [DWCaseMonitor].[CaseStateStatistics]
AS select 
a.skcasestatestatistic,
a.OperationName,
a.OperationType,
a.Deviation1,
a.Deviation2,
a.Deviation3,
a.SourceSystem
from dw.[CaseStateStatistics] a 
where a.operationName is not null;