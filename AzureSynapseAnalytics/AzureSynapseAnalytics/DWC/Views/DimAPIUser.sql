CREATE VIEW DWC.DimAPIUser
AS
SELECT
    h.SKAPIUser,
    h.KeyAPIUser,
    s.SKContact,
    s.clin_id as ClinId,
    s.lead_id as LeadId,
    g.Country as MailingCountry,
    s.remote_care_invite_status as InviteStatus,
    s.remote_care_accept_terms as TermsStatus,
    s.created_date as CreatedDate,
    s.updated_date as UpdatedDate,
    s.is_app_user as IsAppUser,
    s.is_demo as IsDemo,
    s.user_type as UserType,
    s.InitialUserType,
    s.ConvertedToProspect,
    s.ConvertedToPatient,
    s.SKGeography,
    g.RegionGroup
FROM DWMyInvisalignApp.HubAPIUser h
JOIN DWMyInvisalignApp.SatAPIUser s on s.SKAPIUser=h.SKAPIUser
LEFT JOIN [Custom].GeographyHierarchy g on g.SKGeography= s.SKGeography
