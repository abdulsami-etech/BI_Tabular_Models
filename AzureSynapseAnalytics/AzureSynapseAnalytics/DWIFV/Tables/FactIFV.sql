CREATE TABLE DWIFV.FactIFV (
    Patient_id          VARCHAR(32)     NOT NULL,
    DWBatchID           INT             NOT NULL,     
	InsertDateTime      DATETIME        NOT NULL,
    MinPhotoID          VARCHAR(36)     NOT NULL,
    Region              VARCHAR(32)     NOT NULL,
    MinPhotoDate        DATE            NOT NULL,
    IDSOrderId          BIGINT          NULL,
    CreatedBy           NVARCHAR(128)   NULL,
    IsInitial           BIT             NULL,
    IsSuccessSim        BIT             NULL,
    SKOrder             BIGINT          NULL,
    OrderKey            BIGINT          NULL,
    CCAADate            DATE            NULL,
    DeliverableType     VARCHAR(40)     NULL,
    ProductType         NVARCHAR (128)  NULL,  
    TreatmentCategory   VARCHAR(40)     NULL,
    SKContact           BIGINT          NULL,
    SKIFVStatus         INT             NULL,
    CCIFVUsage          INT             NULL,
    FirstIFVReviewDate  date            NULL,
    IsReport            BIT             NULL
)
with (CLUSTERED INDEX (patient_id), DISTRIBUTION = HASH(patient_id))