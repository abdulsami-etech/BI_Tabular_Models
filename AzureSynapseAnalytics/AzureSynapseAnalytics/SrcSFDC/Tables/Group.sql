CREATE TABLE [SrcSFDC].[Group] (
    [LZBatchID]              INT            NOT NULL,
    [ADLSBatchID]            INT            NOT NULL,
    [ADLSTimestamp]          DATETIME2 (0)  NOT NULL,
    [CreatedById]            NCHAR (18)     NULL,
    [CreatedDate]            DATETIME2 (7)  NOT NULL,
    [DeveloperName]          NVARCHAR (80)  NULL,
    [DoesIncludeBosses]      BIT            NULL,
    [DoesSendEmailToMembers] BIT            NULL,
    [Email]                  NVARCHAR (255) NULL,
    [Id]                     NCHAR (18)     NOT NULL,
    [LastModifiedById]       NCHAR (18)     NULL,
    [LastModifiedDate]       DATETIME2 (7)  NOT NULL,
    [Name]                   NVARCHAR (40)  NULL,
    [OwnerId]                NCHAR (18)     NOT NULL,
    [QueueRoutingConfigId]   NCHAR (18)     NULL,
    [RelatedId]              NCHAR (18)     NULL,
    [SystemModstamp]         DATETIME2 (7)  NOT NULL,
    [Type]                   NVARCHAR (40)  NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

