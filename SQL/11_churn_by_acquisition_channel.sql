-- Q11 How does subscription churn vary across
-- different customer acquisition channels?

SELECT
    a.acquisition_channel,
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
GROUP BY a.acquisition_channel
ORDER BY churn_rate DESC;

-- Outbound customers have the highest observed churn rate at 21.53%, 
-- while partner-acquired customers have the lowest at 16.80%. This indicates 
-- a difference in retention across acquisition channels, so I would investigate
-- customer segment, plan and tenure to understand the possible reasons behind this pattern.