CREATE TABLE [SrcEUPRWEMEA].[scanreportsharing] (
    [LZBatchID]       INT           NOT NULL,
    [ADLSBatchID]     INT           NOT NULL,
    [ADLSTimestamp]   DATETIME2 (0) NOT NULL,
    [id]              BIGINT        NOT NULL,
    [companyid]       INT           NOT NULL,
    [doctorid]        INT           NOT NULL,
    [orderid]         INT           NOT NULL,
    [sharingtype]     INT           NOT NULL,
    [sharingdatetime] DATETIME      NOT NULL,
    [platform]        INT           NOT NULL
)
WITH (CLUSTERED INDEX([id]), DISTRIBUTION = HASH([id]));

