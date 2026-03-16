CREATE VIEW [SrcGoogleBigQuery].[GASessionHits] AS 

-- FOR US REGION
SELECT CONVERT(CHAR(40), '')	AS DWHash
, CONVERT(CHAR(40), '')	AS DWHashKey
, SH.Id
, 'US' as GARegion
, SH.FullVisitorId
, SH.VisitNumber
, SH.VisitId
, SH.VisitStartTime
, SH.VisitStartDateTime
, SH.VisitDate
, SH.DataSource
, SH.ExperimentId
, SH.ExperimentVariant
, SH.HitNumber
, SH.Hour
, SH.IsEntrance
, SH.IsExit
, SH.IsInteraction
, SH.Minute
, SH.Time
, SH.Referer
, SH.HasSocialSourceReferral
, SH.SocialInteractionAction
, SH.SocialNetwork
, SH.Type
, SH.PagePath
, SH.PagePathLevel1
, SH.PagePathLevel2
, SH.PagePathLevel3
, SH.PagePathLevel4
, SH.PageTitle
, SH.SearchKeyword
, SH.EventCategory
, SH.EventAction
, SH.EventLabel
, SH.EventValue
, [SH].[Index]
, [SH].[Value]
, S.Source
, S.AdContent
, S.Medium
, S.ChannelGrouping
, S.Campaign
, S.DeviceCategory
, S.Country
, SH.Hostname
, CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of US' END AS CountryFromHostName
FROM SrcGoogleBigQuery.GA_Sessionhits_US SH
INNER JOIN (SELECT DISTINCT Id, VisitNumber, Source, AdContent, Medium, ChannelGrouping, Campaign, DeviceCategory, Country FROM SrcGoogleBigQuery.GA_Sessions_US) S
ON SH.Id = S.Id AND SH.VisitNumber = S.VisitNumber
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM
ON SH.HostName = CM.HostName AND CM.GARegion = 'US' AND CM.IsValid = 1
WHERE SH.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') FROM [DWCONSDL].[GASessionHits] WHERE GARegion = 'US')

UNION ALL

-- FOR CANADA REGION
SELECT CONVERT(CHAR(40), '')	AS DWHash
, CONVERT(CHAR(40), '')	AS DWHashKey
, SH.Id
, 'CANADA' as GARegion
, SH.FullVisitorId
, SH.VisitNumber
, SH.VisitId
, SH.VisitStartTime
, SH.VisitStartDateTime
, SH.VisitDate
, SH.DataSource
, SH.ExperimentId
, SH.ExperimentVariant
, SH.HitNumber
, SH.Hour
, SH.IsEntrance
, SH.IsExit
, SH.IsInteraction
, SH.Minute
, SH.Time
, SH.Referer
, SH.HasSocialSourceReferral
, SH.SocialInteractionAction
, SH.SocialNetwork
, SH.Type
, SH.PagePath
, SH.PagePathLevel1
, SH.PagePathLevel2
, SH.PagePathLevel3
, SH.PagePathLevel4
, SH.PageTitle
, SH.SearchKeyword
, SH.EventCategory
, SH.EventAction
, SH.EventLabel
, SH.EventValue
, [SH].[Index]
, [SH].[Value]
, S.Source
, S.AdContent
, S.Medium
, S.ChannelGrouping
, S.Campaign
, S.DeviceCategory
, S.Country
, SH.Hostname
, CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of CANADA' END AS CountryFromHostName
FROM SrcGoogleBigQuery.GA_Sessionhits_CANADA SH
INNER JOIN (SELECT DISTINCT Id, VisitNumber, Source, AdContent, Medium, ChannelGrouping, Campaign, DeviceCategory, Country FROM SrcGoogleBigQuery.GA_Sessions_CANADA) S 
ON SH.Id = S.Id AND SH.VisitNumber = S.VisitNumber
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM
ON SH.HostName = CM.HostName AND CM.GARegion = 'CANADA' AND CM.IsValid = 1
WHERE SH.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') FROM [DWCONSDL].[GASessionHits] WHERE GARegion = 'CANADA')

