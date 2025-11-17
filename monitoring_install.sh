#!/bin/bash
wget https://github.com/prometheus/prometheus/releases/download/v3.5.0/prometheus-3.5.0.linux-amd64.tar.gz
tar xvf prometheus-3.5.0.linux-amd64.tar.gz

# Create user/group
sudo groupadd --system prometheus || true
sudo useradd --system -s /sbin/nologin -g prometheus prometheus || true

# Move binaries
cd prometheus-3.5.0.linux-amd64/
sudo mv prometheus /usr/local/bin/
sudo mv promtool /usr/local/bin/

# Directories
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus

# Move other configs
sudo mv consoles /etc/prometheus/
sudo mv console_libraries /etc/prometheus/
sudo mv prometheus.yml /etc/prometheus/

sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus

# Prometheus config
# Change the node_exporter ip to the AWS ec2 IP
sudo tee /etc/prometheus/prometheus.yml >/dev/null <<'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
EOF


sudo tee /etc/systemd/system/prometheus.service >/dev/null <<'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now prometheus.service

cd ..



# Grafana
sudo apt-get install -y apt-transport-https software-properties-common wget

wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt update
sudo apt install -y grafana

sudo systemctl enable --now grafana-server


# Checks
sudo systemctl status grafana-server
prometheus --version