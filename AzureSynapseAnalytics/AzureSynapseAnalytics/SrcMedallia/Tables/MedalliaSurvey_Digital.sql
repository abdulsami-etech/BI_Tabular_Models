CREATE TABLE [SrcMedallia].[MedalliaSurvey_Digital] (
    [LZBatchID]                        INT            NOT NULL,
    [ADLSBatchID]                      INT            NOT NULL,
    [ADLSTimestamp]                    DATETIME2 (0)  NOT NULL,
    [survey_id_text]                   BIGINT         NOT NULL,
    [responsedate]                     DATETIME       NULL,
    [aligntech_itero_ease_sc11na]      NVARCHAR (MAX) NULL,
    [md_31223_5_scale_faq_content]     NVARCHAR (MAX) NULL,
    [md_31986_page_1_grading_38429]    NVARCHAR (MAX) NULL,
    [md_31986_always_on_dropdown_en]   NVARCHAR (MAX) NULL,
    [md_32546_5_scale_chat_exp]        NVARCHAR (MAX) NULL,
    [md_31986_always_on_open_text_en]  NVARCHAR (MAX) NULL,
    [md_31223_negative_feedback]       NVARCHAR (MAX) NULL,
    [md_31223_positive_feedback]       NVARCHAR (MAX) NULL,
    [md_31179_negative_feedback]       NVARCHAR (MAX) NULL,
    [md_31179_positive_feedback]       NVARCHAR (MAX) NULL,
    [md_32546_positive_feedback]       NVARCHAR (MAX) NULL,
    [md_32546_negative_feedback]       NVARCHAR (MAX) NULL,
    [align_itero_usage_yn_enum_pretty] NVARCHAR (MAX) NULL,
    aligntech_customer_support_ces_sc10 NVARCHAR (MAX) NULL,
    md_text_custom_parameter_field_9662 NVARCHAR (MAX) NULL,
    bp_digital_itm_survey_alt NVARCHAR (MAX) NULL
)
WITH (CLUSTERED INDEX([survey_id_text]), DISTRIBUTION = HASH([survey_id_text]));

