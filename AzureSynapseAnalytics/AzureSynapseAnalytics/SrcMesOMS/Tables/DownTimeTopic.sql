CREATE TABLE [SrcMesOMS].[DownTimeTopic] (
    [LZBatchID]              INT           NOT NULL,
    [ADLSBatchID]            INT           NOT NULL,
    [ADLSTimestamp]          DATETIME2 (0) NOT NULL,
    [downTimeTopicID]        INT           NOT NULL,
    [downTimeTopicName]      VARCHAR (200) NOT NULL,
    [isSeenByTeamLead]       BIT           NOT NULL,
    [isSeenByTechnician]     BIT           NOT NULL,
    [isSeenByQA]             BIT           NOT NULL,
    [isSeenByTrainer]        BIT           NOT NULL,
    [isSeenByClinical]       BIT           NOT NULL,
    [isSeenBySupervisor]     BIT           NOT NULL,
    [valueAdded]             BIT           NOT NULL,
    [downTimeSubCategoryID]  INT           NOT NULL,
    [isSeenByEngineer]       BIT           NOT NULL,
    [isSeenByProcessAnalyst] BIT           NOT NULL,
    [creationDate]           DATETIME      NOT NULL,
    [modificationDate]       DATETIME      NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

