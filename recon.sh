#!/bin/bash

echo "=== Subdomain Discovery Automation ==="
read -p "Enter target domain (e.g., python.org): " domain

if [ -z "$domain" ]; then
    echo "No domain entered. Exiting."
    exit 1
fi

raw_list="raw_subs.txt"
final_list="live_hosts.txt"

echo "[*] Scanning for subdomains..."
assetfinder --subs-only "$domain" | sort -u > "$raw_list"

echo "[+] Found $(wc -l < $raw_list) potential subdomains."
echo "[*] Checking which hosts are active..."

# Clear final list from previous runs
> "$final_list"

# Check each host
while read -r sub; do
    if [ -n "$sub" ]; then
        if curl -s --head --connect-timeout 2 "http://$sub" > /dev/null; then
            echo "[ALIVE] http://$sub"
            echo "http://$sub" >> "$final_list"
        fi
    fi
done < "$raw_list"

# Cleanup
rm "$raw_list"
echo "[+] Done! Active hosts saved to $final_list"
