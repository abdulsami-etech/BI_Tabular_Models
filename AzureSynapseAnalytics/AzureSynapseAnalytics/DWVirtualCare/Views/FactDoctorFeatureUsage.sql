CREATE VIEW [DWVirtualCare].[FactDoctorFeatureUsage]
	AS
WITH events as (
select vc.patient_id,
       TRY_CONVERT(date, LEFT(created_at, 10)) as date,
       CASE
           WHEN CHARINDEX('$', vc.clin_id) > 0 THEN SUBSTRING(vc.clin_id, 0, CHARINDEX('$', vc.clin_id))
           ELSE vc.clin_id
           END                                 as ClinId,
       CASE
           /*NotificationOnTrack*/
           WHEN vc.event_name = 'notification_popup' and vc.event_action = 'click' and
                vc.event_category = 'sent_on_track' THEN 'NotificationOnTrack'
           /*NotificationInstructions*/
           WHEN vc.event_name = 'notification_popup' and vc.event_action = 'click' and
                vc.event_category = 'sent_instructions' THEN 'NotificationInstructions'
           /*NotificationAppointment*/
           WHEN vc.event_name = 'appointment_popup' and vc.event_action = 'click' and
                vc.event_category = 'scheduled_appointment' THEN 'NotificationAppointment'
           /*Demo accounts*/
           WHEN vc.event_name = 'profile_settings_popup' and vc.event_action = 'click' and
                vc.event_category = 'demo_accounts_done' THEN 'DemoAccount'
           /*Custom templates*/
           WHEN vc.event_name = 'profile_templates_settings' and vc.event_action = 'created' and
                vc.event_category = 'template' THEN 'CustomTemplate'
            /*archive*/
           WHEN vc.event_name='archive' and vc.event_action='click'
                and vc.event_category='init' THEN 'Archive'
            /*unarchive*/
           WHEN vc.event_name='unarchive_confirmation' and vc.event_action='click'
                and vc.event_category='init_unarchive_confirmation' THEN 'Unarchive'
           END as event
from SrcEventHub.VirtualCare vc
where event_name in ('notification_popup', 'appointment_popup', 'profile_settings_popup', 'profile_settings_popup',
                     'profile_templates_settings','archive','unarchive_confirmation')
    AND TRY_CONVERT(date, LEFT(created_at, 10))<'2021-10-01'
),
events_Heroku as (
    select vc.patient_id,
       TRY_CONVERT(date, LEFT(created_at, 10)) as date,
       CASE
           WHEN CHARINDEX('$', vc.clin_id) > 0 THEN SUBSTRING(vc.clin_id, 0, CHARINDEX('$', vc.clin_id))
           ELSE vc.clin_id
           END                                 as ClinId,
       CASE
           /*NotificationOnTrack*/
           WHEN vc.event_name = 'notification_popup' and vc.event_action = 'click' and
                vc.event_category = 'sent_on_track' THEN 'NotificationOnTrack'
           /*NotificationInstructions*/
           WHEN vc.event_name = 'notification_popup' and vc.event_action = 'click' and
                vc.event_category = 'sent_instructions' THEN 'NotificationInstructions'
           /*NotificationAppointment*/
           WHEN vc.event_name = 'appointment_popup' and vc.event_action = 'click' and
                vc.event_category = 'scheduled_appointment' THEN 'NotificationAppointment'
           /*Demo accounts*/
           WHEN vc.event_name = 'profile_settings_popup' and vc.event_action = 'click' and
                vc.event_category = 'demo_accounts_done' THEN 'DemoAccount'
           /*Custom templates*/
           WHEN vc.event_name = 'profile_templates_settings' and vc.event_action = 'created' and
                vc.event_category = 'template' THEN 'CustomTemplate'
            /*archive*/
           WHEN vc.event_name='archive' and vc.event_action='click'
                and vc.event_category='init' THEN 'Archive'
            /*unarchive*/
           WHEN vc.event_name='unarchive_confirmation' and vc.event_action='click'
                and vc.event_category='init_unarchive_confirmation' THEN 'Unarchive'
           END as event
from SrcKafkaHeroku.remote_care_web_event vc
where event_name in ('notification_popup', 'appointment_popup', 'profile_settings_popup', 'profile_settings_popup',
                     'profile_templates_settings','archive','unarchive_confirmation')
AND TRY_CONVERT(date, LEFT(created_at, 10))>='2020-10-01'
),
eventsFromEventsAPI as (
    select
        vcu.KeyUser as patient_id,
       TRY_CONVERT(date, LEFT(created_date, 10)) as date,
       vcu.KeyClinID  as ClinId,
       CASE
           /*NotificationOnTrack*/
           WHEN vc.event_type = 'on_track' and vc.app_name='events-api'
               THEN 'NotificationOnTrack'
           /*NotificationInstructions*/
           WHEN vc.event_type = 'send_instructions' and vc.app_name='events-api'
                THEN 'NotificationInstructions'
           /*NotificationAppointment*/
           WHEN vc.event_type = 'appointment' and vc.app_name='events-api'
               THEN 'NotificationAppointment'
           END as event
    from SrcEventHub.VirtualCare vc
    JOIN DWC.DimVCUser vcu on vcu.KeyUser=vc.patient_id
    JOIN (Select SKUser from DWC.FactVCUserContactEvent where SKEvent=1 group by SKUser) as Invited
        on Invited.SKUser=vcu.SKUser
    where vc.app_name='events-api' and vc.event_type IN ('on_track','send_instructions','appointment')
    AND TRY_CONVERT(date, LEFT(created_date, 10)) <'2021-10-01'
    ),
