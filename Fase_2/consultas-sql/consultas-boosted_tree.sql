-- 1️⃣ CREAMOS UN DATASET OPTIMIZADO (si no existe)
-- Sustituye dereckproy2 por el nombre de tu schema si difiere.
CREATE SCHEMA IF NOT EXISTS `dereckproy2`;

-- 2️⃣ CREAMOS UNA TABLA OPTIMIZADA (PARTICIONADA Y CLUSTERIZADA)
CREATE OR REPLACE TABLE `dereckproy2.taxi_2022_opt`
PARTITION BY DATE(pickup_datetime)
CLUSTER BY payment_type, passenger_count AS
SELECT
  pickup_datetime,
  payment_type,
  fare_amount,
  total_amount,
  passenger_count,
  tip_amount
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE
  (payment_type IN (1,2))       -- Solo efectivo y tarjeta
  AND tip_amount IS NOT NULL
  AND tip_amount >= 0
  AND fare_amount > 0;


-- Creamos una vista con variables derivadas útiles
CREATE OR REPLACE VIEW `dereckproy2.v_features_for_model` AS
SELECT
  payment_type,
  CAST(payment_type AS STRING) AS payment_type_str,
  passenger_count,
  fare_amount,
  total_amount - tip_amount AS total_no_tip,  -- Evita fuga de datos
  tip_amount,                                -- variable objetivo
  EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour,
  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS pickup_dow,
  EXTRACT(MONTH FROM pickup_datetime) AS pickup_month,
  pickup_datetime
FROM `dereckproy2.taxi_2022_opt`
WHERE
  fare_amount > 0
  AND tip_amount >= 0
  AND passenger_count > 0;


-- Creamos una columna hash estable para dividir datos
CREATE OR REPLACE VIEW `dereckproy2.v_split` AS
SELECT *,
  MOD(ABS(FARM_FINGERPRINT(CAST(pickup_datetime AS STRING))), 10) AS split_key
FROM `dereckproy2.v_features_for_model`;

-- 80% entrenamiento
CREATE OR REPLACE VIEW `dereckproy2.v_train` AS
SELECT * FROM `dereckproy2.v_split` WHERE split_key < 8;

-- 20% prueba
CREATE OR REPLACE VIEW `dereckproy2.v_test` AS
SELECT * FROM `dereckproy2.v_split` WHERE split_key >= 8;


-- Modelo principal: BOOSTED TREE
CREATE OR REPLACE MODEL `dereckproy2.m_tip_btr`
OPTIONS(
  model_type = 'boosted_tree_regressor',
  input_label_cols = ['tip_amount'],
  max_iterations = 50,     -- número de árboles
  subsample = 0.8,         -- porcentaje de datos usados por iteración
  learn_rate = 0.3,        -- velocidad de aprendizaje
  data_split_method = 'NO_SPLIT'  -- usamos nuestra propia división
) AS
SELECT * EXCEPT(pickup_datetime, split_key)
FROM `dereckproy2.v_train`;



-- Información de iteraciones y pérdida
SELECT * FROM ML.TRAINING_INFO(MODEL `dereckproy2.m_tip_btr`);


-- Evaluamos el modelo con el conjunto de prueba
SELECT *
FROM ML.EVALUATE(
  MODEL `dereckproy2.m_tip_btr`,
  (
    SELECT * EXCEPT(pickup_datetime, split_key)
    FROM `dereckproy2.v_test`
  )
);


--Generar predicciones y guardar resultados
CREATE OR REPLACE TABLE `dereckproy2.pred_tip_btr_test` AS
SELECT
  p.predicted_tip_amount,
  f.tip_amount AS real_tip,
  f.pickup_datetime,
  f.pickup_hour,
  f.pickup_dow,
  f.pickup_month,
  f.fare_amount,
  f.passenger_count,
  f.payment_type_str,
  ABS(f.tip_amount - p.predicted_tip_amount) AS error_abs,
  SAFE_DIVIDE(ABS(f.tip_amount - p.predicted_tip_amount), NULLIF(f.tip_amount,0)) AS error_rel
FROM ML.PREDICT(
  MODEL `dereckproy2.m_tip_btr`,
  (SELECT * EXCEPT(pickup_datetime, split_key)
   FROM `dereckproy2.v_test`)
) AS p
JOIN `dereckproy2.v_test` AS f
USING (fare_amount, passenger_count, pickup_hour, pickup_dow, pickup_month, payment_type_str);


--Analizar el error por hora del día
CREATE OR REPLACE VIEW `dereckproy2.v_error_summary` AS
SELECT
  pickup_hour,
  ROUND(AVG(error_abs), 2) AS error_promedio,
  ROUND(AVG(error_rel)*100, 1) AS error_relativo_pct,
  COUNT(*) AS total_viajes
FROM `dereckproy2.pred_tip_btr_test`
GROUP BY pickup_hour
ORDER BY pickup_hour;


--probar otros hiperparámetros
CREATE OR REPLACE MODEL `dereckproy2.m_tip_btr_tuned`
OPTIONS(
  model_type = 'boosted_tree_regressor',
  input_label_cols = ['tip_amount'],
  max_iterations = 80,      -- Aumentamos iteraciones
  learn_rate = 0.25,        -- Velocidad de aprendizaje
  subsample = 0.9,          -- Porcentaje de datos por iteración
  data_split_method = 'NO_SPLIT'
) AS
SELECT * EXCEPT(pickup_datetime, split_key)
FROM `dereckproy2.v_train`;

--comparacion
SELECT 'base' AS modelo, * FROM ML.EVALUATE(MODEL `dereckproy2.m_tip_btr`)
UNION ALL
SELECT 'tuned', * FROM ML.EVALUATE(MODEL `dereckproy2.m_tip_btr_tuned`);
