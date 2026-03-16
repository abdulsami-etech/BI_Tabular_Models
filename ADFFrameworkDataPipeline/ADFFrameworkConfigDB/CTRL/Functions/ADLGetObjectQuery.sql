

create function CTRL.ADLGetObjectQuery (
		@ObjectID			int
	,	@DataSliceEndValue	varchar(64)
	,	@IsFullLoad			bit
)
returns table as
return (
	select	iif(ss.SourceSystem = 'SAP'
				,	convert(varchar(8000), 
						iif(adl.DataSliceStartValue is null or @IsFullLoad = 1
							,	isnull(adl.QueryFilter, '')
							,	replace(replace(adl.PredicateExpression, '_DataSliceStartValue_', 
									iif(adl.SAPPredicateType = 'Timestamp', convert(varchar, adl.DataSliceStartValue), format(convert(datetime, adl.DataSliceStartValue), ss.DateTimeFormat))),
									'_DataSliceEndValue_', 
									iif(adl.SAPPredicateType = 'Timestamp', @DataSliceEndValue, format(convert(datetime, @DataSliceEndValue), ss.DateTimeFormat)))
								+ isnull(' AND (' + adl.QueryFilter + ')', '')
						) 
					)
				,	'select ' 
					+	isnull(adl.ColumnList, '*')
					+	' from '
					+	concat(
								adl.DatabaseName + '.'
							,	adl.SchemaName + '.'
							,	iif(ss.SourceSystemType = 'PostgreSQL' or (adl.SourceSystem = 'SFDC' and adl.ObjectName not in ('Case', 'Group')), adl.ObjectName, concat(ss.ObjectDelimeter1, adl.ObjectName, ss.ObjectDelimeter2))
						)
					+	iif(ss.SourceSystem like 'MES%', ' with (nolock) ', '')
					+	iif (@IsFullLoad = 1 or adl.DataSliceStartValue is null or isnull(@DataSliceEndValue, 'null') = 'null'
							,	isnull(' where ' + adl.QueryFilter, '')
							,	' where ' + isnull(adl.PredicateExpression, concat(ss.ObjectDelimeter1, adl.PredicateColumn, ss.ObjectDelimeter2)) + ' >= '
								+	CTRL.ADLGetFormattedDataSliceValue(convert(varchar(64), adl.DataSliceStartValue, 120), adl.DataSliceValueDataType, ss.DateTimeFormat, ss.DateTimeFormat1, ss.DateTimeFormat2, iif(ss.SourceSystem like 'MES%', -600, 0))
								+	' and ' + isnull(adl.PredicateExpression, concat(ss.ObjectDelimeter1, adl.PredicateColumn, ss.ObjectDelimeter2)) + ' <= ' 
								+	CTRL.ADLGetFormattedDataSliceValue(@DataSliceEndValue, adl.DataSliceValueDataType, ss.DateTimeFormat, ss.DateTimeFormat1, ss.DateTimeFormat2, 1)
								+  isnull(' and (' + adl.QueryFilter + ')', '') 
						)
			) as Query
		,	adl.ObjectName
		,	iif(adl.ObjectName like '%[_]table[0-9]%', left(adl.ObjectName, charindex('_table', adl.ObjectName) - 1), adl.ObjectName) as ObjectNameEx
		,	adl.ColumnList
	from CTRL.ADLObject adl
	inner join CTRL.SourceSystem ss on ss.SourceSystem = adl.SourceSystem
	where adl.ObjectID = @ObjectID
)
