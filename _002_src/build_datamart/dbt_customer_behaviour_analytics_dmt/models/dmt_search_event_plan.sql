{{ config(materialized='table') }}

WITH search_user_month AS (

    SELECT
        date_trunc('month', date.date) AS month_key,
        fact.user_id
    FROM {{ source('gold', 'fact_customer_search') }} fact
    JOIN {{ source('gold', 'dim_date') }} date
        ON fact.date_key = date.date_key
    WHERE fact.category = 'enter'
    GROUP BY 1, 2

),

plan_with_subscription AS (

    SELECT
        bridge.user_id,
        bridge.first_effective_date,
        bridge.recent_effective_date,
        subscription.plan_name,
        subscription.plan_type
    FROM {{ source('gold', 'bridge_user_plan') }} bridge
    JOIN {{ source('gold', 'dim_subscription') }} subscription
        ON bridge.subscription_key = subscription.subscription_key
)

SELECT
    to_char(s.month_key, 'MM/YYYY') AS monthly_date_key,
    p.plan_name,
    p.plan_type,
    COUNT(DISTINCT s.user_id) AS user_count

FROM search_user_month s
JOIN plan_with_subscription p
    ON p.user_id = s.user_id
   AND p.first_effective_date <= (s.month_key + INTERVAL '1 month - 1 day')
   AND (
        p.recent_effective_date IS NULL
        OR p.recent_effective_date >= s.month_key
   )

GROUP BY
    s.month_key,
    p.plan_name,
    p.plan_type

ORDER BY
    s.month_key,
    p.plan_name