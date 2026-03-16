CREATE TABLE [SrcLoyalty].[Behaviour] (
    [LZBatchID]               INT             NOT NULL,
    [ADLSBatchID]             INT             NOT NULL,
    [ADLSTimestamp]           DATETIME2 (0)   NOT NULL,
    [Id]                      INT             NOT NULL,
    [Behavior_Description__c] VARCHAR (200)   NOT NULL,
    [EffectiveDateFrom]       DATE            NOT NULL,
    [EffectiveDateTo]         DATE            NOT NULL,
    [LoyaltyProgramId]        NCHAR (18)      NOT NULL,
    [Points]                  NUMERIC (18, 2) NOT NULL,
    [RuleCriteria]            VARCHAR (100)   NOT NULL,
    [SystemModStamp]          DATETIME        NOT NULL,
    [LightFilter]             VARCHAR (200)   NULL,
    [Source]                  VARCHAR (50)    NOT NULL,
    [SourceTable]             VARCHAR (128)   NOT NULL,
    [PointsValue]             NVARCHAR (50)   NULL,
    [PointsColumn]            NVARCHAR (50)   NULL,
    [EventDateColumn]         VARCHAR (128)   NOT NULL,
    [BehaviorType]            VARCHAR (32)    NULL
)
WITH (HEAP, DISTRIBUTION = REPLICATE);

