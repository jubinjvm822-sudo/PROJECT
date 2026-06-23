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
```

##Results
**Target Domain: python.org**
**Output Example (live_hosts.txt):**
[http://africa.python.org](http://africa.python.org)
[http://analytics.python.org](http://analytics.python.org)
[http://blog-cn.python.org](http://blog-cn.python.org)

---


## 2. Network Scanning Report (Nmap)

### Objective
The objective of this phase is to perform active host discovery, port scanning, and service version fingerprinting against an authorized lab target to map open entry points and system environments.

### Tools Used
* **Nmap:** For network infrastructure exploration, state detection, and service profiling.

### Methodology
1. **Host Verification:** Execute a fast ping sweep to ensure the target machine is active on the network segment.
2. **Port State Analysis:** Launch a stealth TCP SYN scan against the standard ports to identify open listening ports.
3. **Application Interrogation:** Probe verified open ports with protocol banners to map application layer service names and versions.

### Commands and Flags Used
* `nmap -sn 10.10.10.45`: **Ping Sweep** – Verifies if the host is active and reachable without scanning individual ports.
* `nmap -sS 10.10.10.45`: **SYN Stealth Scan** – Identifies open TCP ports by checking for initial connection handshakes without establishing complete connections.
* `nmap -sV -p 22,80,443,8080 10.10.10.45`: **Service Version Detection** – Probes open communication channels to extract application version data, narrowing down potential software vulnerabilities.

### Scan Results
```text
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
```
###Interpretation of Results
**The network scan confirms that the target lab host is live and responding. Operating system fingerprinting indicates an underlying Ubuntu Linux environment. The system exposes an standard web application stack: Apache HTTP Server (2.4.52) handling traditional web services on ports 80 and 443, an Apache Tomcat server (9.0.58) active on port 8080, and an open OpenSSH 8.9p1 deployment on port 22 designated for secure administrative access.**


---

## 3. OSINT Footprinting Exercise

### Objective
The objective of this phase is to safely collect public domain infrastructure configurations, authoritative DNS mappings, and frontend architecture characteristics for a target platform using non-intrusive open-source intelligence methods.

### Tools Used
* **WHOIS Utilities:** For exploring registry creation timelines, expiration data, and operational name servers.
* **Nslookup / Dig:** For evaluating structural IPv4 resolution records.
* **Passive Stack Analysis:** For identifying public edge servers and delivery interfaces without direct engagement.

### Methodology
1. **Domain Registration Analysis:** Query public registrar databases using WHOIS to map domain lifespan, current registry status, and primary nameservers.
2. **DNS Record Interrogation:** Use command-line utilities to perform forward network lookup routing maps for apex assets.
3. **Infrastructure Fingerprinting:** Evaluate public header configurations and CDN endpoints to classify frontend technology assets dynamically.
		
### WHOIS Domain Information
| Record Property | Collected Value Details |
| :--- | :--- |
| **Domain Name** | github.com |
| **Registrar** | MarkMonitor Inc. |
| **Registration Date** | 2007-10-09 |
| **Expiration Date** | 2028-10-09 |
| **Domain Status** | clientDeleteProhibited, clientTransferProhibited |
| **Name Servers** | dns1.p01.nsone.net, ns-1251.awsdns-28.org |

### DNS Queries (nslookup & dig)
```text
$ nslookup github.com
Name:    github.com
Address: 140.82.121.4

I###nterpretation: 

**The apex domain resolves directly to the active IPv4 target address 140.82.121.4, confirming active public routing paths via GitHub's assigned autonomous system network boundaries.**



###Technology Stack Fingerprinting

**Web Server/CDN Network: Fastly Content Delivery Network (CDN) **

**Security Controls: Strict-Transport-Security (HSTS) configuration verified**

**AUI Frameworks/Frontend: Native Web Components, JavaScript ES Modules**

---
```
## 4. Documented Methodology

### Objective
The objective of this phase is to establish a systematic, reproducible blueprint for the entire information-gathering, automation, and vulnerability assessment workflow.

### Tools Used
* **Passive Intelligence Tools:** WHOIS, Nslookup, Dig (For initial asset identification).
* **Automation Engines:** Bash, Assetfinder, Curl (For active subdomain filtering).
* **Active Probing Utility:** Nmap (For deep network-layer and transport-layer auditing).

### Methodology
1. **Passive Information Gathering:** Initial footprinting began with open-source WHOIS and public DNS querying to identify root authority layers safely without generating traffic logs.
2. **Reconnaissance Automation:** Developed and launched a custom Bash pipeline integrating `assetfinder` and `curl` to dynamically isolate valid, responsive subdomains from broader record groups.
3. **Active Lab Mapping:** Deployed precise `Nmap` probing sequences within an authorized lab environment to determine active ports, firewall behaviors, and concrete software versions on target endpoints.

### Summary Matrix
| Phase | Focus Layer | Principal Tool Deployed | Core Objective |
| :--- | :--- | :--- | :--- |
| **Phase 1: OSINT** | Public Metadata | WHOIS / Nslookup | Boundary Mapping |
| **Phase 2: Automation** | Subdomain Infrastructure | Bash Script (`recon.sh`) | Live Host Isolation |
| **Phase 3: Scanning** | Transport & Service Layer | Nmap Suite | Software Version Identification |

---

## 5. Conclusion

### Objective
The objective of this phase is to evaluate the operational outcomes of the security lifecycle assessment and summarize the core security posture metrics observed.

### Key Takeaways
* **Automation Efficiency:** Custom Bash development demonstrates how manual target sorting can be minimized to improve operational speed.
* **Proactive Mapping:** Precision scanning with Nmap validates that accurate service profiling is foundational for identifying vulnerable network entry points.
* **Intelligence Gathering:** Passive OSINT mapping proves that critical external corporate structural data can be systematically acquired without direct threat generation.

### Summary Metrics
| Evaluation Category | Target Group | Primary Security Metric | Status |
| :--- | :--- | :--- | :--- |
| **Process Automation** | python.org subdomains | Automated Active Filtering | Successful |
| **Network Probing** | 10.10.10.45 (Lab) | Version Banner Isolation | Complete |
| **Public Footprinting** | github.com | Infrastructure Mappings | Documented |

### Final Summary
This multi-module implementation provided hands-on experience covering core components of security reconnaissance, process automation, active scanning, and OSINT asset verification. Building custom automation scripts highlights how modern teams minimize manual search routines to collect environment metrics at scale. Applying specialized network probes demonstrated the importance of precise version fingerprinting for risk analysis, while the external OSINT phase proved that rich system blueprints can be constructed using public records alone.

---

## 6. GitHub Repository

### Objective
The objective of this phase is to establish a secure, version-controlled source code management framework to track development artifacts, scripts, and deployment documentation.

### Version Control Platform
* **Hosting Service:** GitHub, Inc.
* **Tracking Engine:** Git Core v2.45+
* **Primary Branch:** `main`

### Repository Architecture Matrix
| Tracked File | File Execution Mode | Operational Description |
| :--- | :--- | :--- |
| `recon.sh` | Executable Script (`chmod +x`) | Automated Bash pipeline for passive subdomain discovery and active HTTP validation checks. |
| `README.md` | Markdown Document | Complete technical project blueprint, network logs, OSINT findings, and methodology reports. |

### Upstream Remote Link
All functional deployment files, modular logic scripts, and tracking configurations developed for this security blueprint are actively managed and publicly hosted at:  
 [https://github.com/jubinjvm822-sudo/PROJECT.git](https://github.com/jubinjvm822-sudo/PROJECT.git)
