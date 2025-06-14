CREATE DATABASE music;

USE music
GO

/* Q1: Who is the senior most employee based on job title? */

SELECT TOP 1 *
FROM employee
ORDER BY levels DESC;



/* Q2: Which countries have the most Invoices? */

SELECT
	COUNT(*) AS Invoice_Count,
	billing_country AS Billing_Country
FROM
	invoice
GROUP BY
	billing_country
ORDER BY
	Invoice_Count DESC;



/* Q3: What are top 3 values of total invoice? */

SELECT TOP 3 CEILING(total) AS Total_Invoice_Count
FROM invoice
ORDER BY Total_Invoice_Count DESC;



/* Q4: Which city has the best customers?
We would like to throw a promotional Music Festival in the city we made the most money.
Write a query that returns one city that has the highest sum of invoice totals.
Return both the city name & sum of all invoice totals. */

SELECT
	TOP 1 billing_city AS City_Name,
	CEILING(SUM(total)) AS Total_Invoice_Sum
FROM
	invoice
GROUP BY
	billing_city
ORDER BY
	Total_Invoice_Sum DESC;



/* Q5: Who is the best customer?
The customer who has spent the most money will be declared the best customer.
Write a query that returns the person who has spent the most money. */

SELECT
	TOP 1 c.customer_id AS Customer_ID,
	c.first_name AS First_Name, 
	c.last_name AS Last_Name,
	CEILING(SUM(i.total)) AS Total_Money_Spent
FROM
	customer c
JOIN
	invoice i ON i.customer_id = c.customer_id
GROUP BY
	c.customer_id, c.first_name, c.last_name
ORDER BY
	Total_Money_Spent DESC;



/* Q6: Write a query to return the email, first name, last name, & genre of all Rock Music listeners.
Return your list ordered alphabetically by email starting with A. */

SELECT
	DISTINCT c.first_name AS First_Name,
	c.last_name AS Last_Name,
	c.email AS Email_ID,
	g.name AS Genre
FROM
	customer c
JOIN
	invoice i ON i.customer_id = c.customer_id
JOIN
	invoice_line il ON il.invoice_id = i.invoice_id
JOIN
	track t ON t.track_id = il.track_id
JOIN
	genre g ON g.genre_id = t.genre_id
WHERE
	g.name IN ('Rock')
ORDER BY
	Email_ID ASC;



/* Q7: Let's invite the artists who have written the most rock music in our dataset.
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT
	TOP 10 a.artist_id AS Artist_ID,
	a.name AS Artist_Name,
	g.name AS Genre,
	COUNT(a.artist_id) AS Number_of_Songs
FROM
	artist a
JOIN
	album al ON al.artist_id = a.artist_id
JOIN
	track t ON t.album_id = al.album_id
JOIN
	genre g ON g.genre_id = t.genre_id
WHERE
	g.name IN ('Rock')
GROUP BY
	a.artist_id, a.name, g.name
ORDER BY
	Number_of_Songs DESC;



/* Q8: Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track.
Order by the song length with the longest songs listed first. */

SELECT
	t.track_id AS Track_ID,
	t.name AS Track_Name,
	t.milliseconds AS Track_Length
FROM
	track t
WHERE
	t.milliseconds > (SELECT AVG(t.milliseconds) AS Avg_Track_Length
			FROM track t)
GROUP BY
	t.track_id,
	t.name,
	t.milliseconds
ORDER BY
	Track_Length DESC;



/* Q9: Find how much amount spent by each customer on artists?
Write a query to return customer name, artist name and total spent. */

WITH Best_Selling_Artist AS (
		SELECT
			TOP 1 a.artist_id AS Artist_ID,
			a.name AS Artist_Name,
			SUM(il.unit_price * il.quantity) AS Total_Sales
		FROM
			artist a
		JOIN
			album al ON al.artist_id = a.artist_id
		JOIN
			track t ON t.album_id = al.album_id
		JOIN
			invoice_line il ON il.track_id = t.track_id
		GROUP BY
			a.artist_id,
			a.name
		ORDER BY
			Total_Sales DESC
)
SELECT
	c.customer_id AS Customer_ID,
	c.first_name AS First_Name,
	c.last_name AS Last_Name,
	bsa.Artist_Name AS Artist_Name,
	SUM(il.unit_price * il.quantity) AS Total_Spent
FROM
	customer c
JOIN
	invoice i ON i.customer_id = c.customer_id
JOIN
	invoice_line il ON il.invoice_id = i.invoice_id
JOIN
	track t ON t.track_id = il.track_id
JOIN
	album a ON a.album_id = t.album_id
JOIN
	Best_Selling_Artist bsa ON bsa.Artist_ID = a.artist_id
GROUP BY
	c.customer_id,
	c.first_name,
	c.last_name,
	bsa.Artist_Name
ORDER BY
	Total_Spent DESC;



/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases.
Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres. */

WITH Popular_Genre AS (
		SELECT
			g.genre_id AS Genre_ID,
			g.name AS Genre_Name,
			c.country AS Country,
			COUNT(il.quantity) AS Highest_Purchase,
			ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS Rank_No
		FROM
			genre g
		JOIN
			track t ON t.genre_id = g.genre_id
		JOIN
			invoice_line il ON il.track_id = t.track_id
		JOIN
			invoice i ON i.invoice_id = il.invoice_id
		JOIN
			customer c ON c.customer_id = i.customer_id
		GROUP BY
			g.genre_id,
			g.name,
			c.country
)
SELECT *
FROM Popular_Genre
WHERE Rank_No <= 1
ORDER BY Country ASC;



/* Q11: Write a query that determines the customer that has spent the most on music for each country.
Write a query that returns the country along with the top customer and how much they spent.
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH Customer_with_Country AS (
		SELECT
			c.customer_id AS Customer_ID,
			c.first_name AS First_Name,
			c.last_name AS Last_Name,
			i.billing_country AS Billing_Country,
			CEILING(SUM(i.total)) AS Total_Spent,
			ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS Rank_No
		FROM
			customer c
		JOIN
			invoice i ON i.customer_id = c.customer_id
		GROUP BY
			c.customer_id,
			c.first_name,
			c.last_name,
			i.billing_country
)
SELECT *
FROM Customer_with_Country
WHERE Rank_No <= 1
ORDER BY Billing_Country ASC;
