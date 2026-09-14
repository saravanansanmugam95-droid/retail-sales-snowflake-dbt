{{ config(
    materialized='incremental',
    unique_key=['SALES_ORDER_ID', 'SALES_ORDER_ITEM'],
    schema='SILVER'
) }}

WITH cleaned AS (

    SELECT
        TRIM(VBELN) AS SALES_ORDER_ID,
        TRIM(POSNR) AS SALES_ORDER_ITEM,
        TRIM(MATNR) AS MATERIAL_ID,
        TRIM(WERKS) AS PLANT_ID,
        KWMENG AS ORDER_QUANTITY,
        TRIM(VRKME) AS SALES_UOM,
        NETPR AS NET_PRICE,
        TRIM(WAERK) AS CURRENCY,

        ROW_NUMBER() OVER (
            PARTITION BY
                TRIM(VBELN),
                TRIM(POSNR)
            ORDER BY
                KWMENG DESC,
                NETPR DESC
        ) AS RN

    FROM {{ source('bronze', 'VBAP_SALES_ITEM_RAW') }}

    WHERE NULLIF(TRIM(VBELN), '') IS NOT NULL
      AND NULLIF(TRIM(POSNR), '') IS NOT NULL
      AND NULLIF(TRIM(MATNR), '') IS NOT NULL
      AND NULLIF(TRIM(WERKS), '') IS NOT NULL
      AND KWMENG >= 0
      AND NETPR >= 0
)

SELECT
    SALES_ORDER_ID,
    SALES_ORDER_ITEM,
    MATERIAL_ID,
    PLANT_ID,
    ORDER_QUANTITY,
    SALES_UOM,
    NET_PRICE,
    CURRENCY

FROM cleaned

WHERE RN = 1