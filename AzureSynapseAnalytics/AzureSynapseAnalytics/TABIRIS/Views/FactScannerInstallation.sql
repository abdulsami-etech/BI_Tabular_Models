CREATE VIEW [TABIRIS].[FactScannerInstallation]
AS select	SKAsset
	,	SKAccount
	,	convert(date, convert(varchar(8), SKDate), 112)	as Date
from [DWIRIS].[FactScannerInstallation];