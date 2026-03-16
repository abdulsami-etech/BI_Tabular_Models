

create function CTRL.ADLGetObjectAPIURL (
		@ObjectID				int
	,	@DataSliceStartValue	varchar(64)
	,	@DataSliceEndValue		varchar(64)
)
returns table as
return (
	select	replace(
				replace(
					adl.APIURL, 
					'_DataSliceStartValue_', 
					CTRL.ADLGetFormattedDataSliceValue(@DataSliceStartValue, adl.DataSliceValueDataType, s.DateTimeFormat, s.DateTimeFormat1, s.DateTimeFormat2, 0)
				), 
				'_DataSliceEndValue_', 
				CTRL.ADLGetFormattedDataSliceValue(@DataSliceEndValue, adl.DataSliceValueDataType, s.DateTimeFormat, s.DateTimeFormat1, s.DateTimeFormat2, 1)
			) as URL
		,	CTRL.ADLGetFormattedDataSliceValue(@DataSliceStartValue, adl.DataSliceValueDataType, s.DateTimeFormat, s.DateTimeFormat1, s.DateTimeFormat2, 0) as DataSliceStartValue
		,	CTRL.ADLGetFormattedDataSliceValue(@DataSliceEndValue, adl.DataSliceValueDataType, s.DateTimeFormat, s.DateTimeFormat1, s.DateTimeFormat2, 1) as DataSliceEndValue
	from CTRL.ADLObject adl
	inner join CTRL.SourceSystem s on s.SourceSystem = adl.SourceSystem
	where ObjectID = @ObjectID
)
