CREATE VIEW DWC.DimIFVStatus
as
    SELECT
        SKIFVStatus,
        StatusName
    from DWIFV.DimIFVStatus