CREATE TABLE [DW].[DimAccountSCD] (
    [SKAccount]            INT            NOT NULL,
    [KeyAccount]           NCHAR (18)     NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [LZBatchID]            INT            NOT NULL,
    [DWBatchID]            INT            NULL,
    [StartDateSCD]         DATE           NOT NULL,
    [EndDateSCD]           DATE           NOT NULL,
    [AccountStatus]        NVARCHAR (255) NULL,
    [ShippingCountryCode]  NVARCHAR (10)  NULL,
    [GroupAccounts]        NCHAR(18) NULL,
	[Type]                 NVARCHAR(40) NULL,
	[AccountSubType]       NVARCHAR(255) NULL,
	[CustomerGroup]        NVARCHAR(255) NULL,
	[AccountSegmentation]  NVARCHAR(510) NULL,
    [ShippingCountry]      VARCHAR (256)  NULL,
    [ShippingCountryGroup] VARCHAR (256)  NULL,
    [ShippingRegionPC]     VARCHAR (256)  NULL,
    [ShippingRegionGroup]  VARCHAR (256)  NULL,
    [ShippingGlobalRegion] VARCHAR (256)  NULL,
    CONSTRAINT [PK_DimAccountSCD] PRIMARY KEY NONCLUSTERED ([SKAccount] ASC, [StartDateSCD] ASC) NOT ENFORCED
)
WITH (HEAP, DISTRIBUTION = REPLICATE);

