-- The product image quantity affect on on the happiness (review score).

SELECT TOP(50)  p.[product_photos_qty],ROUND(AVG(CAST(o.[review_score] AS float)),2) AS [review_score],count([order_item_id]) AS 'Number of Orders'
FROM  [dbo].[order_reviews] o
JOIN order_items oi ON o.order_id= oi.order_id
JOIN [dbo].[products] p ON oi.product_id=p.product_id
GROUP BY p.[product_photos_qty]
ORDER BY ROUND(AVG(CAST(o.[review_score] AS float)),2)  DESC


--Description vs review score
SELECT 
CASE 
WHEN ISNULL(product_description_lenght,0)=0 THEN 'No description'
WHEN ISNULL(product_description_lenght,0)>1 AND  ISNULL(product_description_lenght,0)<=300 THEN 'Very short description'
WHEN ISNULL(product_description_lenght,0)>300 AND ISNULL(product_description_lenght,0)<=500 THEN 'Short description'
WHEN ISNULL(product_description_lenght,0)>500 AND ISNULL(product_description_lenght,0)<=1500 THEN 'Medium description'
WHEN ISNULL(product_description_lenght,0)>1500 AND ISNULL(product_description_lenght,0)<=3000 THEN 'Long description'
WHEN ISNULL(product_description_lenght,0)>3000 THEN 'Very long description'
END AS [description_category], -- Classifies the product description into user defined categories in order to make product description analysis easier to analyse
ROUND(AVG(CAST(o.[review_score] AS float)),2) AS [review_score], -- Gets the average review score (Converted tinyint to float to output values to the nearest 2 decimal)
count([order_item_id]) AS 'Number of Orders'
FROM  [dbo].[order_reviews] o
JOIN order_items oi ON o.order_id= oi.order_id
JOIN [dbo].[products] p ON oi.product_id=p.product_id
GROUP BY CASE 
WHEN ISNULL(product_description_lenght,0)=0 THEN 'No description'
WHEN ISNULL(product_description_lenght,0)>1 AND  ISNULL(product_description_lenght,0)<=300 THEN 'Very short description'
WHEN ISNULL(product_description_lenght,0)>300 AND ISNULL(product_description_lenght,0)<=500 THEN 'Short description'
WHEN ISNULL(product_description_lenght,0)>500 AND ISNULL(product_description_lenght,0)<=1500 THEN 'Medium description'
WHEN ISNULL(product_description_lenght,0)>1500 AND ISNULL(product_description_lenght,0)<=3000 THEN 'Long description'
WHEN ISNULL(product_description_lenght,0)>3000 THEN 'Very long description'
END
ORDER BY ROUND(AVG(CAST(o.[review_score] AS float)),2)  DESC



--SELECT TOP(50)  p.[product_photos_qty],ROUND(AVG(CAST(o.[review_score] AS float)),2) AS [review_score]
--FROM  [dbo].[order_reviews] o
--JOIN order_items oi ON o.order_id= oi.order_id
--JOIN [dbo].[products] p ON oi.product_id=p.product_id
--GROUP BY p.[product_photos_qty]
--ORDER BY AVG(o.[review_score])  DESC



--SELECT TOP(1000) p.product_description_lenght
--FROM products p
--WHERE product_description_lenght is not null
--ORDER BY product_description_lenght 

--SELECT * FROM [dbo].[orders]


--SELECT TOP(50)  p.[product_photos_qty],ROUND(AVG(CAST(o.[review_score] AS float)),2) AS [review_score]
--FROM  [dbo].[order_reviews] o
--JOIN order_items oi ON o.order_id= oi.order_id
--JOIN [dbo].[products] p ON oi.product_id=p.product_id
--GROUP BY p.[product_photos_qty]
--ORDER BY ROUND(AVG(CAST(o.[review_score] AS float)),2)  DESC


--SELECT TOP(50)  p.[product_photos_qty],ROUND(AVG(CAST(o.[review_score] AS float)),2) AS [review_score],count([order_item_id]) AS 'Number of Orders'
--FROM  [dbo].[order_reviews] o
--JOIN order_items oi ON o.order_id= oi.order_id
--JOIN [dbo].[products] p ON oi.product_id=p.product_id 
--GROUP BY p.[product_photos_qty]
--HAVING count([order_item_id])>100
--ORDER BY ROUND(AVG(CAST(o.[review_score] AS float)),2)  DESC


--------------------------------------------------------------------------------------------------------------------------------------------------------

--All Products making losses more than -100 dollars per city

SELECT customer_city,category_name,[Total Sales Amount],[Total Cost],[Total Sales Amount]-[Total Cost] AS [Profit Amount]
FROM 
(SELECT  c.customer_city,
SUM([payment_installments]*op.payment_value) AS 'Total Sales Amount', --Gets the total sales value amount by including all the installments
p.category_name,
seller_id,
SUM(price+[freight_value]) AS [Total Cost] --Adds price and freight value to get total cost from suppliers
FROM  [dbo].[order_reviews] o
JOIN order_items oi ON o.order_id= oi.order_id
JOIN [dbo].[product_category_name_english] p ON oi.product_id=p.product_id 
JOIN orders os ON os.order_id=oi.order_id 
JOIN customers c ON c.customer_id=os.customer_id
JOIN order_payments op ON op.order_id=os.order_id
GROUP BY c.customer_city,p.category_name,seller_id
) AS  [Most Profitable Product Per City] -- Gets the most profitable product according to the city in which the customer bought the product
WHERE [Total Sales Amount]-[Total Cost]<-100 -- Negative Threshold of loss value assumed to be deemed "acceptable"
ORDER BY [Total Sales Amount]-[Total Cost] 


--------------------------------------------------------------------------------------------------------------------------------------------------------

---If the order is delivered past the estimated date how does that affect the customers happiness (review score)
SELECT 
CASE 
WHEN order_estimated_delivery_date < [order_delivered_customer_date] THEN 'Yes'
ELSE 'No'
END AS [Is Delivered Later Than Estimated Date], -- Categorizes the deliveries to customers to identify whether an order is late or not 
ROUND(AVG(CAST(o.[review_score] AS float)),2) AS [review_score] -- Gets the average review score (Converted tinyint to float to output values to the nearest 2 decimal)
FROM [dbo].[order_reviews] o
JOIN order_items oi ON o.order_id= oi.order_id
JOIN [dbo].[product_category_name_english] p ON oi.product_id=p.product_id 
JOIN orders os ON os.order_id=oi.order_id 
GROUP BY 
CASE 
WHEN order_estimated_delivery_date < [order_delivered_customer_date] THEN 'Yes'
ELSE 'No'
END
ORDER BY review_score desc

