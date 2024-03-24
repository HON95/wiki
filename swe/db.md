---
title: Databases
breadcrumbs:
- title: Software Engineering
---
{% include header.md %}

A very brief comparison of different database management systems (DBMSes).

## Theory

- ACID (for relational databases):
    - Atomicity (A): Each transaction from start to stop must be handled as a single unit and either be completely successful or completely rolled back. It can never be perceived as being "in progress" from another client, it must either be fully applied or not.
    - Consistency (C): All transactions must take the database from one consistent state to another consistent state. The database can never be in an inconsistent state even for very short periods. All defined rules such as constraints, cascades and triggers must be satisfied at all times.
    - Isolation (I): Transactions executed concurrently must not be visible to eachother. They must be applied as if they had been applied sequentially. (Often enforced through different levels of isolation.)
    - Durebility (D): Committed (completed) transactions must remain committed even in case of system failure. (Often enforced through write-ahead logging (WAL).)
- Eventual consistency (for NoSQL databases):
    - Aka. the BASE properties, in contrast to the ACID properties for relational databases.
    - For distributed databases, where each read will eventually receive the last updated value, i.e. with short-time gaps in consistency until the database _converges_ again.
    - Basically available (BA): The database is always (mostly?) available, at the cost of consistency.
    - Soft-state (S): As the database might not be in a converged state, the returned data only has a probability of being the last updated state.
    - Eventually consistent (E): A while after a set of writes, the reads must become consistent and return the same value for each read.
- CAP theorem (for distributed databases):
    - Consistency (C): Every read receives the most recent write or an error. (Defined slightly differently than in ACID.)
    - Availability (A): Every request receives a (non-error) response, without the guarantee that it contains the most recent write.
    - Partition tolerance (P): The system continues to operate despite an arbitrary number of messages being dropped (or delayed) by the network between nodes.
    - When the database gets partitioned due to connectivity issues, the you can only chose one of the following approaches:
        - CP: Cancel the operation and reduce availability, but ensure consistency.
        - AP: Proceed with the operation maintain availability, but risk inconsistency.
        - CA: Maintain both consistency and availability, but don't support designs which might suffer from partitioning (i.e. not distributed).
    - You can see that most distributed databases are classified as either CP or AP.
- Object-relational mapping (ORM):
    - A programming technique for converting data between a relational database and an object-oriented programming language.
- CRUD:
    - The four basic operations for persistant storage: create, read, update and delete.
    - SQL version: INSERT, SELECT, UPDATE, DELETE
    - REST version: POST/PUT, GET, PUT/PATCH, DELETE

## Relational Databases

- Based on tables consisting of rows and columns, and it thus apropriate for structured data.
- Heavily based on discrete mathematics and data science.
- Require the core properties atomicity, consistency, isolation and durability (ACID).
- Normalization is heavily used to remove data redundancy, but requires proper design by the user.
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

### CockrouchDB

- A distributed, transactional, relational SQL DBMS.
- See [Linux Server Database: CockroachDB](/linux-server/db-crdb/).

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
- While RDBMSes rely on strict consistency, NoSQL aims for eventual consistency, meaning it allows data changes to reach all database nodes in a short time rather than instantaneously. This means that the data received from the database(s) may in some cases be slightly outdated. See the note about eventual consistency above.

### Key-Value Stores

- Generally consists of an associative array of unstructured/blob values indexed by unique keys.
- Typically used for data caching and message queueing.
- Good for:
    - Caching
    - Pub/Sub
    - Leaderboards
- Examples:
    - Memcached
    - Redis

### Columnar-Oriented Databases

Aka. wide-column databases.

- Similar to RDBMSes, but splits all columns into different files. This allows for certain types of optimizations, which may improve both storage and querying for certain application types.
- Good for:
    - Time-series
    - Historical records
    - High-write, low-read
- Examples:
    - Apache Cassandra
    - Apache HBase

### Document-Oriented Databases

Aka. document stores.

- Often referred to as simply NoSQL.
- Stores semi-structured data like key-value pairs or blobs in documents, which are organized into ocollections.
- Simple to use and and quick to read from due to denormalization, so appropriate for unorganized data.
- Good for:
    - Most apps
    - Games
    - IoT
- Examples:
    - MongoDB
    - Couchbase
    - Apache CouchDB

### Graph Databases

- Document-oriented databases which use graph theory to relate documents.
- Useful for applications where relations in the data are of interest.
- Related to relational databases, but without schemas.
- Uses _nodes_ and _edges_ instead of rows (entities) and foreign keys (relations).
- Has simpler many-to-many relationships.
- Good for:
    - Graphs
    - Knowledge graphs
    - Recommendation engines
- Examples:
    - Neo4j
    - ArangoDB
    - OrientDB

### Full-Text Search Engine

- Good for:
    - Search engines
    - Typeahead
- Examples:
    - ElasticSearch
    - Algolia
    - Meilisearch

## Other Database Paradigms

### Multi-Model Database

- Combining multiple paradigms.
- For instance FaunaDB, which automatically figures out which paradigms work best by analysing the GraphQL code you provide to access it.

{% include footer.md %}
