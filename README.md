# Healthcare User Log Analysis
Using MySQL | By Hemant Choudhary

## Introduction:

A healthcare company is launching a new weight management program using a mobile application. The app tracks users' weight and other health measures to help them monitor their progress and achieve their weight loss goals. 

## Business Problem:

The company needs to gain insights from the initial user logs data collected through the app to:

1. **Understand user engagement:** Analyze the number of users and the frequency of weight entries to assess initial user engagement with the app.
2. **Identify data quality issues:** Investigate the presence of missing weight entries, potential duplicate records, and unrealistic weight values to ensure data quality for reliable analysis.
3. **Explore weight distribution:** Analyze the distribution of user weights within the app to understand the user base demographics and potential target groups for the program.
4. **Calculate initial weight statistics:** Compute descriptive statistics like mean, median, and standard deviation of user weight to establish a baseline for measuring program effectiveness over time.

By analyzing the user logs data using techniques demonstrated in this project, the healthcare company can gain valuable insights to address these business needs and optimize their weight management program for better user engagement and successful weight loss outcomes.

# 1. Exploratory Data Analysis

## 1.1 A look at the dataset

Let's take a look at the first 10 rows from the `health.user_logs` table.

```sql
SELECT *
FROM health.user_logs
LIMIT 10;
```

*Output:*
| id                                       | log_date                 | measure        | measure_value | systolic | diastolic |
|------------------------------------------|--------------------------|----------------|---------------|----------|-----------|
| fa28f948a740320ad56b81a24744c8b81df119fa | 2020-11-15T00:00:00.000Z | weight         | 46.03959      | null     | null      |
| 1a7366eef15512d8f38133e7ce9778bce5b4a21e | 2020-10-10T00:00:00.000Z | blood_glucose  | 97            | 0        | 0         |
| bd7eece38fb4ec71b3282d60080d296c4cf6ad5e | 2020-10-18T00:00:00.000Z | blood_glucose  | 120           | 0        | 0         |
| 0f7b13f3f0512e6546b8d2c0d56e564a2408536a | 2020-10-17T00:00:00.000Z | blood_glucose  | 232           | 0        | 0         |
| d14df0c8c1a5f172476b2a1b1f53cf23c6992027 | 2020-10-15T00:00:00.000Z | blood_pressure | 140           | 140      | 113       |
| 0f7b13f3f0512e6546b8d2c0d56e564a2408536a | 2020-10-21T00:00:00.000Z | blood_glucose  | 166           | 0        | 0         |
| 0f7b13f3f0512e6546b8d2c0d56e564a2408536a | 2020-10-22T00:00:00.000Z | blood_glucose  | 142           | 0        | 0         |
| 87be2f14a5550389cb2cba03b3329c54c993f7d2 | 2020-10-12T00:00:00.000Z | weight         | 129.060012817 | 0        | 0         |
| 0efe1f378aec122877e5f24f204ea70709b1f5f8 | 2020-10-07T00:00:00.000Z | blood_glucose  | 138           | 0        | 0         |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-10-04T00:00:00.000Z | blood_glucose  | 210           | null     | null      |

## 1.2 Total record count

Let's also take a look at the total record count.

```sql
SELECT 
  COUNT(*)
FROM health.user_logs;
```

*Output:*
| count |
|-------|
| 43891 |

## 1.3 Unique column count

We'll take a look at how many unique id's are present in the dataset. That'll give us a count of the total number of users.

```sql
SELECT COUNT(DISTINCT id)
FROM health.user_logs;
```

*Output:*
| count |
|-------|
| 554   |

## 1.4 Single column frequency counts

Let's take a look at the measure column and see frequency and the percentage count of each value across the table.

```sql
SELECT 
  measure,
  COUNT(*) AS frequency,
  ROUND(
    100 * COUNT(*) / (SELECT COUNT(*) FROM health.user_logs), 2
  ) AS percentage
FROM health.user_logs
GROUP BY measure
ORDER BY frequency DESC;
```

*Output:*
| measure        | frequency | percentage |
|----------------|-----------|------------|
| blood_glucose  | 38692     | 88.15      |
| weight         | 2782      | 6.34       |
| blood_pressure | 2417      | 5.51       |

