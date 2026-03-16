CREATE VIEW DWAppLog.KafkaConfluent_TPStatus
AS
    SELECT
        Timestamp,
        TRY_CONVERT( datetime,dateadd(S, timestamp/1000, '1970-01-01') ) as dt,   
        Partition,
        Offset,
        MessageValue,
        MessageHeaders
    FROM SrcConfluentKafka.TPStatus