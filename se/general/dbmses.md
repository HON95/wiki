---
title: DBMSes
breadcrumbs:
- title: Software Engineering
- title: General
---
{% include header.md %}

A very brief comparison of different database management systems (DBMSes).

## Relational DBMSes

### General

- Most RDBMSes use their own variation of standard SQL, with both extra and missing features.

### SQLite

- Open-source.
- Lightweight and portable.
- Serverless and backed by a single file, which makes it very simple to configure and use.
- No users or access control.
- Low memory requirements, making it appropriate for memory constrained enviromnents.
- Limited concurrency, although multiple processes *can* read the DB file simultaneously.
- Can be used entirely in memory, e.g. for testing.

### MySQL

- Dual-licensed as open-source and proprietary. Acquired by Oracle Corporation.
- Very popular with a huge amount of community support and 3rd-party tools.
- Focused more on speed than SQL compliance.
- Server-based  with users and access control.
- Supports replication, for increased reliability and horizontal scaling.
- Not fully SQL compliant, lacking support for certain features.
- Limited support for replication.

### PostgreSQL

- Open-source and community-driven.
- Object-relational DBMS (ORDBMS).
- Server-based  with users and access control.
- Focused more on SQL compliance and features than speed.
- Better concurrent read-write performance than MySQL, but less performant for simple read-heavy traffic.

{% include footer.md %}
