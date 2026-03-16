CREATE VIEW DWC.FactIFVUsage as
SELECT
    f.Patient_id,
    f.MinPhotoDate,
    f.SKOrder,
    f.IDSOrderId,
    f.OrderKey as SAPOrderNumber,
    f.SKIFVStatus,
    CASE WHEN f.CCIFVUsage>0 THEN 1 ELSE 0 END as CCIFVUsage,
    c.SKContact,
    c.ClinID,
    f.FirstIFVReviewDate
from DWIFV.FactIFV f
JOIN DWC.DimContact c on c.SKContact=f.SKContact
WHERE f.IsReport=1