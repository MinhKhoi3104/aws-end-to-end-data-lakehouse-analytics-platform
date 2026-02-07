# Apache Airflow Orchestration

## 📋 General

`Orchestration` folder contains the whole config and code source for Apache Airflow to orchestrate data pipeline end-to-end from Bronze → Silver → Gold layer, and replicate data from Redshift to PostgreSQL.

## 🏗️  Architecture

### Components

1. **Apache Airflow 2.10.3**: Workflow orchestration engine
2. **Apache Spark 3.5.3**: Distributed data processing
3. **PostgreSQL 15**: Airflow metadata database
4. **Docker Compose**: Container orchestration

### Directory Structure

```
orchestration/
├── dags/                          # Airflow DAG definitions
│   ├── data_pipeline.py           # Main ETL pipeline DAG
│   └── redshift_to_postgre.py    # Redshift → PostgreSQL replication DAG
├── data_pipeline/                 # ETL jobs source code
│   ├── _01_config/                # Configuration files
│   │   ├── data_storage_config.py # S3, Redshift, PostgreSQL configs
│   │   └── jar_paths.py          # JAR file paths
│   ├── _02_utils/                 # Utility functions
│   │   ├── utils.py              # Spark session builders, S3/Redshift utils
│   │   └── surrogate_key_registry.py # Surrogate key management
│   └── _03_etl_jobs/             # ETL job implementations
│       ├── _0301_bronze/         # Bronze layer jobs
│       ├── _0302_silver/         # Silver layer jobs
│       └── _0303_gold/           # Gold layer jobs (dimensions & facts)
├── jars/                          # Required JAR dependencies
├── Dockerfile                     # Airflow container image
├── docker-compose.orchestration.yml # Docker Compose configuration
└── requirements.txt               # Python dependencies
```

## 🔄 Data Pipeline Flow

### DAG: `data_pipeline_daily`

Main pipeline performs ETL following the Medallion Architecture pattern:

```
Start → Bronze → Silver → Gold → Finish
```

#### 1. **Bronze Layer** (Raw Data Ingestion)
- **Task**: `030101_customer_search`
- **Function**: Reads raw data from S3 (`customer_search_log_data/{etl_date}`) and saves to Bronze layer

#### 2. **Silver Layer** (Cleaned & Normalized)
- **Task 1**: `030201_user_plans_map`
  - Creates mapping table for user plans
- **Task 2**: `030202_customer_search_keynormalize`
  - Normalizes and cleans customer search data
- **Dependency:** 
```
user_plans_map → customer_search_keynormalize
```

#### 3. **Gold Layer** (Data Warehouse)
Creates dimension tables and fact tables:

**Dimensions:**
- `030301_dim_date_overwrite`: Date dimension (overwrite mode)
- `030302_dim_category_append`: Category dimension
- `030303_dim_platform_append`: Platform dimension
- `030304_dim_network_append`: Network dimension
- `030305_dim_user_scd1`: User dimension (SCD Type 1)
- `030306_dim_subscription_append`: Subscription dimension

**Bridge & Fact:**
- `030307_bridge_user_plan`: Bridge table user-plan relationship
- `030308_fact_customer_search_append`: Fact table customer search events

**Dependencies:**
```
dim_category → dim_platform → dim_network → dim_subscription → dim_user → bridge_user_plan → fact_customer_search
```

![airflow_pipeline_daily](/image/airflow_pipeline_daily.png)

### DAG: `redshift_to_postgre`

Replication pipeline from Redshift Gold schema to PostgreSQL:

```
Start → Wait for Gold Finish → Extract from Redshift → Load to PostgreSQL → End
```

- **External Dependency**: Waits for `data_pipeline_daily.gold_finish` task to complete
- **Tables Replicated**:
  - `dim_date`
  - `dim_category`
  - `dim_platform`
  - `dim_network`
  - `dim_user`
  - `dim_subscription`
  - `bridge_user_plan`
  - `fact_customer_search`

![airflow_redshift_to_postgre](/image/airflow_redshift_to_postgre.png)
## ⚙️ Configuration

### 1. Environment Variables

Create `.env.aws` file in the `orchestration/` directory:

```bash
# AWS Credentials
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_DEFAULT_REGION=ap-southeast-1

# Redshift (if override needed)
REDSHIFT_HOST=your-redshift-host
REDSHIFT_DB=your-database
REDSHIFT_USER=admin
REDSHIFT_PASSWORD=your-password
```

### 2. Data Storage Config

File `data_pipeline/_01_config/data_storage_config.py` contains:

- **S3 Configuration**:
  - `S3_DATALAKE_PATH`: Base path for data lake
  - `S3_ICEBERG_PATH`: Iceberg warehouse path

- **Redshift Configuration**:
  - JDBC connection URL
  - Temp directory on S3
  - IAM role ARN

- **PostgreSQL Configuration**:
  - Host, port, database
  - Schema name (`dwh_user_search`)

### 3. Spark Configuration

Each task has its own Spark config:

```python
conf = {
    "spark.executor.instances": "1",
    "spark.executor.cores": "1",
    "spark.executor.memory": "1g",
    "spark.executor.memoryOverhead": "256m",
    "spark.driver.memory": "1g",
    "spark.driver.memoryOverhead": "256m",
    "spark.sql.shuffle.partitions": "4",
    "spark.default.parallelism": "4",
}
```

