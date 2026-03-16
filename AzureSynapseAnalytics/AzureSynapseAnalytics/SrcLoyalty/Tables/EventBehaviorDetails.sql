CREATE TABLE [SrcLoyalty].[EventBehaviorDetails] (
    [LZBatchID]       INT             NOT NULL,
    [ADLSBatchID]     INT             NOT NULL,
    [ADLSTimestamp]   DATETIME2 (0)   NOT NULL,
    [EventBehaviorId] INT             NOT NULL,
    [EventTypeId]     INT             NOT NULL,
    [ClinId]          NVARCHAR (50)   NOT NULL,
    [EntityId]        NVARCHAR (50)   NOT NULL,
    [BehaviorId]      INT             NOT NULL,
    [LoyaltyPoints]   NUMERIC (18, 2) NOT NULL,
    [DateCreated]     DATETIME        NOT NULL,
    [DateUpdated]     DATETIME        NOT NULL,
    [BatchID]         INT             NOT NULL,
    [EventDate]       DATE            NULL
)
WITH (CLUSTERED INDEX([ClinId]), DISTRIBUTION = HASH([ClinId]));

