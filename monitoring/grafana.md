---
title: Grafana
breadcrumbs:
- title: Monitoring
---
{% include header.md %}

For visualizing stuff.
Supports metrics backends like Prometheus, InfluxDB, MySQL etc.

## Setup (Docker)

1. (Note) See [(Grafana) Run Grafana Docker image](https://grafana.com/docs/grafana/latest/installation/docker/).
1. Mount:
    - Config: `./grafana.ini:/etc/grafana/grafana.ini:ro`
    - Data: `./data:/var/lib/grafana/:rw` (requires UID 472)
    - Logs: `./logs:/var/log/grafana/:rw` (requires UID 472)
1. Configure `grafana.ini`.
1. Open the webpage to configure it.

## Miscellanea

- Be careful with public dashboards. "Viewers" can modify any query and thus query the entire data source for the dashboard, unless you have configured some type of access control for the data source (which you probably haven't).
- If the Grafana metrics endpoint is enabled, make sure your reverse proxy blocks the metrics path `/metrics` to avoid leaking them.

{% include footer.md %}