Let's also see the frequency of unique id's that appear in the dataset and limit the output to just 5.

```sql
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
```

*Output:*
| id                                       | frequency | percentage |
|------------------------------------------|-----------|------------|
| 054250c692e07a9fa9e62e345231df4b54ff435d | 22325     | 50.86      |
| 0f7b13f3f0512e6546b8d2c0d56e564a2408536a | 1589      | 3.62       |
| ee653a96022cc3878e76d196b1667d95beca2db6 | 1235      | 2.81       |
| abc634a555bbba7d6d6584171fdfa206ebf6c9a0 | 1212      | 2.76       |
| 576fdb528e5004f733912fae3020e7d322dbc31a | 1018      | 2.32       |

## 1.5 Individual column distribution

Let's now take a look at the most frequent values across each column.

1. <u>Measure Value Column</u>

```sql
SELECT 
  measure_value,
  COUNT(*) AS frequency
FROM health.user_logs
GROUP BY measure_value
ORDER BY frequency DESC
LIMIT 10;
```

*Output:*
| measure_value | frequency |
|---------------|-----------|
| 0             | 572       |
| 401           | 433       |
| 117           | 390       |
| 118           | 346       |
| 123           | 342       |
| 122           | 331       |
| 126           | 326       |
| 120           | 323       |
| 128           | 319       |
| 115           | 319       |

2. <u>Systolic column</u>

```sql
SELECT 
  systolic,
  COUNT(*) AS frequency
FROM health.user_logs
GROUP BY systolic
ORDER BY frequency DESC
LIMIT 10;
```

*Output:*
| systolic | frequency |
|----------|-----------|
| null     | 26023     |
| 0        | 15451     |
| 120      | 71        |
| 123      | 70        |
| 128      | 66        |
| 127      | 64        |
| 130      | 60        |
| 119      | 60        |
| 135      | 57        |
| 124      | 55        |

Wow. So many null and zero values! We'll come back to this later.

3. <u>Diastolic column</u>

```sql
SELECT 
  diastolic,
  COUNT(*) AS frequency
FROM health.user_logs
GROUP BY diastolic
ORDER BY frequency DESC
LIMIT 10;
```

*Output:*
| diastolic | frequency |
|-----------|-----------|
| null      | 26023     |
| 0         | 15449     |
| 80        | 156       |
| 79        | 124       |
| 81        | 119       |
| 78        | 110       |
| 77        | 109       |
| 73        | 109       |
| 83        | 106       |
| 76        | 102       |

This is somewhat similar output if compared to systolic column.

## 1.6 Deep dive into the specific values

So there are many 0 values in the measure_value column and some large number of nulls in systolic, diastolic. Let's take a look to see if the measure_value = 0 only when there is a specific measure value. We can use the WHERE clause here.

```sql
SELECT 
  measure,
  COUNT(*) AS frequency
FROM health.user_logs
WHERE measure_value = 0
GROUP BY measure
ORDER BY frequency DESC;
```

*Output:*
| measure        | frequency |
|----------------|-----------|
| blood_pressure | 562       |
| blood_glucose  | 8         |
| weight         | 2         |

And,

```sql
SELECT 
  measure,
  COUNT(*) AS frequency,
  ROUND(
    100 * COUNT(*) / (SELECT COUNT(*) FROM health.user_logs), 2
  ) AS percentage
FROM health.user_logs
GROUP BY measure
ORDER BY frequency DESC;
```

*Output:*
| measure        | frequency | percentage |
|----------------|-----------|------------|
| blood_glucose  | 38692     | 88.15      |
| weight         | 2782      | 6.34       |
| blood_pressure | 2417      | 5.51       |

So, it looks like most of the time measure_value = 0 when measure is blood_pressure. Let's take a look what happens when measure_value=0 and measure = blood_pressure.

```sql
SELECT 
  measure,
  measure_value,
  systolic,
  diastolic
FROM health.user_logs
WHERE measure = 'blood_pressure'
AND measure_value = 0
LIMIT 10;
```

