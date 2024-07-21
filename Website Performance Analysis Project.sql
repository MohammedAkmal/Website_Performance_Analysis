USE mavenfuzzyfactory;


--  Q1: What are the monthly trends for Gsearch sessions and orders to showcase its growth as the biggest driver of our business?

SELECT 
	YEAR(website_sessions.created_at) AS Year,
	MONTH(website_sessions.created_at) As Month,
    COUNT(DISTINCT website_sessions.website_session_id) AS Sessions,
    COUNT(DISTINCT orders.order_id) AS Orders,
   ROUND(COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id)*100,2) As CVR 
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.created_at < '2012-11-27'
GROUP BY
	1,2;
 
 
--  Q2: Next, What are the monthly trends for Gsearch sessions and orders,
-- separated by nonbrand and brand campaigns, to determine if brand campaigns are picking up?

SELECT 
	YEAR(website_sessions.created_at) AS Year,
    MONTH(website_sessions.created_at) As Month,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS Nonbrand_Sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS Nonbrand_Orders,
    ROUND(COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) *100,2) AS Nonbrand_CVR,
	
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS Brand_Sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS Brand_Orders,
    ROUND(COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END)*100,2) AS Brand_CVR

FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.created_at < '2012-11-27'
GROUP BY 
	1,2;


-- Q3: What are the monthly trends for Gsearch nonbrand sessions and orders, 
-- split by device type, to demonstrate our detailed understanding of traffic sources?


SELECT 
    MONTH(website_sessions.created_at) As Month,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS Desktop_Sessions,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS Desktop_Orders,
    ROUND(COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) *100,2) AS Desktop_CVR,
	
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS Mobile_Sessions,
	COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS Mobile_Orders,
    ROUND(COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END)*100,2) AS Mobile_CVR

FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
	AND website_sessions.created_at < '2012-11-27'
GROUP BY 
	1;
    
    
-- Q4: What are the monthly trends for Gsearch compared to the monthly trends for each of our other channels to address concerns about the high percentage of traffic from Gsearch?

-- First, find the various utm sources and referers to see the traffic we're getting
SELECT DISTINCT
	utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE created_at < '2012-11-27';

-- NOW, If utm_source and utm_campaign IS NULL and http_referer IS NOT NULL,
-- it means the sessions come from organic search sessions.

-- AND If utm_source and utm_campaign IS NULL and http_referer IS NULL,
-- it means the sessions come directly from the web / users directly type the website link.

SELECT
  EXTRACT(YEAR_MONTH FROM website_sessions.created_at) AS YearMonth,
  COUNT(website_sessions.website_session_id) AS Sessions,
  COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_Paid_Sessions,
  COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_Paid_Sessions,
  COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS Organic_Search_Sessions,
  COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS Direct_Type_Sessions
FROM website_sessions
  LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1;


-- Q5: What are the monthly session-to-order conversion rates over the first 8 months to illustrate the story of our website performance improvements?


SELECT
  MONTH(website_sessions.created_at) AS Month,
  COUNT(DISTINCT website_sessions.website_session_id) AS Sessions,
  COUNT(DISTINCT order_id) AS Orders,
  ROUND(COUNT(DISTINCT order_id) / COUNT(DISTINCT website_sessions.website_session_id)*100, 2) AS CVR
FROM website_sessions
  LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1;


-- Q6: What is the estimated revenue earned from the Gsearch lander test,
-- based on the increase in conversion rate from June 19 to July 28,
-- and using nonbrand sessions and revenue since then to calculate the incremental value?


