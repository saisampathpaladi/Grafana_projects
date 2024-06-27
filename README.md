# Grafana Projects
This guide explains how to install Grafana, Loki, and Promtail on a Linux server, containerizing Loki and Promtail using Docker.

## Prerequisites
Ensure you have a Linux server with sudo privileges.
- Install Grafana
- Install Dependencies

# This is automated installation of grafana here use this 
### Explanation:

1. **Shell Script Updates**:
   - Added Prometheus setup: Creates directories, downloads configuration (`prometheus.yml`), and runs Prometheus Docker container.
   - Loki and Promtail setup remains unchanged from the previous script.

2. **README Template Updates**:
   - Provides step-by-step installation instructions for Grafana, Prometheus, Loki, and Promtail.
   - Includes URLs for accessing Grafana, Prometheus, and Loki post-installation.
   - Mentions default credentials for Grafana.

### Usage:

1. **Shell Script**:
   - Save the script as `install_grafana_prometheus_loki.sh`.
   - Make it executable: `chmod +x install_grafana_prometheus_loki.sh`.
   - Run the script with sudo: `sudo ./install_grafana_prometheus_loki.sh`.

This setup automates the installation and configuration of Grafana, Prometheus, Loki, and Promtail using Docker containers, providing a straightforward setup process and clear documentation for users. Adjust paths and configurations as needed for your specific environment.
=====================================================
# You can also use this manual steps below:
### Installation 
```
sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
sudo wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
```
### Stable release installation of grafana
```
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
```
# Update the list of available packages
```
sudo apt-get update
sudo apt-get install grafana
```
# To start Grafana Server
```
sudo /bin/systemctl status grafana-server
sudo /bin/systemctl start grafana-server
sudo /bin/systemctl enable grafana-server
```
# Install loki and promtail via docker 
### so install docker
```
sudo apt-get install docker.io

sudo usermod -aG docker $USER
```
#reboot server to make the changes active
```
sudo reboot 
```
### Install with Docker on Linux
# Create directories for Prometheus and Loki configurations
```
mkdir -p /home/ubuntu/prometheus/data
mkdir -p /home/ubuntu/loki
```
Copy and paste the following commands into your command line to download loki-local-config.yaml and promtail-docker-config.yaml to your loki directory.
```
wget https://raw.githubusercontent.com/grafana/loki/v3.0.0/cmd/loki/loki-local-config.yaml -O loki-config.yaml
wget https://raw.githubusercontent.com/grafana/loki/v3.0.0/clients/cmd/promtail/promtail-docker-config.yaml -O promtail-config.yaml
wget https://raw.githubusercontent.com/prometheus/prometheus/main/documentation/examples/prometheus.yml -O /home/ubuntu/prometheus/prometheus.yml
```
To to run the containers use the below commands
```
docker run --name loki -d -v $(pwd):/mnt/config -p 3100:3100 grafana/loki:3.0.0 -config.file=/mnt/config/loki-config.yaml
docker run --name promtail -d -v $(pwd):/mnt/config -v /var/log:/var/log --link loki grafana/promtail:3.0.0 -config.file=/mnt/config/promtail-config.yaml
docker run -d --name prometheus -p 9090:9090 -v /home/ubuntu/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml -v /home/ubuntu/prometheus/data:/prometheus/data prom/prometheus
```
### NOTE
The image is configured to run by default as user loki with UID 10001 and GID 10001. You can use a different user, specially if you are using bind mounts, by specifying the UID with a docker run command and using --user=UID with a numeric UID suited to your needs.
Verify that your containers are running:
```
docker container ls
```
You should see something similar to the following: also note it have 3 containers running instead of 2 I have update readme
```
CONTAINER ID   IMAGE                    COMMAND                  CREATED              STATUS              PORTS                                       NAMES
9485de9ad351   grafana/promtail:3.0.0   "/usr/bin/promtail -…"   About a minute ago   Up About a minute                                               promtail
cece1df84519   grafana/loki:3.0.0       "/usr/bin/loki -conf…"   About a minute ago   Up About a minute   0.0.0.0:3100->3100/tcp, :::3100->3100/tcp   loki
```
Verify that Loki is up and running.
- To view readiness, navigate to http://localhost:3100/ready.
- To view metrics, navigate to http://localhost:3100/metrics.



