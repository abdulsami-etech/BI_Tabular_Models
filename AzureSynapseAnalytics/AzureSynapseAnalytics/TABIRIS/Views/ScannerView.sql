CREATE VIEW [TABIRIS].[ScannerView]
AS select 
	s.SystemKey,
	CASE
		WHEN s.EventName = 'Pairing' THEN NULL
		WHEN s.EventName = 'Shipped' THEN convert(varchar(255),scan_SFDC.MATID)
		ELSE convert(varchar(255),scan_mat.HolderID)
	end as [MAT ID],
	CASE
		WHEN s.EventName = 'Pairing' THEN NULL
		WHEN s.EventName = 'Shipped' THEN scan_SFDC.AccountName
		ELSE scan_mat.HolderName
	end as [MAT Name],
	s.KeyScanner as [Base Unit],
	s.KeyWand as Wand,
	s.EventDate as [Event Date],
	s.EventCloseDate as [Event Close Date],
	s.EventName as Status,
	s.CurrentStatus as [Current State],
	scan_mat.ScannerModel as ScannerModel,
	case when scan_mat.ScannerModel in ('Element 2 5D',	'Flex 5D','5D Wand UPG Kit','5D Flex Wand UPG Kit','iTero Element 5D Plus, Cart Configuration','iTero Element 5D Plus, Mobile Configuration','iTero Element 5D Plus Lite, Cart Configuration','iTero Element 5D Plus Lite, Mobile Configuration')
then 'Yes' else 'No' end as IsColorScanEligible
from [DWIRIS].[SatLink_ScannerWand] s
left join DWIRIS.Sat_WandMES mes
	on s.SourceSystem = 'MES' and s.KeyWand = mes.KeyWand
left join (select 
		KeyScanner,
		ScannerID, 
		ScannerModel,
		HolderID,
		HolderName,
		OwnerID,
		OwnerName,
		RegistrationDate
	from DWIRIS.Sat_ScannerMAT
	where RegistrationOrder = 1) scan_mat
on scan_mat.KeyScanner = s.KeyScanner and s.SourceSystem = 'MAT'
left join (select 
			s.KeyScanner, 
			s.ScannerID,
			dacc.MATID,
			dacc.AccountNAme
		from DWIRIS.Sat_ScannerSFDC s
		left join DWIRIS.DimAsset da
			on da.SerialNumber = s.KeyScanner
		left join DW.DimAccount dacc
			on dacc.SKAccount = da.SKAccount) scan_SFDC
on scan_SFDC.KeyScanner = s.KeyScanner and s.SourceSystem = 'SFDC';


