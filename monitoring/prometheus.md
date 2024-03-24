---
title: Prometheus
breadcrumbs:
- title: Monitoring
---
{% include header.md %}

For metrics collection.

## Info

- Prometheus is a metrics collection platform based mainly on pull-style metrics collection.
- Metrics are generally exposed by applications in the Prometheus exposition format on some HTTP endpoint.
- See [OpenMetrics](https://openmetrics.io/) \[[spec](https://github.com/OpenObservability/OpenMetrics/blob/main/specification/OpenMetrics.md)\] for a more standardized version of the Prometheus exposition format.
- Metrics (typically?) contain a name, a label set and a numeric value (integer, floating-point or boolean).

## Setup (Docker)

Includes instructions for both the normal mode (aka server mode) and agent mode (no local storage).

1. (Note) See [(Prometheus) Installation](https://prometheus.io/docs/prometheus/latest/installation/).
1. (Server mode) Set CLI args:
    - Set retention time: `--storage.tsdb.retention.time=15d` (for 15 days)
    - Alternatively, set retention size: `--storage.tsdb.retention.size=100GB` (for 100GB)
    - (Note) The old `storage.local.*` and `storage.remote.*` flags no longer work.
1. (Agent mode) Set CLI args:
    - Enable: `--enable-feature=agent`
    - (Note) You can mount the data path, but it's a bit pointless wrt. how short-lived the data is.
1. Configure mounts:
    - Config: `./prometheus.yml:/etc/prometheus/prometheus.yml:ro`
    - Data (server mode): `./data/:/prometheus/:rw`
1. Configure `prometheus.yml`.
    - I.e. set global variables (like `scrape_interval`, `scrape_timeout` and `evaluation_interval`) and scrape configs.
1. (Optional) Setup Cortex or Thanos for global view, HA and/or long-term storage. **TODO:** See Grafana Mimir too.

## Notes

- Prometheus hierarchies and stuff:
    - High-availability: Simply run multiple instances in parallel, scraping the same targets.
    - Federation: Allows one instance to scrape specific metrics from another instance. May be used to forward metrics from a local to a global instance, but you may want to use remote write for that instead now. Also useful to to setup instances with a more limited view, e.g. for metrics accessible from some public Grafana dashboard.
    - Remote write: Used to forward metrics to an upstream instance. Prometheus Agent uses this to forward all metrics instead of storing them locally. Typically the remote instance is a Cortex or Mimir instance.
    - Remote read: Used to query another Prometheus instance. Generally as a reversed alternative to the remote write approach.
- The agent mode disables local metrics storage, for cases where you just want to forward the metrics upstream to e.g. a centralized Grafana Mimir instance. It uses the remote write feature of Prometheus. The normal TSDB is replaced by a simpler Agent TSDB WAL, which stores data temporarily until it's successfully written upstream. In practice, this turns Prometheus into a pull-to-push-based proxy. This also preserves separation of concerns since the upstream/central instance doesn't need to know what and where to scrape (as well as the mess of firewall and ACLs rules the alternative would entail). The agent mode (aka Prometheus Agent) is based on the older Grafana Agent.
- Prometheus currently uses the Prometheus exposition format v0.0.4 to ingest metrics into Prometheus. It later gave rise to the OpenMetrics metrics format.
- The open port (9090 by default) contains both the dashboard and the query API. It has no authentication mechanism, so you don't want this exposed publicly.
- You can check the status of scrape jobs in the dashboard.
- Prometheus does not store data forever, it's meant for short- to mid-term storage.
- Prometheus should be "physically" close to the apps it's monitoring. For large infrastructures, you should use multiple instances, not one huge global instance.
- If you need a "global view" (when using multiple instances), long-term storage and (in some way) HA, consider using Cortex or Thanos.
- Since Prometheus receives an almost continuous stream of telemetry, any restart or crash will cause a gap in the stored data. Therefore you should generally always use some type of HA in production setups.
- Cardinality is the number of time series. Each unique combination of metrics and key-value label pairs (yes, including the label value) amounts to a new time series. Very high cardinality (i.e. over 100 000 series, number taken from a Splunk presentation from 2019) amounts to significantly reduced performance and increased memory and resource usage, which is also shared by HA peers (fate sharing). Therefore, avoid using valueless labels, add labels only to metrics they belong with, try to limit the numer of unique values of a label and consider splitting metrics to use less labels. Some useful queries to monitor cardinality: `sum(scrape_series_added) by (job)`, `sum(scrape_samples_scraped) by (job)`, `prometheus_tsdb_symbol_table_size_bytes`, `rate(prometheus_tsdb_head_series_created_total[5m])`, `sum(sum_over_time(scrape_series_added[5m])) by (job)`. You can also find some useful stats in the dashboard.

## Cortex and Thanos

**TODO:** This is outdated, see Grafana Mimir instead (based on Cortex).

- Two similar projects, which both provide global view, HA and long-term storage.
- Cortex is push-based using Prometheus remote writing, while Thanos is pull-based using Thanos sidecars for all Prometheus instances.
- Global view: Cortex stores all data internally, while Thanos queries the Prometheus instances.
- Prometheus HA: Cortex stores one instance of the received data (at write time), while Thanos queries Prometheus instances which have data (at query time). Both approaches removes gaps in the data.
- Long-term storage: Cortex periodically flushes the NoSQL index and chunks to an external object store, while Thanos uploads TSDB blocks to an object store.

## Prometheus Exporters

### General

- Exporters often expose the metrics endpoint over plain HTTP without any scraper or exporter authentication. Prometheus supports exporters using HTTPS for scraping (for integrity, confidentiality and authenticating the Prometheus), as well as using client authentication (from Prometheus, for authenticating Prometheus), providing mutual authentication if both are used. This may require setting up a reverse web proxy in front of the exporter. Therefore, the simplest alternative (where appropriate) is often to just secure the network itself using segmentation and segregation.

### List of Exporters and Software

This list contains exporters and software with built-in exposed metrics I typically use. Some are described in more detail in separate subsections.

#### Software with exposed metrics

- Prometheus (exports metrics about itself)
- [Grafana](https://grafana.com/docs/grafana/latest/administration/metrics/)
- [Docker Daemon](https://docs.docker.com/config/daemon/prometheus/)
- [Traefik](https://github.com/containous/traefik)
- [AWX](https://docs.ansible.com/ansible-tower/latest/html/administration/metrics.html)

#### Exporters

- [Node exporter (Prometheus)](https://github.com/prometheus/node_exporter)
- [Windows exporter (Prometheus Community)](https://github.com/prometheus-community/windows_exporter)
- [SNMP exporter (Prometheus)](https://github.com/prometheus/snmp_exporter)
- [IPMI exporter (Soundcloud)](https://github.com/soundcloud/ipmi_exporter)
- [NVIDIA DCGM exporter (NVIDIA)](https://github.com/NVIDIA/gpu-monitoring-tools/)
- [NVIDIA GPU exporter (mindprince)](https://github.com/mindprince/nvidia_gpu_prometheus_exporter)
- [cAdvisor (Google)](https://github.com/google/cadvisor)
- [UniFi exporter (jessestuart)](https://github.com/jessestuart/unifi_exporter)
- [BIND exporter (Prometheus Community)](https://github.com/prometheus-community/bind_exporter)
- [Blackbox exporter (Prometheus)](https://github.com/prometheus/blackbox_exporter)
- [Prometheus Proxmox VE exporter (prometheus-pve)](https://github.com/prometheus-pve/prometheus-pve-exporter)
- [NUT Exporter (HON95)](https://github.com/HON95/prometheus-nut-exporter)
- [ESP8266 DHT Exporter (HON95)](https://github.com/HON95/prometheus-esp8266-dht-exporter)

#### Special

- [Pushgateway (Prometheus)](https://github.com/prometheus/pushgateway)

## Prometheus Node Exporter

Can be set up either using Docker ([prom/node-exporter](https://hub.docker.com/r/prom/node-exporter/)), using the package manager (`prometheus-node-exporter` on Debian), or by building it from source. The Docker method provides a small level of protection as it's given only read-only system access. The package version is almost always out of date and is typically not optimal to use. If Docker isn't available and you want the latest version, build it from source.

### Setup (Downloaded Binary)

See [Building and running](https://github.com/prometheus/node_exporter#building-and-running (node_exporter)).

Details:

- User: `prometheus`
- Binary file: `/usr/bin/prometheus-node-exporter`
- Service file: `/etc/systemd/system/prometheus-node-exporter.service`
- Configuration file: `/etc/default/prometheus-node-exporter`
- Textfile directory: `/var/lib/prometheus/node-exporter/`

Instructions:

1. Install requirements: `apt install moreutils`
1. Find the link to the latest tarball from [the download page](https://prometheus.io/download/#node_exporter).
1. Download and unzip it: `wget <url>` and `tar xvf <file>`
1. Move the binary to the system: `cp node_exporter*/node_exporter /usr/bin/prometheus-node-exporter`
1. Make sure it's runnable: `node_exporter -h`
1. Add the user: `useradd -r prometheus`
    - If you have hidepid setup to hide system process details from normal users, remember to add the user to a group with access to that information. This is only required for some metrics, most of them work fine without this extra access.
1. Create the required files and directories:
    - `touch /etc/default/prometheus-node-exporter`
    - `mkdir -p /var/lib/prometheus/node-exporter/`
1. Create the systemd service `/etc/systemd/system/prometheus-node-exporter.service`, see [prometheus-node-exporter.service](/monitoring/files/prometheus-node-exporter.service.txt).
1. (Optional) Configure it:
    - The defaults work fine.
    - File: `/etc/default/prometheus-node-exporter`
    - Example: `ARGS="--collector.processes --collector.interrupts --collector.systemd"` (enables more detailed process and interrupt collectors)
1. Enable and start the service: `systemctl enable --now prometheus-node-exporter`
1. (Optional) Setup textfile exporters.

### Textfile Collector

#### Setup and Usage

1. Set the collector script output directory using the CLI argument `--collector.textfile.directory=<dir>`.
    - Example dir: `/var/lib/prometheus/node-exporter/`
    - If the node exporter was installed as a package, it can be set in the `ARGS` variable in `/etc/default/prometheus-node-exporter`.
    - If using Docker, the CLI argument specified as part of the command.
1. Download the collector scripts and make them executable.
    - Example dir: `/opt/prometheus/node-exporter/textfile-collectors/`
1. Add cron jobs for the scripts using sponge to wrote to the output dir.
    - Make sure `sponge` is installed. For Debian, it's found in the `moreutils` package.
    - Example cron file: `/etc/cron.d/prometheus-node-exporter-textfile-collectors`
    - Example cron entry: `0 * * * * root /opt/prometheus/node-exporter/textfile-collectors/apt.sh | sponge /var/lib/prometheus/node-exporter/apt.prom`

#### Collector Scripts

Some I typically use.

- [apt.sh (Prometheus Community)](https://github.com/prometheus-community/node-exporter-textfile-collector-scripts/blob/master/apt.sh)
- [yum.sh (Prometheus Community)](https://github.com/prometheus-community/node-exporter-textfile-collector-scripts/blob/master/yum.sh)
- [deleted_libraries.sh (Prometheus Community)](https://github.com/prometheus-community/node-exporter-textfile-collector-scripts/blob/master/deleted_libraries.py)
- [ipmitool (Prometheus Community)](https://github.com/prometheus-community/node-exporter-textfile-collector-scripts/blob/master/ipmitool) (requires ipmitool) (**Warning:** This is slow, don't run it frequently. If you do, it may spawn more and more processes waiting to read the IPMI sensors. Run it manually to get a feeling.)
- [smartmon.sh (Prometheus Community)](https://github.com/prometheus-community/node-exporter-textfile-collector-scripts/blob/master/smartmon.sh) (requires smartctl)
- [My own textfile exporters](https://github.com/HON95/prometheus-textfile-exporters)

## Prometheus Blackbox Exporter

### Monitor Service Availability

Add a HTTP probe job for the services and query for probe success over time.

Example query: `avg_over_time(probe_success{job="node"}[1d]) * 100`

### Monitor for Expiring Certificates

Add a HTTP probe job for the services and query for `probe_ssl_earliest_cert_expiry - time()`.

Example alert rule: `probe_ssl_earliest_cert_expiry{job="blackbox"} - time() < 86400 * 30` (30 days)

{% include footer.md %}
