CREATE VIEW [TABTOPS].[DimDoctor]
AS select	h.SKDoctor
	,	d.ClinicianID
	,	d.KeyDoctor as DoctorID
	,	d.DoctorFirstName
	,	d.DoctorLastName
	,	d.DoctorFullName
	,	d.DoctorSource
	,	d.DoctorCertLevel
	,	d.DoctorCalculatedLevel
	,	d.DoctorCalculatedLevelFlag
	,	d.DoctorJDETeam
	,	d.DoctorSkillLevel
	,   d.DoctorRegionMES
	,   d.SKCountry
from DWTOPS.HubDoctor h
left join DWTOPS.DimDoctor d on d.SKDoctor = h.SKDoctor;