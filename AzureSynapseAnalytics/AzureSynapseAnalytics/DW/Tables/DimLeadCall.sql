CREATE TABLE [DW].[DimLeadCall] (
    [SKLeadCall]           INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [LZBatchID]            INT            NOT NULL,
    [DWBatchID]            INT            NOT NULL,
    [DWHash]               CHAR (40)      NOT NULL,
    [KeyLeadCall]          NCHAR (18)     NOT NULL

    ,[CallConnected]                        NVARCHAR(5) NULL  
    ,[CreatedById]                          NCHAR(18) NULL
    ,[CreatedByUserName]                    NVARCHAR(121) NULL
    ,[CreatedDate]                          DATETIME2 NULL
    ,[CurrencyIsoCode]                      NVARCHAR(6) NULL
    ,[IsDeleted]                            NVARCHAR(5) NULL
    ,[LastModifiedById]                     NCHAR(18) NULL
    ,[LastModifiedByUserName]               NVARCHAR(121) NULL
    ,[Name]                                 NVARCHAR(160) NULL
    ,[OwnerId]                              NCHAR(18) NULL
    ,[OwnerUserName]                        NVARCHAR(121) NULL
    ,[RingAbandonedCall]                    NVARCHAR(5) NULL
    ,[RingAccountId]                        NCHAR(18) NULL
    ,[RingActivityDate]                     DATETIME2 NULL
    ,[RingCallConnected]                    NVARCHAR(5) NULL
    ,[RingCallDirection]                    NVARCHAR(510) NULL
    ,[RingCallDuationSec]                   DECIMAL(18,0) NULL
    ,[RingCallHourOfDayAgent]               DECIMAL(18,0) NULL
    ,[RingCallHourOfDayLocal]               DECIMAL(18,0) NULL
    ,[RingCallStatus]                       NVARCHAR(510) NULL
    ,[RingCallObject]                       NVARCHAR(510) NULL
    ,[RingCampaignId]                       NCHAR(18) NULL
    ,[RingContactId]                        NCHAR(18) NULL
    ,[RingLeadId]                           NCHAR(18) NULL
    ,[RingDescription]                      NVARCHAR(MAX) NULL
    ,[RingLocalPresence]                    NVARCHAR(5) NULL                  
    ,[RingStatus]                           NVARCHAR(510) NULL
    ,[SystemModstamp]                       DATETIME2 NULL
    ,[TimeOfDay]                            DECIMAL(18,2) NULL
    ,[LeadCountryCode]                      NVARCHAR(20) NULL
    ,[LeadCountry]                          NVARCHAR(160) NULL
    ,[SecRegion]                            VARCHAR (10)  NULL

    --CONSTRAINT [PK_DimLeadCall] PRIMARY KEY NONCLUSTERED ([SKLeadCall] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_DimLeadCall_KeyLeadCall] UNIQUE NONCLUSTERED ([KeyLeadCall] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([SKLeadCall]), DISTRIBUTION = HASH([SKLeadCall]));
