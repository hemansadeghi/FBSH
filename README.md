# 🔐 FBSH – Fast Basic Security Hardening

```
                                           ,--, 
    ,---,.     ,---,.    .--.--.          ,--.'| 
  ,'  .' |   ,'  .'  \  /  /    '.     ,--,  | : 
,---.'   | ,---.' .' | |  :  /`. /  ,---.'|  : ' 
|   |   .' |   |  |: | ;  |  |--`   |   | : _' | 
:   :  :   :   :  :  / |  :  ;_     :   : |.'  | 
:   |  |-, :   |    ;   \  \    `.  |   ' '  ; : 
|   :  ;/| |   :     \   `----.   \ '   |  .'. | 
|   |   .' |   |   . |   __ \  \  | |   | :  | ' 
'   :  '   '   :  '; |  /  /`--'  / '   : |  : ; 
|   |  |   |   |  | ;  '--'.     /  |   | '  ,/  
|   :  \   |   :   /     `--'---'   ;   : ;--'   
|   | ,'   |   | ,'                 |   ,/       
`----'     `----'                   '---'        
```

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/language-Bash-blue.svg)](https://www.gnu.org/software/bash/)

A simple and practical Bash script for basic Linux system security auditing.  
It provides quick insights into your system’s security posture, highlighting weak spots and misconfigurations.

---

## ✅ What It Checks

* 🔥 **Firewall** status via `ufw`, `firewalld`, and `iptables`
* 🌐 **Open ports** using `ss` or `netstat`
* ⚙️ **Running services** via `systemctl`
* 🔐 **Users without passwords** (from `/etc/shadow`)
* 👑 **Users with sudo privileges**
* 🚪 **SSH port** – detects if default `22` is still in use
* 📆 **Vulnerable or outdated packages** via `apt`, `yum`, or `dnf`
* 📜 **Sudoers configuration** – checks for overly permissive `ALL` rules in `/etc/sudoers` and `/etc/sudoers.d`
* 🕵️‍♂️ **Rootkit detection** using `chkrootkit` and `rkhunter` (if installed)
* 💬 Displays a clear colored startup notification
* 🎨 Includes an ASCII art logo banner for better branding and UX
* 🕹️ Rootkit detection commands (`chkrootkit` and `rkhunter`) are run with a spinner animation for improved user experience.
* 📁 The complete security report is saved to a timestamped log file in the current working directory for review.
* ⚠️ Run the script as `root` or via `sudo` to ensure all checks perform correctly.


---

## 🚀 Quick Start

### 🧰 Option 1: Run directly using `curl`

```bash
bash <(curl -s https://raw.githubusercontent.com/hemansadeghi/FBSH/main/security-check.sh)
```

### 📦 Option 2: Clone and run manually

```bash
git clone https://github.com/hemansadeghi/FBSH.git
cd FBSH
chmod +x security-check.sh
sudo ./security-check.sh
```

> ℹ️ **Run as `root`** or with `sudo` to ensure full access to system checks.

---

## 🧪 Example Output

```bash
==> Firewall status (UFW + iptables)
UFW: Status: active
iptables is active. Sample rules:
...

==> Open ports
Netid State  Recv-Q Send-Q Local Address:Port ...

==> Users without password
All users have passwords.

==> Vulnerable/Upgradable packages
libssl1.1/bionic-updates 1.1.1-1ubuntu2.1~18.04.14 upgradable from 1.1.1-1ubuntu2.1~18.04.13

==> Custom sudoers entries
root ALL=(ALL:ALL) ALL

==> Rootkit detection
chkrootkit: Nothing found
rkhunter: [Warning] Possible suspicious file...
```

---

## 🔧 Optional Tools

If you want full rootkit checks, install:

```bash
# Debian/Ubuntu
sudo apt install chkrootkit rkhunter

# RHEL/CentOS/Fedora
sudo yum install chkrootkit rkhunter
```

---

## 📄 License

**MIT** – © Hemansadeghi, 2025  
Feel free to fork, customize, and contribute.