*Output:*
| measure        | measure_value | systolic | diastolic |
|----------------|---------------|----------|-----------|
| blood_pressure | 0             | 115      | 76        |
| blood_pressure | 0             | 115      | 76        |
| blood_pressure | 0             | 105      | 70        |
| blood_pressure | 0             | 136      | 87        |
| blood_pressure | 0             | 164      | 84        |
| blood_pressure | 0             | 190      | 94        |
| blood_pressure | 0             | 125      | 79        |
| blood_pressure | 0             | 136      | 84        |
| blood_pressure | 0             | 135      | 89        |
| blood_pressure | 0             | 138      | 85        |

It looks like whenever blood_pressure is measured, the systolic and diastolic columns are populated but the measure_value is blank. Let's see what happens when the measure is blood_pressure but measure_value!=0.

```sql
SELECT 
  measure,
  measure_value,
  systolic,
  diastolic
FROM health.user_logs
WHERE measure = 'blood_pressure'
AND measure_value is NOT NULL
LIMIT 10;
```

*Output:*
| measure        | measure_value | systolic | diastolic |
|----------------|---------------|----------|-----------|
| blood_pressure | 140           | 140      | 113       |
| blood_pressure | 114           | 114      | 80        |
| blood_pressure | 132           | 132      | 94        |
| blood_pressure | 105           | 105      | 68        |
| blood_pressure | 149           | 149      | 85        |
| blood_pressure | 156           | 156      | 88        |
| blood_pressure | 142           | 142      | 84        |
| blood_pressure | 131           | 131      | 71        |
| blood_pressure | 128           | 128      | 77        |
| blood_pressure | 114           | 114      | 76        |

So, it looks like whenever blood_pressure is measured, measure_value is populated with systolic and sometimes it is equal to 0.

Let's check the same for the null values of systolic and diastolic.

```sql
SELECT 
  measure,
  count(*)
FROM health.user_logs
WHERE systolic is NULL
GROUP BY measure
LIMIT 10;
```

*Output:*
| measure       | count |
|---------------|-------|
| weight        | 443   |
| blood_glucose | 25580 |

This confirms that systolic only has non-null values when ``measure='blood_pressure'``. Is it the same for the diastolic column, let's see.

```sql
SELECT 
  measure,
  count(*)
FROM health.user_logs
WHERE diastolic is NULL
GROUP BY measure
LIMIT 10;
```

*Output:*
| measure       | count |
|---------------|-------|
| weight        | 443   |
| blood_glucose | 25580 |

And, it's the same as systolic. Non-null values are only present when ``measure='blood_pressure'``.

# 2. Data Preparation and Cleaning

## 2.1 Checking for duplicate values

First, let's take a look at the total count of rows in the dataset.

```sql
SELECT 
  COUNT(*)
FROM health.user_logs;
```

*Output:*
| count |
|-------|
| 43891 |

Now, let's check for distinct number of values in the dataset. There are three different ways we could do that:

### 2.1.1 Subquery

A subquery is essentially a query within a query. Here we get an output from querying on the inner query.

```sql
SELECT COUNT(*)
FROM (
  SELECT DISTINCT *
  FROM health.user_logs
) AS subquery
;
```

*Output:*
| count |
|-------|
| 31004 |

### 2.1.2 Common Table Expression

```sql
WITH deduped_logs AS (
  SELECT DISTINCT *
  FROM health.user_logs
)
SELECT COUNT(*)
FROM deduped_logs;
```

*Output:*
| count |
|-------|
| 31004 |

### 2.1.3 Temporary Tables

A temporary table will help you minimize the number of time you'll have to use the DISTINCT command everytime you want to query from the table without any duplicate values.

But, before creating a temp table, you should run a drop table query to clear any previously created tables. This helps us create a clean table and if there's any table with the same name, it'll clear it.

Now, let's create the temporary table.

```sql
DROP TABLE IF EXISTS deduplicated_user_logs;
CREATE TEMPORARY TABLE deduplicated_user_logs AS
SELECT DISTINCT *
FROM health.user_logs;
```

*Output:*
None

Let's take a look at the newly created TEMP table with distinct values only.

```sql
SELECT * 
FROM deduplicated_user_logs
LIMIT 5;
```

