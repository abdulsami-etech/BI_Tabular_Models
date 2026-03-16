CREATE VIEW [TABIRIS].[DimVirtualProduct]
AS SELECT
	vp.[SKVirtualProduct]														as [SKVirtualProduct],
	vp.[KeyVirtualProduct]														as [Key Virtual Product],
	vp.[SKAsset]																as [SKAsset],
	convert(datetime, vp.[StartDate])											as [Start Date],
	convert(datetime, vp.[ExpiryDate])											as [Expiry Date],
	vp.[AutoRenewal]															as [AutoRenewal],
	vp.[SerialCode]															as [Serial Code],
	vp.[Category]																as [Category],
	vp.[TypeName]																as [Name],
	vp.[Description]															as [Description]
FROM [DWIRIS].[DimVirtualProduct] vp
INNER JOIN [DWIRIS].[HubVirtualProduct] hvp
	on hvp.[SKVirtualProduct] = vp.[SKVirtualProduct];