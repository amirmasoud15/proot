#!/data/data/com.termux/files/usr/bin/bash

#############################################
#   Ubuntu PRoot-Distro Installer - Stage 1#
#   Professional Ubuntu Installation        #
#############################################

# Colors and Styles
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Unicode Characters
CHECK="✓"
CROSS="✗"
ARROW="➜"
SPINNER=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

# Clear screen function
clear_screen() {
    clear
}

# Show banner function
show_banner() {
    clear_screen
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║        ██╗   ██╗██████╗ ██╗   ██╗███╗   ██╗████████╗██╗ ║
║        ██║   ██║██╔══██╗██║   ██║████╗  ██║╚══██╔══╝██║ ║
║        ██║   ██║██████╔╝██║   ██║██╔██╗ ██║   ██║   ██║ ║
║        ██║   ██║██╔══██╗██║   ██║██║╚██╗██║   ██║   ██║ ║
║        ╚██████╔╝██████╔╝╚██████╔╝██║ ╚████║   ██║   ██║ ║
║         ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝ ║
║                                                          ║
║         Stage 1: PRoot-Distro Installation               ║
║              Ubuntu 24.04 LTS on Termux                  ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Progress display function
show_progress() {
    local message="$1"
    echo -e "${YELLOW}${ARROW}${NC} ${WHITE}${message}${NC}"
}

# Success display function
show_success() {
    local message="$1"
    echo -e "${GREEN}${CHECK}${NC} ${message}"
}

# Error display function
show_error() {
    local message="$1"
    echo -e "${RED}${CROSS}${NC} ${message}"
}

# Info display function
show_info() {
    local message="$1"
    echo -e "${BLUE}ℹ${NC} ${message}"
}

# Warning display function
show_warning() {
    local message="$1"
    echo -e "${YELLOW}⚠${NC} ${message}"
}

# Check if running in Termux
check_termux() {
    if [ ! -d "/data/data/com.termux" ]; then
        show_error "This script must be run in Termux!"
        exit 1
    fi
}

# Check available storage
check_storage() {
    local available=$(df -h $PREFIX | awk 'NR==2 {print $4}' | sed 's/G//')
    if (( $(echo "$available < 3" | bc -l 2>/dev/null || echo "0") )); then
        show_warning "Low storage space! At least 3GB recommended"
        read -p "Continue anyway? (y/n): " choice
        if [ "$choice" != "y" ] && [ "$choice" != "Y" ]; then
            exit 1
        fi
    fi
}

show_banner

echo ""
show_progress "Checking system requirements..."
check_termux
check_storage
show_success "System requirements verified"

echo ""
echo -e "${PURPLE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}              ${BOLD}System Information${NC}                        ${PURPLE}║${NC}"
echo -e "${PURPLE}╠════════════════════════════════════════════════════════╣${NC}"
echo -e "${PURPLE}║${NC}  Architecture: ${CYAN}$(uname -m)${NC}"
echo -e "${PURPLE}║${NC}  OS: ${CYAN}Android (Termux)${NC}"
echo -e "${PURPLE}║${NC}  Method: ${CYAN}proot-distro (Official)${NC}"
echo -e "${PURPLE}║${NC}  Available Space: ${CYAN}$(df -h $PREFIX | awk 'NR==2 {print $4}')${NC}"
echo -e "${PURPLE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

show_progress "Installing required Termux packages..."
echo ""

show_info "Updating Termux packages..."
pkg update -y > /dev/null 2>&1
show_success "Termux packages updated"

show_info "Installing proot-distro..."
pkg install -y proot-distro > /dev/null 2>&1
show_success "proot-distro installed"

echo ""
show_progress "Checking existing Ubuntu installation..."

# Check if Ubuntu is already installed
if proot-distro list | grep -q "ubuntu.*installed"; then
    echo ""
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║${NC}  ${BOLD}WARNING: Ubuntu is already installed${NC}                ${YELLOW}║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "$(echo -e ${RED}Do you want to remove it and reinstall? \(y/n\): ${NC})" choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        show_progress "Removing old Ubuntu installation..."
        proot-distro remove ubuntu > /dev/null 2>&1
        show_success "Old installation removed"
    else
        show_error "Installation cancelled"
        exit 1
    fi
fi

echo ""
echo -e "${PURPLE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  ${BOLD}Installing Ubuntu 24.04 LTS${NC}                           ${PURPLE}║${NC}"
echo -e "${PURPLE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

show_progress "Downloading and installing Ubuntu..."
show_info "This may take 5-15 minutes depending on your internet speed"
echo ""

# Install Ubuntu using proot-distro
proot-distro install ubuntu

if [ $? -ne 0 ]; then
    echo ""
    show_error "Failed to install Ubuntu"
    show_info "Please check your internet connection and try again"
    exit 1
fi

echo ""
show_success "Ubuntu installed successfully"

echo ""
show_progress "Creating convenience scripts..."

# Create ubuntu-root script (for root access)
cat > "$PREFIX/bin/ubuntu-root" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# Colors
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}Starting Ubuntu as root...${NC}"
proot-distro login ubuntu --user root
EOF

