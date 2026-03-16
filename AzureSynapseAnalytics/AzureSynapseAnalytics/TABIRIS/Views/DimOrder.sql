CREATE VIEW [TABIRIS].[DimOrder] AS SELECT a.[KeyCase] as [MAT Case order ID]
      ,a.[CaseCode] as [MAT Case Code]
      ,a.[CaseTypeId] as [MAT Case Type ID]
      ,a.[CaseTypeName] as [MAT Case Type Name]
      ,a.[ITeroVersion] as [MAT iTero Version]
      ,a.[CaseDateCreated] as [MAT Order Date]
      ,a.[InitiatorPartnerID] as [MAT Account ID]
      ,a.[InitiatorContactID] as [MAT Contact ID]
      ,a.[PartnerLabID] as [MAT Lab Account ID]
      ,a.[InstrCode] as [MAT Instr Code] 
	  ,a.ScannerID as [MAT Scanner ID]
	  ,a.BaseUnitSN as [MAT BaseUnit SN]
	  ,a.WandSN as [MAT Wand SN]
	  ,a.IsDirectToLab as [MAT Is DirectToLab]
	  , case when cd.skcase is Not Null then 'Yes' else 'No' end as [MAT IsCaseDownload]
	  , isnull(cd.NumberOfDownloads,0) as [MAT NumberOfDownloads]
   	  ,b.[KeyOrder] as [SAP Order ID]
      ,b.[IDSOrderNumber] as [IDS Case order ID]
      ,b.[SKContact] as [IDS SKContact]
      ,b.[OrderType] as  [IDS Order Type]
      ,b.[DeliverableType] as [IDS Deliverable Type]
      ,b.[TreatmentCategory] as [IDS Treatment Category]
      ,b.[TreatmentType] as [IDS Treatment Type]
      ,b.[ScanType] as [IDS Scan Type]
      ,b.[SubmissionType] as [IDS  Submission Type]
      ,b.[SubmitDate] as [IDS Submission Date]
      ,b.[AMRDate] as [IDS AMR Date]
      ,b.[CCADate] as [IDS CCA Date]
      ,b.[ShipmentDate] as [IDS Shipped Date]
      ,b.[CancellationDate] as [IDS Cancellation Date]
      ,b.[TreatmentID] as [IDS Treatment ID]
	  ,MATOrderCount = case when b.casecode is null then 1 else row_number() over (partition by a.casecode order by b.[SubmitDate]) end
  FROM [DWIRIS].[DimCase] a
  left join [DW].[DimOrderIDS] b 
  on a.casecode = b.casecode
  left join (select skcase,count(1) as NumberOfDownloads 
				from dwiris.factcasedownload
				group by skcase
			) cd on cd.skcase=a.skcase;