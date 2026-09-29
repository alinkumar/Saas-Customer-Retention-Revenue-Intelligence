-- Q10 How does subscription churn vary across different
-- customer segments?

SELECT
    a.segment,
    COUNT(s.subscription_id) AS total_subscriptions,
    SUM(CASE WHEN s.status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_subscriptions,
    ROUND(
        SUM(CASE WHEN s.status = 'cancelled' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(s.subscription_id),
        2
    ) AS churn_rate
FROM subscriptions s
JOIN accounts a
    ON s.account_id = a.account_id
GROUP BY a.segment
ORDER BY churn_rate DESC;

-- SMB has the highest observed churn rate at 19.85%, followed by Enterprise at 19.34%, while Mid-Market has 
-- the lowest at 17.65%. This suggests churn varies somewhat by customer segment, but segment alone does not explain
 -- the reason for churn. I would investigate other dimensions such as region, acquisition channel and customer tenure
 -- before drawing a conclusion.