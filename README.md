# 🛵 Rollout de Sobrepenalización en Pickup (PU) Distances - Argentina (2026)

Este repositorio contiene la consulta SQL optimizada y el panel de control interactivo de alta fidelidad para el análisis del impacto del experimento de **Sobrepenalización de Distancias en Pickup** para las flotas logísticas de **PedidosYa Argentina** durante el período de marzo a agosto de 2026.

El objetivo del proyecto es auditar de manera rigurosa la evolución de los tiempos de entrega, ruteo, costos (CPO) y calidad de servicio ante la implementación de la penalización de distancias excesivas de pickup (retiro).

---

## 📂 Contenido del Repositorio

1. **`Query_BigQuery_Distances_Test_Sobrepenalizacion.sql`**: Consulta consolidada de producción en Google Cloud BigQuery. Realiza la extracción histórica de órdenes logísticas, cruza con el Datamart de costos y fulfillment, segmenta por cohortes simétricas temporales y excluye distorsiones estacionales.
2. **`Reporte_Sobrepenalizacion_PU_Distances.html`**: Reporte congelado estático de alta fidelidad, auto-contenido y listo para producción. Integra de forma nativa un dataset de **87,527 registros reales** de BigQuery y presenta los KPIs clave bajo las guías oficiales de diseño visual de la marca **PedidosYa**.

---

## 📅 Metodología y Definición de Cohortes

Para garantizar comparaciones metodológicas simétricas libres de sesgo geográfico o estacional, se definieron tres brazos temporales de análisis:

*   **Pre-rollout (Pre-feature):** Período congelado y simétrico de control que abarca del **27/03/2026 al 30/04/2026**.
*   **Rollout (Test):** Ventana específica de duración del experimento según el calendario oficial del rollout de cada ciudad (flota).
*   **Post-rollout (Post-feature):** Período congelado y simétrico posterior al fin del experimento que abarca del **27/07/2026 al 31/08/2026**.

### 🚫 Criterios de Exclusión Global (FIFA & Burger Day)
Para evitar picos de demanda o anomalías operativas que distorsionen el análisis de ruteo, la lógica SQL y la visualización excluyen de forma estricta:
1.  **Día de la Hamburguesa (`2026-05-28`):** Anomalía logística nacional debido a picos de stacking y delay.
2.  **Copa del Mundo de la FIFA (`11/06/2026` al `19/07/2026`):** Exclusión total de los días con partidos mundialistas debido a la alteración estacional en los hábitos de consumo y la oferta de repartidores, **exceptuando los días oficiales de descanso FIFA** (`08/07`, `12/07`, `13/07`, `16/07`, `17/07`) los cuales se computan con normalidad.

---

## 🗄️ Detalle de la Query SQL (`Query_BigQuery_Distances_Test_Sobrepenalizacion.sql`)

La consulta extrae métricas ponderadas a nivel diario y por flota uniendo las siguientes fuentes de datos oficiales del dwh de PedidosYa:
*   `peya-bi-tools-pro.il_logistics.fact_logistic_orders` (órdenes y tiempos logísticos).
*   `peya-datamarts-pro.dm_cpo.overall_cpo` (costo detallado por orden).
*   `peya-datamarts-pro.dm_fulfillment.non_seamless_delivery_order_level` (flags de seamless y fricciones).

### 🍔 Lógica de Segmentación por Verticales:
Para evitar sesgos por el plural en las bases de datos de producción, se implementó una lógica de comodines parciales robustos (`LIKE %`):
```sql
CASE 
  WHEN LOWER(ro.vertical_type) LIKE '%darkstore%' 
       OR LOWER(ro.vertical_type) LIKE '%dmart%' 
       OR LOWER(ro.vertical_type) LIKE '%peyamarket%' 
       OR LOWER(ro.vertical_type) LIKE '%market_peya%'
       THEN 'DMARTS'
  WHEN LOWER(ro.vertical_type) = 'restaurants' THEN 'RESTAURANTS'
  ELSE 'LOCAL STORES'
END AS vertical
```

### 🥞 Lógica de Cálculo de Stacking y Seamless:
Para evitar la sobre-ponderación por volumen, la query extrae acumuladores absolutos que luego el frontend divide para calcular promedios ponderados matemáticamente exactos:
*   **Tasa de Stacking (%)** = `SUM(stacked_sum) / SUM(orders_count) * 100`
*   **Tasa de Seamless (%)** = `SUM(seamless_sum) / SUM(orders_count) * 100`

---

## 📊 Panel de Control (`Reporte_Sobrepenalizacion_PU_Distances.html`)

El dashboard es un desarrollo web responsivo que funciona **100% en local** (sin necesidad de servidores locales ni compiladores). Cuenta con las siguientes secciones y características de diseño de marca:

*   **Identidad PeYa:** Tipografía corporativa *Outfit*, paleta cromática de marca (Rojo PeYa `#EA044E`, Navy `#100423`, Positive/Fulfillment `#2DE1A0` e Info `#04ADDF`).
*   **Métricas Absolutas en Tarjetas:** 4 tarjetas superiores de KPIs (Delivery Time, Tasa de Stacking, Distancia PU, Seamless Delivery) que desglosan de forma simultánea promedios de Pre, RO y Post junto a sus respectivos deltas porcentuales.
*   **Filtro Global de Flota:** Ubicado en la cima, recalcula de forma unificada todo el set de datos del reporte en vivo para analizar comportamientos de flotas específicas (como Buenos Aires, Córdoba o Rosario).
*   **Gráficos de Mean Delay Despejados:**
    *   **Gráfico 1:** Evolución de Distancia de Pickup (km), Tasa de Stacking (%) y Share de Órdenes (%).
    *   **Gráfico 2:** Evolución de Delivery Time (min), Seamless Delivery (%) y Share de Órdenes (%).
    *   *Nota: Las curvas punteadas rojas del Share de Órdenes (%) se visualizan permanentemente en ambos gráficos para dar un contexto inmediato de volumen, independientemente de los filtros primarios seleccionados.*
*   **Matrices de Canal:** Tablas comparativas tridireccionales de calidad, tiempos, distancias y CPO desglosadas para el canal tradicional (*Food + Local Stores*) y el de tiendas propias (*DMarts*).
*   **Tabla de Variación por Flota:** Estructura simétrica de 7 columnas que muestra los deltas de tiempos y ruteo, coloreada al 100% de forma ejecutiva con formato estricto de **1 decimal**.

---

## 🚀 Cómo Ejecutar

Debido a su naturaleza auto-contenida (HTML5, Tailwind CSS, Chart.js y Lucide Icons cargados vía CDN), para visualizar y operar el reporte de manera local solo debes:

1.  Clonar este repositorio o descargar la carpeta `Sobrepenalizacion_PU_Distances`.
2.  Hacer doble clic sobre el archivo **`Reporte_Sobrepenalizacion_PU_Distances.html`** para abrirlo de forma nativa en cualquier navegador moderno (se recomienda Google Chrome).

---

*Desarrollado de forma unificada por el equipo de Experimentación & Analytics de PedidosYa Argentina.*
