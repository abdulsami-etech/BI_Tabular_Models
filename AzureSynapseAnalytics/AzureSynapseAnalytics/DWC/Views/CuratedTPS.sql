CREATE VIEW [DWC].[CuratedTPS]
AS SELECT cte.TPSID, cte.TPSName, cte.TPSDrName, cte.TPSEmail, cte.TPSCountry
		, cte.TPSLabType, cte.TPSStatus, sc.clinician_id__c as "ClinID"
		,sa.account_number__c as "DID",sa.name as "Dr Name",sc.email as "Dr Email"
		,sc.line_of_business__c as "DrLOB",sa.account_status__c as "DrStatus"
		,sc.mailingcountrycode as "DrCountry"
	    ,cte.case_type as "TPSEvaluationType"
	    ,cte.order_id as "VOI"
        ,case
           when cte.tx_type_id in (1) then 'FULL'
           when cte.tx_type_id in (4) then 'ASSIST'
           when cte.tx_type_id in (6) then 'TEEN'
           when cte.tx_type_id in (7) then 'I_SEVEN'
           when cte.tx_type_id in (8) then 'LITE'
           when cte.tx_type_id in (2) then 'EXPRESS 10'
           when cte.tx_type_id in (15) then 'EXPRESS 5'
           when cte.tx_type_id in (21) then 'INVISALIGN GO'
           when cte.tx_type_id in (13) then 'RETAINER_DUAL_INT'
           when cte.tx_type_id in (14) then 'RETAINER_SINGLE_INT'
           when cte.tx_type_id in (19) then 'RETAINER_DUAL_CON'
           when cte.tx_type_id in (20) then 'RETAINER_SINGLE_CON'
           when cte.tx_type_id in (24) then 'COMPREHENSIVE_MAUI'
           when cte.tx_type_id in (25) then 'MODERATE_MAUI'
           when cte.tx_type_id in (26) then 'LITE_MAUI'
           when cte.tx_type_id in (27) then 'EXPRESS_MAUI'
           when cte.tx_type_id in (28) then 'GO_PLUS'
           when cte.tx_type_id in (30) then 'GO_STD'
           when cte.tx_type_id in (31) then 'CLEAR_ALIGNER_GO'
           when cte.tx_type_id in (33) then 'FIRST_MODERATE'
           when cte.tx_type_id in (34) then 'PHASE_2_COMPREHENSIVE'
           when cte.tx_type_id in (35) then 'IGO_STD'
           when cte.tx_type_id in (36) then 'IGO_PLUS'
           when cte.tx_type_id in (37) then 'DELUXE'
           when cte.tx_type_id in (38) then 'SIGNATURE'
           when cte.tx_type_id in (39) then 'SIGNATURE_PLUS'
           when cte.tx_type_id in (32) then 'FIRST_COMPREHENSIVE'
           when cte.tx_type_id in (401) then 'ASSIST_SIMPLE'
           when cte.tx_type_id in (201) then 'EXPRESS_10_PARTIAL'
           when cte.tx_type_id in (701) then 'I_SEVEN_PARTIAL'
           when cte.tx_type_id in (801) then 'LITE_PARTIAL'
           when cte.tx_type_id in (1501) then 'EXPRESS_5_PARTIAL'
           when cte.tx_type_id in (2501) then 'MODERATE_MAUI_PARTIAL'
           when cte.tx_type_id in (2601) then 'LITE_MAUI_PARTIAL'
           when cte.tx_type_id in (2701) then 'EXPRESS_MAUI_PARTIAL'
           when cte.tx_type_id in (3301) then 'FIRST_MODERATE_PARTIAL'
           when cte.tx_type_id in (12) then 'INVISALIGN R&D'
           when cte.tx_type_id in (22) then 'IAS'
           END as "TreatmentType",
       case
           when cte.vip_order_type in (101) then 'UNKNOWN_PRIMARY'
           when cte.vip_order_type in (3,4) then 'FULL'
           when cte.vip_order_type in (60) then 'RD'
           when cte.vip_order_type in(1,2) then 'ANTERIOR'
           when cte.vip_order_type in (14,11) then 'EXPRESS'
           when cte.vip_order_type in (32) then 'EXPRESS_FIVE'
           when cte.vip_order_type in (23) then 'TEEN'
           when cte.vip_order_type in (17) then 'ASSIST'
           when cte.vip_order_type in (30) then 'LITE'
           when cte.vip_order_type in (33) then 'I_SEVEN'
           when cte.vip_order_type in (16) then 'PATIENTS_FIRST'
           when cte.vip_order_type in (34) then 'REALINE'
           when cte.vip_order_type in (102) then 'UNKNOWN_SECONDARY'
           when cte.vip_order_type in (5,10,24) then 'MCC'
           when cte.vip_order_type in (6,19,25) then 'REFINEMENT'
           when cte.vip_order_type in (12,27,29,31) then 'WARRANTY'
           when cte.vip_order_type in (15) then 'DETAILING'
           when cte.vip_order_type in (18) then 'PROGRESS'
           when cte.vip_order_type in (28) then 'RD_PROGRESS_SCAN'
           when cte.vip_order_type in (61) then 'RD_OUTCOME_RETAINER'
           when cte.vip_order_type in (9,62) then 'RD_OUTCOME_CASE'
           when cte.vip_order_type in (63) then 'ATTACHMENT_TEMPLATE'
           when cte.vip_order_type in (21,59) then 'RETAINER_SINGLEPACK'
           when cte.vip_order_type in (7,22,26) then 'REPLACEMENT'
           when cte.vip_order_type in (41) then 'RETAINER_WARRANTY'
           when cte.vip_order_type in (42) then 'ALIGNER_WARRANTY'
           when cte.vip_order_type in (20) then 'RETAINER_MULTIPACK'
           when cte.vip_order_type in (51) then 'RETAINER_BATCH'
           when cte.vip_order_type in (52) then 'RETAINER_REPLACEMENT'
           when cte.vip_order_type in (53) then 'RETAINER_NEW_IMPRESSION'
           when cte.vip_order_type in (54) then 'RETAINER_WARRANTY_FIT'
           when cte.vip_order_type in (55) then 'RETAINER_WARRANTY_DEFECTIVE'
           when cte.vip_order_type in (56) then 'RETAINER_MULTIPACK_INT'
           when cte.vip_order_type in (57) then 'RETAINER_MULTIPACK_RLN'
           when cte.vip_order_type in (58) then 'RETAINER_MULTIPACK_CON'
           when cte.vip_order_type in (70) then 'Additional Aligners'
           when cte.vip_order_type in (80) then 'ACCESS'
           when cte.vip_order_type in (90) then 'IAS'
           when cte.vip_order_type in (91) then 'IAS_BATCH'
           when cte.vip_order_type in (92) then 'NUME'
           when cte.vip_order_type in (93) then 'COMPREHENSIVE_MAUI'
           when cte.vip_order_type in (94) then 'MODERATE_MAUI'
           when cte.vip_order_type in (95) then 'LITE_MAUI'
           when cte.vip_order_type in (96) then 'EXPRESS_MAUI'
           when cte.vip_order_type in (97) then 'GO_PLUS'
           when cte.vip_order_type in (99) then 'GO_STD'
           when cte.vip_order_type in (100) then 'CLEAR_ALIGNER_GO'
           when cte.vip_order_type in (106) then 'IGO_STD'
           when cte.vip_order_type in (107) then 'IGO_PLUS'
           when cte.vip_order_type in (103) then 'FIRST_COMPREHENSIVE'
           when cte.vip_order_type in (104) then 'FIRST_MODERATE'
           when cte.vip_order_type in (105) then 'PHASE_2_COMPREHENSIVE'
           when cte.vip_order_type in (108) then 'DELUXE'
           when cte.vip_order_type in (109) then 'SIGNATURE'
           when cte.vip_order_type in (110) then 'SIGNATURE_PLUS'
           END  as "OrderType",
       cte.event_type as "OrderStatus",
       cte.shared_on as "Order Lab Referral Date",
       case
           when cte.case_status in (0) then 'CREATED'
           when cte.case_status in (1) then 'COMPLETED'
           when cte.case_status in (2) then 'CANCELED'
           when cte.case_status in (3) then 'RECOMMENDED'
           when cte.case_status in (4) then 'MODIFIED'
           else 'SWITCHED'
           END  as "TPSCaseStatus",
       cte.updated_at as "OrderLabLastReviewedAt",
       cte.updated_by as "Order Lab Reviewed By",
       cte.cc_accept_date CCADate, 
	   cte.ss_ship_date ShipDate,
       convert(Date, cte.updated_at) as DateKey,
       cte.SAPOrderNumber,
	   cte.cc_count,
       cte.ReClinCheckCount
      
