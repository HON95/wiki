---
title: Database Management Systems (DBMSes)
breadcrumbs:
- title: Software Engineering
- title: General
---
{% include header.md %}

A very brief comparison of different database management systems (DBMSes).

## Relational DBMSes (RDBMSes)

- RDBMSes are based on tables consisting of rows and columns, and it thus apropriate for structured data.
- RDBMSes require the core properties atomicity, consistency, isolation and durability (ACID).
- Normalization is heavily used (by the user) to remove data redundancy.
- The need for consistency (and other properties) may hinder horizontal scaling.
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

## Object-Oriented DBMSes (OODBMSes)

- OODBMSes are based on objects from object-oriented programming and thus allows using a common representation and environment in both the application layer and database layer without the need for querying the data (unlike RDBMSes).

## Object-Relational DBMSes (ORDBMSes)

- ORDBMSes are a hybrid of OODBMSes and RDBMSes which contains features from both.
- Unline pure RDBMSes, they may support (e.g.) inheritance and custom data types.

### PostgreSQL

- Open-source and community-driven.
- Object-relational DBMS (ORDBMS).
- Server-based  with users and access control.
- Focused more on SQL compliance and features than speed.
- Better concurrent read-write performance than MySQL, but less performant for simple read-heavy traffic.

## NoSQL

- NoSQL is an umbrella term for non-relational DBMSes and thus consists of many different categories.
- It's aimed at non-structured data that wouldn't fit nicely in a (relational) table.
- OODBMSes may technically be considered NoSQL, but they often contain features which make them more similar to RDBMSes.
- While RDBMSes rely on strict consistency, NoSQL aims for eventual consistency, meaning it allows data changes to reach all database nodes in a short time rather than instantaneously. This means that the data received from the database(s) may in some cases be slightly outdated.

### Key-Value Stores

- Generally consists of an associative array of unstructured/blob values indexed by unique keys.
- Typically used for data caching and message queueing.
- Examples:
    - Memcached
    - Redis

### Columnar-Oriented Databases

- Similar to RDBMSes, but splits all columns into different files. This allows for certain types of optimizations, which may improve both storage and querying for certain application types.
- Examples:
    - Apache Cassandra
    - Apache HBase

### Document-Oriented Databases

- Aka document stores.
- A special type of key-value stores with documents as values, but contains metadata about the document as well.
- May allow nesting of documents.
- Examples:
    - MongoDB
    - Couchbase
    - Apache CouchDB

### Graph Databases

- Document-oriented databases which use graph theort to relate documents.
- Useful for applications where relations in the data are of interest.
- Examples:
    - Neo4j
    - ArangoDB
    - OrientDB

{% include footer.md %}
