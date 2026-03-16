CREATE TABLE [SrcMAT].[svc_VirtualProduct] (
    [LZBatchID]         INT             NOT NULL,
    [ADLSBatchID]       INT             NOT NULL,
    [ADLSTimestamp]     DATETIME2 (0)   NOT NULL,
    [VirtualProductID]  INT             NOT NULL,
    [BusinessPartnerID] INT             NOT NULL,
    [ItemID]            INT             NOT NULL,
    [StartDate]         DATETIME        NULL,
    [ExpiryDate]        DATETIME        NULL,
    [SerialCode]        VARCHAR (12)    NOT NULL,
    [Notes]             NVARCHAR (2000) NOT NULL,
    [RowStatusID]       TINYINT         NOT NULL,
    [DateCreated]       DATETIME        NOT NULL,
    [CreatedByUserID]   INT             NOT NULL,
    [DateUpdated]       DATETIME        NOT NULL,
    [UpdatedByUserID]   INT             NOT NULL,
    [AutoRenewal]       BIT             NOT NULL
)
WITH (CLUSTERED INDEX([VirtualProductID]), DISTRIBUTION = HASH([VirtualProductID]));