chmod +x "$PREFIX/bin/ubuntu-root"
show_success "ubuntu-root command created"

echo ""
show_progress "Configuring Ubuntu initial setup..."

# Create initial setup script inside Ubuntu
UBUNTU_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu"

cat > "$UBUNTU_ROOT/root/setup.sh" << 'SETUPEOF'
#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

export DEBIAN_FRONTEND=noninteractive

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    Ubuntu 24.04 Initial Setup          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}➜${NC} Updating system packages..."
apt update > /dev/null 2>&1
apt upgrade -y > /dev/null 2>&1
echo -e "${GREEN}✓${NC} System updated"

echo -e "${YELLOW}➜${NC} Installing essential packages..."
apt install -y \
    sudo \
    nano \
    vim \
    wget \
    curl \
    git \
    net-tools \
    iputils-ping \
    locales \
    dialog \
    apt-utils \
    software-properties-common \
    ca-certificates \
    gnupg \
    lsb-release \
    dbus-x11 > /dev/null 2>&1
echo -e "${GREEN}✓${NC} Essential packages installed"

echo -e "${YELLOW}➜${NC} Configuring locale..."
locale-gen en_US.UTF-8 > /dev/null 2>&1
update-locale LANG=en_US.UTF-8
echo -e "${GREEN}✓${NC} Locale configured"

echo -e "${YELLOW}➜${NC} Setting up timezone..."
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
echo -e "${GREEN}✓${NC} Timezone set to UTC"

# Fix for PRoot environment
echo -e "${YELLOW}➜${NC} Configuring PRoot environment..."
echo "export PULSE_SERVER=127.0.0.1" >> /etc/profile
echo "export DISPLAY=:1" >> /etc/profile
echo -e "${GREEN}✓${NC} Environment configured"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ Initial setup completed!            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "${YELLOW}  1. Create user: ${NC}bash /root/user.sh"
echo -e "${YELLOW}  2. Install desktop: ${NC}bash /root/end.sh"
echo ""
SETUPEOF

chmod +x "$UBUNTU_ROOT/root/setup.sh"
show_success "Setup script created"

# Create README
cat > "$UBUNTU_ROOT/root/README.txt" << 'READMEEOF'
╔════════════════════════════════════════════════════╗
║       Welcome to Ubuntu on Termux! 🚀              ║
║          Powered by proot-distro                   ║
╚════════════════════════════════════════════════════╝

QUICK START:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

From Termux:
  ubuntu             - Start Ubuntu with your user
  ubuntu-root        - Start Ubuntu as root

Inside Ubuntu:
  bash /root/setup.sh    - Run initial setup
  bash /root/user.sh     - Create new user
  bash /root/end.sh      - Install desktop & apps

USEFUL COMMANDS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

From Termux:
  proot-distro login ubuntu              - Login to Ubuntu
  proot-distro login ubuntu --user root  - Login as root
  proot-distro backup ubuntu             - Backup Ubuntu
  proot-distro restore ubuntu            - Restore Ubuntu
  proot-distro remove ubuntu             - Remove Ubuntu

ADVANTAGES OF PROOT-DISTRO:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Official Termux tool
✓ Easy management
✓ Automatic updates
✓ Better performance
✓ Multiple distro support
✓ Backup/Restore features

Enjoy! 🎉
READMEEOF

show_success "README created"

echo ""
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                          ║${NC}"
echo -e "${GREEN}║        ✓ Ubuntu Installation Completed Successfully!     ║${NC}"
echo -e "${GREEN}║                                                          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}Quick Start Guide${NC}                                        ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}1.${NC} Start Ubuntu:"
echo -e "   ${GREEN}ubuntu${NC}"
echo -e "   ${WHITE}(will login with your created user)${NC}"
echo ""
echo -e "${YELLOW}2.${NC} Run initial setup (inside Ubuntu):"
echo -e "   ${GREEN}bash /root/setup.sh${NC}"
echo ""
echo -e "${YELLOW}3.${NC} Create user (inside Ubuntu):"
echo -e "   ${GREEN}bash /root/user.sh${NC}"
echo ""
echo -e "${YELLOW}4.${NC} Install Desktop & Software (inside Ubuntu):"
echo -e "   ${GREEN}bash /root/end.sh${NC}"
echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  ${BOLD}Useful Commands${NC}                                          ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}From Termux:${NC}"
echo -e "  ${GREEN}ubuntu${NC}                    - Start Ubuntu with your user"
echo -e "  ${GREEN}ubuntu-root${NC}               - Start Ubuntu as root"
echo -e "  ${GREEN}proot-distro backup ubuntu${NC} - Backup your Ubuntu"
echo -e "  ${GREEN}proot-distro list${NC}         - List all distros"
echo ""
echo -e "${CYAN}Advantages of proot-distro:${NC}"
echo -e "  ${BLUE}•${NC} Official Termux tool"
echo -e "  ${BLUE}•${NC} Easy backup/restore"
echo -e "  ${BLUE}•${NC} Better performance"
echo -e "  ${BLUE}•${NC} Automatic updates"
echo -e "  ${BLUE}•${NC} Multiple distro support"
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

# Clear screen after 1 second
sleep 1
clear
