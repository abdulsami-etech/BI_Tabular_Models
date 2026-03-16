CREATE VIEW [TABTOPS].[FactWorkOrder]
AS select	DgnVIPOrderNumber as VIPOrderNumber
	,	DgnWorkOrderKey as WorkOrderKey
	,	DgnWorkOrderNumber as WorkOrderNumber
	,	DgnIsRejectedImpression as IsRejectedImpression
	,	DgnIsIPLEnabled as IsIPLEnabled
	,	DgnIsScan as IsIOScan
	,	DgnIOScanType as ScanType
	,	DgnHardwareVersion as HardwareVersion
	,	DgnSoftwareVersion as SoftwareVersion
	,	DgnDeliverableType as DeliverableType
    , CASE WHEN DgnDeliverableType Like '%RETAINER%' THEN 'Retainer' ELSE 'Aligner' END AS ProductLine
	,	DgnTreatmentCategory as TreatmentCategory
	,	DgnStorageLocation as StorageLocation
	,   DgnPilotDescription as PilotDescription
	,   DgnTreatmentFlow as TreatmentFlow
	,	DgnProcessingType as ProcessingType
	,	DgnMAFeature as MAFeature
	,	DgnIsMTPSend as IsMTPSend
	,	DgnSTPExecuted as STPExecuted
	,	SKDoctor
	,	SKExpediteScope 
	,	SKMaterialReceivedDate
	,	SKMaterialReceivedTime
	,	SKOrderCreationDate
	,	SKOrderCreationTime
	,	SKPlantOrderEntry
	,	SKCountry
	,   SKCancelReason
	,   SKCancelledDate
	,	DurationToFinishedInMinutes
from DWTOPS.FactWorkOrder;