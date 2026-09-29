-- Q14 Which plans, customer segments and acquisition channels
-- contribute the most to subscription churn and cancelled MRR?

SELECT
    p.plan_name,
    a.segment,
    a.acquisition_channel,

    COUNT(s.subscription_id) AS total_subscriptions,

    SUM(
        CASE
            WHEN s.status = 'cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_subscriptions,

    ROUND(
        SUM(
            CASE
                WHEN s.status = 'cancelled' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(s.subscription_id),
        2
    ) AS churn_rate,

    SUM(
        CASE
            WHEN s.status = 'cancelled' THEN s.mrr
            ELSE 0
        END
    ) AS cancelled_mrr

FROM subscriptions s

JOIN accounts a
    ON s.account_id = a.account_id

JOIN plans p
    ON s.plan_id = p.plan_id

GROUP BY
    p.plan_name,
    a.segment,
    a.acquisition_channel

HAVING COUNT(s.subscription_id) >= 50

ORDER BY
    cancelled_mrr DESC;