
# 🗄️ Data Architecture: Polyglot Persistence

Nozie utilizes the "Right Tool for the Right Job" principle for data storage.

## 1. Storage Selection
- **PostgreSQL (RMDB)**:
    - Used for: `Identity`, `Customer`, `Payment`.
    - Reasoning: Requires strict ACID compliance, complex relational queries, and transactional integrity.
- **MongoDB (NoSQL)**:
    - Used for: `Movie`, `Notification`.
    - Reasoning: Handles high-volume, semi-structured data (Movie metadata with varying fields) and high write throughput (Notification logs).
- **Redis (In-Memory)**:
    - Used for: Shared state, caching, rate limiting.

## 2. Consistency Model
- **Strong Consistency**: Within a single domain service (e.g., updating a User's password).
- **Eventual Consistency**: Across service boundaries using RabbitMQ (e.g., syncing a payment success to the subscription status).

## 3. Optimization Techniques
- **Indexing Strategy**:
    - Mongo: Compound indexes for searching (`title`, `genres`).
    - Postgres: B-Tree indexes on foreign keys and unique constraints.
- **Read/Write Splitting**: (Future Scope) Scaling read replicas for the Movie Database.
- **Sharding**: (Future Scope) Partitioning `Audit Logs` in Identity Service by time.
