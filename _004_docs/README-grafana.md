## Monitoring with Grafana & Prometheus

This repository ships with a ready-to-use monitoring stack:

- **Prometheus**: collects metrics from Airflow (via StatsD exporter) and PostgreSQL.
- **Grafana**: visualizes metrics via two dashboards:
  - **Airflow cluster dashboard** (`airflow-cluster-dashboard.json`)
  - **Postgres Overview dashboard** (`postgresql-dashboard.json`)

Related configuration files:

- `docker-compose.grafana.yml`: starts Prometheus, Grafana, StatsD exporter, Postgres exporter.
- `_002_src/monitoring/config/prometheus.yml`: declares scrape jobs for Airflow & Postgres.
- `_002_src/monitoring/config/statsd.yml`: maps Airflow StatsD metrics to Prometheus metrics (prefix `af_agg_*`).
- `_002_src/monitoring/grafana/*.json`: definitions of the two dashboards to import into Grafana.

---

## 📊 Airflow cluster dashboard

This dashboard helps you monitor **Airflow cluster health**: DAG/task success & failures, scheduler performance, executor capacity, and DAG runtimes.

![grafana_airflow_dashboard](/image/grafana_airflow_dashboard.png)

### Overview – Today

- **DAG Success Today**  
  - **Meaning**: Number of successful DAG runs in the last 24 hours.  
  - **Key metric**: `af_agg_dagrun_duration_success` (counting DAG runs that reached `success` state).

- **DAG Failed Today**  
  - **Meaning**: Number of failed DAG runs in the last 24 hours.  
  - **Key metric**: `af_agg_dagrun_duration_failed`.

- **Tasks Failed Today**  
  - **Meaning**: Total number of failed task instances in the last 24 hours.  
  - **Key metric**: `af_agg_ti_failures`.

- **Avg DAG Duration Today (sec)**  
  - **Meaning**: Average (median, quantile `0.5`) DAG runtime over the last 24 hours.  
  - **Key metric**: `af_agg_dag_task_duration{quantile="0.5"}` (seconds).

### Scheduler

- **Scheduler heartbeat**  
  - **Meaning**: Scheduler heartbeat, showing whether the scheduler is alive and progressing.  
  - **Metric**: `af_agg_scheduler_heartbeat`.

- **Dagbag size**  
  - **Meaning**: Number of DAGs loaded into the scheduler’s dagbag.  
  - **Metric**: `af_agg_dagbag_size`.

- **Total DAG parse time today**  
  - **Meaning**: Total time (seconds) spent parsing all DAG files over the last 24 hours.  
  - **Metric**: `af_agg_dag_processing_total_parse_time` (via `increase(...[1d])`).

- **Dagbag import errors**  
  - **Meaning**: Number of errors when importing/parsing DAGs (e.g. syntax errors, import failures).  
  - **Metric**: `af_agg_dag_processing_import_errors`.

- **Zombies killed**  
  - **Meaning**: Number of “zombie” tasks cleaned up by the scheduler.  
  - **Metric**: `af_agg_zombies_killed`.

### Task & Operator stats

- **Total successful tasks**  
  - **Meaning**: Total number of successful task instances (cumulative).  
  - **Metric**: `af_agg_ti_successes`.

- **Total failed tasks**  
  - **Meaning**: Total number of failed task instances (cumulative).  
  - **Metric**: `af_agg_ti_failures`.

- **Operator success rate per minute**  
  - **Meaning**: Success rate of tasks per operator, in tasks per minute.  
  - **Metric**: `rate(af_agg_ti_successes[1m]) * 60`, grouped by `operator_name`.

- **Operator failure rate per minute**  
  - **Meaning**: Failure rate of tasks per operator, in tasks per minute.  
  - **Metric**: `rate(af_agg_ti_failures[1m]) * 60`, grouped by `operator_name`.

### Executor Pool

- **Jobs started per minute**  
  - **Meaning**: Number of tasks starting execution per minute (per job/executor).  
  - **Metric**: `rate(af_agg_ti_start[5m]) * 60`.

- **Jobs ended per minute**  
  - **Meaning**: Number of tasks finishing (success or fail) per minute.  
  - **Metric**: `rate(af_agg_ti_finish[1m]) * 60`.

