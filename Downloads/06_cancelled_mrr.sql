-- How much MRR comes from active subscriptions
-- compared with cancelled subscriptions?

SELECT
    status,
    SUM(mrr) AS total_mrr
FROM subscriptions
GROUP BY status
ORDER BY total_mrr DESC;