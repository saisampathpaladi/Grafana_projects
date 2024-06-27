#!/bin/bash

# Install dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https software-properties-common wget

# Add Grafana GPG key and repository
sudo wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Install Grafana
sudo apt-get update
sudo apt-get install -y grafana

# Start Grafana server
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Install Docker
sudo apt-get install -y docker.io

# Add current user to docker group
sudo usermod -aG docker $USER

# Reboot to apply Docker group changes
echo "Rebooting server to apply Docker group changes..."
sudo reboot

# After reboot, continue with Docker setup for Prometheus, Loki, and Promtail

# Create directories for Prometheus and Loki setups
mkdir -p /home/ubuntu/prometheus/data
mkdir -p /home/ubuntu/loki

# Download Prometheus and Loki configurations
wget https://raw.githubusercontent.com/prometheus/prometheus/main/documentation/examples/prometheus.yml -O /home/ubuntu/prometheus/prometheus.yml
wget https://raw.githubusercontent.com/grafana/loki/v3.0.0/cmd/loki/loki-local-config.yaml -O /home/ubuntu/loki/loki-config.yaml
wget https://raw.githubusercontent.com/grafana/loki/v3.0.0/clients/cmd/promtail/promtail-docker-config.yaml -O /home/ubuntu/loki/promtail-config.yaml

# Run Prometheus container
docker run -d --name prometheus -p 9090:9090 -v /home/ubuntu/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml -v /home/ubuntu/prometheus/data:/prometheus/data prom/prometheus

# Run Loki container
docker run -d --name loki -v /home/ubuntu/loki:/mnt/config -p 3100:3100 grafana/loki:3.0.0 -config.file=/mnt/config/loki-config.yaml

# Run Promtail container
docker run -d --name promtail -v /home/ubuntu/loki:/mnt/config -v /var/log:/var/log --link loki grafana/promtail:3.0.0 -config.file=/mnt/config/promtail-config.yaml

# Verify containers are running
echo "Prometheus, Loki, and Promtail containers are now running:"
docker container ls

# Display additional instructions
echo "====================================================="
echo "Grafana, Prometheus, Loki, and Promtail installation completed."
echo "Grafana URL: http://localhost:3000 (default credentials: admin/admin)"
echo "Prometheus is accessible at http://localhost:9090"
echo "Loki is accessible at http://localhost:3100"
echo "Promtail is configured to collect logs from /var/log directory."
echo "====================================================="
