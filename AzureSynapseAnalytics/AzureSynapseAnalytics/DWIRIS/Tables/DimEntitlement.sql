CREATE TABLE [DWIRIS].[DimEntitlement] (
    [SKEntitlement]        INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [LZBatchID]            INT            NOT NULL,
    [DWBatchID]            INT            NOT NULL,
    [DWHash]               CHAR (40)      NOT NULL,
    [KeyEntitlement]       CHAR (40)      NOT NULL,
    [SourceSystem]         CHAR (40)      NOT NULL,
    [AccountID]            NCHAR (50)     NULL,
    [SKAccount]            INT            NOT NULL,
    [AssetID]              NCHAR (50)     NULL,
    [SKASset]              INT            NOT NULL,
    [ContractLineItemID]   NCHAR (50)     NULL,
    [CreatedDate]          DATETIME2 (7)  NULL,
    [CreatedByID]          NCHAR (50)     NULL,
    [SKUserCreatedBy]      INT            NULL,
    [EndDate]              DATETIME2 (7)  NULL,
    [LastModifiedDate]     DATETIME2 (7)  NULL,
    [LastModifiedByID]     NCHAR (50)     NULL,
    [SKUserLastModifiedBy] INT            NULL,
    [Name]                 NVARCHAR (300) NULL,
    [ServiceContractID]    NCHAR (50)     NULL,
    [StartDate]            DATETIME2 (7)  NULL,
    [Status]               NCHAR (300)    NULL,
    [Type]                 NCHAR (300)    NULL
)
WITH (CLUSTERED INDEX([SKEntitlement]), DISTRIBUTION = REPLICATE);

