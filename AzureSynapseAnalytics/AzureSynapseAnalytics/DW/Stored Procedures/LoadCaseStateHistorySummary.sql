CREATE PROC [DW].[LoadCaseStateHistorySummary] AS
declare @IsFullLoad [bit] = 0
		,   @RowsInserted		int = 0
		,	@RowsUpdated		int = 0
		,	@totalRowsInserted	int = 0
		,	@totalRowsUpdated	int = 0
if not exists(select * from [DW].CaseStateHistorySummary)
set @IsFullLoad = 1


		IF Object_id('DW.Temp_CaseStateHistorySummary', 'U') IS NOT NULL 
		DROP TABLE [DW].Temp_CaseStateHistorySummary
		
		CREATE TABLE [DW].[Temp_CaseStateHistorySummary](
				[DWBatchID] [int] NOT NULL,
				[SAPOrderNumber] [bigint] NOT NULL,
				[ClinID] [varchar](80) NULL,
				[Validated] [int] NOT NULL,
				[DetailStatus] [varchar](100) NULL,
				[DetailStatusBusinessTranslation] [varchar](500) NULL,
				[AggregateStatus] [varchar](200) NULL,
				[DoctorStatus] [varchar](200) NULL,
				[StartTime_UTC] [datetime] NULL,
				[EndTime_UTC] [datetime] NULL,
				[SequenceNumber] [bigint] NULL,
				[NumberofTimesInOperation] [int] NULL,
				[QueueName] [varchar](200) NULL,
				[OperationTimeInMinutes] [int] NULL,
				[OperationDeviationInMinutes] [int] NULL,
				[StatusIndicatorOfTimeSpentInCurrentStep] [int] NULL,
				[QueueTimeinMinutes] [int] NULL,
				[QueueDeviationInMinutes] [int] NULL,
				[StatusIndicatorOfTimespentInPreviousQueue] [int] NULL,
				[RecordLevel] [int] NOT NULL,
				[SourceSystem] [varchar](16) NULL,
				[SKCaseStateStatistic] [int] NULL,
				[EECDDate] [Datetime] NULL,
				[CCDDate] [Datetime] NULL,
				[HistoryKey] bigint null
				)
						WITH
				(
					DISTRIBUTION = HASH ( [SAPOrderNumber] ),
					CLUSTERED COLUMNSTORE INDEX
				)

	insert into [DW].[Temp_CaseStateHistorySummary] (
		  DWBatchID
		  ,[SAPOrderNumber]
		  ,[ClinID]
		  ,[Validated]
		  ,[DetailStatus]
		  ,[DetailStatusBusinessTranslation]
		  ,[AggregateStatus]
		  ,[DoctorStatus]
		  ,[StartTime_UTC]
		  ,[EndTime_UTC]
		  ,[SequenceNumber]
		  ,[NumberofTimesInOperation]
		  ,QueueName
		  ,[OperationTimeInMinutes]
		  ,[OperationDeviationInMinutes]
		  ,[StatusIndicatorOfTimeSpentInCurrentStep]
		  ,[QueueTimeinMinutes]
		  ,[QueueDeviationInMinutes]
		  ,[StatusIndicatorOfTimespentInPreviousQueue]
		  ,[RecordLevel]
		  ,[SourceSystem]
		  ,[SKCaseStateStatistic]
		  ,EECDDate
		  ,[CCDDate]
		  ,HistoryKey
		)
	select
		   a.[DWBatchID]
		  ,a.[SAPOrderNumber]
		  ,cs.ClinID
		  ,1 as Validated
		  ,a.OrderStatus as [DetailStatus]
		  ,b.BusinessTranslation as [DetailStatusBusinessTranslation]
		  ,case when a.OrderStatus='Asset Replication' and a.NumberofTimesInOperation>1 then 'Cases for CAD Designer Setup and Stage process' else b.InternalStatus end as [AggregateStatus]
		  ,case when a.OrderStatus='Asset Replication' and a.NumberofTimesInOperation>1 then 'Developing treatment plan' else b.DoctorStatus end as DoctorStatus
		  ,a.[StartTime_UTC]
		  ,a.[CompleteTime_UTC]
		  ,a.[SequenceNumber]
		  ,a.[NumberofTimesInOperation]
		  ,a.[QueueName]
		  ,case when a.[OperationTimeInMinutes] < 0 then 0 else isnull(a.[OperationTimeInMinutes],0) end as [OperationTimeInMinutes]
		  ,[OperationDeviationInMinutes] = isnull(co.Deviation2/60,0)
		  ,[StatusIndicatorOfTimeSpentInCurrentStep] = 1
		  ,case when a.[QueueTimeinMinutes] < 0 then 0 else isnull(a.[QueueTimeinMinutes],0) end as [QueueTimeinMinutes]
		  ,[QueueDeviationInMinutes] =  isnull(cq.Deviation2/60,0)
		  ,[StatusIndicatorOfTimespentInPreviousQueue] = 1
		  ,3 as RecordLevel-- Details
		  ,a.SourceSystem
		  ,a.SKCaseStateStatistic
		  ,cs.EECDDate
		  ,cs.CCDDate
		  ,a.HistoryKey
	from
	(
			select a.DWBatchid,
			a.sapordernumber,
			a.OrderStatus,
			a.HistoryKey,
			a.SourceSystem,
			a.StartTime_UTC,
			a.CompleteTime_UTC,
			a.[SKCaseStateStatistic],
			ROW_NUMBER() Over(Partition By a.SAPOrderNumber order by a.StartTime_UTC) as SequenceNumber,
			ROW_NUMBER() Over(Partition By a.SAPOrderNumber,a.SourceSystem,a.OrderStatus order by a.StartTime_UTC) as [NumberofTimesInOperation],
			a.[OrderStatus]+'-'+lead(a.[OrderStatus],1) over(partition by a.[SAPOrderNumber] order by a.[startTime_UTC]) as QueueName,
			DATEDIFF(Minute,a.StartTime_UTC,a.CompleteTime_UTC) as [OperationTimeInMinutes],
			[StatusIndicatorOfTimeSpentInCurrentStep] = 0,
			DATEDIFF(Minute,a.[completeTime_UTC],lead(a.[startTime_UTC],1) over(partition by a.[SAPOrderNumber] order by a.[startTime_UTC])) as [QueueTimeinMinutes]
			from [DWCaseMonitor].CaseStateHistory a
			where (@IsFullLoad=1 or a.DWBatchid >(select max(DWBatchid) from [DW].[CaseStateHistorySummary]))
	) a
	inner join  [Custom].[MappingTranslation] b on a.OrderStatus=b.CaseStatus and a.SourceSystem = b.SourceSystem
	inner join DW.[CaseState] cs on cs.sapordernumber=a.sapordernumber
	left join [DW].[CaseStateStatistics] co on a.SKCaseStateStatistic = co.SKCaseStateStatistic and a.OrderStatus = co.operationname and a.SourceSystem = co.SourceSystem
	left join [DW].[CaseStateStatistics] cq on a.SKCaseStateStatistic = cq.SKCaseStateStatistic and a.QueueName = cq.operationname and a.SourceSystem = cq.SourceSystem

