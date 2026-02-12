# 🚀 AWS End-to-End Data Lakehouse Analytics Platform

<p align="center">
  <a href="https://github.com/MinhKhoi3104/aws-end-to-end-data-lakehouse-analytics-platform?tab=readme-ov-file#-quick-start-guide">
  <img src="https://img.shields.io/badge/project-🚀quick_start-blue?style=for-the-badge&logo=github" alt="Quick Start Guide"/>
</a>
  <a href="https://github.com/MinhKhoi3104/aws-end-to-end-data-lakehouse-analytics-platform/tree/main/_002_src">
      <img src="https://img.shields.io/badge/project-source_code-green?style=for-the-badge&logo=github" alt="Sublime's custom image"/>
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Apache%20Spark-3.5.3-orange?style=plastic&logo=apachespark&logoColor=white"/>
  <img src="https://img.shields.io/badge/Apache%20Airflow-2.10.3-017CEE?style=plastic&logo=apacheairflow&logoColor=white"/>
  <img src="https://img.shields.io/badge/Apache%20Iceberg-1.5.2-4B9CD3?style=plastic&logo=apache&logoColor=white"/>
  <img src="https://img.shields.io/badge/Amazon%20Redshift-Serverless-8C4FFF?style=plastic&logo=amazonredshift&logoColor=white"/>
  <img src="https://img.shields.io/badge/Amazon%20S3-Data%20Lake-569A31?style=plastic&logo=amazons3&logoColor=white"/>
  <img src="https://img.shields.io/badge/AWS%20Glue-Data%20Catalog-FF9900?style=plastic&logo=amazonaws&logoColor=white"/>
  <img src="https://img.shields.io/badge/PostgreSQL-15-4169E1?style=plastic&logo=postgresql&logoColor=white"/>
  <img src="https://img.shields.io/badge/dbt-Latest-FF694B?style=plastic&logo=dbt&logoColor=white"/>
  <img src="https://img.shields.io/badge/Apache%20Superset-Latest-20A7C9?style=plastic&logo=apache&logoColor=white"/>
  <img src="https://img.shields.io/badge/Grafana-Latest-F46800?style=plastic&logo=grafana&logoColor=white"/>
  <img src="https://img.shields.io/badge/Prometheus-2.38.0-E6522C?style=plastic&logo=prometheus&logoColor=white"/>
  <img src="https://img.shields.io/badge/Terraform-%3E%3D1.0-844FBA?style=plastic&logo=terraform&logoColor=white"/>
  <img src="https://img.shields.io/badge/Docker-Containerized-2496ED?style=plastic&logo=docker&logoColor=white"/>
</p>


This project implements an **AWS-based Data Lakehouse platform** for processing and analyzing large-scale user search and behavior data across **Internet TV, OTT, and online entertainment platforms**. The system follows a **Lakehouse architecture on Amazon S3** using **Apache Iceberg** as the table format, while data ingestion and transformation across the **Bronze, Silver, and Gold layers** are performed using **Apache Spark (PySpark)**. At the **Gold layer**, data is modeled into **fact and dimension tables using a star schema**, providing curated and analytics-ready datasets.

The Gold-layer datasets are then **replicated into PostgreSQL**, which serves as the **analytical serving layer** for downstream consumption. Within PostgreSQL, **dbt** is used to apply business transformations, build **datamarts**, and define analytical metrics in a structured and version-controlled manner. These datamarts are subsequently consumed by **BI and visualization tools (Apache Superset)**, enabling efficient OLAP-style analysis and reporting. The data pipeline is orchestrated using **Apache Airflow**, with infrastructure provisioned via **Terraform (Infrastructure as Code)** on AWS to ensure scalable, reproducible environments, and system observability supported by **Grafana and Prometheus**.

![e2e_project_overview](/image/e2e_project_overview.png)
<p align="center">
  <em>End-to-End Project Overview</em>
</p>


