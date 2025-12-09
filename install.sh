#!/bin/bash

PREFIX="[BadIP]"
export PATH="/usr/sbin:/sbin:/usr/bin:/bin"

clear
echo -e "
\e[38;5;93m    ██████╗  █████╗ ██████╗ ██╗██████╗ 
\e[38;5;129m    ██╔══██╗██╔══██╗██╔══██╗██║██╔══██╗
\e[38;5;135m    ██████╔╝███████║██║  ██║██║██████╔╝
\e[38;5;141m    ██╔══██╗██╔══██║██║  ██║██║██╔═══╝ 
\e[38;5;177m    ██████╔╝██║  ██║██████╔╝██║██║     
\e[38;5;183m    ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝     

\e[38;5;207m       BadIP Installer by MaksimovAV
\e[0m
"

sleep 1

function progress_bar() {
    bar="=================================================="
    max=50
    echo -ne "$PREFIX Loading: "
    for i in $(seq 1 $max); do
        printf "\r$PREFIX Loading: [%-50.${i}s] %d%%" "$bar" $((i*2))
        sleep 0.02
    done
    echo -e "\n"
}
progress_bar

function ensure_iptables_installed() {
    if command -v iptables >/dev/null 2>&1; then
        echo "$PREFIX iptables detected: $(iptables -V)"
        return 0
    fi

    echo "$PREFIX iptables not found. Install? (y/n)"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        if command -v apt >/dev/null 2>&1; then
            apt update -y && apt install -y iptables ip6tables
        elif command -v yum >/dev/null 2>&1; then
            yum install -y iptables iptables-services
        elif command -v apk >/dev/null 2>&1; then
            apk add iptables
        else
            echo "$PREFIX Unknown OS."
            exit 1
        fi
    else
        exit 1
    fi
}

function ensure_ipset_installed() {
    if command -v ipset >/dev/null 2>&1; then
        echo "$PREFIX ipset detected: $(ipset -v | head -n 1)"
        return 0
    fi

    echo "$PREFIX ipset not found. Install? (y/n)"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        if command -v apt >/dev/null 2>&1; then
            apt update -y && apt install -y ipset
        elif command -v yum >/dev/null 2>&1; then
            yum install -y ipset
        elif command -v apk >/dev/null 2>&1; then
            apk add ipset
        else
            echo "$PREFIX Unknown OS."
            exit 1
        fi
    else
        exit 1
    fi
}

ensure_iptables_installed
ensure_ipset_installed

echo "$PREFIX Initializing IP sets..."

ipset create myBlackhole-4 hash:net family inet -exist
ipset create myBlackhole-6 hash:net family inet6 -exist

if ! ipset list myBlackhole-4 >/dev/null 2>&1; then
    echo "$PREFIX ERROR: Failed to create ipset myBlackhole-4"
    exit 1
fi

function yep_ipset() {
    BAD_IPV4=$(curl -s https://raw.githubusercontent.com/MaksimovAV11/BadIP/proxies.txt)
    if [[ $? -ne 0 || -z "$BAD_IPV4" ]]; then
        echo "$PREFIX Failed to download IP list!"
        return 1
    fi

    echo "$PREFIX Adding IPs to ipset:"
    echo ""

    count=0
    while read -r ip; do
        [[ -z "$ip" ]] && continue
        ipset add myBlackhole-4 "$ip" -exist 2>/dev/null
        printf "\e[38;5;135m$PREFIX >> Adding %-20s...\e[0m\n" "$ip"
        ((count++))
    done <<< "$BAD_IPV4"

    echo ""
    echo "$PREFIX Added $count IPs to myBlackhole-4."
    return 0
}

function yep_iptables() {
    echo "$PREFIX Applying firewall rules..."

    iptables -C INPUT -m set --match-set myBlackhole-4 src -j DROP 2>/dev/null \
        || iptables -A INPUT -m set --match-set myBlackhole-4 src -j DROP

    if command -v ip6tables >/dev/null 2>&1; then
        ip6tables -C INPUT -m set --match-set myBlackhole-6 src -j DROP 2>/dev/null \
            || ip6tables -A INPUT -m set --match-set myBlackhole-6 src -j DROP
    fi

    echo "$PREFIX iptables rules applied."
    return 0
}

function setup_cron() {
    echo "$PREFIX Enable automatic update? (y/n)"
    read -r cron_answer

    if [[ "$cron_answer" =~ ^[Yy]$ ]]; then
        echo "$PREFIX Setting up cron job..."

        cat <<EOF >/usr/local/bin/badip-update.sh
#!/bin/bash
BAD_IPV4=\$(curl -s https://raw.githubusercontent.com/MaksimovAV11/BadIP/proxies.txt)
ipset flush myBlackhole-4
for ip in \$BAD_IPV4; do
    ipset add myBlackhole-4 \$ip -exist 2>/dev/null
done
EOF

        chmod +x /usr/local/bin/badip-update.sh
        (crontab -l 2>/dev/null; echo "0 */6 * * * bash /usr/local/bin/badip-update.sh >/dev/null 2>&1") | crontab -

        echo "$PREFIX Cron update enabled."
    else
        echo "$PREFIX Cron disabled."
    fi
}

if yep_ipset; then
    if yep_iptables; then
        echo "$PREFIX Firewall rules applied successfully!"
    else
        echo "$PREFIX Failed to configure iptables!"
    fi
else
    echo "$PREFIX Failed to generate ipset. Aborting."
    exit 1
fi

setup_cron

echo "$PREFIX BadIP system fully installed."
echo "$PREFIX Enjoy your firewall protection!"
