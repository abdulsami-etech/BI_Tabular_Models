CREATE VIEW [DWIOSIM].[IOSimSession] AS SELECT
    session_datetime as [Date],
    s.clinID as [ClinID],
    c.ContactName AS [Name],
    c.MailingCountry As [Country],
    c.MailingRegionGroup as [Region],
    c.LineofBusiness as [LineofBusiness],
	case when (N';'+c.LineofBusiness+N';') like N'%;Invisalign Go;%' AND (N';'+c.LineofBusiness+N';') like N'%;Invisalign;%'
		then N'Single Account'
		when (N';'+c.LineofBusiness+N';') like N'%;Invisalign Go;%'
		then N'Invisalign Go'
		when (N';'+c.LineofBusiness+N';') like N'%;Invisalign;%'
		then N'Invisalign'
		else N'Invisalign'
	end as [ProductType],
    c.ProfessionalCategory as [DoctorType],
    1 as [Sessions],
    CASE WHEN COALESCE(CreateSimulationActions,0)>0 then 1 else 0 end as [Sessions with Simulation],
    CASE WHEN COALESCE(TreatmentGoals,0)>0 then 1 else 0 end as [Sessions with Treatment Goal Changes],
 
    CASE WHEN COALESCE(WidgetActions,0)>0 then 1 else 0 end as [Sessions with Widget],
    COALESCE(WidgetActions,0)  as [Actions Widget],
 
    CASE WHEN COALESCE(AllowIPRActions,0)>0 then 1 else 0 end as [Sessions with Allow IPR],
    COALESCE(AllowIPRActions,0) as [Actions Allow IPR],
 
    CASE WHEN COALESCE(ExtractionActions,0)>0 then 1 else 0 end as [Sessions with Extraction],
    COALESCE(ExtractionActions,0) as [Actions Extraction],
 
    CASE WHEN COALESCE(APCorrectionActions,0)>0 then 1 else 0 end as [Sessions with AP Correction],
    COALESCE(APCorrectionActions,0) as [Actions AP Correction],
 
    CASE WHEN COALESCE(Compare_with_Original,0)>0 then 1 else 0 end as [Sessions with Compare],
    COALESCE(Compare_with_Original,0) as [Actions Compare],
 
    CASE WHEN COALESCE(Direct_Submission,0)>0 then 1 else 0 end as [Sessions with Submission],
    COALESCE(Direct_Submission,0) as [Actions Submission],
 
    CASE WHEN COALESCE(ProgressAssessment,0)>0 then 1 else 0 end as [Sessions with Progress Assessment]
    
FROM DWIOSIM.Session s
JOIN DW.DimContact c on c.ClinID = s.clinID;