*Output:*
| id                                       | log_date                 | measure        | measure_value | systolic | diastolic |
|------------------------------------------|--------------------------|----------------|---------------|----------|-----------|
| 576fdb528e5004f733912fae3020e7d322dbc31a | 2019-12-15T00:00:00.000Z | blood_pressure | 0             | 124      | 72        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-04-15T00:00:00.000Z | blood_glucose  | 267           | null     | null      |
| 8b130a2836a80239b4d1e3677302709cea70a911 | 2019-12-31T00:00:00.000Z | blood_glucose  | 109.799995    | null     | null      |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-05-07T00:00:00.000Z | blood_glucose  | 189           | null     | null      |
| 0f7b13f3f0512e6546b8d2c0d56e564a2408536a | 2020-08-18T00:00:00.000Z | weight         | 68.49244787   | 0        | 0         |

The total count of values in the table:

```sql
SELECT COUNT(*) 
FROM deduplicated_user_logs;
```

*Output:*
| count |
|-------|
| 31004 |

## 2.2 Comparing our output with original data

In our original table, there are **43,891** values whereas in the deduplicated table we got **31,004**.

That means, we definitely have some duplicate values in our dataset.

## 2.3 Identifying duplicate records

Let us take a look at the duplicate row values from dataset.

### 2.3.1 Group by count on all columns

Here, we use a group by clause on all the columns and count as our aggregate function. This will give us all the rows along their count i.e. the number of time they appear in the dataset. Let's limit the output to 10.

```sql
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
```

*Output:*

| id                                       | log_date                 | measure       | measure_value | systolic | diastolic | frequency |
|------------------------------------------|--------------------------|---------------|---------------|----------|-----------|-----------|
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-06T00:00:00.000Z | blood_glucose | 401           | null     | null      | 104       |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-05T00:00:00.000Z | blood_glucose | 401           | null     | null      | 77        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-04T00:00:00.000Z | blood_glucose | 401           | null     | null      | 72        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-07T00:00:00.000Z | blood_glucose | 401           | null     | null      | 70        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-09-30T00:00:00.000Z | blood_glucose | 401           | null     | null      | 39        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-09-29T00:00:00.000Z | blood_glucose | 401           | null     | null      | 24        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-10-02T00:00:00.000Z | blood_glucose | 401           | null     | null      | 18        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-10T00:00:00.000Z | blood_glucose | 140           | null     | null      | 12        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-11T00:00:00.000Z | blood_glucose | 220           | null     | null      | 12        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-04-15T00:00:00.000Z | blood_glucose | 236           | null     | null      | 12        |

### 2.3.2 Having Clause for Unique Duplicates

```sql
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
```

*Output:*

| id                                       | measure        | measure_value | systolic | diastolic |
|------------------------------------------|----------------|---------------|----------|-----------|
| 3bb42419c1d4a801a01ec9eb8cecae2806d450eb | blood_glucose  | 139           | 0        | 0         |
| ac240708637cc4ea3781e878e4bcdd827b9e5292 | blood_glucose  | 129           | null     | null      |
| 46d921f1111a1d1ad5dd6eb6e4d0533ab61907c9 | blood_glucose  | 192           | null     | null      |
| cc85b6fd19008f32a82562efed00cf22918d7bd4 | blood_glucose  | 105           | 0        | 0         |
| d696925de5e9297694ef32a1c9871f3629bec7e5 | blood_glucose  | 238           | 0        | 0         |
| 3dcab94d65fa303807557df09cf566d809e0b15f | blood_glucose  | 76            | null     | null      |
| 0efe1f378aec122877e5f24f204ea70709b1f5f8 | blood_glucose  | 130           | 0        | 0         |
| 24eb992fbddc32223595d1ad8f927002292063b0 | blood_glucose  | 138           | 0        | 0         |
| 0f7b13f3f0512e6546b8d2c0d56e564a2408536a | blood_pressure | 132           | 132      | 79        |
| ee653a96022cc3878e76d196b1667d95beca2db6 | blood_pressure | 111           | 111      | 67        |

### 2.3.3 Getting all the duplicate counts

```sql
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
```

*Output:*

