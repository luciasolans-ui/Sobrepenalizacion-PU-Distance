-- =====================================================================================
-- BLOQUE 2: PROYECTO SOBREPENALIZACIÓN PU DISTANCES (HISTÓRICO ABRIL - AGOSTO 2026)
--
-- Esta consulta calcula de forma dinámica los periodos (Pre, Durante y Post)
-- para cada una de las 55+ flotas de Argentina.
--
-- Lógica Aplicada:
--   1. Durante (Rollout): Todos los días válidos entre la fecha de inicio y fin de la flota.
--   2. Pre-rollout: Rango fijo del 26/03/2026 al 29/04/2026 (previo al inicio de cada flota).
--   3. Post-rollout: Rango fijo del 27/07/2026 al 31/08/2026 (posterior al fin de cada flota).
--   4. Exclusiones exactas: Se excluyen los partidos del Mundial (11/06 al 19/07, excepto 5 días
--      de descanso: 08/07, 12/07, 13/07, 16/07, 17/07) y el Día de la Hamburguesa (28/05/2026).
-- =====================================================================================

WITH rollout_calendar AS (
   -- 1. Calendario oficial de fechas de rollout de sobrepenalización de Pickup (PU) por flota.
   SELECT 'ar-buenos_aires' AS fleet_id, DATE('2026-05-10') AS start_date, DATE('2026-05-30') AS end_date UNION ALL
   SELECT 'ar-rosario', DATE('2026-05-15'), DATE('2026-06-05') UNION ALL
   SELECT 'ar-cordoba', DATE('2026-05-01'), DATE('2026-05-20') UNION ALL
   -- Flotas con rollout nacional por defecto (Mayo 10 a Mayo 30, 2026)
   SELECT 'ar-Azul', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-La_Plata', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-Zarate_Campana', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-bariloche', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-buenos_aires-norte', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-buenos_aires_norte_nueva', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-catamarca', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-corrientes_resistencia', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-formosa', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-junin', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-la_rioja', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-lujan', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-mendoza', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-olavarria', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-pinamar', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-rafaela', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-reconquista', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-resistencia', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-rio_cuarto', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-salta', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-san_juan', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-san_nicolas_de_los_arroyos', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-san_rafael', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-santiago_del_estero', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-tandil', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-tucuman', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-venado_tuerto', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-villa_maria', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-Viedma', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-bahia_blanca', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-buenos_aires_oeste', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-cipoletti', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-comodoro_rivadavia', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-concepcion', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-esperanza', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-gba_oeste', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-gba_sur', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-mar_del_plata', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-neuquen', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-parana', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-pergamino', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-posadas', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-puerto_madryn', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-saenz_pena', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-san_luis', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-san_salvador_de_jujuy', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-santa_fe', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-santa_rosa', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-santo_tome', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-trelew', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-ushuaia', DATE('2026-05-10'), DATE('2026-05-30') UNION ALL
   SELECT 'ar-villa_mercedes', DATE('2026-05-10'), DATE('2026-05-30')
),

all_days AS (
   -- 2. Universo de fechas para clasificar días laborables válidos (excluye distorsiones).
   SELECT 
     dt,
     NOT (
       dt = DATE('2026-05-28') -- Día de la Hamburguesa
       OR (
         dt BETWEEN DATE('2026-06-11') AND DATE('2026-07-19') -- Ventana Mundial de la FIFA
         AND dt NOT IN (DATE('2026-07-08'), DATE('2026-07-12'), DATE('2026-07-13'), DATE('2026-07-16'), DATE('2026-07-17')) -- Días de descanso
       )
     ) AS is_valid
   FROM UNNEST(GENERATE_DATE_ARRAY(DATE('2026-03-26'), DATE('2026-08-31'))) AS dt
),