UNION ALL

-- FOR EMEA REGION
SELECT  CONVERT(CHAR(40), '')	AS DWHash
, CONVERT(CHAR(40), '')	AS DWHashKey
, SH.Id
, 'EMEA' as GARegion
, SH.FullVisitorId
, SH.VisitNumber
, SH.VisitId
, SH.VisitStartTime
, SH.VisitStartDateTime
, SH.VisitDate
, SH.DataSource
, SH.ExperimentId
, SH.ExperimentVariant
, SH.HitNumber
, SH.Hour
, SH.IsEntrance
, SH.IsExit
, SH.IsInteraction
, SH.Minute
, SH.Time
, SH.Referer
, SH.HasSocialSourceReferral
, SH.SocialInteractionAction
, SH.SocialNetwork
, SH.Type
, SH.PagePath
, SH.PagePathLevel1
, SH.PagePathLevel2
, SH.PagePathLevel3
, SH.PagePathLevel4
, SH.PageTitle
, SH.SearchKeyword
, SH.EventCategory
, SH.EventAction
, SH.EventLabel
, SH.EventValue
, [SH].[Index]
, [SH].[Value]
, S.Source
, S.AdContent
, S.Medium
, S.ChannelGrouping
, S.Campaign
, S.DeviceCategory
, S.Country
, SH.Hostname
, CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of EMEA' END AS CountryFromHostName
FROM SrcGoogleBigQuery.GA_Sessionhits_EMEA SH
INNER JOIN (SELECT DISTINCT Id, VisitNumber, Source, AdContent, Medium, ChannelGrouping, Campaign, DeviceCategory, Country FROM SrcGoogleBigQuery.GA_Sessions_EMEA) S
ON SH.Id = S.Id AND SH.VisitNumber = S.VisitNumber
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM
ON SH.HostName = CM.HostName AND CM.GARegion = 'EMEA' AND CM.IsValid = 1
WHERE SH.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') FROM [DWCONSDL].[GASessionHits] WHERE GARegion = 'EMEA')

UNION ALL

-- FOR BRAZIL REGION
SELECT  CONVERT(CHAR(40), '')	AS DWHash
, CONVERT(CHAR(40), '')	AS DWHashKey
, SH.Id
, 'BRAZIL' as GARegion
, SH.FullVisitorId
, SH.VisitNumber
, SH.VisitId
, SH.VisitStartTime
, SH.VisitStartDateTime
, SH.VisitDate
, SH.DataSource
, SH.ExperimentId
, SH.ExperimentVariant
, SH.HitNumber
, SH.Hour
, SH.IsEntrance
, SH.IsExit
, SH.IsInteraction
, SH.Minute
, SH.Time
, SH.Referer
, SH.HasSocialSourceReferral
, SH.SocialInteractionAction
, SH.SocialNetwork
, SH.Type
, SH.PagePath
, SH.PagePathLevel1
, SH.PagePathLevel2
, SH.PagePathLevel3
, SH.PagePathLevel4
, SH.PageTitle
, SH.SearchKeyword
, SH.EventCategory
, SH.EventAction
, SH.EventLabel
, SH.EventValue
, [SH].[Index]
, [SH].[Value]
, S.Source
, S.AdContent
, S.Medium
, S.ChannelGrouping
, S.Campaign
, S.DeviceCategory
, S.Country
, SH.Hostname
, CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of BRAZIL' END AS CountryFromHostName
FROM SrcGoogleBigQuery.GA_Sessionhits_BRAZIL SH
INNER JOIN (SELECT DISTINCT Id, VisitNumber, Source, AdContent, Medium, ChannelGrouping, Campaign, DeviceCategory, Country FROM SrcGoogleBigQuery.GA_Sessions_BRAZIL) S 
ON SH.Id = S.Id AND SH.VisitNumber = S.VisitNumber
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM
ON SH.HostName = CM.HostName AND CM.GARegion = 'BRAZIL' AND CM.IsValid = 1
WHERE SH.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') FROM [DWCONSDL].[GASessionHits] WHERE GARegion = 'BRAZIL')