eventsFromEventsAPI_Heroku as (
    select
        vcu.KeyUser as patient_id,
       TRY_CONVERT(date, LEFT(created_date, 10)) as date,
       vcu.KeyClinID  as ClinId,
       CASE
           /*NotificationOnTrack*/
           WHEN vc.event_type = 'on_track' and vc.app_name='events-api'
               THEN 'NotificationOnTrack'
           /*NotificationInstructions*/
           WHEN vc.event_type = 'send_instructions' and vc.app_name='events-api'
                THEN 'NotificationInstructions'
           /*NotificationAppointment*/
           WHEN vc.event_type = 'appointment' and vc.app_name='events-api'
               THEN 'NotificationAppointment'
           END as event
    from SrcKafkaHeroku.events_api_event vc
    JOIN DWC.DimVCUser vcu on vcu.KeyUser=vc.patient_id
    JOIN (Select SKUser from DWC.FactVCUserContactEvent where SKEvent=1 group by SKUser) as Invited
        on Invited.SKUser=vcu.SKUser
    where vc.app_name='events-api' and vc.event_type IN ('on_track','send_instructions','appointment')
    AND TRY_CONVERT(date, LEFT(created_date, 10)) >='2021-10-01'
),
EducationalMaterial as (
        select  NULL as patient_id,
           TRY_CONVERT(date, LEFT(created_at, 10)) as date,
           CASE
               WHEN CHARINDEX('$', vc.clin_id) > 0 THEN SUBSTRING(vc.clin_id, 0, CHARINDEX('$', vc.clin_id))
               ELSE vc.clin_id
               END                                 as ClinId,
           CASE
               /*'EducationalMaterial'*/
               WHEN vc.event_name = 'resources' and vc.event_action = 'click' and
                    vc.event_category = 'init_resource_link' THEN 'EducationalMaterial'
        END as event,
        JSON_VALUE(event_meta_data,'$.resourceName') as ResourceName
    from SrcEventHub.VirtualCare vc
    where vc.event_name='resources' and vc.event_action='click' and vc.event_category='init_resource_link'
    AND TRY_CONVERT(date, LEFT(created_at, 10)) <'2021-10-01'
    ),