- **Executor open slots / queued tasks / running tasks**  
  - **Meaning**:  
    - `Executor open slots`: free slots available to accept new tasks.  
    - `Executor queued tasks`: number of tasks waiting in the executor queue.  
    - `Executor running tasks`: number of tasks currently running.  
  - **Metrics**: `af_agg_executor_open_slots`, `af_agg_executor_queued_tasks`, `af_agg_executor_running_tasks`.

### DAG stats

- **Success DAG run duration**  
  - **Meaning**: Distribution of runtimes (per quantile) for successful DAG runs, in milliseconds.  
  - **Metric**: `af_agg_dagrun_duration_success` (combined with `quantile` label).

- **Failed DAG run duration**  
  - **Meaning**: Distribution of runtimes for failed DAG runs, in milliseconds.  
  - **Metric**: `af_agg_dagrun_duration_failed`.

- **DAG run duration**  
  - **Meaning**: Total number of seconds that all tasks of each DAG have run in the last 24 hours (aggregated per `dag_id`).  
  - **Metric**: `af_agg_dag_task_duration_sum` with `increase(...[1d])` and `sum by (dag_id)`.

- **DAG run dependency check time**  
  - **Meaning**: Time (milliseconds) the scheduler spends checking dependencies (upstream/downstream) for each DAG run.  
  - **Metric**: `af_agg_dagrun_dependency_check`.

---

## 📊 Postgres Overview dashboard

This dashboard monitors **PostgreSQL performance** used in the platform, via metrics from the Postgres exporter.

![grafana_postgres_dashboard](/image/grafana_postgres_dashboard.png)

### PostgreSQL overview

- **QPS (Queries per second)**  
  - **Meaning**: Total number of transactions (commit + rollback) per second → reflects current workload.  
  - **Metrics**: `pg_stat_database_xact_commit` and `pg_stat_database_xact_rollback` (using `irate`/`sum`).

- **Rows**  
  - **Meaning**: Read/write throughput: number of rows fetched/returned/inserted/updated/deleted over time.  
  - **Metrics**: `pg_stat_database_tup_*`:
    - `pg_stat_database_tup_fetched`
    - `pg_stat_database_tup_returned`
    - `pg_stat_database_tup_inserted`
    - `pg_stat_database_tup_updated`
    - `pg_stat_database_tup_deleted`

### I/O & bgwriter

- **Buffers**  
  - **Meaning**: Number of buffers allocated/cleaned/backend/checkpoint per second → reflects Postgres write/flush activity.  
  - **Metrics**: `pg_stat_bgwriter_buffers_*` (`buffers_alloc`, `buffers_clean`, `buffers_backend`, `buffers_backend_fsync`, `buffers_checkpoint`).

### Conflicts & cache

- **Conflicts/Deadlocks**  
  - **Meaning**: Number of deadlocks and conflicts in the database → helps detect locking/concurrency issues.  
  - **Metrics**: `pg_stat_database_deadlocks`, `pg_stat_database_conflicts`.

- **Cache hit ratio**  
  - **Meaning**: Percentage of reads served from buffer cache (hits) versus disk reads.  
  - **Metrics**: `pg_stat_database_blks_hit` and `pg_stat_database_blks_read`.

### Connections

- **Number of active connections**  
  - **Meaning**: Number of active connections to PostgreSQL per database.  
  - **Metric**: `pg_stat_database_numbackends`.

---

## 🚀 Usage

- Start the Grafana/Prometheus/Exporters stack:
  - `docker-compose -f docker-compose.grafana.yml up -d`
- Open Grafana (URL/port as configured in `docker-compose.grafana.yml`), and import:
  - `_002_src/monitoring/grafana/airflow-cluster-dashboard.json`
  - `_002_src/monitoring/grafana/postgresql-dashboard.json`
- Select the correct **Prometheus datasource** in Grafana so the dashboards start showing data.

## 📚 References
- [Airflow Dashboard Code Template](https://github.com/databand-ai/airflow-dashboards)
- [Postgres Exporter Code Template](https://github.com/prometheus-community/postgres_exporter)