| id                                       | log_date                 | measure       | measure_value | systolic | diastolic | frequency |
|------------------------------------------|--------------------------|---------------|---------------|----------|-----------|-----------|
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-06T00:00:00.000Z | blood_glucose | 401           | null     | null      | 104       |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-05T00:00:00.000Z | blood_glucose | 401           | null     | null      | 77        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-04T00:00:00.000Z | blood_glucose | 401           | null     | null      | 72        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-07T00:00:00.000Z | blood_glucose | 401           | null     | null      | 70        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-09-30T00:00:00.000Z | blood_glucose | 401           | null     | null      | 39        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-09-29T00:00:00.000Z | blood_glucose | 401           | null     | null      | 24        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-10-02T00:00:00.000Z | blood_glucose | 401           | null     | null      | 18        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-10T00:00:00.000Z | blood_glucose | 140           | null     | null      | 12        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2019-12-11T00:00:00.000Z | blood_glucose | 220           | null     | null      | 12        |
| 054250c692e07a9fa9e62e345231df4b54ff435d | 2020-04-15T00:00:00.000Z | blood_glucose | 236           | null     | null      | 12        |

## 2.4 Ignoring Duplicate Records

In this case study, the log date doesn't contain any timestamps. So, it could be that the patient logged on to the online portal and submitted their health measurements at different times throughout a day. Hence, we may just ignore the duplicate values here.

# 3. Statistical Analysis and Distribution Functions

## 3.1 Arithmetic Mean or Average

Let's take a look at the average of the ```median_value``` column.

```sql
SELECT
  AVG(measure_value)
FROM health.user_logs;
```

*Output:*

| avg                   |
|-----------------------|
| 1986.2288605267024675 |


Whoa! That's a huge number. Let's go further into this. Let's see our measures again.

```sql
SELECT
  measure,
  COUNT(*) AS counts
FROM health.user_logs
GROUP BY measure;
```

*Output:*

| measure        | counts |
|----------------|--------|
| blood_glucose  | 38692  |
| blood_pressure | 2417   |
| weight         | 2782   |

Also, let's see the average measure_value based grouped by the measure column.

```sql
SELECT
  measure,
  AVG(measure_value),
  COUNT(*) AS counts
FROM health.user_logs
GROUP BY measure
ORDER BY counts;
```

*Output:*

| measure        | avg                  | counts |
|----------------|----------------------|--------|
| blood_pressure | 95.4040815126905254  | 2417   |
| weight         | 28786.846657295953   | 2782   |
| blood_glucose  | 177.3485953624517730 | 38692  |

Something is wrong here. The weight average of a person is ```28786```. Let's comeback later to this.

## 3.2 Median & Mode

Let's also calculate the median & mode for the weight column and see why is this happening.

```sql
SELECT
  AVG(measure_value) as mean,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY measure_value) AS median,
  MODE() WITHIN GROUP (ORDER BY measure_value) AS mode
FROM health.user_logs
WHERE measure = 'weight';
```

*Output:*

| mean               | median       | mode        |
|--------------------|--------------|-------------|
| 28786.846657295953 | 75.976721975 | 68.49244787 |

Looks like there are outliers in the dataset within the measure_value column when ```measure='weights'```.

## 3.3 Spread of the Data

Let's see how the data is spread across the measure_value column and the measure is equal to weight. 

### 3.3.1 Min, Max, Range values

```sql
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
```

*Output:*

| min_value | max_value | range_value |
|-----------|-----------|-------------|
| 0         | 39642120  | 39642120    |

### 3.3.2 Variance & Standard Deviation

The variance and standard deviation will give us a more clear idea about the spread of data as compared to just min, max values.

```sql
SELECT
  VARIANCE(measure_value) AS var_value,
  STDDEV(measure_value) AS std_value
FROM health.user_logs
WHERE measure = 'weight';
```

*Output:*

| var_value                        | std_value                  |
|----------------------------------|----------------------------|
| 1129457862383.414293789530531301 | 1062759.550596189323085400 |

## 3.4 Statistical Summary

Let's query all the stats values again but this time let's round of the data by 2 decimals.

