CREATE VIEW [DWSFMC].[Standard_Tracking_Complaints]
AS SELECT
    ClientID,

    SendID,

    SubscriberKey,

    EmailAddress,

    SubscriberID,

    ListID,

    EventDate,

    EventType,

    BatchID,

    TriggeredSendExternalKey,

    Domain

FROM [SrcSFMC].[Standard_Tracking_Complaints];