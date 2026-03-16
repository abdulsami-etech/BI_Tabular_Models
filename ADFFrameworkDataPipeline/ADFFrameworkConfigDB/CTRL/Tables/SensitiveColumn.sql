create table CTRL.SensitiveColumn (
		SchemaName	varchar(64)		not null
	,	ObjectName	varchar(64)		not null
	,	ColumnName	varchar(128)	not null
	,	constraint PK_SensitiveColumn primary key clustered (SchemaName, ObjectName, ColumnName)
)