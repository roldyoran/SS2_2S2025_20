

-- MODELO VERSION 1: Modelo de regresión logística para predecir si la propina es mayor a 5 dólares
CREATE OR REPLACE MODEL `my_dataset.modelo_propinas_v1`
OPTIONS(
  model_type = 'logistic_reg',
  input_label_cols = ['tip_five_dolars'],
  data_split_method='RANDOM',
  data_split_eval_fraction=0.3,
  l1_reg = 0.2,
  l2_reg = 0.01,
  max_iterations = 10,
  ls_init_learn_rate = 0.2
) AS
SELECT
  IF(tip_amount > 5, 1, 0) AS tip_five_dolars,
  fare_amount,
  trip_distance,
  passenger_count,
  CAST(payment_type AS INT64) AS payment_type, 

  SAFE_DIVIDE(tip_amount, fare_amount) AS tip_to_fare_ratio,

  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS pickup_dayofweek,
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
    -- AND RAND() < 0.1
    AND EXTRACT(MONTH FROM pickup_datetime) BETWEEN 1 AND 6;


SELECT * 
FROM ML.EVALUATE(MODEL `my_dataset.modelo_propinas_v1`);


-- MODELO VERSION 2: Modelo de regresión logística para predecir si la propina es mayor a 5 dólares con ligeros cambios en los hiperparámetros
CREATE OR REPLACE MODEL `my_dataset.modelo_propinas_v2`
OPTIONS(
  model_type = 'logistic_reg',
  input_label_cols = ['tip_five_dolars'],
  data_split_method='RANDOM',
  data_split_eval_fraction=0.25,
  l1_reg = 0.2,
  l2_reg = 0.05,
  max_iterations = 20,
  ls_init_learn_rate = 0.2
) AS
SELECT
  IF(tip_amount > 5, 1, 0) AS tip_five_dolars,
  fare_amount,
  trip_distance,
  passenger_count,
  CAST(payment_type AS INT64) AS payment_type, 

  SAFE_DIVIDE(tip_amount, fare_amount) AS tip_to_fare_ratio,

  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS pickup_dayofweek,
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
    -- AND RAND() < 0.1
    AND EXTRACT(MONTH FROM pickup_datetime) BETWEEN 1 AND 6;




SELECT * 
FROM ML.EVALUATE(MODEL `my_dataset.modelo_propinas_v2`);