CREATE VIEW [TABTOPS].[FactTicketComplaints]
AS SELECT  
       [DgnCaseNumber] as  CaseNumber
      ,[DgnCreatedDate] as CreatedDate
      ,[DgnComplaintType] as ComplaintType
      ,[DgnComplaintSubType] as ComplaintSubType 
      ,[DgnStatus]           as [Status]
      ,[DgnManufacturingSite] as ManufacturingSite
      ,[DgnDoctor] as  DoctorID
      ,[DgnRegion] as Region
      ,[SKDoctor]
      ,[SKCreatedDate]
      ,[SKCreatedTime]
      ,[SkPlantOriginal]
	  ,[SkPlantActual]
      ,[IsDesignExecution]
      ,[IsProductEnvelope]
      ,[IsSystemORSoftware]
      ,[IsUnspecifiedExpectation]
	  ,[IsAlignerManufacturing]
	  ,[IsViveraRetainer]
      ,[IsNonValid]
  FROM [DWTOPS].[FactTicketComplaints];