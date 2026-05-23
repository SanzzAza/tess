# Zynetra Roleplay Starter

Ini bukan freeroam. Ini starter base Roleplay untuk open.mp / SA-MP.

## Fitur
- MySQL login/register
- Inventory basic
- Admin system basic
- Faction basic
- Job system basic
- Dealership basic
- Rumah basic
- Mapping kota starter
- Speedometer filterscript
- Discord bot connect ke MySQL

## Struktur
```txt
gamemodes/zynetra-rp.pwn
filterscripts/mapping.pwn
filterscripts/speedometer.pwn
database/schema.sql
discord-bot/
setup-vps.sh
start.sh
config.json
```

## Upload ke GitHub
```bash
git init
git add .
git commit -m "init zynetra roleplay"
git branch -M main
git remote add origin https://github.com/USERNAME/zynetra-rp.git
git push -u origin main
```

## Run di VPS Ubuntu 22
```bash
cd /opt
git clone https://github.com/USERNAME/zynetra-rp.git
cd zynetra-rp
chmod +x setup-vps.sh start.sh
sudo ./setup-vps.sh
./start.sh
```

## Systemd auto start
```bash
sudo cp zynetra-rp.service /etc/systemd/system/zynetra-rp.service
sudo systemctl daemon-reload
sudo systemctl enable zynetra-rp
sudo systemctl restart zynetra-rp
sudo journalctl -u zynetra-rp -f
```

## Discord Bot
```bash
cd discord-bot
cp .env.example .env
nano .env
npm install
npm start
```

## Catatan penting
File plugin MySQL/sscanf/streamer `.so` belum disertakan karena biasanya beda versi.
Taruh plugin `.so` di folder `plugins/`, dan include `.inc` di `qawno/include/`.
