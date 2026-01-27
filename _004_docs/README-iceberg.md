# Apache Iceberg Application

## 📋 General

This project uses **Apache Iceberg** as an open table format for the **Gold Layer** of the data warehouse. Iceberg provides efficient table management on S3, along with features such as **ACID transactions, time travel, schema evolution, and partition evolution**.

## 🎯 Why using Apache Iceberg?

### 1. **ACID Transactions**
- Ensures **data consistency** during **concurrent read and write operations**
- Safely supports operations such as `MERGE INTO`, `UPDATE`, and `DELETE`
- Prevents issues related to **dirty reads** and **write conflicts**

### 2. **Time Travel & Snapshot Isolation**
- Enables querying data at **any point in time in the past**
- **Supports rollback** to a previous snapshot when needed
- Well-suited for **audit trails and compliance requirements**

### 3. **Schema Evolution**
- Allows **schema changes (adding, dropping, or modifying columns) without rewriting the entire dataset**
- Automatically handles **backward compatibility**
- **Minimizes downtime** and **storage costs**

### 4. **Partition Evolution**
- Allows changing the **partitioning strategy** without requiring data migration
- Provides flexibility to **optimize query performance over time**

### 5. **Hidden Partitioning**
- Partitions are **automatically managed by Iceberg**
- Query engines automatically apply **partition pruning**
- Queries do **not require knowledge of the underlying partition structure**

### 6. **Performance Optimization**
- Metadata is **stored efficiently**, reducing overhead from **file listing operations**
- Supports **file-level statistics for query optimization**
- Integrates well with Spark, Presto, Trino, and other query engines

## 🏗️ Architecture and Configuration

### General Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Gold Layer                           │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │         Apache Iceberg Tables                    │   │
│  │  - sk_registry                                   │   │
│  │  - bridge_user_plan                              │   │
│  │  - dim_category                                  |   |
|  |  - dim_network                                   |   |
|  |  - dim_platform                                  |   |               
│  │  - dim_subscription                              |   |
|  |  - dim_user                                      |   |
|  |  - fact_customer_search                          |   |
│  └──────────────────────────────────────────────────┘   │
│                          │                              │
│                          ▼                              │
│  ┌──────────────────────────────────────────────────┐   │
│  │      AWS Glue Catalog (Metadata Catalog)         │   │
│  │  - Manage table metadata                         │   │
│  │  - Schema definitions                            │   │
│  │  - Table properties                              │   │
│  └──────────────────────────────────────────────────┘   │
│                          │                              │
│                          ▼                              │
│  ┌──────────────────────────────────────────────────┐   │
│  │      S3 Warehouse (Data + Metadata)              │   │
│  │  - Data files (Parquet)                          │   │
│  │  - Metadata files (JSON)                         │   │
│  │  - Manifest files                                │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```
  

![AWS_Glue_Data_Catalog](/image/AWS_Glue_Data_Catalog.png)
<p align="center">
  <em> AWS Glue Data Catalog</em>
</p>


![iceberg_tbl_detail](/image/iceberg_tbl_detail.png)
<p align="center">
  <em> Apache Iceberg table details in AWS Glue Data Catalog</em>
</p>
### Cấu hình Spark Session

Iceberg được cấu hình trong hàm `create_gold_spark_session()` với các thông số sau:

```python
# Iceberg Extensions
spark.sql.extensions = org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions

# Catalog Configuration
spark.sql.catalog.iceberg = org.apache.iceberg.spark.SparkCatalog
spark.sql.catalog.iceberg.catalog-impl = org.apache.iceberg.aws.glue.GlueCatalog
spark.sql.catalog.iceberg.warehouse = s3a://data-pipeline-e2e-datalake-98c619f9/iceberg-warehouse
spark.sql.catalog.iceberg.io-impl = org.apache.iceberg.aws.s3.S3FileIO
```

### Thành phần chính

1. **AWS Glue Catalog**: Lưu trữ metadata về tables, schemas, và partitions
   - Tích hợp với AWS Glue Data Catalog
   - Có thể query từ Athena, Redshift Spectrum, và các tools khác

2. **S3 Warehouse**: Lưu trữ dữ liệu và metadata files
   - **Data files**: Dữ liệu thực tế dưới dạng Parquet
   - **Metadata files**: Thông tin về snapshots, schemas, và partition specs
   - **Manifest files**: Danh sách các data files trong mỗi snapshot

3. **JAR Dependencies**:
   - `iceberg-spark-runtime-3.5_2.12-1.5.2.jar`: Spark runtime cho Iceberg
   - `iceberg-aws-bundle-1.5.2.jar`: AWS integration (Glue Catalog, S3)

## 💻 Cách sử dụng trong Dự án

### 1. Tạo Namespace và Table

```python
# Tạo namespace
spark.sql("CREATE NAMESPACE IF NOT EXISTS iceberg.gold")

