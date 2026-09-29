-- Q12 Does subscription churn vary based on customer tenure?

SELECT
    CASE
        WHEN DATEDIFF(
            COALESCE(s.ended_at, CURDATE()),
            s.started_at
        ) <= 90 THEN '0-3 months'

        WHEN DATEDIFF(
            COALESCE(s.ended_at, CURDATE()),
            s.started_at
        ) <= 180 THEN '3-6 months'

        WHEN DATEDIFF(
            COALESCE(s.ended_at, CURDATE()),
            s.started_at
        ) <= 365 THEN '6-12 months'

        ELSE '12+ months'
    END AS tenure_group,

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
    ) AS churn_rate

FROM subscriptions s

GROUP BY tenure_group

ORDER BY churn_rate DESC;


# “The tenure analysis shows a strong association between shorter subscription tenure and higher observed churn. 
-- The 6–12 month group has 78.83% churn, while the 12+ month group has only 10.01%. However, the 0–3 month group 
-- contains only two subscriptions, so I would not draw a conclusion from that group alone. I would investigate the 
-- early-tenure customers further by looking at plan, acquisition channel and segment.