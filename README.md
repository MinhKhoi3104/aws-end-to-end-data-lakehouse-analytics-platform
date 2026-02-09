# 🚀 AWS End-to-End Data Lakehouse Analytics Platform

<p align="center">
  <a href="https://github.com/MinhKhoi3104/aws-end-to-end-data-lakehouse-analytics-platform/tree/main/README/#-quick-start-guide">
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
  - [Crawled data from film website](#crawled-data-from-film-website)
- [🌐 Architecture Overview](#-architecture-overview)
  - [1. AWS Configuration (Infrastructure as Code - Terraform)](#-aws-configuration-)
  - [2. Distributed Batch Processing](#2-distributed-batch-processing)
  - [3. Monitoring & Observability](#3-monitoring--observability)
  - [4. Datamart for business analytics and reporting](#4-datamart-for-business-analytics-and-reporting)
  - [5. Business Intelligence & Visualization](#5-business-intelligence--visualization)
- [🚀 Quick Start Guide](#-quick-start-guide)
  - [Step 1: Infrastructure Setup with Terraform](#step-1-infrastructure-sepup-with-terraform)
  - [Step 2: Create Docker Network](#step-2-create-docker-network)
  - [Step 3: Start PostgreSQL and Monitoring Services](#step-3-start-postgresql-and-monitoring-services)
  - [Step 4: Configure Airflow Environment](#step-4-configure-airflow-environment)
  - [Step 5: Build and Start Airflow](#step-5-build-and-start-airflow)
  - [Step 6: Import Grafana Dashboards](#step-4-configure-airflow-environment)
  - [Step 7: Run Data Pipeline](#step-7-run-data-pipeline)
  - [Step 8: Replicate Data to PostgreSQL](#step-8-replicate-data-to-postgresql)
  - [Step 9: Build Datamart with dbt](#step-9-build-datamart-with-dbt)
  - [Step 10: Visualize data by Apache Superset and Reporting](#step-10-visualize-data-by-apache-superset-and-reporting)
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
│   ├── crawl_web_data/          # Web scraping scripts
│   ├── monitoring/              # Grafana & Prometheus configs
│   │   ├── config/
│   │   └── grafana/
│   └── orchestration/           # Airflow DAGs and ETL jobs
│       ├── dags/
│       ├── data_pipeline/
│       └── jars/
│
├── _003_test/                    # Test utilities
│   └── data_pipeline/
│
├── _004_docs/                    # Documentation
│
├── docker-compose.dmt.yml        # PostgreSQL & pgAdmin
├── docker-compose.grafana.yml   # Grafana & Prometheus
├── docker-compose.orchestration.yml # Airflow (in orchestration/)
└── README.md                     # This file
```

---

## 📚 Dataset
### Customer search data log
Dữ liệu được dùng cho dự án này là dữ liệu customer searching được log từ 1 online entertainment platforms có thể dùng trên nhiều thiết bị (máy tính, điện thoại, Tivi,...) từ ngày 2022-06-01 đến ngày 2022-06-03. Dữ liệu cho biết được lịch sử searching của customer trong thời gian sử dụng dịch vụ trên nền tảng với cấu trúc và ý nghĩa như sau:

| Field          | Description                                                          |
| -------------- | -------------------------------------------------------------------- |
| event_time     | Mã ID duy nhất cho mỗi sự kiện log                                   |
| datetime       | Thời điểm sự kiện xảy ra (timestamp)                                 |
| user_id        | ID người dùng (có thể None nếu chưa đăng nhập / guest)               |
| keyword        | Từ khoá user sử dụng để search                                       |
| category       | Loại hành vi (enter / quit ) — có thể là trạng thái session          |
| proxy_isp      | Nhà mạng / ISP mà user sử dụng (fpt / vnpt / viettel/ other / spt)   |
| platform       | Thiết bị / hệ điều hành (android / ios / smarttv-sony-android…)      |
| networkType    | Loại kết nối ('wifi', 'WWAN', 'ethernet','3g', ...)                  |
| action         | Hành động chính (search)                                             |
| userPlansMap   | Danh sách gói dịch vụ hiện tại của user                              |

![customer_search_log_data](/image/customer_search_log_data.png)
<p align="center">
  <em>Customer Search Log Data Sample</em>
</p>

### Crawled data from film website
Dữ liệu được crawl từ 1 web film online, dữ liệu được dùng để chuẩn hóa dữ liệu search của customer bằng thuật toán Machine Learning để có thể chuẩn hóa dữ liệu search ví dụ như: có 2 user đều tìm phim Doraemon, trong đó user_1 search ký tự 'doramon' (mất chữ 'e') và user_2 search ký tự 'doremon' (mất chữ 'a') thì dựa vào việc áp dụng ML, từ khóa của 2 user này sẽ được chuẩn hóa về loại phim đúng cần tìm là 'Doraemon'.

Cấu trúc của dữ liệu crawl về là:

| Field          | Description                                                          |
| -------------- | -------------------------------------------------------------------- |
| _id            | ID định danh duy nhất của bộ phim                                    |
| title          | Tên phim hiển thị cho người dùng (Tiếng việt)                        |
| slug           | Chuỗi định danh thân thiện với URL (SEO-friendly)                    |
| original_title | Tên gốc của phim theo ngôn ngữ sản xuất                              |
| release_date   | Ngày phim chính thức phát hành hoặc bắt đầu chiếu                    |
| status         | Trạng thái phát hành của phim                                        |
| quality        | Chất lượng video cao nhất hiện có                                    |
| rating         | Phân loại độ tuổi người xem (Age Rating)                             |
| runtime        | Thời lượng mỗi tập hoặc toàn bộ phim                                 |
| overview       | Mô tả ngắn / tóm tắt nội dung phim                                   |
| origin_country | Quốc gia sản xuất phim                                               |
| genres         | Thể loại phim                                                        |

![crawled_data](/image/crawled_data.png)
<p align="center">
  <em>Crawled Data Sample</em>
</p>

---

## 🌐 Architecture Overview
### 1. AWS Configuration (Infrastructure as Code - Terraform)

Dự án này sử dụng Terraform như một công cụ Infrastructure as Code (IaC) để định nghĩa, cấu hình và quản lý hạ tầng cũng như các tài nguyên đám mây trên AWS (bao gồm Amazon S3 và Amazon Redshift), nhằm tạo ra các môi trường nhất quán, được kiểm soát phiên bản và có thể tái tạo một cách tự động.

1. [🔨 Infrastructure Code – Configure AWS Architecture using Terraform](/_001_iac/terraform/)

Tài liệu mô tả chi tiết cách tổ chức mã nguồn, cấu hình tài nguyên AWS được áp dụng trong Terraform cho dự án này:

2. [📃 Documents - Terraform Documentation](/_004_docs/README-terraform.md)

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

Dự án này triển khai kiến ​​trúc xử lý hàng loạt phân tán mạnh mẽ sử dụng PySpark để tính toán và Apache Airflow để điều phối. Bên cạnh đó, Apache Iceberg is used as the table format on Amazon S3, providing enterprise-grade capabilities such as ACID transactions, time travel, schema evolution, and partition evolution, ensuring reliable and maintainable datasets. Các chức năng cốt lõi được cấu trúc như sau:


1. [🔨 Code – Data Pipeline (OLTP -> Data Lakehouse & Data Warehouse)](/_002_src/orchestration/data_pipeline/)

2. [📃 Documents - Data Lakehouse & Warehouse Architecture Documentation](/_004_docs/README-data-lakehouse-&-warehouse-architecture.md)

Dữ liệu hàng ngày sẽ được sử lý dựa trên Pyspark, dữ liệu được xử lý qua 3 tầng theo mô hình Medallion Architecture , where data is processed sequentially across three layers: **Bronze, Silver, and Gold**. This architectural approach ensures data quality, consistency, scalability, and end-to-end data lineage throughout the entire pipeline. At the Gold layer, data is modeled using a star schema with fact and dimension tables, enabling the construction of subject-oriented datamarts** that efficiently support OLAP analysis and BI reporting. Apache Iceberg được sử dụng làm định dạng bảng trên Amazon S3 ở Gold Layer, cung cấp các khả năng cấp doanh nghiệp như ACID transactions, time travel, schema evolution, and partition evolution, ensuring reliable and maintainable datasets.

<p align="center">
  <img src="/image/Medallion_Architect.png" alt="Medallion Architect" />
</p>

3. [🔨 Code – Scheduling based on Airflow (DAGs)](/_002_src/orchestration/dags/)
4. [📃 Documents - Airflow Documentation](/_004_docs/README-airflow.md)

Toàn bộ quy trình xử lý hàng loạt được tự động hóa thông qua Apache Airflow, với các DAG được lên lịch chạy hàng đêm lúc 2:00 sáng. Bộ lập lịch điều phối 2 Dags bao gồm DAG 'data_pipeline_daily' dùng để chạy các job data pipeline hàng ngày (bao gồm đọc dữ liệu từ nguồn, xử lý dữ liệu qua các tầng và mô hình hóa dữ liệu) và DAG 'redshift_to_postgre' dùng để replicate dữ liệu từ tầng Gold về PostgreSQL để dùng cho việc xây dựng Datamart và visualization.

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
### 4. Datamart for business analytics and reporting
### 5. Business Intelligence & Visualization
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

Then, điền các thông tin này dựa trên thông tin AWS credentials của bạn:

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

![datamart](/image/datamart.png)


**📖 Detailed Documentation:** See [Build Datamart by using DBT](_004_docs/README-dbt.md)

---

### Step 10: Visualize data by Apache Superset and Reporting
Thực hiện lấy dữ liệu từ Data Warehouse và Datamart để visualize thực hiện báo cáo để từ đó get insight từ hành vi của user để từ đó có thể đưa ra được các quyết định, chính sách hợp lý để nâng cao số lượng người đăng ký, nâng cao chất lượng người dùng và phát triển lợi nhuận của doanh nghiệp.

You can access the dashboard from the link: [Customer_Behaviour_Analyst_Dashboard](https://misfashioned-premonarchial-nguyet.ngrok-free.dev/superset/dashboard/12)

![superset_dashboard](/image/superset_dashboard.jpg)
<p align="center">
  <em>Customer Behaviour Analyst Dashboard</em>
</p>

**📖 Detailed Documentation:** See [Visualize by using Apache Superset and Report](_004_docs/)

---

## 🔧 Key Technologies

| Technology | Version | Purpose |
|------------|---------|---------|
| Apache Spark | 3.5.3 | Distributed data processing |
| Apache Airflow | 2.10.3 | Workflow orchestration |
| Apache Iceberg | 1.5.2 | Open table format for ACID transactions |
| AWS Redshift Serverless | Latest | Serverless data warehouse |
| AWS S3 | - | Object storage for data lake |
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
