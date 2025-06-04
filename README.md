# 🔐 FBSH

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

A simple and practical Bash script for basic Linux system security auditing.  
It provides quick insights into your system’s firewall status, open ports, privileged users, and more.

---

## ✅ What It Checks

- 🔥 **Firewall** status via `ufw` and `iptables`  
- 🌐 **Open ports** using `ss` or `netstat`  
- ⚙️ **Running services** via `systemctl`  
- 🔐 **Users without passwords** (from `/etc/shadow`)  
- 👑 **Users with sudo privileges**  
- 🚪 **SSH port** – detect if default `22` is still in use

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

---

## 📄 License

MIT – © Hemansadeghi, 2025