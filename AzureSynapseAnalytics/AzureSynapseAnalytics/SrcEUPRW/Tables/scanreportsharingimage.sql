CREATE TABLE [SrcEUPRW].[scanreportsharingimage] (
    [LZBatchID]           INT           NOT NULL,
    [ADLSBatchID]         INT           NOT NULL,
    [ADLSTimestamp]       DATETIME2 (0) NOT NULL,
    [id]                  BIGINT        NOT NULL,
    [imageid]             VARCHAR (128) NOT NULL,
    [imagetype]           INT           NOT NULL,
    [isShared]            BIGINT        NOT NULL,
    [scanreportsharingid] INT           NOT NULL
)
WITH (CLUSTERED INDEX([id]), DISTRIBUTION = HASH([id]));

