CREATE TABLE [CTRL].[SourceSystemProperty] (
    [SourceSystem]  VARCHAR (32)   NOT NULL,
    [PropertyName]  VARCHAR (32)   NOT NULL,
    [PropertyValue] VARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_SourceSystemProperty] PRIMARY KEY CLUSTERED ([SourceSystem] ASC, [PropertyName] ASC)
);

