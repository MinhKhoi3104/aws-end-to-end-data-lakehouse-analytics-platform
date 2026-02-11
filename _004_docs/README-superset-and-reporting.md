# Apache Superset

## 📋 GENERAL

Apache Superset is a modern, enterprise-ready data exploration and visualization platform. In this project, it serves as the **Business Intelligence (BI)** layer, allowing users to visualize data stored in the Data Warehouse (PostgreSQL) and Data Lakehouse. It replaces traditional BI tools by providing an open-source, code-first analytics experience.

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
**Project Structure:**
The Superset project structure is minimal as most configuration is handled via Docker and the UI/Database state.

```
aws-end-to-end-data-lakehouse-analytics-platform/
│
├── _002_src/
│   └── business_intelligence/
│       └── dashboards.zip      # Exported dashboards & charts for import
├── docker-compose.superset.yml
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
docker compose -f docker-compose.superset.yml up -d
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


**Step 3: Import Pre-built Dashboards**

This step allows you to import predefined dashboards into Apache Superset using a ZIP bundle (exported dashboards, datasets, charts, and metadata).

From your project root, run:

```bash
cd _002_src/business_intelligence
```

This ensures you are in the directory containing the dashboards.zip file.

**Copy dashboard bundle into Superset container**

```bash
docker cp dashboards.zip superset_app:/app/dashboards.zip
```

This command copies the `dashboards.zip` file from your local machine into the Superset container at `/app/dashboards.zip`.

**Access Superset container**

```bash
docker exec -it superset_app bash
```

This opens an interactive shell inside the Superset container.

**Import dashboards via Superset CLI**

Inside the container, execute:

```bash
superset import-dashboards -p /app/dashboards.zip -u admin
```

**Explanation:**

- `-p /app/dashboards.zip`: Path to the dashboard export bundle
- `-u admin`: Superset username who owns the imported objects

**After successful execution:**

- Dashboards
- Charts
- Datasets
- Database connections (if included)

will be automatically restored into Superset.

![superset_dashboard](https://github.com/user-attachments/assets/86e03ad8-2d3f-4384-9cc6-953bef073d2c)

## 📉 Dataset Overview

### Dmt_search_event_base
Stores detailed information for each user search event.
**Granularity:** 1 record = 1 search event

| Column | Description |
| :--- | :--- |
| event_id | Unique identifier for each search event |
| user_id | User ID |
| keyword | Search keyword |
| user_state_at_search | User status at the time of searching:<br>- **Plan:** logged-in user with an active subscription plan<br>- **Noplan:** logged-in user without any subscription plan<br>- **Guest:** user not logged in |
| device_type | Device used (mobile, web, smart TV, etc.) |
| network_name | Internet service provider (Viettel, VNPT, FPT, etc.) |
| network_location | Network location (Local, International, Unknown) |
| main_category | Main content category |
| sub1_category | Sub-category level 1 |
| sub2_category | Sub-category level 2 |
| sub3_category | Sub-category level 3 |
| day | Day |
| month | Month |
| year | Year |
| day_of_week | Day of week |
| time_slot | Time slot:<br>- **1h–4h:** Late Night<br>- **5h–8h:** Early Morning<br>- **9h–12h:** Morning<br>- **13h–16h:** Afternoon<br>- **17h–20h:** Evening<br>- **21h–24h:** Night |
| date_key | Standardized time key |

### Dmt_search_event_category
Aggregates search behavior by category, user, and time.
**Granularity:** 1 record = 1 user – 1 category – 1 time slot

| Column | Description |
| :--- | :--- |
| date_key | Date key |
| day | Day |
| month | Month |
| year | Year |
| day_of_week | Day of week |
| time_slot | User search time slot (Late Night, Early Morning, Morning, Afternoon, Evening, Night) |
| user_id | User ID |
| category | Content category |
| device_type | Device type |
| user_state_at_search | User status at the time of search (Plan / Noplan / Guest) |

### Dmt_search_event_plan
Aggregates users by subscription plan.
**Granularity:** 1 record = 1 plan – 1 month

| Column | Description |
| :--- | :--- |
| date_key | Month (mm/yyyy) |
| plan_name | Subscription plan name |
| plan_type | Plan type (promotion / direct / giftcode) |
| user_count | Number of users using the plan |

## 📈 Dashboard Details
The dashboard is designed to visualize user search behavior on the entertainment platform using data sourced from the Data Mart. The visualizations are constructed to support multidimensional analysis, providing insights into user scale, access characteristics, search behavior over time, content categories, device usage, and user segmentation.

### Visualizations

#### Total Login User & Total Search (Big Number)
These indicators represent the total number of logged-in users and the total number of search events within the analysis period, providing a high-level overview of data volume and overall system activity.

<img width="499" height="175" alt="superset_dashboard_detail_1" src="https://github.com/user-attachments/assets/20010256-fd13-48cc-8304-48bfcd492dca" />


#### Local-international distribution & Top network name (Donut Chart)
*   **Local-international distribution:** Illustrates the proportion of users from local versus international regions.
*   **Top network name:** Shows the distribution of access by internet service providers, including Viettel, VNPT, FPT, and others.

Together, these charts describe user access characteristics from both geographic and network infrastructure perspectives.

<img width="949" height="282" alt="superset_dashboard_detail_2" src="https://github.com/user-attachments/assets/34b849f8-7cc6-4449-8ba4-cfcf184a5526" />

#### Search volume x user state (Stacked Area Chart)
This chart presents search volume over time, segmented by user state at the time of search (guest, login, plan).
*   **Total Area:** Represents overall search volume.
*   **Colored Layers:** Indicate the contribution of each user group.

The visualization supports tracking temporal changes in search behavior and comparing activity levels across user segments.

<img width="591" height="468" alt="superset_dashboard_detail_3" src="https://github.com/user-attachments/assets/abbfb28e-c836-4304-9fe6-db7ae04e8b68" />

#### Search Behavior by Time & Category (Heatmap)
The heatmap illustrates the relationship between time of day and content categories.
*   **Horizontal Axis:** Content categories.
*   **Vertical Axis:** Time slots.
*   **Color Intensity:** Indicates search volume.

This visualization highlights the distribution of search activity across both temporal and content dimensions.

<img width="837" height="496" alt="superset_dashboard_detail_4" src="https://github.com/user-attachments/assets/27e17f54-b2d5-450f-9fdc-a83b0af173ba" />

#### Category Word Cloud & Top Keyword (Word Cloud)
*   **Category Word Cloud:** Visualizes content categories based on their frequency of occurrence, where larger font sizes correspond to higher search volumes.

<img width="1430" height="430" alt="superset_dashboard_detail_5" src="https://github.com/user-attachments/assets/f6ff96b7-253a-4e7a-a2d7-a0be93f7cc4a" />

  
*   **Top Keyword Word Cloud:** Displays the most frequently searched keywords, reflecting user interests at a more granular level.

<img width="1460" height="581" alt="superset_dashboard_detail_6" src="https://github.com/user-attachments/assets/69539bef-7079-4a71-bcef-186a119ba983" />


#### Top 10 Category × Device & Top Plan × Plan Type (Stacked Bar Chart)
*   **Top 10 Category × Device:** Shows the ten most searched content categories segmented by device type (mobile, web, smart TV, etc.).
    *   **X-axis:** Categories.
    *   **Y-axis:** Search volume.
    *   **Stacked Colors:** Device contributions.
*   **Top Plan × Plan Type:** Presents user counts by subscription plan and plan type (promotion, direct, giftcode).
    *   **Grouping:** By plan name.
    *   **Colors:** Plan types.

These charts describe content consumption across platforms and the distribution of users across subscription models.

<img width="1459" height="459" alt="superset_dashboard_detail_7" src="https://github.com/user-attachments/assets/573711d1-44ad-4cf5-b905-9283921d33a3" />

### User Segmentation Analysis
Users are divided into two main groups. For each group, the dashboard uses heatmaps to visualize peak activity times and word clouds to represent the most searched content categories.

1.  **Login User**
   
**Core User:** Logged-in users with an active subscription plan (`user_state_at_search` = ‘plan’).

*  **Peaktime (Core User):** This heatmap visualizes search activity of core users (logged-in users with an active subscription plan) across different time slots and content categories.

*   **Category Word Cloud:** Visualizes content categories based on their frequency of occurrence, where larger font sizes correspond to higher search volumes, specifically reflecting search behavior of logged-in users.

<img width="1470" height="404" alt="superset_dashboard_detail_8" src="https://github.com/user-attachments/assets/b71e7f98-ae32-472d-ab00-029d131f7217" />


**Ready-to-Convert User:** Top 30% of logged-in users without a subscription plan, ranked by highest search volume.

*  **Peaktime (Ready-to-Convert User):** This heatmap visualizes search activity of Ready-to-Convert users (Top 30% noplan logged-in users by search volume) across different time slots and content categories.


*   **Category Word Cloud (Ready-to-Convert User):** Visualizes content categories based on their frequency of occurrence, where larger font sizes correspond to higher search volumes, specifically reflecting search behavior of Ready-to-Convert User.

<img width="1472" height="400" alt="superset_dashboard_detail_9" src="https://github.com/user-attachments/assets/7f8c00e1-ed6f-43e5-9277-f37be7ac1f77" />

2. **Guest:** User not logged in.


*  **Peaktime (Guest):** This heatmap visualizes search activity of guest (non-logged-in users) across different time slots and content categories.

*   **Category Word Cloud (Guest):** Visualizes content categories based on their frequency of occurrence, where larger font sizes correspond to higher search volumes, specifically reflecting search behavior of non-logged-in users.
  
<img width="1469" height="398" alt="superset_dashboard_detail_10" src="https://github.com/user-attachments/assets/861b7ddd-590e-4587-b64b-765b9694c0da" />

*   **Stacked Bar Chart (Top Category × Device Type)** is included to present search volumes by content category, segmented by device type such as mobile, smart TV, web, and OTT box.
*   **X-axis:** Content categories.
*   **Y-axis:** Total searches.
*   **Colored Segments:** Different device types.

This chart provides a combined view of content distribution and device usage among non-logged-in users.

<img width="1458" height="382" alt="superset_dashboard_detail_11" src="https://github.com/user-attachments/assets/00fe1238-3e81-4114-b1ac-d3695995e85a" />


---
## 📚 REFERENCES

-   [Apache Superset Documentation](https://superset.apache.org/docs/intro)
-   [Superset on Docker Compose](https://superset.apache.org/docs/installation/docker-compose)
-   [Connecting to Databases](https://superset.apache.org/docs/databases/installing-database-drivers)



