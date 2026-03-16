CREATE PROC [DWVirtualCare].[LoadSatUser]
	@BatchID [int],
	@LastSuccessfullDWTimestamp [datetime2](0),
	@IsForceFullLoad [bit]
AS
BEGIN
	set xact_abort on


	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0


	if object_id('tempdb..#TempSatUser') is not null
	drop table #TempSatUser

	create table #TempSatUser with (distribution = round_robin, heap) as
    Select
        u.[SKUser],
        pn.[ADLSBatchID],
        pn.[ADLSTimestamp],
        pn.[LZBatchID],
        convert(char(40), '') as [DWHash],
        COALESCE(pn.DeliverableType,pn.product_name) as [ProductName],
		pn.vip_patient_id,
		pn.[SKOrder]
    FROM DWVirtualCare.HubUser u
	/* last update for each user */
    JOIN (
		Select
			ROW_NUMBER() over (
				partition by v.uuid
				order by  COALESCE(
							TRY_CONVERT(datetime, LEFT(v.updated_date, 19), 120),
							TRY_CONVERT(datetime, LEFT(v.created_date, 19), 120)
						) DESC,
						o.SubmitDate
				) as R
			,v.uuid
			,v.ADLSTimestamp
			,CASE WHEN COALESCE(v.product_name,'')<>'' THEN v.product_name END as product_name
			,v.ADLSBatchID
			,v.LZBatchID
			,v.vip_patient_id
			,o.SKOrder
			,o.DeliverableType
		from [SrcKafkaHeroku].[user_profile_event] v
		LEFT JOIN [DW].[DimOrderIDS] o
			on v.vip_patient_id=convert(char(64), hashbytes('sha2_256', convert(varchar, o.PatientVIPID)), 2)
			and o.TreatmentCategory='Primary'
			and o.CancellationDate IS NULL
		where v.app_name='user-profile-api'
		and (v.ADLSTimestamp>=@LastSuccessfullDWTimestamp or @IsForceFullLoad=1)
    ) as pn
    on u.KeyUser=pn.uuid and pn.R=1

    update #TempSatUser set DWHash=
	convert(char(40),
		hashbytes('SHA1',
					ISNULL(convert(nvarchar,ProductName),'')
					+'|'+ISNULL(convert(nvarchar,vip_patient_id),'')
					+'|'+ISNULL(convert(nvarchar,SKOrder),'')
			)
		,2)


	--   Create Unknow Element in case there is none
	if not exists (select * from DWVirtualCare.SatUser where SKUser = -1)
	begin
		declare @Hash char(40) = ''
		insert into DWVirtualCare.SatUser (
				SKUser,
				ADLSBatchID,
				ADLSTimestamp,
				LZBatchID,
				DWBatchID,
				DWHash,
				ProductName
		)
		Select
				-1 as SKUser,
				-1 as ADLSBatchID,
				'2000-01-01' as ADLSTimestamp,
				0 as LZBatchID,
				0 as DWBatchID,
				@Hash as DWHash,
				NULL as ProductName
	end
	--  End  createing unknow element


		-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update DWVirtualCare.SatUser
		set
		     ADLSBatchID = src.ADLSBatchID,
			ADLSTimestamp = src.ADLSTimestamp,
			LZBatchID = src.LZBatchID,
			DWBatchID = @BatchID,
			DWHash = src.DWHash,
			ProductName = src.ProductName,
			vip_patient_id = src.vip_patient_id,
		    SKOrder = src.SKOrder
	from #TempSatUser src
	where DWVirtualCare.SatUser.SKUser = src.SKUser
		and DWVirtualCare.SatUser.DWHash != src.DWHash
	option (label = 'DWVirtualCare.LoadSatUser');
	
	exec CTRL.GetLastRowCount @Label = 'DWVirtualCare.LoadSatUser', @rc = @RowsUpdated out

		--INSERT new rows
	INSERT DWVirtualCare.SatUser (
		SKUser,
		ADLSBatchID,
		ADLSTimestamp,
		LZBatchID,
		DWBatchID,
		DWHash,
		ProductName,
        vip_patient_id,
	    SKOrder
		)
	SELECT
		SKUser,
		ADLSBatchID,
		ADLSTimestamp,
		LZBatchID,
		@BatchID as DWBatchID,
		DWHash,
		ProductName,
	    vip_patient_id,
	    SKOrder
	from #TempSatUser src
	where not exists(
		select dst.SKUser
		from DWVirtualCare.SatUser dst 
		where dst.SKUser = src.SKUser
	)
	option (label = 'DWVirtualCare.LoadSatUser');

	exec CTRL.GetLastRowCount @Label = 'DWVirtualCare.LoadSatUser', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

END