**Note**: `fact_customer_search` task has higher memory allocation (3g executor, 1g overhead).

## 🚀 Setup & Deployment

### Prerequisites

1. Docker & Docker Compose
2. AWS credentials configured (`.env.aws` file)
3. Network `aws_e2e_network` already created

### 1. Build Docker Image

```bash
cd _002_src/orchestration
docker-compose -f docker-compose.orchestration.yml build
```

### 2. Initialize Airflow Database

```bash
docker-compose -f docker-compose.orchestration.yml up airflow-init
```

### 3. Start Services

```bash
docker-compose -f docker-compose.orchestration.yml up -d
```

### 4. Access Airflow UI

- **URL**: http://localhost:8080
- **Username**: `admin`
- **Password**: `admin`

![airflow_ui](/image/airflow_ui.png)

### 5. Services & Ports

| Service | Container Name | Port | Description |
|---------|---------------|------|-------------|
| Airflow Webserver | `airflow_webserver` | 8080 | Airflow UI |
| Airflow Scheduler | `airflow_scheduler` | - | Task scheduler |
| PostgreSQL | `airflow_postgres` | 5433 | Metadata DB |
| Spark Master | `spark-master` | 7077, 8081 | Spark cluster master |
| Spark Worker | `spark-worker` | 8082 | Spark worker node |

## 📦 Dependencies

### Python Packages (`requirements.txt`)

- `apache-airflow-providers-apache-spark==4.10.0`
- `apache-airflow-providers-postgres==5.12.0`
- `apache-airflow-providers-amazon==8.28.0`
- `pyspark==3.5.3`
- `pandas==2.0.3`
- `pyarrow>=12.0.1`
- `psycopg2-binary==2.9.9`
- `boto3>=1.34.0`

### JAR Files (`jars/`)

Required JAR files:

1. **Redshift**:
   - `redshift-jdbc42-2.2.1.jar`
   - `spark-redshift_2.12-4.2.0.jar`

2. **S3/AWS**:
   - `hadoop-aws-3.3.4.jar`
   - `aws-java-sdk-bundle-1.12.262.jar`

3. **Iceberg**:
   - `iceberg-spark-runtime-3.5_2.12-1.4.3.jar`
   - `iceberg-aws-bundle-1.5.2.jar`

4. **PostgreSQL**:
   - `postgresql-42.7.3.jar`

5. **Spark**:
   - `spark-avro_2.12-3.5.1.jar`

## 🔧 Spark Session Types

### Bronze Session
- **Function**: `create_bronze_spark_session(app_name)`
- **JARs**: Hadoop AWS, AWS SDK
- **Use Case**: Read/write raw data from/to S3

### Silver Session
- **Function**: `create_silver_spark_session(app_name)`
- **JARs**: Hadoop AWS, AWS SDK
- **Use Case**: Transform and clean data

### Gold Session
- **Function**: `create_gold_spark_session(app_name)`
- **JARs**: All JARs (Hadoop, AWS, Iceberg, Redshift, PostgreSQL)
- **Features**:
  - Iceberg catalog integration (Glue Catalog)
  - Redshift JDBC connection
  - PostgreSQL JDBC connection
- **Use Case**: Create dimension/fact tables, write to Redshift/PostgreSQL

## 📊 DAG Parameters

### `data_pipeline_daily`

**Parameter**: `etl_date`
- **Type**: String (YYYYMMDD format)
- **Default**: `ds_nodash` (Airflow execution date)
- **Example**: `20250123`
- **Validation**: Pattern `^[0-9]{8}$`

**Usage in Airflow UI**:
1. Trigger DAG manually
2. Select "Trigger DAG w/ config"
3. Enter JSON:
```json
{
  "etl_date": "20220601"
}
```

### Logs

- **Location**: `/opt/airflow/logs` (inside container)
- **Volume**: `airflow_logs` (Docker volume)
- **Access**: 
  ```bash
  docker exec -it airflow_scheduler tail -f /opt/airflow/logs/dag_id/task_id/...
  ```

## 🛠️ Utility Functions

### S3 Utils
- `ensure_s3_prefix(spark, s3_path)`: Creates S3 prefix if it doesn't exist

### Redshift Utils
- `read_from_redshift(spark, table_name)`: Reads table from Redshift
- `write_to_redshift(df, table_name, mode)`: Writes DataFrame to Redshift
- `execute_sql_ddl(spark, sql_query)`: Executes DDL statements

### PostgreSQL Utils
- `read_from_postgres(spark, table_name, schema)`: Reads from PostgreSQL
- `write_to_postgres(df, table_name, mode, schema)`: Writes to PostgreSQL

### Surrogate Key Management
- `allocate_surrogate_keys(spark, df_new, entity_name, business_key_col, sk_col)`: 
  - Automatically allocates surrogate keys from registry table
  - Uses Iceberg table `iceberg.gold.sk_registry`

## 🔐 Security Notes

⚠️ **Important**: File `data_storage_config.py` contains sensitive information (passwords, connection strings). In production:
1. Use Airflow Connections/Variables
2. Use AWS Secrets Manager
3. Do not commit credentials to Git
4. Add to `.gitignore`
