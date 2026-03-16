CREATE PROC [DWInst].[LoadDimInstSession] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted		int = 0
		,	@RowsUpdated		int = 0
		,	@totalRowsInserted	int = 0
		,	@totalRowsUpdated	int = 0
		,	@IsFullLoad			bit = 0

	if not exists (select * from [DWInst].[DimInstSession])
		set @IsFullLoad = 1


    if object_id('tempdb..#LoadDimAction') is not null
		drop table #LoadDimAction
			
	create table #LoadDimAction with (distribution = hash([Session_id]), heap) 
	as
	select session_id,datediff(minute,max(action_datetime),min(action_datetime)) DurationInMinutes 
					from srcinst.[action] 
					where ADLSTimestamp>=@LastSuccessfullDWTimestamp
					and year(ADLSTimestamp) >= year(getdate())-1 --and month(action_datetime)=6
					group by session_id

					

	if object_id('tempdb..#LoadDimInstSession') is not null
		drop table #LoadDimInstSession
			
	create table #LoadDimInstSession with (distribution = hash([Session_id]), heap) 
	as 
	SELECT ses.[session_id]
	  ,ses.[ADLSTimeStamp]
      ,ext.[Wand_version] as [WandVersion]
      ,ext.[rx_id] as [RxId]
      ,ext.[scan_date] as [ScanDate]
      ,ext.[case_type] as [CaseType]
      ,ext.[firewall_info_1]  as [FirewallInfo]
      ,ext.[still_time_in_seconds] as StillTimeInSeconds
      ,ses.[Session_Datetime] as [SessionTime]
	  ,cast(ses.[Session_Datetime] as date) sessionDate
      ,ext.[doctor_name] as DoctorName
      ,ext.[occlusionColors] as [OcclusionColors]
      ,ext.[computer_name] as [ComputerName]
      ,ext.[crown_install_date] as [CrownInstallDate]
      ,ext.[wand_id] as [WandId]
      ,ext.[company_id] as [CompanyId]
      ,ext.[doctor_id] as [DoctorId]
      ,ext.[internet_explorer_version] as [InternetExplorerVersion]
      ,ext.[instrumentation_case_id] as [InstrumentationCaseId]
      ,ext.[case_type (id)] as CaseTypeId
      ,ext.[is_online_mode] as IsOnlineMode
	  ,ses.application_name as ApplicationName
	  ,ses.application_version as ApplicationVersion
	  ,ses.application_language as ApplicationLanguage
	  ,ses.clinician_id as ClinicianId
	  ,act.DurationInMinutes
  FROM srcinst.session ses
  inner join  [SrcInst].[DimInstSession] ext on Ses.session_id = ext.session_id
  inner join #LoadDimAction act on act.session_id = ses.session_id
		WHERE  ( @IsFullLoad = 1 
				  OR ses.adlstimestamp >= Isnull(@LastSuccessfullDWTimestamp, '19000101') 
			   )
			   and year(ses.adlstimestamp)>=year(getdate())-1
			 
	

	begin tran

	delete from [DWInst].[DimInstSession]
	where exists (
		select *
		from #LoadDimInstSession s
		where --s.SAPOrdernumber = DW.CaseStateHistory.SAPOrdernumber and --this one causes duplicates when the same history key comes with a different order #
		s.session_id = [DWInst].[DimInstSession].Session_id
		)
	option (Label = 'DWInst.DimInstSession_Delete');

	exec CTRL.GetLastRowCount @Label = 'DWInst.DimInstSession_Delete', @rc = @RowsUpdated out

	INSERT INTO [DWInst].[DimInstSession]
           (
         [session_id]
      ,[DWBatchID]
      ,[ADLSTimestamp]
      ,[WandVersion]
      ,[RxId]
      ,[ScanDate]
      ,[CaseType]
      ,[FirewallInfo]
      ,[StillTimeInSeconds]
      ,[SessionTime]
      ,[sessionDate]
      ,[DoctorName]
      ,[OcclusionColors]
      ,[ComputerName]
      ,[CrownInstallDate]
      ,[WandId]
      ,[CompanyId]
      ,[DoctorId]
      ,[InternetExplorerVersion]
      ,[InstrumentationCaseId]
      ,[CaseTypeId]
      ,[ApplicationName]
      ,[ApplicationVersion]
      ,[ApplicationLanguage]
      ,[ClinicianId]
	  ,[DurationInMinutes]
	  )
	SELECT    
	   [session_id]
		,@BatchID
	    ,[ADLSTimestamp]
      ,[WandVersion]
      ,[RxId]
      ,[ScanDate]
      ,[CaseType]
      ,[FirewallInfo]
      ,[StillTimeInSeconds]
      ,[SessionTime]
      ,[sessionDate]
      ,[DoctorName]
      ,[OcclusionColors]
      ,[ComputerName]
      ,[CrownInstallDate]
      ,[WandId]
      ,[CompanyId]
      ,[DoctorId]
      ,[InternetExplorerVersion]
      ,[InstrumentationCaseId]
      ,[CaseTypeId]
      ,[ApplicationName]
      ,[ApplicationVersion]
      ,[ApplicationLanguage]
      ,[ClinicianId]
	  ,[DurationInMinutes]
	  FROM   #LoadDimInstSession
	option (label = 'DWInst.DimInstSession_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWInst.DimInstSession_Insert', @rc = @RowsInserted out

	set @totalRowsInserted += @RowsInserted - @RowsUpdated
	set @totalRowsUpdated += @RowsUpdated

	commit tran
	select @totalRowsInserted as RowsInserted, @totalRowsUpdated as RowsUpdated

	end



GO