fleet_dates_mapped AS (
   -- 3. Ensamble final de la matriz Fecha-Flota-Brazo con rangos de fechas fijos
   
   -- Durante
   SELECT c.fleet_id, ad.dt, 'Test' AS brazo_test
   FROM all_days ad
   INNER JOIN rollout_calendar c ON ad.dt BETWEEN c.start_date AND c.end_date
   WHERE ad.is_valid
   
   UNION ALL
   
   -- Pre-feature (Rango fijo estático del 26/03 al 29/04)
   SELECT c.fleet_id, ad.dt, 'Pre-feature' AS brazo_test
   FROM all_days ad
   CROSS JOIN rollout_calendar c
   WHERE ad.is_valid 
     AND ad.dt BETWEEN DATE('2026-03-26') AND DATE('2026-04-29')
     AND ad.dt < c.start_date
   
   UNION ALL
   
   -- Post-feature (Rango fijo excluyendo solapamiento)
   SELECT c.fleet_id, ad.dt, 'Post-feature' AS brazo_test
   FROM all_days ad
   CROSS JOIN rollout_calendar c
   WHERE ad.is_valid 
     AND ad.dt BETWEEN DATE('2026-07-27') AND DATE('2026-08-31')
     AND ad.dt > c.end_date
),

zdim_sp AS (
   -- 4. Dimensión de Zonas y Flotas para evitar contaminación geográfica
   SELECT
     zo.id AS zone_id,
     ANY_VALUE(zo.fleet_id) AS fleet_id
   FROM `peya-data-origins-pro.cl_hurrier.countries` c
   LEFT JOIN UNNEST(c.cities) ci
   LEFT JOIN UNNEST(ci.zones) zo
   WHERE c.country_code = 'ar' AND zo.id IS NOT NULL
   GROUP BY zo.id
),

rdds_sp AS (
   -- 5. Distancia Google ruteada (RDDS) para Pickup y Dropoff
   SELECT
     delivery_id,
     ANY_VALUE(stack_lead_id)             AS stack_lead_id,
     MAX(pickup_distance_google)          AS pu_g,
     MAX(dropoff_distance_google)         AS dof_g
   FROM `fulfillment-dwh-production.curated_data_shared.rider_payment_delivery_distance_service`
   WHERE created_date BETWEEN '2026-03-26' AND '2026-08-31'
     AND country_code = 'ar'
     AND region = 'Americas'
   GROUP BY delivery_id
),

bags_sp AS (
   -- 6. Ponderador de bolsas para prorratear correctamente DistPU en agrupados
   SELECT
     stack_lead_id AS lead,
     MAX(pu_g) AS lead_pu,
     COUNT(*) AS bagsize
   FROM rdds_sp
   WHERE stack_lead_id IS NOT NULL
   GROUP BY stack_lead_id
),

cpo_data_sp AS (
   -- 7. Datos de CPO (Costo por Orden)
   SELECT
     delivery_id,
     basic_cpo_lc                                   AS cpo_base,   
     basic_payment_per_km_pu_lc                     AS cpo_pu,     
     basic_payment_per_km_do_lc                     AS cpo_do,     
     basic_cpo_lc + CAST(scoring_cpo_lc AS FLOAT64) AS cpo_total  
   FROM `peya-datamarts-pro.dm_cpo.overall_cpo`
   WHERE created_date BETWEEN '2026-03-26' AND '2026-08-31'
     AND country_code = 'ar'
),

seamless_data_sp AS (
   -- 8. Tasa de Seamless Delivery
   SELECT
     platform_order_code_str AS oid,
     created_date_local AS dt,
     MAX(CAST(non_seamless_order AS INT64)) AS non_seamless
   FROM `peya-datamarts-pro.dm_fulfillment.non_seamless_delivery_order_level`
   WHERE created_date_local BETWEEN '2026-03-26' AND '2026-08-31'
     AND country_name = 'Argentina'
   GROUP BY oid, dt
),

raw_orders_sp AS (
   -- 9. Extracción optimizada de Fact Logistic Orders (PRIMARY DELIVERY ONLY)
   SELECT
     lo.platform_order_code,
     lo.created_date_local,
     lo.zone.zone_id,
     lo.city.city_name,
     lo.timings.zone_stats.mean_delay,
     lo.vendor.vertical_type,
     lo.is_order_late_10,
     d.delivery_id,
     d.is_stacked,
     d.timings.actual_delivery_time
   FROM `peya-bi-tools-pro.il_logistics.fact_logistic_orders` lo, UNNEST(lo.deliveries) d
   WHERE lo.created_date BETWEEN '2026-03-26' AND '2026-08-31'
     AND lo.created_date_local BETWEEN '2026-03-26' AND '2026-08-31'
     AND lo.country.country_id = 3
     AND d.is_primary
     AND lo.timings.zone_stats.mean_delay IS NOT NULL
     AND lo.vendor.vertical_type NOT IN ('courier','courier_business')
),

