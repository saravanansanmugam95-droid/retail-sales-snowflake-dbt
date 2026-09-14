{{ config(
    materialized='table',
    schema='SILVER'
) }}

WITH fiscal_period AS (

    SELECT
        TRIM(MANDT) AS CLIENT,
        TRIM(PERIV) AS FISCAL_YEAR_VARIANT,
        TRY_TO_NUMBER(BDATJ) AS CALENDAR_YEAR,
        TRY_TO_NUMBER(BUMON) AS CALENDAR_MONTH,
        TRY_TO_DATE(BUTAG, 'YYYYMMDD') AS PERIOD_END_DATE,
        TRY_TO_NUMBER(POPER) AS FISCAL_PERIOD,
        TRY_TO_NUMBER(RELJR) AS RELATIVE_YEAR

    FROM {{ source('bronze', 'T009B_FISCAL_PERIOD_RAW') }}

    WHERE NULLIF(TRIM(MANDT), '') IS NOT NULL
      AND NULLIF(TRIM(PERIV), '') IS NOT NULL
      AND BDATJ IS NOT NULL
      AND BUMON IS NOT NULL

),

calendar AS (

    SELECT
        DATEADD(
            DAY,
            SEQ4(),
            TO_DATE('2025-01-01')
        ) AS FULL_DATE

    FROM TABLE(
        GENERATOR(
            ROWCOUNT => 731
        )
    )

),

final AS (

    SELECT
        TO_NUMBER(TO_CHAR(c.FULL_DATE, 'YYYYMMDD')) AS DATE_KEY,

        c.FULL_DATE,

        YEAR(c.FULL_DATE) AS YEAR,

        QUARTER(c.FULL_DATE) AS QUARTER,

        MONTH(c.FULL_DATE) AS MONTH,

        TO_CHAR(c.FULL_DATE, 'MMMM') AS MONTH_NAME,

        WEEKOFYEAR(c.FULL_DATE) AS WEEK_OF_YEAR,

        DAY(c.FULL_DATE) AS DAY_OF_MONTH,

        DAYOFWEEK(c.FULL_DATE) AS DAY_OF_WEEK,

        TO_CHAR(c.FULL_DATE, 'Day') AS DAY_NAME,

        CASE
            WHEN DAYOFWEEK(c.FULL_DATE) IN (6, 7)
            THEN TRUE
            ELSE FALSE
        END AS IS_WEEKEND,

        fp.FISCAL_YEAR_VARIANT,

        fp.FISCAL_PERIOD,

        COALESCE(
            fp.CALENDAR_YEAR,
            YEAR(c.FULL_DATE)
        ) AS FISCAL_YEAR

    FROM calendar c

    LEFT JOIN fiscal_period fp
        ON YEAR(c.FULL_DATE) = fp.CALENDAR_YEAR
       AND MONTH(c.FULL_DATE) = fp.CALENDAR_MONTH

)

SELECT *
FROM final