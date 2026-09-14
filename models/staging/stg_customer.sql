{{ config(
    materialized='incremental',
    unique_key='CUSTOMER_ID',
    schema='SILVER'
) }}

WITH cleaned AS (

    SELECT
        TRIM(KUNNR) AS CUSTOMER_ID,
        TRIM(NAME1) AS CUSTOMER_NAME,
        TRIM(LAND1) AS COUNTRY,
        TRIM(REGIO) AS REGION,
        TRIM(ORT01) AS CITY,
        TRIM(KTOKD) AS CUSTOMER_ACCOUNT_GROUP,
        ERDAT AS CREATED_DATE,

        ROW_NUMBER() OVER (
            PARTITION BY TRIM(KUNNR)
            ORDER BY ERDAT DESC
        ) AS RN

    FROM {{ source('bronze', 'KNA1_CUSTOMER_RAW') }}

    WHERE NULLIF(TRIM(KUNNR), '') IS NOT NULL
      AND NULLIF(TRIM(NAME1), '') IS NOT NULL
)

SELECT
    CUSTOMER_ID,
    CUSTOMER_NAME,
    COUNTRY,
    REGION,
    CITY,
    CUSTOMER_ACCOUNT_GROUP,
    CREATED_DATE

FROM cleaned

WHERE RN = 1