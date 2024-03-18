---
title: 'Linux Server Database: CockroachDB (CRDB)'
breadcrumbs:
- title: Linux Server
---
{% include header.md %}

## Resources

- [Databases](/soft-eng/db/)

## Info

- A distributed, transactional, relational SQL DBMS.
- Designed to support:
    - Seemless scalability as load increases.
    - High availability across nodes, zones or regions.
    - Transactional isolation and consistency.
    - Good performance for low-latency and high-throughput workloads.
    - Geo-partitioning to store data in specific physical locations to support localized applications.
    - Compatibility with ANSI SQL and wire-protocol compatibility with PostgreSQL.
    - Portability between cloud-hosted environments, local servers, Kubernetes (operator) and more.
- It's a CP database, which prioritizes consistency over availability, meaning it may refuse to service requests in certain partitioning scenarios. The logo itself is based on the CP intersection in the CAP diagram, which looks a bit like a cockroach.
- Comparison to PostgreSQL:
    - Both use the same SQL (CRDB is wire compatible).
    - CRDB natively supports horizontal scaling, whereas PSQL typically scales vertically.
    - CRDB natively supports resilience due to clustering, whereas PSQL only supports active/passive that is hard to set up.
    - CRDB natively supports multi-region, unlike PSQL, for the above-mentioned reasons.

## Setup

**TODO**

## Usage

- Access web server: Go to port 8080 (default).
- Access local SQL client: `cockroach sql [--insecure]`

{% include footer.md %}
