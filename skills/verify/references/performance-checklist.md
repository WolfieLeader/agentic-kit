# Performance Checklist

Domain reference for verify extension reviewers. Load when reviewing code with database queries, API endpoints, rendering logic, or data-heavy operations.

## Database

- N+1 queries eliminated (use eager loading / joins / batch queries)
- Queries use indexes (check EXPLAIN for full table scans)
- Pagination on list endpoints (never unbounded SELECT)
- Connection pooling configured
- Transactions scoped minimally (no long-held locks)

## API & Network

- Response payloads right-sized (no over-fetching, use field selection)
- Compression enabled (gzip/brotli for responses > 1KB)
- Cache headers set appropriately (ETags, Cache-Control)
- Expensive computations behind queue/background jobs
- Timeouts set on all external HTTP calls

## Frontend

- Bundle size monitored (no accidental large dependency imports)
- Images: lazy loaded, appropriately sized, modern formats (WebP/AVIF)
- Critical rendering path: no render-blocking resources
- Virtualization for long lists (> 100 items)
- Debounced/throttled user input handlers

## General

- No synchronous I/O in hot paths
- Memory: no unbounded caches, no leaked event listeners
- Startup time: lazy initialization for non-critical subsystems
- Logging: structured, leveled, no verbose logging in hot paths