## 📋 Table of Contents
- [📁 Project Structure](#-project-structure)
- [📚 Dataset](#-dataset)
  - [Customer search data log](#customer-search-data-log)
  - [Crawled Movie Dataset](#crawled-movie-dataset)
- [🌐 Architecture Overview](#-architecture-overview)
  - [1. AWS Configuration (Infrastructure as Code - Terraform)](#1-aws-configuration-infrastructure-as-code---terraform)
  - [2. Distributed Batch Processing](#2-distributed-batch-processing)
  - [3. Monitoring & Observability](#3-monitoring--observability)
  - [4. Datamart for business analytics and reporting](#4-datamart-for-business-analytics-and-reporting)
  - [5. Business Intelligence & Visualization](#5-business-intelligence--visualization)
- [🚀 Quick Start Guide](#-quick-start-guide)
  - [Step 1: Infrastructure Setup with Terraform](#step-1-infrastructure-setup-with-terraform)
  - [Step 2: Create Docker Network](#step-2-create-docker-network)
  - [Step 3: Start PostgreSQL and Monitoring Services](#step-3-start-postgresql-and-monitoring-services)
  - [Step 4: Configure Airflow Environment](#step-4-configure-airflow-environment)
  - [Step 5: Build and Start Airflow](#step-5-build-and-start-airflow)
  - [Step 6: Import Grafana Dashboards](#step-6-import-grafana-dashboards)
  - [Step 7: Run Data Pipeline](#step-7-run-data-pipeline)
  - [Step 8: Replicate Data to PostgreSQL](#step-8-replicate-data-to-postgresql)
  - [Step 9: Build Datamart with dbt](#step-9-build-datamart-with-dbt)
  - [Step 10: Business Intelligence & Visualization by Apache Superset](#step-10-business-intelligence--visualization-by-apache-superset)
- [🔧 Key Technologies](#-key-technologies)
- [📃 License](#-license)

## 📁 Project Structure

```
aws-end-to-end-data-lakehouse-analytics-platform/
├── _000_data/                    # Sample data files
│   ├── crawl_data/               # Crawled reference data
│   └── customer_search_log_data/ # Raw customer search logs
│
├── _001_iac/                     # Infrastructure as Code
│   └── terraform/
│       ├── bootstrap/            # Terraform state bucket
│       ├── s3/                   # S3 data lake buckets
│       └── redshift/            # Redshift Serverless
│
├── _002_src/                     # Source code
│   ├── build_datamart/          # dbt project
│   │   └── dbt_customer_behaviour_analytics_dmt/
|   ├── business_intelligence/   # Visualization
│   ├── crawl_web_data/          # Web scraping scripts
│   ├── monitoring/              # Grafana & Prometheus configs
│   │   ├── config/
│   │   └── grafana/
│   └── orchestration/           # Airflow DAGs and ETL jobs
│       ├── dags/
│       ├── data_pipeline/
│       ├── jars/
│       ├── docker-compose.orchestration.yml
│       └── Dockerfile
│
├── _003_test/                    # Test utilities
│   ├── config/
|   ├── processing_layer/
│   │   ├── bronze/
│   │   ├── silver/
│   │   └── gold/
|   ├── utils/
|   ├── spark_connect_redshift.py
│   └── spark_connect_s3.py
│
├── _004_docs/                    # Documentation
|
├── docker/
|
├── image/                    
│
├── docker-compose.dmt.yml        # PostgreSQL & pgAdmin
├── docker-compose.grafana.yml   # Grafana & Prometheus
├── docker-compose.superset.yml   # Superset
├── LICENSE
└── README.md                     # This file
```

---

## 📚 Dataset
### Customer search data log
The dataset used in this project consists of customer search activity logs collected from an online entertainment platform that is accessible across multiple device types, including desktop, mobile, and smart TV devices.
The data covers the period from 2022-06-01 to 2022-06-03.

This dataset captures the search behavior history of users during their interaction with the platform, providing detailed information about search events, user context, device characteristics, and network attributes. The structure and semantic meaning of the dataset are described as follows:

| Field          | Description                                                                  |
| -------------- | ---------------------------------------------------------------------------- |
| event_time     | Unique identifier for each logged event                                      |
| datetime       | Timestamp indicating when the event occurred                                 |
| user_id        | User identifier (may be null for unauthenticated or guest users)             |
| keyword        | Search keyword entered by the user                                           |
| category       | Event category (e.g., enter, quit), representing session-related states      |
| proxy_isp      | Internet service provider used by the user (FPT, VNPT, Viettel, SPT, other)  |
| platform       | Device type or operating system (e.g., Android, iOS, SmartTV-Android)        |
| networkType    | Network connection type (e.g., WiFi, WWAN, Ethernet, 3G)                     |
| action         | Primary user action (search)                                                 |
| userPlansMap   | List of active subscription plans associated with the user                   |

![customer_search_log_data](/image/customer_search_log_data.png)
<p align="center">
  <em>Customer Search Log Data Sample</em>
</p>

### Crawled Movie Dataset
The dataset is crawled from an online movie streaming website and is used as a reference dataset for normalizing customer search queries by applying Machine Learning–based text normalization and matching techniques.

The goal of this dataset is to standardize noisy or misspelled user search inputs into their correct canonical movie titles.
For example, two users may search for the same movie Doraemon using slightly different misspellings:

- user_1 searches for "doramon" (missing the letter e)

- user_2 searches for "doremon" (missing the letter a)

By applying ML-based similarity matching and normalization algorithms, both search queries are mapped to the correct canonical movie title: "Doraemon".
This process improves search accuracy, user experience, and downstream analytical consistency.

The structure of the crawled movie dataset is as follows:

| Field          | Description                                                          |
| -------------- | -------------------------------------------------------------------- |
| _id            | Unique identifier of the movie                                       |
| title          | Display title shown to users (Vietnamese)                            |
| slug           | URL-friendly, SEO-optimized identifier derived from the movie title  |
| original_title | Original title of the movie in its production language               |
| release_date   | Official release or premiere date                                    |
| status         | Movie release status                                                 |
| quality        | Highest available video quality                                      |
| rating         | Audience age rating classification                                   |
| runtime        | Duration per episode or total runtime of the movie                   |
| overview       | Short synopsis or summary of the movie content                       |
| origin_country | Country of origin or production                                      |
| genres         | Movie genres                                                         |

![crawled_data](/image/crawled_data.png)
<p align="center">
  <em>Crawled Data Sample</em>
</p>

---

## 🌐 Architecture Overview
### 1. AWS Configuration (Infrastructure as Code - Terraform)

This project uses **Terraform** as an **Infrastructure as Code (IaC)** tool to define, provision, and manage cloud infrastructure and AWS resources—such as **Amazon S3** and **Amazon Redshift**—in a consistent, version-controlled, and fully reproducible manner.

Terraform enables automated infrastructure provisioning, ensures environment consistency across deployments, and supports infrastructure changes through declarative configuration.

1. [🔨 Infrastructure Code – Configure AWS Architecture using Terraform](/_001_iac/terraform/)

This section contains the Terraform codebase that defines the AWS infrastructure architecture and resource configurations used in this project.

2. [📃 Documents - Terraform Documentation](/_004_docs/README-terraform.md)

This document provides detailed explanations of the Terraform project structure, resource definitions, and configuration strategies applied in this implementation.


Directory Structure:

```
_001_iac/terraform/
├── bootstrap/          # First module to deploy - creates the S3 bucket used to store Terraform state (backend)
├── s3/                # Module creates S3 data lake buckets
└── redshift/          # Module creates Redshift Serverless infrastructure
```

### 2. Distributed Batch Processing
Data Flow:

```
Raw Data (S3)
    ↓
Bronze Layer (S3 Parquet)
    ↓
Silver Layer (S3 Parquet)
    ↓
Gold Layer (Redshift + Iceberg)
    ↓
PostgreSQL (Replication)
    ↓
dbt Datamart (PostgreSQL)
    ↓
BI Tools (Superset)
```

This project implements a robust distributed batch processing architecture, leveraging PySpark as the core computation engine and Apache Airflow for workflow orchestration.
In addition, Apache Iceberg is used as the table format on Amazon S3, providing enterprise-grade capabilities such as ACID transactions, time travel, schema evolution, and partition evolution, ensuring reliable, scalable, and maintainable datasets.

The core components are organized as follows:


1. [🔨 Code – Data Pipeline (OLTP -> Data Lakehouse & Data Warehouse)](/_002_src/orchestration/data_pipeline/)

2. [📃 Documents - Data Lakehouse & Warehouse Architecture Documentation](/_004_docs/README-data-lakehouse-&-warehouse-architecture.md)

3. [📃 Documents - Apache Iceberg Documentation](/_004_docs/README-iceberg.md)

Daily batch data is processed using PySpark following the Medallion Architecture, where data flows sequentially through three layers: Bronze, Silver, and Gold. This layered processing model ensures data quality, consistency, scalability, and end-to-end data lineage across the entire pipeline. Raw data is first ingested into the Bronze layer, cleansed and enriched in the Silver layer, and finally curated in the Gold layer for analytical consumption.

At the Gold layer, datasets are modeled using a star schema with fact and dimension tables, enabling the creation of subject-oriented analytical datasets that efficiently support OLAP workloads and BI reporting. Data at this layer is stored on Amazon S3 using Apache Iceberg as the table format, providing enterprise-grade capabilities such as ACID transactions, time travel, schema evolution, and partition evolution, ensuring reliable and maintainable datasets over time.

<p align="center">
  <img src="/image/Medallion_Architect.png" alt="Medallion Architect" />
</p>

![aws_lakehouse_architecture](/image/aws_lakehouse_architecture.png)
<p align="center">
  <em>AWS Data Lakehouse Architecture</em>
</p>

4. [🔨 Code – Apache Airflow Docker Compose](/_002_src/orchestration/docker-compose.orchestration.yml)
5. [🔨 Code – Scheduling based on Airflow (DAGs)](/_002_src/orchestration/dags/)
6. [📃 Documents - Airflow Documentation](/_004_docs/README-airflow.md)

The entire batch processing workflow is fully automated and orchestrated using Apache Airflow. Airflow DAGs are scheduled to run daily at 1:00 AM, coordinating all stages of the data pipeline—from source data ingestion and transformation across Medallion layers to data modeling and publishing. The workflow includes a primary DAG (`data_pipeline_daily`) responsible for executing daily PySpark jobs and a downstream DAG (`redshift_to_postgre`) that replicates curated Gold-layer data into PostgreSQL, where it is further used for datamart construction, analytics, and BI visualization.

Directory Structure:

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

### 3. Monitoring & Observability
To ensure system observability and operational scalability, the project integrates Grafana and Prometheus for real-time monitoring of Airflow clusters and PostgreSQL performance, supporting performance tuning and capacity planning.

1. [🔨 Code – Grafana and Prometheus Docker Compose](/docker-compose.grafana.yml)
2. [🔨 Dashboard – Grafana Airflow Cluster and Postgres Dashboards](/_002_src/monitoring/grafana/)
3. [📃 Documents - Grafana Documentation](/_004_docs/README-grafana.md)

![grafana_home](/image/grafana_home.png)

### 4. Datamart for business analytics and reporting
The datamart is built from Gold-layer data to support reporting and user behavior analysis on the platform.

1. [🔨 Code – Datamart PostgreSQL Docker Compose](/docker-compose.dmt.yml)
2. [🔨 Code – Build Datamart by using DBT](/_002_src/build_datamart/dbt_customer_behaviour_analytics_dmt/)
3. [📃 Documents - DBT and Building Datamart Documentation](/_004_docs/README-dbt.md)

![dbt_dodbt_lineage_graphcs_ui](/image/dbt_lineage_graph.png)

Directory Structure:
```
build_datamart/ 
│
├── profile.yml
├── requirements.txt
└── dbt_customer_behaviour_analytics_dmt/
         │
         ├── dbt_project.yml
         ├── models/
         │   ├── source/
         │   │   └── gold_sources.yml
         │   ├── dmt_search_event_base.sql
         │   ├── dmt_search_event_category.sql
         │   ├── dmt_search_event_plan.sql
         │   └── schema.yml
         │
         ├── tests/
         ├── macros/
         ├── seeds/
         ├── snapshots/
         └── analyses/
```

### 5. Business Intelligence & Visualization
The project leverages Apache Superset for data visualization and reporting. Apache Superset is an open-source, cost-efficient business intelligence (BI) platform that helps organizations significantly reduce licensing costs compared to commercial solutions such as Tableau or Power BI. It is designed to handle large-scale (Big Data) workloads, integrating seamlessly with modern, cloud-native, and distributed data systems while maintaining high query performance.

Superset offers a rich and extensible visualization library, ranging from basic charts to advanced analytical visualizations, enabling deep data exploration and insight discovery. Additionally, its high extensibility through custom visualization plugins allows teams to develop and integrate domain-specific visual components tailored to specific business requirements. With a flexible and user-friendly interface, Superset empowers both technical and non-technical users to explore data and build interactive dashboards using drag-and-drop functionality, without requiring programming knowledge.

1. [🔨 Code – Apache Superset Docker Compose](/docker-compose.superset.yml)
2. [📃 Dashboard Zip - Visualization File Zip](/_002_src/business_intelligence/)
3. [📃 Documents - Business Intelligence & Visualization by Apache Superset Documentation](/_004_docs/README-superset-and-reporting.md)

![superset_dashboard_list](/image/superset_dashboard_list.png)

---
## 🚀 Quick Start Guide

### Step 1: Infrastructure Setup with Terraform

Deploy AWS infrastructure in the following order:

#### 1.1 AWS Configuration (Required)

Terraform requires valid AWS credentials to provision resources.
Configure AWS access using one of the following methods (recommended: AWS CLI profile).

```bash
aws configure
```

Then, fill the following information using your AWS credentials:

```
AWS Access Key ID: {AWS_ACCESS_KEY_ID} 
AWS Secret Access Key: {AWS_SECRET_ACCESS_KEY} 
Default region name: ${AWS_DEFAULT_REGION} 
Default output format: json
```

#### 1.2 Bootstrap (Required First)

Creates S3 bucket for Terraform state:

```bash
cd _001_iac/terraform/bootstrap
terraform init
terraform plan
terraform apply
```

**Resources Created:**
- S3 bucket: `data-pipeline-e2e-terraform-state` (for storing Terraform state)

#### 1.3 S3 Data Lake

Creates S3 buckets for data storage:

```bash
cd _001_iac/terraform/s3
terraform init
terraform plan
terraform apply
```

**Resources Created:**
- Main data bucket: `data-pipeline-e2e-datalake-{random-suffix}`
- Log bucket: `s3-access-logs-{random-suffix}`

#### 1.4 Redshift Serverless

Creates Redshift Serverless infrastructure:

```bash
cd _001_iac/terraform/redshift
terraform init
terraform plan
terraform apply
```

**Resources Created:**
- VPC with 3 subnets across AZs
- Security groups
- IAM roles and policies
- Redshift Serverless namespace and workgroup

**📖 Detailed Documentation:** See [Terraform Infrastructure Documentation](_004_docs/README-terraform.md)

![Infrastructure Setup with Terraform](/image/s3_buckets.png)
<p align="center">
  <em>Infrastructure Setup with Terraform Sample Output</em>
</p>

---

### Step 2: Create Docker Network

Create the shared Docker network for all services:

```bash
docker network create aws_e2e_network
```

---

### Step 3: Start PostgreSQL and Monitoring Services

#### 3.1 Start PostgreSQL (for Airflow metadata and datamart)

```bash
docker-compose -f docker-compose.dmt.yml up -d --build
```

**Services Started:**
- PostgreSQL (port 5432)
- pgAdmin (port 5050)
- Postgres Exporter (port 9187)

#### 3.2 Start Monitoring Stack (Grafana + Prometheus)

```bash
docker-compose -f docker-compose.grafana.yml up -d --build
```

**Services Started:**
- Prometheus (port 9090)
- Grafana (port 3000)
- StatsD Exporter (ports 9125/udp, 9102)

**Access:**
- Grafana: http://localhost:3000 (admin/grafana)
- Prometheus: http://localhost:9090

**📖 Detailed Documentation:** See [Grafana Monitoring Documentation](_004_docs/README-grafana.md)

---

### Step 4: Configure Airflow Environment

#### 4.1 Create Environment File

Create `.env.aws` in `_002_src/orchestration/`:

```bash
cd _002_src/orchestration
cat > .env.aws << EOF
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_DEFAULT_REGION=ap-southeast-1

# Redshift (if override needed)
REDSHIFT_HOST=your-redshift-host.redshift-serverless.amazonaws.com
REDSHIFT_DB=my-project-e2e-dtb
REDSHIFT_USER=admin
REDSHIFT_PASSWORD=your-password
EOF
```

#### 4.2 Update Data Storage Configuration

Edit `_002_src/orchestration/data_pipeline/_01_config/data_storage_config.py`:

- Update `S3_DATALAKE_PATH` with your S3 bucket name
- Update `REDSHIFT_HOST`, `REDSHIFT_DB`, credentials
- Update `REDSHIFT_IAM_ROLE_ARN` with your IAM role ARN

---

### Step 5: Build and Start Airflow

#### 5.1 Build Docker Image

```bash
cd _002_src/orchestration
docker-compose -f docker-compose.orchestration.yml build
```

#### 5.2 Initialize Airflow Database

```bash
docker-compose -f docker-compose.orchestration.yml up airflow-init
```

#### 5.3 Start Airflow Services

```bash
docker-compose -f docker-compose.orchestration.yml up -d
```

**Services Started:**
- Airflow Webserver (port 8080)
- Airflow Scheduler
- Spark Master (port 7077, 8081)
- Spark Worker (port 8082)

**Access:**
- Airflow UI: http://localhost:8080 (admin/admin)

![Airflow UI](/image/airflow_ui.png)

**📖 Detailed Documentation:** See [Apache Airflow Orchestration Documentation](_004_docs/README-airflow.md)

---

### Step 6: Import Grafana Dashboards

1. Access Grafana: http://localhost:3000
2. Login with admin/grafana
3. Configure Prometheus datasource:
   - Go to **Configuration** → **Data Sources**
   - Add Prometheus datasource: `http://prometheus:9090`
4. Import dashboards:
   - **Airflow Dashboard**: Import `_002_src/monitoring/grafana/airflow-cluster-dashboard.json`
   - **PostgreSQL Dashboard**: Import `_002_src/monitoring/grafana/postgresql-dashboard.json`

![grafana_airflow_dashboard](/image/grafana_airflow_dashboard.png)
<p align="center">
  <em>Grafana Airflow Monitoring Dashboard</em>
</p>

![grafana_postgres_dashboard](/image/grafana_postgres_dashboard.png)
<p align="center">
  <em>Grafana Postgres Monitoring Dashboard</em>
</p>

---

### Step 7: Run Data Pipeline

#### 7.1 Trigger Airflow DAG

1. Access Airflow UI: http://localhost:8080
2. Enable DAG: `data_pipeline_daily`
3. Trigger DAG with config:
   ```json
   {
     "etl_date": "20220601"
   }
   ```

The pipeline will:
- **Bronze Layer**: Ingest raw data from S3
- **Silver Layer**: Clean and normalize data
- **Gold Layer**: Create dimension and fact tables in Redshift and Iceberg

![airflow_pipeline_daily](/image/airflow_pipeline_daily.png)

#### 7.2 Monitor Pipeline Execution

- View DAG progress in Airflow UI
- Check Grafana dashboards for system metrics
- Review logs in Airflow task logs

**📖 Detailed Documentation:** See [Data Lakehouse and Warehouse Architecture Documentation](/_004_docs/README-data-lakehouse-&-warehouse-architecture.md)

---

### Step 8: Replicate Data to PostgreSQL

After Gold layer completes, trigger the replication DAG:

1. Enable DAG: `redshift_to_postgre`
2. Trigger manually (it will wait for `data_pipeline_daily.gold_finish`)

This DAG replicates all Gold layer tables from Redshift to PostgreSQL at schema 'dwh_user_search'.

![airflow_redshift_to_postgre](/image/airflow_redshift_to_postgre.png)

---

### Step 9: Build Datamart with dbt

#### 9.1 Install dbt libs

```bash
cd _002_src/build_datamart
pip install -r requirements.txt
```

#### 9.2 Configure dbt Profile

```bash
# Manually create the .dbt directory and set up profile.yml file
mkdir -p ~/.dbt;
# open folder dbt
cd ~/.dbt/ && code .
```

Create profile.yml and add this content into profile.yml
``` python
dbt_customer_behaviour_analytics_dmt:
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: admin
      password: "admin"
      dbname: postgres
      schema: datamart

    prod:
      type: postgres
      host: localhost
      port: 5432
      user: admin
      password: "admin"
      dbname: postgres
      schema: datamart

  target: dev
```

#### 9.3 Run dbt Models

```bash
cd _002_src/build_datamart/dbt_customer_behaviour_analytics_dmt

# Install dependencies
dbt deps

# Run all models
dbt run

# Run tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

**Models Created:**
- `dmt_search_event_base`
- `dmt_search_event_plan`
- `dmt_search_event_category`

![dbt_docs_ui](/image/dbt_docs_ui.png)

![datamart](/image/datamart.png)


**📖 Detailed Documentation:** See [Build Datamart by using DBT](_004_docs/README-dbt.md)

---

### Step 10: Business Intelligence & Visualization by Apache Superset
Data is retrieved from the Data Warehouse and Datamart layers to power analytical dashboards and reports, enabling the visualization and analysis of user behavior patterns. These insights support data-driven decision-making, allowing the business to define effective strategies and policies aimed at increasing user subscriptions, enhancing user experience and engagement, and driving sustainable revenue growth.

#### 10.1 Run Apache Superset
```bash
docker compose -f docker-compose.superset.yml up -d --build
```

#### 10.2 Copy dashboard bundle into Superset container
```bash
cd _002_src/business_intelligence &&
docker cp dashboards.zip superset_app:/app/dashboards.zip
```

#### 10.3 Access Superset container

```bash
docker exec -it superset_app bash
```

This opens an interactive shell inside the Superset container.

#### 10.4 Import dashboards via Superset CLI

Inside the container, execute:

```bash
superset import-dashboards -p /app/dashboards.zip -u admin
```

![superset_dashboard](/image/superset_dashboard.jpg)
<p align="center">
  <em>Customer Behaviour Analyst Dashboard</em>
</p>

**📖 Detailed Documentation:** See [Business Intelligence & Visualization by Apache Superset](/_004_docs/README-superset-and-reporting.md)

---

## 🔧 Key Technologies

| Technology | Version | Purpose |
|------------|---------|---------|
| Apache Spark | 3.5.3 | Distributed data processing |
| Apache Airflow | 2.10.3 | Workflow orchestration |
| Apache Iceberg | 1.5.2 | Open table format for ACID transactions |
| AWS Redshift Serverless | Latest | Serverless data warehouse |
| AWS S3 | - | Object storage for data lake |
| AWS Glue Data Catalog | - | Managed metastore / catalog |
| PostgreSQL | 15 | Metadata DB and BI datamart |
| dbt | Latest | Data transformation and modeling |
| Grafana | Latest | Metrics visualization |
| Prometheus | 2.38.0 | Metrics collection |
| Terraform | >= 1.0 | Infrastructure as Code |
| Terraform | >= 1.0 | Infrastructure as Code |
| Apache Superset | Latest | Visualization and Reports |

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](/LICENSE) file for details.

---
