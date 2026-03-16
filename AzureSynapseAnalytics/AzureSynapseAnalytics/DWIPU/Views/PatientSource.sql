CREATE VIEW [DWIPU].[PatientSource]
AS WITH IDS_Hist as (
        Select 
            pat.create_date,
            1 as IDS_pat,
            0 as IPU_pat,
            CONVERT(nvarchar(100),NULL) AS Session_id,
            acc.user_name as ClinID,
            YEAR(pat.create_date)*100+MONTH(pat.create_date) as ym,
            ROW_Number() over (partition by acc.user_name,YEAR(pat.create_date)*100+MONTH(pat.create_date) order by pat.create_date desc) as R
        from SrcIDS.tblcndoctorpatientmap dpm WITH (NOLOCK)
        JOIN SrcIDS.tblcnpatients pat WITH (NOLOCK) on pat.vip_patient_id= dpm.vip_patient_id and dpm._Region=pat._Region
        JOIN SrcIDS.tblcnAccounts acc WITH (NOLOCK) on acc.master_user_id=dpm.master_user_id and acc._Region=dpm._Region
        where pat.create_date>='2018-01-01' and pat.create_date<'2020-06-01' and dpm._Region='Global'
    ),
    IPU_Hist as (
        Select
            ipu.LogTimestamp as create_date,
            0 as IDS_pat,
            1 as IPU_pat,
            ipu.Session_ID,
            ipu.[user] as ClinID,
            YEAR(ipu.LogTimestamp)*100+MONTH(ipu.LogTimestamp) as ym,
            ipu.OS,
            ROW_Number() over (partition by ipu.[user] ,YEAR(ipu.LogTimestamp)*100+MONTH(ipu.LogTimestamp) order by ipu.LogTimestamp desc) as R
        FROM SrcSplunk.MobileIPU ipu WITH (NOLOCK)
        where [Action]='New Patient Created'
        and ipu.LogTimestamp<'2020-06-01'
        and COALESCE(Session_ID,'')<>''
    ),
    Pat_Cr_Hist as (
        Select
            IDS.ClinId as ContactClinID
            ,CONVERT(date,COALESCE(IPU.create_date,IDS.create_date)) as PatientCreationDate
            ,IDS.IDS_pat as PatientsCreated
            ,COALESCE(IPU.IPU_pat,0) as PatientsCreatedInIPU
            ,IPU.Session_ID as SessionId
            ,IPU.OS
        from IDS_Hist IDS
        LEFT JOIN IPU_Hist IPU on IDS.ClinID=IPU.ClinID and IDS.R=IPU.R and IDS.ym=IPU.ym
    ),
    IDS as (
        Select 
            CONVERT(date,DATEADD(HOUR,7,pat.create_date)) as create_date ,
            1 as IDS_pat,
            0 as IPU_pat,
            CONVERT(nvarchar(100),NULL) AS Session_id,
            acc.user_name as ClinID,
            ROW_Number() over (partition by acc.user_name,CONVERT(date,DATEADD(HOUR,7,pat.create_date)) order by pat.create_date desc) as R
        from SrcIDS.tblcndoctorpatientmap dpm WITH (NOLOCK)
        JOIN SrcIDS.tblcnpatients pat WITH (NOLOCK) on pat.vip_patient_id= dpm.vip_patient_id and dpm._Region=pat._Region
        JOIN SrcIDS.tblcnAccounts acc WITH (NOLOCK) on acc.master_user_id=dpm.master_user_id and acc._Region=dpm._Region
        where pat.create_date>='2020-06-01' and dpm._Region='Global'
    ),
    IPU as (
        Select
            CONVERT(date,ipu.TS) as create_date,
            0 as IDS_pat,
            1 as IPU_pat,
            ipu.SessionID as Session_ID,
            ipu.[_user] as ClinID,
            ipu.OS,
            ROW_Number() over (partition by ipu.[_user] ,CONVERT(date,ipu.TS) order by ipu.TS desc) as R
        FROM SrcSplunk.IPU_Other ipu WITH (NOLOCK)
        where [Action]='New Patient Created'
        and COALESCE(SESSIONID,'')<>''
        and ipu.TS>='2020-06-01'
    ),
    Pat_Cr as (
    Select
        IDS.ClinId as ContactClinID
        ,CONVERT(date,COALESCE(IPU.create_date,IDS.create_date)) as PatientCreationDate
        ,IDS.IDS_pat as PatientsCreated
        ,COALESCE(IPU.IPU_pat,0) as PatientsCreatedInIPU
        ,IPU.Session_ID as SessionId
        ,IPU.OS
    from IDS IDS
    LEFT JOIN IPU IPU on IDS.ClinID=IPU.ClinID and IDS.R=IPU.R and IDS.create_date=IPU.create_date
    )
    Select * FROM Pat_Cr 
    UNION ALL 
    Select * FROM Pat_Cr_Hist;