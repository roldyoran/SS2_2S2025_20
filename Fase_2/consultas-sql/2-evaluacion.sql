-- TABLA COMPARATIVA DE MODELOS
CREATE OR REPLACE TABLE `my_dataset.comparativa_modelos` AS
WITH eval_v1 AS (
  SELECT 
    'Modelo V1' as modelo,
    precision,
    recall,
    accuracy,
    f1_score,
    log_loss,
    roc_auc
  FROM ML.EVALUATE(MODEL `my_dataset.modelo_propinas_v1`)
),
eval_v2 AS (
  SELECT 
    'Modelo V2' as modelo,
    precision,
    recall,
    accuracy,
    f1_score,
    log_loss,
    roc_auc
  FROM ML.EVALUATE(MODEL `my_dataset.modelo_propinas_v2`)
),
comparativa AS (
  SELECT
    'COMPARACIÓN' as tipo,
    CASE 
      WHEN v1.precision > v2.precision THEN 'V1 MAYOR'
      WHEN v1.precision < v2.precision THEN 'V2 MAYOR'
      ELSE 'IGUALES'
    END as precision_comparacion,
    CASE 
      WHEN v1.recall > v2.recall THEN 'V1 MAYOR'
      WHEN v1.recall < v2.recall THEN 'V2 MAYOR'
      ELSE 'IGUALES'
    END as recall_comparacion,
    CASE 
      WHEN v1.accuracy > v2.accuracy THEN 'V1 MAYOR'
      WHEN v1.accuracy < v2.accuracy THEN 'V2 MAYOR'
      ELSE 'IGUALES'
    END as accuracy_comparacion,
    CASE 
      WHEN v1.f1_score > v2.f1_score THEN 'V1 MAYOR'
      WHEN v1.f1_score < v2.f1_score THEN 'V2 MAYOR'
      ELSE 'IGUALES'
    END as f1_score_comparacion,
    -- Para log_loss, menor es mejor
    CASE 
      WHEN v1.log_loss < v2.log_loss THEN 'V1 MEJOR'
      WHEN v1.log_loss > v2.log_loss THEN 'V2 MEJOR'
      ELSE 'IGUALES'
    END as log_loss_comparacion,
    CASE 
      WHEN v1.roc_auc > v2.roc_auc THEN 'V1 MAYOR'
      WHEN v1.roc_auc < v2.roc_auc THEN 'V2 MAYOR'
      ELSE 'IGUALES'
    END as roc_auc_comparacion,
    ABS(v1.precision - v2.precision) as diff_precision,
    ABS(v1.recall - v2.recall) as diff_recall,
    ABS(v1.accuracy - v2.accuracy) as diff_accuracy,
    ABS(v1.f1_score - v2.f1_score) as diff_f1_score,
    ABS(v1.log_loss - v2.log_loss) as diff_log_loss,
    ABS(v1.roc_auc - v2.roc_auc) as diff_roc_auc
  FROM eval_v1 v1, eval_v2 v2
)

