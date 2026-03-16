CREATE TABLE [CTRL].[LZObject] (
    [LZObjectID]                     INT            NOT NULL,
    [SourceSystem]                   VARCHAR (32)   NOT NULL,
    [IsActive]                       BIT            NOT NULL,
    [ObjectName]                     VARCHAR (128)  NOT NULL,
    [Destination]                    VARCHAR (64)   NOT NULL,
    [Status]                         VARCHAR (32)   NOT NULL,
    [StoreOption]                    VARCHAR (128)  NOT NULL,
    [DistributionOption]             VARCHAR (128)  NOT NULL,
    [SourceColumnDroppedAction]      VARCHAR (32)   NOT NULL,
    [PKColumns]                      VARCHAR (128)  NULL,
    [IsLoadAllColumns]               BIT            NOT NULL,
    [DateUpdated]                    DATETIME2 (3)  NOT NULL,
    [LastSuccessfullLZTimestamp]     DATETIME2 (0)  NULL,
    [SFDCFlattenedHistoryColumnList] VARCHAR (1000) NULL,
    CONSTRAINT [PK_LZObject] PRIMARY KEY CLUSTERED ([LZObjectID] ASC),
    CONSTRAINT [UQ_LZObject] UNIQUE NONCLUSTERED ([SourceSystem] ASC, [ObjectName] ASC, [Destination] ASC)
);

