CREATE TABLE [DW].[DimUser] (
    [SKUser]               INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [LZBatchID]            INT            NOT NULL,
    [DWBatchID]            INT            NOT NULL,
    [DWHash]               CHAR (40)      NOT NULL,
    [KeyUser]              NCHAR (18)     NOT NULL,
    [SourceSystemCode]     VARCHAR (10)   NOT NULL,
    [UserName]             NVARCHAR (121) NOT NULL,
    [FirstName]            NVARCHAR (40)  NULL,
    [LastName]             NVARCHAR (80)  NOT NULL,
    [Alias]                NVARCHAR (8)   NULL,
    [AlignSalesRepID]      NVARCHAR (10)  NULL,
    [UserRoleName]         NVARCHAR (80)  NULL,
    [FederationIdentifier] NVARCHAR (64)  NULL,
    [CreatedDate]          DATE           NOT NULL,
    [IsActive]             BIT            NOT NULL,
    [ManagerID]            NVARCHAR (18)  NULL,
    [EmpHireDate]          DATE           NULL,
    [Address]              NVARCHAR (255) NULL,
    [City]                 NVARCHAR (80)  NULL,
    [State]                NVARCHAR (80)  NULL,
    [Country]              NVARCHAR (80)  NULL,
    [PostalCode]           NVARCHAR (20)  NULL,
    [Phone]                NVARCHAR (40)  NULL,
    CONSTRAINT [PK_DimUser] PRIMARY KEY NONCLUSTERED ([SKUser] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_DimUser_KeyUser] UNIQUE NONCLUSTERED ([KeyUser] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([SKUser]), DISTRIBUTION = REPLICATE);


GO
CREATE NONCLUSTERED INDEX [IX_DimUser_KeyUser]
    ON [DW].[DimUser]([KeyUser] ASC);

