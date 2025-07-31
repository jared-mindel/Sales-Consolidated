# Sales-Consolidated
This Power BI report built upon a SQL view demonsstrates my qualities as a data analyst specializing in SQL and Power BI. The SQL code is available in the [SalesByTerritory view creation file](https://github.com/jared-mindel/Sales-Consolidated/blob/main/SalesByTerritory%20view%20creation.sql), and I will include in-depth analysis of in this readme. For this project, I decided to show my skills in SQL view development, Power BI dashboard creation and design, and data validation. This project is built upon the AdventureWorks2022 database, focusing on the various sales tables contained therein. Initially I had intended to focus on metrics related to sales and territory, but I found throughout the process that metrics like location group were also valuable, such that "Sales by Territory" may be a misnomer. Therefore, at the front-end of the project, I speak of this project as "Sales Consolidated," but on the back end it remains "SalesByTerritory."

# SQL View

## SELECT Statement
As with other projects, I find it especially helpful for ease of execution that we begin with:

```sql

USE AdventureWorks2022
GO

```
oftentimes this kind of code unnecessary in other environments like Snowflake, but I used SQL Server Management Studio, where this is a helpful. For this project, I used a normal 

```sql 

SELECT

```

statement instead of a 

```sql 

SELECT DISTINCT

```
statement because I wanted to capture all of the relevant data, and it would be superfluous anyway. The Order ID is unique and there are no one-to-many relationships built off the primary key of the driver table. I pulled the following columns without any alterations; any alterations will be performed in Power BI with measures. Thus, the complete SELECT statement is as follows:

```sql
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
```

## FROM and JOIN Statements

These statements are fairly obvious. I chose the "Sales.SalesOrderHeader" (aliased as "soh") table as the driver table because it contains the most granular level of data that is relevant for our purpose, which is actually aggregated higher than other tables like "Sales.SalesOrderDetail" table in the same database. The JOINs were done in a fairly simple way. I wanted to look at all the information where the TerritoryID is populated since that is a key metric for this report, so I used a standard

```SQL

INNER JOIN

```

while the rest of the tables have some NULL values that I find useful, so each had a 

```sql

LEFT JOIN

```

to capture that. The SELECT and JOIN clauses are thus:

```SQL
FROM Sales.SalesOrderHeader soh

JOIN Sales.SalesTerritory st 
  ON st.TerritoryID = soh.TerritoryID

LEFT JOIN Sales.SalesOrderHeaderSalesReason sohsr
  ON sohsr.SalesOrderID = soh.SalesOrderID

LEFT JOIN Sales.SalesReason sr
  ON sr.SalesReasonID = sohsr.SalesReasonID

LEFT JOIN Sales.PersonCreditCard pcc
  ON pcc.[CreditCardID] = soh.[CreditCardID]

LEFT JOIN Sales.SalesPerson sp
  ON sp.BusinessEntityID = pcc.BusinessEntityID
```
We will return to SQL soon with the data validation portions.

# Power BI Report

## DAX Measures

I focused on developing DAX measures for this report, avoiding calculated columns because measures are more dynamic and do not take up space in the model. Therefore, they are more efficient. For a small dataset (36,100 rows) like this, the efficiency gained by using measures over calculated columns is insignificant, but it is nonetheless a good business practice in general.

For this report, I avoided using DAX measures that were too complex, so I could instead focus on reusability and readability if I make any updates with new KPIs. The primary DAX measure I wanted to create was the "Total Due Difference" measure, which would show the difference between the Total Due from one month to the next. To get to this measure, I first created a few other measures. First, I created the Previous Total Due Month measure as a way to see what the change would be month over month:

```

Previous Total Due Month = 

CALCULATE(
    SUM([TotalDue]), 
    DATEADD('SalesByTerritory'[Order Date].[Date], - 1, MONTH)
)
```
From here, I built the Total Due Difference measure, which should be fairly self-explanatory:
```
Total Due Difference = 

SUM([TotalDue]) - [Previous Total Due Month]
```

The report is capable of aggregating these values up to the year-level in visuals as well. 

I also created the Order Count measure as a simple way to count the The measure is as follows:

```
Order Count = 

COUNT(SalesByTerritory[Order ID])
```
Again, no need for a distinct count. 
