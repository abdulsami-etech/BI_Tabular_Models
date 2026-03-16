CREATE VIEW [DWC].[DimContactSCD]
AS select c.[SKContact], c.[KeyContact], c.[StartDateSCD], c.[EndDateSCD], c.[CertificationDate], c.[MailingCountryCode], c.[MailingCountry]
, c.[MailingCountryGroup], c.[MailingRegionPC], c.[MailingRegionGroup], c.[MailingGlobalRegion], c.[ProfessionalCategory], c.[AdvCurrentAdvantageLevel]
, c.[AdvCurrentAdvantageProgram], c.[AdvRegistrationStatus], c.TrainingCompletionDate, c.EMEASegmentation, c.ContactStatus, C.DoctorSegment
from [DW].[DimContactSCD]   c
inner join Custom.GeographyHierarchy g on c.MailingCountryCode = g.CountryCode
inner join dwglobal.GeographyRegion d on d.RegionGroup = g.SecRegion and d.dataset='DWC';