----For Internal Status Record Level 2
;with Details as (
select saporderNumber,
StartTime_UTC,
EndTime_UTC,
AggregateStatus as InternalStatus,
DoctorStatus,
lead(AggregateStatus,1) over(partition by sapordernumber order by starttime_utc asc) as NextinternalStatus,
lag(AggregateStatus,1) over(partition by sapordernumber order by starttime_utc asc) as PreviousinternalStatus,
lead(DoctorStatus,1) over(partition by sapordernumber order by starttime_utc asc) as NextDoctorStatus,
lag(DoctorStatus,1) over(partition by sapordernumber order by starttime_utc asc) as PreviousDoctorStatus
from DW.Temp_CaseStateHistorySummary
)
,
NextInternalStatus as (
select SAPOrderNumber,
					EndTime_UTC,
					InternalStatus,
					DoctorStatus,
					case when PreviousinternalStatus = internalStatus then lag(StartTime_UTC,1) over(partition by sapordernumber order by starttime_utc asc)
					else StartTime_UTC end StartTime_UTC,
					case when isnull(PreviousinternalStatus,'') <> internalStatus then 1 else 0 end OperationCount, 
					ROW_NUMBER() over(partition by sapordernumber,internalstatus order by starttime_utc desc) as Rankrow 
from Details  
where (internalStatus <> isnull(NextinternalStatus,'')) or (internalStatus <> isnull(PreviousinternalStatus,''))
),
InternalStatus as
(select 
		b.sapordernumber,
		b.internalstatus,
		b.DoctorStatus,
		b.StartTime_UTC,
		b.EndTime_UTC as EndTime_UTC,
		op.NumberofTimesinOperation as NumberofTimesinOperation
from NextInternalStatus b
inner join (
			select 
				sapordernumber,
				internalstatus,
				DoctorStatus,
				Sum(OperationCount) as NumberofTimesinOperation 
			from NextInternalStatus b 
			group by sapordernumber,internalstatus,DoctorStatus
			)op 
on b.SAPOrderNumber = op.SAPOrderNumber and b.InternalStatus = op.InternalStatus
where b.rankrow =1
),

