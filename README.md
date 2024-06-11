# Grafana Projects
This guide explains how to install Grafana, Loki, and Promtail on a Linux server, containerizing Loki and Promtail using Docker.

## Prerequisites
Ensure you have a Linux server with sudo privileges.
- Install Grafana
- Install Dependencies
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
- Create a directory called loki. Make loki your current working directory:
```
mkdir loki
cd loki
```
Copy and paste the following commands into your command line to download loki-local-config.yaml and promtail-docker-config.yaml to your loki directory.
```
wget https://raw.githubusercontent.com/grafana/loki/v3.0.0/cmd/loki/loki-local-config.yaml -O loki-config.yaml
wget https://raw.githubusercontent.com/grafana/loki/v3.0.0/clients/cmd/promtail/promtail-docker-config.yaml -O promtail-config.yaml
```
To to run the containers use the below commands
```
docker run --name loki -d -v $(pwd):/mnt/config -p 3100:3100 grafana/loki:3.0.0 -config.file=/mnt/config/loki-config.yaml
docker run --name promtail -d -v $(pwd):/mnt/config -v /var/log:/var/log --link loki grafana/promtail:3.0.0 -config.file=/mnt/config/promtail-config.yaml
```
### NOTE
The image is configured to run by default as user loki with UID 10001 and GID 10001. You can use a different user, specially if you are using bind mounts, by specifying the UID with a docker run command and using --user=UID with a numeric UID suited to your needs.
Verify that your containers are running:
```
docker container ls
```
You should see something similar to the following:
```
CONTAINER ID   IMAGE                    COMMAND                  CREATED              STATUS              PORTS                                       NAMES
9485de9ad351   grafana/promtail:3.0.0   "/usr/bin/promtail -…"   About a minute ago   Up About a minute                                               promtail
cece1df84519   grafana/loki:3.0.0       "/usr/bin/loki -conf…"   About a minute ago   Up About a minute   0.0.0.0:3100->3100/tcp, :::3100->3100/tcp   loki
```
Verify that Loki is up and running.
- To view readiness, navigate to http://localhost:3100/ready.
- To view metrics, navigate to http://localhost:3100/metrics.



