
# 🚫 BadIP — Lightweight IP Blackhole Firewall  
A simple and efficient Bash script that automatically downloads a list of malicious or suspicious IP addresses and blocks them using `ipset` + `iptables`.  
Perfect for filtering proxy networks, scanners, botnets, and low-level DDoS noise.

Author: **MaksimovAV**

---

# 🇬🇧 English Version

## ✨ Features
- Downloads IP list from `proxies.txt` (GitHub)
- Automatically creates IPSET sets:
  - `myBlackhole-4` — IPv4 blacklist  
  - `myBlackhole-6` — IPv6 blacklist
- Adds IPs to `ipset` in real-time with progress output
- Applies firewall rules using `iptables` and `ip6tables`
- Checks and installs `iptables` if missing
- Optional automatic update every 6 hours via CRON
- Beautiful colored output & progress bar

---

## 🛠 Supported Systems
BadIP works on:

- Debian / Ubuntu  
- CentOS / RHEL  
- Alpine Linux  
- Any Linux with `iptables` + `ipset`

---

## 🚀 Installation

### 1. Clone repository
```bash
git clone https://github.com/MaksimovAV11/BadIP.git
cd BadIP
````

### 2. Make script executable

```bash
chmod +x install.sh
```

### 3. Run installer

```bash
./install.sh
```

---

## 🔧 How It Works

### 1. iptables check

If not installed — script offers to install it automatically.

### 2. Creates ipset sets

```bash
ipset -N myBlackhole-4 hash:net family inet
ipset -N myBlackhole-6 hash:net family inet6
```

### 3. Downloads IP blacklist

```bash
curl -s https://raw.githubusercontent.com/MaksimovAV11/BadIP/proxies.txt
```

### 4. Adds IPs with realtime output

Each IP is added to the blacklist set with colored progress display.

### 5. Applies firewall rules

Blocks all traffic from blacklisted IPs:

```bash
iptables -A INPUT -m set --match-set myBlackhole-4 src -j DROP
```

### 6. Optional automatic updates

CRON updates the blacklist every 6 hours:

```bash
/usr/local/bin/badip-update.sh
```

---

## 🔄 Manual update

```bash
bash /usr/local/bin/badip-update.sh
```

---

## ⚠️ Note

BadIP **is not a full DDoS protection system**, but it effectively filters garbage traffic, public proxies, and part of botnets before they reach your application.

---

## 📁 Project Structure

```
BadIP/
├── install.sh         # Main installer script
└── proxies.txt        # Blacklisted IP list
```

---

## 📜 License

Free to use. Provided as-is.

---

## ❤️ Author

**MaksimovAV**
If you like the project, drop a ⭐ on GitHub!

---

---

# 🇷🇺 Русская версия

# 🚫 BadIP — Лёгкая система блокировки вредных IP

BadIP — простой и эффективный Bash-скрипт, который автоматически загружает список подозрительных IP и блокирует их через `ipset` и `iptables`.
Подходит для фильтрации прокси, сканеров, ботов и слабых DDoS-атак.

Автор: **MaksimovAV**

---

## ✨ Возможности

* Загружает список IP из `proxies.txt` (GitHub)
* Создаёт IPSET-наборы:

  * `myBlackhole-4` — чёрный список IPv4
  * `myBlackhole-6` — чёрный список IPv6
* Добавляет адреса в реальном времени
* Настраивает правила iptables/ip6tables
* Проверяет и при необходимости устанавливает iptables
* Автообновление каждые 6 часов через CRON
* Красивый цветной интерфейс и прогресс-бар

---

## 🛠 Поддерживаемые системы

* Debian / Ubuntu
* CentOS / RHEL
* Alpine Linux
* Любой Linux с поддержкой `iptables` + `ipset`

---

## 🚀 Установка

### 1. Клонируйте репозиторий

```bash
git clone https://github.com/MaksimovAV11/BadIP.git
cd BadIP
```

### 2. Сделайте файл исполняемым

```bash
chmod +x install.sh
```

### 3. Запустите установщик

```bash
./install.sh
```

---

## 🔧 Как это работает

### 1. Проверка наличия iptables

Если нет — предложит установить автоматически.

### 2. Создание наборов ipset

```bash
ipset -N myBlackhole-4 hash:net family inet
ipset -N myBlackhole-6 hash:net family inet6
```

### 3. Загрузка списка IP

```bash
curl -s https://raw.githubusercontent.com/MaksimovAV11/BadIP/proxies.txt
```

### 4. Добавление IP с выводом прогресса

Каждый IP добавляется в набор с визуальным выводом.

### 5. Настройка iptables

Полная блокировка трафика от вредных IP:

```bash
iptables -A INPUT -m set --match-set myBlackhole-4 src -j DROP
```

### 6. Опциональное автообновление

CRON обновляет список каждые 6 часов:

```bash
/usr/local/bin/badip-update.sh
```

---

## 🔄 Ручное обновление

```bash
bash /usr/local/bin/badip-update.sh
```

---

## ⚠️ Важно

BadIP **не является полноценной DDoS-защитой**, но отлично отфильтровывает мусорный трафик, ботов и публичные прокси до уровня приложения.

---

## 📁 Структура проекта

```
BadIP/
├── install.sh         # Основной установочный скрипт
└── proxies.txt        # Список вредных IP
```

---

## 📜 Лицензия

Свободное использование. Как есть.

---

## ❤️ Автор

**MaksimovAV**
Если проект полезен — ставь ⭐ на GitHub!

