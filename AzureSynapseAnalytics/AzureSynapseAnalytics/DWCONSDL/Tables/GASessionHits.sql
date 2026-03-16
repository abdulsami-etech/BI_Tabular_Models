CREATE TABLE [DWCONSDL].[GASessionHits] (
    [DWBatchID]               INT             NOT NULL,
    [DWHash]                  CHAR (40)       NOT NULL,
    [DWHashKey]               CHAR (40)       NOT NULL,
    [Id]                      NVARCHAR (50)   NOT NULL,
    [GARegion]                NVARCHAR (50)   NULL,
    [FullVisitorId]           NVARCHAR (30)   NOT NULL,
    [VisitNumber]             INT             NULL,
    [VisitId]                 BIGINT          NULL,
    [VisitStartTime]          BIGINT          NULL,
    [VisitStartDateTime]      DATETIME        NULL,
    [VisitDate]               DATETIME        NULL,
    [DataSource]              NVARCHAR (30)   NULL,
    [ExperimentId]            NVARCHAR (30)   NULL,
    [ExperimentVariant]       NVARCHAR (10)   NULL,
    [HitNumber]               INT             NULL,
    [Hour]                    INT             NULL,
    [IsEntrance]              BIT             NULL,
    [IsExit]                  BIT             NULL,
    [IsInteraction]           BIT             NULL,
    [Minute]                  INT             NULL,
    [Time]                    INT             NULL,
    [Referer]                 NVARCHAR (4000) NULL,
    [HasSocialSourceReferral] NVARCHAR (10)   NULL,
    [SocialInteractionAction] NVARCHAR (30)   NULL,
    [SocialNetwork]           NVARCHAR (30)   NULL,
    [Type]                    NVARCHAR (10)   NULL,
    [PagePath]                NVARCHAR (4000) NULL,
    [PagePathLevel1]          NVARCHAR (4000) NULL,
    [PagePathLevel2]          NVARCHAR (4000) NULL,
    [PagePathLevel3]          NVARCHAR (4000) NULL,
    [PagePathLevel4]          NVARCHAR (4000) NULL,
    [PageTitle]               NVARCHAR (2000) NULL,
    [SearchKeyword]           NVARCHAR (200)  NULL,
    [EventCategory]           NVARCHAR (50)   NULL,
    [EventAction]             NVARCHAR (200)  NULL,
    [EventLabel]              NVARCHAR (400)  NULL,
    [EventValue]              INT             NULL,
    [Index]                   INT             NULL,
    [Value]                   NVARCHAR (200)  NULL,
    [Source]                  NVARCHAR (250)  NULL,
    [AdContent]               NVARCHAR (4000) NULL,
    [Medium]                  NVARCHAR (50)   NULL,
    [ChannelGrouping]         NVARCHAR (50)   NULL,
    [Campaign]                NVARCHAR (400)  NULL,
    [DeviceCategory]          NVARCHAR (25)   NULL,
    [Country]                 NVARCHAR (50)   NULL,
    [Hostname]                NVARCHAR (100)  NULL,
    [CountryFromHostName]     NVARCHAR (200)  NULL,
    [CreatedDate]             DATETIME        NULL,
    [ModifiedDate]            DATETIME        NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([Id]));


GO
CREATE STATISTICS [STATS_DWCONSDL_GASessionHits_DWHash]
    ON [DWCONSDL].[GASessionHits]([DWHash]);


GO
CREATE STATISTICS [STATS_DWCONSDL_GASessionHits_DWHashKey]
    ON [DWCONSDL].[GASessionHits]([DWHashKey]);

