# 🛵 Rollout de Sobrepenalización en Pickup (PU) Distances - Argentina (2026)

Este repositorio contiene la consulta SQL optimizada y el panel de control interactivo de alta fidelidad para el análisis del impacto del experimento de **Sobrepenalización de Distancias en Pickup** para las flotas logísticas de **PedidosYa Argentina** durante el período de marzo a agosto de 2026.

El objetivo del proyecto es auditar de manera rigurosa la evolución de los tiempos de entrega, ruteo, costos (CPO) y calidad de servicio ante la implementación de la penalización de distancias excesivas de pickup (retiro) de manera 100% visual y dinámica.

---

## 📂 Contenido del Repositorio

1. **`Query_BigQuery_Distances_Test_Sobrepenalizacion.sql`**: Consulta consolidada de producción en Google Cloud BigQuery. Realiza la extracción histórica de órdenes logísticas, cruza con el Datamart de costos y fulfillment, segmenta por cohortes simétricas temporales y excluye distorsiones estacionales.
2. **`Reporte_Sobrepenalizacion_PU_Distances.html`**: Reporte minimalista ejecutivo de alta fidelidad, auto-contenido y listo para producción. Integra de forma nativa un dataset de **87,527 registros reales** de BigQuery y presenta los KPIs clave bajo las guías oficiales de diseño visual de la marca **PedidosYa**.
3. **`Dashboard_Sobrepenalizacion_PU_Distances_cargar_sábana.html`**: Plantilla interactiva limpia (sin datos precargados) que funciona como cargador universal para arrastrar sábanas históricas CSV y generar los gráficos de forma dinámica de manera offline.

---

## 📅 Metodología y Definición de Cohortes

Para garantizar comparaciones metodológicas simétricas libres de sesgo geográfico o estacional, se definieron tres brazos temporales de análisis:

*   **Pre-rollout (Pre-feature):** Período congelado y simétrico de control que abarca del **26/03/2026 al 29/04/2026** (congelado metodológicamente).
*   **Rollout (Test):** Ventana específica de duración del experimento según el calendario oficial del rollout de cada ciudad o flota.
*   **Post-rollout (Post-feature):** Período congelado y simétrico posterior al fin del experimento que abarca del **27/07/2026 al 31/08/2026** (congelado metodológicamente).

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

## 📊 Panel de Control Exclusivo de Gráficos

El dashboard es un desarrollo web responsivo que funciona **100% en local** (sin necesidad de servidores locales ni compiladores). Está enfocado de forma absoluta y limpia en la sección de **4 gráficos dinámicos** por buckets de Mean Delay (Zona), eliminando ruidos y tablas para dar un informe visual de alto impacto ejecutivo:

*   **Identidad PeYa:** Tipografía corporativa *Outfit*, paleta cromática de marca (Rojo PeYa `#EA044E`, Navy `#100423`, Positive/Fulfillment `#2DE1A0`, Info `#04ADDF`, Comms `#F8EA46`).
*   **4 Gráficos de Mean Delay por Buckets:**
    1.  **Distancia PU por Bucket (km):** Evolución de pickup promedio por cohorte.
    2.  **Tasa de Stacking (%) por Bucket:** Evolución de agrupamiento real.
    3.  **Delivery Time por Bucket (min):** Evolución de tiempos totales de entrega.
    4.  **Seamless Delivery (%) por Bucket:** Calidad de servicio y fricciones.
*   **Interruptor Global de Share de Órdenes:** Ubicado en la cima de los filtros, permite con un solo checkbox activar/desactivar la visualización opcional de la curva punteada rosa del *Share de Órdenes (%)* en los 4 gráficos en simultáneo para un análisis de volumen despejado.
*   **Filtros Dinámicos Integrados:** Filtrado unificado de flotas específicas e identificación por unidad de negocio (*Restaurants & LS* vs *DMarts*).
*   **Botón de Exportación en Vivo:** Permite exportar instantáneamente el estado del panel, empaquetar la sábana de órdenes que tengas cargada en ese momento en la memoria y descargar un archivo HTML auto-contenido congelado para distribución.

---

## 🚀 Cómo Ejecutar

Debido a su naturaleza auto-contenida (HTML5, Tailwind CSS, Chart.js y Lucide Icons cargados vía CDN), para visualizar y operar el reporte de manera local solo debes:

1.  Hacer doble clic sobre el archivo **`Reporte_Sobrepenalizacion_PU_Distances.html`** para abrirlo en tu navegador.
2.  Si deseas cargar una sábana de órdenes histórica diferente o actualizar los datos, arrastra el archivo CSV de BigQuery al panel de carga (el sistema autodetectará delimitadores por `,` o `;` de forma automática).

---

*Desarrollado de forma unificada por el equipo de Experimentación & Analytics de PedidosYa Argentina.*
