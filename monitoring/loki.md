---
title: Grafana Loki
breadcrumbs:
- title: Monitoring
---
{% include header.md %}

For log collection.

## Info

- No ingestion log format requirements.
- Index-free (somewhat).
    - Meaning it indexes less data from log lines.
    - This gives a smaller index file and faster ingestion, but slower querying.
    - Specifically, the timestamp and a set of labels (key-value pairs) are indexed, but the content is unindexed.
- Prometheus-inspired query language.
- Typically uses Promtail for log collection from servers, sometimes with syslog-ng for log format conversion.
- Good integration with e.g. Kubernetes, Grafana and Prometheus.

{% include footer.md %}
