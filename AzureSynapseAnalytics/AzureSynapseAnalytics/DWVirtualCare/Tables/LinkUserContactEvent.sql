CREATE TABLE [DWVirtualCare].[LinkUserContactEvent] (
    [SKUser]         INT          NOT NULL,
    [SKContact]      INT          NOT NULL,
    [SKEvent]        INT          NOT NULL,
    [EventDate]      DATE         NOT NULL,
    [DWBatchID]      INT          NULL,
    [InsertDateTime] DATETIME     NULL,
    [RegionGroup]    VARCHAR (10) NULL,
    CONSTRAINT [PK_DWVirtualCareLinkUserContactEvent] PRIMARY KEY NONCLUSTERED ([SKContact] ASC, [SKUser] ASC, [SKEvent] ASC, [EventDate] ASC) NOT ENFORCED
)
WITH (HEAP, DISTRIBUTION = REPLICATE);


GO
CREATE CLUSTERED INDEX [IX_CL_DWVirtualCareLinkUserContactEvent]
    ON [DWVirtualCare].[LinkUserContactEvent]([SKContact] ASC, [SKUser] ASC, [SKEvent] ASC, [EventDate] ASC);

