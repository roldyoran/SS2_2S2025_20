-- Crear tabla particionada por mes y clustering por ubicaciones Y tipo de pago
CREATE TABLE `my_dataset.nyc_taxi_optimized`
PARTITION BY DATE_TRUNC(pickup_datetime, MONTH)
CLUSTER BY pickup_location_id, dropoff_location_id, payment_type
AS
SELECT 
    *,
    DATE_TRUNC(pickup_datetime, MONTH) as partition_month
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE pickup_datetime BETWEEN '2022-01-01' AND '2022-12-31'
  AND dropoff_datetime BETWEEN '2022-01-01' AND '2022-12-31'
  LIMIT 1000;


-- KPI: 1
-- Viajes por mes en 2022
CREATE OR REPLACE TABLE `my_dataset.viajes_por_mes` AS
SELECT 
    EXTRACT(HOUR FROM pickup_datetime) as hora_dia,
    AVG(trip_distance) as distancia_promedio,
    COUNT(*) as total_viajes
FROM `my_dataset.nyc_taxi_optimized`
WHERE pickup_datetime BETWEEN '2022-01-01' AND '2022-12-31'
  AND trip_distance > 0
  AND trip_distance < 100
GROUP BY hora_dia
HAVING COUNT(*) > 1000  -- Filtra horas con pocos viajes
ORDER BY hora_dia
LIMIT 24;  -- Máximo 24 horas


-- KPI: 2
-- Análisis de distancia promedio por hora del día en 2022
CREATE OR REPLACE TABLE `my_dataset.distancia_promedio_hora` AS
SELECT 
    EXTRACT(HOUR FROM pickup_datetime) as hora_dia,
    AVG(trip_distance) as distancia_promedio,
    COUNT(*) as total_viajes
FROM `my_dataset.nyc_taxi_optimized`
WHERE pickup_datetime BETWEEN '2022-01-01' AND '2022-12-31'
  AND trip_distance > 0  -- Filtrar valores inválidos
  -- AND trip_distance < 100  -- Filtrar outliers
GROUP BY hora_dia
ORDER BY hora_dia
LIMIT 1000;


-- KPI: 3
-- Ingreso promedio total por tipo de pago en 2022
CREATE OR REPLACE TABLE `my_dataset.ingreso_total_tipo_pago` AS
SELECT 
    payment_type,
    CASE payment_type
        WHEN '1' THEN 'Credit card'
        WHEN '2' THEN 'Cash'
        WHEN '3' THEN 'No charge'
        WHEN '4' THEN 'Dispute'
        WHEN '5' THEN 'Unknown'
        WHEN '6' THEN 'Voided trip'
        ELSE 'Other'
    END as tipo_pago_desc,
    SUM(total_amount) as ingreso_total,
    COUNT(*) as total_viajes
FROM `my_dataset.nyc_taxi_optimized`
WHERE pickup_datetime BETWEEN '2022-01-01' AND '2022-12-31'
  AND total_amount > 0
GROUP BY payment_type
ORDER BY ingreso_total DESC
LIMIT 1000;


-- KPI: 4
-- propina promedio por tipo de pago en 2022
CREATE OR REPLACE TABLE `my_dataset.propina_promedio_tipo_pago` AS
SELECT 
    payment_type,
    CASE payment_type
        WHEN '1' THEN 'Credit card'
        WHEN '2' THEN 'Cash'
        WHEN '3' THEN 'No charge'
        WHEN '4' THEN 'Dispute'
        WHEN '5' THEN 'Unknown'
        WHEN '6' THEN 'Voided trip'
        ELSE 'Other'
    END as tipo_pago_desc,
    AVG(tip_amount) as propina_promedio,
    COUNT(*) as total_viajes_con_propina
FROM `my_dataset.nyc_taxi_optimized`
WHERE pickup_datetime BETWEEN '2022-01-01' AND '2022-12-31'
  AND tip_amount >= 0  -- Incluir 0 para ver diferencia entre métodos
GROUP BY payment_type
ORDER BY propina_promedio DESC
LIMIT 1000;


