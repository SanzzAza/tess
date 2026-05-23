#!/bin/bash
set -e

echo "== Zynetra RP setup Ubuntu 22 =="

apt update
apt install -y git wget tar unzip curl mariadb-server mariadb-client \
  libc6:i386 libstdc++6:i386 libatomic1 libatomic1:i386

systemctl enable mariadb
systemctl start mariadb

DB_NAME="zynetra_rp"
DB_USER="samp_user"
DB_PASS="samp_password"

mysql -u root <<MYSQL
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1';
FLUSH PRIVILEGES;
MYSQL

mysql -u root ${DB_NAME} < database/schema.sql

if [ ! -f "omp-server" ]; then
  wget -O omp.tar.gz https://github.com/openmultiplayer/open.mp/releases/download/v1.5.8.3079/open.mp-linux-x86.tar.gz
  tar -xzf omp.tar.gz
  cp -r Server/* .
fi

chmod +x omp-server || true
chmod +x qawno/pawncc || true
chmod +x start.sh || true

echo "Compile gamemode..."
cd qawno
./pawncc ../gamemodes/zynetra-rp.pwn -iinclude -o../gamemodes/zynetra-rp.amx || true
./pawncc ../filterscripts/mapping.pwn -iinclude -o../filterscripts/mapping.amx || true
./pawncc ../filterscripts/speedometer.pwn -iinclude -o../filterscripts/speedometer.amx || true
cd ..

echo "Setup selesai. Jalankan: ./start.sh"
