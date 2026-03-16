CREATE TABLE [SrcLoyalty].[EventType] (
    [LZBatchID]             INT            NOT NULL,
    [ADLSBatchID]           INT            NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0)  NOT NULL,
    [EventTypeId]           INT            NOT NULL,
    [IsActive]              BIT            NOT NULL,
    [EventTypeName]         VARCHAR (128)  NOT NULL,
    [SourceSystem]          VARCHAR (32)   NOT NULL,
    [ObjectName]            VARCHAR (50)   NOT NULL,
    [APIObjectName]         VARCHAR (128)  NOT NULL,
    [ADWBatchColumns]       VARCHAR (8000) NULL,
    [ADWBatchDefaultFilter] VARCHAR (8000) NULL
)
WITH (HEAP, DISTRIBUTION = REPLICATE);

