
# 🚦 Quick Start Guide: Observability Stack

## 1. Visualization (Grafana) - http://localhost:3000
**Primary tool for monitoring health and performance.**
- **Login**: `admin` / `admin`.
- **Setup Dashboard**:
    1. Click **Dashboards** icon -> **New** -> **Import**.
    2. Enter ID: **`11378`** (JVM MicroMeter Dashboard).
    3. Select **Prometheus** as the datasource.
    4. Click **Import**.
- **What to look for**: Request rates, Latency (P99), Thread usage, and Heap Memory.

## 2. Distributed Tracing (Zipkin) - http://localhost:9411
**Used for debugging slow requests or cross-service failures.**
- **Usage**:
    1. Perform actions in the Nozie app.
    2. Go to Zipkin and click **Run Query**.
    3. Click on a trace to see the hierarchical "Timeline" of the request.
    4. Identify which service is causing the bottleneck.

## 3. Metrics Scraper (Prometheus) - http://localhost:9090
**The engine that collects data. Use it to check connectivity.**
- **Check Targets**: Go to **Status** -> **Targets**. Ensure all microservices are **UP**.
- **Raw Queries**: Type `logback_events_total` to see error counts or `process_cpu_usage` for CPU load.

## 4. Developer Logs (Correlation IDs)
**Identify requests across distributed log files.**
- **Format**: `[service, traceId, spanId]`
- **Power Move**: Copy a `traceId` from a console log and paste it into **Zipkin** to see the visual flow of that specific request.
