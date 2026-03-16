CREATE VIEW [TABTOPS].[DimUser]
AS select	h.SKUser
	,	d.UserKey
	,	h.KeyUser as UserName
	,	d.FirstName
	,	d.LastName
	,	d.FullName
	,	d.UserDescription
	,	d.UserCategory
	,	d.UserShift
from DWTOPS.HubUser h
left join DWTOPS.DimUser d on d.SKUser = h.SKUser;