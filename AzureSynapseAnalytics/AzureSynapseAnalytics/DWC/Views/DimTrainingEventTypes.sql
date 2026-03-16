CREATE VIEW [DWC].[DimTrainingEventTypes] AS
SELECT 		SKTrainingEventType
			,	KeyTrainingEventType
			,	TrainingEventTypeCode
			,	TrainingEventTypeName
			,	ProfEdEventType
			,	CustomerAddressListExtendedGrouping
			,	AudienceType
			,	NewTraining
  FROM [DW].[DimTrainingEventTypes];


