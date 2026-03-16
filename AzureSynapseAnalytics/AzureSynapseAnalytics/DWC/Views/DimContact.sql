CREATE VIEW [DWC].[DimContact] AS select c.[SKContact],  c.[KeyContact], c.[PrimarySKAccount], c.[PrimaryAccountID], c.[PrimaryAccountNumber], c.[ContactNumber], c.[OwnerID]
, c.[ContactName], c.[RecordType], c.[ContactType], c.[LineofBusiness], c.[Salutation], c.[ContactFirstName], c.[ContactLastName]
, c.[ProfessionalCategory], c.[Status], c.[StatusReason], c.[LeadSource], c.[Phone], c.[Mobile], c.[Fax], c.[OtherPhone], c.[Email]
, c.[EmailOptout], c.[DoNotCall], c.[FaxOptOut], c.[MailOptOut], c.[MailingStreet1], c.[MailingStreet2], c.[MailingStreet3], c.[MailingCity]
, c.[MailingState], c.[MailingPostalCode], c.[MailingCountry], c.[MailingCountryCode], c.[MailingCountryGroup], c.[MailingRegionPC]
, c.[MailingRegionGroup], c.[MailingGlobalRegion], c.[AlumniStateCode], c.[AlumniUniversity], c.[CEHours], c.[CertificationDate]
, c.[CertificationLocation], c.[ClinID], c.[Gender], c.[GraduationYear], c.[ReactivationDate], c.[ProductEligibility], c.[TimeZone]
, c.[CreatedDate], c.[ModifiedDate], c.[TeenProviderFlag], c.[AdvCurrentAdvantageProgram], c.[AdvCurrentAdvantageLevel], c.[AdvCurrentAdvantagePoints]
, c.[AdvAdditionalPointsForNextLevel], c.[AdvRegistrationStatus], c.[AdvCumulativeTier], c.[ClincheckLab], c.[IOScanEnabledDate]
, c.[EPTOptIn], c.[iTeroFusionContractDate], c.[PrivatePracticeClinID], c.[TPSTermsCondition], c.[ProfileCreationDate], c.[MATContactID]
, c.[SecRegion], c.[EMEASEgmentation], c.[AcceptedPrograms]
from  [DW].[DimContact]  c
INNER JOIN dwglobal.GeographyRegion d on d.RegionGroup = c.SecRegion and d.dataset='DWC';