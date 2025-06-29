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

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run this script as root.${NC}"
  exit 1
fi

LOG_FILE="security-report-$(date +%Y%m%d_%H%M%S).log"
touch "$LOG_FILE"

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

echo -e "\n ${YELLOW}Starting security audit...${NC}\n"
echo " FBSH Security Report - $(date)" > "$LOG_FILE"

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

# ─────────────── FIREWALL CHECK ───────────────
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

# ─────────────── OPEN PORTS ───────────────
print_section "Open ports"
if command -v ss &>/dev/null; then
  ss -tuln | tee -a "$LOG_FILE"
else
  netstat -tuln | tee -a "$LOG_FILE"
fi

# ─────────────── RUNNING SERVICES ───────────────
print_section "Running services"
systemctl list-units --type=service --state=running | head -n 20 | tee -a "$LOG_FILE"

# ─────────────── EMPTY PASSWORD USERS ───────────────
print_section "Users without password"
awk -F: '($2==""){print $1}' /etc/shadow > /tmp/empty_pass_users.txt
if [ -s /tmp/empty_pass_users.txt ]; then
  log_msg "$RED" " Users without password:"
  cat /tmp/empty_pass_users.txt | tee -a "$LOG_FILE"
else
  log_msg "$GREEN" "All users have passwords."
fi
rm -f /tmp/empty_pass_users.txt

# ─────────────── SUDO USERS ───────────────
print_section "Users with sudo privileges"
getent group sudo | cut -d: -f4 | tr ',' '\n' | tee -a "$LOG_FILE"

# ─────────────── SSH PORT ───────────────
print_section "SSH port check"
SSH_PORT=$(grep "^Port" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
[ -z "$SSH_PORT" ] && SSH_PORT=22

if [ "$SSH_PORT" = "22" ]; then
  log_msg "$YELLOW" " SSH is running on default port (22). Consider changing it."
else
  log_msg "$GREEN" " SSH is running on custom port ($SSH_PORT)."
fi

# ─────────────── CRON JOBS ───────────────
print_section "Cron Jobs"
echo -e "${CYAN}-- System-wide cron jobs (/etc/crontab and /etc/cron.*)${NC}"
cat /etc/crontab >> "$LOG_FILE" 2>/dev/null
echo "" >> "$LOG_FILE"

for dir in /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly; do
  echo -e "${CYAN}-- Jobs in $dir${NC}"
  ls -l "$dir" >> "$LOG_FILE" 2>/dev/null
  echo "" >> "$LOG_FILE"
done

echo -e "${CYAN}-- User cron jobs${NC}"
users=$(awk -F: '($7 !~ /(nologin|false)/) {print $1}' /etc/passwd)
for user in $users; do
  echo -e "${YELLOW}Cron jobs for user: $user${NC}"
  crontab -l -u "$user" >> "$LOG_FILE" 2>/dev/null || echo "No cron jobs for $user" >> "$LOG_FILE"
  echo "" >> "$LOG_FILE"
done

# ─────────────── PACKAGES ───────────────
print_section "Vulnerable/Upgradable packages"
if command -v apt &>/dev/null; then
  log_msg "$CYAN" "Using APT to check for upgradable packages..."
  apt list --upgradable 2>/dev/null | tee -a "$LOG_FILE"
elif command -v yum &>/dev/null; then
  log_msg "$CYAN" "Using YUM to check for available updates..."
  yum check-update | tee -a "$LOG_FILE"
elif command -v dnf &>/dev/null; then
  log_msg "$CYAN" "Using DNF to check for available updates..."
  dnf check-update | tee -a "$LOG_FILE"
else
  log_msg "$YELLOW" "No supported package manager (apt/yum/dnf) found to check updates."
fi

# ─────────────── SUDOERS ENTRIES ───────────────
print_section "Custom sudoers entries"
log_msg "$CYAN" "Scanning /etc/sudoers and /etc/sudoers.d/ for entries allowing ALL commands..."

if [ -f /etc/sudoers ]; then
  grep -rE '^[^#].*ALL' /etc/sudoers | tee -a "$LOG_FILE"
fi

if [ -d /etc/sudoers.d ]; then
  grep -rE '^[^#].*ALL' /etc/sudoers.d/ | tee -a "$LOG_FILE"
fi


# Spinner function for running commands with spinner
run_with_spinner() {
  # $1 = command to run (string)
  # $2 = message to display while running

  local cmd=$1
  local msg=$2
  local pid
  local spinner='|/-\'
  local i=0

  echo -ne "${CYAN}${msg}... ${NC}"

  bash -c "$cmd" >> "$LOG_FILE" 2>&1 &
  pid=$!

  while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) %4 ))
    printf "\b${spinner:$i:1}"
    sleep 0.2
  done
  wait $pid
  local status=$?

  if [ $status -eq 0 ]; then
    echo -e "\b${GREEN}done${NC}"
  else
    echo -e "\b${RED}failed${NC}"
  fi
  return $status
}

# ─────────────── ROOTKIT CHECK ───────────────
print_section "Rootkit detection"

if command -v chkrootkit &>/dev/null; then
  log_msg "$CYAN" "Running chkrootkit..."
  chkrootkit | tee -a "$LOG_FILE"
else
  log_msg "$YELLOW" "chkrootkit is not installed."
fi

if command -v rkhunter &>/dev/null; then
  log_msg "$CYAN" "Running rkhunter (this may take a while)..."
  rkhunter --check --sk | tee -a "$LOG_FILE"
else
  log_msg "$YELLOW" "rkhunter is not installed."
fi

# ─────────────── DONE ───────────────
log_msg "$GREEN" "Security audit completed."
echo -e "\n Full report saved to: ${YELLOW}${LOG_FILE}${NC}"
