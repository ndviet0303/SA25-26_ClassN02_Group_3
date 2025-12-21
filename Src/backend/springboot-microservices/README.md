# Movie Microservice - Spring Boot

Microservice quản lý phim cho ứng dụng Nozie, được xây dựng theo **Layered Architecture**.

## 🏗️ Kiến trúc

```
┌─────────────────────────────────────────────────────────┐
│              Layer 1: Presentation (Controller)          │
│                    MovieController                        │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│          Layer 2: Business Logic (Service)               │
│              MovieService / MovieServiceImpl             │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│          Layer 3: Persistence (Repository)               │
│                   MovieRepository                         │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│              Layer 4: Data (Database)                     │
│                 H2 / PostgreSQL                           │
└─────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Java 17+
- Maven 3.8+

### Run Application

```bash
# Clone và di chuyển vào thư mục
cd Src/backend/springboot-microservices

# Build và run với Maven Wrapper
./mvnw spring-boot:run

# Hoặc với Maven đã cài đặt
mvn spring-boot:run
```

### Access Points

- **API Base URL:** http://localhost:8080/api/movies
- **H2 Console:** http://localhost:8080/h2-console
  - JDBC URL: `jdbc:h2:mem:moviedb`
  - Username: `sa`
  - Password: (empty)

## 📚 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/movies` | Create new movie |
| GET | `/api/movies` | Get all movies |
| GET | `/api/movies/{id}` | Get movie by ID |
| GET | `/api/movies/slug/{slug}` | Get movie by slug |
| PUT | `/api/movies/{id}` | Update movie |
| DELETE | `/api/movies/{id}` | Delete movie |
| GET | `/api/movies/search?q={keyword}` | Search movies |
| GET | `/api/movies/type/{type}` | Filter by type |
| GET | `/api/movies/trending` | Top trending |
| GET | `/api/movies/new` | New releases |
| GET | `/api/movies/free` | Free movies |

## 🧪 Test với cURL

### Create Movie

```bash
curl -X POST http://localhost:8080/api/movies \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Avengers: Endgame",
    "slug": "avengers-endgame",
    "type": "movie",
    "status": "completed",
    "year": 2019,
    "price": 4.99
  }'
```

### Get All Movies

```bash
curl http://localhost:8080/api/movies
```

### Get Movie by ID

```bash
curl http://localhost:8080/api/movies/1
```

## 📁 Cấu trúc Project

```
src/main/java/com/nozie/movieservice/
├── MovieServiceApplication.java    # Main entry point
├── config/
│   └── DataInitializer.java        # Sample data
├── controller/                      # Layer 1: Presentation
│   └── MovieController.java
├── service/                         # Layer 2: Business Logic
│   ├── MovieService.java
│   └── impl/
│       └── MovieServiceImpl.java
├── repository/                      # Layer 3: Persistence
│   └── MovieRepository.java
├── model/                           # Entity
│   └── Movie.java
├── dto/                             # Data Transfer Objects
│   └── MovieDTO.java
└── exception/                       # Exception handling
    ├── MovieNotFoundException.java
    ├── DuplicateSlugException.java
    └── GlobalExceptionHandler.java
```

## 🛠️ Tech Stack

- **Java 17**
- **Spring Boot 3.2**
- **Spring Data JPA**
- **H2 Database** (Development)
- **PostgreSQL** (Production)
- **Lombok**
- **Jakarta Validation**

## 📝 License

MIT License - ClassN02_Group_03

