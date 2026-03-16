CREATE TABLE [DW].[DimContactSCD] (
    [SKContact]                  INT            NOT NULL,
    [KeyContact]                 NCHAR (18)     NOT NULL,
    [ADLSBatchID]                INT            NOT NULL,
    [ADLSTimestamp]              DATETIME2 (0)  NOT NULL,
    [LZBatchID]                  INT            NOT NULL,
    [DWBatchID]                  INT            NULL,
    [StartDateSCD]               DATE           NOT NULL,
    [EndDateSCD]                 DATE           NOT NULL,
    [CertificationDate]          DATE           NULL,
    [MailingCountryCode]         NVARCHAR (10)  NULL,
    [MailingCountry]             VARCHAR (256)  NULL,
    [MailingCountryGroup]        VARCHAR (256)  NULL,
    [MailingRegionPC]            VARCHAR (256)  NULL,
    [MailingRegionGroup]         VARCHAR (256)  NULL,
    [MailingGlobalRegion]        VARCHAR (256)  NULL,
    [ProfessionalCategory]       NVARCHAR (50)  NULL,
    [AdvCurrentAdvantageLevel]   NVARCHAR (255) NULL,
    [AdvCurrentAdvantageProgram] NVARCHAR (20)  NULL,
    [AdvRegistrationStatus]      NVARCHAR (255) NULL,
    [TrainingCompletionDate]     DATE           NULL,
	[EMEASegmentation]           NVARCHAR (50)  NULL,
	[ContactStatus]              NVARCHAR (50)  NULL,
	[DoctorSegment]              NVARCHAR (50)  NULL,
    CONSTRAINT [PK_DimContactSCD] PRIMARY KEY NONCLUSTERED ([SKContact] ASC, [StartDateSCD] ASC) NOT ENFORCED
)
WITH (HEAP, DISTRIBUTION = REPLICATE);

