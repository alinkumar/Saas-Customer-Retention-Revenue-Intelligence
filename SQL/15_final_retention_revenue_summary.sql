-- Q15 What is the overall retention and revenue impact
-- of customer cancellations?

SELECT
    COUNT(*) AS total_subscriptions,

    SUM(
        CASE
            WHEN status = 'active' THEN 1
            ELSE 0
        END
    ) AS active_subscriptions,

    SUM(
        CASE
            WHEN status = 'cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_subscriptions,

    ROUND(
        SUM(
            CASE
                WHEN status = 'cancelled' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS churn_rate,

    SUM(
        CASE
            WHEN status = 'active' THEN mrr
            ELSE 0
        END
    ) AS active_mrr,

    SUM(
        CASE
            WHEN status = 'cancelled' THEN mrr
            ELSE 0
        END
    ) AS cancelled_mrr

FROM subscriptions;