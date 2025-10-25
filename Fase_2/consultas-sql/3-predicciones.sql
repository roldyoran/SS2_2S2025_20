CREATE OR REPLACE TABLE `my_dataset.predicciones_julio_diciembre_2022` AS
SELECT
  *,
  predicted_tip_five_dolars AS propina_predicha,
  (SELECT prob FROM UNNEST(predicted_tip_five_dolars_probs) WHERE label = 1) AS probabilidad_alta,
  -- Columna de comparación numérica: 1 si acertó, 0 si falló
  CASE 
    WHEN predicted_tip_five_dolars = tip_five_dolars_real THEN 1 
    ELSE 0 
  END AS prediccion_correcta,
  -- Columna en formato texto: indica si acertó o no
  CASE 
    WHEN predicted_tip_five_dolars = tip_five_dolars_real THEN 'ACIERTO' 
    ELSE 'ERROR' 
  END AS resultado_prediccion
FROM ML.PREDICT(
  MODEL `my_dataset.modelo_propinas_v1`,
  (
    SELECT
      fare_amount,
      trip_distance,
      passenger_count,
      CAST(payment_type AS INT64) AS payment_type,
      EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour,
      EXTRACT(DAYOFWEEK FROM pickup_datetime) AS pickup_dayofweek,
      SAFE_DIVIDE(tip_amount, fare_amount) AS tip_to_fare_ratio,
      SAFE_DIVIDE(fare_amount, trip_distance) AS fare_per_mile,
      -- Incluimos el valor real para poder comparar
      IF(tip_amount > 5, 1, 0) AS tip_five_dolars_real,
      tip_amount  -- También incluimos el monto real de propina por si quieres analizarlo
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
    WHERE
      payment_type IN ('1', '2')
      AND tip_amount IS NOT NULL
      AND tip_amount > 0
      AND fare_amount > 0
      AND fare_amount <= 500
      AND passenger_count > 0
      AND passenger_count <= 6
      AND trip_distance > 0 
      AND trip_distance < 1000
      AND EXTRACT(MONTH FROM pickup_datetime) BETWEEN 7 AND 12
      AND EXTRACT(YEAR FROM pickup_datetime) = 2022
      AND RAND() < 0.2  -- 0.2% de datos aleatorios
    LIMIT 1001
  )
);


SELECT 
  AVG(prediccion_correcta) AS precision_modelo,
  COUNT(*) AS total_predicciones,
  COUNTIF(resultado_prediccion = 'ACIERTO') AS aciertos,
  COUNTIF(resultado_prediccion = 'ERROR') AS errores
FROM `my_dataset.predicciones_julio_diciembre_2022`;