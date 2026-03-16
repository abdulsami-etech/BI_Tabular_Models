CREATE PROC [DWIOSim].[LoadSession] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

    declare 
        @max_complete_session_id bigint, 
        @max_auto_session_id bigint, 
        @min_empty_lt bigint;

	Select @max_auto_session_id=COALESCE(MAX(auto_session_id),0) from DWIOSim.[Session]

    Select @min_empty_lt=MIN(auto_session_id) from DWIOSim.[Session] where launch_type='' and auto_session_id<>-1

    Select @max_complete_session_id= CASE WHEN @min_empty_lt<@max_auto_session_id then @min_empty_lt else @max_auto_session_id END

	if object_id('tempdb..#Session') is not null
	drop table #Session


	create table #Session with (distribution = round_robin, heap) as 
	Select
		s.session_id,
		s.session_datetime,
		s.parent_session_id,
		s.auto_session_id,
		s.application_version,
		s.clinician_id,
		CAST(s.[timezone] AS NVARCHAR(6)) AS timezone,
		Convert(nvarchar(30),'') as launch_type,
        Convert(nvarchar(50),'-1') as ClinId
	from SrcInst.Session s
	where application_name = 'Invisalign Outcome Simulator'
	and s.auto_session_id>@max_complete_session_id

	UPDATE #Session 
	set launch_type=s_ext.[value]
	from SrcInst.Session_ext s_ext
	where #Session.session_id=s_ext.session_id and s_ext.[name]='launch_type'

	if object_id('tempdb..#usermapping') is not null
	drop table #usermapping
    
	create table #usermapping with (distribution = round_robin, heap) as 
    Select 
        sc.external_id as external_id ,
        a.[user_name] as [user_name],
        row_number() over(partition by external_id order by modified_date desc) as rn
    from SrcIDS.tblPuDoctorIntraOralScan sc 
    JOIN SrcIDS.tblcnaccounts a on a.master_user_id=sc.master_user_id  and a._Region=sc._Region
    where sc.vendor=1 /*Itero only*/
	and sc._Region='Global'

    update #Session
        set ClinID=[user_name]
    from #usermapping usermapping
    where usermapping.rn=1 and usermapping.external_id=#Session.clinician_id

	update DWIOSIM.Session
    set launch_type=s.launch_type
    from #Session s
    where s.auto_session_id=Session.auto_session_id and Session.launch_type=''
	option (label = 'DWIOSIM.LoadSession');

	exec CTRL.GetLastRowCount @Label = 'DWIOSIM.LoadSession', @rc = @RowsUpdated out

	INSERT DWIOSIM.Session (
		[session_id] ,
		[DWBatchID],
		[InsertDateTime],
		[session_datetime] ,
		[parent_session_id] ,
		auto_session_id ,
		application_version ,
		clinician_id ,
		timezone ,
		launch_type ,
		ClinID)

	SELECT 
		temp_ses.[session_id] ,
		@BatchID,
		@dt,
		temp_ses.[session_datetime] ,
		temp_ses.[parent_session_id] ,
		temp_ses.auto_session_id ,
		temp_ses.application_version ,
		temp_ses.clinician_id ,
		temp_ses.timezone ,
		temp_ses.launch_type,
		temp_ses.ClinID
	from #Session temp_ses
	LEFT JOIN DWIOSim.Session ses on ses.session_id=temp_ses.session_id
	WHERE ses.session_id IS NULL
	option (label = 'DWIOSIM.LoadSession');

	exec CTRL.GetLastRowCount @Label = 'DWIOSIM.LoadSession', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

END