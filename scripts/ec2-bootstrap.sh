#!/usr/bin/env bash
# =============================================================================
# MiniCloud - EC2 bootstrap (Ubuntu 22.04 LTS)
# Bật 4GB Swap + cài Docker Engine & Docker Compose plugin
# Cách dùng:  bash scripts/ec2-bootstrap.sh
# =============================================================================
set -euo pipefail

echo "==> [1/3] Kich hoat 4GB Swap RAM"
if swapon --show | grep -q '/swapfile'; then
  echo "    Swap da ton tai, bo qua."
else
  sudo fallocate -l 4G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  grep -q '^/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi
free -h

echo "==> [2/3] Cai Docker Engine + Compose plugin"
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sudo sh /tmp/get-docker.sh
fi
sudo usermod -aG docker "$USER"
sudo systemctl enable --now docker

echo "==> [3/3] Cong cu ho tro kiem thu (dig, curl, git)"
sudo apt-get update -y
sudo apt-get install -y dnsutils curl git

docker --version
docker compose version
echo ""
echo "XONG! Hay 'exit' roi SSH lai de quyen nhom docker co hieu luc."

