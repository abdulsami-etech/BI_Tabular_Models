CREATE PROC [DWTOPS].[LoadFactLotAFABLeadTime] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS

begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@IsFullLoad		bit = 0
	

	if not exists (select * from DWTOPS.FactLotAFABLeadTime)
		set @IsFullLoad = 1

	IF OBJECT_ID('Stage.Temp_AFABLeadTime_WorkingTrackedObjHistory','U') IS NOT NULL
	DROP TABLE Stage.Temp_AFABLeadTime_WorkingTrackedObjHistory
	
	IF OBJECT_ID('Stage.Temp_FinalAFABLeadTime','U') IS NOT NULL
	DROP TABLE Stage.Temp_FinalAFABLeadTime


	--Get the Distinct Lot History from last Run
	CREATE TABLE Stage.Temp_AFABLeadTime_WorkingTrackedObjHistory
	WITH (
		DISTRIBUTION = HASH([tobj_key]),
		CLUSTERED COLUMNSTORE INDEX
	)  
	AS
	SELECT 
		 a.[ADLSBatchID]
		,a.[ADLSTimestamp]
		,a.[LZBatchID]
		,a.[tobj_history_key] 
		,a.[tobj_key] 
		,d.[at_Plant_S] as KeyPlant
		,d.[at_Country_S] as KeyCountryCode
		,ISNULL(CONVERT(VARCHAR(8), a.[complete_time_u], 112), -1) AS [SKCompleteDate]
		,c.creation_time_u as LotCreationTime
		,a.[complete_time_u] as ShippingInspectionTime
		,d.[at_TreatmentOption_S] as TreatmentOption
		,d.at_TreatmentCategory_S as TreatmentCategory
		FROM [SrcMES_AFAB_MX1].[tracked_object_history]  as a
		inner join [SrcMES_AFAB_MX1].[LOT]  as c
		on c.[lot_key]=a.[tobj_key]
		inner join [SrcMES_AFAB_MX1].[UDA_Order] as d
		on d.object_key=c.order_key
	    where a.complete_time_u >= '2019-01-01' and 
		      a.op_name ='Shipping Inspection' AND  a.complete_reason ='OK' 
				and (
						@IsFullLoad = 1
					or	a.ADLSTimestamp >= isnull(@LastSuccessfullDWTimestamp, '19000101')
				)

		UNION ALL  -----Union plant 1 and plant 2

     	SELECT 
		 a.[ADLSBatchID]
		,a.[ADLSTimestamp]
		,a.[LZBatchID]
		,a.[tobj_history_key] 
		,a.[tobj_key] 
		,d.[at_Plant_S] as KeyPlant
		,d.[at_Country_S] as KeyCountryCode
		,ISNULL(CONVERT(VARCHAR(8), a.[complete_time_u], 112), -1) AS [SKCompleteDate]
		,c.creation_time_u as LotCreationTime
		,a.[complete_time_u] as ShippingInspectionTime
		,d.[at_TreatmentOption_S] as TreatmentOption
		,d.at_TreatmentCategory_S as TreatmentCategory
		FROM [SrcMES_AFAB_MX2].[tracked_object_history]  as a
		inner join [SrcMES_AFAB_MX2].[LOT]  as c
		on c.[lot_key]=a.[tobj_key]
		inner join [SrcMES_AFAB_MX2].[UDA_Order] as d
		on d.object_key=c.order_key
	    where a.complete_time_u >= '2019-01-01' and 
		      a.op_name ='Shipping Inspection' AND  a.complete_reason ='OK' 
				and (
						@IsFullLoad = 1
					or	a.ADLSTimestamp >= isnull(@LastSuccessfullDWTimestamp, '19000101')
				)

--------#Getting Keys into Final table
		   
	CREATE TABLE Stage.Temp_FinalAFABLeadTime
	WITH (
		DISTRIBUTION = HASH([DgnLotKey]), heap
		 )  
	AS
			SELECT a.ADLSBatchID,
				a.ADLSTimestamp,
				a.LZBatchID,
			    a.ShippingInspectionTime AS [DgnCompleteDateTime],
				a.[tobj_key] as [DgnLotKey],
				ISNULL(b.[SKPlant],-1) as [SKPlant],
				ISNULL(CONVERT(VARCHAR(8), a.ShippingInspectionTime, 112), -1) AS [SKCompleteDate],
				ISNULL(c.[SKCountry],-1) as [SKCountry],
	            a.TreatmentOption,
				a.TreatmentCategory,
			    ISNULL(datediff(hour,a.LotCreationTime, a.ShippingInspectionTime ),0)  AS [LeadTimeHour]

			FROM
				Stage.Temp_AFABLeadTime_WorkingTrackedObjHistory as a
				Left join [DWTOPS].[DimPlant] as b
				on a.KeyPlant=b.KeyPlant
				left join [DW].[DimCountry] as c
				on c.[CountryCode]=a.KeyCountryCode

	begin tran


------------Delete Existing rows----------

   DELETE FROM [DWTOPS].[FactLotAFABLeadTime]
	WHERE EXISTS (
		SELECT * FROM Stage.Temp_FinalAFABLeadTime s
		WHERE s.[DgnLotKey] = [DWTOPS].[FactLotAFABLeadTime].[DgnLotKey]
	)

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotAFABLeadTime_Delete', @rc = @RowsUpdated out
	
	INSERT INTO [DWTOPS].[FactLotAFABLeadTime]
			   ([ADLSBatchID]
			   ,[ADLSTimestamp]
			   ,[LZBatchID]
			   ,[DWBatchID]
			   ,[DgnCompleteDateTime]
			   ,[DgnLotKey]
			   ,[SKPlant]
			   ,[SKCompleteDate]
			   ,[SkCountry]
			   ,[TreatmentOption]
			   ,[TreatmentCategory]
			   ,[LeadTimeHour])
		Select 
			    [ADLSBatchID]
			   ,[ADLSTimestamp]
			   ,[LZBatchID]
			   ,@BatchId
			   ,[DgnCompleteDateTime]
			   ,[DgnLotKey]
			   ,[SKPlant]
			   ,[SKCompleteDate]
			   ,[SkCountry]
			   ,[TreatmentOption]
			   ,[TreatmentCategory]
			   ,[LeadTimeHour]
		from Stage.Temp_FinalAFABLeadTime

		option (label = 'DWTOPS.LoadFactLotAFABLeadTime_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotAFABLeadTime_Insert', @rc = @RowsInserted out

	commit tran

	IF OBJECT_ID('Stage.Temp_AFABLeadTime_WorkingTrackedObjHistory','U') IS NOT NULL
	DROP TABLE Stage.Temp_AFABLeadTime_WorkingTrackedObjHistory
	
	IF OBJECT_ID('Stage.Temp_FinalAFABLeadTime','U') IS NOT NULL
	DROP TABLE Stage.Temp_FinalAFABLeadTime

	select @RowsInserted - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated

END