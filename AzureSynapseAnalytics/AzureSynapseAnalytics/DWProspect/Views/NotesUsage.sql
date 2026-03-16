CREATE VIEW DWProspect.NotesUsage
AS
SELECT
    lead_id,
    clin_id,
    created_date,
    updated_date,
    description
FROM SrcKafkaHeroku.notes_event