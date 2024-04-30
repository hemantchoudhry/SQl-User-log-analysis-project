-- Create a new schema
CREATE DATABASE health;

-- Use the dbms_assignment1 database
USE health;

RENAME TABLE `user-logs` TO user_logs;

SELECT * 
FROM health.user_logs 
LIMIT 10;

SELECT 
  COUNT(*)
FROM health.user_logs;

SELECT COUNT(DISTINCT id)
FROM health.user_logs;

SELECT 
  measure,
  COUNT(*) AS frequency,
  ROUND(
    100 * COUNT(*) / (SELECT COUNT(*) FROM health.user_logs), 2
  ) AS percentage
FROM health.user_logs
GROUP BY measure
ORDER BY frequency DESC;


SELECT 
  id,
  COUNT(*) AS frequency,
  ROUND(
    100 * COUNT(*) / (SELECT COUNT(*) FROM health.user_logs), 2
  ) AS percentage
FROM health.user_logs
GROUP BY id
ORDER BY frequency DESC
LIMIT 5;

SELECT 
  measure_value,
  COUNT(*) AS frequency
FROM health.user_logs
GROUP BY measure_value
ORDER BY frequency DESC
LIMIT 10;

SELECT 
  systolic,
  COUNT(*) AS frequency
FROM health.user_logs
GROUP BY systolic
ORDER BY frequency DESC
LIMIT 10;

SELECT 
  diastolic,
  COUNT(*) AS frequency
FROM health.user_logs
GROUP BY diastolic
ORDER BY frequency DESC
LIMIT 10;

SELECT 
  measure,
  COUNT(*) AS frequency
FROM health.user_logs
WHERE measure_value = 0
GROUP BY measure
ORDER BY frequency DESC;

SELECT 
  measure,
  COUNT(*) AS frequency,
  ROUND(
    100 * COUNT(*) / (SELECT COUNT(*) FROM health.user_logs), 2
  ) AS percentage
FROM health.user_logs
GROUP BY measure
ORDER BY frequency DESC;

SELECT 
  measure,
  measure_value,
  systolic,
  diastolic
FROM health.user_logs
WHERE measure = 'blood_pressure'
AND measure_value = 0
LIMIT 10;

SELECT 
  measure,
  measure_value,
  systolic,
  diastolic
FROM health.user_logs
WHERE measure = 'blood_pressure'
AND measure_value is NOT NULL
LIMIT 10;

SELECT 
  measure,
  count(*)
FROM health.user_logs
WHERE systolic is NULL
GROUP BY measure
LIMIT 10;

SELECT 
  measure,
  count(*)
FROM health.user_logs
WHERE diastolic is NULL
GROUP BY measure
LIMIT 10;

SELECT 
  COUNT(*)
FROM health.user_logs;

SELECT COUNT(*)
FROM (
  SELECT DISTINCT *
  FROM health.user_logs
) AS subquery
;

WITH deduped_logs AS (
  SELECT DISTINCT *
  FROM health.user_logs
)
SELECT COUNT(*)
FROM deduped_logs;

DROP TABLE IF EXISTS deduplicated_user_logs;
CREATE TEMPORARY TABLE deduplicated_user_logs AS
SELECT DISTINCT *
FROM health.user_logs;

SELECT * 
FROM deduplicated_user_logs
LIMIT 5;

SELECT COUNT(*) 
FROM deduplicated_user_logs;

SELECT
  id,
  log_date,
  measure,
  measure_value,
  systolic,
  diastolic,
  COUNT(*) AS frequency
FROM health.user_logs
GROUP BY
  id,
  log_date,
  measure,
  measure_value,
  systolic,
  diastolic
ORDER BY frequency DESC
LIMIT 10;

DROP TABLE IF EXISTS duplicated_record_count;

CREATE TEMPORARY TABLE duplicated_record_count AS (
SELECT
  id,
  measure,
  measure_value,
  systolic,
  diastolic
FROM health.user_logs
GROUP BY
  id,
  measure,
  measure_value,
  systolic,
  diastolic
HAVING COUNT(*) > 1
);

SELECT * 
FROM duplicated_record_count
LIMIT 10;

WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT *
FROM groupby_counts
WHERE frequency > 1
ORDER BY frequency DESC
LIMIT 10;

SELECT
  AVG(measure_value)
FROM health.user_logs;

SELECT
  measure,
  COUNT(*) AS counts
FROM health.user_logs
GROUP BY measure;

SELECT
  measure,
  AVG(measure_value),
  COUNT(*) AS counts
FROM health.user_logs
GROUP BY measure
ORDER BY counts;

SELECT
  AVG(measure_value) AS mean,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY measure_value) AS median,
  (SELECT measure_value FROM health.user_logs WHERE measure = 'weight' GROUP BY measure_value ORDER BY COUNT(*) DESC LIMIT 1) AS mode
FROM health.user_logs
WHERE measure = 'weight';

WITH min_max_values AS (
  SELECT
    MIN(measure_value) AS min_value,
    MAX(measure_value) AS max_value
  FROM health.user_logs
  WHERE measure = 'weight'
)

