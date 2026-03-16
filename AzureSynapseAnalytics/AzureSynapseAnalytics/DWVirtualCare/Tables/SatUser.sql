CREATE TABLE [DWVirtualCare].[SatUser] (
    [SKUser]                         INT             NOT NULL,
    [ADLSBatchID]                    INT             NOT NULL,
    [ADLSTimestamp]                  DATETIME2 (0)   NOT NULL,
    [LZBatchID]                      INT             NOT NULL,
    [DWBatchID]                      INT             NOT NULL,
    [DWHash]                         CHAR (40)       NOT NULL,
    [ProductName]                    NVARCHAR(100)   NULL,
    [vip_patient_id]                 varchar(64)     NULL,
    [SKOrder]                        BIGINT          NULL
)
WITH (CLUSTERED INDEX(SKUser), DISTRIBUTION = HASH(SKUser));

