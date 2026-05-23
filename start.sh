#!/bin/bash
cd "$(dirname "$0")"

if [ ! -f "./omp-server" ]; then
  echo "omp-server belum ada. Jalankan setup-vps.sh dulu."
  exit 1
fi

chmod +x ./omp-server
./omp-server