SELECT
  min_value,
  max_value,
  max_value - min_value AS range_value
FROM min_max_values;

SELECT
  VARIANCE(measure_value) AS var_value,
  STDDEV(measure_value) AS std_value
FROM health.user_logs
WHERE measure = 'weight';

SELECT
  'weight' as measure,
  ROUND(MIN(measure_value), 2) AS min_value,
  ROUND(MAX(measure_value), 2) AS max_value,
  ROUND(AVG(measure_value), 2) AS mean_value,
  ROUND(
    IF(COUNT(*) % 2 = 1,
       (SELECT measure_value
        FROM health.user_logs
        WHERE measure = 'weight'
        ORDER BY measure_value
        LIMIT 1 OFFSET COUNT(*) / 2),
       (SELECT AVG(measure_value)
        FROM (SELECT measure_value
              FROM health.user_logs
              WHERE measure = 'weight'
              ORDER BY measure_value
              LIMIT COUNT(*) / 2, 2) AS subquery)
     ), 2
  ) AS median_value,
  (
    SELECT measure_value
    FROM health.user_logs
    WHERE measure = 'weight'
    GROUP BY measure_value
    ORDER BY COUNT(*) DESC
    LIMIT 1
  ) AS mode_value,
  ROUND(VARIANCE(measure_value), 2) AS var_value,
  ROUND(STDDEV(measure_value), 2) AS std_value
FROM health.user_logs
WHERE measure = 'weight';


SELECT
  measure_value,
  NTILE(100) OVER (ORDER BY measure_value) AS percentile
FROM health.user_logs
WHERE measure = 'weight'
ORDER BY percentile
LIMIT 10;

WITH percentile_values AS (
  SELECT
    measure_value,
    NTILE(100) OVER (ORDER BY measure_value) AS percentile
  FROM health.user_logs
  WHERE measure = 'weight'
  ORDER BY percentile
)

SELECT
  percentile,
  MIN(measure_value) AS floor_value,
  MAX(measure_value) AS ceiling_value,
  COUNT(*) AS percentile_count
FROM percentile_values
GROUP BY percentile
ORDER BY percentile;

WITH percentile_values AS (
  SELECT 
    measure_value,
    NTILE(100) OVER (
      ORDER BY measure_value
    ) AS percentile
  FROM health.user_logs
  WHERE measure='weight'
)

SELECT 
  measure_value,
  ROW_NUMBER() OVER (ORDER BY measure_value DESC) AS row_number_order,
  RANK() OVER (ORDER BY measure_value DESC) AS rank_order,
  DENSE_RANK() OVER (ORDER BY measure_value DESC) AS dense_rank_order
FROM percentile_values
WHERE percentile = 100
ORDER BY measure_value DESC
LIMIT 10;

WITH percentile_values AS (
  SELECT 
    measure_value,
    NTILE(100) OVER (
      ORDER BY measure_value
    ) AS percentile
  FROM health.user_logs
  WHERE measure='weight'
)

SELECT 
  measure_value,
  ROW_NUMBER() OVER (ORDER BY measure_value) AS row_number_order,
  RANK() OVER (ORDER BY measure_value) AS rank_order,
  DENSE_RANK() OVER (ORDER BY measure_value) AS dense_rank_order
FROM percentile_values
WHERE percentile = 1
ORDER BY measure_value
LIMIT 10;

DROP TABLE IF EXISTS clean_weight_logs;
CREATE TEMP TABLE clean_weight_logs AS (
  SELECT *
  FROM health.user_logs
  WHERE measure = 'weight'
    AND measure_value > 0
    AND measure_value < 201
);

SELECT
  ROUND(MIN(measure_value), 2) AS minimum_value,
  ROUND(MAX(measure_value), 2) AS maximum_value,
  ROUND(AVG(measure_value), 2) AS mean_value,
  ROUND(
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY measure_value) AS NUMERIC),
    2
  ) AS median_value,
  ROUND(
    MODE() WITHIN GROUP (ORDER BY measure_value),
    2
  ) AS mode_value,
  ROUND(STDDEV(measure_value), 2) AS standard_deviation,
  ROUND(VARIANCE(measure_value), 2) AS variance_value
FROM clean_weight_logs;

WITH percentile_values AS (
  SELECT
    measure_value,
    NTILE(100) OVER (
      ORDER BY
        measure_value
    ) AS percentile
  FROM clean_weight_logs
)
SELECT
  percentile,
  MIN(measure_value) AS floor_value,
  MAX(measure_value) AS ceiling_value,
  COUNT(*) AS percentile_counts
FROM percentile_values
GROUP BY percentile
ORDER BY percentile;

SELECT
  WIDTH_BUCKET(measure_value, 0, 200, 50) AS bucket,
  AVG(measure_value) AS measure_value,
  COUNT(*) AS frequency
FROM clean_weight_logs
GROUP BY bucket
ORDER BY bucket
LIMIT 10;