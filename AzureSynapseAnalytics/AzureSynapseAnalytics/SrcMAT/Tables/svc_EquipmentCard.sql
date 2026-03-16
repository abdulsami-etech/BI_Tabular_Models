CREATE TABLE [SrcMAT].[svc_EquipmentCard] (
    [LZBatchID]               INT             NOT NULL,
    [ADLSBatchID]             INT             NOT NULL,
    [ADLSTimestamp]           DATETIME2 (0)   NOT NULL,
    [EquipmentCardID]         INT             NOT NULL,
    [SoldToBusinessPartnerID] INT             NOT NULL,
    [HolderBusinessPartnerID] INT             NOT NULL,
    [ItemID]                  INT             NOT NULL,
    [SerialIdentifier]        NVARCHAR (100)  NOT NULL,
    [Notes]                   NVARCHAR (2000) NOT NULL,
    [RowStatusID]             TINYINT         NOT NULL,
    [DateCreated]             DATETIME        NOT NULL,
    [CreatedByUserID]         INT             NOT NULL,
    [DateUpdated]             DATETIME        NOT NULL,
    [UpdatedByUserID]         INT             NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