# Tạo table với schema định nghĩa sẵn
spark.sql("""
    CREATE TABLE IF NOT EXISTS iceberg.gold.dim_category(
        category_key   int,
        category_name   string,
        category_slug    string
    )
    USING iceberg;
""")
```

### 2. Append Data (Insert mới)

```python
# Append data vào table
insert_df.writeTo("iceberg.gold.dim_category").append()
```

### 3. Merge Data (Upsert)

```python
# Sử dụng MERGE INTO cho upsert operations
spark.sql("""
    MERGE INTO iceberg.gold.sk_registry t
    USING stg_registry s
    ON t.entity_name = s.entity_name
    WHEN MATCHED THEN
      UPDATE SET
        current_max = s.current_max,
        updated_at  = s.updated_at
    WHEN NOT MATCHED THEN
      INSERT (entity_name, current_max, updated_at)
      VALUES (s.entity_name, s.current_max, s.updated_at)
""")
```

### 4. Query Data

```python
# Query từ Iceberg table
df = spark.sql("SELECT * FROM iceberg.gold.dim_category")

# Hoặc sử dụng DataFrame API
df = spark.read.format("iceberg").load("iceberg.gold.dim_category")
```

### 5. Time Travel Queries

```python
# Query dữ liệu tại một snapshot cụ thể
df = spark.read \
    .option("as-of-timestamp", "2024-01-01 00:00:00") \
    .format("iceberg") \
    .load("iceberg.gold.dim_category")

# Hoặc query tại một snapshot ID
df = spark.read \
    .option("snapshot-id", 1234567890) \
    .format("iceberg") \
    .load("iceberg.gold.dim_category")
```

## 📝 Ví dụ thực tế trong Dự án

### File: `_030302_dim_category_append.py`

File này minh họa cách sử dụng Iceberg để:
1. Tạo table nếu chưa tồn tại
2. Đọc dữ liệu từ Silver layer
3. Transform và chuẩn bị dữ liệu
4. So sánh với dữ liệu hiện có để chỉ insert records mới
5. Append data vào Iceberg table

```python
# Tạo table
spark.sql("""CREATE TABLE IF NOT EXISTS iceberg.gold.dim_category(...) USING iceberg;""")

# Đọc dữ liệu cũ
tg_df_old = spark.sql("SELECT * FROM iceberg.gold.dim_category")

# So sánh và chỉ lấy dữ liệu mới
insert_df = tg_df.subtract(tg_df_old)

# Append dữ liệu mới
if insert_df.count() > 0:
    insert_df.writeTo("iceberg.gold.dim_category").append()
```

### File: `surrogate_key_registry.py`

Sử dụng Iceberg table để quản lý surrogate keys:
- Table `iceberg.gold.sk_registry` lưu trữ max key hiện tại cho mỗi entity
- Sử dụng `MERGE INTO` để update registry một cách atomic
- Đảm bảo không có duplicate keys khi chạy parallel jobs

## 🔍 Các tính năng nâng cao

### 1. Schema Evolution

```python
# Thêm cột mới
spark.sql("ALTER TABLE iceberg.gold.dim_category ADD COLUMN description string")

# Đổi tên cột
spark.sql("ALTER TABLE iceberg.gold.dim_category RENAME COLUMN category_name TO name")

