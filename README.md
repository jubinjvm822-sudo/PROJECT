Markdown
# Network Reconnaissance and OSINT Project

**Prepared by:** Jubin Varghese Mathew  


---

## 1. Bash Automation for Live Host Discovery

### Objective
The objective of this phase is to automate the reconnaissance process by discovering subdomains of a target domain and identifying live hosts using custom scripting and open-source security tools.

### Tools Used
* **Bash:** For writing the automation pipeline.
* **Assetfinder:** To gather potential subdomains from public records.
* **Curl:** To verify if the discovered web targets are actively online.

### Methodology
1. **Input:** The script requests a target domain string from the user.
2. **Scan:** It runs assetfinder to query and compile potential subdomains passively.
3. **Clean:** It sorts the discovered entries and filters out duplicates.
4. **Test:** It loops through each subdomain, running a quick curl check to verify network responsiveness.
5. **Output:** Active hosts are saved to a separate log file, and temporary files are cleaned up.

### Bash Script (recon.sh)
```bash
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

> "$final_list"

while read -r sub; do
    if [ -n "$sub" ]; then
        if curl -s --head --connect-timeout 2 "http://$sub" > /dev/null; then
            echo "[ALIVE] http://$sub"
            echo "http://$sub" >> "$final_list"
        fi
    fi
done < "$raw_list"

rm "$raw_list"
echo "[+] Done! Active hosts saved to $final_list"
Results
Target Domain: python.org

Output Example (live_hosts.txt):

Plaintext
[http://africa.python.org](http://africa.python.org)
[http://analytics.python.org](http://analytics.python.org)
[http://blog-cn.python.org](http://blog-cn.python.org)
2. Network Scanning Report (Nmap)
We conducted host discovery, port scanning, and service version detection against an authorized lab target (10.10.10.45).

Commands and Flags Used
nmap -sn 10.10.10.45: Ping Sweep – Verifies if the host is active and reachable without scanning ports.

nmap -sS 10.10.10.45: SYN Stealth Scan – Identifies open TCP ports by sending half-open requests without creating a full handshake connection.

nmap -sV -p 22,80,443,8080 10.10.10.45: Service Version Detection – Probes open ports to identify exact software versions, helping assess known vulnerabilities.

Scan Results
Plaintext
$ nmap -sn 10.10.10.45
Starting Nmap 7.95 ( [https://nmap.org](https://nmap.org) ) at 2026-06-23 14:45 IST
Nmap scan report for 10.10.10.45
Host is up (0.00042s latency).

$ nmap -sS 10.10.10.45
Starting Nmap 7.95 ( [https://nmap.org](https://nmap.org) ) at 2026-06-23 14:47 IST
Nmap scan report for 10.10.10.45
Host is up (0.00038s latency).
Not shown: 996 closed ports
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
443/tcp  open  https
8080/tcp open  http-proxy

$ nmap -sV -p 22,80,443,8080 10.10.10.45
Starting Nmap 7.95 ( [https://nmap.org](https://nmap.org) ) at 2026-06-23 14:50 IST
Nmap scan report for 10.10.10.45
Host is up (0.00041s latency).
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.4 (Linux; protocol 2.0)
80/tcp   open  http    Apache httpd 2.4.52 ((Ubuntu))
443/tcp  open  https   Apache httpd 2.4.52
8080/tcp open  http    Apache Tomcat 9.0.58
Service Info: OS: Linux
Interpretation of Results
The target is active. The system runs on Ubuntu Linux, exposing an Apache web server (2.4.52) on ports 80 and 443, an Apache Tomcat server (9.0.58) on port 8080, and OpenSSH 8.9p1 on port 22 for administrative communication.

3. OSINT Footprinting Exercise
An OSINT footprinting exercise was completed on GitHub, Inc. using only publicly available information sources to collect domain infrastructure, DNS data, and technological details safely.

WHOIS Domain Information
Domain Name: github.com

Registrar: MarkMonitor Inc.

Registration Date: 2007-10-09

Expiration Date: 2028-10-09

Domain Status: clientDeleteProhibited, clientTransferProhibited

Name Servers: dns1.p01.nsone.net, ns-1251.awsdns-28.org

DNS Queries (nslookup & dig)
Plaintext
$ nslookup github.com
Name:   github.com
Address: 140.82.121.4
Interpretation: The apex domain routes back to active IP address 140.82.121.4, which forms part of GitHub's cloud block.

Technology Stack Fingerprinting
Web Server/CDN Network: Fastly CDN

Security Controls: Strict-Transport-Security (HSTS) deployed

UI Frameworks/Frontend: Web Components, JavaScript ES Modules

4. Documented Methodology
This project used a systematic information-gathering approach. We began with OSINT footprinting and passive subdomain hunting to gather domain assets and DNS records without directly contacting internal target systems. Next, we used a custom Bash script to automate active live-host verification. Finally, we performed network mapping using Nmap scanning tools within an authorized lab environment to identify active hosts, open ports, and service versions.

5. Conclusion
This project provided practical experience across the primary stages of cybersecurity reconnaissance, automation, network scanning, and OSINT footprinting. Writing the custom Bash script showed how automation can save manual effort and streamline asset collection. Using Nmap allowed for precise network mapping and host profiling within an authorized lab target. Finally, the OSINT exercise on GitHub demonstrated how valuable structural information can be gathered ethically using entirely public sources.

6. GitHub Repository
The automation script and structural reconnaissance files are tracked and documented at:

https://github.com/jubinjvm822-sudo/PROJECT.git