----
NextDoctorStatus as (select  saporderNumber,
case when PreviousDoctorStatus = DoctorStatus then lag(StartTime_UTC,1) over(partition by sapordernumber order by starttime_utc asc)
					else StartTime_UTC end StartTime_UTC,
case when isnull(PreviousDoctorStatus,'') <> DoctorStatus then 1 else 0 end OperationCount, 
EndTime_UTC,
DoctorStatus,
NextDoctorStatus,
PreviousDoctorStatus,
ROW_NUMBER() over(partition by sapordernumber,DoctorStatus order by starttime_utc desc) as Rankrow 
from Details  where (DoctorStatus <> isnull(NextDoctorStatus,'')) or (DoctorStatus <> isnull(PreviousDoctorStatus,''))
),
DoctorStatus as(
	select b.sapordernumber,
	b.DoctorStatus,
	b.startTime_UTC as startTime_UTC,
	b.EndTime_UTC as  CompleteTime_UTC,
	op.NumberofTimesinOperation as NumberofTimesinOperation
from NextDoctorStatus b
		inner join (
		select sapordernumber,
		DoctorStatus,
		Sum(OperationCount) as NumberofTimesinOperation 
		from NextDoctorStatus 
		group by sapordernumber,DoctorStatus
		)
op on b.SAPOrderNumber = op.SAPOrderNumber and b.DoctorStatus = op.DoctorStatus
where b.rankrow =1
)


insert into [DW].[Temp_CaseStateHistorySummary] (
	   DWBatchID
	  ,[SAPOrderNumber]
      ,[ClinID]
      ,[Validated]
      ,[DetailStatus]
      ,[DetailStatusBusinessTranslation]
      ,[AggregateStatus]
      ,[DoctorStatus]
      ,[StartTime_UTC]
      ,[EndTime_UTC]
      ,[SequenceNumber]
      ,[NumberofTimesInOperation]
	  ,QueueName
      ,[OperationTimeInMinutes]
      ,[OperationDeviationInMinutes]
      ,[StatusIndicatorOfTimeSpentInCurrentStep]
      ,[QueueTimeinMinutes]
      ,[QueueDeviationInMinutes]
      ,[StatusIndicatorOfTimespentInPreviousQueue]
      ,[RecordLevel]
      ,[SourceSystem]
	  ,[SKCaseStateStatistic]
	  ,[EECDDate]
	  ,CCDDate
	  ,Historykey
	)
select b.dwbatchid,
a.SAPOrderNumber,
b.ClinID,
b.Validated,
Null as DetailStatus,
Null as [DetailStatusBusinessTranslation],
a.InternalStatus as [AggregateStatus] ,
a.DoctorStatus,
a.startTime_UTC,
a.EndTime_UTC,
ROW_NUMBER() over(partition by a.sapordernumber order by starttime_utc) as [SequenceNumber],
NumberofTimesinOperation,
Null as QueueName,
b.OperationTimeInMinutes,
b.[OperationDeviationInMinutes],
[StatusIndicatorOfTimeSpentInCurrentStep] =1,
b.[QueueTimeinMinutes],
b.[QueueDeviationInMinutes],
[StatusIndicatorOfTimespentInPreviousQueue] = 1,
2 as RecordLevel,
Null as SourceSystem,
0 as skcasestatestatistics,
b.EECDDate,
b.CCDDate,
-1 as Historykey
from InternalStatus a
inner join (select sapordernumber,
					clinid,
					validated,
					[AggregateStatus] as internalstatus,
					doctorstatus,
					max(EECDDate) as EECDDate,
					max(CCDDate) as CCDDate,
					max(dwbatchid) as dwbatchid,
					sum([OperationTimeInMinutes]) as [OperationTimeInMinutes],
					sum([OperationDeviationInMinutes]) as [OperationDeviationInMinutes],
					sum([QueueTimeinMinutes]) as [QueueTimeinMinutes],
					sum([QueueDeviationInMinutes]) as [QueueDeviationInMinutes]
			from DW.Temp_CaseStateHistorySummary 
				group by 
				sapordernumber,[AggregateStatus],doctorstatus,ClinID,Validated
			) b on a.SAPOrderNumber = b.SAPOrderNumber and a.InternalStatus = b.InternalStatus and a.DoctorStatus=b.DoctorStatus


