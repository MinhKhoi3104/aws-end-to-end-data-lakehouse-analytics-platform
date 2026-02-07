{{ config(materialized='table') }}

WITH base AS (

    SELECT
<<<<<<< HEAD
        event_id,
=======
>>>>>>> 2edeb30c7e0779508b73f9ceb592d70c62179153
        date_key,
        month,
        year,
        day,
        day_of_week,
        time_slot,
        user_id,
        user_state_at_search,
        device_type,
        main_category,
        sub1_category,
        sub2_category,
        sub3_category
    FROM {{ ref('dmt_search_event_base') }}
    WHERE main_category <> 'not_matched'
),

category_exploded AS (

    SELECT DISTINCT
<<<<<<< HEAD
        b.event_id,
=======
>>>>>>> 2edeb30c7e0779508b73f9ceb592d70c62179153
        b.date_key,
        b.month,
        b.year,
        b.day,
        b.day_of_week,
        b.time_slot,
        b.user_id,
        b.user_state_at_search,
        b.device_type,
        c.category

    FROM base b

    CROSS JOIN LATERAL (
        VALUES 
            (b.main_category),
            (b.sub1_category),
            (b.sub2_category),
            (b.sub3_category)
    ) AS c(category)

    WHERE c.category IS NOT NULL
)

SELECT *
FROM category_exploded