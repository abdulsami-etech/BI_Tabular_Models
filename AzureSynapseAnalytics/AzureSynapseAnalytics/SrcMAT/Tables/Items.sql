CREATE TABLE [SrcMAT].[Items] (
    [LZBatchID]              INT           NOT NULL,
    [ADLSBatchID]            INT           NOT NULL,
    [ADLSTimestamp]          DATETIME2 (0) NOT NULL,
    [ItemID]                 INT           NOT NULL,
    [ItemGenericDescription] VARCHAR (100) NULL,
    [ItemCode]               VARCHAR (50)  NULL,
    [BuyFlag]                BIT           NULL,
    [FinishedProductFlag]    BIT           NULL,
    [ItemTypeID]             SMALLINT      NULL,
    [ItemCategoryID]         SMALLINT      NULL,
    [InvntItem]              BIT           NOT NULL,
    [ItemRoutingCategoryID]  INT           NOT NULL,
    [SerialTrackingIn]       BIT           NOT NULL,
    [SerialTrackingOut]      BIT           NOT NULL,
    [SerialEntry]            BIT           NOT NULL,
    [RowStatusID]            TINYINT       NOT NULL,
    [DateCreated]            DATETIME      NOT NULL,
    [CreatedByUserID]        INT           NOT NULL,
    [DateUpdated]            DATETIME      NULL,
    [UpdatedByUserID]        INT           NOT NULL,
    [SoftwareOptionsBitMask] SMALLINT      NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