FROM (SELECT acc.account_number__c  "TPSID",
           acc.name "TPSName",
           acc.doctor_name__c "TPSDrName",
           acc.notification_email__c as "TPSEmail",
           acc.shippingcountrycode as "TPSCountry",
           acc.Lab_Type__c as "TPSLabType",
           acc.account_status__c "TPSStatus",
           tps.*, tsh.tx_type_id,osh.vip_order_type
           ,osh.event_type
		   ,osh.cc_accept_date,osh.ss_ship_date
		   ,pom.jde_order_id as SAPOrderNumber
		   ,osh.cc_count 
		   ,osh.cc_mod_count as ReClinCheckCount
    FROM SrcSFDC.account acc
        JOIN Srctps.cases tps ON acc.account_number__c = tps.lab_id
        LEFT JOIN srcids.tblpuorderstatus os on tps.order_id=os.vip_order_id
        LEFT JOIN srcids.tblpuorderstatushistory osh on os.order_status_history_id = osh.order_status_history_id
        LEFT JOIN srcids.tblputreatmentstatus ts on osh.treatment_id = ts.treatment_id
        LEFT JOIN srcids.tblputreatmentstatushistory tsh on ts.treatment_status_history_id = tsh.treatment_status_history_id
		LEFT JOIN srcids.tblcnpatientordermap pom on os.vip_order_id = pom.vip_order_id
    WHERE acc.Account_Sub_Type__c = 'TPS Provider'
      AND acc.account_status__c = 'Active') as cte JOIN SrcSFDC.contact sc ON cte.doctor_id = sc.clinician_id__c
    JOIN SrcSFDC.account sa ON sc.accountid = sa.id;