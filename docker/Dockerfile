# Boomi Molecule Runtime Dockerfile
FROM registry.hub.docker.com/boomi/molecule:latest

USER root

# Install required packages and setup JMX monitoring
RUN apk update && \
    apk upgrade && \
    apk add --no-cache wget curl jq && \
    mkdir -p /tmp && \
    mkdir -p /opt/scripts/ && \
    wget -O /tmp/jmx_prometheus_javaagent-0.20.0.jar https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.20.0/jmx_prometheus_javaagent-0.20.0.jar

# Copy configuration files and scripts
COPY config/jmx-config.yaml /tmp/
COPY scripts/node_offboard.sh /opt/scripts/
RUN chmod +x /opt/scripts/node_offboard.sh

# Switch back to boomi user for security
USER boomi

# Health check for container monitoring
HEALTHCHECK --interval=30s --timeout=10s --start-period=5m --retries=3 \
  CMD curl -f http://localhost:9090/_admin/liveness || exit 1

# Standard ports
EXPOSE 9090 8080 1099
