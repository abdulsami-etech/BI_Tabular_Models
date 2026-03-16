CREATE PROC [DW].[LoadDimTrainingEventTypes] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0), @IsForceFullLoad [bit] AS
BEGIN
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@CurrentDate	datetime2(0) = getdate()

	if object_id('tempdb..#TempDimTrainingEventTypes') is not null
		drop table #TempDimTrainingEventTypes

	create table #TempDimTrainingEventTypes with (distribution = round_robin, heap) as 
	select	h.SKTrainingEventType
	,	e.Id					as KeyTrainingEventType
	,	convert(char(40), '')	as DWHash
	,	isnull(nullif(ltrim(e.Training_Code__c), N''), N'-') as TrainingEventTypeCode
	,	isnull(convert(nvarchar(50), e.Name), N'')	as TrainingEventTypeName
	,	isnull(nullif(ltrim(c.ProfEdEventType), N''), N'-') as ProfEdEventType
	,	isnull(nullif(c.CustomerAddressListExtendedGrouping, N''), N'-') as CustomerAddressListExtendedGrouping
	,	isnull(nullif(c.AudienceType, N''), N'-') as AudienceType
	,	convert(nvarchar(3), case when c.NewTraining = 1 then N'Yes' else N'No' end) as NewTraining
from [SrcSFDC].[Event__c] e
inner join [DW].[HubTrainingEventTypes] h on e.Id = h.KeyTrainingEventType
left join custom.TrainingEvents c  on c.TrainingEventCode = e.Training_Code__c
where isnull(e.Training_Code__c, N'Unk') != N'Unk'

	update #TempDimTrainingEventTypes set DWHash=
		convert(char(40),
			hashbytes('SHA1',
							 isnull(convert(nvarchar, [TrainingEventTypeCode]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [TrainingEventTypeName]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [ProfEdEventType]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [CustomerAddressListExtendedGrouping]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [AudienceType]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [NewTraining]), N'N/A')
				)
			, 2)

	if not exists (select * from DW.DimTrainingEventTypes where SKTrainingEventType = -1)
	begin
		declare @Hash char(40) = ''

		insert into DW.DimTrainingEventTypes (
				SKTrainingEventType
			,	KeyTrainingEventType
			,	DWBatchID
			,	DWHash
			,	TrainingEventTypeCode
			,	TrainingEventTypeName
			,	ProfEdEventType
			,	CustomerAddressListExtendedGrouping
			,	AudienceType
			,	NewTraining
			,	CreatedDate
			,	ModifiedDate
		)
		values (
				-1
			,	N'N/A'
			,	@BatchID
			,	@Hash
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	'19000101'
			,	'19000101'
		)
	end

	update DW.DimTrainingEventTypes
		set	DWBatchID = @BatchID
		,	DWHash = src.DWHash
		,	TrainingEventTypeCode = src.TrainingEventTypeCode
		,	TrainingEventTypeName = src.TrainingEventTypeName
		,	ProfEdEventType = src.ProfEdEventType
		,	CustomerAddressListExtendedGrouping = src.CustomerAddressListExtendedGrouping
		,	AudienceType = src.AudienceType
		,	NewTraining = src.NewTraining
		,	ModifiedDate = @CurrentDate
	from #TempDimTrainingEventTypes src
	where DW.DimTrainingEventTypes.SKTrainingEventType = src.SKTrainingEventType
		and DW.DimTrainingEventTypes.DWHash != src.DWHash
	option (label = 'DW.LoadDimTrainingEventTypes_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimTrainingEventTypes_Update', @rc = @RowsUpdated out



	insert into DW.DimTrainingEventTypes (
				SKTrainingEventType
			,	KeyTrainingEventType
			,	DWBatchID
			,	DWHash
			,	TrainingEventTypeCode
			,	TrainingEventTypeName
			,	ProfEdEventType
			,	CustomerAddressListExtendedGrouping
			,	AudienceType
			,	NewTraining
			,	CreatedDate
			,	ModifiedDate
	)
	select		src.SKTrainingEventType
			,	src.KeyTrainingEventType
			,	@BatchID
			,	src.DWHash
			,	src.TrainingEventTypeCode
			,	src.TrainingEventTypeName
			,	src.ProfEdEventType
			,	src.CustomerAddressListExtendedGrouping
			,	src.AudienceType
			,	src.NewTraining
			,	@CurrentDate
			,	@CurrentDate
	from #TempDimTrainingEventTypes src
	where not exists (select * from DW.DimTrainingEventTypes dst where dst.SKTrainingEventType = src.SKTrainingEventType)
	option (label = 'DW.LoadDimTrainingEventTypes_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimTrainingEventTypes_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
