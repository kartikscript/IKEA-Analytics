-- combining both tables and coverting types
SELECT
Invoice, StockCode, Description, Quantity,
COALESCE(
	TRY_CONVERT(datetime2, InvoiceDate, 120),
	TRY_CONVERT(datetime2, InvoiceDate, 105)
) AS InvoiceDate,
TRY_CONVERT(decimal(10,2), Price) AS Price,
Customer_ID, Country, '2009-2010' AS SourceSheet
INTO dbo.RetailCombined
FROM dbo.[Year 2009-2010]

UNION ALL 

SELECT
Invoice, StockCode, Description, Quantity,
COALESCE(
	TRY_CONVERT(datetime2, InvoiceDate, 120),
	TRY_CONVERT(datetime2, InvoiceDate, 105)
) AS InvoiceDate,
TRY_CONVERT(decimal(10,2), Price) AS Price,
Customer_ID, Country, '2010-2011' AS SourceSheet
FROM dbo.[Year 2010-2011]
;


SELECT COUNT(*) FROM dbo.RetailCombined WHERE InvoiceDate IS NULL OR Price IS NULL;

--eda

SELECT COUNT(*) AS missing_customer_id
FROM dbo.RetailCombined
WHERE Customer_ID IS NULL

SELECT COUNT(*) AS negative_quantity
FROM dbo.RetailCombined
WHERE Quantity <= 0

SELECT COUNT(*) AS missing_description
FROM dbo.RetailCombined
WHERE Description IS NULL;

SELECT Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country,
COUNT(*) AS duplicate_count
FROM dbo.RetailCombined
GROUP BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country
HAVING COUNT(*) > 1


-- cleaning
WITH Deduped AS (
	SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country
		ORDER BY (SELECT NULL)
		) AS row_num
	FROM dbo.RetailCombined
)
SELECT Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country, SourceSheet
INTO dbo.RetailCleaned
FROM Deduped
WHERE row_num = 1


SELECT * FROM dbo.RetailCleaned;
