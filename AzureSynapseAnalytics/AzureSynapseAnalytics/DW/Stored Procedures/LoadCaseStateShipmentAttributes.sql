CREATE PROC [DW].[LoadCaseStateShipmentAttributes] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	declare @RowsInserted		int = 0
		,	@RowsUpdated		int = 0
		,	@totalRowsInserted	int = 0
		,	@totalRowsUpdated	int = 0

	if not exists (select * from [DW].CaseStateShipmentAttributes) or @IsForceFullLoad=1
	Begin
		SET @LastSuccessfullDWTimestamp = getutcdate()-30
	end
	else
	begin
		select @LastSuccessfullDWTimestamp=max(startDate) from [DW].CaseStateShipmentAttributes
	end


	if object_id('DW.Temp_ShipmentActualDuration','U') is not null
    drop table DW.Temp_ShipmentActualDuration

	
	create table [DW].Temp_ShipmentActualDuration (SAPOrderNumber bigint not null ) with (distribution = round_robin, heap)
	ALTER TABLE [DW].Temp_ShipmentActualDuration ADD CONSTRAINT PK_Temp_ShipmentActualDuration PRIMARY KEY NONCLUSTERED (SAPOrderNumber) NOT ENFORCED

	Insert into [DW].Temp_ShipmentActualDuration (SAPOrderNumber)
	select distinct sapordernumber 
	from dw.casestatehistory 
	where (completetime_utc>=@LastSuccessfullDWTimestamp)
	and orderstatus='Shipping Inspection'


	if object_id('DW.Temp_CaseStateShipmentAttributes','U') is not null
    drop table DW.Temp_CaseStateShipmentAttributes
	CREATE TABLE [DW].[Temp_CaseStateShipmentAttributes] 
		(
				[DWBatchID] Int not null,
				[SAPOrderNumber] [int] NOT NULL,
				[StartDate] [datetime] NOT NULL,
				[ScanType] [nvarchar](400) NULL,
				[ProductType] [nvarchar](400) NULL,
				[Region] [nvarchar](400) NULL,
				[Arches] [nvarchar](400) NULL,
				[Backlog] [int] NULL,
				[Capacity] [int] NULL,
				[ComplianceIndicator] [int] NULL,
				[MassFinisher] [int] NULL,
				[WeekNumber] [int] NULL,
				[DayNumberOfWeek] [int] NULL,
				[Stages] [int] NULL,
				[FABMachineCount] [int] NULL,
				[Expedite] [nvarchar](1000) NULL,
				[FABHourCapacity] [int] NULL,
				[AFABMachineCount] [int] NULL,
				[Rework] [int] NULL,
				[PredictedTime] [real] NULL,
				[ActualTime] [real] NULL,
				[BacklogFactor] [real] NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([SAPOrderNumber]))

		INSERT INTO [DW].Temp_CaseStateShipmentAttributes
           (
			   [DWBatchID]
              ,[SAPOrderNumber]
			  ,[StartDate]
			  ,[ScanType]
			  ,[ProductType]
			  ,[Region]
			  ,[Arches]
			  ,[Backlog]
			  ,[Capacity]
			  ,[ComplianceIndicator]
			  ,[MassFinisher]
			  ,[WeekNumber]
			  ,[DayNumberOfWeek]
			  ,[Stages]
			  ,[FABMachineCount]
			  ,[Expedite]
			  ,[FABHourCapacity]
			  ,[AFABMachineCount]
			  ,[Rework]
			  ,[PredictedTime]
			  ,[ActualTime]
			  ,[BacklogFactor]
		   )
		select 
		@BatchID,
		SAPOrderNumber,
		StartDate,
		ScanType,
		ProductType,
		Region,
		Arches,
		Backlog,
		CapaCity,
		ComplianceIndicator,
		MassFinisher,
		WeekNumber,
		DayNumberofWeek,
		Stages,
		FABMachineCount ,
		Expedite,
		FABHourCapacity,
		AFABMachieCount,
		Rework,
		PredictedTime,
		ActualTime,
		BacklogFactor
		from (
		select
		a.DWBatchID,
		a.SAPOrderNumber as SAPOrderNumber,
		a.startTime_UTC as StartDate,
		isnull(b.scan_type__C,'') as ScanType,
		isnull(b.AMR_product_type__C,'') as ProductType,
		isnull(b.Promotion_region__C,'') as Region,
		isnull(c.at_TreatedArch_s,'') as Arches,
		isnull(backlog.totalquantity,0) as Backlog,
		isnull(cap.Capacity,0) as CapaCity,
		ComplianceIndicator = 0,
		MassFinisher = 0,
		dt.weekofyear as WeekNumber,
		dt.DayNumberofWeek as DayNumberofWeek,
		isnull(b.lower_Quantity__C,0)+isnull(b.Upper_Quantity__C,0) as Stages,
		isnull(fabMX1.FABMachineCount,0) + isnull(fabMX2.FABMachineCount,0) as FABMachineCount ,
		isnull(b.Delivery_Priority__c,'NULL') as Expedite,
		isnull(AfabMX1.Capacity,0) + isnull(AfabMX2.Capacity,0) as FABHourCapacity,
		isnull(AfabMX1.AFABMachieCount,0) + isnull(AfabMX2.AFABMachieCount,0) as AFABMachieCount,
		Rework = 0,
		PredictedTime = 0,
		ActualTime = 0,
		isnull(cast(backlog.totalquantity/cap.Capacity as decimal(10,2)),0.0) as BacklogFactor,
		row_number() over(partition by a.sapordernumber order by a.historykey) as RowNum
		from dw.casestatehistory a
		inner join [SrcSFDC].[Apttus_Config2__Order__c] b 
		on a.[SAPOrderNumber] = b.sap_order_id__C
		inner join srcMEScorp.uda_order c on c.at_vipordernumber_S = b.vip_order_id__C
		inner join dw.dimdate dt on dt.keydate = cast(a.starttime_utc as date) 
		left join (
					select cast(a.starttime_utc as date) as Shipdate,sum(isnull(b.lower_Quantity__C,0)+isnull(b.Upper_Quantity__C,0)) as Capacity
					from dw.casestateHistory a
					inner join [SrcSFDC].[Apttus_Config2__Order__c] b 
					on a.[SAPOrderNumber] = b.sap_order_id__C
					where a.orderstatus='Shipping Inspection'
					group by cast(a.starttime_utc as date)
		) as cap on cap.Shipdate = dateadd(day,-1,dt.keydate)
		left join (
					select count(distinct [location]) As FABMachineCount, cast([trx_time] as date) As StartDate
					FROM [SrcMES_FAB_MX1].[ALGN_CARRIER_EVENT]
					group by  cast([trx_time] as date)
				  ) fabMX1 on fabMX1.StartDate = dateadd(day,-1,dt.keydate)
		left join(	select count(distinct [location]) As FABMachineCount, cast([trx_time] as date) As StartDate
					FROM [SrcMES_FAB_MX2].[ALGN_CARRIER_EVENT]
					group by  cast([trx_time] as date)
				)as FabMX2 on fabMX2.StartDate = dateadd(day,-1,dt.keydate)
		left join (
					select SUM (tm.Afabhour) As Capacity, count(tm.ProductionLine) As AFABMachieCount, Startdate
					from
					(select DATEDIFF(hour,min([start_time]), max([start_time])) As Afabhour  , p_line_name  As ProductionLine, 
					cast([start_time] As Date) As Startdate from 
					[SrcMES_AFAB_MX1].[TRACKED_OBJECT_HISTORY] --WHERE cast([start_time] As Date) 
					group by p_line_name, cast([start_time] As Date)
					) tm
					group by Startdate
					) AFABMX1 on AFABMX1.startdate = dateadd(day,-1,dt.keydate)
		left join (
					select SUM (tm.Afabhour) As Capacity, count(tm.ProductionLine) As AFABMachieCount, Startdate
					from
					(select DATEDIFF(hour,min([start_time]), max([start_time])) As Afabhour  , p_line_name  As ProductionLine, 
					cast([start_time] As Date) As Startdate from 
					[SrcMES_AFAB_MX1].[TRACKED_OBJECT_HISTORY] --WHERE cast([start_time] As Date) 
					group by p_line_name, cast([start_time] As Date)
					) tm
					group by Startdate
				  )AFABMX2 on AFABMX2.startDate = dateadd(day,-1,dt.keydate)
		left join (
					select dt.keydate as startdate,sum(isnull(b.lower_Quantity__C,0)+isnull(b.Upper_Quantity__C,0)) as TotalQuantity
					from dw.casestatehistory a
					inner join [SrcSFDC].[Apttus_Config2__Order__c] b 
					on a.[SAPOrderNumber] = b.sap_order_id__C
					inner join dw.dimdate dt on dt.keydate between cast(a.starttime_utc as date)  and isnull(b.shipped_date1__C,getdate())
					and a.sourceSystem in ('IDS')
					and a.orderstatus in ('ClinCheckAccepted','FirstSevenTreatmentPurchased')
					group by dt.keydate
		) backlog on backlog.startdate = dateadd(day,-1,dt.keydate)
		where (a.starttime_utc>=@LastSuccessfullDWTimestamp) 
		and a.sourceSystem in ('IDS')
		and a.orderstatus in ('ClinCheckAccepted','FirstSevenTreatmentPurchased')
		) final where rownum = 1




	begin tran
			INSERT INTO [DW].CaseStateShipmentAttributes
				   (
				   DWBatchID
				   ,[SAPOrderNumber]
				  ,[StartDate]
				  ,[ScanType]
				  ,[ProductType]
				  ,[Region]
				  ,[Arches]
				  ,[Backlog]
				  ,[Capacity]
				  ,[ComplianceIndicator]
				  ,[MassFinisher]
				  ,[WeekNumber]
				  ,[DayNumberOfWeek]
				  ,[Stages]
				  ,[FABMachineCount]
				  ,[Expedite]
				  ,[FABHourCapacity]
				  ,[AFABMachineCount]
				  ,[Rework]
				  ,[PredictedTime]
				  ,[ActualTime]
				  ,[BacklogFactor]
		
			   )
			   select 
		   			a.DWBatchID
				   ,a.[SAPOrderNumber]
				  ,a.[StartDate]
				  ,a.[ScanType]
				  ,a.[ProductType]
				  ,a.[Region]
				  ,a.[Arches]
				  ,a.[Backlog]
				  ,a.[Capacity]
				  ,a.[ComplianceIndicator]
				  ,a.[MassFinisher]
				  ,a.[WeekNumber]
				  ,a.[DayNumberOfWeek]
				  ,a.[Stages]
				  ,a.[FABMachineCount]
				  ,a.[Expedite]
				  ,a.[FABHourCapacity]
				  ,a.[AFABMachineCount]
				  ,a.[Rework]
				  ,a.[PredictedTime]
				  ,a.[ActualTime]
				  ,a.[BacklogFactor]
			from [DW].Temp_CaseStateShipmentAttributes a
			left join [DW].CaseStateShipmentAttributes b
			on a.sapordernumber = b.sapordernumber
			where b.sapordernumber is null
			option (label = 'DW.CaseStateShipmentAttributes_Insert');
			exec CTRL.GetLastRowCount @Label = 'DW.CaseStateShipmentAttributes_Insert', @rc = @RowsInserted out

		update a
		set ActualTime = isnull(b.ActualTime,0), 
		DWBatchid = @BatchID
		from [DW].CaseStateShipmentAttributes a
		inner join (
				select a.saporderNumber,datediff(hour,min(a.starttime_utc),max(completeTime_utc))/24.0 as ActualTime
				from dw.casestatehistory a
				inner join [DW].Temp_ShipmentActualDuration b on a.sapordernumber = b.sapordernumber
				where orderstatus in ('ClinCheckAccepted','FirstSevenTreatmentPurchased','Shipping Inspection')
				group by a.sapordernumber
				) b on a.sapordernumber = b.sapordernumber
		option (label = 'LoadCaseStateShipmentAttributes');
		exec CTRL.GetLastRowCount @Label = 'LoadCaseStateShipmentAttributes', @rc = @RowsUpdated out
commit tran	


	if object_id('DW.Temp_CaseStateShipmentAttributes', 'U') is not null
	drop table DW.Temp_CaseStateShipmentAttributes
	
	if object_id('DW.Temp_ShipmentActualDuration', 'U') is not null
	drop table DW.Temp_ShipmentActualDuration
	select @RowsInserted as RowsInserted,@RowsUpdated as RowsUpdated
End