# Proyecto Fase 1 – Seminario de Sistemas 2

## 1. Nombre del proyecto y del equipo
**Proyecto:** Análisis Exploratorio de Datos Masivos en BigQuery – NYC Taxi Trips 2022  
**Equipo:**  
- Dereck Gabriel Cuyan Catalán - 202010825 
- [Nombre Integrante 2]  
 

---

## 2. Dataset utilizado y descripción breve
**Dataset:** `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`  

Este dataset contiene más de 100 millones de registros de viajes de taxis amarillos en la ciudad de Nueva York durante el año 2022. Incluye información como:  
- Fecha y hora de inicio y fin del viaje.  
- Ubicaciones de origen y destino.  
- Distancia recorrida.  
- Tarifa, propina y monto total.  
- Método de pago.  
- Cantidad de pasajeros.  

---

## 3. Transformaciones y consultas realizadas
Se realizaron consultas SQL en BigQuery aplicando:  
- **Filtros:** eliminación de valores nulos, distancias = 0, tarifas inválidas.  
- **Funciones agregadas:** `AVG()`, `COUNT()`, `COUNTIF()`.  
- **Funciones temporales:** `EXTRACT()`, `TIMESTAMP_DIFF()`.  
- **Agrupaciones:** por día de la semana y zonas de pickup.  

Consultas principales:  
1. **Tarifa promedio por milla recorrida.**  
2. **Top 5 zonas de pickup con mayor cantidad de viajes.**  
3. **Duración promedio de viaje por día de la semana.**  
4. **Viajes con origen/destino en aeropuertos (JFK, LGA, Newark).**

---

## 4. Técnicas de optimización aplicadas
Para reducir el costo de procesamiento y mejorar el rendimiento:  
- **Particiones** por `DATE(pickup_datetime)`  
- **Clustering** por `pickup_location_id` y `dropoff_location_id`  

Se compararon los costos **antes y después de optimizar**, observando:  
- En el dataset original BigQuery escanea **toda la tabla**.  
- En las tablas optimizadas, al filtrar por fechas o ubicaciones, BigQuery solo escanea **las particiones y clusters necesarios**, reduciendo bytes procesados.  

📷 *Evidencias incluidas en la carpeta de capturas (detalles de ejecución antes y después).*

---

## 5. Patrones o hallazgos relevantes identificados
- La **tarifa promedio por milla** se mantiene relativamente estable, con variaciones mínimas según zona.  
- Las **zonas de pickup más concurridas** se concentran en áreas cercanas a Manhattan y aeropuertos.  
- La **duración promedio de los viajes** es mayor durante fines de semana, especialmente sábados por la noche.  
- Existe un alto volumen de **viajes con origen/destino en aeropuertos**, lo cual refleja la importancia del transporte hacia y desde JFK y LaGuardia.  

---

## 6. Enlace al informe visual
Se creó un tablero interactivo en **Google Looker Studio**, conectado directamente a las tablas optimizadas de BigQuery.  
Incluye 3 visualizaciones:  
- **Barras**: Top 5 zonas de pickup.  
- **Líneas**: Duración promedio por día de la semana.  
- **Tarjetas KPI**: Tarifa promedio por milla y viajes desde/hacia aeropuertos.  

👉 [Ver informe en Looker Studio](https://lookerstudio.google.com/s/k-qhwzILB_8)  

---
