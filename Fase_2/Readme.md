# 🚕 Fase 2 - Modelo de Predicción de Propinas

## 👥 Equipo - Pareja 20

| Carnet | Nombre |
|--------|--------|
| **202001144** | Edgar Rolando Alvarez Rodriguez |
| **202010825** | Dereck Gabriel Cuyan Catalan |

## 🎯 Objetivo del Modelo

> **Predecir si la propina será mayor a 5 dólares mediante una clasificación binaria**

### 📊 Especificaciones del Modelo

| Parámetro | Valor |
|-----------|--------|
| **Modelo** | `modelo_propinas_v1` |
| **Tipo** | Regresión logística |
| **Dataset** | `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022` |
| **Variables** | `fare_amount`, `trip_distance`, `passenger_count`, `payment_type`, `pickup_hour`, `pickup_dayofweek`, `tip_to_fare_ratio`, `fare_per_mile` |
| **Objetivo** | `tip_five_dolars` (1 si propina > $5) |
| **Data split** | 70/30 aleatorio (eval_fraction=0.3) |
| **Regularización** | L1 = 0.2, L2 = 0.01 |
| **Iteraciones** | 10 |
| **Tasa de aprendizaje** | 0.2 |
| **Métrica usada** | Log Loss, Accuracy |
| **Evidencia** | Resultados de ML.TRAINING_INFO y ML.EVALUATE |

### 📈 Resultados del Modelo

| Evaluación del Modelo V1 | Entrenamiento del Modelo V1 |
|----------------------|--------------------------|
| ![Evaluación Modelo V1](evidencias/202001144/2-evaluate_modelo_v1.png) | ![Entrenamiento Modelo V1](evidencias/202001144/2-training_modelo_v1.png) |


| Evaluación del Modelo V2 | Entrenamiento del Modelo V2 |
|----------------------|--------------------------|
| ![Evaluación Modelo V2](evidencias/202001144/2-evaluate_modelo_v2.png) | ![Entrenamiento Modelo V2](evidencias/202001144/2-training_modelo_v2.png) |
## 💾 Código SQL de los Modelos

### 🔧 Modelo Versión 1

<details>
<summary>📝 Ver código completo del Modelo V1</summary>

```sql
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

  EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour,
  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS pickup_dayofweek,

  SAFE_DIVIDE(tip_amount, fare_amount) AS tip_to_fare_ratio,  
  SAFE_DIVIDE(fare_amount, trip_distance) AS fare_per_mile,   

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
```
</details>

### 🔧 Modelo Versión 2

<details>
<summary>📝 Ver código completo del Modelo V2</summary>

```sql
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

  EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour,
  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS pickup_dayofweek,
  
  SAFE_DIVIDE(tip_amount, fare_amount) AS tip_to_fare_ratio,   -- J: Patrón relativo de propina
  SAFE_DIVIDE(fare_amount, trip_distance) AS fare_per_mile,     -- J: Tarifa por milla (valor)

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
```
</details>

## 🧠 Modelos Implementados y Justificación

> Se crearon **2 modelos de datos**, con sus respectivas variantes en los hiperparámetros

### 📋 **Modelo de Regresión Logística para Propinas > $5**

#### 🎯 **Diseño del Modelo**

Este modelo de regresión logística está **estratégicamente diseñado** porque utiliza variables predictivas altamente relevantes para predecir propinas generosas:

#### 🔍 **Variables Clave**
- **`fare_amount`**, **`trip_distance`** y **`tip_to_fare_ratio`** → Capturan directamente los patrones de gasto de los pasajeros
- **`pickup_hour`** y **`pickup_dayofweek`** → Identifican momentos con mayor probabilidad de propinas altas
- **Pagos con tarjeta únicamente** (tipos 1 y 2) → Asegura datos consistentes
- **Filtros aplicados** → Eliminan valores atípicos que podrían distorsionar las predicciones

#### ⚙️ **Configuración Técnica Robusta**

| Aspecto | Detalle | Beneficio |
|---------|---------|-----------|
| **Regularización** | L1 y L2 combinadas | Previene sobreajuste manteniendo interpretabilidad |
| **Iteraciones** | 10 iteraciones | Convergencia eficiente sin consumo excesivo de recursos |
| **Tasa de aprendizaje** | 0.2 | Optimización balanceada |
| **División de datos** | 70/30 | Evaluación confiable |
| **Viabilidad** | Computacionalmente eficiente | Comercialmente viable para producción |

#### ✅ **Justificación**
> El modelo aprovecha **relaciones comprobadas** en la industria de taxis: viajes más largos, tarifas más altas y ciertos horarios correlacionan con propinas generosas.


## 📊 Comparación de Métricas y Hallazgos Relevantes

### 🆚 **Modelo V1 vs Modelo V2**

| Modelo | Tipo | Métrica Principal | Valor | Métricas Secundarias | Interpretabilidad | Costo | Seleccionado |
|--------|------|------------------|-------|---------------------|------------------|-------|--------------|
| **Modelo V1** | Logistic Regression | ROC AUC | `0.969` | Accuracy = `0.940`, F1 = `0.755`, Log Loss = `0.174` | 🟢 Alta (fácil de explicar) | 🟢 Bajo | ✅ **SÍ** |
| **Modelo V2** | Logistic Regression | ROC AUC | `0.969` | Accuracy = `0.939`, F1 = `0.755`, Log Loss = `0.174` | 🟢 Alta (fácil de explicar) | 🟢 Bajo | ❌ NO |

---

### 🎯 **Conclusión del Análisis Comparativo**

Se compararon **dos versiones** del modelo de regresión logística (V1 y V2) que muestran un rendimiento prácticamente idéntico en todas las métricas evaluadas. 

#### 🏆 **¿Por qué se seleccionó el Modelo V1?**

El **Modelo V1** fue seleccionado por presentar ligeras ventajas en la mayoría de las métricas clave:

| Métrica | Modelo V1 | Modelo V2 | Diferencia |
|---------|-----------|-----------|------------|
| **ROC AUC** | `0.96935` | `0.96931` | `+0.00004` |
| **Accuracy** | `93.96%` | `93.95%` | `+0.01%` |
| **F1-Score** | `0.7546` | `0.7545` | `+0.0001` |
| **Log Loss** | `0.174` | `0.174` | `-0.000004` (V2 mejor) |

#### 🔍 **Análisis de Resultados**

> **Aunque las diferencias son mínimas** (inferiores al 0.01%), el **Modelo V1** demuestra una **consistencia ligeramente superior** en métricas críticas. 
> 
> Dado que ambos modelos comparten la misma arquitectura y costo computacional, se optó por la versión que muestra el **mejor balance global de rendimiento**.

---

### 🔗 Enlaces a Tableros

*Enlaces a los tableros de resultados y métricas...*