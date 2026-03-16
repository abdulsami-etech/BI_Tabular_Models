Create PROC [DW].[LoadCaseStateHistory] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted		int = 0
		,	@RowsUpdated		int = 0
		,	@totalRowsInserted	int = 0
		,	@totalRowsUpdated	int = 0
		,	@IsFullLoad			bit = 0

	if not exists (select * from [DW].[CaseStateHistory])
		set @IsFullLoad = 1

	if object_id('tempdb..#LoadCaseStateHistory') is not null
		drop table #LoadCaseStateHistory

			
	create table #LoadCaseStateHistory with (distribution = hash([sapordernumber]), heap) 
	as 
		SELECT  
			   [sapordernumber], 
			   [orderstatus], 
			   [StartTime_UTC],
			   [CompleteTime_UTC],
			   [orderstatusdatetime_utc], 
			   [historykey], 
			   [sourcesystem] 
		FROM   [SrcIDS].[srcfactcasestatehistory] AS a 
		WHERE  ( @IsFullLoad = 1 
				  OR a.adlstimestamp >= Isnull(@LastSuccessfullDWTimestamp, '19000101') 
			   ) 
		UNION All
		SELECT
			   [sapordernumber], 
			   [orderstatus], 
			   [StartTime_UTC],
			   [CompleteTime_UTC],
			   [orderstatusdatetime_utc], 
			   [historykey], 
			   [sourcesystem] 
		FROM   [SrcMESCorp].[srcfactcasestatehistory] AS a 
		WHERE  ( @IsFullLoad = 1 
				  OR a.adlstimestamp >= Isnull(@LastSuccessfullDWTimestamp, '19000101') 
				 ) 
		UNION All
		SELECT
			   [sapordernumber], 
			   [orderstatus], 
			   [StartTime_UTC],
			   [CompleteTime_UTC],
			   [orderstatusdatetime_utc], 
			   [historykey], 
			   [sourcesystem] 
		FROM   [SrcMES_AFAB_MX1].[srcfactcasestatehistory] AS a 
		WHERE   ( @IsFullLoad = 1 
				  OR a.adlstimestamp >= Isnull(@LastSuccessfullDWTimestamp, '19000101') 
			   ) 
		UNION All
		SELECT 
			   [sapordernumber], 
			   [orderstatus], 
			   [StartTime_UTC],
			   [CompleteTime_UTC],
			   [orderstatusdatetime_utc], 
			   [historykey], 
			   [sourcesystem] 
		FROM   [SrcMES_AFAB_MX2].[srcfactcasestatehistory] AS a 
		WHERE    ( @IsFullLoad = 1 
				  OR a.adlstimestamp >= Isnull(@LastSuccessfullDWTimestamp, '19000101') 
			   ) 
		UNION All
		SELECT 
			   [sapordernumber], 
			   [orderstatus], 
			   [StartTime_UTC],
			   [CompleteTime_UTC],
			   [orderstatusdatetime_utc], 
			   [historykey], 
			   [sourcesystem] 
		FROM   [SrcMES_FAB_MX1].[srcfactcasestatehistory] AS a 
		WHERE  ( @IsFullLoad = 1 
				  OR a.adlstimestamp >= Isnull(@LastSuccessfullDWTimestamp, '19000101') 
			   ) 
		UNION All
		SELECT 
			   [sapordernumber], 
			   [orderstatus],
			   [StartTime_UTC],
			   [CompleteTime_UTC],
			   [orderstatusdatetime_utc], 
			   [historykey], 
			   [sourcesystem] 
		FROM   [SrcMES_FAB_MX2].[srcfactcasestatehistory] AS a 
		WHERE  ( @IsFullLoad = 1 
				  OR a.adlstimestamp >= Isnull(@LastSuccessfullDWTimestamp, '19000101') 
			   ) 

	;with CTE as (
				select *,row_number() over (partition by SAPOrderNumber,sourcesystem,historykey order by [StartTime_UTC] desc) as DuplicateCount 
				from #LoadCaseStateHistory
			)
	DELETE FROM CTE
	WHERE DuplicateCount > 1;

	   
	begin tran

	delete from [DW].[CaseStateHistory]
	where exists (
		select *
		from #LoadCaseStateHistory s
		where --s.SAPOrdernumber = DW.CaseStateHistory.SAPOrdernumber and --this one causes duplicates when the same history key comes with a different order #
		s.HistoryKey = DW.CaseStateHistory.HistoryKey
		and s.SourceSystem = DW.CaseStateHistory.SourceSystem
		
	)
	option (Label = 'DW.CaseStateHistory_Delete');

	exec CTRL.GetLastRowCount @Label = 'DW.CaseStateHistory_Delete', @rc = @RowsUpdated out


		
	
	INSERT INTO [DW].[CaseStateHistory]
           (
            [DWBatchID]
           ,[SAPOrdernumber]
           ,[OrderStatus]
		   ,[StartTime_UTC]
		   ,[CompleteTime_UTC]
           ,[OrderStatusDateTime_UTC]
           ,[HistoryKey]
           ,[SourceSystem]
		
		   )
	SELECT    
			   @BatchID,
			   [sapordernumber], 
			   [orderstatus], 
			   [StartTime_UTC],
		       [CompleteTime_UTC],
			   [orderstatusdatetime_utc], 
			   [historykey], 
			   [sourcesystem]
		
	FROM   #LoadCaseStateHistory
	--where  LatestRow=1
	option (label = 'DW.CaseStateHistory_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.CaseStateHistory_Insert', @rc = @RowsInserted out

	set @totalRowsInserted += @RowsInserted - @RowsUpdated
	set @totalRowsUpdated += @RowsUpdated

	commit tran

	if object_id('tempdb..#LoadCaseState') is not null
		drop table #LoadCaseState
		
	create table #LoadCaseState with (distribution = hash([SAPOrdernumber]), heap) 
        as 
		Select * from
			(
			SELECT 
				   a.[DWBatchID]
				  ,b.[ClinId__c] as  [ClinID]
				  ,b.[Treatment_Location_Number__c] as [DID]
				  ,b.[Treatment_ID_Number__c] as [TreatmentID]
				  ,a.[SAPOrdernumber]
				  ,b.[Name] as [SFDCOrderNumber]
				  ,b.[VIP_Order_ID__c] as [IDSOrderNumber]
				  ,b.Treatment_Category__C as [TreatmentCategory]
				  ,a.[OrderStatus] as [CurrentOrderStatus]
				  ,a.[OrderStatusDateTime_UTC]  as [CurrentOrderStatusDateTime_UTC]
				  ,b.[Product_Type__c] as [ProductType]
				  ,a.[SourceSystem]
				  ,tx.EECDDate
				  ,tx.CCDDate
				  ,ROW_NUMBER()OVER(partition by a.[SAPOrdernumber] order by a.[OrderStatusDateTime_UTC] desc ) as IsCurrent
			  FROM [DW].[CaseStateHistory] as a
			  left join srcsfdc.[Apttus_Config2__Order__c] as b 
			  on a.[SAPOrdernumber]= b.sap_order_id__c
			 left join (
							select tmap.jde_order_id as SAPOrderNumber,th.tx_EECD as EECDDate,th.tx_ccd as CCDDate from [SrcIDS].[tblputreatmentstatushistory] th
							inner join srcids.tblputreatmentstatus ts on th.Treatment_status_history_id=ts.Treatment_status_history_id
							inner join [SrcIDS].[tblPuTreatmentOrderMap] tord on tord.treatment_id=ts.treatment_id
							inner join [SrcIDS].[tblcnpatientordermap] tmap on tmap.vip_order_id = tord.vip_order_id
						)tx on tx.SAPOrderNumber = a.Sapordernumber
			 Where EXISTS (Select 1 from #LoadCaseStateHistory as l
			            where l.[sapordernumber]=a.[SAPOrdernumber])
			  ) as m
			  where m.IsCurrent=1

	begin tran

	delete from [DW].[CaseState]
	where exists (
		select *
		from #LoadCaseState s
		where s.SAPOrdernumber = DW.CaseState.SAPOrdernumber
	)
	option (Label = 'DW.CaseState_Delete');

	exec CTRL.GetLastRowCount @Label = 'DW.CaseState_Delete', @rc = @RowsUpdated out


	INSERT INTO [DW].[CaseState]
           (
            [DWBatchID]
           ,[ClinID]
           ,[DID]
           ,[TreatmentID]
           ,[SAPOrdernumber]
           ,[SFDCOrderNumber]
           ,[IDSOrderNumber]
           ,[TreatmentCategory]
           ,[CurrentOrderStatus]
           ,[CurrentOrderStatusDateTime_UTC]
           ,[ProductType]
           ,[SourceSystem]
		   ,[EECDDate]
		   ,[CCDDate]
		   )
	SELECT    
            @BatchID
           ,[ClinID]
           ,[DID]
           ,[TreatmentID]
           ,[SAPOrdernumber]
           ,[SFDCOrderNumber]
           ,[IDSOrderNumber]
           ,[TreatmentCategory]
           ,[CurrentOrderStatus]
           ,[CurrentOrderStatusDateTime_UTC]
           ,[ProductType]
           ,[SourceSystem]
		   ,[EECDDate]
		   ,[CCDDate]
		FROM   #LoadCaseState
		where [sapordernumber] is not null
		option (label = 'DW.CaseState_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.CaseState_Insert', @rc = @RowsInserted out

	set @totalRowsInserted += @RowsInserted - @RowsUpdated
	set @totalRowsUpdated += @RowsUpdated

	commit tran

	select @totalRowsInserted as RowsInserted, @totalRowsUpdated as RowsUpdated

end