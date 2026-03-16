CREATE VIEW [TABIRIS].[DimVctTraining]
AS SELECT
    
        d.[TicketNumber],
        d.[IsCompleted],
        d.[CreatedDate],
        d.[Id],
        d.[IsInvisalign],
        d.[IsDeleted],
        d.[Name],
        d.[NumberOfParticipants],
        d.[RecordType],
        d.[MethodOfTraining],
        d.[ModulesCompleted],
        d.[Status],
        d.[TotalTime],
        d.[Type],
        d.[VCTTrainingDate],
        d.[IsBasic],
        d.[IsOrtho],
        d.[IsOtherSW],
        d.[IsRestorative],
        d.[AccountNumber],
        d.[ContactNumber],
        d.[MATID],
        d.[Lab]
    from [DWIRIS].[DimVctTraining] d
    inner join [DWIRIS].[HubVctTraining] h
        on h.[SKVctTraining] = d.[SKVctTraining];