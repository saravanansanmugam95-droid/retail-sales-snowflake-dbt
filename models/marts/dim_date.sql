{{ config(
    materialized='table',
    schema='GOLD',
    alias='DIM_DATE'
) }}

SELECT

    DATE_KEY,

    FULL_DATE,

    YEAR,

    QUARTER,

    MONTH,

    MONTH_NAME,

    WEEK_OF_YEAR,

    DAY_OF_MONTH,

    DAY_OF_WEEK,

    DAY_NAME,

    IS_WEEKEND,

    FISCAL_YEAR_VARIANT,

    FISCAL_YEAR,

    FISCAL_PERIOD

FROM {{ ref('stg_date') }}

WHERE DATE_KEY IS NOT NULL
  AND FULL_DATE IS NOT NULL