
# 🧩 C4 Level 3 – Component Diagram (Movie Catalog Service)

## 1. Prompt (Detailed)
**Title:** "C4 Level 3: Advanced Component Architecture – Movie Catalog Service"

**Description:** 
"Visualize the internal architecture of the **Movie Catalog Service**, a critical core service of the Nozie platform. This diagram must go beyond simple CRUD, emphasizing a high-performance **Orchestration Layer** that coordinates multiple internal and external technical units."

**Technical Requirements for Visualization:**
- **Boundary Box:** A large container labeled 'Movie Catalog Service'.
- **Internal Components (The Orchestrator):**
    - `MovieController`: The entry point for validating JSON requests from the Front-end.
    - `MovieService (Orchestrator)`: the central brain. It handles business logic such as VIP/Free content checking and decides the data retrieval strategy.
- **Support Units:**
    - `CacheComponent`: A wrapper for **Redis** interaction, implementing the 'Cache-aside' pattern (Hit/Miss logic).
    - `SearchComponent`: A dedicated unit for full-text search and complex filtering (actors, genres, quality).
    - `MovieRepository`: The persistence manager for the primary database.
- **External Connections:**
    - Show `CacheComponent` connecting to an external **Redis** ring.
    - Show `SearchComponent` connecting to an external **Elasticsearch** cluster.
    - Show `MovieRepository` connecting to the **MongoDB** metadata store.

**Visual Aesthetic:** 3D Technical schematic. Highlight the priority-based flow (1. Cache -> 2. Search -> 3. Database) using distinct neon-colored data paths. Set against a sleek, dark professional tech background.

---

## 2. Technical Components Description
- **MovieController**: Validates incoming request parameters and maps the response to standard `ApiResponse` objects.
- **MovieService (Orchestrator)**: The heart of the service. It validates user permissions (e.g., preventing non-VIPs from accessing premium content) and manages the flow between cache, search, and database layers to ensure low latency.
- **CacheComponent**: Encapsulates Redis operations. It checks for hot data before hitting the database, significantly improving response times for trending movies.
- **SearchComponent**: Acts as a client for the search engine (Elasticsearch), providing high-speed search capabilities across millions of movie records and attributes.
- **MovieRepository**: Uses Spring Data to manage unstructured movie metadata within the MongoDB cluster.

---

## 3. PlantUML Diagram

```plantuml
@startuml
!include https://raw.githubusercontent.com/plantuml-office/C4-PlantUML/master/C4_Component.puml

LAYOUT_WITH_LEGEND()

title Component Diagram: Movie Catalog Service (Advanced Orchestration)

'--- External Containers ---
Container(gateway, "API Gateway", "Spring Cloud", "Entry Point & Security")
ContainerDb(redis, "Hot Data Store", "Redis 7.2", "Cache-aside repository")
ContainerDb(elastic, "Search Engine", "Elasticsearch", "Full-text searchable data")
ContainerDb(mongodb, "Metadata Store", "MongoDB 7.0", "Primary film document data")

'--- Internal Components ---
Container_Boundary(movie_svc, "Movie Catalog Service") {
    Component(ctrl, "MovieController", "Spring MVC", "Validates JSON & Maps Responses")
    Component(svc, "MovieService", "Spring Service", "Orchestrator: Logic, Role/VIP Checks")
    
    Component(cache_mgr, "CacheComponent", "Spring Component", "Redis Wrapper (Check/Update Cache)")
    Component(search_client, "SearchComponent", "Spring Component", "Elasticsearch Client (Complex Queries)")
    Component(repo, "MovieRepository", "Spring Data", "Primary DB Persistence Manager")
}

'--- Coordination Flows ---
Rel(gateway, ctrl, "API Requests", "HTTPS/JSON")
Rel(ctrl, svc, "Invokes Orchestration")

'-- 1. Cache Check
Rel(svc, cache_mgr, "1. Verify Cache Hit", "In-memory query")
Rel_Neighbor(cache_mgr, redis, "Query active cache", "RESP/6379")

'-- 2. Search Logic
Rel(svc, search_client, "2. Execute Full-text Search", "Complex Filter")
Rel(search_client, elastic, "Query Indexes", "REST/JSON")

'-- 3. Database Fallback
Rel(svc, repo, "3. Fetch Full Metadata (Cache Miss)", "Document Query")
Rel(repo, mongodb, "Read/Write", "TCP/27017")

'-- 4. Cache Update
Rel(cache_mgr, svc, "Return Hit", "Data")
@enduml
```
