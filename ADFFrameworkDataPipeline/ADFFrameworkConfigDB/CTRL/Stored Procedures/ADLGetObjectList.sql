/****** Object:  StoredProcedure [CTRL].[ADLGetObjectList]    Script Date: 12/10/2020 3:58:32 PM ******/

CREATE procedure [CTRL].[ADLGetObjectList] (
		@SourceSystem	varchar(32)
	,	@ObjectList		varchar(8000) = null
)
as 
begin
	set nocount on
	set xact_abort on

	declare @CurrentTimestamp datetime2(0)
	declare @ObjectsToProcess table (ObjectID int);  
--Used for SAP timestamp changes (Ref: Jira BI-10970) Date: 09/11/2020---
declare @CurrentTimestampSAP datetime2(0)
-----

	begin tran

	update CTRL.ADLObject with (tablockx)
		set Status = 'In Progress'
		,	DateUpdated = getdate()
	output inserted.ObjectID  
	into @ObjectsToProcess
	where SourceSystem = @SourceSystem
		and IsActive = 1
		and Status = 'Ready'
		and (isnull(@ObjectList, '') = '' or ObjectID in (select value from string_split(@ObjectList, ',')))

	set @CurrentTimestamp = getdate()
---(Ref: Jira BI-10970) Date: 09/11/2020---
set @CurrentTimestampSAP = Convert(datetime2, getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific standard time')
--
		
	select	adl.ObjectID
		,	adl.ObjectName
		,	replace(adl.ObjectName, '/', '') + '_' + format(@CurrentTimestamp, 'yyyyMMddHHmmss') + '_' + left(newid() , 8) + '.parquet' as FileName
		,	'raw/' + @SourceSystem + '/' + replace(adl.ObjectName, '/', '') + '/' + format(@CurrentTimestamp, 'yyyy/MM/dd/') as RawFilePath
		,	iif (adl.IsFullLoad = 0
				,	CTRL.ADLGetFormattedDataSliceValue(convert(varchar(64), adl.DataSliceStartValue, 120), adl.DataSliceValueDataType, 'yyyy-MM-dd HH:mm:ss', '', '', 0)
				,	null
			) as DataSliceStartValue
		,	iif (adl.IsFullLoad = 0
				,	CTRL.ADLGetFormattedDataSliceValue(convert(varchar(64), adl.DataSliceEndValue, 120), adl.DataSliceValueDataType, 'yyyy-MM-dd HH:mm:ss', '', '', 1)
				,	null
			) as DataSliceEndValue
		,	replace(
					replace(
							ss.MaxPredicateQueryTemplate
						,	'_PredicateColumn_'
						--trick below is needed for performance purposes
						,	iif(adl.SourceSystem = 'SFDC' and adl.PredicateColumn = 'LastModifiedDate', 'SystemModStamp', isnull(adl.PredicateExpression, adl.PredicateColumn))
					)
				,	'_TableName_'
				,	concat(
							adl.DatabaseName + '.'
						,	adl.SchemaName + '.'
						,	iif(ss.SourceSystemType = 'PostgreSQL' or (adl.SourceSystem = 'SFDC' and adl.ObjectName not in ('Case', 'Group')), adl.ObjectName, concat(ss.ObjectDelimeter1, adl.ObjectName, ss.ObjectDelimeter2))
					)
			) as MaxPredicateValueQuery
		,	iif(lz.Destinations is not null, convert(bit, 1), convert(bit, 0)) as IsLZ
		,	lz.Destinations
		,	adl.PredicateColumn
		,	iif(adl.DataSliceStartValue is null, convert(bit, 1), adl.IsFullLoad) as IsFullLoad
		,	format(@CurrentTimestamp, 'yyyy-MM-dd HH:mm:ss') as CurrentTimestamp
		,	iif(adl.SourceSystem = 'SAP'
				,	case adl.SAPPredicateType
---(Ref: Jira BI-10970) Date: 09/11/2020---
--	when 'Date' then format(isnull(convert(datetime, adl.DataSliceEndValue), @CurrentTimestamp), 'yyyyMMdd')  
                       when 'Date' then format(isnull(convert(datetime, adl.DataSliceEndValue), DateAdd(minute, isnull(adl.SAPTimestampOffsetMinutes,0),@CurrentTimestampSAP)), 'yyyy-MM-dd')
---Added logic to accomodate time offset for Timestamp based SAP pipelines 
						when 'Timestamp' then isnull(convert(varchar, adl.DataSliceEndValue), convert(varchar, convert(bigint, datediff(second, '19900101', DateAdd(minute, isnull(adl.SAPTimestampOffsetMinutes,0), @CurrentTimeStampSAP))) * 10000))
--						when 'Timestamp' then isnull(convert(varchar, adl.DataSliceEndValue), convert(varchar, convert(bigint, datediff(second, '19900101', DateAdd(minute, isnull(adl.SAPTimestampOffsetMinutes,0), @CurrentTimeStamp))) * 10000))
--						when 'Timestamp' then isnull(convert(varchar, adl.DataSliceEndValue), convert(varchar, convert(bigint, datediff(second, '19900101', @CurrentTimestamp)) * 10000))
					end
				,	null
			) as SAPDataSliceEndValue

		,	iif(adl.SourceSystem = 'SAP', adl.SAPPartitionOption, null) as SAPPartitionOption
		,	iif(adl.SourceSystem = 'SAP', adl.SAPPartitionColumnName, null) as SAPPartitionColumnName
		,	iif(adl.SourceSystem = 'SAP', adl.SAPPartitionLowerBound, null) as SAPPartitionLowerBound
		,	iif(adl.SourceSystem = 'SAP', adl.SAPPartitionUpperBound, null) as SAPPartitionUpperBound
		,	iif(adl.SourceSystem = 'SAP', adl.SAPMaxPartitionsNumber, null) as SAPMaxPartitionsNumber
		,	iif(ss.SourceSystemType = 'API'
				,	isnull(CTRL.GetSourceSystemProperty(@SourceSystem, 'APITokenPrefix') + ' ', '') + CTRL.GetSourceSystemProperty(@SourceSystem, 'APIToken')
				,	null
			) as APIToken
		,	iif(ss.SourceSystemType = 'API', adl.APIDefaultDataSliceStartValueExpr, null) as APIDefaultDataSliceStartValueExpr
		,	iif(ss.SourceSystemType = 'API', adl.APIDefaultDataSliceEndValueExpr, null) as APIDefaultDataSliceEndValueExpr
		,   iif(ss.SourceSystemType = 'SFDC' , isnull(adl.SFDCIsDeleted,convert(bit,0)), null) as SFDCIsDeleted
	from CTRL.ADLObject adl
	inner join CTRL.SourceSystem ss on ss.SourceSystem = adl.SourceSystem
	outer apply (
		select string_agg(lz.Destination, ',') as Destinations
		from CTRL.LZObject lz
		where lz.SourceSystem = adl.SourceSystem
			and lz.ObjectName = adl.ObjectName
	) lz
	where adl.SourceSystem = @SourceSystem
		and adl.ObjectID in (select ObjectID from @ObjectsToProcess)

	commit tran
end


