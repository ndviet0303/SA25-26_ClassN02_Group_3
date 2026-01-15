
# 🚀 Future Services: Scalability & Innovation

## 1. Streaming Service (Media Orchestrator)
Currently, video is delivered via CDN, but a dedicated service is needed for growth.

### A. Architectural Goals
- **Adaptive Bitrate Streaming (ABR)**: Automatically switching quality (480p, 720p, 1080p) based on network speed.
- **DRM Integration**: Working with Widevine/FairPlay for content protection.
- **Transcoding Pipeline**: Processing uploaded `.mp4` files into HLS/DASH segments (.ts files).

### B. Optimizations
- **CDN Selection**: Geo-aware logic to route users to the nearest edge server.
- **Pre-fetching**: Predicting the next segment to load to prevent buffering.

---

## 2. Recommendation Service (AI & Big Data)
To increase user retention through personalization.

### A. Data Pipeline
- **Activity Stream**: Consumes "Movie Viewed" events from RabbitMQ/Kafka.
- **Model Inference**: Using a pre-trained ML model (Python/TensorFlow) to predict interests.

### B. Optimization: Fallback System
- **Cold Start**: For new users, show "Global Trending" (from Movie Service).
- **Fallback**: If the AI model is slow or down, return cached "Popular in your Country" results.

---

## 3. Analytics Service (Data Insights)
- **Big Data Storage**: Moving historical logs to a **Data Lake** (e.g., S3/Hadoop) for long-term analysis.
- **Real-time Dashboards**: Using Grafana to monitor system health and business KPIs (Churn rate, Daily Active Users).