EducationalMaterial_Heroku as (
        SELECT  NULL as patient_id,
           TRY_CONVERT(date, LEFT(created_at, 10)) as date,
           CASE
               WHEN CHARINDEX('$', vc.clin_id) > 0 THEN SUBSTRING(vc.clin_id, 0, CHARINDEX('$', vc.clin_id))
               ELSE vc.clin_id
               END                                 as ClinId,
           CASE
               /*'EducationalMaterial'*/
               WHEN vc.event_name = 'resources' and vc.event_action = 'click' and
                    vc.event_category = 'init_resource_link' THEN 'EducationalMaterial'
        END as event,
        JSON_VALUE(event_meta_data,'$.resourceName') as ResourceName
    from SrcKafkaHeroku.remote_care_web_event vc
    where vc.event_name='resources' and vc.event_action='click' and vc.event_category='init_resource_link'
    AND TRY_CONVERT(date, LEFT(created_at, 10)) >='2021-10-01'
    ),
ChangeSchedule as (
        select
            patient_id as patient_id,
            TRY_CONVERT(date, LEFT(created_at, 10)) as date,
            CASE
                WHEN CHARINDEX('$', vc.clin_id) > 0 THEN SUBSTRING(vc.clin_id, 0, CHARINDEX('$', vc.clin_id))
                ELSE vc.clin_id
            END        as ClinId,
            CASE
                /*'Change Schedule all stages'*/
                WHEN
                    vc.event_name='notification_popup'
                    and vc.event_action = 'click'
                    and vc.event_category='sent_instructions'
                    and JSON_VALUE(event_meta_data,'$.alignerSchedule.schedule_all')='true'
                    THEN 'ChangeScheduleAll'
                /*'Change Schedule all stages'*/
                WHEN
                    vc.event_name='notification_popup'
                    and vc.event_action = 'click'
                    and vc.event_category='sent_instructions'
                    and JSON_VALUE(event_meta_data,'$.alignerSchedule.schedule_all')='false'
                    THEN 'ChangeScheduleSelected'
                END as event
    from SrcEventHub.VirtualCare vc
    where
        vc.event_name='notification_popup'
        and vc.event_action='click'
        and vc.event_category='sent_instructions'
        and JSON_VALUE(event_meta_data,'$.alignerSchedule.schedule_all') IS NOT NULL
        AND TRY_CONVERT(date, LEFT(created_at, 10)) <'2021-10-01'
    ),
ChangeSchedule_Heroku as (
        select
            patient_id as patient_id,
            TRY_CONVERT(date, LEFT(created_at, 10)) as date,
            CASE
                WHEN CHARINDEX('$', vc.clin_id) > 0 THEN SUBSTRING(vc.clin_id, 0, CHARINDEX('$', vc.clin_id))
                ELSE vc.clin_id
            END        as ClinId,
            CASE
                /*'Change Schedule all stages'*/
                WHEN
                    vc.event_name='notification_popup'
                    and vc.event_action = 'click'
                    and vc.event_category='sent_instructions'
                    and JSON_VALUE(event_meta_data,'$.alignerSchedule.schedule_all')='true'
                    THEN 'ChangeScheduleAll'
                /*'Change Schedule all stages'*/
                WHEN
                    vc.event_name='notification_popup'
                    and vc.event_action = 'click'
                    and vc.event_category='sent_instructions'
                    and JSON_VALUE(event_meta_data,'$.alignerSchedule.schedule_all')='false'
                    THEN 'ChangeScheduleSelected'
                END as event
    from SrcKafkaHeroku.remote_care_web_event vc
    where
        vc.event_name='notification_popup'
        and vc.event_action='click'
        and vc.event_category='sent_instructions'
        and JSON_VALUE(event_meta_data,'$.alignerSchedule.schedule_all') IS NOT NULL
        AND TRY_CONVERT(date, LEFT(created_at, 10)) >='2021-10-01'
    ),
