{{ config(
    materialized='incremental',
    unique_key='PLANT_ID',
    schema='SILVER'
) }}

WITH cleaned AS (

    SELECT
        TRIM(WERKS) AS PLANT_ID,
        TRIM(NAME1) AS PLANT_NAME,
        TRIM(LAND1) AS COUNTRY,
        TRIM(REGIO) AS REGION,
        TRIM(ORT01) AS CITY,
        ERDAT AS CREATED_DATE,

        ROW_NUMBER() OVER (
            PARTITION BY TRIM(WERKS)
            ORDER BY ERDAT DESC
        ) AS RN

    FROM {{ source('bronze', 'T001W_PLANT_RAW') }}

    WHERE NULLIF(TRIM(WERKS), '') IS NOT NULL
      AND NULLIF(TRIM(NAME1), '') IS NOT NULL
)

SELECT
    PLANT_ID,
    PLANT_NAME,
    COUNTRY,
    REGION,
    CITY,
    CREATED_DATE

FROM cleaned

WHERE RN = 1