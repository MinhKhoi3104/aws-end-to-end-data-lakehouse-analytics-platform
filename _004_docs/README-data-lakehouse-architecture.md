# AWS Data Lakehouse 

## 📋 General
This project applies the **Medallion Architecture**, organizing data processing into three layers: Bronze, Silver, and Gold. Each layer enforces specific transformation and data quality rules before passing data to the next stage.

![Medallion_Architect](/image/Medallion_Architect.png)
<p align="center">
  <em>Medallion Architect</em>
</p>

## 🏗️ AWS Data Lakehouse Architecture

![aws_lakehouse_architecture](/image/aws_lakehouse_architecture.png)
<p align="center">
  <em>AWS Data Lakehouse Architecture</em>
</p>

### 🟤 Bronze Layer
#### Purpose
Store raw data ingested from source systems with minimal transformation, preserving the original data structure for traceability and reprocessing.

#### Processing Rules
- 1:1 mapping with source data
- No deduplication or data cleansing
- No business logic applied
- Schema-on-read
- Stored in Parquet format on Amazon S3

#### Output
- Raw datasets stored in **AWS S3** (Bronze zone) in Parquet format
- Used as input for Silver layer transformations

#### List of code jobs
- `_030101_customer_search.py`

![bronze_s3_store](/image/bronze_s3_store.png)
<p align="center">
  <em>Store Bronze Data at AWS S3</em>
</p>

### ⚪️ Silver Layer
#### Purpose
Clean, standardize, and enrich raw data to create structured datasets suitable for analytics and downstream modeling.

#### Processing Rules
- Cleaned and normalized data
- Data type standardization
- Null handling and data validation
- Reduced data duplication
- Keyword normalization using ML-based logic
- Normalize nested or semi-structured fields into rows and columns

#### Output
- Curated datasets stored in **AWS S3** (Silver zone) in Parquet format
- Used as input for Gold layer transformations

#### List of code jobs
- `crawl_movies.py` -- Crawl movie-related data used as input for ML-based keyword normalization
- `_030201_user_plans_map.py` -- Standardize and map user plan information.
- `_030202_customer_search_keynormalize` --  Normalize customer search keywords using ML logic

![silver_s3_store](/image/silver_s3_store.png)
<p align="center">
  <em>Store Silver Data at AWS S3</em>
</p>

### 🟡 Gold Layer
#### Purpose
Deliver analytics-ready data models optimized for BI tools, reporting, and business consumption.


#### Processing Rules
- Apply Slowly Changing Dimension (SCD) logic
- Build fact and dimension tables
- Aggregated and business-aligned datasets
- Star schema design (fact and dimension tables)
- Enforce referential integrity
- Business metric calculation

#### Output
- Data warehouse tables in **AWS Redshift**
- **Iceberg tables** in the Gold layer for ACID-compliant, analytics-ready datasets

#### List of code jobs
- `_030301_dim_date_overwrite.py`
- `_030302_dim_category_append.py`
- `_030303_dim_platform_append.py`
- `_030304_dim_network_append.py`
- `_030305_dim_user_scd1.py`
- `_030306_dim_subscription_append.py`
- `_030307_bridge_user_plan.py` 
- `_030308_fact_customer_search_append.py`

![data_warehouse_model](/image/data_warehouse_model.png)
<p align="center">
  <em>Data Warehouse Model</em>
</p>

![gold_table_list](/image/gold_table_list.png)
<p align="center">
  <em>List of Tables of Gold layer</em>
</p>

![dim_date_data](/image/dim_date_data.png)
<p align="center">
  <em>Dim Date Table</em>
</p>

![dim_category_data](/image/dim_category_data.png)
<p align="center">
  <em>Dim Category Table</em>
</p>

![dim_platform_data](/image/dim_platform_data.png)
<p align="center">
  <em>Dim Platform Table</em>
</p>

![dim_network_data](/image/dim_network_data.png)
<p align="center">
  <em>Dim Network Table</em>
</p>

![dim_user_data](/image/dim_user_data.png)
<p align="center">
  <em>Dim User Table</em>
</p>

![dim_subscription_data](/image/dim_subscription_data.png)
<p align="center">
  <em>Dim Subscription Table</em>
</p>

![bridge_user_plan_data](/image/bridge_user_plan_data.png)
<p align="center">
  <em>Bridge User Plan Table</em>
</p>

![fact_customer_search](/image/fact_customer_search_data.png)
<p align="center">
  <em>Fact Customer Search Table</em>
</p>

## 📚 References

- [Medallion Architecture](https://www.databricks.com/glossary/medallion-architecture)
- [Star Schema](https://www.databricks.com/glossary/star-schema)
- [Data Warehouse Models: Star, Snowflake, Data Vault & More](https://www.exasol.com/hub/data-warehouse/models-modeling)