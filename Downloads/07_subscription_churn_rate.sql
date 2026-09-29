-- Q7 What percentage of subscriptions have been cancelled?

SELECT
    ROUND(
        SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_churn_rate
FROM subscriptions;

-- The subscription churn rate is 19.30%, which means around 19% of the subscriptions in our dataset have been cancelled. 
-- This indicates that the company is losing a noticeable portion of its subscription base, so I would investigate 
-- which plans, customer segments, regions, or acquisition channels are contributing most to cancellations.