universe_sp AS (
   -- 10. Agrupamiento e identificación de verticales
   SELECT
     ro.platform_order_code,
     ro.created_date_local AS dt,
     z.fleet_id,
     ro.city_name,
     ro.mean_delay AS md,
     CASE 
       WHEN LOWER(ro.vertical_type) LIKE '%darkstore%' 
            OR LOWER(ro.vertical_type) LIKE '%dmart%' 
            OR LOWER(ro.vertical_type) LIKE '%peyamarket%' 
            OR LOWER(ro.vertical_type) LIKE '%market_peya%'
            THEN 'DMARTS'
       WHEN LOWER(ro.vertical_type) = 'restaurants' THEN 'RESTAURANTS'
       ELSE 'LOCAL STORES'
     END AS vertical,
     ro.delivery_id AS did,
     ro.is_stacked,
     ro.actual_delivery_time AS delivery_time_seconds,
     ro.is_order_late_10 AS ol10
   FROM raw_orders_sp ro
   INNER JOIN zdim_sp z ON z.zone_id = ro.zone_id
)

-- 11. Ensamble de Métricas consolidadas agrupadas por día y flota.
SELECT
   u.dt                                                                        AS fecha,
   u.fleet_id                                                                  AS fleet_id,
   ANY_VALUE(u.city_name)                                                      AS city_name,
   u.vertical                                                                  AS vertical,
   fdm.brazo_test                                                              AS brazo_test,
   CAST(FLOOR(u.md / 2) * 2 AS INT64)                                          AS mean_delay_zona_min,

   COUNT(*)                                                                    AS orders_count,
   ROUND(SUM(SAFE_DIVIDE(u.delivery_time_seconds, 60)), 2)                     AS delivery_time_sum,
   SUM(IF(CAST(u.ol10 AS STRING) IN ('1', 'true', 'TRUE'), 1, 0))              AS late_10_sum,
   SUM(IF(s.non_seamless = 0, 1, 0))                                           AS seamless_sum,
   SUM(IF(CAST(u.is_stacked AS STRING) IN ('1', 'true', 'TRUE'), 1, 0))        AS stacked_sum,

   ROUND(SUM(COALESCE(b.lead_pu / b.bagsize, rd.pu_g) / 1000), 3)              AS pickup_distance_sum,
   ROUND(SUM(rd.dof_g / 1000), 3)                                              AS dropoff_distance_sum,
   ROUND(SUM((COALESCE(b.lead_pu / b.bagsize, rd.pu_g) + COALESCE(rd.dof_g, 0)) / 1000), 3) AS total_distance_sum,

   ROUND(SUM(cp.cpo_base), 2)                                                  AS cpo_base_sum,
   ROUND(SUM(cp.cpo_pu), 2)                                                    AS cpo_dist_pu_sum,
   ROUND(SUM(cp.cpo_do), 2)                                                    AS cpo_dist_do_sum,
   ROUND(SUM(cp.cpo_total), 2)                                                 AS cpo_total_sum

FROM universe_sp u
INNER JOIN fleet_dates_mapped fdm ON fdm.fleet_id = u.fleet_id AND fdm.dt = u.dt
LEFT JOIN seamless_data_sp s  ON s.oid = u.platform_order_code AND s.dt = u.dt
LEFT JOIN rdds_sp           rd ON rd.delivery_id = u.did
LEFT JOIN bags_sp           b  ON b.lead        = rd.stack_lead_id
LEFT JOIN cpo_data_sp       cp ON cp.delivery_id = u.did
GROUP BY 1, 2, 4, 5, 6
ORDER BY
   fecha DESC,
   fleet_id;
