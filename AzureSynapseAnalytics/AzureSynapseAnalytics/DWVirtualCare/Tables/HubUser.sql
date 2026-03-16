CREATE TABLE [DWVirtualCare].[HubUser] (
    [SKUser]         INT            IDENTITY (1, 1) NOT NULL,
    [KeyUser]        NVARCHAR (100) NOT NULL,
    [KeyClinID]      NVARCHAR (100) NOT NULL,
    [SKContact]      INT            NOT NULL,
    [DWBatchID]      INT            NOT NULL,
    [InsertDateTime] DATETIME       NOT NULL,
    [RegionGroup]    VARCHAR (50)   NOT NULL
)
WITH (CLUSTERED INDEX([KeyUser], [KeyClinID]), DISTRIBUTION = REPLICATE);

