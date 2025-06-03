# 🔐 FBSH

A simple and practical Bash script for basic Linux system security auditing.  
It provides quick insights into your system’s firewall status, open ports, privileged users, and more.

---

## ✅ What It Checks

- **Firewall** status via `ufw` and `iptables`  
- **Open ports** using `ss` or `netstat`  
- **Running services** (via `systemctl`)  
- **Users without passwords** (parsed from `/etc/shadow`)  
- **Users with sudo privileges**  
- **SSH port** (detect if default 22 is still in use)

---

## 🚀 Quick Start

### 🔧 Run directly using `curl`

```bash
bash <(curl -s https://raw.githubusercontent.com/hemansadeghi/FBSH/main/security-check.sh)
 

 or 

````bash 
git clone https://github.com/hemansadeghi/FBSH.git
cd FBSH
chmod +x security-check.sh
sudo ./security-check.sh

Output
Full log saved automatically to a file like:
security-report-20250603_144500.log

Best Practices
Review the script before execution on production systems.
Change the default SSH port (22) if detected.
Ensure all users have strong passwords.
Enable and configure your firewall (ufw or iptables).

🔒Requirements
Bash
sudo privileges
ufw, iptables, ss or netstat, systemctl

