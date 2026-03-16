CREATE TABLE [DW].[HubTrainingEventTypes] (
    [SKTrainingEventType]       INT          	IDENTITY (1, 1) NOT NULL,
    [KeyTrainingEventType]      NCHAR (18)   					NOT NULL,
    [SourceSystemCode] 		    VARCHAR (10) 					NOT NULL,
    [DWBatchID]        		    INT          					NOT NULL,
    [InsertDateTime]   		    DATETIME     					NOT NULL,
    CONSTRAINT [PK_HubTrainingEventTypes] PRIMARY KEY NONCLUSTERED ([SKTrainingEventType] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_HubTrainingEventTypes_KeyTrainingEventType] UNIQUE NONCLUSTERED ([KeyTrainingEventType] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([KeyTrainingEventType]), DISTRIBUTION = REPLICATE);