SELECT * FROM (
  SELECT 
    modelo,
    precision,
    recall,
    accuracy,
    f1_score,
    log_loss,
    roc_auc,
    CAST(NULL AS STRING) as precision_comparacion,
    CAST(NULL AS STRING) as recall_comparacion,
    CAST(NULL AS STRING) as accuracy_comparacion,
    CAST(NULL AS STRING) as f1_score_comparacion,
    CAST(NULL AS STRING) as log_loss_comparacion,
    CAST(NULL AS STRING) as roc_auc_comparacion,
    CAST(NULL AS FLOAT64) as diff_precision,
    CAST(NULL AS FLOAT64) as diff_recall,
    CAST(NULL AS FLOAT64) as diff_accuracy,
    CAST(NULL AS FLOAT64) as diff_f1_score,
    CAST(NULL AS FLOAT64) as diff_log_loss,
    CAST(NULL AS FLOAT64) as diff_roc_auc
  FROM eval_v1
  UNION ALL
  SELECT 
    modelo,
    precision,
    recall,
    accuracy,
    f1_score,
    log_loss,
    roc_auc,
    CAST(NULL AS STRING) as precision_comparacion,
    CAST(NULL AS STRING) as recall_comparacion,
    CAST(NULL AS STRING) as accuracy_comparacion,
    CAST(NULL AS STRING) as f1_score_comparacion,
    CAST(NULL AS STRING) as log_loss_comparacion,
    CAST(NULL AS STRING) as roc_auc_comparacion,
    CAST(NULL AS FLOAT64) as diff_precision,
    CAST(NULL AS FLOAT64) as diff_recall,
    CAST(NULL AS FLOAT64) as diff_accuracy,
    CAST(NULL AS FLOAT64) as diff_f1_score,
    CAST(NULL AS FLOAT64) as diff_log_loss,
    CAST(NULL AS FLOAT64) as diff_roc_auc
  FROM eval_v2
  UNION ALL
  SELECT 
    tipo as modelo,
    CAST(NULL AS FLOAT64) as precision,
    CAST(NULL AS FLOAT64) as recall,
    CAST(NULL AS FLOAT64) as accuracy,
    CAST(NULL AS FLOAT64) as f1_score,
    CAST(NULL AS FLOAT64) as log_loss,
    CAST(NULL AS FLOAT64) as roc_auc,
    precision_comparacion,
    recall_comparacion,
    accuracy_comparacion,
    f1_score_comparacion,
    log_loss_comparacion,
    roc_auc_comparacion,
    diff_precision,
    diff_recall,
    diff_accuracy,
    diff_f1_score,
    diff_log_loss,
    diff_roc_auc
  FROM comparativa
);


-- CONSULTA FINAL PARA VER TODOS LOS RESULTADOS
SELECT * FROM `my_dataset.comparativa_modelos`;


-- =======================
-- MEJOR MODELO: V1
-- =======================

-- RESULTADOS EN FORMATO JSON
-- [{
--   "modelo": "Modelo V2",
--   "precision": "0.864095131569965",
--   "recall": "0.66959856762090786",
--   "accuracy": "0.9394933945660745",
--   "f1_score": "0.754514232786765",
--   "log_loss": "0.17438796818640151",
--   "roc_auc": "0.96931068931068931",
--   "precision_comparacion": null,
--   "recall_comparacion": null,
--   "accuracy_comparacion": null,
--   "f1_score_comparacion": null,
--   "log_loss_comparacion": null,
--   "roc_auc_comparacion": null,
--   "diff_precision": null,
--   "diff_recall": null,
--   "diff_accuracy": null,
--   "diff_f1_score": null,
--   "diff_log_loss": null,
--   "diff_roc_auc": null
-- }, {
--   "modelo": "Modelo V1",
--   "precision": "0.86427698360196092",
--   "recall": "0.66959127843435406",
--   "accuracy": "0.93956228849191126",
--   "f1_score": "0.75457892270766991",
--   "log_loss": "0.17439176316842833",
--   "roc_auc": "0.96935264735264737",
--   "precision_comparacion": null,
--   "recall_comparacion": null,
--   "accuracy_comparacion": null,
--   "f1_score_comparacion": null,
--   "log_loss_comparacion": null,
--   "roc_auc_comparacion": null,
--   "diff_precision": null,
--   "diff_recall": null,
--   "diff_accuracy": null,
--   "diff_f1_score": null,
--   "diff_log_loss": null,
--   "diff_roc_auc": null
-- }, {
--   "modelo": "COMPARACIÓN",
--   "precision": null,
--   "recall": null,
--   "accuracy": null,
--   "f1_score": null,
--   "log_loss": null,
--   "roc_auc": null,
--   "precision_comparacion": "V1 MAYOR",
--   "recall_comparacion": "V2 MAYOR",
--   "accuracy_comparacion": "V1 MAYOR",
--   "f1_score_comparacion": "V1 MAYOR",
--   "log_loss_comparacion": "V2 MEJOR",
--   "roc_auc_comparacion": "V1 MAYOR",
--   "diff_precision": "0.0001818520319959438",
--   "diff_recall": "7.2891865537938472e-06",
--   "diff_accuracy": "6.889392583675491e-05",
--   "diff_f1_score": "6.4689920904914544e-05",
--   "diff_log_loss": "3.79498202682238e-06",
--   "diff_roc_auc": "4.1958041958056747e-05"
-- }]