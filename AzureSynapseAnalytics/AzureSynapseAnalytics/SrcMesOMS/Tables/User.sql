CREATE TABLE [SrcMesOMS].[User] (
    [LZBatchID]        INT           NOT NULL,
    [ADLSBatchID]      INT           NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0) NOT NULL,
    [userID]           INT           NOT NULL,
    [loginName]        VARCHAR (50)  NOT NULL,
    [badgeNumber]      INT           NOT NULL,
    [name]             VARCHAR (150) NOT NULL,
    [roleID]           INT           NOT NULL,
    [picture]          VARCHAR (300) NULL,
    [email]            VARCHAR (150) NULL,
    [isActive]         BIT           NOT NULL,
    [modifiedBy]       INT           NULL,
    [modificationDate] DATETIME      NULL,
    [domainName]       VARCHAR (50)  NOT NULL,
    [buildingID]       INT           NOT NULL,
    [floorID]          INT           NOT NULL,
    [siteID]           INT           NOT NULL,
    [isDeleted]        BIT           NOT NULL,
    [creationDate]     DATETIME      NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

