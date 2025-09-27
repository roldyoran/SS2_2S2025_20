--1. Tarifa promedio por milla recorrida
--a) Tabla derivada
CREATE OR REPLACE TABLE `dereckproyec.trips_fare_distance`
AS
SELECT
  fare_amount,
  trip_distance,
  pickup_datetime,
  pickup_location_id,
  dropoff_location_id
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE trip_distance > 0
  AND fare_amount > 0
LIMIT 10000;

--b) Optimizada con partición + clustering
CREATE OR REPLACE TABLE `dereckproyec.trips_fare_distance_opt`
PARTITION BY DATE(pickup_datetime)
CLUSTER BY pickup_location_id, dropoff_location_id AS
SELECT *
FROM `dereckproyec.trips_fare_distance`
LIMIT 10000;

--c) KPI
CREATE OR REPLACE TABLE `dereckproyec.kpi_fare_per_mile` AS
SELECT
  AVG(fare_amount / trip_distance) AS avg_fare_per_mile
FROM `dereckproyec.trips_fare_distance_opt`
LIMIT 10000;


--2. Top 5 zonas de pickup con mayor cantidad de viajes
--a) Consulta
SELECT
  pickup_location_id,
  COUNT(*) AS total_viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY pickup_location_id
ORDER BY total_viajes DESC
LIMIT 5;

--b) Optimizada
CREATE OR REPLACE TABLE `dereckproyec.trips_pickup_opt`
PARTITION BY DATE(pickup_datetime)
CLUSTER BY pickup_location_id AS
SELECT
  pickup_location_id,
  pickup_datetime
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;

-- Consulta sobre tabla optimizada
SELECT
  pickup_location_id,
  COUNT(*) AS total_viajes
FROM `dereckproyec.trips_pickup_opt`
GROUP BY pickup_location_id
ORDER BY total_viajes DESC
LIMIT 5;

--c) KPI
CREATE OR REPLACE TABLE `dereckproyec.kpi_top5_pickup` AS
SELECT
  pickup_location_id,
  COUNT(*) AS total_viajes
FROM `dereckproyec.trips_pickup_opt`
GROUP BY pickup_location_id
ORDER BY total_viajes DESC
LIMIT 5;


--3. Duración promedio de viaje por día de la semana
--a) Consulta
SELECT
  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS dia_semana,
  AVG(TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE)) AS duracion_promedio_min
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE dropoff_datetime > pickup_datetime
GROUP BY dia_semana
ORDER BY dia_semana;
LIMIT 1000;

--b) Optimizada
CREATE OR REPLACE TABLE `dereckproyec.trips_duration_opt`
PARTITION BY DATE(pickup_datetime)
CLUSTER BY pickup_location_id, dropoff_location_id AS
SELECT
  pickup_datetime,
  dropoff_datetime,
  pickup_location_id,
  dropoff_location_id
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE dropoff_datetime > pickup_datetime
LIMIT 1000;

-- Consulta sobre tabla optimizada
SELECT
  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS dia_semana,
  AVG(TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE)) AS duracion_promedio_min
FROM `dereckproyec.trips_duration_opt`
GROUP BY dia_semana
ORDER BY dia_semana
LIMIT 1000;

--c) KPI
CREATE OR REPLACE TABLE `dereckproyec.kpi_avg_duration_weekday` AS
SELECT
  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS day_of_week,
  AVG(TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE)) AS avg_duration_min
FROM `dereckproyec.trips_duration_opt`
GROUP BY day_of_week
ORDER BY day_of_week
LIMIT 1000;


--4. Viajes con origen/destino en aeropuertos
--(Aeropuertos más comunes: 132 = JFK, 138 = LGA, 1 y 140 = Newark/EWR)

--a) Consulta
SELECT
  COUNTIF(pickup_location_id IN ('132','138','1','140')) AS viajes_pickup_aeropuerto,
  COUNTIF(dropoff_location_id IN ('132','138','1','140')) AS viajes_dropoff_aeropuerto
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
LIMIT 1000;

--b) Consulta optimizada
CREATE OR REPLACE TABLE `dereckproyec.trips_airports_opt`
PARTITION BY DATE(pickup_datetime)
CLUSTER BY pickup_location_id, dropoff_location_id AS
SELECT
  pickup_datetime,
  pickup_location_id,
  dropoff_location_id
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE pickup_location_id IN ('132','138','1','140')
   OR dropoff_location_id IN ('132','138','1','140')
LIMIT 1000;

-- Consulta sobre tabla optimizada
SELECT
  COUNTIF(pickup_location_id IN ('132','138','1','140')) AS viajes_pickup_aeropuerto,
  COUNTIF(dropoff_location_id IN ('132','138','1','140')) AS viajes_dropoff_aeropuerto
FROM `dereckproyec.trips_airports_opt`
LIMIT 1000;


--c) KPI
CREATE OR REPLACE TABLE `dereckproyec.kpi_airport_trips` AS
SELECT
  COUNTIF(pickup_location_id IN (132,138,1,140)) AS viajes_pickup_aeropuerto,
  COUNTIF(dropoff_location_id IN (132,138,1,140)) AS viajes_dropoff_aeropuerto
FROM `dereckproyec.trips_airports_opt`
LIMIT 1000;




