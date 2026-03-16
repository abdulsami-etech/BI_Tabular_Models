CREATE VIEW [TABTOPS].[FactMedalliaRatings]
AS SELECT 
  b.[SKDate]                                                                    AS [SKResponseDate], 
  a.[align_all_doctor_global_region_enum]                                            AS [GlobalRegion], 
  a.[align_agentid]																AS [Tech/Agent_ID],
  a.[align_cscc_surveyunit_supervisor_text]                                        AS [SupervisorName],
  a.[align_cc_ordernum_text]													AS [OrderNumber],
  a.[align_doctorid_text]                                                            AS [DoctorID],
  c.CountryCode                                                                    As CountryCode, 
  c.Country                                                                        AS [Country], 
  a.[cc_initial_setup_rating_enum]                                                as [RatingNumber],
  case when a.[cc_initial_setup_rating_enum] >= 9 then 1 else 0 end                AS [IsPromoterCases] ,
  case when a.[cc_initial_setup_rating_enum] between 7 and 8 then 1 else 0 end    AS [IsNeutralCases],
  case when a.[cc_initial_setup_rating_enum] <= 6 then 1 else 0 end                AS [IsDetractorCases],
		a.survey_id_text as SurveyIdText,
		a.survey_type  as SurveyType,
		a.responsedate as ResponseDate,
		a.align_cs_osat_comment as CsOsatComment,
		a.aligntech_customer_support_ltr_comment_text as CustomerLtrComment,
		a.align_agentid as AgentID,
		a.align_all_doctor_global_region_enum as AllDoctorGlobalRegion,
		a.align_cc_accepted_cases_12_months_integer as AcceptedCases12Months,
		a.align_cs_agent_first_name as AgentFirstName,
		a.align_cscc_surveyunit_lead_text as SurveyUnitLead,
		a.align_cscc_surveyunit_supervisor_text as SurveyUnitSupervisor,
		a.align_doc_join_date as DOCJoinDate,
		a.align_rel_territorymgrname as TerritoryMgrName,
		a.align_volume_tier_enum as VolumeTier,
		a.cc_initial_setup_rating_enum as SetupRating


FROM [SrcMedallia].[MedalliaSurvey] as a
    INNER join [DW].[DimDate] as b on a.[responsedate]=b.[KeyDate]
    LEFT JOIN    (    SELECT a.Account_Number__c    as AccountNumber, 
                    a.ShippingCountryCode        As CountryCode, 
                    g.CountryName as Country 
                    from SrcSFDC.Account a 
                    inner join DW.DimCountry g on a.ShippingCountryCode = g.CountryCode
                    where a.Account_Number__c  is not null) C ON C.AccountNumber = A.[align_doctorid_text]    
        
WHERE 

    a.[align_perfect_score_alert_type] like 'Initial Setup'
    and a.[cc_initial_setup_rating_enum] is not null;