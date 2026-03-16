CREATE VIEW [DWC].[TPSKafkaMessage]
	AS
WITH  request as (
    SELECT dt, JSON_VALUE(t.[value], '$.Value') as requestId
    FROM DWAppLog.KafkaConfluent_TPRequest
        CROSS APPLY OPENJSON(MessageHeaders) t
    WHERE JSON_VALUE(t.[value], '$.Key') = 'requestId'
),
Response as (
    SELECT dt,MessageValue,JSON_VALUE(t.[value],'$.Value') as requestId
    from  DWAppLog.KafkaConfluent_TPStatus
    CROSS APPLY OPENJSON(MessageHeaders) t
    where JSON_VALUE(t.[value],'$.Key')='requestId'
),
SplunkAction as (
    SELECT action,ts,trace, COALESCE(JSON_VALUE(_data,'$.revisionId'),JSON_VALUE(_data,'$.revisionid')) as revisionID
    from DWAppLog.CCCloudLog_Splunk_MiscRecalc
    where action<>'Misc.recalculation.Calculate2MinFlow'
)
SELECT
    c.SKContact,
    c.ClinID,
    ss.SKOrder,
    ss.SAPOrderNumber,
    s.SKSession as SKSession,
    s.KeyTrace as SessionID,
    sa.action as SplunkActionName,
    sa.ts as SplunkActionTimestamp,
    req.dt as RequestTimestamp,
    req.requestId as RequestId,
    res.dt as StatusTimestamp,
    res.MessageValue as StatusMessage
from request req
LEFT JOIN Response res on req.requestId = res.requestId
LEFT JOIN SplunkAction sa on sa.revisionID=req.requestId
LEFT JOIN DWAppLog.HubSession s on s.KeyTrace=sa.trace
LEFT JOIN DWAppLog.SatSessionCCProCloud ss on ss.SKSession=s.SKSession
LEFT JOIN DWC.DimContact c on c.ClinID=SS.event_user;