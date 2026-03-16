CREATE TABLE [SrcSFDC].[AssetRelationship] (
    [LZBatchID]               INT            NOT NULL,
    [ADLSBatchID]             INT            NOT NULL,
    [ADLSTimestamp]           DATETIME2 (0)  NOT NULL,
    [AssetId]                 NCHAR (18)     NOT NULL,
    [AssetRelationshipNumber] NVARCHAR (255) NULL,
    [CreatedById]             NCHAR (18)     NULL,
    [CreatedDate]             DATETIME2 (7)  NOT NULL,
    [CurrencyIsoCode]         NVARCHAR (3)   NOT NULL,
    [FromDate]                DATETIME2 (7)  NULL,
    [Id]                      NCHAR (18)     NOT NULL,
    [IsDeleted]               BIT            NOT NULL,
    [LastModifiedById]        NCHAR (18)     NULL,
    [LastModifiedDate]        DATETIME2 (7)  NOT NULL,
    [LastReferencedDate]      DATETIME2 (7)  NULL,
    [LastViewedDate]          DATETIME2 (7)  NULL,
    [RelatedAssetId]          NCHAR (18)     NOT NULL,
    [RelationshipType]        NVARCHAR (40)  NULL,
    [SystemModstamp]          DATETIME2 (7)  NOT NULL,
    [ToDate]                  DATETIME2 (7)  NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

