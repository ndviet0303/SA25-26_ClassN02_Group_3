
# 👤 Customer Service: Subscription & Relationship Management

## 1. Domain
Maintains customer profiles, their subscription levels (FREE, VIP), and historical activity.

## 2. Event-Driven Sync
- **Subscription Update**: Listens for `PaymentSucceededEvent` from RabbitMQ.
- **Action**: Dynamically extends the `expired_at` date for the specific user and clears any cached subscription status.

## 3. Caching & Performance
- **Active Subscription Cache**: Since the Gateway needs to check if a user can watch a "VIP Movie", the `membershipStatus` is cached in **Redis**.
- **User Activity History**: Fast lookup for "Recently Watched" movies, optimized using PostgreSQL indexes on `user_id` and `timestamp`.

---

# 🔔 Notification Service: Async Engagement

## 1. Architecture
A pure **Consumer** service that reacts to system events.

## 2. Technical Strategy
- **Worker Pool**: Uses RabbitMQ Work Queues to handle thousands of notifications per second.
- **Template Caching**: Email/Push templates are pre-loaded in memory to avoid disk I/O.
- **Provider Abstraction**: Interfaces for different providers (SendGrid for Email, Firebase for Push).

## 3. Reliability
- **Dead Letter Queues (DLQ)**: If a notification fails (e.g., mail server down), it is moved to a DLQ for retry.
- **Deduplication**: Ensures a user doesn't receive the same "Payment Success" email twice if an event is processed twice.
