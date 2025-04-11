
1--What percentage of journeys are delayed / cancelled, and what is the average delay time?
SELECT 
    FORMAT(
        COUNT(CASE WHEN [Journey Status] IN ('Delayed', 'Cancelled') THEN 1 END) * 100.0 / COUNT(*), 
        'N2'
    ) + '%' AS Delayed_Cancelled_Percentage,
    ROUND(AVG(CASE WHEN [Journey Status] = 'Delayed' THEN [Delay Minutes] ELSE NULL END), 1) AS Average_Delay_Minutes
FROM [UKtrains].[dbo].[Dataset];

2-- Which routes experience the highest frequency of delays/cancellations?
SELECT TOP 20 
    [Departure Station],
    [Arrival Destination],
    COUNT(*) AS Delay_Cancellation_Count
FROM [UKtrains].[dbo].[Dataset]
WHERE [Journey Status] IN ('Delayed', 'Cancelled')
GROUP BY [Departure Station], [Arrival Destination]
ORDER BY Delay_Cancellation_Count DESC;

3--What are the most common reasons for train delays/cancellations?
SELECT TOP 10 
    [Reason for Delay], 
    COUNT(*) AS Occurrence_Count
FROM [UKtrains].[dbo].[Dataset]
WHERE [Journey Status] IN ('Delayed', 'Cancelled')
AND [Reason for Delay] IS NOT NULL
GROUP BY [Reason for Delay]
ORDER BY Occurrence_Count DESC;

4-- Do certain stations contribute more to delays (departure vs. arrival)?

WITH DepartureDelays AS (
    SELECT 
        [Departure Station] AS Station,
        COUNT(*) AS Departure_Delay_Count
    FROM [UKtrains].[dbo].[Dataset]
    WHERE [Journey Status] = 'Delayed'
    GROUP BY [Departure Station]
), 

ArrivalDelays AS (
    SELECT 
        [Arrival Destination] AS Station,
        COUNT(*) AS Arrival_Delay_Count
    FROM [UKtrains].[dbo].[Dataset]
    WHERE [Journey Status] = 'Delayed'
    GROUP BY [Arrival Destination]
)

SELECT TOP 20 
    COALESCE(d.Station, a.Station) AS Station,
    COALESCE(d.Departure_Delay_Count, 0) AS Departure_Delay_Count,
    COALESCE(a.Arrival_Delay_Count, 0) AS Arrival_Delay_Count
FROM DepartureDelays d
FULL OUTER JOIN ArrivalDelays a ON d.Station = a.Station
ORDER BY (COALESCE(d.Departure_Delay_Count, 0) + COALESCE(a.Arrival_Delay_Count, 0)) DESC;

5-- What is the total revenue generated per month, per station, and per ticket type?

SELECT 
    FORMAT([Date of Purchase], 'yyyy-MM') AS Month, 
    [Departure Station], 
    [Ticket Type], 
    SUM([Price]) AS Total_Revenue
FROM [UKtrains].[dbo].[Dataset]
GROUP BY FORMAT([Date of Purchase], 'yyyy-MM'), [Departure Station], [Ticket Type]
ORDER BY Total_Revenue DESC;

6-- Which ticket class (Standard, First-Class) contributes the most to revenue?

SELECT 
    [Ticket Class], 
    COUNT(*) AS Booking_Count, 
    SUM([Price]) AS Total_Revenue
FROM [UKtrains].[dbo].[Dataset]
GROUP BY [Ticket Class]
ORDER BY Total_Revenue DESC;


7--What are the peak hours for departure based on sales volume?

SELECT 
    DATEPART(HOUR, [Departure Time]) AS Departure_Hour, 
    COUNT(*) AS Ticket_Sales
FROM [UKtrains].[dbo].[Dataset]
GROUP BY DATEPART(HOUR, [Departure Time])
ORDER BY Ticket_Sales DESC;

8-- What is the average ticket price per journey type (Advance, Anytime, Off-Peak) & count?

SELECT 
    [Ticket Type], 
    COUNT(*) AS Ticket_Count, 
    CAST(ROUND(AVG([Price]), 1) AS DECIMAL(10,1)) AS Avg_Ticket_Price,
    CONCAT(CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS DECIMAL(5,1)), '%') AS Ticket_Percentage
FROM [UKtrains].[dbo].[Dataset]
GROUP BY [Ticket Type]
ORDER BY Avg_Ticket_Price DESC;



9-- What is the financial impact of refunds on total revenue?

SELECT 
    SUM([Price]) AS Total_Revenue, 
    SUM(CASE WHEN [Refund Request] = 'Yes' THEN [Price] ELSE 0 END) AS Refunded_Amount,
    SUM([Price]) - SUM(CASE WHEN [Refund Request] = 'Yes' THEN [Price] ELSE 0 END) AS Net_Revenue,
    CONCAT(
        CAST(ROUND(
            (SUM(CASE WHEN [Refund Request] = 'Yes' THEN [Price] ELSE 0 END) * 100.0) / SUM([Price]), 1
        ) AS DECIMAL(10,1)), '%'
    ) AS Refund_Impact_Percentage
