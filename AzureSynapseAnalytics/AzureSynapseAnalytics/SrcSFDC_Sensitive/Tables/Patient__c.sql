CREATE TABLE [SrcSFDC_Sensitive].[Patient__c] (
    [LZBatchID]         INT            NOT NULL,
    [ADLSBatchID]       INT            NOT NULL,
    [ADLSTimestamp]     DATETIME2 (0)  NOT NULL,
    Id                  CHAR (64)      NOT NULL,
    Patient_ID__c       CHAR (64)          NULL
)
WITH (CLUSTERED INDEX(Id), DISTRIBUTION = HASH(Id));