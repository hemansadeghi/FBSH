#!/bin/bash

# ────────────────────────────────────────────────
# security-check.sh – FBSH: Basic Linux security audit
# Author: hemansadeghi
# License: MIT
# Date: 2025
# ────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

LOG_FILE="security-report-$(date +%Y%m%d_%H%M%S).log"
touch "$LOG_FILE"

# ───── LOGO ─────
echo -e "${CYAN}"
cat << "EOF"
                                             
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
EOF
echo -e "${NC}"

# ───── Functions ─────
print_section() {
  echo -e "\n${CYAN}==> $1${NC}"
  echo -e "\n==> $1" >> "$LOG_FILE"
}

log_msg() {
  local color="$1"
  local msg="$2"
  echo -e "${color}${msg}${NC}"
  echo "$msg" >> "$LOG_FILE"
}

echo -e "\n ${YELLOW}Starting security audit...${NC}\n"
echo " FBSH Security Report - $(date)" > "$LOG_FILE"

# 1. Firewall check (ufw + iptables)
print_section "Firewall status (UFW + iptables)"
if command -v ufw &>/dev/null; then
  UFW_STATUS=$(ufw status | grep Status)
  log_msg "$GREEN" "UFW: $UFW_STATUS"
else
  log_msg "$RED" "UFW is not installed."
fi

if command -v iptables &>/dev/null; then
  IPTABLES_RULES=$(iptables -L)
  if echo "$IPTABLES_RULES" | grep -q "ACCEPT"; then
    log_msg "$YELLOW" "iptables is active. Sample rules:"
    echo "$IPTABLES_RULES" | head -n 10 >> "$LOG_FILE"
  else
    log_msg "$RED" "iptables seems not configured."
  fi
else
  log_msg "$RED" "iptables is not installed."
fi

# 2. Open ports
print_section "Open ports"
if command -v ss &>/dev/null; then
  ss -tuln | tee -a "$LOG_FILE"
else
  netstat -tuln | tee -a "$LOG_FILE"
fi

# 3. Running services
print_section "Running services"
systemctl list-units --type=service --state=running | head -n 20 | tee -a "$LOG_FILE"

# 4. Users without password
print_section "Users without password"
awk -F: '($2==""){print $1}' /etc/shadow > /tmp/empty_pass_users.txt
if [ -s /tmp/empty_pass_users.txt ]; then
  log_msg "$RED" " Users without password:"
  cat /tmp/empty_pass_users.txt | tee -a "$LOG_FILE"
else
  log_msg "$GREEN" "All users have passwords."
fi
rm -f /tmp/empty_pass_users.txt

# 5. Users with sudo privileges
print_section "Users with sudo privileges"
getent group sudo | cut -d: -f4 | tr ',' '\n' | tee -a "$LOG_FILE"

# 6. SSH port check
print_section "SSH port check"
SSH_PORT=$(grep "^Port" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
if [ -z "$SSH_PORT" ]; then
  SSH_PORT=22
fi

if [ "$SSH_PORT" = "22" ]; then
  log_msg "$YELLOW" " SSH is running on default port (22). Consider changing it."
else
  log_msg "$GREEN" " SSH is running on custom port ($SSH_PORT)."
fi

echo -e "\n Full report saved to: ${YELLOW}${LOG_FILE}${NC}"
log_msg "$GREEN" "Security audit completed."
