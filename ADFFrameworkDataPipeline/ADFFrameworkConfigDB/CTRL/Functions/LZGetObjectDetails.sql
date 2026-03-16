create function CTRL.LZGetObjectDetails (
		@LZObjectID int
)
returns table
as return (
	select	t1.LZObjectID
		,	t1.ObjectName
		,	t1.ExternalViewName
		,	t1.SourceSystem
		,	t1.DestSchema
		,	t1.SourceSchema
		,	t1.DestTableName
		,	t1.SourceTableName
		,	t1.StoreOption
		,	t1.DistributionOption
		,	t1.IsLoadAllColumns
		,	t1.SourceColumnDroppedAction
		,	t1.[Columns]
		,	t1.Datatypes
		,	t1.IsNullables
		,	t2.JoinPredicates
		,	t2.JoinPredicatesForUpdate
		,	t1.PKColumns
		,	(select top (1) PredicateColumn from CTRL.ADLObject adl where adl.SourceSystem = t1.SourceSystem and adl.ObjectName = t1.ObjectName) as PredicateColumn
	from (
		select	o.LZObjectID
			,	o.ObjectName
			,	'EXT.' + quotename(o.SourceSystem + '_' + o.ObjectName) as ExternalViewName
			,	o.SourceSystem
			,	'Src' + o.SourceSystem as DestSchema
			,	'Stage' as SourceSchema
			,	o.ObjectName as DestTableName
			,	o.SourceSystem + '_' + o.ObjectName as SourceTableName
			,	o.StoreOption
			,	o.DistributionOption
			,	o.IsLoadAllColumns
			,	o.SourceColumnDroppedAction
			,	iif(o.IsLoadAllColumns = 0, string_agg(col.ColumnName, '|') within group (order by col.OrdinalPosition asc), null) as [Columns]
			,	iif(o.IsLoadAllColumns = 0
					,	string_agg(
							concat(
									col.Datatype
								,	'(' + iif(col.Length = -1, 'max', convert(varchar, col.Length)) + ')'
								,	'(' + convert(varchar, col.Precision) + isnull(',' + convert(varchar, col.Scale), '') + ')'
							), '|'
						) within group (order by col.OrdinalPosition asc) 
					,	null
				) as Datatypes
			,	iif(o.IsLoadAllColumns = 0, string_agg(col.IsNullable, '|') within group (order by col.OrdinalPosition asc), null) as IsNullables
			,	replace(o.PKColumns, '|', ',') as PKColumns
		from CTRL.LZObject o
		left join CTRL.LZObjectColumn col on col.LZObjectID = o.LZObjectID
		where o.LZObjectID = @LZObjectID
		group by o.LZObjectID, o.ObjectName, o.SourceSystem, o.StoreOption, o.DistributionOption, o.PKColumns, o.IsLoadAllColumns, o.SourceColumnDroppedAction
	) t1
	left join (
		select	o.LZObjectID
			,	'(' + string_agg('t1.' + quotename(pk.value) + ' = t2.' + quotename(pk.value), ' and ') + ')' as JoinPredicates
			,	'(' + string_agg('t1.' + quotename(pk.value) + ' = ' + quotename('Src' + o.SourceSystem) + '.' + quotename(o.ObjectName) + '.' + quotename(pk.value), ' and ') + ')' as JoinPredicatesForUpdate
		from CTRL.LZObject o
		outer apply string_split(o.PKColumns, '|') pk 
		where o.LZObjectID = @LZObjectID
		group by o.LZObjectID
	) t2 on t1.LZObjectID = t2.LZObjectID
)