invite as (
    SELECT
        u.KeyUser,
        c.SKContact,
        c.ClinID,
        fi.EventDate,
        'First invite' as event
    from DWC.DimContact c
    JOIN (
        SELECT fce.SKUser,
               fce.SKContact,
               fce.EventDate,
               ROW_NUMBER() over (PARTITION BY fce.SKContact,fce.SKUser ORDER BY fce.EventDate ASC) as r
        from DWC.FactVCUserContactEvent fce
        where fce.SKEvent = 1
    ) as fi on fi.SKContact=c.SKContact and fi.r=1
    JOIN DWC.DimVCUser u on u.SKUser=fi.SKUser
),
msg as (
    SELECT
        e.patient_id,
        TRY_CONVERT(date, LEFT(e.created_date, 10)) as date,
        hu.KeyClinID as ClinId,
        CASE WHEN e.event_type IN ('anterior','anterior_openBite_aligners','buccal_left','buccal_left_openBite_aligners','buccal_right','buccal_right_openBite_aligners','face_smiling_clinical','cheeek_retractors_aligners_on','cheek_retractors_aligners_off','smileVideo','myCareVideo','profile','selfie','video/flv','video/ogv','selfieVideo','anterior_open_bite','buccal_left_open_bite','buccal_right_open_bite','ipa_anterior_open_bite','ipa_buccal_left','ipa_buccal_right','ipa_face_smiling')
        THEN 'Photo message'
        WHEN e.event_type IN ('send_instructions') THEN 'Instructions message'
        WHEN e.event_type IN ('on_track') THEN 'On track message'
        END as Event
    from SrcKafkaHeroku.events_api_event e
    JOIN DWVirtualCare.HubUser hu on hu.KeyUser=e.patient_id
    where e.event_name='event_created'
    and e.event_type IN ('send_instructions','on_track','anterior','anterior_openBite_aligners','buccal_left','buccal_left_openBite_aligners','buccal_right','buccal_right_openBite_aligners','face_smiling_clinical','cheeek_retractors_aligners_on','cheek_retractors_aligners_off','smileVideo','myCareVideo','profile','selfie','video/flv','video/ogv','selfieVideo','anterior_open_bite','buccal_left_open_bite','buccal_right_open_bite','ipa_anterior_open_bite','ipa_buccal_left','ipa_buccal_right','ipa_face_smiling')
    and COALESCE(e.notes,'')<>''
    and TRY_CONVERT(date, LEFT(e.created_date, 10)) IS NOT NULL
)
SELECT
    e.patient_id,
    e.date,
    c.SKContact,
    e.ClinId,
    e.event,
    e.ResourceName
from (
    Select
        events.patient_id,
        events.date,
        events.ClinId,
        events.event,
        NULL as ResourceName
    from events
    where events.event IS NOT NULL
    UNION
        Select
        events.patient_id,
        events.date,
        events.ClinId,
        events.event,
        NULL as ResourceName
    from events_Heroku events
    where event IS NOT NULL
    UNION
    Select
        ea.patient_id,
        ea.date,
        ea.ClinId,
        ea.event,
        NULL as ResourceName
    from eventsFromEventsAPI ea
    UNION
        Select
        ea.patient_id,
        ea.date,
        ea.ClinId,
        ea.event,
        NULL as ResourceName
    from eventsFromEventsAPI_Heroku ea
    UNION
    Select
        em.patient_id,
        em.date,
        em.ClinId,
        em.event,
        em.ResourceName as ResourceName
    from EducationalMaterial  em
    UNION
    Select
        em.patient_id,
        em.date,
        em.ClinId,
        em.event,
        em.ResourceName as ResourceName
    from EducationalMaterial_Heroku  em
    UNION
    Select
        cs.patient_id,
        cs.date,
        cs.ClinId,
        cs.event,
        NULL as ResourceName
    from ChangeSchedule  cs
    UNION
    Select
        cs.patient_id,
        cs.date,
        cs.ClinId,
        cs.event,
        NULL as ResourceName
    from ChangeSchedule_Heroku  cs
    UNION
    Select
        i.KeyUser as patient_id,
        i.EventDate as date,
        i.ClinID as  ClinId,
        i.Event as event,
        NULL as ResourceName
    from invite  i
    UNION
    Select
        m.patient_id,
        m.date,
        m.ClinID,
        m.event,
        NULL as ResourceName
    from msg  m
         ) as e
JOIN DWC.DimContact c on c.ClinID=e.ClinId
where e.event is not null
group by
    e.patient_id,
    e.date,
    e.ClinId,
    e.event,
    c.SKContact,
    e.ResourceName