-- Find out the minimum or first pageview id for '/lander-1' 
SELECT
  MIN(website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';

-- The Minimum_PageView_ID is 23504

-- Calculate The CVR for The relevant Entry Pages
SELECT
  website_pageviews.pageview_url AS LANDING_PAGE,
  COUNT(DISTINCT website_sessions.website_session_id) AS Total_Sessions,
  COUNT(DISTINCT orders.order_id) AS Total_Orders,
  ROUND(COUNT(DISTINCT orders.order_id)/
    COUNT(DISTINCT website_sessions.website_session_id) * 100.0,2) AS CVR
FROM website_sessions
INNER JOIN website_pageviews
  ON website_sessions.website_session_id = website_pageviews.website_session_id
LEFT JOIN orders
  ON website_sessions.website_session_id = orders.website_session_id
WHERE website_pageviews.website_pageview_id >= 23504
  AND website_sessions.created_at < '2012-07-28'
  AND website_sessions.utm_source = 'gsearch'
  AND website_sessions.utm_campaign = 'nonbrand'
  AND website_pageviews.pageview_url IN ('/home', '/lander-1')
GROUP BY website_pageviews.pageview_url;

-- Homepage lander conversion rate's is 3.18%, while new test lander page's conversion rate is 4.06%.
-- The conversion rate is increased by 0.88%.

-- Now, Calculate estimate revenue

-- First we need to find the last time '/home' page appeared, then we count the total sessions since that.

SELECT
  MAX(website_sessions.website_session_id) AS Most_Recent_HomePage_Sessions
FROM website_sessions
  LEFT JOIN website_pageviews
  ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
  AND website_sessions.utm_campaign = 'nonbrand'
  AND website_pageviews.pageview_url = '/home' -- Home landing page
  AND website_sessions.created_at < '2012-11-27';
  
-- Max website_session_id for /home is 17145
-- After this session, there are no more /home landing page,
-- and all landing page has been replaced with /lander-1

SELECT
  COUNT(website_session_id) AS New_Sessions
FROM website_sessions
WHERE
  created_at < '2012-11-27'
  AND website_session_id >= 17145 -- last home session
  AND utm_source = 'gsearch'
  AND utm_campaign = 'nonbrand';
  
-- Total of sessions using /lander-1 = 22,973
-- Conversion rate difference: 0.88%
-- 22,973 x 0.88% = estimated at least 202 incremental orders since July 29 using \lander-1 page for roughly 4 months
-- 202/4 = 50 additional orders per month. Awesome!!


-- Q7: For the landing page test you analyzed previously, 
-- What does the full conversion funnel from each of the two landing pages to orders look like for the period from June 19 to July 28?

-- STEP 1: Select all pageviews for relevant sessions
-- STEP 2: Identify each relevant pagview as the specific funnel step
-- STEP 3: Create the session-level conversion funnel view
-- STEP 4: Aggregate the data to asses funnel performance CTR 



SELECT
  MIN(website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';

-- First test lander-1 pageviews is 23504
-- STEP 1:

SELECT
  website_sessions.website_session_id,
  website_pageviews.pageview_url,
  -- website_pageviews.created_at AS pageview_created_at,
  CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS Home_Page,
  CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander1_Page,
  CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS Product_Page,
  CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS MrFuzzy_Page,
  CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS Cart_Page,
  CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS Shipping_Page,
  CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS Billing_Page,
  CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS ThankYou_Page
FROM website_sessions
  LEFT JOIN website_pageviews
    ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
  website_sessions.utm_source = 'gsearch'
  AND website_sessions.utm_campaign = 'nonbrand'
  AND website_pageview_id >= 23504
  AND website_pageviews.created_at < '2012-07-28'
  AND website_pageviews.pageview_url IN ('/home', '/lander-1', '/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
ORDER BY
  website_sessions.website_session_id,
  website_pageviews.created_at;

-- STEP 2:
-- Next we will put the previous query inside a Subquery 
-- we will group by website_session_id, and take the MAX() of each of the flags
-- this MAX() becomes a made it flag for that session, to show the session made it there

-- STEP 3: THEN Turn the Subquery it into Temp Table
CREATE TEMPORARY TABLE Sessions_Level_made_it_flags
SELECT
  website_session_id,
  MAX(homepage) AS saw_homepage,
  MAX(custom_lander) AS saw_custom_lander,
  MAX(product_page) AS Product_made_it,
  MAX(mrfuzzy_page) AS MrFuzzy_made_it,
  MAX(cart_page) AS Cart_made_it,
  MAX(shipping_page) AS Shipping_made_it,
  MAX(billing_page) AS Billing_made_it,
  MAX(thankyou_page) AS ThankYou_made_it
FROM(
SELECT
  website_sessions.website_session_id,
  website_pageviews.pageview_url,
  website_pageviews.created_at AS pageview_created_at,
  CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
  CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
  CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
  CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
  CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
  CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
  CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
  CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
  LEFT JOIN website_pageviews
    ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
  website_sessions.utm_source = 'gsearch'
  AND website_sessions.utm_campaign = 'nonbrand'
  AND website_pageviews.created_at < '2012-07-28'
  AND website_pageviews.created_at > '2012-06-19'
ORDER BY
  website_sessions.website_session_id,
  website_pageviews.created_at
) AS pageview_level
GROUP BY 1;

SELECT * FROM Sessions_Level_made_it_flags; -- QA ONLY

-- then this will produce the final output (part 1)
-- STEP 4:
SELECT
  CASE
    WHEN saw_homepage = 1 THEN 'saw_homepage'
    WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
    ELSE 'uh oh... check logic'
    END AS Segment,
  COUNT(DISTINCT website_session_id) AS Sessions,
  COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS To_products,
  COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS To_MrFuzzy,
  COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS To_Cart,
  COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS To_Shipping,
  COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS To_Billing,
  COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS To_ThankYou
FROM
  Sessions_Level_made_it_flags
GROUP BY 1;

-- then this is the final output part 2, click rates or conversion rates
-- click rates or conversion rates is percentage of click rate from certain page divided by total sessions

SELECT
  CASE
    WHEN saw_homepage = 1 THEN 'saw_homepage'
    WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
    ELSE 'uh oh... check logic'
    END AS Segment,
    
  ROUND(COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) /
    COUNT(DISTINCT website_session_id) * 100.0, 2) AS Products_CTR,
    
  ROUND(COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) /
    COUNT(DISTINCT website_session_id) * 100.0, 2) AS MrFuzzy_CTR,
    
  ROUND(COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) /
    COUNT(DISTINCT website_session_id) * 100.0, 2) AS Cart_CTR,
    
  ROUND(COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) /
    COUNT(DISTINCT website_session_id) * 100.0, 2) AS Shipping_CTR,
    
  ROUND(COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) /
    COUNT(DISTINCT website_session_id) * 100.0, 2) AS Billing_CTR,
    
  ROUND(COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) /
    COUNT(DISTINCT website_session_id) * 100.0, 2) AS ThankYou_CTR
    
FROM
  Sessions_Level_made_it_flags
GROUP BY 1;


