CREATE function CTRL.GetLastSuccessfullTimestamp (@DWObjectId int)
returns datetime2(0)
begin
	return (
		select min(lz.LastSuccessfullLZTimestamp) as LastSuccessfullTimestamp
		from CTRL.DWObject o
		cross apply string_split(DependentLZObjectIDs, ',') d
		inner join CTRL.LZObject lz on lz.LZObjectID = d.value
									and lz.Destination = 'LZ'
		where o.DWObjectId = @DWObjectId
	)
end
