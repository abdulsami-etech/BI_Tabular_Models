CREATE function [CTRL].[LZGetFileListForObject] (@LZObjectID int)
returns table 
as
return (
	with allFiles as (
		select	adlf.FileName
			,	adlf.FilePath
			,	adlf.DateUpdated
			,	adlf.IsFullLoad
			,	adlf.FileSizeInBytes
			,	adlf.ADLSBatchID
			,	substring(adlf.FileName, len(adlf.FileName) - 30, 14) as ADLSTimestamp
		from CTRL.LZObject lz
		inner join CTRL.ADLObject adl on lz.SourceSystem = adl.SourceSystem
									and lz.ObjectName = adl.ObjectName
		inner join CTRL.ADLObjectFile adlf on adlf.ObjectID = adl.ObjectID
									and adlf.Destination = lz.Destination
		where lz.LZObjectID = @LZObjectID
			and adlf.Status = 'Ready'	
	), lastFullLoad as (
		select max(FileName) as LastFullLoadFileName
		from allFiles
		where IsFullLoad = 1
	)
	select	adlf.FileName
		,	adlf.FilePath
		,	adlf.DateUpdated
		,	adlf.IsFullLoad
		,	adlf.FileSizeInBytes
		,	adlf.ADLSBatchID
		,	adlf.ADLSTimestamp
		,	left(adlf.ADLSTimestamp, 8) + ' ' + substring(adlf.ADLSTimestamp, 9, 2) + ':' + substring(adlf.ADLSTimestamp, 11, 2) + ':' + substring(adlf.ADLSTimestamp, 13, 2) as ADLSTimestampFormatted
	from allFiles adlf
	cross join lastFullLoad lfl
	where adlf.FileName >= lfl.LastFullLoadFileName
		or lfl.LastFullLoadFileName is null
)

