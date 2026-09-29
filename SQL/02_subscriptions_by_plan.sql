-- Q2 How many subscriptions does the company have for each plan?

SELECT
    p.plan_name,
    COUNT(s.subscription_id) AS total_subscriptions
FROM subscriptions s
JOIN plans p
    ON s.plan_id = p.plan_id
GROUP BY p.plan_name
ORDER BY total_subscriptions DESC;