```sql
SELECT
  'weight' as measure,
  ROUND(MIN(measure_value), 2) AS min_value,
  ROUND(MAX(measure_value), 2) AS max_value,
  ROUND(AVG(measure_value), 2) AS mean_value,
  ROUND(
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY measure_value) AS NUMERIC),
    2
  ) AS median_value,
  ROUND(
    MODE() WITHIN GROUP (ORDER BY measure_value),
    2
  ) AS mode_value,
  ROUND(VARIANCE(measure_value), 2) AS var_value,
  ROUND(STDDEV(measure_value), 2) AS std_value
FROM health.user_logs
WHERE measure = 'weight';
```

*Output:*

| measure | min_value | max_value   | mean_value | median_value | mode_value | var_value        | std_value  |
|---------|-----------|-------------|------------|--------------|------------|------------------|------------|
| weight  | 0.00      | 39642120.00 | 28786.85   | 75.98        | 68.49      | 1129457862383.41 | 1062759.55 |

## 3.5 Cumulative Distribution Function

CDF takes up a value and returns the percentile in which the value belongs to. Let's query the CDF of all values in measure_value when ```measure='weight```. We'll limit the output to 10 rows.

```sql
SELECT
  measure_value,
  NTILE(100) OVER (ORDER BY measure_value) AS percentile
