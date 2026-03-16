CREATE VIEW [TABIRIS].[FactAssetInstallation]
AS SELECT
	[SKAsset]													as [SKAsset],
	convert(date, convert(varchar(8), [SKDate]), 112)		as [KeyDate]

FROM [DWIRIS].[FactScannerInstallation];