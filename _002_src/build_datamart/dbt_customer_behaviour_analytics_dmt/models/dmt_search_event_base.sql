{{ config(materialized='table') }}

SELECT
    fact.event_id,
    fact.date_key,
    date.day,
    date.month,
    date.year,
    date.day_of_week,

    CASE
        WHEN EXTRACT(HOUR FROM fact.datetime_log) BETWEEN 1 AND 4  THEN 'Late Night'
        WHEN EXTRACT(HOUR FROM fact.datetime_log) BETWEEN 5 AND 8  THEN 'Early Morning'
        WHEN EXTRACT(HOUR FROM fact.datetime_log) BETWEEN 9 AND 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM fact.datetime_log) BETWEEN 13 AND 16 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM fact.datetime_log) BETWEEN 17 AND 20 THEN 'Evening'
        ELSE 'Night'
    END AS time_slot,

    fact.user_id,

    CASE
        WHEN fact.user_id = '00000000' THEN 'guest'

        WHEN EXISTS (
            SELECT 1
            FROM {{ source('gold', 'bridge_user_plan') }} bridge
            WHERE bridge.user_id = fact.user_id
            AND bridge.first_effective_date
                <= fact.datetime_log::date
            AND (
                    bridge.recent_effective_date IS NULL
                    OR bridge.recent_effective_date >= fact.datetime_log::date
            )
        ) THEN 'plan'

        ELSE 'noplan'
    END AS user_state_at_search,


    platform.device_type,
    network.proxy_isp AS network_name,
    network.isp_group AS network_location,

    fact.keyword,
    main_cat.category_name AS main_category,
    sub1_cat.category_name AS sub1_category,
    sub2_cat.category_name AS sub2_category,
    sub3_cat.category_name AS sub3_category

FROM {{ source('gold', 'fact_customer_search') }} fact

JOIN {{ source('gold', 'dim_date') }} date
    ON fact.date_key = date.date_key

LEFT JOIN {{ source('gold', 'dim_platform') }} platform
    ON fact.platform_key = platform.platform_key

LEFT JOIN {{ source('gold', 'dim_network') }} network
    ON fact.network_key = network.network_key

LEFT JOIN {{ source('gold', 'dim_category') }} main_cat
    ON fact.main_keyword_category = main_cat.category_key

LEFT JOIN {{ source('gold', 'dim_category') }} sub1_cat
    ON fact.sub1_keyword_category = sub1_cat.category_key

LEFT JOIN {{ source('gold', 'dim_category') }} sub2_cat
    ON fact.sub2_keyword_category = sub2_cat.category_key

LEFT JOIN {{ source('gold', 'dim_category') }} sub3_cat
    ON fact.sub3_keyword_category = sub3_cat.category_key

WHERE fact.category = 'enter'