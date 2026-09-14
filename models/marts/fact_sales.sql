{{ config(
    materialized='table',
    schema='GOLD',
    alias='FACT_SALES'
) }}

SELECT

    so.SALES_ORDER_ID AS TRANSACTION_ID,

    so.SALES_ORDER_ID,

    si.SALES_ORDER_ITEM,

    TO_NUMBER(
        TO_CHAR(so.ORDER_DATE, 'YYYYMMDD')
    ) AS DATE_KEY,

    so.CUSTOMER_ID,

    si.MATERIAL_ID,

    si.PLANT_ID,

    so.SALES_ORGANIZATION AS SALES_ORGANIZATION_ID,

    si.ORDER_QUANTITY AS QUANTITY,

    si.NET_PRICE AS UNIT_PRICE,

    ROUND(
        si.ORDER_QUANTITY * si.NET_PRICE,
        2
    ) AS SALES_AMOUNT,

    so.CURRENCY

FROM {{ ref('stg_sales_order') }} so

INNER JOIN {{ ref('stg_sales_item') }} si

    ON so.SALES_ORDER_ID = si.SALES_ORDER_ID

WHERE so.SALES_ORDER_ID IS NOT NULL
  AND si.SALES_ORDER_ITEM IS NOT NULL