--- Populating Doctor Status Record Level 1
union all
select b.dwbatchid,
a.SAPOrderNumber,
b.clinid,
b.validated,
null as Detailstatus,
Null as [AggregateStatus],
Null as [DetailStatusBusinessTranslation],
a.DoctorStatus,
a.startTime_UTC,
a.CompleteTime_UTC,
ROW_NUMBER() over(partition by a.sapordernumber order by starttime_utc) as [SequenceNumber],
a.NumberofTimesinOperation,
Null as QueueName,
b.OperationTimeInMinutes,
b.[OperationDeviationInMinutes],
[StatusIndicatorOfTimeSpentInCurrentStep] = 1,
b.[QueueTimeinMinutes],
b.[QueueDeviationInMinutes],
[StatusIndicatorOfTimespentInPreviousQueue] = 1,
1 as RecordLevel,
NULL as SourceSystem,
0 as skcasestatestatistics,
b.EECDDate,
b.CCDDate,
-1 as Historykey
from DoctorStatus a
inner join (select 
				sapordernumber,
				DoctorStatus,
				clinid,
				validated,
				max(EECDDate) as EECDDate,
				max(CCDDate) as CCDDate,
				max(dwbatchid) as dwbatchid,
				sum([OperationTimeInMinutes]) as [OperationTimeInMinutes],
				sum([OperationDeviationInMinutes]) as [OperationDeviationInMinutes],
				sum([QueueTimeinMinutes]) as [QueueTimeinMinutes],
				sum([QueueDeviationInMinutes]) as [QueueDeviationInMinutes]
				from DW.Temp_CaseStateHistorySummary where recordlevel=3 
				group by 
				sapordernumber,DoctorStatus,clinid,validated
) b on a.SAPOrderNumber = b.SAPOrderNumber and a.DoctorStatus = b.DoctorStatus


if @IsFullLoad = 1
begin

			IF Object_id('[DW].CaseStateHistorySummaryPrevious', 'U') IS NOT NULL 
			  Drop Table [DW].DoctorCaseStateHistoryPrevious
		   	  rename object DW.CaseStateHistorySummary to CaseStateHistorySummaryPrevious
			  rename object  DW.Temp_CaseStateHistorySummary to CaseStateHistorySummary
			IF Object_id('DW.CaseStateHistorySummaryPrevious', 'U') IS NOT NULL 
			  DROP TABLE [DW].CaseStateHistorySummaryPrevious
		    CREATE NONCLUSTERED INDEX [ix_DoctorCaseState_DWBatchid] ON [DW].CaseStateHistorySummary
			([DWBatchid] ASC
			)
  
end
else
begin
Begin Tran
DELETE FROM [DW].CaseStateHistorySummary
		WHERE EXISTS (
			SELECT * FROM [DW].[Temp_CaseStateHistorySummary] s
			WHERE s.[SAPOrdernumber] = DW.CaseStateHistorySummary.[SAPOrdernumber]
		)
		option (Label = 'DW.CaseStateHistorySummary_Delete');

	exec CTRL.GetLastRowCount @Label = 'DW.CaseStateHistorySummary_Delete', @rc = @RowsUpdated out

insert into [DW].CaseStateHistorySummary( 	   
		DWBatchID
	  ,[SAPOrderNumber]
      ,[ClinID]
      ,[Validated]
      ,[DetailStatus]
      ,[DetailStatusBusinessTranslation]
      ,[AggregateStatus]
      ,[DoctorStatus]
      ,[StartTime_UTC]
      ,[EndTime_UTC]
      ,[SequenceNumber]
      ,[NumberofTimesInOperation]
	  ,QueueName
      ,[OperationTimeInMinutes]
      ,[OperationDeviationInMinutes]
      ,[StatusIndicatorOfTimeSpentInCurrentStep]
      ,[QueueTimeinMinutes]
      ,[QueueDeviationInMinutes]
      ,[StatusIndicatorOfTimespentInPreviousQueue]
      ,[RecordLevel]
      ,[SourceSystem]
	  ,[SKCaseStateStatistic]
	  ,EECDDate
	  ,CCDDate
	  ,HistoryKey
	  )
select 
	   DWBatchID
	  ,[SAPOrderNumber]
      ,[ClinID]
      ,[Validated]
      ,[DetailStatus]
      ,[DetailStatusBusinessTranslation]
      ,[AggregateStatus]
      ,[DoctorStatus]
      ,[StartTime_UTC]
      ,[EndTime_UTC]
      ,[SequenceNumber]
      ,[NumberofTimesInOperation]
	  ,QueueName
      ,[OperationTimeInMinutes]
      ,[OperationDeviationInMinutes]
      ,[StatusIndicatorOfTimeSpentInCurrentStep]
      ,[QueueTimeinMinutes]
      ,[QueueDeviationInMinutes]
      ,[StatusIndicatorOfTimespentInPreviousQueue]
      ,[RecordLevel]
      ,[SourceSystem]
	  ,[SKCaseStateStatistic]
	  ,EECDDate
	  ,CCDDate
	  ,HistoryKey
from [DW].Temp_CaseStateHistorySummary
option (label = 'DW.CaseStateHistorySummary_Insert');
exec CTRL.GetLastRowCount @Label = 'DW.CaseStateHistorySummary_Insert', @rc = @RowsInserted out

	set @totalRowsInserted += @RowsInserted - @RowsUpdated
	set @totalRowsUpdated += @RowsUpdated

	select @totalRowsInserted as RowsInserted, @totalRowsUpdated as RowsUpdated

commit Tran
end
GO


