CREATE VIEW [DWC].[FactVolume] AS 
SELECT  TreatmentCategory
, SKOrder
, SAPOrderNumber
, SKOrderStatus
, SKContact
, SKAccountSoldTo
, SKAccountShipTo
, SKAccountTreatmentLocation
, StatusDate
, CountryCode
, SecRegion
, NewOrRestart
, ProductHierarchy
, TreatmentOption,DeliverableType
, MaterialNumber
, ProfitCenter
, ProfCat
, IsDSO
, TotalAlignerQuantity
, DeliverableQuantity
, Statuscount
, Plant as SKPlant
, TreatmentID
, SoldTo
, ShipTo
, TreatmentLocation
, ItemCategory
, ClinID
, SFOrderId
 ,SFOrderNumber
FROM DW.FactVolume fv
INNER JOIN dwglobal.GeographyRegion d ON d.RegionGroup = fv.SecRegion AND d.dataset='DWC';