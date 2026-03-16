CREATE TABLE [CTRL].[DWObject] (
    [DWObjectId]                 INT            NOT NULL,
    [SchemaName]                 VARCHAR (64)   NOT NULL,
    [ObjectName]                 VARCHAR (64)   NOT NULL,
	IsActive					 BIT			NOT NULL,
    [DependentLZObjectIDs]       VARCHAR (1000) NULL,
    [LastSuccessfullDWTimestamp] DATETIME2 (0)  NULL,
    [DateUpdated]                DATETIME2 (3)  NOT NULL,
	IsForceFullLoadOnNextRun	 BIT			NULL,
    [HubSPName]                  VARCHAR (64)   NULL,
    [SPName]                     VARCHAR (64)   NULL,
	SCDSPName					 varchar(64)	null,
    CONSTRAINT [PK_DWObject] PRIMARY KEY CLUSTERED ([DWObjectId] ASC),
    CONSTRAINT [UQ_DWObject] UNIQUE NONCLUSTERED ([SchemaName] ASC, [ObjectName] ASC)
);