FROM health.user_logs
WHERE measure = 'weight'
ORDER BY percentile
LIMIT 10;
```

*Output:*

| measure_value | percentile |
|---------------|------------|
| 0             | 1          |
| 1.814368      | 1          |
| 2.26796       | 1          |
| 2.26796       | 1          |
| 8             | 1          |
| 10.432616     | 1          |
| 11.3398       | 1          |
| 12.700576     | 1          |
| 15.422128     | 1          |
| 0             | 1          |

Now, we can find out the floor and ceiling value (i.e. max and min value) within each bucket or percentile and also the total number of values present in that particular bucket. Ideally, since we are calculating 100 buckets each bucket should contain 1% of the total data.

```sql
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
```

*Output:*

| percentile | floor_value   | ceiling_value | percentile_count |
|------------|---------------|---------------|------------------|
| 1          | 0             | 29.029888     | 28               |
| 2          | 29.48348      | 32.0689544    | 28               |
| 3          | 32.205032     | 35.380177     | 28               |
| 4          | 35.380177     | 36.74095      | 28               |
| 5          | 36.74095      | 37.194546     | 28               |
| ...        |  ...          |   ...         |    ...           |
| 95         | 129.86485     | 130.542007446 | 27               |
| 96         | 130.54207     | 131.570999146 | 27               |
| 97         | 131.670013428 | 132.776       | 27               |
| 98         | 132.776000977 | 133.832000732 | 27               |
| 99         | 133.89095     | 136.531192    | 27               |
| 100        | 136.531192    | 39642120      | 27               |

If we look at the above output. Let's just take a look at 1st and 100th percentile.

| percentile | floor_value   | ceiling_value | percentile_count |
|------------|---------------|---------------|------------------|
| 1          | 0             | 29.029888     | 28               |
| 100        | 136.531192    | 39642120      | 27               |

The ceiling_value of 1st percentile is 29.02 i.e. 29kg maybe, and the floor_value of 100th percentile is 136kg but ceiling is 3964210 kg?? Sounds abnormal. Maybe there was an incorrect measurement input fro few of the patient logs from the 100th %tile. Let's dive further into the 100th %tile to investigate more on this.

```sql
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
```

*Output:*

| measure_value | row_number_order | rank_order | dense_rank_order |
|---------------|------------------|------------|------------------|
| 39642120      | 1                | 1          | 1                |
| 39642120      | 2                | 1          | 1                |
| 576484        | 3                | 3          | 2                |
| 200.487664    | 4                | 4          | 3                |
| 190.4         | 5                | 5          | 4                |
| 188.69427     | 6                | 6          | 5                |
| 186.8799      | 7                | 7          | 6                |
| 185.51913     | 8                | 8          | 7                |
| 175.086512    | 9                | 9          | 8                |
| 173.725736    | 10               | 10         | 9                |

## 3.6 Large Outliers

| measure_value | row_number_order | rank_order | dense_rank_order |
|---------------|------------------|------------|------------------|
| 39642120      | 1                | 1          | 1                |
| 39642120      | 2                | 1          | 1                |
| 576484        | 3                | 3          | 2                |
| 200.487664    | 4                | 4          | 3                |

Here, if we take a look at the top 4 values. We can see values like 39642120 kg, 39642120 kg, .., 200 kg which seems unreal for a person to have. Maybe 200 kg is fine but the others are definitely outliers and we should remove them.

## 3.7 Small Outliers

We shall also look for any outliers in the 1st %tile if there are any as they could also skew our analysis.

```sql
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
```

*Output:*

| measure_value | row_number_order | rank_order | dense_rank_order |
|---------------|------------------|------------|------------------|
| 0             | 1                | 1          | 1                |
| 0             | 2                | 1          | 1                |
| 1.814368      | 3                | 3          | 2                |
| 2.26796       | 4                | 4          | 3                |
| 2.26796       | 5                | 4          | 3                |
| 8             | 6                | 6          | 4                |
| 10.432616     | 7                | 7          | 5                |
| 11.3398       | 8                | 8          | 6                |
| 12.700576     | 9                | 9          | 7                |
| 15.422128     | 10               | 10         | 8                |

There are a few 0 values which also seems unreal for a person to have that measure as a weight. We shall remove that as well.

## 3.8 Removing Outlier

Here, we'll create a new temporary table and remove our outliers.

```sql
DROP TABLE IF EXISTS clean_weight_logs;
CREATE TEMP TABLE clean_weight_logs AS (
  SELECT *
  FROM health.user_logs
  WHERE measure = 'weight'
    AND measure_value > 0
    AND measure_value < 201
);
```

*Output:*

None

Now, let's run all the statistical analysis on this new temp dataset without the outliers.

```sql
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
```

*Output:*

| minimum_value | maximum_value | mean_value | median_value | mode_value | standard_deviation | variance_value |
|---------------|---------------|------------|--------------|------------|--------------------|----------------|
| 1.81          | 200.49        | 80.76      | 75.98        | 68.49      | 26.91              | 724.29         |

Now the stats look somewhat normal as they don't have any huge or odd values. Also, let's take a look at the Cumulative Distribution Function for our new weight dataset.

```sql
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
```

*Output:*

| percentile | floor_value | ceiling_value | percentile_counts |
|------------|-------------|---------------|-------------------|
| 1          | 1.814368    | 29.48348      | 28                |
| 2          | 29.48348    | 32.4771872    | 28                |
| 3          | 32.658623   | 35.380177     | 28                |
| 4          | 35.380177   | 36.74095      | 28                |
| 5          | 36.74095    | 37.194546     | 28                |
| ...        |  ...        |   ...         |    ...            |
| 95         | 129.77278   | 130.52802     | 27                |
| 96         | 130.5389    | 131.54168     | 27                |
| 97         | 131.54169   | 132.6599      | 27                |
| 98         | 132.736     | 133.765       | 27                |
| 99         | 133.80965   | 136.0776      | 27                |
| 100        | 136.0776    | 200.487664    | 27                |

## 3.9 Frequency Distribution

Let's finally also plot a histogram to see the distribution of values in a visual graph. We use the ```WIDTH_BUCKET``` function to break down into n number of buckets.

```sql
SELECT
  WIDTH_BUCKET(measure_value, 0, 200, 50) AS bucket,
  AVG(measure_value) AS measure_value,
  COUNT(*) AS frequency
FROM clean_weight_logs
GROUP BY bucket
ORDER BY bucket
LIMIT 10;
```

*Output:*

| bucket | measure_value       | frequency |
|--------|---------------------|-----------|
| 1      | 2.1167626666666667  | 3         |
| 3      | 9.9241386666666667  | 3         |
| 4      | 14.0613520000000000 | 2         |
| 5      | 18.1436800000000000 | 1         |
| 6      | 22.2260080000000000 | 2         |
| 7      | 26.6485300000000000 | 8         |
| 8      | 30.5550911625000000 | 32        |
| 9      | 34.4161344213953488 | 43        |
| 10     | 37.9527840350000000 | 120       |
| 11     | 41.5446259242424242 | 66        |

Looks like there are large number of patients with weight in between 60-80 kg/lb.
