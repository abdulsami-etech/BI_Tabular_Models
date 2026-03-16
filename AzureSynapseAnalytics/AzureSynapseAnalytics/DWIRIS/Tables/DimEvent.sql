CREATE TABLE [DWIRIS].[DimEvent] (
    [SKEvent]        INT            NOT NULL,
    [ADLSBatchID]    INT            NOT NULL,
    [ADLSTimestamp]  DATETIME2 (0)  NOT NULL,
    [LZBatchID]      INT            NOT NULL,
    [DWBatchID]      INT            NOT NULL,
    [DWHash]         CHAR (40)      NOT NULL,
    [KeyEvent]       NCHAR (510)    NOT NULL,
    [CreatedDate]    DATETIME2 (7)  NULL,
    [WhatId]         NCHAR (36)     NULL,
    [PrimaryFocus]   NVARCHAR (510) NULL,
    [Subject]        NVARCHAR (510) NULL,
    [Status]         NVARCHAR (80)  NULL,
    [SKAccount]      INT            NULL,
    [SKUser]         INT            NULL,
    [CallCounter]    DECIMAL (18)   NULL,
    [RecordTypeName] NVARCHAR (160) NULL,
    [IsDeleted]      VARCHAR (10)   NULL
)
WITH (CLUSTERED INDEX([SKEvent]), DISTRIBUTION = HASH([SKEvent]));

