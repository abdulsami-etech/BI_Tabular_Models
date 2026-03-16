CREATE VIEW [DWMedallia].[MedalliaSurvey]
AS SELECT a.[LZBatchID]
      ,a.[ADLSBatchID]
      ,a.[ADLSTimestamp]
      ,a.[align_doctorid_text]
      ,a.[survey_id_text]
      ,a.[survey_type]
      ,a.[responsedate]
      ,a.[aligntech_itero_satisfaction_comment_comment] as iTero_Satisfaction_Comment
      ,a.[comments]
      ,a.[align_record_type]
      ,a.[align_cs_osat_comment]
      ,a.[aligntech_itero_likelihood_to_recommend_sc11]  as iTero_LTR
      ,a.[aligntech_relationship_likelihood_to_continue_sc10]as Likelihood_to_Continue
      ,a.[aligntech_relationship_likelihood_to_recommend_sc10] as Likelihood_to_Recommend
      ,a.[aligntech_customer_support_multiling_oe_text]  as Customer_Support_Final_Comment_Translated
      ,a.[aligntech_relationship_additional_kpi_feedback_text]
      ,a.[aligntech_customer_support_ltr_comment_text] as Customer_Support_Satisfaction_Comment
      ,a.[alert_date_closed]
      ,a.[alert_date_created]
      ,a.[alert_date_resolved]
      ,a.[alert_date_status_changed]
      ,a.[alert_desc]
      ,a.[alert_ever_escalated]
      ,a.[alert_ever_escalated2]
      ,a.[alert_ever_overdue]
      ,a.[alert_num_reopened]
      ,a.[alert_resolution_time_hours]
      ,a.[alert_status]
      ,a.[alert_status_code]
      ,a.[alert_triggered]
      ,a.[alert_type]
      ,a.[align_agentid]
      ,a.[align_alert_emailtemplates_perfectten_agentrep_text]
      ,a.[align_alert_resolution_time]
      ,a.[align_alert_type]
      ,a.[align_all_doctor_global_region_enum]
      ,a.[align_case_closed_timestamp]
      ,a.[align_case_opened_timestamp]
      ,a.[align_cases_six_months_integer]
      ,a.[align_cc_accepted_cases_12_months_integer]
      ,a.[align_cc_action_enum]
      ,a.[align_cc_alert_email]
      ,a.[align_cc_alert_escalation_email]
      ,a.[align_cc_casemanagement_resolutioncontact_text]
      ,a.[align_cc_escalated_alert_country_code]
      ,a.[align_cc_id_text]
      ,a.[align_cc_new_alert_country_code]
      ,a.[align_cc_ordernum_text]
      ,a.[align_cc_product_clincheck_submitted_for_auto]
      ,a.[align_cc_product_enum]
      ,a.[align_cc_version]
      ,a.[align_cs_agent_first_name]
      ,a.[align_cs_interaction_date]
      ,a.[align_cs_ticket_type]
      ,a.[align_cscc_surveyunit_lead_text]
      ,a.[align_cscc_surveyunit_supervisor_text]
      ,a.[align_date_last_case_date]
      ,a.[align_doc_join_date]
      ,a.[align_doctor_volume]
      ,a.[align_escalated_relationship_alert_emails]
      ,a.[align_new_relationship_alert_emails]
      ,a.[align_open_alert_status_cs_enum]
      ,a.[align_open_alert_status_enum]
      ,a.[align_overdue_relationship_alert_emails]
      ,a.[align_perfect_score_alert_type]
      ,a.[align_rel_territorymgrname]
      ,a.[align_rl_closedloop_followupowner_text]
      ,a.[align_rl_surveyunit_regionalmanager_text]
      ,a.[align_rl_surveyunit_rep_text]
      ,a.[align_symptom_code]
      ,a.[align_tfm_doctor_org_filter]
      ,a.[align_total_cc_orders_integer]
      ,a.[align_volume_tier_by_global_region]
      ,a.[align_volume_tier_enum]
      ,a.[aligntech_alert_closed_48_hours_yn]
      ,a.[aligntech_alert_goal_closed_48_hours_yn]
      ,a.[aligntech_alert_goal_closed_5_day_yn]
      ,a.[aligntech_alert_has_been_enum]
      ,a.[aligntech_alert_open_48_hours_yn]
      ,a.[aligntech_alert_open_5_days_yn]
      ,a.[aligntech_alert_owner_manager_text]
      ,a.[aligntech_alert_owner_rep_text]
      ,a.[aligntech_alert_owner_text]
      ,a.[aligntech_all_tfm_flag]
      ,a.[aligntech_cs_invisalign_pro_yn]
      ,a.[aligntech_customer_support_agent_osat_sc10]
      ,a.[aligntech_customer_support_call_resolution_pick1]
      ,a.[aligntech_customer_support_communicating_clearly_sc10]  as CustomerSupport_Clear_communication
      ,a.[aligntech_customer_support_knowledgeable_sc10] as CustomerSupport_Knowledgeable
      ,a.[aligntech_customer_support_osat_sc10] as CS_Experience_Satisfaction
      ,a.[aligntech_customer_support_understanding_your_needs_sc10] as CustomerSupport_Understanding_of_your_needs
      ,a.[aligntech_customer_support_willingness_to_help_sc10] as CustomerSupport_Willingness_to_help
      ,a.[aligntech_invisalign_pro_yn]
      ,a.[aligntech_itero_customer_support_sc11na] as iTero_Customer_Support
      ,a.[aligntech_itero_ease_scanning_yn] as iTero_Ease_of_Scanning
      ,a.[aligntech_itero_installation_sc11na] as iTero_Installation
      ,a.[cc_initial_setup_rating_enum]
      ,a.[align_cc_initialsetup_ratinggroup_enum]
      ,a.[align_rl_surveyunit_salesdirector_text]
      ,a.[aligntech_relationship_account_management_osat_sc10]
      ,a.[aligntech_relationship_company_trust_sc10] as Company_trust
      ,a.[aligntech_relationship_expertise_osat_sc10] as Support_Offerings_Satisfaction
      ,b.[align_casemanagement_contactednotes_comment]
      ,b.[align_casemanagement_contactednotes_cs_comment]
      ,b.[align_casemanagement_contactednotes_rel_comment]
      ,b.[align_casemanagement_firstcontactnotes_cc_comment]
      ,b.[align_casemanagement_firstcontactnotes_cs_comment]
      ,b.[align_casemanagement_firstcontactnotes_rel_comment]
      ,b.[align_casemanagement_followupowner_cs_text]
      ,b.[align_casemanagement_followupowner_rel_text]
      ,b.[align_casemanagement_followupowner_text]
      ,b.[align_casemanagement_rel_issuecategory_enum]
      ,b.[align_casemanagement_rel_resolutioncategory_enum]
      ,b.[align_casemanagement_resolutioncategory_enum]
      ,b.[align_casemanagement_resolutiondesc_comment]
      ,b.[align_casemanagement_resolutiondesc_cs_comment]
      ,b.[align_casemanagement_resolutiondesc_rel_comment]
      ,b.[align_casemanagement_secondcontactnotes_cc_comment]
      ,b.[align_casemanagement_secondcontactnotes_cs_comment]
      ,b.[align_casemanagement_secondcontactnotes_rel_comment]
      ,b.[align_rl_itero_comment_flag] as iTero_Comment_Flag
      ,b.[aligntech_customer_support_effectiveness_sc10] as CustomerSupport_Effectiveness_to_resolve_request
      ,b.[aligntech_customer_support_email_contact_email] as Customer_Support_Email_Contact
      ,b.[aligntech_customer_support_multiling_ltr_comment_text] as Customer_Support_Satisfaction_Comment_Translated
      ,b.[aligntech_customer_support_multiling_problem_description_text] as Customer_Support_Issue_Description_Translated
      ,b.[aligntech_customer_support_number_of_contacts_pick1] as CustomerSupport_Times_contacted_for_issue
      ,b.[aligntech_customer_support_oe_text] as Customer_Support_Final_Comment
      ,b.[aligntech_customer_support_phone_email_contact_text] as Customer_Support_Phone_Contact
      ,b.[aligntech_customer_support_phone_email_contact_text_0] as Customer_Support_Email_Contact1
      ,b.[aligntech_customer_support_problem_description_text] as Customer_Support_Issue_Description
      ,b.[aligntech_customer_support_request_to_be_contacted_pick1] as CustomerSupport_Open_to_Contact
      ,b.[aligntech_itero_equipment_support_sc11na] as iTero_Equipment_Support
      ,b.[aligntech_itero_freq_features_sc11na] as iTero_Frequency_of_New_Features
      ,b.[aligntech_itero_improve_other_txt] as iTero_Improve_Other_Text
      ,b.[aligntech_itero_improve_other_yn] as iTero_Improve_Other
      ,b.[aligntech_itero_improve_screen_yn] as iTero_Touch_Screen
      ,b.[aligntech_itero_improve_software_yn] as iTero_Software_Options
      ,b.[aligntech_itero_improve_subscription_yn] as iTero_Subscription_Options
      ,b.[aligntech_itero_improve_technique_yn] as iTero_Scanning_Technique
      ,b.[aligntech_itero_improve_thirdparty_yn] as iTero_3rd_Party_Services_Ease_of_Use
      ,b.[aligntech_itero_improve_visualization_yn] as iTero_3D_Visualization
      ,b.[aligntech_itero_improve_wand_yn] as iTero_Wand_SizeWeight
      ,b.[aligntech_itero_interface_sc11na] as iTero_User_Interface
      ,b.[aligntech_itero_onboarding_satisfaction_sc11na] as iTero_Sales_Support
      ,b.[aligntech_itero_quality_sc11na] as iTero_Quality_and_Durability_of_the_Scanner
      ,b.[aligntech_itero_restorative_sc11na] as iTero_Ease_of_Restorative_Workflow
      ,b.[aligntech_itero_satisfaction_multiling_comment_comment] as iTero_Satisfaction_Comment_Translated
      ,b.[aligntech_itero_scanner_usage_pick1] as iTero_Scanner_Usage
      ,b.[aligntech_itero_training_sc11na] as iTero_Training_on_System
      ,b.[aligntech_itero_uptime_sc11na] as iTero_Scanner_Uptime_Availability
      ,b.[aligntech_relationship_clincheck_accuracy_sc10] as ClinCheck_accuracy
      ,b.[aligntech_relationship_clinical_effectiveness_sc10] as Clinical_effectiveness
      ,b.[aligntech_relationship_clinical_support_sc10] as Clinical_support
      ,b.[aligntech_relationship_communication_sc10] as Communicates_effectively
      ,b.[aligntech_relationship_continuing_education_sc11na] as Continuing_Education
      ,b.[aligntech_relationship_customer_support_sc10] as Customer_support
      ,b.[aligntech_relationship_easy_business_sc11] as Ease_of_doing_business
      ,b.[aligntech_relationship_growth_sc10] as Importance_to_practice_growth
      ,b.[aligntech_relationship_knowledge_subject_sc10] as Clinical_knowledge
      ,b.[aligntech_relationship_lt_continue_comment_text] as Likelihood_to_Continue_Comment
      ,b.[aligntech_relationship_ltr_comment_text] as Likelihood_to_Recommend_Comment
      ,b.[aligntech_relationship_market_leader_sc10] as Market_leader
      ,b.[aligntech_relationship_marketing_sc10] as Marketing_guidance
      ,b.[aligntech_relationship_multiling_additional_kpi_feedback_text] as Relationship_Final_Comment_Translated
      ,b.[aligntech_relationship_multiling_lt_continue_comment_text] as Likelihood_to_Continue_Comment_Translated
      ,b.[aligntech_relationship_multiling_ltr_comment_text] as Likelihood_to_Recommend_Comment_Translated
      ,b.[aligntech_relationship_patient_happiness_sc10] as Patient_Happiness
      ,b.[aligntech_relationship_permission_to_contact_pick1] as Permission_To_Contact
      ,b.[aligntech_relationship_positive_impact_cmt] as Relationship_Positive_Impact_Comment
      ,b.[aligntech_relationship_process_sc10] as Positive_Impact_To_Practice_Growth
      ,b.[aligntech_relationship_product_osat_sc10] as Product_Satisfaction
      ,b.[aligntech_relationship_refinements_sc11] as Refinements
      ,b.[aligntech_relationship_sales_support_pre2017_sc10] as Sales_Support
      ,b.[aligntech_relationship_sales_support_sc10] as Credit_Collections_Department_Support
      ,b.[aligntech_relationship_treatment_planning_sc10] as Treatment_Planning
      ,b.[aligntech_relationship_willingness_to_act_in_your_bes_sc10] as Focuses_On_Your_Needs
      ,b.[align_cs_case_id] as Customer_Support_Ticket_id
      ,c.[aligntech_itero_ease_sc11na] iTero_Easy_Use
      ,c.[align_itero_usage_yn_enum_pretty] as IsiTeroUser
      ,c.[md_31223_5_scale_faq_content] as Is_FAQ_Helpful
      ,c.[md_31986_page_1_grading_38429] as Experience_On_Invisalign_Doctor_Site
      ,c.[md_31986_always_on_dropdown_en]as Suggested_Topic_Problem_Bug
      ,c.[md_32546_5_scale_chat_exp] as Chat_Experience
      ,c.[md_31986_always_on_open_text_en] as Experience_On_Invisalign_Doctor_Site_Text
      ,c.[md_31223_negative_feedback] as Improvement_Options_Negative_Feedback_FAQ
      ,c.[md_31223_positive_feedback] as Improvement_Options_Positive_Feedback_FAQ
      ,c.[md_32546_positive_feedback] as Improvement_Options_Negative_Feedback_Chat
      ,c.[md_32546_negative_feedback] as Improvement_Options_Positive_Feedback_Chat
	  ,c.aligntech_customer_support_ces_sc10 as Customer_Support_Score
      ,c.[md_text_custom_parameter_field_9662] as ChatType
	  ,c.[bp_digital_itm_survey_alt] as DigitalSurveyType
  FROM [SrcMedallia].[MedalliaSurvey] a
  inner join dwglobal.GeographyRegion d on d.RegionGroup =case when a.[align_all_doctor_global_region_enum]='EU' then 'EMEA' else  isnull(a.[align_all_doctor_global_region_enum],'Unassigned') end and d.dataset='Medallia'
  left join [SrcMedallia].[MedalliaSurvey_Extended] b
  on a.survey_id_text=b.survey_id_text
  left join srcMedallia.[MedalliaSurvey_Digital] c on 
  a.survey_id_text=c.survey_id_text;