# Xóa cột
spark.sql("ALTER TABLE iceberg.gold.dim_category DROP COLUMN old_column")
```

### 2. Partitioning

```python
# Tạo table với partition
spark.sql("""
    CREATE TABLE iceberg.gold.fact_sales(
        sale_id bigint,
        sale_date date,
        amount decimal(10,2)
    )
    USING iceberg
    PARTITIONED BY (days(sale_date))
""")
```

### 3. Table Properties

```python
# Set table properties khi tạo table
spark.sql("""
    CREATE TABLE iceberg.gold.dim_category(...)
    USING iceberg
    TBLPROPERTIES (
        'write.target-file-size-bytes'='536870912',
        'write.parquet.compression-codec'='zstd'
    )
""")
```

### 4. Expire Snapshots

```python
# Xóa các snapshots cũ để giải phóng storage
spark.sql("CALL iceberg.system.expire_snapshots('iceberg.gold.dim_category', TIMESTAMP '2024-01-01 00:00:00')")
```

## ✅ Lợi ích cụ thể trong Dự án

### 1. **Data Quality & Consistency**
- ACID transactions đảm bảo dữ liệu luôn consistent
- Hỗ trợ upsert operations với `MERGE INTO`
- Tránh được partial writes và data corruption

### 2. **Operational Efficiency**
- Không cần quản lý partition paths thủ công
- Metadata được quản lý tự động
- Dễ dàng thêm/xóa/sửa schema mà không ảnh hưởng đến dữ liệu hiện có

### 3. **Cost Optimization**
- Chỉ cần đọc các files liên quan nhờ metadata optimization
- Hỗ trợ compaction để tối ưu storage
- Có thể expire snapshots cũ để giảm storage costs

### 4. **Integration với AWS Services**
- Tích hợp với AWS Glue Catalog → có thể query từ Athena, Redshift Spectrum
- Sử dụng S3 làm storage layer → cost-effective và scalable
- Tương thích với các AWS analytics services

### 5. **Developer Experience**
- SQL-like interface, dễ sử dụng
- Hỗ trợ tốt với Spark DataFrame API
- Time travel giúp debug và audit dễ dàng hơn

## 🚀 Best Practices

### 1. **Table Naming Convention**
- Sử dụng namespace để tổ chức: `iceberg.gold.*`, `iceberg.silver.*`
- Đặt tên table rõ ràng, theo convention của dự án

### 2. **Write Operations**
- Sử dụng `append()` cho insert-only workloads
- Sử dụng `MERGE INTO` cho upsert operations
- Batch writes để tối ưu performance

### 3. **Partitioning Strategy**
- Chọn partition columns dựa trên query patterns
- Tránh over-partitioning (quá nhiều small files)
- Sử dụng hidden partitioning khi có thể

### 4. **Maintenance**
- Định kỳ expire snapshots cũ
- Chạy compaction để merge small files
- Monitor table size và file count

### 5. **Error Handling**
- Luôn check số lượng records trước khi write
- Sử dụng try-catch cho các operations
- Log các operations quan trọng

## 📚 Tài liệu tham khảo

- [Apache Iceberg Official Documentation](https://iceberg.apache.org/)
- [Iceberg Spark Integration](https://iceberg.apache.org/docs/latest/spark-configuration/)
- [AWS Glue Catalog Integration](https://iceberg.apache.org/docs/latest/aws/)
- [Iceberg Specification](https://iceberg.apache.org/spec/)

## 🔗 Liên quan đến các thành phần khác

- **Silver Layer**: Dữ liệu từ Silver layer (Parquet trên S3) được đọc và transform trước khi load vào Iceberg tables
- **Redshift**: Dữ liệu từ Iceberg tables có thể được sync sang Redshift để phục vụ BI tools
- **AWS Glue**: Sử dụng Glue Catalog để quản lý metadata, có thể query từ Glue/Athena
- **S3**: Warehouse path: `s3a://data-pipeline-e2e-datalake-98c619f9/iceberg-warehouse`

---

**Lưu ý**: Tài liệu này được cập nhật dựa trên implementation hiện tại của dự án. Khi có thay đổi về cấu hình hoặc cách sử dụng, vui lòng cập nhật tài liệu này.

