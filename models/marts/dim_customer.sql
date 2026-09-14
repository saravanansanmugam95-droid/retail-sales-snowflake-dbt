{{ config(
    materialized='table'
) }}

SELECT
    CUSTOMER_ID,
    CUSTOMER_NAME,
    COUNTRY,
    REGION,
    CITY,
    CUSTOMER_ACCOUNT_GROUP,
    CREATED_DATE

FROM {{ ref('stg_customer') }}

WHERE CUSTOMER_ID IS NOT NULL