CREATE TABLE [SrcMAT].[TransitionHeader] (
    [LZBatchID]          INT             NOT NULL,
    [ADLSBatchID]        INT             NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0)   NOT NULL,
    [TransitionHeaderID] INT             NOT NULL,
    [BusinessPartnerID]  INT             NULL,
    [DirectionOut]       INT             NULL,
    [ArrivalDate]        DATETIME        NULL,
    [AddressID]          INT             NULL,
    [TrackingNumber]     NVARCHAR (100)  NULL,
    [Notes]              NVARCHAR (4000) NULL,
    [RowStatusID]        INT             NULL,
    [DateCreated]        DATETIME        NULL,
    [DateUpdated]        DATETIME        NULL,
    [ShippingCompany]    INT             NULL
)
WITH (CLUSTERED INDEX([TransitionHeaderID]), DISTRIBUTION = HASH([TransitionHeaderID]));

