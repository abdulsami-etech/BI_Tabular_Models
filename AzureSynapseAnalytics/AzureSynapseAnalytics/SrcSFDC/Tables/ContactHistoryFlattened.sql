CREATE TABLE [SrcSFDC].[ContactHistoryFlattened] (
    [LZBatchID]                      INT            NOT NULL,
    [ADLSBatchID]                    INT            NULL,
    [ADLSTimestamp]                  DATETIME2 (0)  NULL,
    [ParentId]                       NCHAR (18)     NULL,
    [StartDate]                      DATE           NULL,
    [EndDate]                        DATE           NULL,
    [Certification_Date__c]          NVARCHAR (255) NULL,
    [MailingCountryCode]             NVARCHAR (255) NULL,
    [Professional_Category__c]       NVARCHAR (255) NULL,
    [CF_Training_Completion_Date__c] NVARCHAR (255) NULL,
    [EMEA_Segmentation__c]           NVARCHAR (255) NULL,
    [Contact_Status__c]              NVARCHAR (255) NULL,
    [Doctor_Segment__c]              NVARCHAR (255) NULL
)
WITH (CLUSTERED INDEX([ParentId]), DISTRIBUTION = HASH([ParentId]));

