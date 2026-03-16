CREATE TABLE [DWIRIS].[DimTask] (
    [SKTask]         INT            NOT NULL,
    [ADLSBatchID]    INT            NOT NULL,
    [ADLSTimestamp]  DATETIME2 (0)  NOT NULL,
    [LZBatchID]      INT            NOT NULL,
    [DWBatchID]      INT            NOT NULL,
    [DWHash]         CHAR (40)      NOT NULL,
    [KeyTask]        NCHAR (255)    NOT NULL,
    [CreatedDate]    DATETIME2 (7)  NULL,
    [WhatId]         NCHAR (18)     NULL,
    [PrimaryFocus]   NVARCHAR (255) NULL,
    [Subject]        NVARCHAR (255) NULL,
    [Status]         NVARCHAR (40)  NULL,
    [SKAccount]      INT            NULL,
    [SKUser]         INT            NULL,
    [CallCounter]    DECIMAL (18)   NULL,
    [RecordTypeName] NVARCHAR (80)  NULL,
    [IsDeleted]      VARCHAR (5)    NULL
)
WITH (CLUSTERED INDEX([SKTask]), DISTRIBUTION = HASH([SKTask]));

