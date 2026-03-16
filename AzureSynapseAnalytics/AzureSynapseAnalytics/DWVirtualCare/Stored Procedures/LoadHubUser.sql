CREATE PROC [DWVirtualCare].[LoadHubUser] 
	@BatchID [int],
	@LastSuccessfullDWTimestamp [datetime2](0)
AS 
BEGIN
	set xact_abort on

	declare
		@RowsInserted	int = 0,
		@RowsUpdated	int = 0,
		@dt datetime=getdate()

	if object_id('tempdb..#TempHubUser') is not null
	drop table #TempHubUser

	Create table #TempHubUser (
		KeyUser nvarchar(100),
		KeyClinID nvarchar(100)
	)
	with (distribution = round_robin, heap) 

	INSERT #TempHubUser (KeyUser,KeyClinID)
	SELECT 
		t.patient_id,
		t.ClinID
	FROM (
		SELECT 
			patient.uuid AS patient_id,
			CASE WHEN CHARINDEX ('$',patient.clin_id)>0 THEN SUBSTRING( patient.clin_id,0,CHARINDEX ('$',patient.clin_id))
					ELSE patient.clin_id
				END	as ClinId
			FROM [SrcKafkaHeroku].[user_profile_event] patient
			WHERE   patient.clin_id IS NOT NULL
				and patient.uuid IS NOT NULL
				and patient.app_name = 'user-profile-api'
				and patient.user_type = 'patient'
				and patient.ADLSTimestamp > @LastSuccessfullDWTimestamp
			GROUP BY patient.uuid, patient.clin_id
		) as t
	group by t.patient_id,t.clinid

	--insert new keys to hub
	insert into DWVirtualCare.HubUser
	(
        KeyUser	,
		KeyClinID	,
		SKContact,
		DWBatchID	,
		InsertDateTime,
		RegionGroup
	)
	select 
        T.KeyUser,
		T.KeyClinID,
		c.SKContact,
		@BatchID,
		@dt ,
		c.MailingRegionGroup as RegionGroup
	from #TempHubUser  T
	JOIN DW.DimContact c on c.ClinID= T.KeyClinID
	LEFT JOIN DWVirtualCare.HubUser H on H.KeyUser=T.KeyUser and H.KeyClinID=T.KeyClinID
	where H.KeyUser IS NULL and T.KeyUser IS NOT NULL
	option (label = 'DWVirtualCare.LoadHubUser');

	exec CTRL.GetLastRowCount @Label = 'DWVirtualCare.LoadHubUser', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

END