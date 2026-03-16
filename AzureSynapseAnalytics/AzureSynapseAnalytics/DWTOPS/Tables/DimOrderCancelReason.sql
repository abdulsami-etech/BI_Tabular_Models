CREATE TABLE DWTOPS.DimOrderCancelReason(
    [SKCancelReason] INT NOT NULL,
	[CancelReasonCode] nvarchar(3) NOT NULL,
	[CancelReasonName] nvarchar(100) NOT NULL
)
WITH (CLUSTERED INDEX(SKCancelReason), DISTRIBUTION = REPLICATE);