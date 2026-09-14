{{ config(
    materialized='table'
) }}

SELECT
    MATERIAL_ID,
    MATERIAL_NAME,
    MATERIAL_GROUP,
    BASE_UOM,
    MATERIAL_TYPE,
    INDUSTRY_SECTOR,
    CREATED_DATE

FROM {{ ref('stg_material') }}

WHERE MATERIAL_ID IS NOT NULL