#!/bin/bash

PREFIX="[BadIP]"

clear
echo -e "
\e[38;5;93m     ██████╗  █████╗ ██████╗ ██╗██████╗ 
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
        return 0
    fi

    echo "$PREFIX iptables is not installed. Install it now? (y/n)"
    read -r answer

    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        echo "$PREFIX Installing iptables..."

        if command -v apt >/dev/null 2>&1; then
            apt update -y && apt install -y iptables ip6tables
        elif command -v yum >/dev/null 2>&1; then
            yum install -y iptables iptables-services
        elif command -v apk >/dev/null 2>&1; then
            apk add iptables
        else
            echo "$PREFIX Unknown OS. Install iptables manually."
            exit 1
        fi
        echo "$PREFIX iptables installed successfully."
    else
        echo "$PREFIX iptables is required. Exiting."
        exit 1
    fi
}

function yep_ipset() {
    BAD_IPV4=$(curl -s https://raw.githubusercontent.com/MaksimovAV11/BadIP/proxies.txt)

    if [[ $? -ne 0 || -z "$BAD_IPV4" ]]; then
        echo "$PREFIX Failed to download IP list!"
        return 1
    fi

    echo "$PREFIX Adding IPs to ipset (real-time stream):"
    echo ""

    count=0
    for ip in $BAD_IPV4; do
        ipset -A myBlackhole-4 "$ip" 2>/dev/null
        printf "\e[38;5;135m$PREFIX >> Adding %-20s...\e[0m\n" "$ip"
        sleep 0.001
        ((count++))
    done

    echo ""
    echo "$PREFIX Added $count IPs to myBlackhole-4."
    return 0
}

function yep_iptables() {
    iptables -C INPUT -m set --match-set myBlackhole-4 src -j DROP 2>/dev/null \
        || iptables -A INPUT -m set --match-set myBlackhole-4 src -j DROP

    if command -v ip6tables >/dev/null 2>&1; then
        ip6tables -C INPUT -m set --match-set myBlackhole-6 src -j DROP 2>/dev/null \
            || ip6tables -A INPUT -m set --match-set myBlackhole-6 src -j DROP
    fi
    return 0
}

function setup_cron() {
    echo "$PREFIX Enable automatic daily update of bad IP list? (y/n)"
    read -r cron_answer

    if [[ "$cron_answer" == "y" || "$cron_answer" == "Y" ]]; then
        echo "$PREFIX Setting up cron job..."

        (crontab -l 2>/dev/null; echo "0 */6 * * * bash /usr/local/bin/badip-update.sh >/dev/null 2>&1") | crontab -

        cat <<EOF >/usr/local/bin/badip-update.sh
#!/bin/bash
BAD_IPV4=\$(curl -s https://raw.githubusercontent.com/MaksimovAV11/BadIP/proxies.txt)

ipset flush myBlackhole-4

for ip in \$BAD_IPV4; do
    ipset -A myBlackhole-4 \$ip 2>/dev/null
done
EOF

        chmod +x /usr/local/bin/badip-update.sh

        echo "$PREFIX Cron auto-update enabled (every 6 hours)."
    else
        echo "$PREFIX Cron auto-update disabled."
    fi
}

ensure_iptables_installed

ipset -N myBlackhole-4 hash:net family inet 2>/dev/null
ipset -N myBlackhole-6 hash:net family inet6 2>/dev/null

if yep_ipset; then
    if yep_iptables; then
        echo "$PREFIX Firewall rules applied successfully!"
    else
        echo "$PREFIX Failed to configure iptables!"
    fi
else
    echo "$PREFIX Failed to generate ipset. Aborting."
fi

setup_cron

echo "$PREFIX BadIP system fully installed."
echo "$PREFIX Enjoy your firewall protection!"
