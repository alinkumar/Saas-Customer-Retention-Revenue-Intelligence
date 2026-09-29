-- ============================================================
-- Business Question 01
-- ============================================================
-- How many total customer accounts does the company have,
-- and how many of them currently have an active subscription?
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM accounts) AS total_accounts,
    (SELECT COUNT(*)
     FROM subscriptions
     WHERE status = 'active') AS active_subscriptions;