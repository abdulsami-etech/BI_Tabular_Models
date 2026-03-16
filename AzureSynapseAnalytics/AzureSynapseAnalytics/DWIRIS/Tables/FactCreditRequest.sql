CREATE TABLE [DWIRIS].[FactCreditRequest] (
    [SKSalesContract]  INT           NOT NULL,
    [ADLSBatchID]      INT           NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0) NOT NULL,
    [LZBatchID]        INT           NOT NULL,
    [DWBatchID]        INT           NOT NULL,
    [DWHash]           CHAR (40)     NULL,
    [KeySalesContract] NCHAR (18)    NOT NULL,
    [SKAccount]        INT           NOT NULL,
    [SKTeam]           INT           NOT NULL,
    [SKUser]           INT           NOT NULL,
    [CreatedDate]      DATETIME2 (7) NOT NULL,
    [CreatedDateKey]   INT           NULL,
    [ClosedDate]       DATETIME2 (7) NULL,
    [ClosedDateKey]    INT           NULL,
    [ProcessedDate]    DATETIME      NULL,
    [ProcessedDateKey] INT           NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([SKSalesContract]));

