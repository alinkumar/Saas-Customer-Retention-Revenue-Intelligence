-- Q9 How much Monthly Recurring Revenue (MRR)
-- is associated with cancelled subscriptions
-- for each subscription plan?

SELECT
    p.plan_name,
    SUM(s.mrr) AS cancelled_mrr
FROM subscriptions s
JOIN plans p
    ON s.plan_id = p.plan_id
WHERE s.status = 'cancelled'
GROUP BY p.plan_name
ORDER BY cancelled_mrr DESC;