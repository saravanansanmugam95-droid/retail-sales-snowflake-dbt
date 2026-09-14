{{ config(
    materialized='table'
) }}

SELECT
    PLANT_ID,
    PLANT_NAME,
    COUNTRY,
    REGION,
    CITY,
    CREATED_DATE

FROM {{ ref('stg_plant') }}

WHERE PLANT_ID IS NOT NULL