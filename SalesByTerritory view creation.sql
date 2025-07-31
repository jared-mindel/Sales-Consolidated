USE AdventureWorks2022
GO

CREATE OR ALTER VIEW SalesByTerritory AS (
	SELECT
		soh.SalesOrderID AS "Order ID",
		soh.OrderDate AS "Order Date",
		soh.OnlineOrderFlag AS "Online Flag",
		soh.TerritoryID,
		st.[Name] AS "Territory Name",
		st.[Group],
		sohsr.SalesReasonID AS "Reason ID",
		soh.[CustomerID],
		sr.[Name] AS "Reason Name",
		soh.SubTotal,
		soh.TaxAmt,
		soh.TotalDue,
		soh.[Freight],
		soh.[SalesPersonID],
		sp.[SalesQuota], 
		sp.[Bonus]

	FROM Sales.SalesTerritory st

	JOIN Sales.SalesOrderHeader soh 
		ON soh.TerritoryID = st.TerritoryID

	LEFT JOIN Sales.SalesOrderHeaderSalesReason sohsr
		ON sohsr.SalesOrderID = soh.SalesOrderID

	LEFT JOIN Sales.SalesReason sr
		ON sr.SalesReasonID = sohsr.SalesReasonID

	LEFT JOIN Sales.PersonCreditCard pcc
		ON pcc.[CreditCardID] = soh.[CreditCardID]

	LEFT JOIN Sales.SalesPerson sp
		ON sp.BusinessEntityID = pcc.BusinessEntityID
)
