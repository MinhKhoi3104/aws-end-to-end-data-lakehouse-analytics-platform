# Apache Superset

## 📋 GENERAL

Apache Superset is a modern, enterprise-ready data exploration and visualization platform. In this project, it serves as the **Business Intelligence (BI)** layer, allowing users to visualize data stored in the Data Warehouse (PostgreSQL) and Data Lakehouse (Iceberg/Trino). It replaces traditional BI tools by providing an open-source, code-first analytics experience.

## 🎯 WHY USING SUPERSET

1.  **Explore Data with SQL Lab**
    *   A rich SQL IDE to query data from any connected database.
    *   Visualize query results instantly.
2.  **Rich Visualization Gallery**
    *   Offers a wide array of charts, from simple pie charts to complex geospatial decks.
    *   Highly customizable visualization settings.
3.  **Code-Free Visualization Builder**
    *   "Explore" interface allows users to build charts without writing code, using drag-and-drop features.
4.  **Interactive Dashboards**
    *   Combine multiple charts into a single interactive dashboard.
    *   Supports cross-filtering and cascading filters.
5.  **Semantic Layer**
    *   Define custom metrics and calculated columns efficiently within Superset without altering the underlying database.
6.  **Security & extensibility**
    *   Detailed row-level security.
    *   Integrates with major authentication backends (database, OpenID, LDAP, etc.).

## 🏗️ ARCHITECTURE AND CONFIGURATION

### Architecture

The superset project structure is minimal as most configuration is handled via Docker and the UI/Database state.

```
aws-end-to-end-dwh-analytics-platform/
│
├── _002_src/
│   └── superset/
│       └── docker/           # Docker specific scripts (bootstrapping)
│
├── docker-compose.superset.yml # Main service definition
└── docker/
    └── .env                    # Environment variables (credentials, config)
```

The Superset deployment consists of the following services:

-   **superset**: The main web server application (Gunicorn).
-   **superset-init**: One-off initialization service (db migration, admin creation).
-   **superset-worker**: Celery worker for async tasks (queries, reports).
-   **superset-worker-beat**: Scheduler for periodic tasks (alerts, reports).
-   **redis**: Message broker for Celery & caching layer.
-   **db**: PostgreSQL metadata store (users, dashboards, slices).

### Configuration

**Environment Variables:**
Configuration is primarily managed through `docker/.env`. Key variables include:

-   `SUPERSET_SECRET_KEY`: Application security key.
-   `SUPERSET_ADMIN_USERNAME` / `PASSWORD`: Default admin credentials.
-   `POSTGRES_DB` / `USER` / `PASSWORD`: Metadata DB credentials.
-   `REDIS_HOST` / `PORT`: Connection to Redis.

**Docker Compose (`docker-compose.superset.yml`):**
Orchestrates the services within the `aws_e2e_network`, ensuring connectivity to the Data Warehouse and Lakehouse.

### Core Components

1. **PostgreSQL Data Warehouse**
   PostgreSQL serves as the primary analytical data warehouse, storing fact and dimension tables generated from the ETL pipeline.
   * Stores structured analytical data
   * Supports SQL-based querying and aggregation
   * Acts as the main data source for Apache Superset
    
2. **Apache Superset Database Connection**
   Apache Superset connects to PostgreSQL through SQLAlchemy URIs, enabling direct querying of warehouse tables.
   * Configured using SQLAlchemy connection strings
   * Manages authentication and database metadata
   * Allows Superset to discover schemas and tables

3. **Datasets (Semantic Layer)**
   Datasets represent the semantic layer in Superset, built on top of physical PostgreSQL tables or custom SQL queries.
   * Defines business metrics (e.g., SUM(user_count))
   * Supports calculated columns
   * Provides reusable analytical models for visualizations

4. **Charts (Slices)**
   Charts are individual visualizations created from Datasets and represent specific analytical perspectives.
   * Includes bar charts, line charts, tables, and big-number KPIs
   * Supports interactive filters and aggregations
   * Enables detailed data exploration

5. **Dashboards**
   Dashboards aggregate multiple Charts into a unified interactive interface.
   * Combines multiple visualizations
   * Supports global filters and markdown components
   * Facilitates exploratory data analysis

## 💻 TO USE SUPERSET

### 1. Create Docker Network

Run the following command from the project root:
This command creates a custom Docker bridge network named aws_e2e_network.
```bash
docker network create aws_e2e_network
```
The custom network allows multiple containers (such as PostgreSQL, Apache Superset, Airflow, Spark, or other data services) to communicate with each other using container names instead of IP addresses.

Key benefits:

- Enables inter-container communication

- Provides network isolation from other Docker projects

- Allows Superset to connect to PostgreSQL using service names (e.g., postgres:5432)

- Supports scalable microservice-style architecture

### 2. Start Apache Superset with Docker Compose
This command launches Apache Superset and its dependent services in detached mode.
```bash
docker-compose -f docker-compose.superset.yml up -d
```
- ```-f docker-compose.superset.yml``` Specifies a custom Docker Compose configuration file dedicated to Superset deployment.
- ```up``` Creates and starts all containers defined in the compose file.
- After execution, Superset becomes accessible via browser (typically at http://localhost:8089).
### 3. Access the Interface

-   **URL**: [http://localhost:8089](http://localhost:8089)
-   **Login**: `admin` / `admin` (default)

### 4. Development Workflow

**Step 1: Connect to Database**
*   Go to **Settings** -> **Database Connections**.
*   Add a new database
*   Connect Superset to PostgreSQL
*   <img width="466" height="800" alt="image" src="https://github.com/user-attachments/assets/86e7b390-82c0-4872-baf6-a0d8aea6c012" />

**Step 2: Create a Dataset**
*   Go to **Datasets** -> **+ Dataset**.
*   Select your Database, Schema, and Table.
<img width="1919" height="663" alt="image" src="https://github.com/user-attachments/assets/c6660832-5f0e-4d92-87dd-a791eacc591b" />


**Step 3: Create Charts**
*   From a Dataset, click the **Charts** tab or "Explore".
*   Select a visualization type (e.g., Time-series Line Chart).
*   <img width="1894" height="874" alt="image" src="https://github.com/user-attachments/assets/acd6726e-4998-4f8e-8582-e066810b548e" />

*   Drag and drop metrics and dimensions.
*   Click **Save** to persist the chart.

**Step 4: Build a Dashboard**
*   Go to **Dashboards** -> **+ Dashboard**.
*   Drag your saved Charts onto the canvas.
*   Add native filters (e.g., Date Range) to make it interactive.
*   Save and Publish.
  <img width="698" height="2048" alt="image" src="https://github.com/user-attachments/assets/822a5089-1e66-4508-82d4-1b1e5ba13e47" />

---
## 📚 REFERENCES

-   [Apache Superset Documentation](https://superset.apache.org/docs/intro)
-   [Superset on Docker Compose](https://superset.apache.org/docs/installation/docker-compose)
-   [Connecting to Databases](https://superset.apache.org/docs/databases/installing-database-drivers)