FROM [UKtrains].[dbo].[Dataset];

10--How does the revenue distribution vary by purchase type (Online vs. Station)?

SELECT 
    [Purchase Type], 
    SUM([Price]) AS Total_Revenue,
    COUNT(*) AS Ticket_Count,
    CONCAT(
        CAST(ROUND(
            (SUM([Price]) * 100.0) / SUM(SUM([Price])) OVER (), 1
        ) AS DECIMAL(10,1)), '%'
    ) AS Revenue_Share_Percentage
FROM [UKtrains].[dbo].[Dataset]
GROUP BY [Purchase Type]
ORDER BY Total_Revenue DESC;

11-- What are the top 10 station on basis of departure & arrival destination ?

SELECT top 10
    [Departure Station], 
    COUNT(*) AS Ticket_Count
FROM [UKtrains].[dbo].[Dataset]
GROUP BY [Departure Station]
ORDER BY Ticket_Count deSC;


SELECT top 10
    [Arrival Destination], 
    COUNT(*) AS Ticket_Count
FROM [UKtrains].[dbo].[Dataset]
GROUP BY [Arrival Destination]
ORDER BY Ticket_Count deSC;

12-- What are the busiest travel days of the week?

SELECT 
    DATENAME(WEEKDAY, [Date of Purchase]) AS Travel_Day, 
    COUNT(*) AS Ticket_Count
FROM [UKtrains].[dbo].[Dataset]
GROUP BY DATENAME(WEEKDAY, [Date of Purchase])
ORDER BY Ticket_Count DESC;

13-- What are the most underutilized routes ?

SELECT TOP 10
    [Departure Station], 
    [Arrival Destination], 
    COUNT(*) AS Ticket_Count
FROM [UKtrains].[dbo].[Dataset]
GROUP BY [Departure Station], [Arrival Destination]
ORDER BY Ticket_Count ASC;


14-- Most utilized routs 

SELECT TOP 10
    [Departure Station], 
    [Arrival Destination], 
    COUNT(*) AS Ticket_Count
FROM [UKtrains].[dbo].[Dataset]
GROUP BY [Departure Station], [Arrival Destination]
ORDER BY Ticket_Count deSC;

15--What are the key statistics of the ticket prices, including the lowest, highest, and average price?

SELECT 
    CAST(MIN([Price]) AS DECIMAL(10,2)) AS Lowest_Price, 
    CAST(MAX([Price]) AS DECIMAL(10,2)) AS Highest_Price, 
    CAST(ROUND(AVG([Price]), 2) AS DECIMAL(10,2)) AS Average_Price
FROM [UKtrains].[dbo].[Dataset];


16-- what is the total sales in uk trains ?

SELECT 
    CAST(SUM([Price]) AS DECIMAL(18,2)) AS Total_Sales
FROM [UKtrains].[dbo].[Dataset];

17-- Which Payment method has the highest sales volume

SELECT [Payment Method], 
       COUNT(*) AS Sales_Volume, 
       SUM([Price]) AS Total_Sales
FROM [UKtrains].[dbo].[Dataset]
GROUP BY [Payment Method]
ORDER BY Total_Sales DESC;

18-- Which are the most frequently used train stations

SELECT Station, COUNT(*) AS Usage_Count
FROM (
    SELECT [Departure Station] AS Station FROM [UKtrains].[dbo].[Dataset]
    UNION ALL
    SELECT [Arrival Destination] AS Station FROM [UKtrains].[dbo].[Dataset]
) AS Station_Usage
GROUP BY Station
ORDER BY Usage_Count DESC;

19-- what is the percent of total railcard holding by count & revrenue 

WITH RailcardData AS (
    SELECT 
        [Railcard], 
        COUNT(*) AS Railcard_Count, 
        SUM([Price]) AS Railcard_Revenue
    FROM [UKtrains].[dbo].[Dataset]
    GROUP BY [Railcard]
),
Totals AS (
    SELECT 
        SUM(Railcard_Count) AS Total_Count, 
        SUM(Railcard_Revenue) AS Total_Revenue
    FROM RailcardData
)
SELECT 
    r.[Railcard], 
    r.Railcard_Count, 
    FORMAT((r.Railcard_Count * 100.0 / t.Total_Count), 'N2') + '%' AS Percent_Count,
    r.Railcard_Revenue, 
    FORMAT((r.Railcard_Revenue * 100.0 / t.Total_Revenue), 'N2') + '%' AS Percent_Revenue
FROM RailcardData r, Totals t
ORDER BY r.Railcard_Revenue DESC;

20-- Impact of railcard holding on the total revenue

SELECT 
    [Railcard], 
    COUNT(*) AS Booking_Count, 
    SUM([Price]) AS Total_Sales_After_Discount,
    (SUM([Price]) * 0.33) AS Total_Sales_Before_Discount
FROM [UKtrains].[dbo].[Dataset]
WHERE [Railcard] IN ('Adult', 'Senior', 'Disabled')
GROUP BY [Railcard]
ORDER BY Total_Sales_Before_Discount DESC;












