CREATE VIEW [TABIRIS].[FactScanReportShare]
AS SELECT KeyCase,
       CompanyId,
       DoctorId,
       CASE
           WHEN SharingType = 1 THEN 'PDF'
           WHEN SharingType = 2 THEN 'WeChat'
       END AS SharingType,
       SharingDateTime,
       CASE
           WHEN [Platform] = 1 THEN 'myitero'
           WHEN [Platform] = 2 THEN 'Scanner'
       END AS [PlatForm],
       CASE
           WHEN [ImageType] = 1 THEN 'SmileSimulation'
           WHEN [ImageType] = 2 THEN 'iTeroTimeLapse'
           WHEN [ImageType] = 3 THEN 'iTeroScan'
           WHEN [ImageType] = 4 THEN 'iTero5D'
           WHEN [ImageType] = 5 THEN 'DentalView'
       END AS ImageType,
       IsShared,
       ImageId,
       ID,
       ScanReportSharingImageId,
       SourceSystem
FROM DWIRIS.FactScanReportSharing;