UNION ALL

-- FOR APAC REGION
SELECT  CONVERT(CHAR(40), '')	AS DWHash
, CONVERT(CHAR(40), '')	AS DWHashKey
, SH.Id
, 'APAC' as GARegion
, SH.FullVisitorId
, SH.VisitNumber
, SH.VisitId
, SH.VisitStartTime
, SH.VisitStartDateTime
, SH.VisitDate
, SH.DataSource
, SH.ExperimentId
, SH.ExperimentVariant
, SH.HitNumber
, SH.Hour
, SH.IsEntrance
, SH.IsExit
, SH.IsInteraction
, SH.Minute
, SH.Time
, SH.Referer
, SH.HasSocialSourceReferral
, SH.SocialInteractionAction
, SH.SocialNetwork
, SH.Type
, SH.PagePath
, SH.PagePathLevel1
, SH.PagePathLevel2
, SH.PagePathLevel3
, SH.PagePathLevel4
, SH.PageTitle
, SH.SearchKeyword
, SH.EventCategory
, SH.EventAction
, SH.EventLabel
, SH.EventValue
, [SH].[Index]
, [SH].[Value]
, S.Source
, S.AdContent
, S.Medium
, S.ChannelGrouping
, S.Campaign
, S.DeviceCategory
, S.Country
, SH.Hostname
, CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of APAC' END AS CountryFromHostName
FROM SrcGoogleBigQuery.GA_Sessionhits_APAC SH
INNER JOIN (SELECT DISTINCT Id, VisitNumber, Source, AdContent, Medium, ChannelGrouping, Campaign, DeviceCategory, Country FROM SrcGoogleBigQuery.GA_Sessions_APAC) S 
ON SH.Id = S.Id AND SH.VisitNumber = S.VisitNumber
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM
ON SH.HostName = CM.HostName AND CM.GARegion = 'APAC' AND CM.IsValid = 1
WHERE SH.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') FROM [DWCONSDL].[GASessionHits] WHERE GARegion = 'APAC')

UNION ALL

-- FOR LATAM REGION
SELECT  CONVERT(CHAR(40), '')	AS DWHash
, CONVERT(CHAR(40), '')	AS DWHashKey
, SH.Id
, 'LATAM' as GARegion
, SH.FullVisitorId
, SH.VisitNumber
, SH.VisitId
, SH.VisitStartTime
, SH.VisitStartDateTime
, SH.VisitDate
, SH.DataSource
, SH.ExperimentId
, SH.ExperimentVariant
, SH.HitNumber
, SH.Hour
, SH.IsEntrance
, SH.IsExit
, SH.IsInteraction
, SH.Minute
, SH.Time
, SH.Referer
, SH.HasSocialSourceReferral
, SH.SocialInteractionAction
, SH.SocialNetwork
, SH.Type
, SH.PagePath
, SH.PagePathLevel1
, SH.PagePathLevel2
, SH.PagePathLevel3
, SH.PagePathLevel4
, SH.PageTitle
, SH.SearchKeyword
, SH.EventCategory
, SH.EventAction
, SH.EventLabel
, SH.EventValue
, [SH].[Index]
, [SH].[Value]
, S.Source
, S.AdContent
, S.Medium
, S.ChannelGrouping
, S.Campaign
, S.DeviceCategory
, S.Country
, SH.Hostname
, CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of LATAM' END AS CountryFromHostName
FROM SrcGoogleBigQuery.GA_Sessionhits_LATAM SH
INNER JOIN (SELECT DISTINCT Id, VisitNumber, Source, AdContent, Medium, ChannelGrouping, Campaign, DeviceCategory, Country FROM SrcGoogleBigQuery.GA_Sessions_LATAM) S 
ON SH.Id = S.Id AND SH.VisitNumber = S.VisitNumber
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM
ON SH.HostName = CM.HostName AND CM.GARegion = 'LATAM' AND CM.IsValid = 1
WHERE SH.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') FROM [DWCONSDL].[GASessionHits] WHERE GARegion = 'LATAM');

