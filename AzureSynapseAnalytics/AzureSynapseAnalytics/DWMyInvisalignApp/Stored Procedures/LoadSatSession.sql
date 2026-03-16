CREATE PROC [DWMyInvisalignApp].[LoadSatSession] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [int] AS
begin
	set xact_abort on


	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	Select @IsForceFullLoad  = COALESCE(@IsForceFullLoad, 0)

	if object_id('tempdb..#TempSatSession') is not null
	drop table #TempSatSession


	create table #TempSatSession with (distribution = round_robin, heap) as 
		Select 
			hs.SKSession,
			s.ADLSBatchID						as ADLSBatchID,
			s.ADLSTimestamp					as ADLSTimestamp,
			s.LZBatchID						as LZBatchID,
			convert(char(40), '')				as DWHash,
			s.SessionTimestamp,
			s.DeviceCategory,
			s.DeviceBrandName    ,
			s.DeviceModelName    ,
			s.DeviceMarketingName,
			s.DeviceOSHardwareModel,
			s.DeviceOS        ,
			s.DeviceOSVersion ,
			s.AppVersion      ,
			s.AppInstallSource
		FROM (
			Select TOP 1 WITH TIES
				s.event_params_ga_session_id,
				s.user_pseudo_id,
				s.ADLSBatchID					as ADLSBatchID,
				s.ADLSTimestamp					as ADLSTimestamp,
				s.LZBatchID						as LZBatchID,
				s.event_timestamp               as SessionTimestamp,
				JSON_VALUE(s.device,'$.category') as DeviceCategory,
				JSON_VALUE(s.device,'$.mobile_brand_name') AS DeviceBrandName    ,
				JSON_VALUE(s.device,'$.mobile_model_name') AS DeviceModelName    ,
				JSON_VALUE(s.device,'$.mobile_marketing_name') AS DeviceMarketingName,
				JSON_VALUE(s.device,'$.mobile_os_hardware_model') AS DeviceOSHardwareModel,
				JSON_VALUE(s.device,'$.operating_system') AS DeviceOS        ,
				JSON_VALUE(s.device,'$.operating_system_version') AS DeviceOSVersion ,
				JSON_VALUE(s.app_info,'$.version') AS AppVersion      ,
				JSON_VALUE(s.app_info,'$.install_source') AS AppInstallSource
			from SrcGoogleBigQuery.MyInvisalignAppOther s
			where s.event_name='session_start'
			and s.event_params_ga_session_id IS NOT NULL
			and s.user_pseudo_id IS NOT NULL
			and ( s.ADLSTimestamp>=@LastSuccessfullDWTimestamp OR @IsForceFullLoad=1)
			ORDER BY ROW_NUMBER() OVER (PARTITION BY s.event_params_ga_session_id,s.user_pseudo_id ORDER BY s.event_timestamp DESC)
			) s
		JOIN DWMyInvisalignApp.HubSession hs on hs.KeyTrace = s.event_params_ga_session_id and hs.KeyUser = s.user_pseudo_id



	update #TempSatSession set DWHash=
		convert(char(40),
			hashbytes('SHA1',
						ISNULL(convert(nvarchar,SessionTimestamp),'')
					+'|'+ISNULL(convert(nvarchar,DeviceCategory),'')
					+'|'+ISNULL(convert(nvarchar,DeviceBrandName),'')
					+'|'+ISNULL(convert(nvarchar,DeviceModelName),'')
					+'|'+ISNULL(convert(nvarchar,DeviceMarketingName),'')
					+'|'+ISNULL(convert(nvarchar,DeviceOSHardwareModel),'')
					+'|'+ISNULL(convert(nvarchar,DeviceOS),'')
					+'|'+ISNULL(convert(nvarchar,DeviceOSVersion),'')
					+'|'+ISNULL(convert(nvarchar,AppVersion),'')
				)
			,2)



	--   Create Unknow Element in case there is none
	if not exists (select * from DWMyInvisalignApp.SatSession where SKSession = -1)
	begin
		declare @Hash char(40) = ''
		insert into DWMyInvisalignApp.SatSession (
				SKSession,
				ADLSBatchID,
				ADLSTimestamp,
				LZBatchID,
				DWBatchID,
				DWHash,
                SessionTimestamp,
                DeviceCategory,
                DeviceBrandName    ,
                DeviceModelName    ,
                DeviceMarketingName,
                DeviceOSHardwareModel,
                DeviceOS        ,
                DeviceOSVersion ,
                AppVersion      ,
                AppInstallSource

		)
		Select
				-1 as SKSession,
				-1 as ADLSBatchID,
				'2000-01-01' as ADLSTimestamp,
				0 as LZBatchID,
				0 as DWBatchID,
				@Hash as DWHash,
				1595440523624000 as SessionTimestamp ,
				NULL as DeviceCategory,
				NULL as DeviceBrandName,
				NULL as DeviceModelName,
				NULL as DeviceMarketingName,
				NULL as DeviceOSHardwareModel,
				NULL as DeviceOS,
				NULL as DeviceOSVersion,
				NULL as AppVersion,
				NULL as AppInstallSource
		
	end
	--  End  createing unknow element

	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update DWMyInvisalignApp.SatSession
		set
		    ADLSBatchID = src.ADLSBatchID,
			ADLSTimestamp = src.ADLSTimestamp,
			LZBatchID = src.LZBatchID,
			DWBatchID = @BatchID,
			DWHash = src.DWHash,
            DeviceCategory=src.DeviceCategory,
            DeviceBrandName= src.DeviceBrandName   ,
            DeviceModelName= src.DeviceModelName   ,
            DeviceMarketingName= src.DeviceMarketingName,
            DeviceOSHardwareModel= src.DeviceOSHardwareModel,
            DeviceOS= src.DeviceOS  ,
            DeviceOSVersion= src.DeviceOSVersion,
            AppVersion= src.AppVersion      ,
            AppInstallSource= src.AppInstallSource
	from #TempSatSession src
	where DWMyInvisalignApp.SatSession.SKSession = src.SKSession
		and DWMyInvisalignApp.SatSession.DWHash != src.DWHash
	option (label = 'DWMyInvisalignApp.LoadSatSession');
	
	exec CTRL.GetLastRowCount @Label = 'DWMyInvisalignApp.LoadSatSession', @rc = @RowsUpdated out


	--INSERT new rows
	INSERT DWMyInvisalignApp.SatSession (
		SKSession,
		ADLSBatchID,
		ADLSTimestamp,
		LZBatchID,
		DWBatchID,
		DWHash,
        SessionTimestamp,
        DeviceCategory,
        DeviceBrandName    ,
        DeviceModelName    ,
        DeviceMarketingName,
        DeviceOSHardwareModel,
        DeviceOS        ,
        DeviceOSVersion ,
        AppVersion      ,
        AppInstallSource
		)
	SELECT
		SKSession,
		ADLSBatchID,
		ADLSTimestamp,
		LZBatchID,
		@BatchID as DWBatchID,
		DWHash,
        SessionTimestamp,
        DeviceCategory,
        DeviceBrandName    ,
        DeviceModelName    ,
        DeviceMarketingName,
        DeviceOSHardwareModel,
        DeviceOS        ,
        DeviceOSVersion ,
        AppVersion      ,
        AppInstallSource
	from #TempSatSession src
	where not exists(
		select dst.SKSession
		from DWMyInvisalignApp.SatSession dst 
		where dst.SKSession = src.SKSession
	)
	option (label = 'DWMyInvisalignApp.LoadSatSession');

	exec CTRL.GetLastRowCount @Label = 'DWMyInvisalignApp.LoadSatSession', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end --procedure